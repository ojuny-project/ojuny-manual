{
  description = "Ojuny manual: the long-form guide, readable offline";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

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
      );

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${(mkManual pkgs)}/bin/ojuny-manual";
        };
      });

      checks = forAllSystems (pkgs: {
        default = mkCheck pkgs;
      });
    };
}
