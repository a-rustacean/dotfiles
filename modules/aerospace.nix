{ pkgs }:
let
  config = import ../config.nix { };
in
{
  enable = true;
  settings = {
    after-login-command = [ ];
    after-startup-command = [ ];
    accordion-padding = 30;
    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";
    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
    automatically-unhide-macos-hidden-apps = false;
    key-mapping.preset = "qwerty";

    gaps = {
      outer = {
        left = config.wm.gaps.outer + config.wm.gaps.inner;
        bottom = config.wm.gaps.outer + config.wm.gaps.inner;
        top = config.wm.gaps.outer + config.wm.gaps.inner;
        right = config.wm.gaps.outer + config.wm.gaps.inner;
      };
      inner = {
        vertical = config.wm.gaps.inner;
        horizontal = config.wm.gaps.inner;
      };
    };
    mode.main.binding = {
      "${config.wm.modifier}-enter" = "exec-and-forget ${pkgs.alacritty}/bin/alacritty";
      "${config.wm.modifier}-slash" = "layout tiles horizontal vertical";
      "${config.wm.modifier}-comma" = "layout accordion horizontal vertical";

      "${config.wm.modifier}-${config.keybindings.movement.left}" = "focus left";
      "${config.wm.modifier}-${config.keybindings.movement.down}" = "focus down";
      "${config.wm.modifier}-${config.keybindings.movement.up}" = "focus up";
      "${config.wm.modifier}-${config.keybindings.movement.right}" = "focus right";

      "${config.wm.modifier}-${config.wm.secondary_modifier}-${config.keybindings.movement.left}" =
        "move left";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-${config.keybindings.movement.down}" =
        "move down";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-${config.keybindings.movement.up}" =
        "move up";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-${config.keybindings.movement.right}" =
        "move right";

      "${config.wm.modifier}-minus" = "resize smart -50";
      "${config.wm.modifier}-equal" = "resize smart +50";

      "${config.wm.modifier}-1" = "workspace 1";
      "${config.wm.modifier}-2" = "workspace 2";
      "${config.wm.modifier}-3" = "workspace 3";
      "${config.wm.modifier}-4" = "workspace 4";
      "${config.wm.modifier}-5" = "workspace 5";
      "${config.wm.modifier}-6" = "workspace 6";
      "${config.wm.modifier}-7" = "workspace 7";
      "${config.wm.modifier}-8" = "workspace 8";
      "${config.wm.modifier}-9" = "workspace 9";

      "${config.wm.modifier}-${config.wm.secondary_modifier}-1" = "move-node-to-workspace 1";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-2" = "move-node-to-workspace 2";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-3" = "move-node-to-workspace 3";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-4" = "move-node-to-workspace 4";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-5" = "move-node-to-workspace 5";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-6" = "move-node-to-workspace 6";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-7" = "move-node-to-workspace 7";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-8" = "move-node-to-workspace 8";
      "${config.wm.modifier}-${config.wm.secondary_modifier}-9" = "move-node-to-workspace 9";

      "${config.wm.modifier}-f" = "fullscreen";
    }
    // (
      if config.keybindings.movement.use_arrows then
        {
          "${config.wm.modifier}-left" = "focus left";
          "${config.wm.modifier}-down" = "focus down";
          "${config.wm.modifier}-up" = "focus up";
          "${config.wm.modifier}-right" = "focus right";

          "${config.wm.modifier}-${config.wm.secondary_modifier}-left" = "move left";
          "${config.wm.modifier}-${config.wm.secondary_modifier}-down" = "move down";
          "${config.wm.modifier}-${config.wm.secondary_modifier}-up" = "move up";
          "${config.wm.modifier}-${config.wm.secondary_modifier}-right" = "move right";
        }
      else
        { }
    );
  };
}
