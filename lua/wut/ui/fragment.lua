return setmetatable({}, {
  __call = function(_, element)
    local fragment = {
      ___type = "UIFragment",
      ___children = nil,
    }

    if type(element) == nil then
      error "should not be nil"
    end

    fragment.___children = element

    return fragment
  end,
})
