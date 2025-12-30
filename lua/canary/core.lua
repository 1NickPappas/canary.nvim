local M = {}

M._state = {}

function M.check_buffer(bufnr, opts)
  opts = opts or {}
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local parsers = require("canary.parsers")
  local sources = require("canary.sources")
  local semver = require("canary.semver")
  local virtual_text = require("canary.ui.virtual_text")

  local filetype = parsers.detect(filename)
  if not filetype then
    return
  end

  local parser = parsers.get(filetype)
  local source = sources.get(filetype)

  if not parser or not source then
    return
  end

  local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
  local deps = parser.parse(content)

  if #deps == 0 then
    return
  end

  virtual_text.show_loading(bufnr, deps)

  source.fetch_versions(deps, opts.force, function(results)
    vim.schedule(function()
      for _, dep in ipairs(results) do
        dep.status = semver.compare_status(dep.current, dep.latest)
      end

      local existing = M._state[bufnr] or {}
      M._state[bufnr] = {
        deps = results,
        visible = true,
        hide_up_to_date = existing.hide_up_to_date or false,
      }

      virtual_text.render(bufnr, results, { hide_up_to_date = M._state[bufnr].hide_up_to_date })
    end)
  end)
end

function M.get_state(bufnr)
  return M._state[bufnr]
end

function M.clear_state(bufnr)
  M._state[bufnr] = nil
end

function M.toggle_filter(bufnr)
  local state = M._state[bufnr]
  if not state or not state.deps then
    return
  end

  state.hide_up_to_date = not state.hide_up_to_date

  local virtual_text = require("canary.ui.virtual_text")
  virtual_text.render(bufnr, state.deps, { hide_up_to_date = state.hide_up_to_date })
end

return M
