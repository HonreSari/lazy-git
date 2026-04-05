return {
  -- No dependencies needed! Pure Neovim Autocmds.
  {
    "nvim-lua/plenary.nvim", -- Optional: only if you want more advanced path utils later, otherwise remove.
    lazy = true,
  },
  {
    "neovim/nvim-lspconfig", -- Ensure LSP is loaded so we can format later if needed
    opts = function()
      -- Add the autocmd here to ensure it runs after LSP setup if you want auto-formatting
      vim.api.nvim_create_autocmd("BufNewFile", {
        pattern = "*.java",
        callback = function(args)
          local bufnr = args.buf
          local filename = vim.fn.expand("%:t:r") -- Class name without extension

          -- Basic validation: Java classes must start with uppercase letter
          if not filename:match("^[A-Z]") then
            return
          end

          local filepath = vim.fn.expand("%:p")
          local dir = vim.fn.fnamemodify(filepath, ":h")

          -- Smart Package Detection:
          -- Look for the last occurrence of "/java/" in the path to determine the root.
          -- This works for: src/main/java/com/example, app/src/java/com/example, etc.
          local package_path = ""
          local java_index = dir:find("/java/")

          if java_index then
            -- Extract everything after "/java/"
            package_path = dir:sub(java_index + 6):gsub("/", ".")
          else
            -- Fallback: If no /java/ folder found, check for /src/
            local src_index = dir:find("/src/")
            if src_index then
              package_path = dir:sub(src_index + 6):gsub("/", ".")
            end
          end

          -- Default package if detection fails
          if package_path == "" then
            package_path = "com.example.demo"
          end

          local template = string.format(
            [[package %s;

public class %s {

}]],
            package_path,
            filename
          )

          -- Insert lines
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(template, "\n"))

          -- Move cursor to inside the class body (line 4, column 1) and enter insert mode
          vim.api.nvim_win_set_cursor(0, { 4, 1 })
          vim.cmd("startinsert")

          -- Optional: Trigger LSP formatting immediately after insertion
          -- vim.lsp.buf.format({ async = true })
        end,
      })
    end,
  },
}
