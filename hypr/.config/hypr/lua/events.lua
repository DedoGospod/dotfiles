-- .config/hypr/lua/events.lua

-- local is_stremio_focused = false
-- hl.on("window.active", function(window)
    -- if window ~= nil and window.class == "com.stremio.Stremio" then
        -- if not is_stremio_focused then
            -- hl.exec_cmd("ddcutil setvcp 10 100 --async")
            -- is_stremio_focused = true
        -- end
    -- else
        -- if is_stremio_focused then
            -- hl.exec_cmd("ddcutil setvcp 10 50 --async")
            -- is_stremio_focused = false
        -- end
    -- end
-- end)

local is_game_active = false
hl.on("window.active", function(window)
    if window ~= nil and window.content_type == "game" then
        if not is_game_active then
            hl.exec_cmd("ddcutil setvcp 10 100 --async")
            hl.exec_cmd("systemctl --user stop hyprsunset.service")
            hl.exec_cmd("swaync-client -dn")
            is_game_active = true
        end
    else
        if is_game_active then
            hl.exec_cmd("ddcutil setvcp 10 50 --async")
            hl.exec_cmd("systemctl --user start hyprsunset.service")
            hl.exec_cmd("swaync-client -df")
            is_game_active = false
        end
    end
end)
