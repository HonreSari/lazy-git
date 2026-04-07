-- State management
local state = { buf = nil, win = nil, is_open = false }

local function toggle_floating_term()
  if state.is_open and state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, false)
    state.is_open = false
    return
  end

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].bufhidden = "hide"
    vim.bo[state.buf].filetype = "terminal"
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.wo[state.win].winblend = 0
  vim.wo[state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
  vim.api.nvim_set_hl(0, "FloatingTermNormal", { link = "Normal" })
  vim.api.nvim_set_hl(0, "FloatingTermBorder", { link = "FloatBorder" })

  local has_content = false
  for _, line in ipairs(vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)) do
    if line ~= "" then
      has_content = true
      break
    end
  end

  if not has_content then
    vim.fn.termopen(vim.env.SHELL or "bash")
  end

  state.is_open = true
  vim.cmd("startinsert")
end

return {
  -- ✅ Use dir to point to current config (prevents GitHub clone attempt)
  dir = vim.fn.stdpath("config"),
  name = "floating-term", -- Just a label, not a repo name
  lazy = true,
  keys = {
    { "<leader>ft", toggle_floating_term, desc = "Toggle Floating Terminal" },
  },
  config = function()
    vim.keymap.set("t", "<Esc>", function()
      if state.is_open and state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, false)
        state.is_open = false
      end
    end, { desc = "Close floating terminal" })
  end,
}
