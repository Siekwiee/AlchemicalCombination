---Utility functions for detecting and checking input
local InputDetection = {}

---Checks if a point is within a rectangle
---@param x number Point X position
---@param y number Point Y position
---@param rect_x number Rectangle X position
---@param rect_y number Rectangle Y position
---@param rect_width number Rectangle width
---@param rect_height number Rectangle height
---@return boolean Whether the point is within the rectangle
function InputDetection.is_point_in_rect(x, y, rect_x, rect_y, rect_width, rect_height)
  return x >= rect_x and x <= rect_x + rect_width and
         y >= rect_y and y <= rect_y + rect_height
end

---Checks if a point is within a circle
---@param x number Point X position
---@param y number Point Y position
---@param circle_x number Circle center X position
---@param circle_y number Circle center Y position
---@param radius number Circle radius
---@return boolean Whether the point is within the circle
function InputDetection.is_point_in_circle(x, y, circle_x, circle_y, radius)
  local dx = x - circle_x
  local dy = y - circle_y
  return dx * dx + dy * dy <= radius * radius
end

---Checks if two rectangles overlap
---@param rect1_x number Rectangle 1 X position
---@param rect1_y number Rectangle 1 Y position
---@param rect1_width number Rectangle 1 width
---@param rect1_height number Rectangle 1 height
---@param rect2_x number Rectangle 2 X position
---@param rect2_y number Rectangle 2 Y position
---@param rect2_width number Rectangle 2 width
---@param rect2_height number Rectangle 2 height
---@return boolean Whether the rectangles overlap
function InputDetection.do_rects_overlap(rect1_x, rect1_y, rect1_width, rect1_height, 
                                          rect2_x, rect2_y, rect2_width, rect2_height)
  return rect1_x < rect2_x + rect2_width and
         rect1_x + rect1_width > rect2_x and
         rect1_y < rect2_y + rect2_height and
         rect1_y + rect1_height > rect2_y
end

---Gets the distance between two points
---@param x1 number Point 1 X position
---@param y1 number Point 1 Y position
---@param x2 number Point 2 X position
---@param y2 number Point 2 Y position
---@return number The distance between the points
function InputDetection.get_distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

---Gets the squared distance between two points (more efficient)
---@param x1 number Point 1 X position
---@param y1 number Point 1 Y position
---@param x2 number Point 2 X position
---@param y2 number Point 2 Y position
---@return number The squared distance between the points
function InputDetection.get_distance_squared(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return dx * dx + dy * dy
end

return InputDetection