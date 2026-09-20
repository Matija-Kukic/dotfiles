local lint = require("lint")

local function cppcheck_linter(name, language, std)
	local copy = vim.deepcopy(lint.linters.cppcheck)
	copy.name = name
	copy.args = {
		"--enable=warning,style,performance,portability",
		"--inline-suppr",
		"--suppress=missingIncludeSystem",
		"--language=" .. language,
		"--std=" .. std,
	}
	return copy
end

lint.linters.c_cppcheck = cppcheck_linter("c_cppcheck", "c", "c17")
lint.linters.cpp_cppcheck = cppcheck_linter("cpp_cppcheck", "c++", "c++17")
lint.linters.cuda_cppcheck = cppcheck_linter("cuda_cppcheck", "c++", "c++17")

lint.linters_by_ft = {
	c = { "c_cppcheck" },
	cpp = { "cpp_cppcheck" },
	cuda = { "cuda_cppcheck" },
	vhdl = { "vsg" },
	latex = { "chktex" },
	tex = { "chktex" },
	markdown = { "markdownlint-cli2" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
}

local group = vim.api.nvim_create_augroup("matijak-lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
	group = group,
	callback = function()
		if vim.opt_local.modifiable:get() then
			lint.try_lint()
		end
	end,
})
