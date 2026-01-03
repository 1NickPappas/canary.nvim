local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  for i, line in ipairs(lines) do
    -- Match PackageVersion with Include and Version attributes
    -- <PackageVersion Include="Newtonsoft.Json" Version="13.0.1" />
    local name, version = line:match('<PackageVersion%s+Include="([^"]+)"%s+Version="([^"]+)"')

    -- Also match with attributes in different order
    if not name then
      name, version = line:match('<PackageVersion%s+Version="([^"]+)"%s+Include="([^"]+)"')
      if name then
        -- Swap since pattern captured in wrong order
        name, version = version, name
      end
    end

    -- Match multi-line PackageVersion
    if not name then
      name = line:match('<PackageVersion%s+Include="([^"]+)"')
      if name then
        -- Look for Version on same line or next few lines
        version = line:match('Version="([^"]+)"')
        if not version then
          -- Check next few lines for Version
          for j = i + 1, math.min(i + 3, #lines) do
            version = lines[j]:match('Version="([^"]+)"')
            if version then
              break
            end
            if lines[j]:match("</PackageVersion>") or lines[j]:match("/>") then
              break
            end
          end
        end
      end
    end

    if name and version then
      table.insert(deps, {
        name = name,
        current = version,
        line = i,
        dev = false,
      })
    end
  end

  return deps
end

return M
