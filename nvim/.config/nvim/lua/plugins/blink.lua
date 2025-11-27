return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	lazy = true,
	event = "InsertEnter", -- 'VimEnter', 'LspAttach'

	version = "1.*",
	---@module 'blink.cmp'
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
			["<C-CR>"] = { "accept", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 50 },
		},
		sources = {
			default = { "snippets", "lsp", "path", "buffer" },
			providers = {
				snippets = { max_items = 3 },
				lsp = { max_items = 3 },
				path = { max_items = 3 },
				buffer = { max_items = 3 },
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
