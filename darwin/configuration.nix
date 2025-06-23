{ pkgs, ... }:

{
  environment.systemPackages = [ ];

  nix.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  system.primaryUser = "dilshad";

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.dilshad = {
    name = "dilshad";
    home = "/Users/dilshad";
  };

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "Hello, Dilshad";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  networking.hostName = "work";

  services.aerospace = import ./aerospace.nix { inherit pkgs; };
}
