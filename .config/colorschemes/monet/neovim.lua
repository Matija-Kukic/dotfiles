-- Monet — neovim activation spec (merged into colors.lua's base list)
return {
	{
		"fynnfluegge/monet.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("monet").setup({
				transparent_background = false,
				semantic_tokens = true,
				dark_mode = true,
			})
			vim.cmd.colorscheme("monet")
		end,
	},
}
