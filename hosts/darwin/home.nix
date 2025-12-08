{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../../modules/home.nix ];

  home = {
    activation =
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = [ "/Applications" ];
        };
      in
      {
        copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          SOURCE_DIR=${apps}/Applications
          TARGET_DIR="$HOME/Applications/Home Manager Apps (Copied)"

          /usr/bin/sudo rm -rf "$TARGET_DIR"
          mkdir -p "$TARGET_DIR"

          # Use rsync to copy folder contents, following symlinks
          $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -aL ''${VERBOSE_ARG:+-v} "$SOURCE_DIR/" "$TARGET_DIR/"

          # Ensure everything is writable afterwards
          $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$TARGET_DIR"
        '';
      };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
