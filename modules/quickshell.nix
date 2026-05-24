{ inputs, system, ... }:
{
  programs.quickshell = {
    enable = true;
    package = inputs.quickshell.packages.${system}.default;
    activeConfig = "default";
    configs = {
      default = "${../quickshell}";
    };
  };
}
