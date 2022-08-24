local M = {}

local rgb_to_hex = function(r, g, b)
  return string.format("#%02X%02X%02X", r, g, b)
end

local hex_to_rgb = function(hex)
  return 1, 1, 1
end

M.from = function(color)
  assert(type(color) == "table" or type(color) == "string")

  local new_color = {
    _type = "Color",
    _data = {
      r = nil,
      g = nil,
      b = nil,
      hex = nil,
    },
  }

  if
    type(color.red) == "string"
    and type(color.green) == "string"
    and type(color.blue) == "string"
  then
    new_color._data.r = color.red
    new_color._data.g = color.green
    new_color._data.b = color.blue
    new_color._data.hex = rgb_to_hex(color.red, color.green, color.blue)
  elseif type(color) == "string" then
    new_color._data.hex = color
  else
    -- TODO: make this better
    print "ERROR"
  end

  return new_color
end

M.darken = function(color, amount)
  return color
end

M.to_hex = function(color)
  return color._data.hex
end

return M
