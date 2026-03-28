return {
  {
    "Exafunction/windsurf.vim",
    -- Load when you enter a buffer
    event = "BufEnter",
    config = function()
      -- Keymaps for ghost text completions
      -- These are standard for the Codeium engine Windsurf uses
      vim.g.codeium_no_map_tab = 1
      vim.keymap.set("i", "<Tab>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true, desc = "Windsurf Accept" })

      vim.keymap.set("i", "<c-;>", function()
        return vim.fn["codeium#CycleCompletions"](1)
      end, { expr = true, silent = true, desc = "Windsurf Next" })

      vim.keymap.set("i", "<c-,>", function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true, silent = true, desc = "Windsurf Prev" })

      vim.keymap.set("i", "<c-x>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true, silent = true, desc = "Windsurf Clear" })
    end,
  },
}
