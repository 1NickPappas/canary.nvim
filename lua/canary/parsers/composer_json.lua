local M = {}

function M.parse(content)
  local deps = {}

  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data then
    return deps
  end

  local lines = vim.split(content, "\n")

  -- Parse require section
  if data.require then
    for name, version in pairs(data.require) do
      -- Skip php and extensions
      if not name:match("^php$") and not name:match("^ext%-") then
        local line = M._find_line(lines, name, "require")
        table.insert(deps, {
          name = name,
          current = version,
          line = line,
          dev = false,
        })
      end
    end
  end

  -- Parse require-dev section
  if data["require-dev"] then
    for name, version in pairs(data["require-dev"]) do
      local line = M._find_line(lines, name, "require-dev")
      table.insert(deps, {
        name = name,
        current = version,
        line = line,
        dev = true,
      })
    end
  end

  return deps
end

function M._find_line(lines, name, section)
  local in_section = false
  local escaped_name = name:gsub("([%-%.%/])", "%%%1")

  for i, line in ipairs(lines) do
    if line:match('"' .. section .. '"') then
      in_section = true
    elseif in_section then
      if line:match("^%s*}") then
        in_section = false
      elseif line:match('"' .. escaped_name .. '"') then
        return i
      end
    end
  end

  return nil
end

return M
