--[[
Copyright (c) 2022 Lucas Trevisan (lucastrvsn@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

---@module "wut.utils.linked_list"

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
