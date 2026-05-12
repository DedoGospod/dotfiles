return {
    'nanotee/zoxide.vim',
    cmd = { 'Z', 'Lz', 'Tz', 'Zi', 'Lzi', 'Tzi' },
    init = function()
        vim.cmd [[cnoreabbrev <expr> z ((getcmdtype() == ':' && getcmdline() == 'z') ? ' Z' : 'z')]]
    end,
}
