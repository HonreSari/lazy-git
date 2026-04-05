return {
  -- ============================================================================
  -- ToggleTerm: For running Spring Boot commands in floating/terminal splits
  -- ============================================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },

  -- ============================================================================
  -- nvim-jdtls: Eclipse Java Language Server integration
  -- ============================================================================
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

      local function warn(msg)
        vim.notify("jdtls: " .. msg, vim.log.levels.WARN)
      end

      -- Mason packages path
      local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
      local jdtls_pkg = mason_packages .. "/jdtls"

      -- Find launcher jar
      local launcher = vim.fn.glob(jdtls_pkg .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      if launcher == "" then
        warn("Could not find jdtls launcher jar. Run :MasonInstall jdtls")
        return
      end

      -- Detect platform-specific config folder
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

      -- Optional Lombok support
      local lombok = jdtls_pkg .. "/lombok.jar"
      local use_lombok = vim.fn.filereadable(lombok) == 1

      -- Find project root
      local root_dir =
        jdtls.setup.find_root({ "pom.xml", "build.gradle", "settings.gradle", ".git", "mvnw", "gradlew" })
      if not root_dir or root_dir == "" then
        root_dir = vim.loop.cwd()
      end

      -- Unique workspace per project
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

      -- Check Java executable
      if vim.fn.executable("java") == 0 then
        warn("`java` executable not found in $PATH. Install JDK 17+ for Spring Boot.")
        return
      end

      -- ========================================================================
      -- Helper: Auto-detect Spring Boot port from config files
      -- ========================================================================
      local function get_spring_boot_port(project_root)
        local paths = {
          project_root .. "/src/main/resources/application.properties",
          project_root .. "/src/main/resources/application.yml",
          project_root .. "/src/main/resources/application.yaml",
          project_root .. "/resources/application.properties",
          project_root .. "/resources/application.yml",
        }

        for _, path in ipairs(paths) do
          if vim.fn.filereadable(path) == 1 then
            local content = vim.fn.readfile(path)
            for _, line in ipairs(content) do
              -- Match: server.port=8081 or server.port: 8081
              local port = line:match("^%s*server%.port%s*[:=]%s*(%d+)%s*$")
              if port then
                return tonumber(port)
              end
            end
          end
        end

        -- Fallback to env var
        local env_port = os.getenv("SPRING_BOOT_PORT")
        if env_port then
          return tonumber(env_port)
        end

        -- Default
        return 8080
      end

      -- ========================================================================
      -- LSP Configuration with Keymaps
      -- ========================================================================
      local config = {
        cmd = cmd,
        root_dir = root_dir,
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = { enabled = true },
            format = { enabled = true },
          },
        },
        on_attach = function(client, bufnr)
          -- ✅ Correct keymap helper: set(mode, lhs, rhs, opts)
          local function buf_set_keymap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- Basic LSP navigation
          buf_set_keymap("n", "gd", vim.lsp.buf.definition, "Go to definition")
          buf_set_keymap("n", "gr", vim.lsp.buf.references, "References")
          buf_set_keymap("n", "K", vim.lsp.buf.hover, "Hover")
          buf_set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")

          -- Java-specific via jdtls
          if jdtls then
            buf_set_keymap("n", "<leader>jo", function()
              jdtls.organize_imports()
            end, "Organize Imports")
            buf_set_keymap("n", "<leader>jv", function()
              jdtls.extract_variable()
            end, "Extract Variable")
            buf_set_keymap("n", "<leader>jc", function()
              jdtls.extract_constant()
            end, "Extract Constant")
            buf_set_keymap("n", "<leader>jm", function()
              jdtls.extract_method()
            end, "Extract Method")
          end

          -- ====================================================================
          -- Spring Boot ToggleTerm Commands
          -- ====================================================================
          local function is_maven()
            return vim.fn.filereadable(root_dir .. "/pom.xml") == 1 or vim.fn.filereadable(root_dir .. "/mvnw") == 1
          end

          local function get_run_cmd()
            if is_maven() then
              return (vim.fn.filereadable(root_dir .. "/mvnw") == 1) and (root_dir .. "/mvnw spring-boot:run")
                or ("mvn -f " .. root_dir .. " spring-boot:run")
            else
              return (vim.fn.filereadable(root_dir .. "/gradlew") == 1) and (root_dir .. "/gradlew bootRun")
                or ("gradle -p " .. root_dir .. " bootRun")
            end
          end

          -- 🚀 Run Spring Boot
          buf_set_keymap("n", "<leader>jsr", function()
            local cmd = get_run_cmd()
            vim.cmd("TermExec cmd='" .. cmd .. "' direction=float")
          end, "Spring Boot Run")

          -- 🛑 Stop Spring Boot (kill processes)
          buf_set_keymap("n", "<leader>jss", function()
            vim.fn.jobstart({ "pkill", "-f", "spring-boot:run" }, { detach = true })
            vim.fn.jobstart({ "pkill", "-f", "bootRun" }, { detach = true })
            vim.notify("⚠ Attempted to stop Spring Boot processes", vim.log.levels.INFO)
          end, "Spring Boot Stop")

          -- ♻ Compile Workspace → DevTools auto-restart (NO manual stop needed)
          buf_set_keymap("n", "<leader>jsc", function()
            if jdtls then
              jdtls.compile_workspace()
              vim.notify("✓ Workspace compiled. DevTools will auto-restart if enabled.", vim.log.levels.INFO)
            end
          end, "Compile Workspace (DevTools Refresh)")

          -- 🔄 Actuator /refresh endpoint (auto-detects port, NO restart)
          buf_set_keymap("n", "<leader>jsa", function()
            local port = get_spring_boot_port(root_dir)
            local url = "http://localhost:" .. port .. "/actuator/refresh"

            if vim.fn.executable("curl") == 1 then
              local code =
                vim.fn.system({ "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "-X", "POST", url }):trim()
              if code == "200" then
                vim.notify("✓ Refreshed via Actuator (port " .. port .. ")", vim.log.levels.INFO)
              else
                vim.notify("✗ Actuator failed (HTTP " .. code .. ") on port " .. port, vim.log.levels.WARN)
              end
            elseif vim.fn.executable("wget") == 1 then
              vim.fn.system({ "wget", "-q", "--post-data", "", "-O", "-", url })
              vim.notify("✓ Sent refresh to port " .. port, vim.log.levels.INFO)
            else
              vim.notify("⚠ Install curl/wget for Actuator refresh", vim.log.levels.WARN)
            end
          end, "Actuator Refresh (Auto-Port)")
        end,
      }

      -- Start or attach JDTLS
      jdtls.start_or_attach(config)
    end,
  },

  -- ============================================================================
  -- Which-Key: Friendly labels for Java/Spring keymaps
  -- ============================================================================
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
