vim.api.nvim_create_autocmd("FileType", {
	pattern = { "<filetype>", "cpp", "lua", "c", "hpp", "markdown", "python" }, -- dodaj jezike ovdje
	callback = function()
		vim.treesitter.start()
	end,
})

--vim.treesitter.language.add("cpp", { path = "/home/matijak/.local/share/nvim/parser/cpp.so" })
--vim.treesitter.language.register("cpp", { "cpp" })
--vim.treesitter.language.add("lua", { path = "/home/matijak/.local/share/nvim/parser/lua.so" })
--vim.treesitter.language.register("lua", { "lua" })
