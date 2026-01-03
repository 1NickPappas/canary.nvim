local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local current_section = nil

  -- First pass: collect version references
  local versions = {}
  for _, line in ipairs(lines) do
    local section = line:match("^%s*%[([%w%-%.]+)%]%s*$")
    if section then
      current_section = section
    elseif current_section == "versions" then
      local name, version = line:match('^%s*([%w_%-]+)%s*=%s*"([^"]+)"')
      if name and version then
        versions[name] = version
      end
    end
  end

  -- Second pass: parse libraries
  current_section = nil
  for i, line in ipairs(lines) do
    local section = line:match("^%s*%[([%w%-%.]+)%]%s*$")
    if section then
      current_section = section
    elseif current_section == "libraries" then
      local dep = M._parse_library_line(line, versions)
      if dep then
        dep.line = i
        table.insert(deps, dep)
      end
    end
  end

  return deps
end

function M._parse_library_line(line, versions)
  -- Match: name = "group:artifact:version" (shorthand notation)
  local alias, coords = line:match('^%s*([%w_%-]+)%s*=%s*"([^"]+)"')
  if alias and coords then
    local group, artifact, version = coords:match("^([^:]+):([^:]+):([^:]+)$")
    if group and artifact and version then
      return {
        name = group .. ":" .. artifact,
        display_name = artifact,
        current = version,
        dev = false,
      }
    end
  end

  -- Match: name = { module = "group:artifact", version = "x.y.z" }
  local module_coords = line:match('module%s*=%s*"([^"]+)"')
  if module_coords then
    local group, artifact = module_coords:match("^([^:]+):([^:]+)$")
    if group and artifact then
      -- Check for direct version
      local version = line:match('version%s*=%s*"([^"]+)"')
      -- Check for version.ref
      if not version then
        local version_ref = line:match('version%.ref%s*=%s*"([^"]+)"')
        if version_ref and versions[version_ref] then
          version = versions[version_ref]
        end
      end

      if version then
        return {
          name = group .. ":" .. artifact,
          display_name = artifact,
          current = version,
          dev = false,
        }
      end
    end
  end

  -- Match: name = { group = "...", name = "...", version.ref = "..." }
  local group = line:match('group%s*=%s*"([^"]+)"')
  local name = line:match('name%s*=%s*"([^"]+)"')

  if group and name then
    -- Check for direct version
    local version = line:match('version%s*=%s*"([^"]+)"')
    -- Check for version.ref
    if not version then
      local version_ref = line:match('version%.ref%s*=%s*"([^"]+)"')
      if version_ref and versions[version_ref] then
        version = versions[version_ref]
      end
    end

    if version then
      return {
        name = group .. ":" .. name,
        display_name = name,
        current = version,
        dev = false,
      }
    end
  end

  return nil
end

return M
