return {
  "Pocco81/auto-save.nvim",
  -- InsertLeave + TextChangedP is safer than raw TextChanged
  event = { "InsertLeave", "TextChangedP" },
  opts = {
    enabled = true,
    write_all_buffers = false, -- Only saves the current buffer
    condition = function(buf)
      -- 1. Guard against invalid/closed buffers
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return false
      end

      -- 2. Use modern, fast buffer-local API
      local ft = vim.bo[buf].filetype

      -- 3. Exclude UI, transient, and sensitive buffers
      local excluded = {
        "neo-tree",
        "TelescopePrompt",
        "harpoon",
        "lazy",
        "mason",
        "checkhealth",
        "gitcommit",
        "java", -- Optional: Disable for Java to prevent LSP compile spam
      }

      return not vim.tbl_contains(excluded, ft)
    end,
  },
}
