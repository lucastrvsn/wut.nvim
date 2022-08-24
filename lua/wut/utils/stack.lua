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
  return self
end

function Stack:pop()
  return table.remove(self._nodes), self
end

function Stack:is_empty()
  return #self._nodes == 0, self
end

function Stack:length()
  return #self._nodes, self
end

return Stack
