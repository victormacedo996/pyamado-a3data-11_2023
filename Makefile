.PHONY: all check-dependencies

.DEFAULT_GOAL := help 

help: ## Show this help
		@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'


V1_POD := `kubectl get pod -n test -l app=sd-example,version=v1 -o jsonpath={.items..metadata.name}`
V2_POD := `kubectl get pod -n test -l app=sd-example,version=v2 -o jsonpath={.items..metadata.name}`
SLEEP_POD := `kubectl get pod -n test -l app=sleep -o jsonpath={.items..metadata.name}`
KNATIVE_POD := `kubectl get pod -n test -l app=sleep -o jsonpath={.items..metadata.name}`
ISTIO_PORT := `kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}'`


check-dependencies: ## Check dependencies
	@docker --version
	@kubectl version
	@helm version

install-knative: all check-dependencies ## Install Knative with Istio
	@kubectl apply -f infraestructure/manifests/knative/serving-crds.yaml
	@kubectl apply -f infraestructure/manifests/knative/serving-core.yaml
	@kubectl apply -l knative.dev/crd-install=true -f infraestructure/manifests/istio/istio.yaml
	@kubectl apply -f infraestructure/manifests/istio/istio.yaml
	@kubectl apply -f infraestructure/manifests/knative/net-istio.yaml
	@kubectl patch configmap/config-domain \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"example.com":""}}'
	@kubectl --namespace istio-system get service istio-ingressgateway


# install-prometheus: all check-dependencies ## Install Prometheus
# 	@helm upgrade --install prometheus --repo=https://prometheus-community.github.io/helm-charts \
# 			--namespace=prometheus \
# 			--create-namespace \
# 			prometheus
	
# install-grafana: all check-dependencies ## Install Granafa
# 	@helm upgrade --install grafana --repo=https://grafana.github.io/helm-charts \
# 		--namespace=grafana \
# 		--create-namespace \
# 		grafana

deploy-application: check-dependencies ## Install app
	@kubectl apply -f ./apps/api/kube/v1/namespace.yaml
	@kubectl apply -f ./apps/api/kube/v1
	@kubectl apply -f ./apps/api/kube/v2
	@kubectl apply -f ./apps/api/kube/sleep
	@kubectl apply -f ./apps/api/kube/virtual-services/destination-rule.yaml
	@kubectl apply -f ./apps/api/kube/virtual-services/sd-example-vsvc.yaml

shadow-traffic: check-dependencies ## Shadow traffic
	@kubectl apply -f ./apps/api/kube/virtual-services/mirror-traffic.yaml

log-app-1: check-dependencies ## Log APP_1
	@kubectl logs -n test -f ${V1_POD} -c sd-example --tail=0

log-app-2: check-dependencies ## Log APP_1
	@kubectl logs -n test -f ${V2_POD} -c sd-example --tail=0

port-forward-istio-gateway: check-dependencies ## Port forward for Istio Gateway
	@kubectl port-forward svc/istio-ingressgateway -n istio-system ${ISTIO_PORT}:80

request: ## Send request from within the sleep pod
	@kubectl exec -n test "${SLEEP_POD}" -c sleep -- curl -sS http://sd-example:8000/


knative-request: ## Send request from within the sleep pod
	@curl -sS -H "Host: hello.test.example.com" http://127.0.0.1:${ISTIO_PORT}
