local M = {}

local function replace_version_in_line(line_content, current_version, new_version)
  -- Extract the prefix from current version (^, ~, >=, etc.)
  local prefix = current_version:match("^([^%d]*)") or ""

  -- Build the new version string with the same prefix
  local new_version_str = prefix .. new_version

  -- Find and replace the version in the line
  -- Match version in quotes: "^1.0.0" or "1.0.0"
  local pattern = '"' .. vim.pesc(current_version) .. '"'
  local replacement = '"' .. new_version_str .. '"'

  local new_line = line_content:gsub(pattern, replacement, 1)

  if new_line == line_content then
    -- Try single quotes (less common but possible)
    pattern = "'" .. vim.pesc(current_version) .. "'"
    replacement = "'" .. new_version_str .. "'"
    new_line = line_content:gsub(pattern, replacement, 1)
  end

  return new_line, new_line ~= line_content
end

function M.update_all(bufnr)
  local core = require("canary.core")
  local state = core.get_state(bufnr)

  if not state or not state.deps then
    vim.notify("Canary: No dependency data. Run :CanaryCheck first.", vim.log.levels.WARN)
    return
  end

  local outdated = {}
  for _, dep in ipairs(state.deps) do
    if dep.status and dep.status ~= "up_to_date" and dep.latest and dep.line then
      table.insert(outdated, dep)
    end
  end

  if #outdated == 0 then
    vim.notify("Canary: All dependencies are up to date!", vim.log.levels.INFO)
    return
  end

  -- Sort by line number descending (so we don't mess up line numbers as we edit)
  table.sort(outdated, function(a, b)
    return a.line > b.line
  end)

  local updated_count = 0

  for _, dep in ipairs(outdated) do
    local line_idx = dep.line - 1
    local lines = vim.api.nvim_buf_get_lines(bufnr, line_idx, line_idx + 1, false)

    if #lines > 0 then
      local line_content = lines[1]
      local new_line, changed = replace_version_in_line(line_content, dep.current, dep.latest)

      if changed then
        vim.api.nvim_buf_set_lines(bufnr, line_idx, line_idx + 1, false, { new_line })
        updated_count = updated_count + 1
      end
    end
  end

  if updated_count > 0 then
    vim.notify(
      string.format("Canary: Updated %d dependenc%s", updated_count, updated_count == 1 and "y" or "ies"),
      vim.log.levels.INFO
    )
    -- Refresh to show new state
    vim.defer_fn(function()
      core.check_buffer(bufnr, { force = true })
    end, 100)
  else
    vim.notify("Canary: No dependencies were updated", vim.log.levels.WARN)
  end
end

function M.update_line(bufnr, line)
  local core = require("canary.core")
  local state = core.get_state(bufnr)

  if not state or not state.deps then
    return
  end

  for _, dep in ipairs(state.deps) do
    if dep.line == line + 1 and dep.status ~= "up_to_date" and dep.latest then
      local lines = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)
      if #lines > 0 then
        local new_line, changed = replace_version_in_line(lines[1], dep.current, dep.latest)
        if changed then
          vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { new_line })
          vim.notify(string.format("Canary: Updated %s to %s", dep.name, dep.latest), vim.log.levels.INFO)
          vim.defer_fn(function()
            core.check_buffer(bufnr, { force = true })
          end, 100)
        end
      end
      return
    end
  end
end

return M
