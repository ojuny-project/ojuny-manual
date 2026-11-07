{
  description = "Ojuny manual: the long-form guide, readable offline";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      binaryInfo =
        if builtins.pathExists ./binary-url.json then
          builtins.fromJSON (builtins.readFile ./binary-url.json)
        else
          null;

      mkBinary =
        {
          system,
          tag ? (
            if binaryInfo == null then throw "ojuny-manual: binary-url.json is missing" else binaryInfo.latest
          ),
          package ? "ojuny-manual",
        }:
        let
          release =
            if binaryInfo == null then
              throw "ojuny-manual: binary-url.json is missing"
            else
              binaryInfo.releases.${tag}
                or (throw "ojuny-manual: release '${tag}' is not recorded in binary-url.json");
          packageInfo =
            release.packages.${package}
              or (throw "ojuny-manual: package '${package}' is not recorded in release '${tag}'");
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.callPackage ./nix/binary.nix {
          name = package;
          program = packageInfo.program or package;
          inherit (packageInfo) file;
          info = {
            inherit (binaryInfo) repo system;
            inherit (release) tag version;
            inherit (packageInfo) url hash;
          };
          postInstall = ''
            install -Dm644 ${./share/applications/ojuny-manual.desktop} "$out/share/applications/ojuny-manual.desktop"
            install -Dm644 ${./share/icons/hicolor/scalable/apps/ojuny-manual.svg} "$out/share/icons/hicolor/scalable/apps/ojuny-manual.svg"
          '';
        };

      mkBook =
        pkgs:
        pkgs.stdenvNoCC.mkDerivation {
          pname = "ojuny-manual-book";
          version = "0.1.0";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = [ pkgs.mdbook ];
          buildPhase = ''
            mdbook build
          '';
          installPhase = ''
            mkdir -p $out/share/ojuny-manual
            cp -r book $out/share/ojuny-manual/book
          '';
        };

      mkManual =
        pkgs:
        let
          inherit (pkgs) lib;
          book = mkBook pkgs;
        in
        pkgs.runCommand "ojuny-manual-0.1.0"
          {
            pname = "ojuny-manual";
            version = "0.1.0";
            nativeBuildInputs = [ pkgs.makeWrapper ];
            meta = {
              description = "Ojuny manual with an offline launcher and desktop entry";
              license = lib.licenses.gpl3Plus;
              mainProgram = "ojuny-manual";
              platforms = lib.platforms.linux;
            };
          }
          ''
            mkdir -p $out/bin $out/share/ojuny-manual $out/share/applications
            mkdir -p $out/share/icons/hicolor/scalable/apps

            cp -r ${book}/share/ojuny-manual/book $out/share/ojuny-manual/book
            install -Dm644 ${./src/SUMMARY.md} $out/share/ojuny-manual/SUMMARY.md

            install -Dm755 ${./bin/ojuny-manual} $out/bin/ojuny-manual
            install -Dm644 ${./share/applications/ojuny-manual.desktop} $out/share/applications/ojuny-manual.desktop
            install -Dm644 ${./share/icons/hicolor/scalable/apps/ojuny-manual.svg} $out/share/icons/hicolor/scalable/apps/ojuny-manual.svg

            wrapProgram $out/bin/ojuny-manual \
              --set OJUNY_MANUAL_HOME $out/share/ojuny-manual \
              --prefix PATH : ${
                lib.makeBinPath [
                  pkgs.w3m
                  pkgs.python3
                  pkgs.xdg-utils
                ]
              }

            patchShebangs $out/bin
          '';

      mkCheck =
        pkgs:
        let
          manual = mkManual pkgs;
        in
        pkgs.runCommand "ojuny-manual-check" { } ''
          test -f ${manual}/share/ojuny-manual/book/index.html

          ${pkgs.dash}/bin/dash -n ${./bin/ojuny-manual}

          ${manual}/bin/ojuny-manual --path
          test "$(${manual}/bin/ojuny-manual --path)" = "${manual}/share/ojuny-manual/book/index.html"
          ${manual}/bin/ojuny-manual --list | grep -qx 'Reading offline'

          test -f ${manual}/share/applications/ojuny-manual.desktop
          grep -qx 'Exec=ojuny-manual --gui' ${manual}/share/applications/ojuny-manual.desktop
          grep -qx 'Terminal=false' ${manual}/share/applications/ojuny-manual.desktop

          touch $out
        '';
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          manual = mkManual pkgs;
        in
        {
          default = manual;
          book = mkBook pkgs;
        }
        // (
          if binaryInfo != null && binaryInfo.system == pkgs.stdenv.hostPlatform.system then
            {
              ojuny-manual-binary = mkBinary { system = pkgs.stdenv.hostPlatform.system; };
            }
          else
            { }
        )
      );

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${(mkManual pkgs)}/bin/ojuny-manual";
        };
        ci = {
          type = "app";
          program = "${
            pkgs.writeShellApplication {
              name = "ci";
              runtimeInputs = [ pkgs.nix ];
              text = ''
                exec nix flake check "$@"
              '';
            }
          }/bin/ci";
        };
      });

      checks = forAllSystems (pkgs: {
        default = mkCheck pkgs;

        manual-summary =
          let
            source = pkgs.lib.cleanSource ./.;
          in
          pkgs.runCommand "check-manual-summary" {
            nativeBuildInputs = [ pkgs.python3 ];
          } ''
            python3 - ${source} <<'PY'
import os
import re
import sys

root = sys.argv[1]
summary = os.path.join(root, "src/SUMMARY.md")
if not os.path.exists(summary):
    raise SystemExit("missing src/SUMMARY.md")
text = open(summary, encoding="utf-8").read()
missing = [
    link
    for link in re.findall(r"\]\(([^)]+\.md)\)", text)
    if not os.path.exists(os.path.join(root, "src", link))
]
if missing:
    print("\n".join(missing))
    raise SystemExit(1)
PY
            touch $out
          '';
      });

      hydraJobs = self.checks;

      lib.mkBinary = mkBinary;
    };
}
