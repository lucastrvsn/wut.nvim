# wut

Highly opinionated neovim plugins

### Note

Please, **don't use this at the current state**. I'm developing all the plugins and features and none of them are ready to be used.

### Goal

I'm trying to create my ideal neovim experience without using any 3rd-party plugins. All the plugins found in this repository needs to be self-contained and work without any issues.

My ideal goal is to have all the plugins to work independly, but I'm not sure yet if worth the cost of the code duplication.

### Features

- [ ] plugin manager
- [ ] statusline
- [ ] workspace manager
- [ ] file explorer framework
- [ ] git provider
- [ ] ui builder framework
- [ ] completion framework
- [ ] linter and formatter stuff
- [ ] fuzzy finder (dont know yet, fzf?)
- [ ] colorscheme? (base16 based)

## Docs

### statusline

A statusline builder framework without hassle.

Located at `wut/statusline`.

```lua
require("wut/statusline").setup {
  active = function(add)
    add.left(require "wut/statusline/builtin/mode")

    add.left(require "wut/statusline/builtin/diagnostics")

    add.center(require "wut/statusline/builtin/filename")

    add.right {
      render = function()
        return "right"
      end,
    }
  end,
  inactive = function(add)
    add.left {
      render = function()
        return "inactive"
      end,
    }
  end,
}
```

### workspace

Located at `wut/workspace`.

### ui

Located at `wut/ui`.

### color

Located at `wut/color`.

### events

Located at `wut/events`.

### highlight

Located at `wut/highlight`.

### theme

Located at `wut/theme`.

### git

Located at `wut/git`.
