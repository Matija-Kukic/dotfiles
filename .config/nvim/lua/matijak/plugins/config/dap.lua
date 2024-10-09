local dap = require("dap")
local dapui = require("dapui")

--dap.setup()
dapui.setup()

vim.keymap.set("n", "<leader>dt", function()
	dapui.toggle()
end)

dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = "/home/matijak/Documents/extension/debugAdapters/bin/OpenDebugAD7",
}

dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "cppdbg",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopAtEntry = true,
	},
	{
		name = "Attach to gdbserver :8008",
		type = "cppdbg",
		request = "launch",
		MIMode = "gdb",
		miDebuggerServerAddress = "localhost:8008",
		miDebuggerPath = "/usr/bin/gdb",
		cwd = "${workspaceFolder}",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
	},
}
dap.configurations.c = dap.configurations.cpp
dap.adapters.python = function(cb, config)
	if config.request == "attach" then
		---@diagnostic disable-next-line: undefined-field
		local port = (config.connect or config).port
		---@diagnostic disable-next-line: undefined-field
		local host = (config.connect or config).host or "127.0.0.1"
		cb({
			type = "server",
			port = assert(port, "`connect.port` is required for a python `attach` configuration"),
			host = host,
			options = {
				source_filetype = "python",
			},
		})
	else
		cb({
			type = "executable",
			command = "/home/matijak/.virtualenvs/debugpy/bin/python3",
			args = { "-m", "debugpy.adapter" },
			options = {
				source_filetype = "python",
			},
		})
	end
end

dap.configurations.python = {
	{
		-- The first three options are required by nvim-dap
		type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
		request = "launch",
		name = "Launch file",

		-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

		program = "${file}", -- This configuration will launch the current file if used.
		pythonPath = function()
			-- debugpy supports launching an application with a different interpreter than the one used to launch debugpy itself.
			-- The code below uses the `VIRTUAL_ENV` environment variable if set, falling back to a default Python interpreter.
			if vim.env.VIRTUAL_ENV then
				return vim.env.VIRTUAL_ENV .. "/bin/python"
			else
				return "/usr/bin/python3"
			end
		end,
	},
}

--require("neodev").setup({
--    library = { plugins = { "nvim-dap-ui" }, types = true },
--})

vim.keymap.set("n", "<Leader>db", function()
	require("dap").toggle_breakpoint()
end)
vim.keymap.set("n", "<Leader>dc", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<Leader>dso", function()
	require("dap").step_over()
end)
vim.keymap.set("n", "<Leader>dsi", function()
	require("dap").step_into()
end)
vim.keymap.set("n", "<Leader>dst", function()
	require("dap").step_out()
end)
