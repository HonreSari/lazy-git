return {
  -- Existing themes
  { "rebelot/kanagawa.nvim" },
  { "rose-pine/neovim", name = "rose-pine" },
  { "scottmckendry/cyberdream.nvim" },

  -- 🎨 Additional Themes
  { "catppuccin/nvim" }, -- Pastel, highly customizable, massive community
  { "folke/tokyonight.nvim" }, -- Clean, excellent plugin support, LazyVim favorite
  { "projekt0n/github-nvim-theme", name = "github-theme" }, -- GitHub's official theme, professional & familiar
  { "sainnhe/everforest" }, -- Soft, nature-inspired, easy on the eyes for long sessions
  { "EdenEast/nightfox.nvim", name = "nightfox" }, -- Multiple variants, terminal & Neovim optimized

  -- Configure LazyVim to actually use one of them by default
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-dragon", -- Change this to your favorite
    },
  },
}
