local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  for i, line in ipairs(lines) do
    -- Skip empty lines, comments, and options
    if line:match("^%s*$") or line:match("^%s*#") or line:match("^%-") then
      goto continue
    end

    -- Skip -r (include), -e (editable), -i (index-url), etc.
    if line:match("^%s*%-[reicf]") then
      goto continue
    end

    local name, version = M._parse_requirement(line)
    if name then
      table.insert(deps, {
        name = name,
        current = version or "*",
        line = i,
        dev = false, -- requirements.txt doesn't distinguish
      })
    end

    ::continue::
  end

  return deps
end

function M._parse_requirement(line)
  -- Strip inline comments
  line = line:gsub("%s*#.*$", "")
  -- Strip whitespace
  line = line:match("^%s*(.-)%s*$")

  if not line or line == "" then
    return nil, nil
  end

  local name, version

  -- Handle various specifiers: >=, <=, ~=, ==, !=, <, >, ~
  -- requests>=2.28.0
  -- flask~=2.0
  -- click==8.1.0
  name, version = line:match("^([%w_%-%.]+)([><=~!]+.*)$")
  if name and version then
    return name:lower(), version
  end

  -- Handle extras: requests[security]>=2.0
  name, version = line:match("^([%w_%-%.]+)%[.-%]([><=~!]+.*)$")
  if name and version then
    return name:lower(), version
  end

  -- No version specified
  name = line:match("^([%w_%-%.]+)%s*$")
  if name then
    return name:lower(), nil
  end

  -- With extras but no version
  name = line:match("^([%w_%-%.]+)%[.-%]%s*$")
  if name then
    return name:lower(), nil
  end

  return nil, nil
end

return M
