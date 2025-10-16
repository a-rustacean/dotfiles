{ pkgs }:
{
  enable = true;
  extensions = [
    pkgs.gh-s
    pkgs.gh-i
    pkgs.gh-eco
    pkgs.gh-dash
    pkgs.gh-notify
    pkgs.gh-markdown-preview
  ];
  settings = {
    editor = "${pkgs.helix}/bin/hx";
    aliases = {
      co = "pr checkout";
      pv = "pr view";
    };
  };
}
