local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local in_dev_group = false
  local group_depth = 0

  for i, line in ipairs(lines) do
    -- Track group blocks
    if line:match("^%s*group%s+:development") or line:match("^%s*group%s+:test") then
      in_dev_group = true
      if line:match("%s+do%s*$") then
        group_depth = group_depth + 1
      end
    elseif line:match("^%s*do%s*$") and in_dev_group then
      group_depth = group_depth + 1
    elseif line:match("^%s*end%s*$") and in_dev_group then
      group_depth = group_depth - 1
      if group_depth <= 0 then
        in_dev_group = false
        group_depth = 0
      end
    end

    -- Parse gem lines: gem 'name', '~> 1.0' or gem "name", "~> 1.0"
    local name, version = line:match("^%s*gem%s+['\"]([^'\"]+)['\"]%s*,%s*['\"]([^'\"]+)['\"]")
    if name then
      table.insert(deps, {
        name = name,
        current = version,
        line = i,
        dev = in_dev_group,
      })
    else
      -- Gem without version: gem 'name'
      name = line:match("^%s*gem%s+['\"]([^'\"]+)['\"]%s*$")
      if name then
        table.insert(deps, {
          name = name,
          current = "*",
          line = i,
          dev = in_dev_group,
        })
      end
    end
  end

  return deps
end

return M
