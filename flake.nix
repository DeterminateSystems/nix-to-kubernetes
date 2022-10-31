{
  description = "Deploying Nix-build Docker images to Kubernetes";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Application metadata
      name = "horoscope";

      image = {
        inherit name;
        registry = "ghcr.io";
        owner = "DeterminateSystems";
      };

      # Tool versions
      goVersion = 19;

      # The hash for the service's Go dependencies. Nix requires this to ensure
      # determinate builds.
      vendorSha256 = "sha256-fwJTg/HqDAI12mF1u/BlnG52yaAlaIMzsILDDZuETrI=";

      # An overlay for exposing a specific Go version as pkgs.go
      goOverlay = self: super: rec {
        go = super."go_1_${toString goVersion}";
      };

      # The combined overlays
      overlays = [ goOverlay ];
    in

    # Per-system outputs for the default systems here:
      # https://github.com/numtide/flake-utils/blob/master/default.nix#L3-L9
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          # Custom Nixpkgs for the current system and with overlay applied
          pkgs = import nixpkgs {
            inherit overlays system;
          };
        in
        {
          packages = rec {
            default = horoscope;

            # Our Go service as a standard Go module
            horoscope = pkgs.buildGoModule {
              inherit name vendorSha256;
              src = ./.;
            };

            # Intended only for CI. The image fails to run if you build this image on a
            # non-x86_64-linux system, despite the build succeeding. There are ways around this in
            # Nix but in this case we only need to build the image in CI.
            docker =
              pkgs.dockerTools.buildLayeredImage {
                name = "${image.registry}/${image.owner}/${image.name}";
                config = {
                  Cmd = [ "${self.packages.${system}.default}/bin/${name}" ];
                  ExposedPorts."8080/tcp" = { };
                };
                maxLayers = 120;
              };
          };

          # Cross-platform development environment (including CI)
          devShells.default = pkgs.mkShell {
            # Packages available in the environment
            buildInputs = with pkgs;
              [
                # Golang
                go
                gotools

                # Utilities
                jq
                graphviz # For visualizing the Terraform graph
                python39Packages.httpie

                # DevOps
                doctl # DigitalOcean CLI
                kubectl # Kubernetes CLI
                kubectx # Kubernetes context management utility
                terraform
              ];
          };

          # Enable running the service locally using `nix run`
          apps.default = flake-utils.lib.mkApp {
            drv = self.packages.${system}.default;
          };
        });
}
