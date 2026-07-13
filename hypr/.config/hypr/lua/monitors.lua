------------------
---- MONITORS ----
------------------

-- Gigabyte MO27Q2
hl.monitor({
    output   = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. MO27Q2",
    mode     = "2560x1440@240",
    position = "0x0",
    scale    = "1",
    bitdepth = 10,
    supports_hdr = 1,
})

-- Render config
hl.config({
    render = {
        cm_auto_hdr = 1,
        direct_scanout = 2,
    }
})
