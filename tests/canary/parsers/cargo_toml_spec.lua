describe("cargo_toml parser", function()
  local fixture_content
  local parser

  before_each(function()
    package.loaded["canary.parsers.cargo_toml"] = nil
    if vim.loader then
      vim.loader.reset("canary.parsers.cargo_toml")
    end
    parser = require("canary.parsers.cargo_toml")

    local fixture_path = "tests/fixtures/Cargo.toml"
    local file = io.open(fixture_path, "r")
    fixture_content = file:read("*a")
    file:close()
  end)

  describe("parse", function()
    it("parses simple dependencies", function()
      local deps = parser.parse(fixture_content)

      local serde = vim.tbl_filter(function(d)
        return d.name == "serde"
      end, deps)[1]

      assert.is_not_nil(serde)
      assert.equals("1.0", serde.current)
      assert.is_false(serde.dev)
    end)

    it("parses inline table syntax", function()
      local deps = parser.parse(fixture_content)

      local tokio = vim.tbl_filter(function(d)
        return d.name == "tokio"
      end, deps)[1]

      assert.is_not_nil(tokio)
      assert.equals("1.0", tokio.current)
    end)

    it("parses dev-dependencies", function()
      local deps = parser.parse(fixture_content)

      local criterion = vim.tbl_filter(function(d)
        return d.name == "criterion"
      end, deps)[1]

      assert.is_not_nil(criterion)
      assert.equals("0.5", criterion.current)
      assert.is_true(criterion.dev)
    end)

    it("tracks line numbers", function()
      local deps = parser.parse(fixture_content)

      local serde = vim.tbl_filter(function(d)
        return d.name == "serde"
      end, deps)[1]

      assert.is_not_nil(serde.line)
      assert.is_true(serde.line > 0)
    end)

    it("returns empty table for empty content", function()
      local deps = parser.parse("")
      assert.equals(0, #deps)
    end)

    it("handles Cargo.toml without dependencies", function()
      local content = [[
[package]
name = "test"
version = "0.1.0"
]]
      local deps = parser.parse(content)
      assert.equals(0, #deps)
    end)

    it("parses all dependencies from fixture", function()
      local deps = parser.parse(fixture_content)
      assert.equals(4, #deps)
    end)
  end)

  describe("_parse_dependency_line", function()
    it("parses simple format", function()
      local name, version = parser._parse_dependency_line('serde = "1.0"')
      assert.equals("serde", name)
      assert.equals("1.0", version)
    end)

    it("parses inline table format", function()
      local name, version = parser._parse_dependency_line('tokio = { version = "1.0", features = ["full"] }')
      assert.equals("tokio", name)
      assert.equals("1.0", version)
    end)

    it("returns nil for non-dependency lines", function()
      local name, version = parser._parse_dependency_line("# comment")
      assert.is_nil(name)
      assert.is_nil(version)
    end)

    it("handles underscores in crate names", function()
      local name, version = parser._parse_dependency_line('some_crate = "1.0"')
      assert.equals("some_crate", name)
      assert.equals("1.0", version)
    end)
  end)
end)
