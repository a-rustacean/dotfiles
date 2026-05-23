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
    ../../modules/dunst.nix
    ../../modules/ashell.nix
  ];
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "26.05";

    packages = with pkgs; [
      hyprpaper
      cliphist
      wl-clipboard
      noto-fonts
      hyprshutdown
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
