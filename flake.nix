# See flake.lock for the specific Git revisions that our flake inputs are
# pinned to.
{
  description = "Deploying Nix-built Docker images to Kubernetes";

  # Flake inputs (the Nix code sources we need to rely on here)
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  # Flake outputs (the stuff we want to provide in this flake)
  outputs = inputs:
    let
      # Helpers for per-system outputs
      forSystem = s: f: inputs.nixpkgs.lib.genAttrs s (system: f {
        pkgs = import inputs.nixpkgs {
          inherit system;
          # Allow unfree packages like Terraform
          config.allowUnfree = true;
        };
      });

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forEachSupportedSystem = forSystem supportedSystems;
    in
    {
      # Cross-platform development environment (including CI)
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
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

      packages = forEachSupportedSystem ({ pkgs }: {
        # Our Go service as a standard Go module (Go 1.19)
        horoscope = pkgs.buildGoModule {
          name = "horoscope";
          # The calculated hash for the service's Go dependencies. Nix requires
          # this to ensure reproducible builds. Any time the Go dependencies
          # change, we need to update this.
          vendorHash = "sha256-rinpy8qlSpKg0N3KsuzD1FjkDh7maERVXd13urHGyU0=";
          src = ./.;
        };
      });

      # Intended only for CI. The image fails to run if you build it on a
      # non-`x86_64-linux` system, despite the build succeeding. There are
      # ways around this in Nix but in this case we only need to build the
      # image in CI.
      dockerImages =
        let
          image = {
            name = "horoscope";
            registry = "ghcr.io";
            owner = "DeterminateSystems";
          };
        in
        forEachSupportedSystem ({ pkgs }: {
          horoscope = pkgs.dockerTools.buildLayeredImage {
            name = "${image.registry}/${image.owner}/${image.name}";
            config = {
              Cmd = [ "${inputs.self.packages.x86_64-linux.horoscope}/bin/horoscope" ];
              ExposedPorts."8080/tcp" = { };
            };
            maxLayers = 120;
          };
        });
    };
}
