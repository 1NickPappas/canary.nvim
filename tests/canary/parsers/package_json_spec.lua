local parser = require("canary.parsers.package_json")

describe("package_json parser", function()
  local fixture_content

  before_each(function()
    local fixture_path = "tests/fixtures/package.json"
    local file = io.open(fixture_path, "r")
    fixture_content = file:read("*a")
    file:close()
  end)

  describe("parse", function()
    it("parses dependencies", function()
      local deps = parser.parse(fixture_content)

      local lodash = vim.tbl_filter(function(d)
        return d.name == "lodash"
      end, deps)[1]

      assert.is_not_nil(lodash)
      assert.equals("^4.17.21", lodash.current)
      assert.is_false(lodash.dev)
    end)

    it("parses devDependencies", function()
      local deps = parser.parse(fixture_content)

      local typescript = vim.tbl_filter(function(d)
        return d.name == "typescript"
      end, deps)[1]

      assert.is_not_nil(typescript)
      assert.equals("^5.0.0", typescript.current)
      assert.is_true(typescript.dev)
    end)

    it("tracks line numbers", function()
      local deps = parser.parse(fixture_content)

      local lodash = vim.tbl_filter(function(d)
        return d.name == "lodash"
      end, deps)[1]

      assert.is_not_nil(lodash.line)
      assert.is_true(lodash.line > 0)
    end)

    it("handles scoped packages", function()
      local deps = parser.parse(fixture_content)

      local scoped = vim.tbl_filter(function(d)
        return d.name == "@scope/package"
      end, deps)[1]

      assert.is_not_nil(scoped)
      assert.equals("1.0.0", scoped.current)
    end)

    it("returns empty table for invalid JSON", function()
      local deps = parser.parse("not valid json")
      assert.equals(0, #deps)
    end)

    it("returns empty table for empty content", function()
      local deps = parser.parse("")
      assert.equals(0, #deps)
    end)

    it("handles package.json without dependencies", function()
      local deps = parser.parse('{"name": "test", "version": "1.0.0"}')
      assert.equals(0, #deps)
    end)

    it("parses all dependencies from fixture", function()
      local deps = parser.parse(fixture_content)
      assert.equals(5, #deps)
    end)
  end)
end)
