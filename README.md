# Nix to Kubernetes

This repo provides an example of integrating [Nix] into a [DevOps] deployment
pipeline. The scenario:

* [Terraform] stands up a [Kubernetes] cluster on [DigitalOcean][do]
* [Nix] provides a development environment for a simple&mdash;okay,
  silly&mdash;[Go] web service that tells you your horoscope based on your star
  sign.

This repo was created in conjunction with [Deploying Nix-built containers to
Kubernetes][post], which is published on our [blog].

## Moving parts

* [Go web service](./cmd/horoscope)
* [Terraform config](./main.tf)
* [Terraform variable definitions](./variables.tf) and [variable
  values](./terraform.tfvars)
* [Kubernetes Deployment config](./kubernetes/deployment.yaml)
* [Nix flake](./flake.nix)
* [Nix-defined continous integration logic](./nix/ci.nix)
* [GitHub Actions pipeline](./.github/workflows/ci.yml)

The GitHub Actions pipeline includes Nix [remote caching][cache] provided by
[Cachix]. [GitHub Container Registry][ghcr] is used to store [Docker] images
built by Nix.

[blog]: https://determinate.systems/posts
[cache]: https://nixos.wiki/wiki/Binary_Cache
[cachix]: https://cachix.org
[devops]: https://atlassian.com/devops
[do]: https://digitalocean.com
[docker]: https://docker.com
[ghcr]: https://github.com/features/packages
[go]: https://golang.org
[kubernetes]: https://kubernetes.io
[nix]: https://nixos.org
[post]: https://determinate.systems/posts/nix-to-kubernetes
[terraform]: https://terraform.io
