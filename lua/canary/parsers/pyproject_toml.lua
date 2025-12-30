local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local current_section = nil
  local in_dependencies_array = false

  for i, line in ipairs(lines) do
    local section = line:match("^%s*%[([%w%-%.]+)%]%s*$")
    if section then
      current_section = section
      in_dependencies_array = false
    elseif current_section then
      -- Check for dependencies array start
      if current_section == "project" and line:match("^%s*dependencies%s*=%s*%[") then
        in_dependencies_array = true
      elseif in_dependencies_array then
        -- End of array
        if line:match("^%s*%]") then
          in_dependencies_array = false
        else
          -- Parse dependency line: "package>=1.0.0" or "package~=1.0"
          local dep_str = line:match('^%s*"([^"]+)"')
          if dep_str then
            local name, version = M._parse_requirement(dep_str)
            if name then
              table.insert(deps, {
                name = name,
                current = version or "*",
                line = i,
                dev = false,
              })
            end
          end
        end
      -- Check for optional-dependencies (dev deps)
      elseif current_section:match("^project%.optional%-dependencies") then
        local dep_str = line:match('^%s*"([^"]+)"')
        if dep_str then
          local name, version = M._parse_requirement(dep_str)
          if name then
            table.insert(deps, {
              name = name,
              current = version or "*",
              line = i,
              dev = true,
            })
          end
        end
      end
    end
  end

  return deps
end

function M._parse_requirement(req)
  -- Handle various Python version specifiers:
  -- requests>=2.0.0, requests~=2.0, requests==2.0.0, requests
  local name, version

  -- Try operators: >=, <=, ~=, ==, !=, <, >
  name, version = req:match("^([%w_%-]+)([><=~!]+.*)$")
  if name and version then
    return name, version
  end

  -- No version specified
  name = req:match("^([%w_%-]+)$")
  if name then
    return name, nil
  end

  -- Handle extras: requests[security]>=2.0
  name, version = req:match("^([%w_%-]+)%[.-%]([><=~!]+.*)$")
  if name and version then
    return name, version
  end

  name = req:match("^([%w_%-]+)%[.-%]$")
  if name then
    return name, nil
  end

  return nil, nil
end

return M
