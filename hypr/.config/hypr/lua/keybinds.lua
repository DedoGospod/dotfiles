---------------------
---- KEYBINDINGS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "nautilus --new-window"
local menu        = "wofi --show drun"
local browser     = "brave"
local pypr        = "/usr/bin/pypr-client"
local scripts     = "$HOME/dotfiles/hypr/.config/hypr/scripts"

local mainMod = "SUPER"

-- Application Binds
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("flatpak run com.stremio.Stremio"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(scripts .. "/idle-inhibitor"))

-- Screenshot Utility
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m region"))

-- Pyprland
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(pypr .. " toggle obsidian"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd(pypr .. " toggle pavucontrol"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(pypr .. " toggle rmpc"))

-- Passthrough (Note the double backslash for Lua escaping)
hl.bind("CTRL + backslash", hl.dsp.exec_cmd("hyprctl dispatch pass 'class:^(com\\.obsproject\\.Studio)$' && " .. scripts .. "/obs-replay-notification"))

-- Window Management
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ state = 3 }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ state = 1 }))

-- Navigation (Vim-style)
local directions = { h = "left", l = "right", k = "up", j = "down" }
for key, dir in pairs(directions) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
end

-- Fixed Resize
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -20, y = 0 }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 20, y = 0 }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -20 }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 20 }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. tostring(key), hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. tostring(key), hl.dsp.window.move({ workspace = i, silent = true }))
end

-- Special Workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", silent = true }))

-- Mouse Binds
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Multimedia
local media_opts = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), media_opts)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), media_opts)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), media_opts)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), media_opts)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), media_opts)

-- Player Controls
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

