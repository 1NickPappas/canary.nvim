local M = {}

local parsers = {
  npm = require("canary.parsers.package_json"),
  cargo = require("canary.parsers.cargo_toml"),
  pypi = require("canary.parsers.pyproject_toml"),
  pypi_requirements = require("canary.parsers.requirements_txt"),
  pypi_pipfile = require("canary.parsers.pipfile"),
  go = require("canary.parsers.go_mod"),
  composer = require("canary.parsers.composer_json"),
  rubygems = require("canary.parsers.gemfile"),
  deno = require("canary.parsers.deno_json"),
  hex = require("canary.parsers.mix_exs"),
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
  if filename:match("requirements%.txt$") then
    return "pypi_requirements"
  end
  if filename:match("Pipfile$") then
    return "pypi_pipfile"
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
  if filename:match("deno%.json$") then
    return "deno"
  end
  if filename:match("mix%.exs$") then
    return "hex"
  end
  return nil
end

function M.supported_files()
  return {
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
    "requirements.txt",
    "Pipfile",
    "go.mod",
    "composer.json",
    "Gemfile",
    "deno.json",
    "mix.exs",
  }
end

return M
