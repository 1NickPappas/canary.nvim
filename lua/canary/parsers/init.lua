local M = {}

local parsers = {
  npm = require("canary.parsers.package_json"),
  cargo = require("canary.parsers.cargo_toml"),
  pypi = require("canary.parsers.pyproject_toml"),
  go = require("canary.parsers.go_mod"),
  composer = require("canary.parsers.composer_json"),
  rubygems = require("canary.parsers.gemfile"),
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
  if filename:match("pyproject%.toml$") then
    return "pypi"
  end
  if filename:match("go%.mod$") then
    return "go"
  end
  if filename:match("composer%.json$") then
    return "composer"
  end
  if filename:match("Gemfile$") then
    return "rubygems"
  end
  return nil
end

function M.supported_files()
  return {
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
    "go.mod",
    "composer.json",
    "Gemfile",
  }
end

return M
