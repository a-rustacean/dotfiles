{ }:
{
  enable = true;
  defaultEditor = true;
  settings = {
    theme = "everblush_inherit_bg";
    editor = {
      line-number = "relative";
      true-color = true;
      cursor-shape.insert = "bar";
      file-picker.hidden = false;

      statusline = {
        left = [
          "mode"
          "spinner"
          "spacer"
          "spacer"
          "version-control"
        ];
        center = [
          "file-base-name"
          "file-modification-indicator"
        ];
        right = [
          "diagnostics"
          "selections"
          "position"
          "file-encoding"
          "file-line-ending"
          "file-type"
        ];
        separator = "|";
        mode.normal = "NOR";
        mode.insert = "INS";
        mode.select = "SEL";
      };

      lsp = {
        enable = true;
        display-messages = true;
        display-inlay-hints = true;
      };

      whitespace.render = {
        space = "all";
        nbsp = "all";
        tab = "all";
        newline = "none";
        tabpad = "all";
      };
    };
  };
  themes = {
    everblush_inherit_bg = {
      inherits = "everblush";
      "ui.background" = {};
    };
  };
}
