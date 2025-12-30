local M = {}

local cache = require("canary.cache")

local INDEX_URL = "https://index.crates.io"

function M._get_index_path(name)
  local len = #name
  if len == 1 then
    return "1/" .. name
  elseif len == 2 then
    return "2/" .. name
  elseif len == 3 then
    return "3/" .. name:sub(1, 1) .. "/" .. name
  else
    return name:sub(1, 2) .. "/" .. name:sub(3, 4) .. "/" .. name
  end
end

function M.fetch_versions(deps, force, callback)
  local results = {}
  local pending = #deps
  local config = require("canary.config").get()

  if pending == 0 then
    callback(results)
    return
  end

  for i, dep in ipairs(deps) do
    local cached = not force and cache.get(dep.name, "cargo")

    if cached then
      results[i] = vim.tbl_extend("force", dep, { latest = cached.latest })
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    else
      local path = M._get_index_path(dep.name)
      local url = string.format("%s/%s", INDEX_URL, path)

      vim.system(
        { "curl", "-s", "-L", "-H", "User-Agent: " .. config.http.user_agent, url },
        { text = true, timeout = config.http.timeout },
        function(result)
          vim.schedule(function()
            local latest = nil

            if result.code == 0 and result.stdout then
              for line in result.stdout:gmatch("[^\n]+") do
                local ok, data = pcall(vim.json.decode, line)
                if ok and not data.yanked then
                  latest = data.vers
                end
              end
            end

            results[i] = vim.tbl_extend("force", dep, { latest = latest })

            if latest then
              cache.set(dep.name, "cargo", { latest = latest, fetched = os.time() })
            end

            pending = pending - 1
            if pending == 0 then
              callback(results)
            end
          end)
        end
      )
    end
  end
end

return M
