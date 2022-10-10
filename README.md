# Nix to Kubernetes

## Setup

Enter Nix shell:

```shell
# If direnv is installed
direnv allow

# Otherwise
nix develop
```

Create resources:

```shell
terraform init
terraform validate
terraform apply -auto-approve
```

Set up your local [kubectl] environment:

```shell
K8S_CLUSTER_NAME="$(terraform output -raw k8s_cluster_name)"
doctl kubernetes cluster kubeconfig save "${K8S_CLUSTER_NAME}"
K8S_CONTEXT="$(terraform output -raw k8s_context)"
kubectx "${K8S_CONTEXT}"

# Verify that you can access the cluster by listing the nodes
kubectl get nodes
```

[kubeconfig]: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig
[kubectl]: https://kubernetes.io/docs/reference/kubectl
