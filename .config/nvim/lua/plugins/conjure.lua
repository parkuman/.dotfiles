return {
  -- dir = "/private/tmp/conjure",
  "Olical/conjure",
  init = function()
    vim.g["conjure#client#clojure#nrepl#test#runner"] = "kaocha"
    -- stops conjure from popping up when browsing code
    vim.g["conjure#client_on_load"] = false
  end,
}
