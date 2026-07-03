local is_stremio_focused = false

hl.on("window.active", function(window)
    if window ~= nil and window.class == "com.stremio.stremio" then
        if not is_stremio_focused then
            hl.exec_cmd("ddcutil setvcp 10 100 --async")
            is_stremio_focused = true
        end
    else
        if is_stremio_focused then
            hl.exec_cmd("ddcutil setvcp 10 50 --async")
            is_stremio_focused = false
        end
    end
end)
