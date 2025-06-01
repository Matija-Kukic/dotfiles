return {
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
				},
			})
			-- Navigate buffers
			vim.api.nvim_set_keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })

			-- Close buffer
			vim.api.nvim_set_keymap("n", "<leader>x", ":BufferLinePickClose<CR>", { noremap = true, silent = true })
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
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>mds", "<Plug>MarkdownPreview", {})
			vim.api.nvim_set_keymap("n", "<leader>mde", "<Plug>MarkdownPreviewStop", {})
			vim.api.nvim_set_keymap("n", "<leader>mdt", "<Plug>MarkdownPreviewToggle", {})
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
}
