return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Load when needed to keep startup fast
    priority = 1000, -- Load early to handle diagnostics correctly
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern", -- Options: "modern", "classic", "minimal", "powerline"
        options = {
          -- Show the source of the error (e.g., "typescript-eslint")
          show_source = { enabled = true },
          -- Use a cleaner multiline approach
          multilines = { enabled = true },
          -- Show the most severe diagnostic if multiple exist on one line
          use_max_severity = true,
        },
      })

      -- IMPORTANT: You must disable the built-in virtual text
      -- to avoid seeing double messages.
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
