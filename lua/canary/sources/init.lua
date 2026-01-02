local M = {}

local pypi = require("canary.sources.pypi")

local sources = {
  npm = require("canary.sources.npm"),
  cargo = require("canary.sources.cargo"),
  pypi = pypi,
  pypi_requirements = pypi, -- reuse PyPI source
  pypi_pipfile = pypi, -- reuse PyPI source
  go = require("canary.sources.goproxy"),
  composer = require("canary.sources.packagist"),
  rubygems = require("canary.sources.rubygems"),
  deno = require("canary.sources.jsr"),
  hex = require("canary.sources.hex"),
  pubdev = require("canary.sources.pubdev"),
  julia = require("canary.sources.juliahub"),
  nuget = require("canary.sources.nuget"),
  maven = require("canary.sources.maven"),
  luarocks = require("canary.sources.luarocks"),
  cpan = require("canary.sources.metacpan"),
  cran = require("canary.sources.cran"),
}

function M.get(filetype)
  return sources[filetype]
end

return M
