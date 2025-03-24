---@class IInventory
---@field addItem fun(itemId: string, amount: number): nil
---@field removeItem fun(itemId: string, amount: number): boolean
---@field getItemCount fun(itemId: string): number
---@field getItems fun(): table
---@field getItemList fun(): table
---@field addGold fun(amount: number): nil
---@field removeGold fun(amount: number): boolean
---@field getGold fun(): number
---@field getFormattedGold fun(): string
---@field sellItem fun(itemId: string, amount: number): boolean
---@field buyItem fun(itemId: string, amount: number): boolean
local IInventory = {}

return IInventory 