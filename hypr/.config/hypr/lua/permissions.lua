-----------------------
----- PERMISSIONS -----
-----------------------

-- Global config stays separate
hl.config({
  ecosystem = {
    enforce_permissions = true,
  },
})

-- A single, structured list for all your security rules
local permission_rules = {
  -- Screencopy permissions
  { binary = "/usr/bin/grim",                        type = "screencopy", mode = "allow" },
  { binary = "/usr/bin/hyprlock",                    type = "screencopy", mode = "allow" },
  { binary = "/usr/bin/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" },
}

---------------
---- LOGIC ----
---------------

-- Loop through and apply everything in one go
for _, rule in ipairs(permission_rules) do
  hl.permission({
    binary = rule.binary,
    type = rule.type,
    mode = rule.mode
  })
end
