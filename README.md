# canary.nvim

Inline dependency version checker for Neovim. Shows version status directly in your package manifests.

## Features

- Inline virtual text showing version status
- Color-coded by severity (up-to-date, minor, major updates)
- Works with any colorscheme
- Caching to minimize API calls
- Async HTTP requests

## Supported Package Managers

- **npm** - package.json
- **Cargo** - Cargo.toml

## Requirements

- Neovim 0.10+
- curl

## Installation

### lazy.nvim

```lua
{
  "username/canary.nvim",
  event = { "BufReadPost package.json", "BufReadPost Cargo.toml" },
  opts = {},
}
```

### packer.nvim

```lua
use {
  "username/canary.nvim",
  config = function()
    require("canary").setup()
  end
}
```

## Configuration

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
  },

  cache = {
    enabled = true,
    ttl = 3600,  -- 1 hour
  },
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:CanaryCheck` | Check dependency versions |
| `:CanaryShow` | Show version hints |
| `:CanaryHide` | Hide version hints |
| `:CanaryToggle` | Toggle version hints |
| `:CanaryRefresh` | Force refresh (bypass cache) |
| `:CanaryFilter` | Toggle hiding up-to-date dependencies |
| `:CanaryUpdate` | Update all outdated dependencies |

## Keymaps

| Key | Action |
|-----|--------|
| `<leader>cs` | Show hints |
| `<leader>ch` | Hide hints |
| `<leader>ct` | Toggle hints |
| `<leader>cc` | Check versions |
| `<leader>cf` | Toggle filter (hide up-to-date) |
| `<leader>cu` | Update all outdated |
| `K` | Show details popup |

## Highlight Groups

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

## API

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
```

## License

MIT
