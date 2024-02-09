return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- remove the time from lualine since tmux already has it
    table.remove(opts.sections.lualine_z)
  end,
}
