# TODO: Move teh files directory to a separate repo

#############
# Variables #
#############

cp files/variables.tf .

cat variables.tf

###############
# Credentials #
###############

open https://console.cloud.google.com

# Register if needed

# Log in if needed

# TODO: Instructions how to install `gcloud`

gcloud auth login

gcloud projects create devops-catalog

gcloud projects list

gcloud iam service-accounts \
    create devops-catalog \
    --project devops-catalog \
    --display-name devops-catalog

gcloud iam service-accounts list \
    --project devops-catalog

gcloud iam service-accounts \
    keys create account.json \
    --iam-account devops-catalog@devops-catalog.iam.gserviceaccount.com \
    --project devops-catalog

gcloud iam service-accounts \
    keys list \
    --iam-account devops-catalog@devops-catalog.iam.gserviceaccount.com \
    --project devops-catalog

gcloud projects \
    add-iam-policy-binding devops-catalog \
  --member serviceAccount:devops-catalog@devops-catalog.iam.gserviceaccount.com \
  --role roles/owner

cp files/provider.tf .

cat provider.tf

terraform apply

terraform init

terraform apply

###########
# Backend #
###########

open https://console.cloud.google.com/storage/browser?project=devops-catalog

# Click the *ENABLE BILLING* button. Follow the instructions.

cp files/storage.tf .

cat storage.tf

terraform apply

# Type `yes`

gsutil ls -p devops-catalog

terraform show

cat terraform.tfstate

cp files/backend.tf .

cat backend.tf

terraform apply

terraform init

terraform apply

#################
# Control Plane #
#################

cp files/k8s-control-plane.tf .

cat k8s-control-plane.tf

terraform apply

# Follow the link to enable *Kubernetes Engine API*

terraform apply

terraform apply

gcloud container get-server-config \
    --region=us-east1 \
    --project devops-catalog

# Replace `[...]` with the second to latest version
export K8S_VERSION=[...]

terraform apply \
    --var k8s_version=$K8S_VERSION

###########
# Outputs #
###########

cp files/output.tf .

cat output.tf

terraform refresh

terraform output cluster_name

export KUBECONFIG=$PWD/kubeconfig

gcloud container clusters \
    get-credentials $(terraform output cluster_name) \
    --project $(terraform output project_id) \
        --region $(terraform output region)

kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)

kubectl get nodes

################
# Worker Nodes #
################

cp files/k8s-worker-nodes.tf .

cat k8s-worker-nodes.tf

terraform apply \
    --var k8s_version=$K8S_VERSION

kubectl get nodes

###########
# Upgrade #
###########

kubectl version --output yaml

gcloud container get-server-config \
    --region=us-east1 \
    --project devops-catalog

# Replace `[...]` with the second to latest version
export K8S_VERSION=[...]

terraform apply \
    --var k8s_version=$K8S_VERSION

kubectl version --output yaml

###########
# Destroy #
###########

terraform destroy \
    --var k8s_version=$K8S_VERSION

gcloud projects delete devops-catalog
