local M = {}

local http = require("canary.http")
local cache = require("canary.cache")

-- Maven Central Search API
local REGISTRY_URL = "https://search.maven.org/solrsearch/select"

function M.fetch_versions(deps, force, callback)
  local results = {}
  local pending = #deps

  if pending == 0 then
    callback(results)
    return
  end

  for i, dep in ipairs(deps) do
    local cached = not force and cache.get(dep.name, "maven")

    if cached then
      results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    else
      -- dep.name is "groupId:artifactId" format
      local group_id, artifact_id = dep.name:match("^([^:]+):(.+)$")
      if not group_id then
        artifact_id = dep.name
        group_id = ""
      end

      local query = string.format("g:%s+AND+a:%s", group_id, artifact_id)
      local url = string.format("%s?q=%s&rows=1&wt=json", REGISTRY_URL, query)

      http.get(url, function(err, data)
        if err or not data then
          results[i] = vim.tbl_extend("force", dep, {
            latest = nil,
            error = err or "Unknown error",
          })
        else
          local latest = nil
          if data.response and data.response.docs and #data.response.docs > 0 then
            latest = data.response.docs[1].latestVersion
          end

          results[i] = vim.tbl_extend("force", dep, { latest = latest })

          if latest then
            cache.set(dep.name, "maven", { latest = latest, fetched = os.time() })
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
