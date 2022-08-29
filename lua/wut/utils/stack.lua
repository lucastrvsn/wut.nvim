local Stack = {}

function Stack:new()
  local stack = {
    _nodes = {},
  }

  return setmetatable(stack, {
    __index = self,
  })
end

function Stack:push(item)
  table.insert(self._nodes, item)
end

function Stack:pop()
  return table.remove(self._nodes)
end

function Stack:is_empty()
  return #self._nodes == 0
end

function Stack:length()
  return #self._nodes
end

return Stack
