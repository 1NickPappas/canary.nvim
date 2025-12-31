# Contributing to canary.nvim

Thanks for your interest in contributing!

## ⇁ Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a branch for your changes

```bash
git clone https://github.com/1NickPappas/canary.nvim.git
cd canary.nvim
git checkout -b feature/your-feature-name
```

## ⇁ Development Setup

Link the plugin locally for testing:

```lua
-- In your Neovim config
{
  dir = "~/path/to/canary.nvim",
  opts = {},
}
```

## ⇁ Project Structure

```
lua/canary/
├── init.lua          -- Main entry point
├── config.lua        -- Configuration handling
├── core.lua          -- Core functionality
├── semver.lua        -- Semver parsing/comparison
├── cache.lua         -- Caching layer
├── parsers/          -- File parsers (one per format)
│   ├── init.lua
│   ├── package_json.lua
│   ├── cargo_toml.lua
│   └── ...
├── sources/          -- Registry API clients
│   ├── init.lua
│   ├── npm.lua
│   ├── cargo.lua
│   └── ...
└── ui/
    ├── virtual_text.lua
    ├── float.lua
    └── highlights.lua
```

## ⇁ Adding a New Package Manager

1. Create a parser in `lua/canary/parsers/your_parser.lua`:

```lua
local M = {}

function M.parse(lines)
  local deps = {}
  -- Parse lines and extract dependencies
  -- Each dep needs: name, version, line (0-indexed)
  return deps
end

return M
```

2. Create a source in `lua/canary/sources/your_source.lua`:

```lua
local M = {}

function M.fetch(name, callback)
  -- Fetch latest version from registry
  -- Call callback(latest_version) or callback(nil) on error
end

return M
```

3. Register in `lua/canary/parsers/init.lua` and `lua/canary/sources/init.lua`

4. Add file detection in `parsers/init.lua` `detect()` function

5. Update documentation in `README.md` and `doc/canary.txt`

## ⇁ Code Style

- Use 2-space indentation
- Keep functions focused and small
- Add comments for non-obvious logic
- Follow existing patterns in the codebase

## ⇁ Submitting Changes

1. Ensure your code follows the existing style
2. Test your changes locally
3. Commit with clear, descriptive messages
4. Push to your fork and open a Pull Request

## ⇁ Reporting Issues

When reporting bugs, please include:
- Neovim version (`:version`)
- Operating system
- Minimal reproduction steps
- Relevant error messages (`:messages`)

## ⇁ Questions?

Feel free to open an issue for questions or discussion.
