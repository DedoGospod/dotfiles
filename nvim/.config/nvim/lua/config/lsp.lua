-- Mason setup to manage both LSPs and formatters
require("mason").setup({})
require("mason-tool-installer").setup({
	ensure_installed = {
		-- LSP Servers
		"basedpyright",           -- python
		"rust_analyzer",          -- rust
		"gopls",                  -- go
		"bashls",                 -- bash
		"html",                   -- html
		"zls",                    -- zig
		"ts_ls",                  -- typescript/javascript
		"clangd",                 -- c/cpp
   	"csharp-language-server", -- c#
		"lua_ls",                 -- lua
		-- Formatters
		"black", "isort",         -- python
		"crlfmt",                 -- Go
		"shfmt",                  -- sh, bash, ksh, zsh
		"prettierd",              -- angular, css, flow, graphql, html, json, jsx, javascript, less, markdown, scss, typescript, vue, yaml)
		"clang-format",           -- C, C++, Objective-C, Objective-C++, Java, JavaScript, TypeScript, C#
		"stylua",                 -- lua
		"csharpier",              -- c#
		-- Linters
    "golangci-lint",          -- GO
		"shellcheck",             -- bash
		"eslint_d",               -- ts_ls/javascript
	},
	auto_update = true,
})

-- Treesitter configuration
local status, configs = pcall(require, "nvim-treesitter.configs")
if status then
    configs.setup({
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true,
        },
        ensure_installed = {
            "json", "javascript", "typescript", "tsx", "yaml", "html",
            "css", "markdown", "markdown_inline", "bash", "lua", "vim",
            "dockerfile", "c", "c_sharp", "cpp", "rust", "go",
            "hyprlang", "python", "zig",
        },
    })
else
    print("Treesitter not yet loaded")
end

-- LSP Configuration
local lspconfig = vim.lsp.config
local capabilities = vim.lsp.protocol.make_client_capabilities()

require("mason-lspconfig").setup({
	handlers = {
		-- 1. Custom Handler for CLANGD:
		["clangd"] = function()
			lspconfig.clangd.setup({
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--clang-tidy",
					"--clang-tidy-checks=*",
				},
				-- Any other custom clangd settings go here
			})
		end,

		-- Default Handler (applies to all other servers not explicitly defined above)
		function(server_name)
			if server_name == "lua_ls" then
				lspconfig[server_name].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
							completion = { callSnippet = "Replace" },
							hint = { enable = true },
						},
					},
				})
			else
				-- The default setup for all other servers
				lspconfig[server_name].setup({ capabilities = capabilities })
			end
		end,
	},
})

-- Conform formatter setup
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		rust = { lsp_format = "fallback" },
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		go = { lsp_format = "fallback" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		html = { "prettierd" },
		zig = { lsp_format = "fallback" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		objc = { "clang-format" },
		objcpp = { "clang-format" },
		csharp = { "csharpier" },
	},
})

-- nvim-lint setup
local lint = require("lint")
lint.linters_by_ft = {
	go = { "golangci-lint" },
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
}

-- Configure specific linters --

-- JavaScript/typescript
vim.env.ESLINT_D_PPID = vim.fn.getpid()
require("lint").linters.eslint_d.args = {
	"--no-warn-ignored",
	"--format=json",
	"--stdin",
	"--stdin-filename",
	function()
		return vim.api.nvim_buf_get_name(0)
	end,
}

-- Setup autocommands to run linting on relevant events
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

-- Diagnostics
vim.diagnostic.config({
  virtual_text = {
    source = "always",
  },
  float = {
    source = "always",
  },
})
