{ pkgs }:
let
  prettierFor = lang: {
    command = "${pkgs.prettier}/bin/prettier";
    args = [
      "--parser"
      lang
    ];
  };
in
{
  enable = true;
  defaultEditor = true;
  settings = {
    theme = "everblush_inherit_bg";
    editor = {
      line-number = "relative";
      true-color = true;
      rulers = [
        80
        100
      ];
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
      "ui.background" = { };
    };
  };
  languages = {
    language = [
      {
        name = "html";
        formatter = prettierFor "html";
        auto-format = true;
      }
      {
        name = "css";
        formatter = prettierFor "css";
        auto-format = true;
      }
      {
        name = "javascript";
        formatter = prettierFor "javascript";
        auto-format = true;
      }
      {
        name = "typescript";
        formatter = prettierFor "typescript";
        auto-format = true;
      }
      {
        name = "tsx";
        formatter = prettierFor "typescript";
        auto-format = true;
      }
      {
        name = "json";
        # TODO: enable it after finding a good formatter, prettier sucks (? or prolly some other issue)
        auto-format = false;
      }
    ];
  };
}
