local M = {}

function M.show_line_details(bufnr, line)
  local core = require("canary.core")
  local state = core.get_state(bufnr)

  if not state then
    return
  end

  local dep = nil
  for _, d in ipairs(state.deps) do
    if d.line and d.line - 1 == line then
      dep = d
      break
    end
  end

  if not dep then
    return
  end

  local lines = {
    string.format("Package: %s", dep.name),
    "",
    string.format("Current:  %s", dep.current),
    string.format("Latest:   %s", dep.latest or "Unknown"),
    string.format("Status:   %s", dep.status or "unknown"),
    "",
    dep.dev and "Type: devDependency" or "Type: dependency",
  }

  if dep.error then
    table.insert(lines, "")
    table.insert(lines, string.format("Error: %s", dep.error))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = 40
  local height = #lines

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    width = width,
    height = height,
    row = 1,
    col = 0,
    style = "minimal",
    border = "rounded",
    title = " Dependency Info ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf })

  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end

return M
