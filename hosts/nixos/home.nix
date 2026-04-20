{
  pkgs,
  user,
  ...
}:

{
  imports = [ ../../modules/home.nix ];
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";
  };

  wayland.windowManager.hyprland = import ../../modules/hyprland.nix { inherit pkgs; };
  programs.rofi = import ../../modules/rofi.nix { inherit pkgs; };
  services.hyprpaper = import ../../modules/hyprpaper.nix { };
}
