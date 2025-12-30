local M = {}

function M.parse(content)
  local ok, data = pcall(vim.json.decode, content, { luanil = { object = true } })
  if not ok or not data then
    return {}
  end

  local deps = {}
  local lines = vim.split(content, "\n")

  local function find_line(name, in_dev)
    local section = in_dev and '"devDependencies"' or '"dependencies"'
    local in_section = false

    for i, line in ipairs(lines) do
      if line:find(section, 1, true) then
        in_section = true
      elseif in_section then
        if line:match("^%s*}") then
          in_section = false
        elseif line:find('"' .. name:gsub("%-", "%%-") .. '"', 1, false) then
          return i
        end
      end
    end
    return nil
  end

  for name, version in pairs(data.dependencies or {}) do
    table.insert(deps, {
      name = name,
      current = version,
      line = find_line(name, false),
      dev = false,
    })
  end

  for name, version in pairs(data.devDependencies or {}) do
    table.insert(deps, {
      name = name,
      current = version,
      line = find_line(name, true),
      dev = true,
    })
  end

  table.sort(deps, function(a, b)
    if a.line and b.line then
      return a.line < b.line
    end
    return a.name < b.name
  end)

  return deps
end

return M
