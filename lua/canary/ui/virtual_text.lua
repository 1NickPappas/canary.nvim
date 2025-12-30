local M = {}

local ns_id = vim.api.nvim_create_namespace("canary")

M._visible = {}

local function get_highlight(status)
  if status == "up_to_date" then
    return "CanaryUpToDate"
  elseif status == "patch" then
    return "CanaryPatch"
  elseif status == "minor" then
    return "CanaryMinor"
  elseif status == "major" then
    return "CanaryMajor"
  else
    return "CanaryInvalid"
  end
end

local function format_dep(dep)
  local config = require("canary.config").get()
  local icons = require("canary.icons")

  local icon, hl

  if dep.status == "up_to_date" then
    icon = icons.get("up_to_date")
    hl = "CanaryUpToDate"
  elseif dep.status == "patch" or dep.status == "minor" then
    icon = icons.get("outdated")
    hl = get_highlight(dep.status)
  elseif dep.status == "major" then
    icon = icons.get("major")
    hl = "CanaryMajor"
  else
    icon = icons.get("invalid")
    hl = "CanaryInvalid"
  end

  local text
  if config.display_format == "icon_only" then
    text = string.format("  %s", icon)
  elseif config.display_format == "version_only" then
    text = string.format("  %s", dep.latest or "?")
  else
    if dep.status == "up_to_date" then
      text = string.format("  %s %s", icon, dep.latest or dep.current)
    else
      text = string.format("  %s %s → %s", icon, dep.current, dep.latest or "?")
    end
  end

  return text, hl
end

function M.render(bufnr, deps, opts)
  M.clear(bufnr)

  opts = opts or {}
  local config = require("canary.config").get()
  local hide_up_to_date = opts.hide_up_to_date
  if hide_up_to_date == nil then
    hide_up_to_date = config.hide_up_to_date
  end

  for _, dep in ipairs(deps) do
    if dep.line and (not hide_up_to_date or dep.status ~= "up_to_date") then
      local text, hl = format_dep(dep)

      vim.api.nvim_buf_set_extmark(bufnr, ns_id, dep.line - 1, 0, {
        virt_text = { { text, hl } },
        virt_text_pos = "eol",
        hl_mode = "combine",
        priority = 100,
      })
    end
  end

  M._visible[bufnr] = true
end

function M.show_loading(bufnr, deps)
  M.clear(bufnr)
  local icons = require("canary.icons")
  local icon = icons.get("loading")

  for _, dep in ipairs(deps) do
    if dep.line then
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, dep.line - 1, 0, {
        virt_text = { { "  " .. icon .. " checking...", "CanaryLoading" } },
        virt_text_pos = "eol",
      })
    end
  end
end

function M.clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  M._visible[bufnr] = false
end

function M.show(bufnr)
  local core = require("canary.core")
  local state = core.get_state(bufnr)
  if state and state.deps then
    M.render(bufnr, state.deps, { hide_up_to_date = state.hide_up_to_date })
  end
end

function M.toggle(bufnr)
  if M._visible[bufnr] then
    M.clear(bufnr)
  else
    M.show(bufnr)
  end
end

function M.is_visible(bufnr)
  return M._visible[bufnr] or false
end

return M
