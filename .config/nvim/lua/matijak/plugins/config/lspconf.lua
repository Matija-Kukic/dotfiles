-- LSP + CMP capabilities
local cmp = require("cmp_nvim_lsp")
local capabilities = cmp.default_capabilities()

-- Lua
vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			format = {
				enable = true,
			},
		},
	},
})
vim.lsp.enable("lua_ls")

-- Python
vim.lsp.config("pyright", {
	capabilities = capabilities,
})
vim.lsp.enable("pyright")

-- C / C++
vim.lsp.config("clangd", {
	capabilities = capabilities,
	cmd = {
		"clangd",
		"--background-index",
		"--query-driver=/usr/bin/gcc,/usr/bin/g++",
	},
})
vim.lsp.enable("clangd")
vim.lsp.config("vhdl_ls", {
	capabilities = capabilities,
})
vim.lsp.enable("vhdl_ls")

-- LaTeX
vim.lsp.config("texlab", {
	capabilities = capabilities,
	settings = {
		texlab = {
			bibtexFormatter = "texlab",
			forwardSearch = {
				executable = "okular",
			},
			auxDirectory = "build",
			bibliography = { "references.bib" },
			diagnosticsDelay = 300,
		},
	},
})
vim.lsp.enable("texlab")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local matijakgroup = augroup("matijak", {})

autocmd("LspAttach", {
	group = matijakgroup,
	callback = function(e)
		local opts = { buffer = e.buf }

		local wk = require("which-key")
		wk.add({
			{ "<leader>v", group = "LSP", buffer = e.buf },
		})

		-- Go to definition
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = e.buf, desc = "LSP: goto definition" })

		-- Hover documentation
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = e.buf, desc = "LSP: hover docs" })

		-- Workspace symbols
		vim.keymap.set(
			"n",
			"<leader>vws",
			vim.lsp.buf.workspace_symbol,
			{ buffer = e.buf, desc = "LSP: workspace symbols" }
		)

		-- Show diagnostics in float
		vim.keymap.set(
			"n",
			"<leader>vd",
			vim.diagnostic.open_float,
			{ buffer = e.buf, desc = "LSP: diagnostics float" }
		)

		-- Code actions
		vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { buffer = e.buf, desc = "LSP: code actions" })

		-- References
		vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, { buffer = e.buf, desc = "LSP: references" })

		-- Rename
		vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { buffer = e.buf, desc = "LSP: rename" })

		-- Signature help (insert mode)
		vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { buffer = e.buf, desc = "LSP: signature help" })

		-- Diagnostics navigation (new API)
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = 1 })
		end, { buffer = e.buf, desc = "LSP: next diagnostic" })

		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = -1 })
		end, { buffer = e.buf, desc = "LSP: prev diagnostic" })

		-- Optional: format keybind (uncomment if desired)
		-- vim.keymap.set("n", "<leader>fm", function()
		--     vim.lsp.buf.format({ async = true })
		-- end, opts)
	end,
})
