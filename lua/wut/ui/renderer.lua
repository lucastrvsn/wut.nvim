local M = {}

--- Recursive render function
function M.render(root)
  if type(root) == "function" then
    return M.render(root())
  end

  if type(root) == "table" and root.___type == "UIFragment" then
    local children_type = type(root.___children)

    if children_type == "table" then
      return M.render(root.___children)
    elseif children_type == "string" then
      return root.___children
    end
  end

  return root
end

return M
