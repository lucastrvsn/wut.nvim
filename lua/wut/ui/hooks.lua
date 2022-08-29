local M = {
  _current_index = 1,
  _current_hook = {},
}

M.get_index = function()
  return M._current_index
end

M.get_value = function(index, should_call_next)
  should_call_next = should_call_next or false

  if should_call_next then
    local temp = M._current_hook[index]

    M.next()

    return temp
  end

  return M._current_hook[index]
end

M.set = function(index, value)
  M._current_hook[index] = value
end

M.next = function()
  M._current_index = M._current_index + 1
end

M.reset = function()
  M._current_index = 1
end

return M
