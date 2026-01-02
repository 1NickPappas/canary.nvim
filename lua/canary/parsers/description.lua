local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  -- R DESCRIPTION uses DCF format
  -- Fields: Depends, Imports, Suggests, LinkingTo
  local dep_fields = {
    Depends = false,
    Imports = false,
    Suggests = true,
    LinkingTo = false,
  }

  local current_field = nil
  local current_value = ""
  local field_line = nil

  local function process_field()
    if current_field and dep_fields[current_field] ~= nil then
      local is_dev = dep_fields[current_field]
      local packages = M._parse_packages(current_value)
      for _, pkg in ipairs(packages) do
        -- Skip R itself
        if pkg.name ~= "R" then
          pkg.line = field_line
          pkg.dev = is_dev
          table.insert(deps, pkg)
        end
      end
    end
  end

  for i, line in ipairs(lines) do
    -- Check for new field
    local field, value = line:match("^([%w]+):%s*(.*)$")
    if field then
      -- Process previous field
      process_field()

      -- Start new field
      current_field = field
      current_value = value or ""
      field_line = i
    elseif line:match("^%s+") and current_field then
      -- Continuation line
      current_value = current_value .. " " .. line:gsub("^%s+", "")
    else
      -- Empty line or other content
      process_field()
      current_field = nil
      current_value = ""
    end
  end

  -- Process last field
  process_field()

  return deps
end

function M._parse_packages(value)
  local packages = {}

  -- Split by comma, handling possible line continuations
  value = value:gsub("%s+", " ")
  local parts = vim.split(value, ",")

  for _, part in ipairs(parts) do
    part = part:gsub("^%s+", ""):gsub("%s+$", "")
    if part ~= "" then
      -- Parse: "package (>= 1.0)" or just "package"
      local name, version = part:match("^([%w%.]+)%s*%(([^%)]+)%)")
      if not name then
        name = part:match("^([%w%.]+)")
        version = "any"
      else
        -- Clean up version constraint
        version = version:gsub("^[><=]+%s*", "")
        version = version:gsub("%s+$", "")
      end

      if name and name ~= "" then
        table.insert(packages, {
          name = name,
          current = version or "any",
        })
      end
    end
  end

  return packages
end

return M
