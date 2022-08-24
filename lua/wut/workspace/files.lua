local fs = require "wut/utils/fs"
local path = require "wut/utils/path"
local Stack = require "wut/utils/stack"
local Node = require "wut/workspace/node"

local Files = {}

local dfs = function(opts)
  local cwd = opts.cwd
  local ignore_patterns = opts.ignore_patterns or nil

  local stack = Stack:new()
  local root_node = Node:new(cwd, cwd, "directory")
  stack:push(root_node)

  while not stack:is_empty() do
    local current_node = stack:pop()
    local files = fs.readdir(current_node.realpath)

    for _, file in ipairs(files) do
      local filename = file[1]

      if ignore_patterns and ignore_patterns[filename] then
        goto continue
      end

      local realpath = path.join(current_node.realpath, filename)
      local type = file[2]
      local new_node = Node:new(filename, realpath, type)

      if type == "directory" then
        stack:push(new_node)
      end

      current_node:append(new_node)

      ::continue::
    end
  end

  return root_node
end

function Files:new(opts)
  local files = {
    _root = nil,
  }

  files._root = dfs(opts)

  return setmetatable(files, {
    __index = self,
  })
end

function Files:iterate(from)
  local root = from or self._root
  local stack = Stack:new():push(root)

  local iterator = function()
    if not stack:is_empty() then
      local node = stack:pop()
      local files = {}

      node.children:for_each(function(n)
        if n.type == "directory" then
          stack:push(n)
        end

        table.insert(files, n)
      end)

      return files
    end

    return nil
  end

  return iterator
end

return Files
