.PHONY: all 

.DEFAULT_GOAL := help 

help: ## Show this help
		@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

check-dependencies: ## Check dependencies
	@docker --version
	@kubectl version
	@helm version
	

install-knative: ## Install Knative with Istio
	@kubectl apply -f infraestructure/manifests/knative/serving-crds.yaml
	@kubectl apply -f infraestructure/manifests/knative/serving-core.yaml
	@kubectl apply -l knative.dev/crd-install=true -f infraestructure/manifests/knative/istio.yaml
	@kubectl apply -f infraestructure/manifests/knative/istio.yaml
	@kubectl apply -f infraestructure/manifests/knative/net-istio.yaml
	@kubectl patch configmap/config-domain \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"example.com":""}}'
	@kubectl --namespace istio-system get service istio-ingressgateway




	
