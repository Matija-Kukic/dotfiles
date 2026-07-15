local cmp = require("cmp")
local luasnip = require("luasnip")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local lspkind = require("lspkind")
lspkind.init({
	mode = "symbol_text",
	preset = "codicons",
})
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" }, -- For luasnip users.
	}, {
		{ name = "buffer" },
	}),
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<TAB>"] = cmp.mapping.select_next_item(cmp_select),
		["S<TAb>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	formatting = {

		fields = { "icon", "kind", "abbr", "menu" },
		format = lspkind.cmp_format({
			mode = "symbol_text", -- show both symbol and text
			maxwidth = 50, -- prevent the popup from showing more than 50 characters
			ellipsis_char = "...", -- when popup menu exceed maxwidth

			-- Optional: add other sources (like buffer, path) to show
			-- different symbols or text in the menu
			before = function(entry, vim_item)
				return vim_item
			end,
		}),
	},
})
-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
	matching = { disallow_symbol_nonprefix_matching = false },
})
