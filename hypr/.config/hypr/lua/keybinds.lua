--------------------------------------------------------------------------------
---- CONFIGURATION CONSTANTS ----
--------------------------------------------------------------------------------
local home       = os.getenv("HOME") or "/home/default"
local scripts    = home .. "/dotfiles/hypr/.config/hypr/scripts"
local pypr       = "pypr"

local mainMod    = "SUPER"
local modPlus    = mainMod .. " + "
local modShift   = mainMod .. " + SHIFT + "

local VOL_STEP   = "5%"
local BRIG_STEP  = "10%"
local SPECIAL_WS = "magic"

local keybinds = {
    {
        mod = modPlus,
        list = {
            ["Q"]     = "kitty",
            ["SPACE"] = "wofi --show drun",
            ["E"]     = "nautilus --new-window",
            ["W"]     = "brave",
            ["N"]     = "swaync-client -t -sw",
            ["M"]     = "flatpak run com.stremio.Stremio",
            ["P"]     = "hyprshot -m window",
            ["I"]     = scripts .. "/idle-inhibitor",
        }
    },
    {
        mod = modShift,
        list = {
            ["P"]     = "hyprshot -m region",
        }
    }
}

local scratchpads = {
    ["Q"]       = "obsidian",
    ["Z"]       = "pavucontrol",
    ["A"]       = "rmpc"
}

-- Multimedia mappings
local media = {
    ["XF86AudioRaiseVolume"]  = "wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. VOL_STEP .. "+",
    ["XF86AudioLowerVolume"]  = "wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. VOL_STEP .. "-",
    ["XF86AudioMute"]         = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
    ["XF86MonBrightnessUp"]   = "brightnessctl s " .. BRIG_STEP .. "+",
    ["XF86MonBrightnessDown"] = "brightnessctl s " .. BRIG_STEP .. "-",
    ["XF86AudioNext"]         = "playerctl next",
    ["XF86AudioPrev"]         = "playerctl previous",
    ["XF86AudioPlay"]         = "playerctl play-pause",
    ["XF86AudioPause"]        = "playerctl play-pause",
}

--------------------------------------------------------------------------------
---- SPECIAL CASES ----
--------------------------------------------------------------------------------

-- Window State
hl.bind(modPlus ..  "C",  hl.dsp.window.close())
hl.bind(modShift .. "M",  hl.dsp.exit())
hl.bind(modShift .. "V",  hl.dsp.window.float({ action = "toggle" }))
hl.bind(modShift .. "T",  hl.dsp.layout("togglesplit"))
hl.bind(modShift .. "F",  hl.dsp.window.fullscreen({ state = 3 }))
hl.bind(modPlus ..  "F",  hl.dsp.window.fullscreen({ state = 1 }))

-- Special Workspace
hl.bind(modPlus .. "S",  hl.dsp.workspace.toggle_special(SPECIAL_WS))
hl.bind(modShift .. "S", hl.dsp.window.move({workspace = "special:" .. SPECIAL_WS, follow = false }))

-- Mouse
hl.bind(modPlus .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(modPlus .. "mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(modPlus .. "mouse:272",  hl.dsp.window.drag(), { mouse = true })

-- Keybinding passthrough
local obs_match = "class:^(com\\.obsproject\\.Studio)$"
hl.bind("CTRL + backslash", hl.dsp.exec_cmd(string.format("hyprctl dispatch pass '%s' && %s/obs-replay-notification", obs_match, scripts)))

--------------------------------------------------------------------------------
---- BINDING ENGINE ----
--------------------------------------------------------------------------------

-- Application keybinds
for _, group in ipairs(keybinds) do
    for key, cmd in pairs(group.list) do
        hl.bind(group.mod .. key, hl.dsp.exec_cmd(cmd))
    end
end

-- Pyprland Toggle
for key, name in pairs(scratchpads) do
    hl.bind(modShift .. key, hl.dsp.exec_cmd(string.format("%s toggle %s", pypr, name)))
end

-- Multimedia & Player Controls
for key, cmd in pairs(media) do
    local is_player = key:find("AudioPlay") or key:find("Next") or key:find("Prev")
    local opts = is_player and { locked = true } or { locked = true, repeating = true }
    hl.bind(key, hl.dsp.exec_cmd(cmd), opts)
end

-- Navigation (Vim-style)
local dirs = { h = "left", l = "right", k = "up", j = "down" }
for key, dir in pairs(dirs) do
    hl.bind(modPlus .. key, hl.dsp.focus({ direction = dir }))
end

-- Workspaces (1-10)
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(modPlus .. key,  hl.dsp.focus({ workspace = i }))
    hl.bind(modShift .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end
