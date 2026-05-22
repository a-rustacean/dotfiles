{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../../modules/home.nix ];

  home = {
    packages = [ pkgs.betterdisplay ];

    activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /usr/bin/osascript -e "
        tell application \"Finder\"
          set desktop picture to POSIX file \"${../../wallpaper.jpg}\"
        end tell"
    '';
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
