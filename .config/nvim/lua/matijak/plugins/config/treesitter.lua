local ts = require("nvim-treesitter")
ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "<filetype>" },
	callback = function()
		vim.treesitter.start()
	end,
})
ts.install({ "lua", "rust", "c", "cpp", "python", "bash", "markdown", "neo-tree" })
