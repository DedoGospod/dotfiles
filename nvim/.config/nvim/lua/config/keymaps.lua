-- Set default options for keymaps
local opts = { silent = true, noremap = true }

-- Utility function to set multiple mappings
local function map(mode, lhs, rhs, options)
    vim.keymap.set(mode, lhs, rhs, options or opts)
end

-- ------------------------------
-- 1. Telescope 🔭
-- ------------------------------
do
    local builtin = require('telescope.builtin')
    local t_opts = { desc = "Telescope | " }

    map('n', '<C-p>', builtin.find_files, { desc = t_opts.desc .. 'Find files' })
    map('n', '<C-g>', builtin.live_grep, { desc = t_opts.desc .. 'Live grep' })
    map('n', '<C-b>', builtin.buffers, { desc = t_opts.desc .. 'Buffers' })
    map('n', '<leader>fh', builtin.help_tags, { desc = t_opts.desc .. 'Help tags' })
end

-- ------------------------------
-- 2. Neo-tree 🌳
-- ------------------------------
do
    local nt_opts = { desc = "Neo-tree | " }

    map('n', '<C-n>', '<cmd>Neotree toggle<cr>', { desc = nt_opts.desc .. 'Toggle' })
    map('n', '<C-o>', '<cmd>Neotree focus<cr>', { desc = nt_opts.desc .. 'Focus' })
end

-- ------------------------------
-- 3. Compiler.nvim ⚙️
-- ------------------------------
do
    local c_opts = { desc = "Compiler | " }

    map('n', '<F9>', '<cmd>CompilerOpen<cr>', { desc = c_opts.desc .. 'Open' })
    map('n', '<F10>', '<cmd>CompilerToggleResults<cr>', { desc = c_opts.desc .. 'Toggle results' })
end

-- ------------------------------
-- 4. trouble.nvim 🚨
-- ------------------------------
do
    local t_opts = { desc = "Trouble | " }
    local trouble_keys = {
        -- Global Diagnostics
        { "<leader>xx", "diagnostics toggle", "Diagnostics (Global)" },
        -- Buffer Diagnostics
        { "<leader>xX", "diagnostics toggle filter.buf=0", "Diagnostics (Buffer)" },
        -- LSP utilities
        { "<leader>cs", "symbols toggle focus=false", "Symbols" },
        { "<leader>cl", "lsp toggle focus=false win.position=right", "LSP Definitions/References" },
        -- Lists
        { "<leader>xL", "loclist toggle", "Location List" },
        { "<leader>xQ", "qflist toggle", "Quickfix List" },
    }

    for _, mapping in ipairs(trouble_keys) do
        -- Prepend <cmd>Trouble and append <cr> for command execution
        map('n', mapping[1], string.format('<cmd>Trouble %s<cr>', mapping[2]),
            { desc = t_opts.desc .. mapping[3] })
    end
end

-- ------------------------------
-- 5. Utility & Harpoon Mappings 📌
-- ------------------------------
do
    -- Comment.nvim
    local CommentAPI = require('Comment.api')
    map('n', '<C-c>', function() CommentAPI.toggle.linewise.current() end, { desc = 'Toggle line comment' })

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
end

-- ------------------------------
-- 6. Core/Non-Plugin Mappings ⌨️
-- ------------------------------
do
    -- Jump to end of line (using <End> key)
    map({'i', 'n'}, '<C-a>', '<End>', { desc = 'Go to end of line' })
    map({'i', 'n'}, '<C-e>', '<End>', { desc = 'Go to end of line' })

    -- Zoxide (Autocommand Abbreviation)
    vim.cmd [[cnoreabbrev <expr> z ((getcmdtype() == ':' && getcmdline() == 'z') ? ' Z' : 'z')]]
end
