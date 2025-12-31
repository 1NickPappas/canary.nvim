local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local current_section = nil

  for i, line in ipairs(lines) do
    -- Check for section headers
    local section = line:match("^%s*%[([%w%-_]+)%]%s*$")
    if section then
      current_section = section:lower()
    elseif current_section == "packages" or current_section == "dev-packages" then
      local name, version = M._parse_dependency_line(line)
      if name then
        table.insert(deps, {
          name = name,
          current = version or "*",
          line = i,
          dev = current_section == "dev-packages",
        })
      end
    end
  end

  return deps
end

function M._parse_dependency_line(line)
  -- Skip empty lines and comments
  if line:match("^%s*$") or line:match("^%s*#") then
    return nil, nil
  end

  local name, version

  -- Format: package = ">=1.0"
  name, version = line:match('^%s*([%w_%-]+)%s*=%s*"([^"]*)"')
  if name and version then
    -- Handle "*" as no version constraint
    if version == "*" then
      version = nil
    end
    return name:lower(), version
  end

  -- Format: package = "*"
  name = line:match('^%s*([%w_%-]+)%s*=%s*"%*"')
  if name then
    return name:lower(), nil
  end

  -- Format: package = {version = ">=1.0", ...}
  name, version = line:match('^%s*([%w_%-]+)%s*=%s*{[^}]*version%s*=%s*"([^"]*)"')
  if name and version then
    return name:lower(), version
  end

  -- Format: package = {git = "...", ...} (no version)
  name = line:match("^%s*([%w_%-]+)%s*=%s*{")
  if name and not line:match("version") then
    return name:lower(), nil
  end

  return nil, nil
end

return M
