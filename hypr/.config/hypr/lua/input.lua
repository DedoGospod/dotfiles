---------------
---- INPUT ----
---------------

hl.config({
    input = {
        -- Keyboard settings
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        -- Mouse settings
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
        force_no_accel = true,
    },
})

-- Touchpad gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
