local M = {}

function M.parse(content)
  local deps = {}

  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data then
    return deps
  end

  local imports = data.imports
  if not imports then
    return deps
  end

  local lines = vim.split(content, "\n")

  for name, specifier in pairs(imports) do
    local line = M._find_line(lines, name)
    local parsed = M._parse_specifier(specifier)

    if parsed then
      table.insert(deps, {
        name = parsed.package,
        current = parsed.version or "*",
        line = line,
        dev = false,
        -- Store source type for routing to correct registry
        source_type = parsed.source_type,
        scope = parsed.scope,
      })
    end
  end

  return deps
end

function M._parse_specifier(specifier)
  -- JSR format: jsr:@scope/package@^1.0.0
  local scope, pkg, version = specifier:match("^jsr:@([^/]+)/([^@]+)@(.+)$")
  if scope and pkg then
    return {
      source_type = "jsr",
      scope = scope,
      package = pkg,
      version = version,
    }
  end

  -- JSR without version: jsr:@scope/package
  scope, pkg = specifier:match("^jsr:@([^/]+)/([^@]+)$")
  if scope and pkg then
    return {
      source_type = "jsr",
      scope = scope,
      package = pkg,
      version = nil,
    }
  end

  -- npm format: npm:package@^1.0.0
  pkg, version = specifier:match("^npm:([^@]+)@(.+)$")
  if pkg then
    return {
      source_type = "npm",
      package = pkg,
      version = version,
    }
  end

  -- npm without version: npm:package
  pkg = specifier:match("^npm:([^@]+)$")
  if pkg then
    return {
      source_type = "npm",
      package = pkg,
      version = nil,
    }
  end

  -- npm scoped: npm:@scope/package@^1.0.0
  scope, pkg, version = specifier:match("^npm:@([^/]+)/([^@]+)@(.+)$")
  if scope and pkg then
    return {
      source_type = "npm",
      package = "@" .. scope .. "/" .. pkg,
      version = version,
    }
  end

  -- deno.land/x URL: https://deno.land/x/oak@v12.0.0/mod.ts
  pkg, version = specifier:match("deno%.land/x/([^@/]+)@v?([%d%.]+)")
  if pkg and version then
    return {
      source_type = "deno_land",
      package = pkg,
      version = version,
    }
  end

  return nil
end

function M._find_line(lines, name)
  local escaped = name:gsub("([%-%.%/])", "%%%1")
  for i, line in ipairs(lines) do
    if line:match('"' .. escaped .. '"') then
      return i
    end
  end
  return nil
end

return M
