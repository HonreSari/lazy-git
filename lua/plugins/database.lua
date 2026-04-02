return {
  "tpope/vim-dadbod",
  dependencies = {
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
  },
  config = function()
    -- Optional: UI configuration
    vim.g.db_ui_save_location = "~/.config/jnvim/db_ui_queries"
    vim.g.db_ui_show_database_navigation = 1
  end,
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
}
