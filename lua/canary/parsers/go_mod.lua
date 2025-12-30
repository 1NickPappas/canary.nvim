local M = {}

function M.parse(content)
  local deps = {}
  local lines = vim.split(content, "\n")
  local in_require_block = false

  for i, line in ipairs(lines) do
    -- Single require line: require github.com/pkg/errors v0.9.1
    local single_mod, single_ver = line:match("^require%s+(%S+)%s+(v[%d%.]+)")
    if single_mod and single_ver then
      table.insert(deps, {
        name = single_mod,
        current = single_ver,
        line = i,
        dev = false,
      })
    end

    -- Start of require block
    if line:match("^require%s*%(") then
      in_require_block = true
    elseif in_require_block then
      -- End of block
      if line:match("^%)") then
        in_require_block = false
      else
        -- Parse module line: github.com/user/repo v1.0.0
        local module, version = line:match("^%s*(%S+)%s+(v[%d%.]+)")
        if module and version then
          -- Skip indirect dependencies
          local is_indirect = line:match("// indirect")
          if not is_indirect then
            table.insert(deps, {
              name = module,
              current = version,
              line = i,
              dev = false,
            })
          end
        end
      end
    end
  end

  return deps
end

return M
