return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ensure_installed = {
					"black",
					"lua_ls",
					"pylsp",
					"pyright",
					"clangd",
					"texlab",
				},
			})
		end,
	},

	{
		"L3MON4D3/LuaSnip",
		version = "v2.*", -- Use the latest released major version
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			require("matijak.plugins.config.cmp")
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("matijak.plugins.config.lspconf")
		end,
	},
	{
		"mhartington/formatter.nvim",
		config = function()
			require("matijak.plugins.config.format")
		end,
	},
}
