return {
  -- ToggleTerm for your terminal execution
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },

  -- Disable the old nvim-java to prevent conflicts
  { "nvim-java/nvim-java", enabled = false },

  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap", "akinsho/toggleterm.nvim" },
    config = function()
      local jdtls = require("jdtls")
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

      -- Find Lombok jar safely
      local lombok_jar = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar")

      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx2G",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",

          "-javaagent:" .. lombok_jar,

          "-jar",
          vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration",
          vim.fn.stdpath("data")
            .. "/mason/packages/jdtls/config_"
            .. (vim.loop.os_uname().sysname:lower() == "darwin" and "mac" or "linux"),
          "-data",
          vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
        },

        root_dir = require("lspconfig.util").root_pattern(
          "pom.xml",
          "build.gradle",
          "build.gradle.kts",
          "settings.gradle",
          ".git"
        ),

        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
          },
        },

        -- Correct way in current LazyVim
        on_attach = function(client, bufnr)
          -- Use LazyVim's default LSP on_attach if available
          local ok, lazy_on_attach = pcall(require, "lazyvim.util.lsp").on_attach
          if ok then
            lazy_on_attach(client, bufnr)
          end
        end,
      }

      jdtls.start_or_attach(config)
    end,
  },
}
