return {
  "hrsh7th/nvim-cmp",
  event = "VeryLazy", -- Assuming your setup allows specifying when the plugin loads.
  dependencies = { "supermaven-nvim" },
  opts = function(_, opts)
    local cmp = require("cmp")

    -- Make Tab and Enter do their normal behavior - never accept completions
    opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
      fallback() -- Always just do normal tab
    end, { "i", "s" })

    opts.mapping["<CR>"] = cmp.mapping(function(fallback)
      fallback() -- Always just do normal enter/newline
    end, { "i", "s" })

    -- Explicit opt-in keys for accepting completions
    opts.mapping["<C-Y>"] = cmp.mapping.confirm({ select = true })

    -- Assuming `opts.mapping` is the correct way to access and modify the mappings for nvim-cmp in your setup.
    -- This approach might not directly work because nvim-cmp's setup is usually done through a direct call to `cmp.setup()`.

    -- Hypothetical way to change "<C-Space>" to "<S-Space>" if the mappings could be modified like this.
    if opts.mapping then
      opts.mapping["<C-b>"] = opts.mapping["<C-Space>"]
      opts.mapping["<C-Space>"] = nil -- Attempt to remove the original mapping.
    end

    if vim.g.ai_cmp then
      table.insert(opts.sources, 1, {
        name = "supermaven",
        group_index = 1,
        priority = 100,
      })
    end
  end,
}
