vim.cmd("set tabstop=4")

local set = vim.opt

set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.softtabstop = 4

set.number = true

set.hlsearch = false
set.incsearch = true

set.showcmd = true
set.showmode = true

--set.colorcolumn = "80"

set.swapfile = false
set.backup = false

-- optionally enable 24-bit colour
vim.o.termguicolors = true
