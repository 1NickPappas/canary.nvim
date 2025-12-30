local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local current_section = nil

  for i, line in ipairs(lines) do
    local section = line:match("^%s*%[([%w%-%.]+)%]%s*$")
    if section then
      current_section = section
    elseif current_section then
      local is_deps = current_section == "dependencies"
        or current_section:match("^dependencies%.") ~= nil
      local is_dev = current_section == "dev-dependencies"
        or current_section:match("^dev%-dependencies%.") ~= nil

      if is_deps or is_dev then
        local name, version = M._parse_dependency_line(line)
        if name and version then
          table.insert(deps, {
            name = name,
            current = version,
            line = i,
            dev = is_dev,
          })
        end
      end
    end
  end

  return deps
end

function M._parse_dependency_line(line)
  local name, version = line:match('^%s*([%w_%-]+)%s*=%s*"([^"]+)"')
  if name and version then
    return name, version
  end

  name, version = line:match('^%s*([%w_%-]+)%s*=%s*{[^}]*version%s*=%s*"([^"]+)"')
  if name and version then
    return name, version
  end

  name = line:match("^%s*([%w_%-]+)%s*=%s*{")
  if name then
    local vers = line:match('version%s*=%s*"([^"]+)"')
    if vers then
      return name, vers
    end
  end

  return nil, nil
end

return M
