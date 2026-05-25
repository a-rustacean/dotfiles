{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    hyprcursor = {
      enable = true;
      size = 18;
    };
    name = "capitaine-cursors";
    package = pkgs.capitaine-cursors;
  };
}
