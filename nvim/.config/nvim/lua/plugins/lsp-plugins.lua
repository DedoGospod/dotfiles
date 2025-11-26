return {
    -- Mason
    {
        "williamboman/mason.nvim",
        lazy = false
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = "VeryLazy"
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        lazy = true
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        lazy = true,
        event = "BufReadPre"
    },

    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        lazy = true,
        event = "InsertEnter"
    },

    -- Formatting
    {
        'stevearc/conform.nvim',
        lazy = true,
        event = { "BufWritePre" }
    },

    -- Linting
    {
        "mfussenegger/nvim-lint",
        lazy = true,
        event = { "BufWritePost", "BufReadPost" }
    },

    -- Auto Pairs
    {
        "windwp/nvim-autopairs",
        lazy = true,
        event = { "InsertEnter", "CmdlineLeave" }
    },

    -- Utility/Other
    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        lazy = true,
        event = "BufReadPre"
    },
}
