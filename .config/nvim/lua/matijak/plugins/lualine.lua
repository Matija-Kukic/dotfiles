return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- Resolve the active colorscheme's lualine theme name
			-- (colorschemes/active is managed by switch-theme)
			local theme_name = "auto"
			local ok, lines = pcall(
				vim.fn.readfile,
				vim.env.HOME .. "/.config/colorschemes/active/lualine-theme"
			)
			if ok and lines[1] and lines[1] ~= "" then
				theme_name = lines[1]
			end

			-- Nordic-style surgery (AlexvZyl/nvim@97425d3): melt section b into
			-- the bar (keep the themed bar strip c.bg), pills = accent a only.
			-- Mid-bar text/icons get one muted fg per scheme (theme's inactive
			-- fg), only diagnostics stay colored.
			local theme = theme_name
			local text_hl = nil
			local tok, t = pcall(require, "lualine.themes." .. theme_name)
			if tok and type(t) == "table" and t.normal then
				for _, m in pairs(t) do
					if m.b and m.c then m.b.bg = m.c.bg end
				end
				theme = t
				local ia = t.inactive
				local muted = ia and ia.c and ia.c.fg or (t.normal.c and t.normal.c.fg)
				if muted then
					text_hl = { fg = muted }
				end
			end

			-- Fixed 6-char mode names keep the pill width stable
			local mode_map = { ["COMMAND"] = "COMMND", ["V-BLOCK"] = "V-BLCK", ["TERMINAL"] = "TERMNL" }
			local function fmt_mode(s)
				return mode_map[s] or s
			end

			local function parent_folder()
				local parent = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h:t")
				if parent == "." or parent == "" then return "" end
				return parent .. "/"
			end

			local function tail()
				return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
			end

			--  <active lsp client(s)> or empty
			local function lsp_clients()
				local get = vim.lsp.get_clients or vim.lsp.get_active_clients
				local names = {}
				for _, c in ipairs(get({ bufnr = 0 })) do
					if c.name ~= "copilot" then
						names[#names + 1] = c.name
					end
				end
				if #names == 0 then return "" end
				return table.concat(names, ", ")
			end

			local function short_cwd()
				return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
			end

			-- All pill caps are component-level (section_separators stay empty)
			-- so caps always draw full-thickness in the component's own colors.
			local mode_pill = { "mode", fmt = fmt_mode, icon = { "" },
				separator = { left = "", right = "" } }
			local loc = { "location", icon = { "", align = "left" },
				separator = { left = "" } }
			local prog = { "progress", icon = { "", align = "left" },
				separator = { right = "", left = "" } }

			-- Neo-tree window gets its own calm bar: mode pill · cwd · right pills
			-- Fixed gap after the mode pill, even when the following component
			-- collapses to empty (e.g. [No Name] buffers)
			local spacer = { function() return " " end, color = { bg = "NONE" }, padding = { left = 1, right = 0 } }

			local tree = {
				sections = {
					lualine_a = { mode_pill, spacer },
					lualine_b = {},
					lualine_c = {
						{ short_cwd, color = text_hl, icon = { " ", color = text_hl }, padding = 0 },
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = { loc, prog },
				},
				filetypes = { "neo-tree" },
			}

			local sections = {
				lualine_a = { mode_pill, spacer },
				lualine_b = {},
				lualine_c = {
					{ parent_folder, color = text_hl, icon = { " ", color = text_hl }, padding = 0, separator = "" },
					{ tail, padding = 0, separator = " " },
					{ "branch", color = text_hl, icon = { " ", color = text_hl }, padding = 0, separator = " " },
					{ "diff", color = text_hl, padding = 0,
						symbols = { added = " ", modified = " ", removed = " " },
						diff_color = text_hl and { added = text_hl, modified = text_hl, removed = text_hl } or nil },
				},
				lualine_x = {
					{ "diagnostics", sources = { "nvim_diagnostic" }, colored = true, padding = 1,
						symbols = { error = " ", warn = " ", info = " ", hint = "󱤅 " } },
					{ lsp_clients, color = text_hl, icon = { " ", color = text_hl }, padding = 2, separator = " " },
				},
				lualine_y = {},
				lualine_z = { loc, prog },
			}

			require("lualine").setup({
				options = {
					theme = theme,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = sections,
				extensions = { tree },
			})
		end,
	},
}
