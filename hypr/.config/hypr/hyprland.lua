local core_modules = {
    "lua.permissions",
    "lua.monitors",
    "lua.ui",
    "lua.input",
    "lua.windowrules",
    "lua.keybinds",
    "lua.misc",
    "lua.events",
}
for _, module in ipairs(core_modules) do
    require(module)
end
