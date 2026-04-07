return {
  "Pocco81/auto-save.nvim",
  -- Trigger only when you exit insert mode or paste (prevents Normal-mode spam)
  event = { "InsertLeave", "TextChangedP" },
  opts = {
    enabled = true,
    write_all_buffers = false, -- Only save the active buffer
    execution_message = {
      message = function()
        return "⚡ Auto-saved: " .. vim.fn.strftime("%H:%M:%S")
      end,
      cleaning_time = 500,
    },
    condition = function(buf)
      -- 1. Guard against invalid/closed buffers
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return false
      end

      local ft = vim.bo[buf].filetype
      local filename = vim.api.nvim_buf_get_name(buf)

      -- 2. Exclude UI, transient, and plugin buffers
      local excluded_ft = {
        "neo-tree",
        "TelescopePrompt",
        "harpoon",
        "lazy",
        "mason",
        "checkhealth",
        "gitcommit",
        "gitrebase",
        "oil",
        "DressingInput",
        "noice",
        "spectre_panel",
        "fugitive",
        "gitconfig",
      }
      if vim.tbl_contains(excluded_ft, ft) then
        return false
      end

      -- 3. Exclude generated/built directories (never auto-save these)
      if
        filename:match("%.next/")
        or filename:match("node_modules/")
        or filename:match("target/")
        or filename:match("build/")
        or filename:match("%.class$")
        or filename:match("dist/")
      then
        return false
      end

      -- 4. Skip very large files (>2MB) to prevent lag
      local ok, stat = pcall(vim.loop.fs_stat, filename)
      if ok and stat and stat.size > 2 * 1024 * 1024 then
        return false
      end

      -- ✅ AUTO-SAVE EVERYTHING ELSE (Java, TS, JSX, CSS, JSON, YAML, etc.)
      return true
    end,
  },
}
