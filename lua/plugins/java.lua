-- Improved Java + JDTLS plugin spec
-- - validates mason/jdtls paths and launcher jar
-- - only adds lombok agent if present
-- - computes workspace from project root
-- - places keymaps in on_attach
-- - graceful notifications when prerequisites are missing

return {
  -- ToggleTerm (used for Spring Boot commands)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },

  -- JDTLS (Eclipse Java language server)
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      local ok, jdtls = pcall(require, "jdtls")
      if not ok then
        vim.notify("nvim-jdtls not found. Install the plugin to enable Java LSP.", vim.log.levels.WARN)
        return
      end

      -- Helper: notify and bail out
      local function warn(msg)
        vim.notify("jdtls: " .. msg, vim.log.levels.WARN)
      end

      -- Mason packages usually live under stdpath("data") .. "/mason/packages"
      local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
      local jdtls_pkg = mason_packages .. "/jdtls"

      -- Find launcher jar
      local launcher = vim.fn.glob(jdtls_pkg .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      if launcher == "" then
        warn("Could not find jdtls launcher jar. Ensure jdtls is installed via Mason (mason.nvim).")
        return
      end

      -- Detect platform-specific config folder shipped by jdtls package
      local config_folder
      if vim.fn.has("mac") == 1 then
        config_folder = jdtls_pkg .. "/config_mac"
      elseif vim.fn.has("unix") == 1 then
        config_folder = jdtls_pkg .. "/config_linux"
      else
        config_folder = jdtls_pkg .. "/config_win"
      end
      if vim.fn.isdirectory(config_folder) == 0 then
        warn("jdtls config folder not found at: " .. config_folder)
        return
      end

      -- Optional lombok jar (only add -javaagent if present)
      local lombok = jdtls_pkg .. "/lombok.jar"
      local use_lombok = vim.fn.filereadable(lombok) == 1

      -- Compute project root
      local root_dir =
        jdtls.setup.find_root({ "pom.xml", "build.gradle", "settings.gradle", ".git", "mvnw", "gradlew" })
      if not root_dir or root_dir == "" then
        root_dir = vim.loop.cwd()
      end

      -- Workspace dir (unique per project root)
      local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

      -- Build command
      local cmd = { "java" }
      if use_lombok then
        table.insert(cmd, "-javaagent:" .. lombok)
      end
      table.insert(cmd, "-jar")
      table.insert(cmd, launcher)
      table.insert(cmd, "-configuration")
      table.insert(cmd, config_folder)
      table.insert(cmd, "-data")
      table.insert(cmd, workspace_dir)

      -- Sanity-check java available
      if vim.fn.executable("java") == 0 then
        warn("`java` executable not found in $PATH.")
        return
      end

      -- jdtls config
      local config = {
        cmd = cmd,
        root_dir = root_dir,
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" }, -- or "jd"
          },
        },
        -- Put LSP-specific keymaps and other buffer-local setup in on_attach
        on_attach = function(client, bufnr)
          local buf_map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, rhs, { buffer = bufnr, desc = desc })
            -- note: which-key registration will pick up these mappings if which-key is configured
          end

          -- Basic LSP keymaps (useful defaults)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "References" })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })

          -- Java-specific helpers via jdtls module
          if jdtls then
            vim.keymap.set("n", "<leader>jo", function()
              jdtls.organize_imports()
            end, { buffer = bufnr, desc = "Organize Imports" })
            vim.keymap.set("n", "<leader>jc", function()
              jdtls.extract_constant()
            end, { buffer = bufnr, desc = "Extract Constant" })
            vim.keymap.set("n", "<leader>jm", function()
              jdtls.extract_method()
            end, { buffer = bufnr, desc = "Extract Method" })
          end

          -- Spring Boot ToggleTerm commands (toggle terminal to run mvnw/gradlew)
          local function is_maven()
            return vim.fn.filereadable(root_dir .. "/pom.xml") == 1 or vim.fn.filereadable(root_dir .. "/mvnw") == 1
          end
          local function run_cmd()
            if is_maven() then
              return (vim.fn.filereadable(root_dir .. "/mvnw") == 1) and (root_dir .. "/mvnw spring-boot:run")
                or ("mvn -f " .. root_dir .. " spring-boot:run")
            else
              return (vim.fn.filereadable(root_dir .. "/gradlew") == 1) and (root_dir .. "/gradlew bootRun")
                or ("gradle -p " .. root_dir .. " bootRun")
            end
          end

          -- ensure toggleterm/TermExec exists before using
          vim.keymap.set("n", "<leader>jsr", function()
            local cmd = run_cmd()
            vim.cmd("TermExec cmd='" .. cmd .. "' direction=float")
          end, { buffer = bufnr, desc = "Spring Boot Run (ToggleTerm)" })

          vim.keymap.set("n", "<leader>jss", function()
            -- Best-effort stop: attempt to kill processes matching common patterns
            vim.fn.jobstart({ "pkill", "-f", "spring-boot:run" }, { detach = true })
            vim.fn.jobstart({ "pkill", "-f", "bootRun" }, { detach = true })
            vim.notify("Attempted to stop Spring Boot processes", vim.log.levels.INFO)
          end, { buffer = bufnr, desc = "Spring Boot Stop" })
        end,
      }

      -- Start or attach to jdtls
      jdtls.start_or_attach(config)
    end,
  },

  -- Optional: which-key labels for Java. LazyVim-style opts may pick these up; this
  -- block registers friendly group names if which-key is installed.
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>j", group = "Java", icon = " " },
        { "<leader>js", group = "Spring", icon = "🍃" },
      },
    },
  },
}
