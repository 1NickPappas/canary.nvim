local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local in_deps_block = false
  local brace_depth = 0

  for i, line in ipairs(lines) do
    -- Look for deps function start
    if line:match("defp?%s+deps") then
      in_deps_block = true
    end

    if in_deps_block then
      -- Track bracket depth to know when we exit the deps block
      for _ in line:gmatch("%[") do
        brace_depth = brace_depth + 1
      end
      for _ in line:gmatch("%]") do
        brace_depth = brace_depth - 1
      end

      -- Check for end of function
      if line:match("^%s*end%s*$") and brace_depth <= 0 then
        in_deps_block = false
        brace_depth = 0
      end

      -- Parse dependency line: {:package, "~> 1.0"} or {:package, "~> 1.0", only: :dev}
      local name, version = M._parse_dependency_line(line)
      if name then
        local is_dev = line:match("only:%s*:dev") ~= nil
          or line:match("only:%s*:test") ~= nil
          or line:match('only:%s*%[.-:dev') ~= nil
          or line:match('only:%s*%[.-:test') ~= nil

        table.insert(deps, {
          name = name,
          current = version,
          line = i,
          dev = is_dev,
        })
      end
    end
  end

  return deps
end

function M._parse_dependency_line(line)
  -- Format: {:package, "~> 1.0"} or {:package, "~> 1.0", ...}
  local name, version = line:match('{:([%w_]+),%s*"([^"]+)"')
  if name and version then
    return name, version
  end

  -- Format with >= or other operators
  name, version = line:match("{:([%w_]+),%s*\"([><=~%d%.]+)\"")
  if name and version then
    return name, version
  end

  return nil, nil
end

return M
