local lspconf = require("lspconfig")
local cmp = require("cmp_nvim_lsp")

local capabilities = cmp.default_capabilities()

lspconf.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			format = {
				enable = true,
			},
		},
	},
})
lspconf.pyright.setup({
	capabilities = capabilities,
	settings = {
		python = {
			formatting = {
				provider = "black", -- Specify 'black' as the formatter
			},
		},
	},
})

lspconf.clangd.setup({
	capabilities = capabilities,
})
lspconf.texlab.setup({
	capabilities = capabilities,
	settings = {
		texlab = {
			bibtexFormatter = "texlab",
			--	build = {
			--	executable = "latexmk",
			--	forwardSearchAfter = true,
			--	onSave = false,
			--},
			forwardSearch = {
				executable = "okular", -- or skim/sumatrapdf
			},
			auxDirectory = "build",
			bibliography = { "references.bib" },
			diagnosticsDelay = 300,
		},
	},
})

local augroup = vim.api.nvim_create_augroup
local matijakgroup = augroup("matijak", {})

local autocmd = vim.api.nvim_create_autocmd
--local yank_group = augroup('HighlightYank', {})

autocmd("LspAttach", {
	group = matijakgroup,
	callback = function(e)
		local opts = { buffer = e.buf }
		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, opts)
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, opts)
		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, opts)
		vim.keymap.set("n", "<leader>vd", function()
			vim.diagnostic.open_float()
		end, opts)
		vim.keymap.set("n", "<leader>vca", function()
			vim.lsp.buf.code_action()
		end, opts)
		vim.keymap.set("n", "<leader>vrr", function()
			vim.lsp.buf.references()
		end, opts)
		vim.keymap.set("n", "<leader>vrn", function()
			vim.lsp.buf.rename()
		end, opts)
		vim.keymap.set("i", "<C-h>", function()
			vim.lsp.buf.signature_help()
		end, opts)
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.goto_next()
		end, opts)
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.goto_prev()
		end, opts)
		--        vim.api.nvim_set_keymap('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format()<CR>', { noremap = true, silent = true })
	end,
})
