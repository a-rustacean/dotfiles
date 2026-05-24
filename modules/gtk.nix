{ ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
