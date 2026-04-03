return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          -- Luffy / Straw Hat Silhouette Style
          header = [[
██╗     ██╗   ██╗██╗ ██████╗ 
██║     ██║   ██║██║██╔═══██╗
██║     ██║   ██║██║██║   ██║
██║     ██║   ██║██║██║   ██║
███████╗╚██████╔╝██║╚██████╔╝
╚══════╝ ╚═════╝ ╚═╝ ╚═════╝ 
                             
--]],
        },
        sections = {
          { section = "header" },
          -- This part adds your "Recent Projects" (Perfect for Yangon Fast Pass)
          { section = "projects", padding = 1 },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
