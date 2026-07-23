-- Catppuccin Mocha — neovim activation spec (merged into colors.lua's base list)
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				integrations = {
					treesitter = true,
					native_lsp = { enabled = true },
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
