return {
  "tomoakley/circleci.nvim",
  ft = "yaml", -- Only load for YAML files
  config = function()
    -- Temporarily override telescope.load_extension to prevent the error
    local telescope = require("telescope")
    local original_load_extension = telescope.load_extension

    telescope.load_extension = function(name)
      if name == "circleci" then
        return -- Skip loading circleci extension
      end
      return original_load_extension(name)
    end

    require("nvim-circleci").setup({
      lsp = {
        enable = true,
        config = {
          enable_yaml = true,
          -- for local dev
          -- cmd = {
          --   "sh",
          --   "-c",
          --   "/Users/parker/circleci/circleci-yaml-language-server/bin/start_server -schema=/Users/parker/circleci/circleci-yaml-language-server/schema.json --stdio",
          -- },
        },
      },
      telescope = false,
    })

    -- Restore original function
    telescope.load_extension = original_load_extension
  end,
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
}
