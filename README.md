# Nix to Kubernetes

## Setup

Create an account with [DigitalOcean][do] and create a [token].

Create `.env` file and fill out missing values:

```shell
# Provide a value for DIGITALOCEAN_TOKEN
cp .env.example .env
```

Enter Nix shell:

```shell
# If direnv is installed
direnv allow

# Otherwise
nix develop
source .env
```

Create resources:

```shell
terraform init
terraform validate
terraform apply -auto-approve
```

Set up your local [kubectl] environment:

```shell
K8S_CLUSTER_NAME="nix-to-k8s"
# Download the Kubernetes cluster config into ~/.kube/config
doctl kubernetes cluster kubeconfig save "${K8S_CLUSTER_NAME}"
# Set the kubectl context to the DigitalOcean cluster
K8S_CONTEXT="$(terraform output -raw k8s_context)"
kubectx "${K8S_CONTEXT}"

# Verify that you can access the cluster by listing the nodes
kubectl get nodes

# You should see output like this:
NAME              STATUS   ROLES    AGE   VERSION
k8s-nodes-75i7a   Ready    <none>   53m   v1.23.10
k8s-nodes-75i7e   Ready    <none>   53m   v1.23.10
k8s-nodes-75i7g   Ready    <none>   53m   v1.23.10
```

[do]: https://digitalocean.com
[kubeconfig]: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig
[kubectl]: https://kubernetes.io/docs/reference/kubectl
[token]: https://docs.digitalocean.com/reference/api/create-personal-access-token
