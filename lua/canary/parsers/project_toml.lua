local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local current_section = nil

  -- First pass: collect all deps from [deps] section
  local dep_names = {}
  local dep_lines = {}

  for i, line in ipairs(lines) do
    local section = line:match("^%s*%[([%w%-]+)%]%s*$")
    if section then
      current_section = section
    elseif current_section == "deps" then
      -- Format: PackageName = "uuid-string"
      local name = line:match('^%s*([%w_]+)%s*=%s*"[%w%-]+"')
      if name then
        dep_names[name] = true
        dep_lines[name] = i
      end
    end
  end

  -- Second pass: get versions from [compat] section
  current_section = nil
  local compat_versions = {}
  local compat_lines = {}

  for i, line in ipairs(lines) do
    local section = line:match("^%s*%[([%w%-]+)%]%s*$")
    if section then
      current_section = section
    elseif current_section == "compat" then
      -- Format: PackageName = "version" or PackageName = ">=1.0, <2.0"
      local name, version = line:match('^%s*([%w_]+)%s*=%s*"([^"]+)"')
      if name and version then
        compat_versions[name] = version
        compat_lines[name] = i
      end
    end
  end

  -- Build deps list - prefer compat line if available, otherwise use deps line
  for name, _ in pairs(dep_names) do
    -- Skip Julia itself
    if name ~= "julia" then
      local version = compat_versions[name] or "any"
      local line_num = compat_lines[name] or dep_lines[name]

      table.insert(deps, {
        name = name,
        current = version,
        line = line_num,
        dev = false,
      })
    end
  end

  -- Also add compat entries that might not be in deps (extras, etc)
  for name, version in pairs(compat_versions) do
    if not dep_names[name] and name ~= "julia" then
      table.insert(deps, {
        name = name,
        current = version,
        line = compat_lines[name],
        dev = false,
      })
    end
  end

  -- Sort by line number
  table.sort(deps, function(a, b)
    if a.line and b.line then
      return a.line < b.line
    end
    return a.name < b.name
  end)

  return deps
end

return M
