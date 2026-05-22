return {
	"numToStr/Comment.nvim",
	opts = {},
	keys = {
		{
			"<C-c>",
			function()
				require("Comment.api").toggle.linewise.current()
			end,
			desc = "Toggle line comment",
		},
	},
}
