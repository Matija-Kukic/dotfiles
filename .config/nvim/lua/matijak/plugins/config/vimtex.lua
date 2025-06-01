vim.g.vimtex_compiler_latexmk = {
	backend = "nvim",
	build_dir = "",
	callback = 1,
	continuous = 1,
	executable = "latexmk",
	options = {
		"-pdf",
		"-shell-escape",
		"-interaction=nonstopmode",
		"-synctex=1",
		"-bibtex",
	},
}
vim.keymap.set("n", "<leader>ltc", "<cmd>VimtexCompile<CR>", { desc = "LaTeX Compile" })
vim.keymap.set("n", "<leader>lto", "<cmd>VimtexView<CR>", { desc = "LaTeX View PDF" })
vim.keymap.set("n", "<leader>ltC", "<cmd>VimtexClean<CR>", { desc = "LaTeX Clean Aux Files" })
vim.keymap.set("n", "<leader>ltq", "<cmd>VimtexStop<CR>", { desc = "LaTeX Stop Compilation" })
vim.keymap.set("n", "<leader>lti", "<cmd>VimtexInfo<CR>", { desc = "LaTeX VimTeX Info" })
vim.keymap.set("n", "<leader>ltt", "<cmd>VimtexTocToggle<CR>", { desc = "LaTeX TOC Toggle" })
