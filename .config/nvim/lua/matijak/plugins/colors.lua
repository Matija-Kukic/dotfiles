-- All theme plugins stay declared (lazy) so :Lazy clean never removes them;
-- the active colorscheme's spec (priority + config) is merged on top from
-- ~/.config/colorschemes/active/neovim.lua (managed by switch-theme).

local plugins = {
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "sainnhe/everforest", lazy = true },
	{ "sainnhe/gruvbox-material", lazy = true },
	{ "folke/tokyonight.nvim", lazy = true },
	{ "fynnfluegge/monet.nvim", lazy = true },
}

local scheme = vim.env.HOME .. "/.config/colorschemes/active/neovim.lua"
local ok, active = pcall(dofile, scheme)
if ok and active then
	vim.list_extend(plugins, active)
else
	vim.notify("colorscheme file missing: " .. scheme, vim.log.levels.WARN)
end

return plugins
