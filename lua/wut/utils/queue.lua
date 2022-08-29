local Queue = {}

function Queue:new()
  local stack = {
    _nodes = {},
  }

  return setmetatable(stack, {
    __index = self,
  })
end

function Queue:add(item)
  table.insert(self._nodes, item)
end

function Queue:remove()
  return table.remove(self._nodes, 1)
end

function Queue:is_empty()
  return #self._nodes == 0
end

function Queue:length()
  return #self._nodes
end

return Queue
