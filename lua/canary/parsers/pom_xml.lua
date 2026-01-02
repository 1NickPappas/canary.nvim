local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")

  local in_dependency = false
  local current_group = nil
  local current_artifact = nil
  local current_version = nil
  local dep_start_line = nil

  for i, line in ipairs(lines) do
    -- Start of dependency block
    if line:match("<dependency>") then
      in_dependency = true
      current_group = nil
      current_artifact = nil
      current_version = nil
      dep_start_line = i
    end

    if in_dependency then
      -- Extract groupId
      local group = line:match("<groupId>([^<]+)</groupId>")
      if group then
        current_group = group
      end

      -- Extract artifactId
      local artifact = line:match("<artifactId>([^<]+)</artifactId>")
      if artifact then
        current_artifact = artifact
      end

      -- Extract version (skip variable references like ${...})
      local version = line:match("<version>([^<$]+)</version>")
      if version then
        current_version = version
      end

      -- End of dependency block
      if line:match("</dependency>") then
        in_dependency = false

        if current_group and current_artifact and current_version then
          -- Use groupId:artifactId as the name for Maven lookup
          local name = current_group .. ":" .. current_artifact
          table.insert(deps, {
            name = name,
            display_name = current_artifact, -- Show shorter name in UI
            current = current_version,
            line = dep_start_line,
            dev = false,
          })
        end
      end
    end
  end

  return deps
end

return M
