{ config, pkgs, lib, ... }:
let baseConfig = import ../home.nix { inherit config pkgs lib; };
in {
  imports = [ ../home.nix ];

  home = {
    username = "dilshad";
    homeDirectory = "/home/dilshad";

    packages = baseConfig.home.packages ++ [ ];

    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "DMZ-White";
      size = 24;
      gtk.enable = true;
    };

    sessionVariables = {
      SSH_AUTH_SOCK = "${builtins.getEnv "XDG_RUNTIME_DIR"}/ssh-agent.socket";
    };
  };

  gtk = import ./gtk.nix { inherit pkgs; };
  xsession = {
    enable = true;
    windowManager.i3 = import ./i3.nix { inherit config pkgs; };
  };

  services.gpg-agent.enable = true;
  services.ssh-agent.enable = true;
  services.picom = import ./services/picom.nix { };
  services.dunst = import ./services/dunst.nix { };
}
