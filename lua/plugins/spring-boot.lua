return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      -- Helper functions inside config to keep things clean
      local function is_maven()
        return vim.fn.filereadable("pom.xml") == 1
      end

      local function get_run_cmd()
        return is_maven() and "./mvnw spring-boot:run" or "./gradlew bootRun"
      end

      --  ==================== KEYMAPS ====================
      -- Run Spring Boot
      vim.keymap.set("n", "<leader>jsr", function()
        vim.cmd("TermExec cmd='" .. get_run_cmd() .. "'")
      end, { desc = "Spring Run (Dev)" })

      -- Stop Spring Boot (Safe kill)
      vim.keymap.set("n", "<leader>jss", function()
        local cmd = "pkill -f 'spring-boot:run' || pkill -f 'bootRun'"
        vim.fn.system(cmd)
        vim.notify("Spring Boot Stopped", vim.log.levels.INFO)
      end, { desc = "Spring Stop" })

      -- Run Tests
      vim.keymap.set("n", "<leader>jst", function()
        local cmd = is_maven() and "./mvnw test" or "./gradlew test"
        vim.cmd("TermExec cmd='" .. cmd .. "'")
      end, { desc = "Spring Run All Tests" })
    end,
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>js", group = "Spring Boot", icon = "🍃" },
      },
    },
  },
}
