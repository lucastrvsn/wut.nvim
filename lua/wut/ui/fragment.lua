local events = require "wut/events"
local EventTypes = require "wut/events/types"

local Fragment = {}

function Fragment:new(opts)
  local fragment = {
    ___type = "UIFragment",
    ___state = nil,
    ___events = nil,
    ___render = nil,
    ___on_update = nil,
  }

  if type(opts.state) == "table" then
    fragment.___state = opts.state
  end

  if type(opts.render) == "function" then
    fragment.___render = opts.render
  end

  if type(opts.events) == "table" and type(opts.on_update) == "function" then
    fragment.___events = opts.events
    fragment.___on_update = opts.on_update

    for _, event in ipairs(opts.events) do
      events.subscribe(event, function()
        fragment:_on_update(fragment:get_state())
      end)
    end
  end

  return setmetatable(fragment, {
    __index = self,
  })
end

function Fragment:render(...)
  return self.___render(...)
end

function Fragment:get_state()
  return self.___state
end

function Fragment:set_state(new_state)
  if self.___state ~= nil then
    self.___state = new_state
  end
end

function Fragment:_on_update()
  local current_state = self:get_state()
  local set_state = function(...)
    return self:set_state(...)
  end

  if self.___on_update(current_state, set_state) then
    self:render(self:get_state())
  end
end

return Fragment
