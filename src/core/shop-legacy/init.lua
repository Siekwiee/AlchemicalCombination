local love = require("love")
local Inventory = require("src.core.items.inventory")

-- Import sub-modules
local Drawing = require("src.core.shop-legacy.drawing")
local Handlers = require("src.core.shop-legacy.handlers")
local Core = require("src.core.shop-legacy.core")

---@class Shop
---@field new fun(self: Shop): Shop Create a new Shop
---@field loadShopItems fun(self: Shop): boolean Load shop items from JSON file
---@field update fun(self: Shop, dt: number) Update the shop
---@field draw fun(self: Shop) Draw the shop UI
---@field mousepressed fun(self: Shop, x: number, y: number, button: number): boolean Handle mouse press
---@field mousemoved fun(self: Shop, x: number, y: number, dx: number, dy: number): boolean Handle mouse movement
---@field mousereleased fun(self: Shop, x: number, y: number, button: number): boolean Handle mouse release
---@field wheelmoved fun(self: Shop, x: number, y: number, dx: number, dy: number): boolean Handle mouse wheel
---@field toggleShop fun(self: Shop) Toggle shop visibility
---@field isOpen fun(self: Shop): boolean Check if shop is open
---@field setInventory fun(self: Shop, inventory: Inventory) Set the player inventory
---@field core ShopCore The shop core module
---@field handlers ShopHandlers The shop handlers module
---@field drawing ShopDrawing The shop drawing module
---@field setInventory fun(self: Shop, inventory: Inventory) Set the player inventory
local Shop = {}

function Shop:new()
    local instance = {}
    setmetatable(instance, {__index = self})
    
    -- Initialize core components
    instance.core = Core:new()
    instance.inventory = nil -- Will be set by setInventory method
    instance.handlers = nil -- Will be initialized after inventory is set
    instance.drawing = nil -- Will be initialized after handlers is set
    
    -- Load shop data
    instance.core:loadShopItems()
    
    return instance
end

---Sets the inventory to be used by the shop
---@param inventory Inventory
function Shop:setInventory(inventory)
    self.inventory = inventory
    
    -- Initialize handlers and drawing with the inventory
    self.handlers = Handlers:new(self.core, self.inventory)
    self.drawing = Drawing:new(self.core, self.handlers, self.inventory)
end

---Loads shop items from the JSON file
---@return boolean success
function Shop:loadShopItems()
    return self.core:loadShopItems()
end

---Updates the shop
---@param dt number Time delta
function Shop:update(dt)
    self.drawing:update(dt)
end

---Draws the shop UI
function Shop:draw()
    self.drawing:draw()
end

---Handles mouse press on the shop UI
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number Mouse button pressed
---@return boolean handled Whether the input was handled
function Shop:mousepressed(x, y, button)
    return self.drawing:mousepressed(x, y, button)
end

---Handles mouse movement for dragging
---@param x number Mouse x position
---@param y number Mouse y position
---@param dx number X movement delta
---@param dy number Y movement delta
---@return boolean handled Whether the input was handled
function Shop:mousemoved(x, y, dx, dy)
    return self.drawing:mousemoved(x, y, dx, dy)
end

---Handles mouse release to end dragging
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number Mouse button released
---@return boolean handled Whether the input was handled
function Shop:mousereleased(x, y, button)
    return self.drawing:mousereleased(x, y, button)
end

---Handles mouse wheel movement for scrolling
---@param x number Mouse x position
---@param y number Mouse y position
---@param dx number Horizontal scroll amount
---@param dy number Vertical scroll amount
---@return boolean handled Whether the input was handled
function Shop:wheelmoved(x, y, dx, dy)
    return self.drawing:wheelmoved(x, y, dx, dy)
end

---Toggles shop visibility
function Shop:toggleShop()
    self.drawing:toggleShop()
end

---Checks if shop is open
---@return boolean isOpen
function Shop:isOpen()
    return self.drawing.isOpen
end

---Gets available items for a category
---@param category string Category name
---@return table items
function Shop:getCategoryItems(category)
    return self.core:getCategoryItems(category)
end

---Gets all available categories
---@return table categories
function Shop:getAvailableCategories()
    return self.core:getAvailableCategories()
end

---Gets all sellable items
---@return table items
function Shop:getSellableItems()
    return self.core:getSellableItems()
end

return Shop
