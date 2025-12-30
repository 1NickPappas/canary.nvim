local M = {}

function M._get_cache_dir()
  local config = require("canary.config").get()
  local dir = config.cache.path or (vim.fn.stdpath("cache") .. "/canary")
  vim.fn.mkdir(dir, "p")
  return dir
end

function M._get_cache_path(key, source)
  local safe_key = key:gsub("/", "_"):gsub("@", "_at_")
  return string.format("%s/%s_%s.json", M._get_cache_dir(), source, safe_key)
end

function M.get(key, source)
  local config = require("canary.config").get()
  if not config.cache.enabled then
    return nil
  end

  local path = M._get_cache_path(key, source)
  local stat = vim.uv.fs_stat(path)

  if not stat then
    return nil
  end

  local age = os.time() - stat.mtime.sec
  if age > config.cache.ttl then
    vim.uv.fs_unlink(path)
    return nil
  end

  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  return ok and data or nil
end

function M.set(key, source, data)
  local config = require("canary.config").get()
  if not config.cache.enabled then
    return
  end

  local path = M._get_cache_path(key, source)
  local file = io.open(path, "w")
  if file then
    file:write(vim.json.encode(data))
    file:close()
  end
end

function M.invalidate(key, source)
  local path = M._get_cache_path(key, source)
  local stat = vim.uv.fs_stat(path)
  if stat then
    vim.uv.fs_unlink(path)
  end
end

function M.invalidate_all()
  local dir = M._get_cache_dir()
  for name, type in vim.fs.dir(dir) do
    if type == "file" then
      vim.uv.fs_unlink(dir .. "/" .. name)
    end
  end
end

return M
