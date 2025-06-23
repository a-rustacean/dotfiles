{ config, pkgs, lib, ... }:
let baseConfig = import ../home.nix { inherit config pkgs lib; };
in {
  imports = [ ../home.nix ];

  home = {
    packages = baseConfig.home.packages ++ [ ];

    activation = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in {
      copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        SOURCE_DIR=${apps}/Applications
        TARGET_DIR="$HOME/Applications/Home Manager Apps (Copied)"
        /usr/bin/sudo rm -rf "$TARGET_DIR"
        mkdir "$TARGET_DIR"
        ls "$TARGET_DIR"
        for SOURCE_FILE in $SOURCE_DIR/*; do
          TARGET_FILE="$TARGET_DIR/$(basename "$SOURCE_FILE")"
          $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$SOURCE_FILE" "$TARGET_FILE"
          $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$TARGET_FILE"
        done
      '';
    };
  };
}
