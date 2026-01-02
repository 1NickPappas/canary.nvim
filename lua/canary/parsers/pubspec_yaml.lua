local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  local current_section = nil
  local in_dependency_block = false

  for i, line in ipairs(lines) do
    -- Check for section headers
    if line:match("^dependencies:%s*$") then
      current_section = "dependencies"
      in_dependency_block = true
    elseif line:match("^dev_dependencies:%s*$") then
      current_section = "dev_dependencies"
      in_dependency_block = true
    elseif line:match("^%S") and not line:match("^#") then
      -- New top-level key, exit dependency section
      if in_dependency_block then
        current_section = nil
        in_dependency_block = false
      end
    elseif in_dependency_block and current_section then
      -- Parse dependency line: "  package_name: ^1.0.0" or "  package_name: '>=1.0.0 <2.0.0'"
      local name, version = line:match("^%s+([%w_]+):%s*[\"']?([^\"'#]+)[\"']?%s*$")

      -- Also match caret syntax without quotes
      if not name then
        name, version = line:match("^%s+([%w_]+):%s*(%^?[%d%.]+)%s*$")
      end

      -- Match hosted/git dependencies (just extract the name, skip version)
      if not name then
        name = line:match("^%s+([%w_]+):%s*$")
        if name then
          -- This is a complex dependency (hosted, git, path) - skip for now
          name = nil
        end
      end

      if name and version and version ~= "" then
        -- Clean up version string
        version = version:gsub("%s+$", "")

        table.insert(deps, {
          name = name,
          current = version,
          line = i,
          dev = current_section == "dev_dependencies",
        })
      end
    end
  end

  return deps
end

return M
