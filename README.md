<div align="center">

# canary.nvim
##### Inline dependency version checker for Neovim

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.10+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

<img alt="canary.nvim" height="200" src="/assets/canary_logo.png" />
</div>

## ⇁ TOC
* [Features](#-features)
* [Supported Package Managers](#-supported-package-managers)
* [Installation](#-installation)
* [Configuration](#-configuration)
* [Commands](#-commands)
* [Keymaps](#-keymaps)
* [API](#-api)
* [Highlight Groups](#-highlight-groups)
* [License](#-license)

## ⇁ Features
- Inline virtual text showing version status
- Color-coded by severity (up-to-date, patch, minor, major updates)
- Works with any colorscheme
- Caching to minimize API calls
- Async HTTP requests
- Update dependencies directly from Neovim

## ⇁ Supported Package Managers

| Language | File | Registry |
|----------|------|----------|
| JavaScript/TypeScript | `package.json` | npm |
| JavaScript (Deno) | `deno.json` | JSR / npm |
| Rust | `Cargo.toml` | crates.io |
| Python | `pyproject.toml` | PyPI |
| Python | `requirements.txt` | PyPI |
| Python | `Pipfile` | PyPI |
| Go | `go.mod` | proxy.golang.org |
| PHP | `composer.json` | Packagist |
| Ruby | `Gemfile` | RubyGems |
| Elixir | `mix.exs` | Hex |

> **Note:** Bun uses `package.json`, so it works automatically with npm support.

## ⇁ Installation
* Neovim 0.10+ required
* curl required for fetching version information

### lazy.nvim
```lua
{
  "1NickPappas/canary.nvim",
  event = {
    "BufReadPost package.json",
    "BufReadPost Cargo.toml",
    "BufReadPost pyproject.toml",
    "BufReadPost requirements.txt",
    "BufReadPost Pipfile",
    "BufReadPost go.mod",
    "BufReadPost composer.json",
    "BufReadPost Gemfile",
    "BufReadPost deno.json",
    "BufReadPost mix.exs",
  },
  opts = {},
}
```

### packer.nvim
```lua
use {
  "1NickPappas/canary.nvim",
  config = function()
    require("canary").setup()
  end
}
```

## ⇁ Configuration

```lua
require("canary").setup({
  autostart = true,        -- Auto-check on file open
  hide_up_to_date = false, -- Hide up-to-date dependencies

  icon_style = "auto",     -- "auto", "nerd", "unicode", "ascii"
  display_format = "full", -- "icon_only", "version_only", "full"

  keymaps = {
    show = "<leader>cs",
    hide = "<leader>ch",
    toggle = "<leader>ct",
    check = "<leader>cc",
    details = "K",
    filter = "<leader>cf",
    update = "<leader>cu",
    update_line = "<leader>cU",
  },

  cache = {
    enabled = true,
    ttl = 3600,  -- 1 hour
  },
})
```

## ⇁ Commands

| Command | Description |
|---------|-------------|
| `:CanaryCheck` | Check dependency versions |
| `:CanaryShow` | Show version hints |
| `:CanaryHide` | Hide version hints |
| `:CanaryToggle` | Toggle version hints |
| `:CanaryRefresh` | Force refresh (bypass cache) |
| `:CanaryFilter` | Toggle hiding up-to-date dependencies |
| `:CanaryUpdate` | Update all outdated dependencies |
| `:CanaryUpdateLine` | Update dependency at cursor |

## ⇁ Keymaps

| Key | Action |
|-----|--------|
| `<leader>cs` | Show hints |
| `<leader>ch` | Hide hints |
| `<leader>ct` | Toggle hints |
| `<leader>cc` | Check versions |
| `<leader>cf` | Toggle filter (hide up-to-date) |
| `<leader>cu` | Update all outdated |
| `<leader>cU` | Update dependency at cursor |
| `K` | Show details popup |

## ⇁ API

```lua
local canary = require("canary")

canary.setup(opts)      -- Initialize with config
canary.check()          -- Check current buffer
canary.show()           -- Show hints
canary.hide()           -- Hide hints
canary.toggle()         -- Toggle visibility
canary.refresh()        -- Force refresh
canary.show_details()   -- Show detail popup
canary.toggle_filter()  -- Toggle hide up-to-date
canary.update_all()     -- Update all outdated deps
canary.update_line()    -- Update dep at cursor
```

## ⇁ Highlight Groups

| Group | Default | Description |
|-------|---------|-------------|
| `CanaryUpToDate` | DiagnosticHint | Up-to-date dependencies |
| `CanaryPatch` | DiagnosticInfo | Patch updates available |
| `CanaryMinor` | DiagnosticWarn | Minor updates available |
| `CanaryMajor` | DiagnosticError | Major (breaking) updates |

Override highlights:

```lua
require("canary").setup({
  highlights = {
    CanaryMajor = { link = "ErrorMsg" },
  },
})
```

## ⇁ License

MIT
