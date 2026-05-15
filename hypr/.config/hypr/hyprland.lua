local core_modules = {
    "lua.permissions",
    "lua.monitors",
    "lua.theme",
    "lua.input",
    "lua.windowrules",
    "lua.keybinds",
    "lua.misc",
}
for _, module in ipairs(core_modules) do
    require(module)
end
