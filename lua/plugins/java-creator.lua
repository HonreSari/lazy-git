-- Java Automatic Template (IntelliJ-like behavior)
-- Auto inserts package + class name when creating new .java file

return {
  {
    "nvim-mini/mini.nvim", -- We only need this for safety, but actually not required
    version = false,
    config = function()
      vim.api.nvim_create_autocmd("BufNewFile", {
        pattern = "*.java",
        callback = function()
          local filename = vim.fn.expand("%:t:r") -- Class name
          local dir = vim.fn.expand("%:p:h")

          -- Detect package from folder (src/main/java/com/example/...)
          local package = ""
          local java_root = dir:match("src/main/java/(.+)") or dir:match("src/test/java/(.+)")

          if java_root then
            package = java_root:gsub("/", ".")
          end

          local template = string.format(
            [[
package %s;

public class %s {

}
]],
            package == "" and "com.example.demo" or package,
            filename
          )

          -- Insert the template
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, "\n"))

          -- Move cursor inside the class and enter insert mode
          vim.cmd("normal! ggj")
          vim.cmd("startinsert")
        end,
      })
    end,
  },
}
