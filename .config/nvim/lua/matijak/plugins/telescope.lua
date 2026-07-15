return {
    "nvim-telescope/telescope.nvim",


    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require("matijak.plugins.config.telescope")
    end
}

