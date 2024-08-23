return {
  "nvim-telescope/telescope.nvim",
  opts = function()
    return {
      pickers = {
        live_grep = {
          file_ignore_patterns = { "**/node_modules/*", "**/.git/*", "**/.venv/*", "**/.yarn/cache/*" },
          additional_args = function(_)
            return { "--hidden" }
          end,
        },
        find_files = {
          file_ignore_patterns = { "**/node_modules/*", "**/.git/*", "**/.venv/*", "**/.yarn/cache/*" },
          hidden = true,
        },
      },
    }
  end,
}
