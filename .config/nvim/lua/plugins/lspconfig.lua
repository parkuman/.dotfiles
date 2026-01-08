return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clojure_lsp = {},
      },
    },
    init = function()
      -- Handle jar file URIs from clojure-lsp
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "zipfile://*",
        callback = function()
          local uri = vim.fn.expand("<amatch>")
          local path = uri:gsub("^zipfile://", "")
          local jar_path, internal_path = path:match("^(.*%.jar)::(.*)")

          if jar_path and internal_path then
            local content = vim.fn.system(string.format("unzip -p '%s' '%s'", jar_path, internal_path))
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
            vim.bo.modifiable = false
            vim.bo.modified = false
            vim.bo.filetype = "clojure"
          end
        end,
      })
    end,
  },
}
