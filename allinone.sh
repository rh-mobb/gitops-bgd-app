## ArgoCD Install & Config
echo "## Deploy the ArgoCD infrastructure"
until oc apply -k bootstrap/; do sleep 2; done
sleep 60

oc patch subscriptions.operators.coreos.com/openshift-gitops-operator -n openshift-operators --type='merge' \
--patch '{ "spec": { "config": { "env": [ { "name": "DISABLE_DEX", "value": "false" } ] } } }'

oc patch argocd/openshift-gitops -n openshift-gitops --type='merge' \
--patch='{ "spec": { "dex": { "openShiftOAuth": true } } }'

oc patch ArgoCD/openshift-gitops -n openshift-gitops --type=merge -p '{"spec":{"rbac":{"defaultPolicy":"role:admin"}}}'

ARGOCD_ROUTE=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}{"\n"}')

while [ `curl -ks -o /dev/null -w "%{http_code}" https://$ARGOCD_ROUTE` != 200 ];do
        echo "waiting for ArgoCD"
        sleep 10
done
        echo "ArgoCD operator"

## Deployment of App of Apps through ArgoCD
echo "## Deploy an example of App of Apps in the Cluster"
oc apply -k gitops/applications/base
