local M = {}

local parsers = {
  npm = require("canary.parsers.package_json"),
  cargo = require("canary.parsers.cargo_toml"),
}

function M.get(filetype)
  return parsers[filetype]
end

function M.detect(filename)
  if filename:match("package%.json$") then
    return "npm"
  end
  if filename:match("Cargo%.toml$") then
    return "cargo"
  end
  return nil
end

function M.supported_files()
  return { "package.json", "Cargo.toml" }
end

return M
