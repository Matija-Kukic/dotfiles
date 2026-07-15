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

vim.api.nvim_create_user_command("DiffDirs", function(opts)
  if #opts.fargs ~= 2 then
    vim.notify("Usage: DiffDirs <left> <right>", vim.log.levels.ERROR)
    return
  end

  local left = opts.fargs[1]
  local right = opts.fargs[2]

  vim.cmd("packadd nvim.difftool")

  require("difftool").open(left, right, {
    ignore = {
      ".git",
      ".svn",
      "CVS",
      "*.swp",
      "node_modules",
      "target",
      ".DS_Store",
      ".cache",
      "*.o",
      "build",
    },
  })
end, {
  nargs = "*",
  complete = "dir",
})
vim.g.DirDiffExcludes = "CVS,*.class,*.exe,*.o,.cache,*.swp,*.DS_Store,*.git,node_modules,target,build"
