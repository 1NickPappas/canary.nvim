package = "example"
version = "1.0-1"

source = {
  url = "git://github.com/example/example.git",
  tag = "v1.0"
}

description = {
  summary = "An example LuaRocks package",
  detailed = "This is an example rockspec file for testing.",
  homepage = "https://github.com/example/example",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1, < 5.5",
  "lpeg >= 1.0.0",
  "luafilesystem >= 1.8.0",
  "penlight >= 1.13.0",
  "luasocket >= 3.0",
}

build = {
  type = "builtin",
  modules = {
    example = "src/example.lua"
  }
}
