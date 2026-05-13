-----------------------
----- PERMISSIONS -----
-----------------------

hl.config({
  ecosystem = {
    enforce_permissions = true,
  },
})

-- Hyprshot
hl.permission({
    binary = "/usr/bin/grim",
    type = "screencopy",
    mode = "allow",
    allow = "allow"
})

-- Hyprlock
hl.permission({
    binary = "/usr/bin/hyprlock",
    type = "screencopy",
    mode = "allow",
    allow = "allow"
})

-- Desktop portal
hl.permission({
    binary = "/usr/bin/xdg-desktop-portal-hyprland",
    type = "screencopy",
    mode = "allow",
    allow = "allow"
})
