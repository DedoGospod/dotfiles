--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
local window_rules = {
    {
        name = "suppress-maximize-events",
        match = { class = ".*" },
        suppress_event = "maximize",
    },
    {
        name = "fix-xwayland-drags",
        match = {
            class      = "^$",
            title      = "^$",
            xwayland   = true,
            float      = true,
            fullscreen = false,
            pin        = false,
        },
        no_focus = true,
    },
    {
        -- Keepass floating authentication window
        name = "keepassxc_auth",
        match = {
            class = "^(org\\.keepassxc\\.KeePassXC)$",
            title = "^(Unlock Database - KeePassXC|KeePassXC - Browser Access Request)$"
        },
        float = true,
    },
    {
        -- Gaming rules
        name = "gaming_rules",
        match = { class = "^(steam_app_\\d+|steam_proton.*|gamescope|tf_linux64|cs2)$" },
        immediate  = true,
        workspace  = tostring(10) .. " silent",
        fullscreen = 1,
        content    = "game",
    },
    {
        name = "move-hyprland-run",
        match = { class = "hyprland-run" },
        move  = "20 monitor_h-120",
        float = true,
    },
}

-- Workspace Assignments
local assignments = {
    { class = "^(com\\.stremio\\.Stremio)$",          ws = 3 },
    { class = "^(com\\.discordapp\\.Discord|steam)$", ws = 4 },
    { class = "^(virt-manager)$",                     ws = 9 },
    { class = "^(com\\.obsproject\\.Studio)$",        ws = "special:magic" },
    { class = "^(opensnitch_ui)$",                    ws = "special:magic" },
}

-- Apply all rules automatically
for _, rule in ipairs(window_rules) do
    hl.window_rule(rule)
end

-- Apply the workspace assignments
for _, rule in ipairs(assignments) do
    hl.window_rule({
        match = { class = rule.class },
        workspace = tostring(rule.ws) .. " silent"
    })
end
