{ }: {
  keybindings = {
    movement = {
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      use_arrows = false;
    };
  };
  wm = {
    modifier = "alt"; # options: cmd, alt, ctrl, shift
    secondary_modifier =
      "shift"; # options: cmd, alt, ctrl, shift (must not be same as `modifier`)
    gaps = {
      outer = 0;
      inner = 8;
    };
    split = {
      vertical = "s";
      horizontal = "v";
    };
  };
}
