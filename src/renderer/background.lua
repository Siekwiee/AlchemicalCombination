local Background = {}

---@class Background
---@field drawBackground fun(game_state: GameState)
function Background:drawBackground(game_state)
    --draw the background
    local valid_states = { ["menu"] = true, ["playstate"] = true }
    if game_state and game_state.state_name and valid_states[game_state.state_name] then
        BasicBackground(game_state)
    end
end

function BasicBackground(game_state)
    -- Get window dimensions for centering
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw title
    love.graphics.setColor(1, 1, 1, 1)
    local title = "Main Menu"
    local font = love.graphics.getFont()
    local title_width = font:getWidth(title) * 2  -- Assuming we want the title larger
    love.graphics.print(title, window_width / 2 - title_width / 2, window_height / 4, 0, 2, 2)
end

return Background
