# Deployment strategies

## Useful commands

### start kind cluster
`kind create cluster --name shadow-deploy`

### Figure out istio node port
`echo $(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')`

### Port forward istio ingress gateway

`k port-forward svc/istio-ingressgateway -n istio-system <NODE_PORT>:80`

### curl the ksvc
`curl -H "Host: hello.test.example.com" http://127.0.0.1:<NODE_PORT>`

### get the knative service url
`kubectl get ksvc -n namespace`

### get v1 pod name
`export V1_POD=$(kubectl get pod -n test -l app=sd-example,version=v1 -o jsonpath={.items..metadata.name})`

### get v2 pod name
`export V2_POD=$(kubectl get pod -n test -l app=sd-example,version=v2 -o jsonpath={.items..metadata.name})`

### get sleep pod name
`export SLEEP_POD=$(kubectl get pod -n test -l app=sleep -o jsonpath={.items..metadata.name})`

### curl from sleep pod
`kubectl exec -n test "${SLEEP_POD}" -c sleep -- curl -sS http://sd-example:8000/`

## get logs from V1_POD

`kubectl logs -n test -f $V1_POD -c sd-example --tail=0`

## get logs from V2_POD

`kubectl logs -n test -f $V2_POD -c sd-example --tail=0`



## Ordem para rodar o lab

### Knative

1. `make install-knative`
2. `kubectl apply -f apps/api/kube/knative/kservice.yaml`
3. `mostrar a aplicação escalar para 0 e o warm up`
4. `alterar as variaveis de ambiente do ksvc e aplicar de novo`
5. `make port-forward-istio-gateway`
6. `make knative-request`

### Shadow deployment
1. `make deploy-application`
2. Run `make request` a few times
3. `make shadow-traffic`
4. Open 3 terminals in the first run `make log-app-1`, in the second `make log-app-2`, finally, in the third `make request`