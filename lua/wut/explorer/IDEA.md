Imagine we have a buffer with the following content

```txt
folder_1/
folder_2/
init.lua
readme.md
```

I'll use another block of code below of each folder representation as an example
of what the operations will look like when we progress. So, for this folder, we'll
have a list operations which is empty for now.

Now, I want to do operations in that folder (currently a virtual folder).
The first operation I want to do is renaming `folder_2` to `utils`. I'll do
that using the normal vim commands like putting my cursor in the second line
and doing the `ciw` motion, for example.

```txt
folder_1/
utils/       << renamed
init.lua
readme.md
```

```lua
local operations = {
  [0] = {
    operation = "rename",
    type = "directory",
    old = {
      id = 0, -- original extmark id
      path = "~/Projects/wut/folder_2",
    },
    new = {
      id = 4, -- new extmark id
      path = "~/Projects/wut/utils",
    },
  },
}
```

After this, I'll create some files with the same extensions, to do this in just
a single line, I will use the `{}` to wrap the file names I want following the
extension.

```txt
folder_1/
utils/
init.lua
{functions,helpers}.lua     << new line inserted
readme.md
```

```lua
local operations = {
  [0] = {
    operation = "rename",
    type = "directory",
    old = {
      path = "~/Projects/wut/folder_2",
    },
    new = {
      path = "~/Projects/wut/utils",
    },
  },
  [1] = {
    operation = "create",
    type = "file",
    old = nil,
    new = {
      path = "~/Projects/wut/functions.lua",
    },
  },
  [2] = {
    operation = "create",
    type = "file",
    old = nil,
    new = {
      path = "~/Projects/wut/helpers.lua",
    },
  },
}
```

After the evaluation, this new line will be resolved as `functions.lua` and
`helpers.lua` and will be inserted in the current virtual folder buffer.

At the moment our virtual folder is looking like this:

```txt
folder_1/
utils/
init.lua
functions.lua     << new file
helpers.lua       << new file
readme.lua
```

But, for some reason I've created the wrong files, I don't want the `functions`
and `helpers` file anymore. So, I can just select both of them and `d`.

```txt
folder_1/
utils/
init.lua
readme.lua
```

Now, our operations table will look like it was "traveled back in time" to the first
operation:

```lua
local operations = {
  [0] = {
    operation = "rename",
    type = "directory",
    old = {
      id = 0,
      path = "~/Projects/wut/folder_2",
    },
    new = {
      id = 4,
      path = "~/Projects/wut/utils",
    },
  },
}
```
