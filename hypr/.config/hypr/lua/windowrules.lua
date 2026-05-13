--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Floating windowrules
hl.window_rule({
    name  = "keepassxc_auth",
    match = {
        class = "^(org\\.keepassxc\\.KeePassXC)$",
        title = "^(Unlock Database - KeePassXC|KeePassXC - Browser Access Request)$"
    },
    float = true,
})

-- Gaming Rules
hl.window_rule({
    name  = "gaming_rules",
    match = {
        class = "^(steam_app_\\d+|steam_proton.*|gamescope|tf_linux64|cs2)$"
    },
    immediate  = true,
    workspace  = 10,
    fullscreen = 1,
    content    = "game",
})

-- Workspace Assignments
local assignments = {
    { class = "^(com\\.stremio\\.stremio)$",          ws = 3 },
    { class = "^(com\\.discordapp\\.Discord|steam)$", ws = 4 },
    { class = "^(virt-manager)$",                     ws = 9 },
    { class = "^(com\\.obsproject\\.Studio)$",        ws = "special:magic" },
}

for _, rule in ipairs(assignments) do
    hl.window_rule({
        match = { class = rule.class },
        workspace = tostring(rule.ws) .. " silent"
    })
end

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
