local M = {
  _coroutine = nil,
}

local r = function(a)
  while true do
    print(a)
    coroutine.yield(M._coroutine)
  end
end

M.run = function(fn)
  M._coroutine = coroutine.create(r)

  -- local ok, data = coroutine.resume(M._coroutine, {})
  if ok then
    print "ok"
  end
end

return M
