{ inputs, system, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland
    ];
    config.common.default = ["gtk" "hyprland"];
  };
}
