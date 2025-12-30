local M = {}

function M.get(url, callback)
  local config = require("canary.config").get()

  vim.system(
    { "curl", "-s", "-L", "-H", "User-Agent: " .. config.http.user_agent, url },
    { text = true, timeout = config.http.timeout },
    function(result)
      vim.schedule(function()
        if result.code == 0 and result.stdout then
          local ok, data = pcall(vim.json.decode, result.stdout)
          if ok then
            callback(nil, data)
          else
            callback("JSON parse error", nil)
          end
        else
          callback(result.stderr or "Request failed", nil)
        end
      end)
    end
  )
end

function M.get_raw(url, callback)
  local config = require("canary.config").get()

  vim.system(
    { "curl", "-s", "-L", "-H", "User-Agent: " .. config.http.user_agent, url },
    { text = true, timeout = config.http.timeout },
    function(result)
      vim.schedule(function()
        if result.code == 0 and result.stdout then
          callback(nil, result.stdout)
        else
          callback(result.stderr or "Request failed", nil)
        end
      end)
    end
  )
end

function M.get_all(urls, callback)
  local results = {}
  local pending = #urls

  if pending == 0 then
    callback(results)
    return
  end

  for i, url in ipairs(urls) do
    M.get(url, function(err, data)
      results[i] = { error = err, data = data, url = url }
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    end)
  end
end

return M
