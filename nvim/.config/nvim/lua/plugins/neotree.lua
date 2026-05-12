return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = true,
		keys = {
			{ "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Neo-tree | Toggle" },
			{ "<C-o>", "<cmd>Neotree focus<cr>", desc = "Neo-tree | Focus" },
		},
		opts = {
			window = {
				width = 30,
				-- auto_expand_width = true,
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
		},
	},
}
