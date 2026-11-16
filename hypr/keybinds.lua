---------------------
---- KEYBINDINGS ----
---------------------

local config = require("config");

local enableArrows = true
local movementKeys = { "H", "J", "K", "L" };
local directions   = { "left", "down", "up", "right" }

local mainMod      = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(config.programs.alacritty))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + ALT + Q", hl.dsp.exec_cmd(config.programs.hyprshutdown))
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(config.programs.hyprlock))
hl.bind(mainMod .. " + O", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(config.programs.quickshell .. " ipc call launcher toggle"))
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(config.programs.hyprpicker .. " --autocopy --format=hex"))

for i = 1, 4 do
  local dir = directions[i]
  local key = movementKeys[i]
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
  if enableArrows then
    hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
  end
end

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- TODO:
-- hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
--   { locked = true, repeating = true })
-- hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
--   { locked = true, repeating = true })
-- hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
--   { locked = true, repeating = true })
-- hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
--   { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("hyprctl hyprsunset gamma +10"), { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("hyprctl hyprsunset gamma -10"), { locked = true, repeating = true })

-- -- Requires playerctl
-- hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
