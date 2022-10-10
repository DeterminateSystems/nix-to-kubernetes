{
  description = "Deploying Nix to Nomad";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      name = "horoscope";

      image = {
        inherit name;
        registry = "ghcr.io";
        owner = "DeterminateSystems";
      };

      vendorSha256 = "sha256-fwJTg/HqDAI12mF1u/BlnG52yaAlaIMzsILDDZuETrI=";

      goVersion = 19;
      goOverlay = self: super: {
        go = super."go_1_${toString goVersion}";
      };
      terraformOverlay = self: super: {
        terraform = super.terraform.overrideAttrs (_: {
          version = "1.3.2";
        });
      };
      overlays = [ goOverlay terraformOverlay ];
    in

    # Per-system outputs
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit overlays system;
          };

          printLatestImage = pkgs.writeScriptBin "print-latest-image" ''
            echo ${image.registry}/${image.owner}/${image.name}:latest | tr '[:upper:]' '[:lower:]'
          '';
        in
        {
          packages = rec {
            default = horoscope;

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

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs;
              [
                # Golang
                go
                gotools

                # Utilities
                jq
                printLatestImage

                # DevOps
                doctl # DigitalOcean CLI
                kubectl # Kubernetes CLI
                kubectx # Kubernetes context management utility
                terraform
              ];
          };
        });
}
