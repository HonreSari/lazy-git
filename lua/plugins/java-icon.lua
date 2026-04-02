return {
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      local devicons = require("nvim-web-devicons")

      local function get_java_icon(filepath)
        local file = io.open(filepath, "r")
        if not file then
          return nil
        end

        local content = file:read("*a")
        file:close()

        if content:match("record%s+") then
          return "", "Identifier"
        elseif content:match("interface%s+") then
          return "", "Type"
        elseif content:match("enum%s+") then
          return "", "Constant"
        elseif content:match("class%s+") then
          return "ﴯ", "Structure"
        end

        return "", "Normal"
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
        pattern = "*.java",
        callback = function(args)
          local icon, hl = get_java_icon(args.file)

          if icon then
            vim.b.devicons_icon = icon
            vim.b.devicons_highlight = hl
          end
        end,
      })
    end,
  },
}
