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
      goLinuxBuildOverlay = self: super: {
        buildGoModuleLinuxAmd64 = super.buildGoModule.override {
          go = super.go // {
            GOOS = "linux";
            GOARCH = "amd64";
            CGO_ENABLED = 0;
          };
        };
      };
    in

    # Specific to CI environment
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ goOverlay goLinuxBuildOverlay ];
          };
        in
        {
          packages = rec {
            default = horoscope;

            horoscope = pkgs.buildGoModuleLinuxAmd64 {
              inherit name;
              src = ./.;
              vendorSha256 = "sha256-fwJTg/HqDAI12mF1u/BlnG52yaAlaIMzsILDDZuETrI=";
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
