vim.api.nvim_set_keymap('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true })
require("neo-tree").setup ({
    window = {
        width = 30
    }
})
