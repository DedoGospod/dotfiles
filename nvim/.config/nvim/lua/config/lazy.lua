-- Plugin setup with lazy.nvim
require("lazy").setup({
	spec = {
		{ import = "plugins" },
		{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	},
	checker = { enabled = true },
})

-- Require configs
require("config.keymaps") -- Keymaps
require("config.lsp") -- Lsp config
