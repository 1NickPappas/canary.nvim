local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  local in_dependencies = false
  local brace_depth = 0

  for i, line in ipairs(lines) do
    -- Check for dependencies block start
    if line:match("dependencies%s*{") then
      in_dependencies = true
      brace_depth = 1
    elseif in_dependencies then
      -- Track brace depth
      for _ in line:gmatch("{") do
        brace_depth = brace_depth + 1
      end
      for _ in line:gmatch("}") do
        brace_depth = brace_depth - 1
      end

      if brace_depth <= 0 then
        in_dependencies = false
      else
        -- Parse Groovy DSL dependency formats:
        -- implementation 'group:artifact:version'
        -- implementation "group:artifact:version"
        -- implementation("group:artifact:version")
        -- implementation(group: 'group', name: 'artifact', version: 'version')
        local dep = M._parse_dependency_line(line)
        if dep then
          dep.line = i
          table.insert(deps, dep)
        end
      end
    end
  end

  return deps
end

function M._parse_dependency_line(line)
  -- Match: implementation 'group:artifact:version' or implementation "group:artifact:version"
  local config, coords = line:match("(%w+)%s+['\"]([^'\"]+)['\"]")
  if config and coords then
    local group, artifact, version = coords:match("^([^:]+):([^:]+):([^:]+)$")
    if group and artifact and version then
      -- Skip variable references like ${...} or $version
      if version:match("^%$") then
        return nil
      end
      return {
        name = group .. ":" .. artifact,
        display_name = artifact,
        current = version,
        dev = config:match("test") ~= nil or config:match("Test") ~= nil,
      }
    end
  end

  -- Match: implementation("group:artifact:version") or implementation('group:artifact:version')
  config, coords = line:match("(%w+)%s*%(%s*['\"]([^'\"]+)['\"]")
  if config and coords then
    local group, artifact, version = coords:match("^([^:]+):([^:]+):([^:]+)$")
    if group and artifact and version then
      if version:match("^%$") then
        return nil
      end
      return {
        name = group .. ":" .. artifact,
        display_name = artifact,
        current = version,
        dev = config:match("test") ~= nil or config:match("Test") ~= nil,
      }
    end
  end

  -- Match: implementation(group: '...', name: '...', version: '...')
  local group = line:match("group%s*:%s*['\"]([^'\"]+)['\"]")
  local name = line:match("name%s*:%s*['\"]([^'\"]+)['\"]")
  local version = line:match("version%s*:%s*['\"]([^'\"]+)['\"]")

  if group and name and version then
    if version:match("^%$") then
      return nil
    end
    local config_match = line:match("^%s*(%w+)%s*%(")
    return {
      name = group .. ":" .. name,
      display_name = name,
      current = version,
      dev = config_match and (config_match:match("test") ~= nil or config_match:match("Test") ~= nil) or false,
    }
  end

  return nil
end

return M
