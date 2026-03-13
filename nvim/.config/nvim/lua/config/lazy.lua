-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true },
})

-- Require configs
require("config.keymaps") -- Keymaps
require("config.lsp") -- Lsp config

-- Core settings
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

-- Filetype detection for Hyprland
vim.filetype.add({
    pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})

-- Make comments gray
vim.api.nvim_set_hl(0, "Comment", {
    fg = "#6a737d",
    italic = true,
    bold = true,
})
