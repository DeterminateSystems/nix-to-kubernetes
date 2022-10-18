# Nix to Kubernetes

This repo provides an example of integrating [Nix] into a [DevOps] deployment
pipeline. The scenario:

* [Terraform] stands up a [Kubernetes] cluster on [DigitalOcean][do]
* [Nix] provides a development environment for a simple&mdash;okay,
  silly&mdash;[Go] web service that tells you your horoscope based on your star
  sign.
* Nix also builds a [Docker] image for the web service.
* A [GitHub Actions][actions] pipeline builds and then deploys the image to a
  [Kubernetes] cluster running on [DigitalOcean][do].

This repo was created in conjunction with [Deploying Nix-built containers to
Kubernetes][post], which is published on our [blog].

## Moving parts

* [Go web service](./cmd/horoscope)
* [Terraform config](./main.tf)
* [Terraform variable definitions](./variables.tf) and [variable
  values](./terraform.tfvars)
* [Kubernetes Deployment config](./kubernetes/deployment.yaml)
* A [Nix flake](./flake.nix) defines the development environment and package/app
  outputs
* [Nix-defined continous integration logic](./nix/ci.nix)
* [GitHub Actions pipeline](./.github/workflows/ci.yml). **Note**: the [`deploy`][deploy] job in the
  Actions pipeline is expected to fail, as it assumes that the Kubernetes cluster is currently
  running. We're gonna go ahead and save costs by `terraform destroy`ing the cluster when we're not
  using it 😀

The GitHub Actions pipeline includes Nix [remote caching][cache] provided by
[Cachix]. [GitHub Container Registry][ghcr] is used to store [Docker] images
built by Nix.

## Developing the scenario

See [DEVELOPMENT.md](./DEVELOPMENT.md) for instructions on standing up the
infrastructure and interacting with the cluster.

[actions]: https://github.com/features/actions
[blog]: https://determinate.systems/posts
[cache]: https://nixos.wiki/wiki/Binary_Cache
[cachix]: https://cachix.org
[deploy]: ./.github/workflows/ci.yml#L82
[devops]: https://atlassian.com/devops
[do]: https://digitalocean.com
[docker]: https://docker.com
[ghcr]: https://github.com/features/packages
[go]: https://golang.org
[kubernetes]: https://kubernetes.io
[nix]: https://nixos.org
[post]: https://determinate.systems/posts/nix-to-kubernetes
[terraform]: https://terraform.io

