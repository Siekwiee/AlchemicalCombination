local Background = {}
local love = require("love")

---@class Background
---@field drawBackground fun(game_state: GameState)
---@field particles table Particle systems for background effects
---@field symbols table Alchemical symbols for decoration
---@field gradients table Color gradients for different states
Background.particles = {}
Background.symbols = {}
Background.gradients = {
    menu = {
        top = {0.1, 0.05, 0.2, 1},    -- Deep purple
        bottom = {0.2, 0.1, 0.3, 1}   -- Lighter purple
    },
    playstate = {
        top = {0.05, 0.1, 0.2, 1},    -- Deep blue
        bottom = {0.1, 0.2, 0.3, 1}   -- Lighter blue
    }
}

-- Initialize background effects
function Background:init()
    -- Create particle system for magical dust/bubbles
    local particle_img = love.graphics.newCanvas(8, 8)
    love.graphics.setCanvas(particle_img)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", 4, 4, 3)
    love.graphics.setCanvas()
    
    -- Create main particle system
    self.particles.dust = love.graphics.newParticleSystem(particle_img, 100)
    self.particles.dust:setParticleLifetime(3, 8)
    self.particles.dust:setEmissionRate(5)
    self.particles.dust:setSizeVariation(1)
    self.particles.dust:setLinearAcceleration(-5, -10, 5, 10)
    self.particles.dust:setColors(
        1, 1, 1, 0.2,   -- White with low alpha
        1, 0.8, 0.4, 0.4,  -- Gold
        0.6, 0.3, 0.9, 0.2,  -- Purple
        0.2, 0.2, 0.8, 0   -- Blue fading out
    )
    
    -- Generate alchemical symbols for decoration
    local symbols = {"⚗", "⚕", "☿", "♀", "♂", "♄", "♃", "☉", "☽", "♆"}
    self.symbols = {}
    for i = 1, 15 do
        table.insert(self.symbols, {
            symbol = symbols[math.random(1, #symbols)],
            x = math.random(50, love.graphics.getWidth() - 50),
            y = math.random(50, love.graphics.getHeight() - 50),
            size = math.random(1, 3),
            alpha = math.random(10, 30) / 100,
            rotation = math.random(0, 360) * (math.pi/180)
        })
    end
    
    -- Start particle systems
    self.particles.dust:start()
end

function Background:update(dt)
    -- Update particle systems
    if self.particles.dust then
        self.particles.dust:update(dt)
    end
    
    -- Update particle emitter positions
    if self.particles.dust then
        local width, height = love.graphics.getDimensions()
        self.particles.dust:setPosition(width / 2, height + 50)
    end
    
    -- Animate symbols
    for i, symbol in ipairs(self.symbols) do
        symbol.rotation = symbol.rotation + (0.1 * dt)
        if i % 3 == 0 then
            symbol.y = symbol.y - (3 * dt)
            if symbol.y < -30 then
                symbol.y = love.graphics.getHeight() + 30
                symbol.x = math.random(50, love.graphics.getWidth() - 50)
            end
        end
    end
end

function Background:drawBackground(game_state)
    if not game_state then return end
    
    -- Initialize if needed
    if not self.particles.dust then
        self:init()
    end
    
    -- Get dimensions
    local width, height = love.graphics.getDimensions()
    
    -- Draw gradient background based on state
    local gradient
    if game_state.state_name == "menu" then
        gradient = self.gradients.menu
    elseif game_state.state_name == "playstate" then
        gradient = self.gradients.playstate
    else
        -- Default gradient
        gradient = { top = {0.1, 0.1, 0.1, 1}, bottom = {0.2, 0.2, 0.2, 1} }
    end
    
    -- Draw gradient background
    love.graphics.setColor(gradient.top)
    love.graphics.rectangle("fill", 0, 0, width, height / 2)
    love.graphics.setColor(gradient.bottom)
    love.graphics.rectangle("fill", 0, height / 2, width, height / 2)
    
    -- Draw subtle grid pattern
    love.graphics.setColor(1, 1, 1, 0.05)
    local grid_size = 30
    for x = 0, width, grid_size do
        love.graphics.line(x, 0, x, height)
    end
    for y = 0, height, grid_size do
        love.graphics.line(0, y, width, y)
    end
    
    -- Draw alchemical symbols in background
    love.graphics.setColor(1, 1, 1, 0.15)
    for _, symbol in ipairs(self.symbols) do
        love.graphics.print(
            symbol.symbol, 
            symbol.x, 
            symbol.y, 
            symbol.rotation, 
            symbol.size, 
            symbol.size, 
            10, 
            10
        )
    end
    
    -- Draw particles
    love.graphics.setColor(1, 1, 1, 1)
    if self.particles.dust then
        love.graphics.draw(self.particles.dust)
    end
    
    -- Draw title with glow effect
    if game_state.state_name == "menu" then
        self:drawTitle("Alchemical Combination", width / 2, height / 4, {1, 0.8, 0.2, 1})
    elseif game_state.state_name == "playstate" then
        self:drawTitle("Laboratory", width / 2, 50, {0.6, 0.9, 1, 1})
    end
end

function Background:drawTitle(title, x, y, color)
    -- Draw glow
    local glow_strength = 10
    for i = glow_strength, 1, -1 do
        local alpha = i / glow_strength * 0.3
        local size = 2 + (i / glow_strength * 0.5)
        love.graphics.setColor(color[1], color[2], color[3], alpha)
        
        local font = love.graphics.getFont()
        local text_width = font:getWidth(title) * 2
        love.graphics.print(
            title, 
            x - text_width / 2 + math.random(-1, 1), 
            y + math.random(-1, 1), 
            0, 
            size, 
            size
        )
    end
    
    -- Draw actual text
    love.graphics.setColor(color[1], color[2], color[3], 1)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(title) * 2
    love.graphics.print(title, x - text_width / 2, y, 0, 2, 2)
end

function BasicBackground(game_state)
    Background:drawBackground(game_state)
end

return Background
