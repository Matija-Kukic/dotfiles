local conform = require("conform")

conform.setup({
	-- Definiramo koji jezici koriste koje formatere
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		c = { "clang_wrapper" },
		h = { "clang_wrapper" },
		cpp = { "clang_wrapper" },
		cuda = { "clang_wrapper" },
		vhdl = { "vsg" }, -- Ugrađeni VSG već koristi glatki stdin po defaultu
	},

	-- Ovdje definiramo tvoj prilagođeni clang-wrapper s logikom preskakanja
	formatters = {
		clang_wrapper = {
			command = "/home/matijak/bin/clang-wrapper.sh",
			stdin = true,
			condition = function(self, ctx)
				local disabled_dirs = {
					"/home/matijak/Documents/skola/osur",
				}
				for _, dir in ipairs(disabled_dirs) do
					if string.find(ctx.filename, dir, 1, true) then
						return false -- Preskače ovaj formater!
					end
				end
				return true
			end,
		},
	},

	--format_on_save = {
	--	timeout_ms = 500,
	--	lsp_format = "fallback",
	--},
})

vim.keymap.set("n", "<leader>fm", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format file" })

vim.keymap.set("n", "<leader>fw", function()
	-- Sinkrono formatira pa odmah nakon toga sprema datoteku
	conform.format({ async = false, lsp_format = "fallback" })
	vim.cmd("write")
end, { desc = "Format file and write" })
