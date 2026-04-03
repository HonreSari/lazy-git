return {
  "Kenzo-Wada/boundary.nvim",
  -- Using the 'release' branch as recommended by the author
  branch = "release",
  event = "BufReadPost",
  opts = {
    auto = true, -- Automatically refreshes markers on save/enter
    marker_text = "󱫿 'use client'", -- The icon plus the text
    marker_hl_group = "DiagnosticWarn", -- Using a soft orange for visibility

    -- This ensures it only runs for your Next.js/React projects
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  },
}
