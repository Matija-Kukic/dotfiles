local action_state = require("telescope.actions.state")
local bufdel = require("bufdel")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--hidden",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--follow",
		},
		mappings = {
			i = {
				["<C-d>"] = function(prompt_bufnr)
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = picker:get_multi_selection()

					-- If nothing selected, fall back to current entry
					if vim.tbl_isempty(selections) then
						table.insert(selections, action_state.get_selected_entry())
					end

					for _, entry in ipairs(selections) do
						vim.cmd("BufDel " .. entry.bufnr)
					end

					--actions.close(prompt_bufnr)
				end,
			},
			n = {
				["<C-d>"] = function(prompt_bufnr)
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = picker:get_multi_selection()

					if vim.tbl_isempty(selections) then
						table.insert(selections, action_state.get_selected_entry())
					end

					for _, entry in ipairs(selections) do
						vim.cmd("BufDel " .. entry.bufnr)
					end

					--actions.close(prompt_bufnr)
				end,
			},
		},
	},
	pickers = {
		find_files = {
			--hidden = true,
			follow = true,
		},
	},
})
vim.keymap.set("n", "<leader>fa", builtin.find_files, { desc = "Find among all files." })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Git files?" })
vim.keymap.set("n", "<leader>fs", function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "Find file containing string." })
vim.keymap.set("n", "<leader>ff", function()
	local filetype = vim.fn.input("Filetype (e.g. lua, cpp) > ")

	require("telescope.builtin").find_files({
		find_command = {
			"rg",
			"--files",
			"--glob",
			"*." .. filetype,
		},
	})
end, { desc = "Find file with given filetype." })
vim.keymap.set("n", "<leader>fd", require("telescope.builtin").buffers, {
	desc = "Find open buffers",
})
vim.keymap.set("n", "<leader>ht", builtin.help_tags, { desc = "Telescope help tags." })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })
