local M = {}

function M.setup(opts)
	local wk = require("which-key")

	wk.setup(opts)

	wk.add({
		{
			"<leader>?",
			function()
				wk.show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
		{ "<leader>f", group = "Find Files/Format" },
		{ "<leader>g", group = "Git" },
		{ "<leader>w", group = "Window" },
		{ "<leader>v", group = "LSP" },
		{ "<leader>h", group = "Help" },
		{ "<leader>t", group = "Trouble diagnostics" },
		{ "<leader>r", group = "Remote" },
		{ "<leader>l", group = "LaTeX" },
		{ "<leader>d", group = "Debug/Buffer Del" },
		{ "<leader>m", group = "Markdown" },
		{ "<leader>c", group = "Change/Toggle" },
	})
end

return M
