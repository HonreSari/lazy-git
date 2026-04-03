return {
  "Pocco81/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    enabled = true,
    condition = function(buf)
      local fn = vim.fn

      -- 1. ADD THIS LINE: Check if the buffer actually exists and is valid
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return false
      end

      -- 2. Your existing logic for filetypes
      local utils = require("auto-save.utils.data")
      if utils.not_in(fn.getbufvar(buf, "&filetype"), { "neo-tree", "TelescopePrompt", "harpoon" }) then
        return true
      end
      return false
    end,
  },
}
