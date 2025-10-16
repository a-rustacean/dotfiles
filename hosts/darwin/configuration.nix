{
  pkgs,
  system,
  user,
  hostname,
  ...
}:
{
  nix.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = user;

  system.stateVersion = 6;

  users.users."${user}" = {
    name = user;
    home = "/Users/${user}";
  };

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  networking.hostName = hostname;

  services.aerospace = import ../../modules/aerospace.nix { inherit pkgs; };
}
