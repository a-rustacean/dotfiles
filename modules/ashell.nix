{ inputs, system, ... }:

{
  programs.ashell = {
    enable = true;
    package = inputs.ashell.packages.${system}.default;
    settings = {
      outputs = "All";
      position = "Top";
      layer = "Top";
      modules = {
        left = [
          "Workspaces"
        ];
        center = [
          "WindowTitle"
        ];
        right = [
          "MediaPlayer"
          "SystemInfo"
          [
            "Tempo"
            "Privacy"
            "Settings"
          ]
        ];
      };
      CustomModule = [ ];
      appearance = {
        style = "Islands";
        font_name = "Comic Sans MS";
        scale_factor = 1.2;
      };
    };
  };
}
