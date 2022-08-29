# wut

Highly opinionated neovim plugins

### Note

Please, **don't use this at the current state**. I'm developing all the plugins and features and none of them are ready to be used.

### Goal

I'm trying to create my ideal neovim experience without using any 3rd-party plugins. All the plugins found in this repository needs to be self-contained and work without any issues.

My ideal goal is to have all the plugins to work independly, but I'm not sure yet if worth the cost of the code duplication.

### Planned features

- [x] main scheduler
- [x] statusline
- [ ] workspace manager
- [ ] file explorer framework
- [ ] git provider
- [ ] ui builder framework
- [ ] completion framework
- [ ] linter and formatter stuff
- [ ] fuzzy finder (dont know yet, fzf?)
- [ ] colorscheme? (base16 based)
- [ ] plugin manager

## Docs

### core

The main module of `wut`. The core module exposes the scheduler used for all other
modules inside `wut`. You can attach any lua function to the scheduler if you want to,
but is recommended that you use the `Promise` module instead to run async operations.

```lua
local core = require("wut/core")

-- Init the core timer. This timer will be run every loop asyncronisoly passing
-- the tick to the scheduler. This way the scheduler will loop through all "ready"
-- threads and let them execute one more time until finishes. All threads created
-- by the scheduler is a new lua native coroutine.
core.init()

-- Use the scheduler to spawn a new function to be processed. You can pass a thread
-- created by `courotine.create(fn)` as well.
core.scheduler:spawn {
  fn = function()
    -- ...some operation
  end,
  priority = 10,
}
```

Located at `lua/wut/core`.

### core.promise

An implementation of `Promise` based of the Javascript promise object. The new
promise created will be executed inside the `core.scheduler` until it resolves
or reject.

The promise life cycle:

1. when created, "pending"
2. until it is being executed, "pending"
3. if resolves, "resolved"
4. if rejects, "rejected"
5. done.

```lua
local Promise = require("wut/core/promise")

local my_number = 10

Promise:new(function(resolve, reject)
  if type(my_number) ~= "number" then
    reject("Not a number")
  else
    resolve(my_number > 20)
  end
end):next(function(result)
  vim.pretty_print("The result is: " .. result)
end):catch(function(err)
  vim.pretty_print("Error occoured: " .. err)
end):start()
```

Located at `lua/wut/core/promise`.

### statusline

A statusline builder framework without hassle.

Located at `lua/wut/statusline`.

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
