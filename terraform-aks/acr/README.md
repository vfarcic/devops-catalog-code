## Create a cluster and a registry

```bash
export RANDOM_STRING=$(date +%Y%m%d%H%M%S)

export RESOURCE_GROUP=rg-$RANDOM_STRING

export ACR_NAME=acr$RANDOM_STRING

export CLUSTER_NAME=aks-$RANDOM_STRING

# NOTE: Using `az`, but it should be `terraform`

az group create \
    --name $RESOURCE_GROUP \
    --location eastus

az acr create \
    --name $ACR_NAME \
    --resource-group $RESOURCE_GROUP \
    --sku basic

az aks get-versions --location eastus

export K8S_VERSION=[...]

az aks create \
    --name $CLUSTER_NAME \
    --resource-group $RESOURCE_GROUP \
    --generate-ssh-keys \
    --attach-acr $ACR_NAME \
    --node-count 3 \
    --node-vm-size Standard_A2_v2 \
    --enable-cluster-autoscaler \
    --max-count 6
    --min-count 3

az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --file kubeconfig

export KUBECONFIG=$PWD/kubeconfig

kubectl get nodes
```

## Test the registry from a laptop

```bash
export ACR_SERVER=$ACR_NAME.azurecr.io

az acr login --name $ACR_NAME

docker image pull alpine

docker image tag alpine $ACR_SERVER/alpine

docker image push $ACR_SERVER/alpine
```

## Test the registry from the cluster

```bash
kubectl run alpine \
    --image $ACR_SERVER/alpine \
    --generator run-pod/v1 \
    -- sleep 10000

kubectl get pods
```

## Install JX

```bash
git clone \
    https://github.com/jenkins-x/jenkins-x-boot-config.git \
    environment-$CLUSTER_NAME-dev

cd environment-$CLUSTER_NAME-dev

export GH_OWNER=[...] # Replace `[...]` with the GitHub owner

cat jx-requirements.yml \
    | sed -e "s@clusterName: \"\"@clusterName: $CLUSTER_NAME@g" \
    | sed -e "s@environmentGitOwner: \"\"@environmentGitOwner: $GH_OWNER@g" \
    | sed -e "s@provider: gke@provider: kubernetes\\
  registry: $ACR_SERVER@g" \
    | tee jx-requirements.yml

cat ~/.docker/config.json

export REGISTRY_AUTH=[...] # Replace `[...]` with the `auth` value from `~/.docker/config.json`

export REGISTRY_IDENTITYTOKEN=[...] # Replace `[...]` with the `identitytoken` value from `~/.docker/config.json`

mkdir -p ~/.jx/localSecrets/$CLUSTER_NAME

echo "registry_auth: \"$REGISTRY_AUTH\"
registry_identitytoken: \"$REGISTRY_IDENTITYTOKEN\"" \
    | tee ~/.jx/localSecrets/$CLUSTER_NAME/registry.yaml

echo "jenkins-x-platform:
  PipelineSecrets:
    DockerConfig: |-
      {
        \"auths\":{
          \"$ACR_SERVER\":
            {
              \"auth\": {{ .Parameters.registry.registry_auth | quote}},
              \"identitytoken\": {{ .Parameters.registry.registry_identitytoken | quote}}
            }
        }
      }
docker-registry:
  enabled: false" \
    | tee kubeProviders/kubernetes/values.tmpl.yaml

# TODO: Switch to `env/values.tmpl.yaml`

# The `env/parameters.yaml` file does not exist.
# It is created only after the boot is run so we cannot modify it right away.
# TODO: Provide means to add values to `env/parameters.yaml` without running `jx boot`.

jx boot

# It will fail in the `install-jenkins-x` step

echo "registry:
  registry_auth: local:$CLUSTER_NAME/registry:registry_auth
  registry_identitytoken: local:$CLUSTER_NAME/registry:registry_identitytoken" \
    | tee -a env/parameters.yaml

jx boot --start-step install-jenkins-x

# Subsequential executions of the boot eliminate the additions to `env/parameters.yaml`.
# TODO: Figure out a different way to provide that info, or stop recreating `env/parameters.yaml`.
```

## Validate JX setup

```bash
kubectl get secret jenkins-docker-cfg -o yaml

export CONFIG_JSON=[...] # Replace `[...]` with the `config.json` value

echo $CONFIG_JSON | base64 -d

cat ~/.docker/config.json

# Compare the two outputs
 
cd ..

jx create quickstart \
    --filter golang-http \
    --project-name jx-go \
    --batch-mode

jx get activities \
    --filter jx-go \
    --watch

jx get activities \
    --filter environment-$CLUSTER_NAME-staging \
    --watch

kubectl --namespace jx-staging get pods

export ADDR=$(kubectl \
    --namespace jx-staging \
    get ing jx-go \
    --output jsonpath="{.spec.rules[0].host}")

curl $ADDR
```