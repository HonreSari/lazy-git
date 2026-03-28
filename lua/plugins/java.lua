return {
  -- 1. Ensure ToggleTerm is available for your Spring Boot commands
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },

  -- 2. Main Java Config
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      local jdtls = require("jdtls")

      -- Find paths for your MacBook Air M2
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
      local lombok_jar = mason_path .. "/jdtls/lombok.jar"

      local cmd = {
        "java",
      }

      -- Only add lombok if it exists
      if vim.fn.filereadable(lombok_jar) == 1 then
        table.insert(cmd, "-javaagent:" .. lombok_jar)
      end

      table.insert(cmd, "-jar")
      table.insert(cmd, launcher_jar)
      table.insert(cmd, "-configuration")
      table.insert(cmd, mason_path .. "/jdtls/config_mac")
      table.insert(cmd, "-data")
      table.insert(cmd, vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root_dir, ":p:h:t"))

      -- Spring Boot Helper Functions
      local function is_maven()
        return vim.fn.filereadable("pom.xml") == 1
      end
      local function get_run_cmd()
        return is_maven() and "./mvnw spring-boot:run" or "./gradlew bootRun"
      end

      local config = {
        cmd = {
          "java",
          "-javaagent:" .. lombok_jar,
          "-jar",
          vim.fn.glob(mason_path .. "/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration",
          mason_path .. "/jdtls/config_mac",
          "-data",
          vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t"),
        },
        root_dir = jdtls.setup.find_root({ "pom.xml", "build.gradle", ".git" }),

        -- THE FIX: Put keymaps inside on_attach
        on_attach = function(client, bufnr)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Java specific tools
          map("n", "<leader>jo", jdtls.organize_imports, "Organize Imports")
          map("n", "<leader>jc", jdtls.extract_constant, "Extract Constant")

          -- Your Spring Boot ToggleTerm commands
          map("n", "<leader>jsr", function()
            vim.cmd("TermExec cmd='" .. get_run_cmd() .. "'")
          end, "Spring Run (Dev)")

          map("n", "<leader>jss", function()
            vim.fn.system("pkill -f 'spring-boot:run' || pkill -f 'bootRun'")
            vim.notify("Spring Boot Stopped", vim.log.levels.INFO)
          end, "Spring Stop")
        end,
      }

      -- Start JDTLS
      jdtls.start_or_attach(config)
    end,
  },

  -- 3. Setup Which-Key labels so they show up in the menu
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>j", group = "Java", icon = " " },
        { "<leader>js", group = "Spring Boot", icon = "🍃" },
      },
    },
  },
}
