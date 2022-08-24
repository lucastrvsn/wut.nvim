-- Simple testing framework

local M = {}

M.describe = function(fn)
  fn()
end

M.expect = function(actual)
  assert(type(actual) ~= "nil")

  local expectation = nil
  if type(actual) == "function" then
    expectation = actual()
  else
    expectation = actual
  end

  return {
    to_be = function(value)
      return expectation == value
    end,
  }
end

return M
