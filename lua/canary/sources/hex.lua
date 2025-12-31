local M = {}

local http = require("canary.http")
local cache = require("canary.cache")

local HEX_API = "https://hex.pm/api/packages"

function M.fetch_versions(deps, force, callback)
  local results = {}
  local pending = #deps

  if pending == 0 then
    callback(results)
    return
  end

  for i, dep in ipairs(deps) do
    local cached = not force and cache.get(dep.name, "hex")

    if cached then
      results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    else
      local url = string.format("%s/%s", HEX_API, dep.name)

      http.get(url, function(err, data)
        if err or not data then
          results[i] = vim.tbl_extend("force", dep, {
            latest = nil,
            error = err or "Unknown error",
          })
        else
          local latest = M._get_latest_version(data)
          results[i] = vim.tbl_extend("force", dep, { latest = latest })

          if latest then
            cache.set(dep.name, "hex", { latest = latest, fetched = os.time() })
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

function M._get_latest_version(data)
  local releases = data.releases
  if not releases or #releases == 0 then
    return nil
  end

  -- Find latest stable release (not pre-release)
  for _, release in ipairs(releases) do
    local version = release.version
    if version and not version:match("%-") then
      -- No hyphen means no pre-release suffix
      return version
    end
  end

  -- Fallback to first release
  return releases[1] and releases[1].version
end

return M
