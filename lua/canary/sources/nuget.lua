local M = {}

local http = require("canary.http")
local cache = require("canary.cache")

-- NuGet v3 API
local REGISTRY_URL = "https://api.nuget.org/v3-flatcontainer"

function M.fetch_versions(deps, force, callback)
  local results = {}
  local pending = #deps

  if pending == 0 then
    callback(results)
    return
  end

  for i, dep in ipairs(deps) do
    local cached = not force and cache.get(dep.name, "nuget")

    if cached then
      results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    else
      -- NuGet package names are case-insensitive, lowercase for API
      local pkg_name = dep.name:lower()
      local url = string.format("%s/%s/index.json", REGISTRY_URL, pkg_name)

      http.get(url, function(err, data)
        if err or not data then
          results[i] = vim.tbl_extend("force", dep, {
            latest = nil,
            error = err or "Unknown error",
          })
        else
          -- NuGet returns versions array, last one is latest stable
          local versions = data.versions or {}
          local latest = nil

          -- Find latest non-prerelease version
          for j = #versions, 1, -1 do
            local v = versions[j]
            if not v:match("%-") then -- Skip prereleases
              latest = v
              break
            end
          end

          -- Fallback to last version if all are prereleases
          if not latest and #versions > 0 then
            latest = versions[#versions]
          end

          results[i] = vim.tbl_extend("force", dep, { latest = latest })

          if latest then
            cache.set(dep.name, "nuget", { latest = latest, fetched = os.time() })
          end
        end

        pending = pending - 1
        if pending == 0 then
          callback(results)
        end
      end)
    end
  end
end

return M
