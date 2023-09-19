# Deployment strategies

## Useful commands

### Figure out istio node port
`echo $(kubectl get svc $INGRESSGATEWAY --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')`

### curl the ksvc
`curl -H "Host: hello.test.example.com" http://127.0.0.1:32551`

### get the knative service url
`kubectl get ksvc -n namespace`

### get v1 pod name
`export V1_POD=$(kubectl get pod -n test -l app=httpbin,version=v1 -o jsonpath={.items..metadata.name})`

### get v2 pod name
`export V2_POD=$(kubectl get pod -n test -l app=httpbin,version=v2 -o jsonpath={.items..metadata.name})`

### get sleep pod name
`export SLEEP_POD=$(kubectl get pod -n test -l app=sleep -o jsonpath={.items..metadata.name})`

### curl from sleep pod
`kubectl exec -n test "${SLEEP_POD}" -c sleep -- curl -sS http://httpbin:8000/headers`

### get logs from app pods
`kubectl logs "$V1_POD" -c httpbin`