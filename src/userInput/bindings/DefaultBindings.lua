-- Default key and button bindings
local DefaultBindings = {
  keys = {
    -- System controls
    quit = "escape",
    debug_toggle = "f3",
    
    -- Game actions
    inventory_toggle = "i",
    crafting_open = "c",
    
    -- Movement (if applicable)
    move_up = "w",
    move_down = "s",
    move_left = "a", 
    move_right = "d",
    
    -- UI navigation
    ui_confirm = "return",
    ui_cancel = "escape",
    ui_up = "up",
    ui_down = "down",
    ui_left = "left",
    ui_right = "right"
  },
  
  buttons = {
    -- Mouse actions
    select = 1,  -- Left click
    context = 2, -- Right click
    middle = 3   -- Middle click/wheel
  }
}

return DefaultBindings 