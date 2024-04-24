# See flake.lock for the specific Git revisions that our flake inputs are
# pinned to.
{
  description = "Deploying Nix-built Docker images to Kubernetes";

  # Flake inputs (the Nix code sources we need to rely on here)
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Flake outputs (the stuff we want to provide in this flake)
  outputs = { self, nixpkgs, flake-utils }:
    let
      # Application metadata
      name = "horoscope";

      image = {
        inherit name;
        registry = "ghcr.io";
        owner = "DeterminateSystems";
      };

      # The calculated hash for the service's Go dependencies. Nix requires
      # this to ensure reproducible builds. Any time the Go dependencies
      # change, we need to update this.
      vendorHash = "sha256-cNcwAG7DliZbgb3AE7y8c8I2C/O1iaXHTdaHkJGtoEs=";
    in

    # Per-system outputs for the default systems here:
      # https://github.com/numtide/flake-utils/blob/master/default.nix#L3-L9
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          # Custom Nixpkgs for the current system
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages = rec {
            # Enables us to build the Go service by running plain old `nix build`
            default = horoscope;

            # Our Go service as a standard Go module (Go 1.19)
            horoscope = pkgs.buildGo122Module {
              inherit name vendorHash;
              src = ./.;
            };

            # Intended only for CI. The image fails to run if you build it on a
            # non-`x86_64-linux` system, despite the build succeeding. There are
            # ways around this in Nix but in this case we only need to build the
            # image in CI.
            docker =
              pkgs.dockerTools.buildLayeredImage {
                name = "${image.registry}/${image.owner}/${image.name}";
                config = {
                  Cmd = [ "${horoscope}/bin/${name}" ];
                  ExposedPorts."8080/tcp" = { };
                };
                maxLayers = 120;
              };
          };

          # Cross-platform development environment (including CI)
          devShells.default = pkgs.mkShell {
            # Packages available in the environment
            packages = with pkgs;
              [
                # Golang
                go_1_22
                gotools # goimports, etc.

                # Utilities
                jq
                graphviz # For visualizing the Terraform graph
                httpie # For arbitrary HTTP calls

                # DevOps
                doctl # DigitalOcean CLI
                kubectl # Kubernetes CLI
                kubectx # Kubernetes context management utility
                terraform # Infrastructure as code FTW
              ];
          };
        });
}
