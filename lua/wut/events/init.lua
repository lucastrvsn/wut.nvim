local M = {
  _listeners = {},
}

M.notify = function(event, payload)
  for _, cb in ipairs(M._listeners[event]) do
    cb(payload)
  end
end

M.subscribe = function(event, callback)
  local listener = M._listeners[event]

  if listener ~= nil then
    table.insert(listener, callback)
    return true
  end

  M._listeners[event] = {}
  table.insert(M._listeners[event], callback)
  return true
end

return M
