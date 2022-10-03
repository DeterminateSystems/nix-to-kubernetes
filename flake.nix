{
  description = "Deploying Nix to Nomad";

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
      overlays = [ goOverlay ];
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
                nomad
                terraform
              ];
          };
        });
}
