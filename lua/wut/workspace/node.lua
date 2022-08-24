local LinkedList = require "wut/utils/linked_list"

local Node = {}

function Node:new(filename, realpath, type)
  local n = {
    filename = filename,
    realpath = realpath,
    type = type,
    children = LinkedList:new(),
  }

  return setmetatable(n, {
    __index = self,
  })
end

function Node:append(node)
  self.children:append(node)
end

return Node
