{ ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          fit_mode = "cover";
          monitor = "";
          path = "${../wallpaper.jpg}";
        }
      ];
    };
  };
}
