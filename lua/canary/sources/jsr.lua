local M = {}

local http = require("canary.http")
local cache = require("canary.cache")

local JSR_API = "https://jsr.io"

function M.fetch_versions(deps, force, callback)
  local results = {}
  local pending = #deps

  if pending == 0 then
    callback(results)
    return
  end

  for i, dep in ipairs(deps) do
    local source_type = dep.source_type or "jsr"

    if source_type == "npm" then
      -- Route npm packages to npm registry
      M._fetch_npm(i, dep, force, results, function()
        pending = pending - 1
        if pending == 0 then
          callback(results)
        end
      end)
    elseif source_type == "jsr" then
      -- Fetch from JSR
      M._fetch_jsr(i, dep, force, results, function()
        pending = pending - 1
        if pending == 0 then
          callback(results)
        end
      end)
    else
      -- Unknown source, skip
      results[i] = vim.tbl_extend("force", dep, { latest = nil, error = "Unknown source" })
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    end
  end
end

function M._fetch_jsr(i, dep, force, results, done)
  local cache_key = (dep.scope or "") .. "/" .. dep.name
  local cached = not force and cache.get(cache_key, "jsr")

  if cached then
    results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
    done()
    return
  end

  local url = string.format("%s/@%s/%s/meta.json", JSR_API, dep.scope, dep.name)

  http.get(url, function(err, data)
    if err or not data then
      results[i] = vim.tbl_extend("force", dep, {
        latest = nil,
        error = err or "Unknown error",
      })
    else
      local latest = data.latest
      results[i] = vim.tbl_extend("force", dep, { latest = latest })

      if latest then
        cache.set(cache_key, "jsr", { latest = latest, fetched = os.time() })
      end
    end
    done()
  end)
end

function M._fetch_npm(i, dep, force, results, done)
  local cached = not force and cache.get(dep.name, "npm")

  if cached then
    results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
    done()
    return
  end

  local pkg_name = dep.name:gsub("/", "%%2f")
  local url = string.format("https://registry.npmjs.org/%s", pkg_name)

  http.get(url, function(err, data)
    if err or not data then
      results[i] = vim.tbl_extend("force", dep, {
        latest = nil,
        error = err or "Unknown error",
      })
    else
      local latest = data["dist-tags"] and data["dist-tags"].latest
      results[i] = vim.tbl_extend("force", dep, { latest = latest })

      if latest then
        cache.set(dep.name, "npm", { latest = latest, fetched = os.time() })
      end
    end
    done()
  end)
end

return M
