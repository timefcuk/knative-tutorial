#!/bin/bash

set -eu
set -o pipefail 

KSVC_NAME=${1:-'greeter'}

CURR_CTX=$(kubectl config current-context)

CURR_NS="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${CURR_CTX}\")].context.namespace}")" \
    || exit_err "error getting current namespace"

if [[ -z "${CURR_NS}" ]]; 
then
  CURR_NS='default'
else
  CURR_NS="${CURR_NS}"
fi

HOST_HEADER="Host:$KSVC_NAME.$CURR_NS.example.com"

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway \
  --namespace istio-system \
  --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

if [ $# -le 1 ]
then
  http GET $IP_ADDRESS "$HOST_HEADER" 
else
  echo "$2" | http --body POST $IP_ADDRESS "$HOST_HEADER" 'Content-Type: plain'
fi

exit_err() {
   echo >&2 "${1}"
   exit 1
}

exit 0
