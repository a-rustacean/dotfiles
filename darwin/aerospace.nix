{ pkgs }:
let common = import ../common.nix { };
in {
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
        left = common.wm.gaps.outer + common.wm.gaps.inner;
        bottom = common.wm.gaps.outer + common.wm.gaps.inner;
        top = common.wm.gaps.outer + common.wm.gaps.inner;
        right = common.wm.gaps.outer + common.wm.gaps.inner;
      };
      inner = {
        vertical = common.wm.gaps.inner;
        horizontal = common.wm.gaps.inner;
      };
    };
    mode.main.binding = {
      "${common.wm.modifier}-enter" =
        "exec-and-forget ${pkgs.alacritty}/bin/alacritty";
      "${common.wm.modifier}-slash" = "layout tiles horizontal vertical";
      "${common.wm.modifier}-comma" = "layout accordion horizontal vertical";

      "${common.wm.modifier}-${common.keybindings.movement.left}" =
        "focus left";
      "${common.wm.modifier}-${common.keybindings.movement.down}" =
        "focus down";
      "${common.wm.modifier}-${common.keybindings.movement.up}" = "focus up";
      "${common.wm.modifier}-${common.keybindings.movement.right}" =
        "focus right";

      "${common.wm.modifier}-${common.wm.secondary_modifier}-${common.keybindings.movement.left}" =
        "move left";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-${common.keybindings.movement.down}" =
        "move down";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-${common.keybindings.movement.up}" =
        "move up";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-${common.keybindings.movement.right}" =
        "move right";

      "${common.wm.modifier}-minus" = "resize smart -50";
      "${common.wm.modifier}-equal" = "resize smart +50";

      "${common.wm.modifier}-1" = "workspace 1";
      "${common.wm.modifier}-2" = "workspace 2";
      "${common.wm.modifier}-3" = "workspace 3";
      "${common.wm.modifier}-4" = "workspace 4";
      "${common.wm.modifier}-5" = "workspace 5";
      "${common.wm.modifier}-6" = "workspace 6";
      "${common.wm.modifier}-7" = "workspace 7";
      "${common.wm.modifier}-8" = "workspace 8";
      "${common.wm.modifier}-9" = "workspace 9";

      "${common.wm.modifier}-${common.wm.secondary_modifier}-1" =
        "move-node-to-workspace 1";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-2" =
        "move-node-to-workspace 2";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-3" =
        "move-node-to-workspace 3";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-4" =
        "move-node-to-workspace 4";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-5" =
        "move-node-to-workspace 5";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-6" =
        "move-node-to-workspace 6";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-7" =
        "move-node-to-workspace 7";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-8" =
        "move-node-to-workspace 8";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-9" =
        "move-node-to-workspace 9";

      "${common.wm.modifier}-f" = "fullscreen";
    } // (if common.keybindings.movement.use_arrows then {
      "${common.wm.modifier}-left" = "focus left";
      "${common.wm.modifier}-down" = "focus down";
      "${common.wm.modifier}-up" = "focus up";
      "${common.wm.modifier}-right" = "focus right";

      "${common.wm.modifier}-${common.wm.secondary_modifier}-left" =
        "move left";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-down" =
        "move down";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-up" = "move up";
      "${common.wm.modifier}-${common.wm.secondary_modifier}-right" =
        "move right";
    } else
      { });
  };
}
