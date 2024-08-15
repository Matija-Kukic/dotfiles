return {
    {
      'sainnhe/everforest',
      lazy = false,
      priority = 1000,
      config = function()
        --Optionally configure and load the colorscheme
        --directly inside the plugin declaration.
        vim.g.everforest_enable_italic = true
        vim.g.everforest_background = 'hard'
        vim.o.background = 'dark'
        vim.cmd.colorscheme('everforest')
      end
    },
    {
      'sainnhe/gruvbox-material',
      lazy = false,
      priority = 1000,
      --config = function()
         --Optionally configure and load the colorscheme
         --directly inside the plugin declaration.
        --vim.g.gruvbox_material_enable_italic = true
        ----------------vim.cmd.colorscheme('gruvbox-material')
      --end
    },
    {
        "folke/tokyonight.nvim",
        --lazy = false,
        --priority = 1000,
        --opts = {},
        --config = function()
            --vim.cmd.colorscheme('tokyonight')
        --end
    }
}
