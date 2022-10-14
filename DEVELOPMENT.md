# Development

This document shows you how to run the scenario yourself. It's mostly here just
so I ([lucperkins]) don't forget how this all works 😀

First, create an account with [DigitalOcean][do] and then an API [token].

Create a `.env` file and fill out the missing token value:

```shell
# Provide a value for DIGITALOCEAN_TOKEN
cp .env.example .env
```

Enter the Nix shell:

```shell
# If direnv is installed
direnv allow

# Otherwise
nix develop
source .env
```

Visualize (just for fun):

```shell
terraform graph | dot -Tsvg > graph.svg
open graph.svg
```

Create resources:

```shell
# Install providers
terraform init
# Make sure `terraform apply` will succeed
terraform validate
# Stand up the infrastructure
terraform apply -auto-approve
```

Once that's done, set up your local [kubectl] environment to talk to the
[Kubernetes] cluster:

```shell
# Download the Kubernetes cluster config into ~/.kube/config
doctl kubernetes cluster kubeconfig save "$(terraform output -raw k8s_cluster_name)"

# Set the kubectl context to the DigitalOcean cluster
kubectx "$(terraform output -raw k8s_context)"

# Verify that you can access the cluster by listing the nodes
kubectl get nodes

# You should see output like this:
NAME              STATUS   ROLES    AGE   VERSION
k8s-nodes-75i7a   Ready    <none>   53m   v1.23.10
k8s-nodes-75i7e   Ready    <none>   53m   v1.23.10
k8s-nodes-75i7g   Ready    <none>   53m   v1.23.10
```

Once the cluster is ready, the [CI pipeline][ci] should work as expected. When
the pipeline finishes building/deploying, you can interact with the running
service via port forwarding:

```shell
kubectl port-forward deployments.apps/horoscope-deployment 8080:8080

# In another window (httpie is provided in the Nix environment)
http --body :8080/pisces
```

[ci]: ./.github/workflows/ci.yml
[do]: https://digitalocean.com
[kubeconfig]: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig
[kubectl]: https://kubernetes.io/docs/reference/kubectl
[kubernetes]: https://kubernetes.io
[lucperkins]: https://github.com/lucperkins
[token]: https://docs.digitalocean.com/reference/api/create-personal-access-token

