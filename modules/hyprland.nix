{ pkgs }:
let
  config = import ../config.nix { };
  mapModifier =
    m:
    if m == "super" then
      "SUPER"
    else if m == "alt" then
      "ALT"
    else if m == "ctrl" then
      "CTRL"
    else if m == "shift" then
      "SHIFT"
    else
      builtins.throw "Invalid modifier `${m}`";

  mod = mapModifier config.wm.modifier;
  smod = mapModifier config.wm.secondary_modifier;

  range = start: end: builtins.genList (n: start + n) (end - start + 1);
  strRange = start: end: map (i: toString i) (range start end);

  terminal = "${pkgs.alacritty}/bin/alacritty";
  menu = "${pkgs.rofi}/bin/rofi -show drun";
in
{
  enable = true;
  settings = {
    monitor = ",1920x1080,auto,1";

    env = [
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ];

    general = {
      gaps_in = 8;
      gaps_out = 16;

      border_size = 2;

      "col.active_border" = "rgba(22ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";

      resize_on_border = false;

      allow_tearing = false;

      layout = "dwindle";
    };

    decoration = {
      rounding = 10;
      rounding_power = 2;
      active_opacity = 0.90;
      inactive_opacity = 0.75;

      shawdow = {

      };
    };

    bind = [
      "${mod}, RETURN, exec, ${terminal}"
      "${mod}, SPACE, exec, ${menu}"
    ]
    ++ (map (workspace: "${mod}, ${workspace}, workspace, ${workspace}") (strRange 1 9))
    ++ (map (workspace: "${mod}_${smod}, ${workspace}, movetoworkspace, ${workspace}") (strRange 1 9));
  };
}
