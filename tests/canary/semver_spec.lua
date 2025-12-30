local semver = require("canary.semver")

describe("semver", function()
  describe("parse", function()
    it("parses standard versions", function()
      local v = semver.parse("1.2.3")
      assert.equals(1, v.major)
      assert.equals(2, v.minor)
      assert.equals(3, v.patch)
      assert.is_nil(v.prerelease)
    end)

    it("parses versions without patch", function()
      local v = semver.parse("1.2")
      assert.equals(1, v.major)
      assert.equals(2, v.minor)
      assert.equals(0, v.patch)
    end)

    it("parses major-only versions", function()
      local v = semver.parse("1")
      assert.equals(1, v.major)
      assert.equals(0, v.minor)
      assert.equals(0, v.patch)
    end)

    it("strips caret prefix", function()
      local v = semver.parse("^1.2.3")
      assert.equals(1, v.major)
      assert.equals(2, v.minor)
      assert.equals(3, v.patch)
    end)

    it("strips tilde prefix", function()
      local v = semver.parse("~1.2.3")
      assert.equals(1, v.major)
    end)

    it("strips >= prefix", function()
      local v = semver.parse(">=1.2.3")
      assert.equals(1, v.major)
    end)

    it("parses prerelease versions", function()
      local v = semver.parse("1.0.0-alpha")
      assert.equals(1, v.major)
      assert.equals("alpha", v.prerelease)
    end)

    it("returns nil for empty string", function()
      assert.is_nil(semver.parse(""))
    end)

    it("returns nil for nil input", function()
      assert.is_nil(semver.parse(nil))
    end)

    it("returns nil for invalid input", function()
      assert.is_nil(semver.parse("not-a-version"))
    end)
  end)

  describe("compare", function()
    it("returns 0 for equal versions", function()
      assert.equals(0, semver.compare("1.2.3", "1.2.3"))
    end)

    it("returns -1 when first is less (major)", function()
      assert.equals(-1, semver.compare("1.0.0", "2.0.0"))
    end)

    it("returns 1 when first is greater (major)", function()
      assert.equals(1, semver.compare("2.0.0", "1.0.0"))
    end)

    it("returns -1 when first is less (minor)", function()
      assert.equals(-1, semver.compare("1.1.0", "1.2.0"))
    end)

    it("returns 1 when first is greater (minor)", function()
      assert.equals(1, semver.compare("1.2.0", "1.1.0"))
    end)

    it("returns -1 when first is less (patch)", function()
      assert.equals(-1, semver.compare("1.0.1", "1.0.2"))
    end)

    it("returns 1 when first is greater (patch)", function()
      assert.equals(1, semver.compare("1.0.2", "1.0.1"))
    end)

    it("prerelease is less than release", function()
      assert.equals(-1, semver.compare("1.0.0-alpha", "1.0.0"))
    end)

    it("handles prefixed versions", function()
      assert.equals(0, semver.compare("^1.2.3", "1.2.3"))
    end)
  end)

  describe("compare_status", function()
    it("returns up_to_date for equal versions", function()
      assert.equals("up_to_date", semver.compare_status("1.2.3", "1.2.3"))
    end)

    it("returns up_to_date when current is newer", function()
      assert.equals("up_to_date", semver.compare_status("2.0.0", "1.0.0"))
    end)

    it("returns major for major version update", function()
      assert.equals("major", semver.compare_status("1.0.0", "2.0.0"))
    end)

    it("returns minor for minor version update", function()
      assert.equals("minor", semver.compare_status("1.0.0", "1.1.0"))
    end)

    it("returns patch for patch version update", function()
      assert.equals("patch", semver.compare_status("1.0.0", "1.0.1"))
    end)

    it("returns invalid for nil current", function()
      assert.equals("invalid", semver.compare_status(nil, "1.0.0"))
    end)

    it("returns invalid for nil latest", function()
      assert.equals("invalid", semver.compare_status("1.0.0", nil))
    end)

    it("handles prefixed versions", function()
      assert.equals("minor", semver.compare_status("^1.0.0", "1.1.0"))
    end)
  end)

  describe("satisfies", function()
    it("matches exact version", function()
      assert.is_true(semver.satisfies("1.2.3", "1.2.3"))
    end)

    it("caret allows patch updates", function()
      assert.is_true(semver.satisfies("1.2.4", "^1.2.3"))
    end)

    it("caret allows minor updates", function()
      assert.is_true(semver.satisfies("1.3.0", "^1.2.3"))
    end)

    it("caret blocks major updates", function()
      assert.is_false(semver.satisfies("2.0.0", "^1.2.3"))
    end)

    it("caret on 0.x locks minor", function()
      assert.is_true(semver.satisfies("0.2.5", "^0.2.3"))
      assert.is_false(semver.satisfies("0.3.0", "^0.2.3"))
    end)

    it("tilde allows patch updates only", function()
      assert.is_true(semver.satisfies("1.2.4", "~1.2.3"))
      assert.is_false(semver.satisfies("1.3.0", "~1.2.3"))
    end)

    it(">= works correctly", function()
      assert.is_true(semver.satisfies("1.2.3", ">=1.2.3"))
      assert.is_true(semver.satisfies("2.0.0", ">=1.2.3"))
      assert.is_false(semver.satisfies("1.2.2", ">=1.2.3"))
    end)
  end)
end)
