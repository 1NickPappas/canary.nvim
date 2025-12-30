local cache = require("canary.cache")
local config = require("canary.config")

describe("cache", function()
  local test_cache_dir

  before_each(function()
    test_cache_dir = vim.fn.tempname() .. "_canary_test"
    config.setup({
      cache = {
        enabled = true,
        ttl = 3600,
        path = test_cache_dir,
      },
    })
  end)

  after_each(function()
    cache.invalidate_all()
    vim.fn.delete(test_cache_dir, "rf")
  end)

  describe("set and get", function()
    it("stores and retrieves data", function()
      local data = { latest = "1.2.3", fetched = os.time() }
      cache.set("lodash", "npm", data)

      local result = cache.get("lodash", "npm")
      assert.is_not_nil(result)
      assert.equals("1.2.3", result.latest)
    end)

    it("returns nil for missing keys", function()
      local result = cache.get("nonexistent", "npm")
      assert.is_nil(result)
    end)

    it("handles scoped packages", function()
      local data = { latest = "2.0.0" }
      cache.set("@scope/package", "npm", data)

      local result = cache.get("@scope/package", "npm")
      assert.is_not_nil(result)
      assert.equals("2.0.0", result.latest)
    end)

    it("separates sources", function()
      cache.set("serde", "cargo", { latest = "1.0.0" })
      cache.set("serde", "npm", { latest = "2.0.0" })

      local cargo_result = cache.get("serde", "cargo")
      local npm_result = cache.get("serde", "npm")

      assert.equals("1.0.0", cargo_result.latest)
      assert.equals("2.0.0", npm_result.latest)
    end)
  end)

  describe("TTL expiration", function()
    it("respects TTL setting", function()
      config.setup({
        cache = {
          enabled = true,
          ttl = 3600,
          path = test_cache_dir,
        },
      })

      cache.set("lodash", "npm", { latest = "1.0.0" })
      local result = cache.get("lodash", "npm")
      assert.is_not_nil(result)
      assert.equals("1.0.0", result.latest)
    end)
  end)

  describe("invalidate", function()
    it("removes specific cache entry", function()
      cache.set("lodash", "npm", { latest = "1.0.0" })
      cache.set("express", "npm", { latest = "2.0.0" })

      cache.invalidate("lodash", "npm")

      assert.is_nil(cache.get("lodash", "npm"))
      assert.is_not_nil(cache.get("express", "npm"))
    end)
  end)

  describe("invalidate_all", function()
    it("clears all cache entries", function()
      cache.set("lodash", "npm", { latest = "1.0.0" })
      cache.set("serde", "cargo", { latest = "2.0.0" })

      cache.invalidate_all()

      assert.is_nil(cache.get("lodash", "npm"))
      assert.is_nil(cache.get("serde", "cargo"))
    end)
  end)

  describe("when cache disabled", function()
    it("get returns nil", function()
      config.setup({
        cache = {
          enabled = false,
          ttl = 3600,
          path = test_cache_dir,
        },
      })

      cache.set("lodash", "npm", { latest = "1.0.0" })
      local result = cache.get("lodash", "npm")
      assert.is_nil(result)
    end)
  end)
end)
