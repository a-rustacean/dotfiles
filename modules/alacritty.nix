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
      opacity = 0.85;
    };
  };
}
