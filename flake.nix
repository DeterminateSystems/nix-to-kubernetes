{
  description = "Deploying Nix to Nomad";

  outputs = { self, nixpkgs, flake-utils }:
    let
      name = "horoscope";
      dockerOrg = "detsys";
      goVersion = 19;
      goOverlay = self: super: {
        go = super."go_1_${toString goVersion}";
      };
      overlays = [ goOverlay ];
    in

    # Specific to CI environment
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit overlays;
            system = "x86_64-linux";
          };
        in
        {
          packages = rec {
            default = horoscope;

            horoscope = pkgs.buildGoModule {
              inherit name;
              src = ./.;
              vendorSha256 = "sha256-fwJTg/HqDAI12mF1u/BlnG52yaAlaIMzsILDDZuETrI=";
              CGO_ENABLED = 0;
            };

            docker =
              let
                run = "${horoscope}/bin/linux_amd64/${name}";
              in
              pkgs.dockerTools.buildLayeredImage {
                name = "${dockerOrg}/${name}";

                config.Cmd = [ run ];
              };
          };
        })

    //

    # Cross-platform logic
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ goOverlay ];
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs;
              [
                go
                jq
                nomad
              ];
          };
        });
}
