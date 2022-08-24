local LinkedList = {}

function LinkedList:new()
  local list = {
    _root = nil,
  }

  return setmetatable(list, {
    __index = self,
  })
end

function LinkedList:append(value)
  if self._root == nil then
    self._root = {
      value = value,
      next = nil,
    }

    return self
  end

  local node = self._root
  while node.next ~= nil do
    node = node.next
  end

  node.next = {
    value = value,
    next = nil,
  }
end

function LinkedList:for_each(fn)
  local node = self._root
  while node ~= nil do
    fn(node.value)
    node = node.next
  end
end

return LinkedList
