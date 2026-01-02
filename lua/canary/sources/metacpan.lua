local M = {}

local http = require("canary.http")
local cache = require("canary.cache")

-- MetaCPAN API
local REGISTRY_URL = "https://fastapi.metacpan.org/v1/module"

function M.fetch_versions(deps, force, callback)
  local results = {}
  local pending = #deps

  if pending == 0 then
    callback(results)
    return
  end

  for i, dep in ipairs(deps) do
    local cached = not force and cache.get(dep.name, "cpan")

    if cached then
      results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    else
      -- Convert Perl module name (Foo::Bar) to API format
      local url = string.format("%s/%s", REGISTRY_URL, dep.name)

      http.get(url, function(err, data)
        if err or not data then
          results[i] = vim.tbl_extend("force", dep, {
            latest = nil,
            error = err or "Unknown error",
          })
        else
          local latest = data.version
          results[i] = vim.tbl_extend("force", dep, { latest = latest })

          if latest then
            cache.set(dep.name, "cpan", { latest = latest, fetched = os.time() })
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
