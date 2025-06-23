{ config, pkgs, }:
let
  nixGL = import <nixgl> { };
  common = import ../common.nix { };

  modifier = if common.wm.modifier == "alt" then
    "Mod1"
  else if common.wm.modifier == "cmd" then
    "Mod4"
  else if common.wm.modifier == "ctrl" then
    "Ctrl"
  else if common.wm.modifier == "shift" then
    "Shift"
  else
    builtins.throw "Invalid modifier `${common.wm.modifier}`";

  secondary_modifier = if common.wm.secondary_modifier == "alt" then
    "Mod1"
  else if common.wm.secondary_modifier == "cmd" then
    "Mod4"
  else if common.wm.secondary_modifier == "ctrl" then
    "Ctrl"
  else if common.wm.secondary_modifier == "shift" then
    "Shift"
  else
    builtins.throw "Invalid secondary modifier `${common.wm.modifier}`";

  refreshI3status = "killall -SIGUSR1 i3status";
in {
  enable = true;
  config = {
    fonts = {
      names = [ "pango" ];
      size = 8.0;
    };
    modifier = modifier;
    floating = {
      modifier = modifier;
      border = 0;
      titlebar = false;
    };
    window = {
      border = 0;
      titlebar = false;
    };
    startup = [
      {
        command = "${pkgs.dex} --autostart --environment i3";
        notification = false;
      }
      {
        command = "${pkgs.xss-lock} --transfer-sleep-lock -- i3lock --nofork";
        notification = false;
      }
      {
        command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        notification = false;
      }
      {
        command =
          "${nixGL.auto.nixGLDefault}/bin/nixGL ${pkgs.picom}/bin/picom -b";
        notification = false;
        always = true;
      }
      {
        command =
          "${pkgs.hsetroot}/bin/hsetroot -full ${config.home.homeDirectory}/.wallpaper.png -tint \\#dfdecd -contrast 1.3";
        always = true;
      }
      { command = "i3-msg workspace 1"; }
    ];
    keybindings = {
      "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun";
      "${modifier}+Return" = "exec i3-sensible-terminal";
      "${modifier}+Shift+q" = "kill";

      "${modifier}+${common.keybindings.movement.left}" = "focus left";
      "${modifier}+${common.keybindings.movement.down}" = "focus down";
      "${modifier}+${common.keybindings.movement.up}" = "focus up";
      "${modifier}+${common.keybindings.movement.right}" = "focus right";

      "${modifier}+${secondary_modifier}+${common.keybindings.movement.left}" =
        "move left";
      "${modifier}+${secondary_modifier}+${common.keybindings.movement.down}" =
        "move down";
      "${modifier}+${secondary_modifier}+${common.keybindings.movement.up}" =
        "move up";
      "${modifier}+${secondary_modifier}+${common.keybindings.movement.right}" =
        "move right";

      # split in horizontal orientation
      "${modifier}+Ctrl+h" = "split h";

      # split in vertical orientation
      "${modifier}+Ctrl+v" = "split v";

      # enter fullscreen mode for the focused container
      "${modifier}+f" = "fullscreen toggle";

      # switch to workspace
      "${modifier}+1" = "workspace number 1";
      "${modifier}+2" = "workspace number 2";
      "${modifier}+3" = "workspace number 3";
      "${modifier}+4" = "workspace number 4";
      "${modifier}+5" = "workspace number 5";
      "${modifier}+6" = "workspace number 6";
      "${modifier}+7" = "workspace number 7";
      "${modifier}+8" = "workspace number 8";
      "${modifier}+9" = "workspace number 9";

      # move focused container to workspace
      "${modifier}+Shift+1" = "move container to workspace number 1";
      "${modifier}+Shift+2" = "move container to workspace number 2";
      "${modifier}+Shift+3" = "move container to workspace number 3";
      "${modifier}+Shift+4" = "move container to workspace number 4";
      "${modifier}+Shift+5" = "move container to workspace number 5";
      "${modifier}+Shift+6" = "move container to workspace number 6";
      "${modifier}+Shift+7" = "move container to workspace number 7";
      "${modifier}+Shift+8" = "move container to workspace number 8";
      "${modifier}+Shift+9" = "move container to workspace number 9";

      "${modifier}+Shift+c" = "reload";
      "${modifier}+Shift+r" = "restart";
      "${modifier}+Shift+e" = ''
        exec "${config.xsession.windowManager.i3.package}/bin/i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"'';

      # change container layout (stacked, tabbed, toggle split)
      "${modifier}+s" = "layout stacking";
      "${modifier}+w" = "layout tabbed";
      "${modifier}+e" = "layout toggle split";

      # toggle tiling / floating
      "${modifier}+Shift+space" = "floating toggle";

      # change focus between tiling / floating windows
      "${modifier}+space" = "focus mode_toggle";

      # focus the parent container
      "${modifier}+a" = "focus parent";

      # enter resize mode
      "${modifier}+r" = ''mod "resize"'';

      # Increase volume
      XF86AudioRaiseVolume =
        "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5% && ${refreshI3status}";
      # Decrease volume
      XF86AudioLowerVolume =
        "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5% && ${refreshI3status}";
      # Mute/unmute volume
      XF86AudioMute =
        "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && ${refreshI3status}";
      # Mute/unmute microphone
      XF86AudioMicMute =
        "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && ${refreshI3status}";

      # screenshot
      "Print" = ''
        exec --no-startup-id ${pkgs.maim}/bin/maim "${config.home.homeDirectory}/Pictures/Screenshots/$$(date).png"'';
      "${modifier}+Print" = ''
        exec --no-startup-id ${pkgs.maim}/bin/maim --window $$(${pkgs.xdotool}/bin/xdotool getactivewindow) "${config.home.homeDirectory}/Pictures/Screenshots/$$(date).png"'';
      "Shift+Print" = ''
        exec --no-startup-id ${pkgs.maim}/bin/maim --select "${config.home.homeDirectory}/Pictures/Screenshots/$$(date).png"'';

      # screenshot & copy to clipboard
      "Ctrl+Print" =
        "exec --no-startup-id ${pkgs.maim}/bin/maim | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
      "${modifier}+Ctrl+Print" =
        "exec --no-startup-id ${pkgs.maim}/bin/maim --window $$(${pkgs.xdotool}/bin/xdotool getactivewindow) | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
      "Ctrl+Shift+Print" =
        "exec --no-startup-id ${pkgs.maim}/bin/maim --select | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
    } // (if common.keybindings.movement.use_arrows then {
      "${modifier}+Left" = "focus left";
      "${modifier}+Down" = "focus down";
      "${modifier}+Up" = "focus up";
      "${modifier}+Right" = "focus right";

      "${modifier}+${secondary_modifier}+Left" = "move left";
      "${modifier}+${secondary_modifier}+Down" = "move down";
      "${modifier}+${secondary_modifier}+Up" = "move up";
      "${modifier}+${secondary_modifier}+Right" = "move right";
    } else
      { });
    gaps = {
      inner = common.wm.gaps.inner;
      outer = common.wm.gaps.outer;
    };
    modes = { };
    bars = [{ statusCommand = "${pkgs.i3status}/bin/i3status"; }];
  };
}
