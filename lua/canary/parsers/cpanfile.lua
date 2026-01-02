local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  local current_phase = "runtime"

  for i, line in ipairs(lines) do
    -- Check for phase blocks
    if line:match("^%s*on%s+['\"]?test['\"]?") then
      current_phase = "test"
    elseif line:match("^%s*on%s+['\"]?develop['\"]?") then
      current_phase = "develop"
    elseif line:match("^%s*on%s+['\"]?build['\"]?") then
      current_phase = "build"
    elseif line:match("^%s*on%s+['\"]?configure['\"]?") then
      current_phase = "configure"
    elseif line:match("^%s*};") then
      current_phase = "runtime"
    end

    -- Parse requires/recommends statements
    -- requires 'Module::Name';
    -- requires 'Module::Name', '1.0';
    -- requires 'Module::Name', '>= 1.0';
    local name, version = line:match("requires%s+['\"]([^'\"]+)['\"]%s*,%s*['\"]([^'\"]+)['\"]")
    if not name then
      -- Without version
      name = line:match("requires%s+['\"]([^'\"]+)['\"]%s*;")
      version = "any"
    end

    if name then
      -- Clean up version
      if version then
        version = version:gsub("^[><=!]+%s*", "")
        version = version:gsub("%s+$", "")
      end

      table.insert(deps, {
        name = name,
        current = version or "any",
        line = i,
        dev = current_phase ~= "runtime",
      })
    end

    -- Also parse recommends
    local rec_name, rec_version = line:match("recommends%s+['\"]([^'\"]+)['\"]%s*,%s*['\"]([^'\"]+)['\"]")
    if not rec_name then
      rec_name = line:match("recommends%s+['\"]([^'\"]+)['\"]%s*;")
      rec_version = "any"
    end

    if rec_name then
      if rec_version then
        rec_version = rec_version:gsub("^[><=!]+%s*", "")
        rec_version = rec_version:gsub("%s+$", "")
      end

      table.insert(deps, {
        name = rec_name,
        current = rec_version or "any",
        line = i,
        dev = true,
      })
    end
  end

  return deps
end

return M
