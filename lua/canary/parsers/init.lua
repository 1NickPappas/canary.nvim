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
  pubdev = require("canary.parsers.pubspec_yaml"),
  julia = require("canary.parsers.project_toml"),
  nuget = require("canary.parsers.csproj"),
  nuget_central = require("canary.parsers.directory_packages"),
  maven = require("canary.parsers.pom_xml"),
  gradle = require("canary.parsers.build_gradle"),
  gradle_kts = require("canary.parsers.build_gradle_kts"),
  gradle_catalog = require("canary.parsers.libs_versions_toml"),
  luarocks = require("canary.parsers.rockspec"),
  cpan = require("canary.parsers.cpanfile"),
  cran = require("canary.parsers.description"),
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
  if filename:match("pubspec%.yaml$") then
    return "pubdev"
  end
  if filename:match("Project%.toml$") then
    return "julia"
  end
  if filename:match("%.csproj$") then
    return "nuget"
  end
  if filename:match("Directory%.Packages%.props$") then
    return "nuget_central"
  end
  if filename:match("pom%.xml$") then
    return "maven"
  end
  if filename:match("build%.gradle%.kts$") then
    return "gradle_kts"
  end
  if filename:match("build%.gradle$") then
    return "gradle"
  end
  if filename:match("libs%.versions%.toml$") then
    return "gradle_catalog"
  end
  if filename:match("%.rockspec$") then
    return "luarocks"
  end
  if filename:match("cpanfile$") then
    return "cpan"
  end
  if filename:match("DESCRIPTION$") then
    return "cran"
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
    "pubspec.yaml",
    "Project.toml",
    "*.csproj",
    "Directory.Packages.props",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "libs.versions.toml",
    "*.rockspec",
    "cpanfile",
    "DESCRIPTION",
  }
end

return M
