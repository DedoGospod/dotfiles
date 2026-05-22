-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Main Configuration Blocks
hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 2,
        border_size = 2,
        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = true,
        allow_tearing = true,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },
})

-- Animation curves
local animation_curves = {
    { name = "easeOutQuint",   type = "bezier", points = { {0.23, 1},    {0.32, 1}    } },
    { name = "easeInOutCubic", type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } },
    { name = "linear",         type = "bezier", points = { {0, 0},       {1, 1}       } },
    { name = "almostLinear",   type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } },
    { name = "quick",          type = "bezier", points = { {0.15, 0},    {0.1, 1}     } },
    { name = "easy",           type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 },
}

-- Animations
local animations = {
    { leaf = "global",         enabled = true,  speed = 10,   bezier = "default" },
    { leaf = "border",         enabled = true,  speed = 5.39, bezier = "easeOutQuint" },
    { leaf = "windows",        enabled = true,  speed = 4.79, spring = "easy" },
    { leaf = "windowsIn",      enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" },
    { leaf = "windowsOut",     enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" },
    { leaf = "fadeIn",         enabled = true,  speed = 1.73, bezier = "almostLinear" },
    { leaf = "fadeOut",        enabled = true,  speed = 1.46, bezier = "almostLinear" },
    { leaf = "fade",           enabled = true,  speed = 3.03, bezier = "quick" },
    { leaf = "layers",         enabled = true,  speed = 3.81, bezier = "easeOutQuint" },
    { leaf = "layersIn",       enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" },
    { leaf = "layersOut",      enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" },
    { leaf = "fadeLayersIn",   enabled = true,  speed = 1.79, bezier = "almostLinear" },
    { leaf = "fadeLayersOut",  enabled = true,  speed = 1.39, bezier = "almostLinear" },
    { leaf = "workspaces",     enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesIn",   enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" },
    { leaf = "workspacesOut",  enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" },
    { leaf = "zoomFactor",     enabled = true,  speed = 7,    bezier = "quick" },
}
---------------------
------- LOGIC -------
---------------------

-- Register Animation Curves
for _, curve in ipairs(animation_curves) do
    hl.curve(curve.name, {
        type = curve.type,
        points = curve.points,
        mass = curve.mass,
        stiffness = curve.stiffness,
        dampening = curve.dampening
    })
end

-- Apply Animations
for _, anim in ipairs(animations) do
    hl.animation(anim)
end
