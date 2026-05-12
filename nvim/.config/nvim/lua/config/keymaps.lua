-- Global movement keys
local map = vim.keymap.set

-- Custom keybindings
map({'i', 'n'}, '<C-a>', '<End>', { desc = 'Go to end of line' })

-- Harpoon
local harpoon = require("harpoon")
    map('n', '<leader>a', function() harpoon:list():add() end, { desc = 'Harpoon | Add file' })
    map('n', '<Leader>ls', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon | Quick menu' })
for i = 1, 4 do
    map('n', string.format('<leader>%d', i), function() harpoon:list():select(i) end,
        { desc = string.format('Harpoon | Go to item %d', i) })
end

-- Conform.nvim (Formatter)
map("n", "<Leader>f", function()
    require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
end, { desc = "Format current buffer (Conform)" })
