return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("matijak.plugins.config.treesitter") 
    end
}
