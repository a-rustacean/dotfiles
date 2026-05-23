{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../../modules/home.nix ];

  home = {
    packages = [
      pkgs.betterdisplay
      pkgs.utm
    ];

    activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /usr/bin/osascript -e "
        tell application \"Finder\"
          set desktop picture to POSIX file \"${../../wallpaper.jpg}\"
        end tell"
    '';
  };
}
