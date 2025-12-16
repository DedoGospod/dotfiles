-- Basic settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true --
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.showmode = false

-- Set global indentation settings
vim.opt.shiftwidth = 4   -- Number of spaces to use for each step of indentation
vim.opt.tabstop = 2      -- Number of spaces a tab character counts for
vim.opt.softtabstop = 2  -- Number of spaces inserted for <Tab> when 'expandtab' is set
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.wrap = false     -- Optional: Prevent line wrapping by default for all files

-- Bootstrap lazy.nvim (ensure lazy.nvim is installed)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git",
        lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugin manager (lazy.nvim)
require("config.lazy")

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Sync clipboard between OS and Neovim
vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end)

-- Disable virtual_text since it's redundant due to lsp_lines
vim.diagnostic.config({
    virtual_text = false, -- Disable inline text
    virtual_lines = true, -- Enable virtual lines below code for diagnostics
    signs = true,
    underline = true,
})

-- Set colorscheme
vim.cmd.colorscheme("catppuccin")

require("catppuccin").setup({
    transparent_background = false,
    float = {
        transparent = false,
    },
})

-- Filetype detection for Hyprland
vim.filetype.add({
    pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})

vim.api.nvim_set_hl(0, "Comment", {
    fg = "#6a737d",
    italic = true,
    bold = true,
})
