local config = {
  programs = {
    alacritty = os.getenv("HYPRLAND_PROGRAM_ALACRITTY") or "alacritty",
    hyprpaper = os.getenv("HYPRLAND_PROGRAM_HYPRPAPER") or "hyprpaper",
    hyprlock = os.getenv("HYPRLAND_PROGRAM_HYPRLOCK") or "hyprlock",
    hyprshutdown = os.getenv("HYPRLAND_PROGRAM_HYPRSHUTDOWN") or "hyprshutdown",
    hyprpicker = os.getenv("HYPRLAND_PROGRAM_HYPRPICKER") or "hyprpicker",
    quickshell = os.getenv("HYPRLAND_PROGRAM_QUICKSHELL") or "qs",
    dunst = os.getenv("HYPRLAND_PROGRAM_DUNST") or "dunst",
  },
}

return config
