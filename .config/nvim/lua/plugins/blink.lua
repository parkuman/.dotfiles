return {
  "saghen/blink.cmp",
  event = "VeryLazy",
  dependencies = { "supermaven-nvim" },
  opts = {
    keymap = {
      preset = "none", -- Disable all default mappings

      -- Make Tab and Enter do their normal behavior - never accept completions
      ["<Tab>"] = {
        "snippet_forward",
        function() -- sidekick next edit suggestion
          return require("sidekick").nes_jump_or_apply()
        end,
        function() -- if you are using Neovim's native inline completions
          return vim.lsp.inline_completion.get()
        end,
        "fallback",
      },
      ["<CR>"] = {},

      -- Explicit opt-in key for accepting completions
      ["<C-Y>"] = { "select_and_accept" },

      -- Change completion trigger from <C-Space> to <C-b>
      ["<C-b>"] = { "show", "hide" },

      -- Navigation keys
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
    },

    -- sources = {
    --   default = function()
    --     local sources = { "lsp", "path", "buffer" }
    --     if vim.g.ai_cmp then
    --       table.insert(sources, 1, "supermaven")
    --     end
    --     return sources
    --   end,
    -- },
  },
}
