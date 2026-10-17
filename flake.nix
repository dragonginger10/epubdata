{
  description = "A Nix-flake-based Go development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # unstable Nixpkgs

  outputs =
    { self, ... }@inputs:

    let
      goVersion = 27; # Change this to update the whole stack

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: {
        go = final."go_1_${toString goVersion}";
      };

      packages = forEachSupportedSystem (
        { system, pkgs, ... }: rec {
          default = epubdata;
          epubdata = pkgs.buildGo127Module {
            pname = "epubdata";
            version = "0.0.1";

            src = ./.;
            vendorHash = "sha256-EytkffcdJ5HiPiHmIYspkMF1DGfeVDlFAiiNaVhbGeQ=";

          };

          library = pkgs.stdenvNoCC.mkDerivation {
            pname = "library";
            version = "alpha";

            propagatedBuildInputs = with pkgs; [
              fzf
              nushell
              self.packages.${system}.epubdata
            ];

            dontUnpack = ":";
            installPhass = "install -Dm755 ./library.nu $out/bin/library";
          };
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # go (version is specified by overlay)
              go

              # goimports, godoc, etc.
              gotools

              # https://github.com/golangci/golangci-lint
              golangci-lint

              self.formatter.${system}
            ];
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
