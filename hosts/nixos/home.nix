{
  pkgs,
  user,
  ...
}:

{
  imports = [
    ../../modules/home.nix
    ../../modules/rofi.nix
    ../../modules/hyprland.nix
    ../../modules/hyprpaper.nix
    ../../modules/hypridle.nix
    ../../modules/hyprlock.nix
    ../../modules/hyprsunset.nix
    ../../modules/dunst.nix
    ../../modules/quickshell.nix
    ../../modules/gtk.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";

    packages = with pkgs; [
      hyprpaper
      hyprshutdown
      hyprpicker
      cliphist
      wl-clipboard
      noto-fonts
      ranger
    ];

    file = {
      ".config/hypr" = {
        source = "${../../hyprland}";
        recursive = true;
      };
    };
  };

  services.hyprpolkitagent.enable = true;
}
