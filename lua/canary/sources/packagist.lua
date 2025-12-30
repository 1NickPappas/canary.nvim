local M = {}

local http = require("canary.http")
local cache = require("canary.cache")

local REGISTRY_URL = "https://repo.packagist.org/p2"

function M.fetch_versions(deps, force, callback)
  local results = {}
  local pending = #deps

  if pending == 0 then
    callback(results)
    return
  end

  for i, dep in ipairs(deps) do
    local cached = not force and cache.get(dep.name, "packagist")

    if cached then
      results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    else
      local url = string.format("%s/%s.json", REGISTRY_URL, dep.name)

      http.get(url, function(err, data)
        if err or not data then
          results[i] = vim.tbl_extend("force", dep, {
            latest = nil,
            error = err or "Unknown error",
          })
        else
          local latest = M._get_latest_version(data, dep.name)
          results[i] = vim.tbl_extend("force", dep, { latest = latest })

          if latest then
            cache.set(dep.name, "packagist", { latest = latest, fetched = os.time() })
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

function M._get_latest_version(data, package_name)
  local packages = data.packages and data.packages[package_name]
  if not packages or #packages == 0 then
    return nil
  end

  -- Find latest stable version (no dev, alpha, beta, RC)
  for _, pkg in ipairs(packages) do
    local version = pkg.version
    if version and not version:match("dev") and not version:match("alpha") and not version:match("beta") and not version:match("RC") then
      -- Remove 'v' prefix if present
      return version:gsub("^v", "")
    end
  end

  -- Fallback to first version
  return packages[1].version
end

return M
