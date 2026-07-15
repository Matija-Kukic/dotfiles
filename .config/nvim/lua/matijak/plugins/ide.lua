return {
	{
		"ojroques/nvim-bufdel",
		config = function()
			require("bufdel").setup({
				next = "tabs",
				quit = false,
			})

			vim.keymap.set("n", "<leader>dx", ":BufDel<CR>", { noremap = true, silent = true })
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					offsets = {
						{
							filetype = "neo-tree",
							text = "File Explorer",
							highlight = "Directory",
							separator = true, -- use a "true" to enable the default, or set your own character
							text_align = "left",
						},
					},
					close_command = function(bufnr)
						vim.cmd("BufDel " .. bufnr)
					end,
					right_mouse_command = function(bufnr)
						vim.cmd("BufDel " .. bufnr)
					end,
				},
			})
			-- Navigate buffers
			vim.api.nvim_set_keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })

			vim.api.nvim_set_keymap("n", "<leader>x", ":BufferLinePickClose<CR>", { noremap = true, silent = true })
			--vim.keymap.set("n", "<leader>x", function()
			--	vim.cmd("BufferLinePick")
			--	vim.schedule(function()
			--		vim.cmd("BufDel")
			--	end)
			--end, { silent = true, desc = "Pick buffer and delete with BufDel" })
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		config = function()
			require("matijak.plugins.config.neotree")
		end,
	},
	--{
	--	"rcarriga/nvim-dap-ui",
	--	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	--	config = function()
	--		require("matijak.plugins.config.dap")
	--	end,
	--},
	{
		"igorlfs/nvim-dap-view",
		-- let the plugin lazy load itself
		--
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		lazy = false,
		version = "1.*",
		---@module 'dap-view'
		---@type dapview.Config
		opts = {
			winbar = {
				sections = { "console", "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
				default_section = "console",
			},
		},
		config = function()
			require("matijak.plugins.config.dap")
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>mds", "<Plug>MarkdownPreview", { desc = "Markdown Preview Start" })
			vim.api.nvim_set_keymap("n", "<leader>mde", "<Plug>MarkdownPreviewStop", { desc = "Markdown Preview Stop" })
			vim.api.nvim_set_keymap(
				"n",
				"<leader>mdt",
				"<Plug>MarkdownPreviewToggle",
				{ desc = "Markdown Preview Toggle" }
			)
		end,
	},
	{
		"startup-nvim/startup.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			require("startup").setup()
		end,
	},
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.vimtex_view_method = "general"
			vim.g.vimtex_view_general_viewer = "okular"
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_view_general_options = "--unique file:@pdf#src:@line@tex"
		end,
		config = function()
			require("matijak.plugins.config.vimtex")
		end,
	},
	{
		"nosduco/remote-sshfs.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
		opts = {},
		config = function(_, opts)
			require("remote-sshfs").setup(opts)
			require("telescope").load_extension("remote-sshfs")
			local api = require("remote-sshfs.api")
			vim.keymap.set("n", "<leader>rc", api.connect, { desc = "Remote connect" })
			vim.keymap.set("n", "<leader>rd", api.disconnect, { desc = "Remote disconnect" })
			vim.keymap.set("n", "<leader>re", api.edit, { desc = "Remote edit" })
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			--triggers = {
			--	{ "<leader>", mode = { "n", "v" } },
			--},
			delay = 600,
		},
		config = function(_, opts)
			require("matijak.plugins.config.which-key").setup(opts)
		end,
	},
	{
		"dlyongemallo/diffview.nvim",
		version = "*",
		-- optional: lazy-load on command
		-- cmd = {
		--     "DiffviewOpen",
		--     "DiffviewToggle",
		--     "DiffviewFileHistory",
		--     "DiffviewDiffFiles",
		--     "DiffviewLog",
		-- },
	},

	{
		"will133/vim-dirdiff",
		cmd = "DirDiff",
		init = function()
			vim.g.DirDiffExcludes = ".git,.svn,CVS,*.swp,node_modules,target,.DS_Store"
		end,
	},
	{
		"amitds1997/remote-nvim.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim",
		},
		opts = {
			client_callback = function(port, _)
				local cmd = ("tmux new-window -n 'Remote Nvim' nvim --server localhost:%s --remote-ui"):format(port)
				vim.fn.jobstart(cmd, { detach = true })
			end,
		},
	},
}
