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

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme = "Adwaita";
    icon-theme = "Flat-Remix-Red-Dark";
    font-name = "Noto Sans Medium 11";
    document-font-name = "Noto Sans Medium 11";
    monospace-font-name = "Noto Sans Mono Medium 11";
  };
}
