local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  local in_dependencies = false
  local brace_depth = 0

  for i, line in ipairs(lines) do
    -- Check for dependencies block start
    if line:match("dependencies%s*=%s*{") then
      in_dependencies = true
      brace_depth = 1
      -- Check if there's content on the same line
      local content_after = line:match("dependencies%s*=%s*{(.+)")
      if content_after then
        local name, version = M._parse_dep_string(content_after)
        if name then
          table.insert(deps, {
            name = name,
            current = version or "any",
            line = i,
            dev = false,
          })
        end
      end
    elseif in_dependencies then
      -- Track brace depth
      for _ in line:gmatch("{") do
        brace_depth = brace_depth + 1
      end
      for _ in line:gmatch("}") do
        brace_depth = brace_depth - 1
      end

      if brace_depth <= 0 then
        in_dependencies = false
      else
        -- Parse dependency line: "package >= 1.0" or "package"
        local name, version = M._parse_dep_string(line)
        if name then
          table.insert(deps, {
            name = name,
            current = version or "any",
            line = i,
            dev = false,
          })
        end
      end
    end
  end

  return deps
end

function M._parse_dep_string(line)
  -- Match quoted string: "lpeg >= 1.0.0"
  local dep_str = line:match('"([^"]+)"') or line:match("'([^']+)'")
  if not dep_str then
    return nil, nil
  end

  -- Skip lua version constraint
  if dep_str:match("^lua%s") then
    return nil, nil
  end

  -- Parse: "package >= 1.0" or "package ~> 1.0" or just "package"
  local name, version = dep_str:match("^([%w_%-]+)%s*(.*)$")
  if name then
    -- Clean up version constraint
    if version and version ~= "" then
      version = version:gsub("^[><=~]+%s*", "")
      version = version:gsub("%s+$", "")
    else
      version = "any"
    end
    return name, version
  end

  return nil, nil
end

return M
