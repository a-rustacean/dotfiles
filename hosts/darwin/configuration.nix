{
  system,
  user,
  hostname,
  ...
}:
{
  imports = [ ../../modules/aerospace.nix ];
  nix = {
    enable = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ user ];
    };
  };

  nixpkgs = {
    hostPlatform = system;
    config.allowUnfree = true;
  };

  system = {
    primaryUser = user;
    stateVersion = 6;
    nixpkgsRelease = "26.05";

    defaults = {
      dock.autohide = true;
      dock.mru-spaces = false;
      dock.persistent-apps = [ ];
      dock.show-recents = false;
      finder.AppleShowAllExtensions = true;
      finder.FXPreferredViewStyle = "clmv";
      loginwindow.GuestEnabled = true;
      screencapture.disable-shadow = true;
      screencapture.location = "~/Pictures/screenshots";
      screensaver.askForPasswordDelay = 10;
    };
  };

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  networking.hostName = hostname;
}
