{
  pkgs,
  user,
  ...
}:

{
  imports = [
    ../../modules/home.nix
    ../../modules/rofi.nix
    ../../modules/hyprpaper.nix
    ../../modules/hypridle.nix
    ../../modules/hyprlock.nix
    ../../modules/hyprsunset.nix
    ../../modules/dunst.nix
    ../../modules/quickshell.nix
    ../../modules/gtk.nix
    ../../modules/cursor.nix
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
