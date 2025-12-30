local M = {}

function M.parse(version_str)
  if not version_str or version_str == "" then
    return nil
  end

  local clean = version_str:gsub("^[%^~>=<]+", "")
  local major, minor, patch, prerelease = clean:match("^(%d+)%.?(%d*)%.?(%d*)%-?(.*)")

  if not major then
    return nil
  end

  return {
    major = tonumber(major) or 0,
    minor = tonumber(minor) or 0,
    patch = tonumber(patch) or 0,
    prerelease = prerelease ~= "" and prerelease or nil,
    original = version_str,
  }
end

function M.compare(v1, v2)
  local a, b = M.parse(v1), M.parse(v2)
  if not a or not b then
    return 0
  end

  if a.major ~= b.major then
    return a.major < b.major and -1 or 1
  end
  if a.minor ~= b.minor then
    return a.minor < b.minor and -1 or 1
  end
  if a.patch ~= b.patch then
    return a.patch < b.patch and -1 or 1
  end

  if a.prerelease and not b.prerelease then
    return -1
  end
  if not a.prerelease and b.prerelease then
    return 1
  end

  return 0
end

function M.compare_status(current, latest)
  local c, l = M.parse(current), M.parse(latest)

  if not c or not l then
    return "invalid"
  end

  if M.compare(current, latest) >= 0 then
    return "up_to_date"
  end

  if l.major > c.major then
    return "major"
  end
  if l.minor > c.minor then
    return "minor"
  end
  if l.patch > c.patch then
    return "patch"
  end

  return "up_to_date"
end

function M.satisfies(version, constraint)
  local prefix = constraint:match("^([%^~>=<]+)")
  local target = M.parse(constraint)
  local v = M.parse(version)

  if not target or not v then
    return false
  end

  if prefix == "^" then
    if target.major == 0 then
      return v.major == 0 and v.minor == target.minor
    end
    return v.major == target.major
  elseif prefix == "~" then
    return v.major == target.major and v.minor == target.minor
  elseif prefix == ">=" then
    return M.compare(version, constraint) >= 0
  elseif prefix == ">" then
    return M.compare(version, constraint) > 0
  elseif prefix == "<=" then
    return M.compare(version, constraint) <= 0
  elseif prefix == "<" then
    return M.compare(version, constraint) < 0
  end

  return M.compare(version, constraint) == 0
end

return M
