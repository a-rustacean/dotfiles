{ pkgs }:

{
  enable = true;
  theme = {
    name = "Tokyonight-Dark";
    package = pkgs.tokyonight-gtk-theme;
  };
  font = {
    name = "Ubuntu";
    package = pkgs.ubuntu-sans;
  };
}
