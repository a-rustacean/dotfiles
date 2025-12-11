{ system }:
let
  isDarwin = builtins.match ".*darwin$" system != null;

  decorations = if isDarwin then "Buttonless" else "None";
in
{
  enable = true;
  settings = {
    general.live_config_reload = true;
    font = {
      size = 24.0;
      bold = {
        family = "JetBrainsMono Nerd Font Mono";
        style = "Bold";
      };
      italic = {
        family = "JetBrainsMono Nerd Font Mono";
        style = "Light Italic";
      };
      normal = {
        family = "JetBrainsMono Nerd Font Mono";
        style = "Medium";
      };
      glyph_offset = {
        x = 0;
        y = 0;
      };
    };
    window = {
      inherit decorations;
      dynamic_padding = true;
      startup_mode = "Windowed";
      dimensions = {
        columns = 120;
        lines = 30;
      };
      padding = {
        x = 10;
        y = 10;
      };
      opacity = 0.9;
    };
    colors = {
      primary = {
        background = "0x0d1117";
        foreground = "0xc9d1d9";
      };
      cursor = {
        text = "0x0d1117";
        cursor = "0xc9d1d9";
      };
      normal = {
        black = "0x484f58";
        red = "0xff7b72";
        green = "0x58a6ff";
        yellow = "0xd29922";
        blue = "0x58a6ff";
        magenta = "0xbc8cff";
        cyan = "0x39c5cf";
        white = "0xb1bac4";
      };
      bright = {
        black = "0x6e7681";
        red = "0xffa198";
        green = "0x79c0ff";
        yellow = "0xe3b341";
        blue = "0x79c0ff";
        magenta = "0xbc8cff";
        cyan = "0x39c5cf";
        white = "0xb1bac4";
      };
    };
  };
}
