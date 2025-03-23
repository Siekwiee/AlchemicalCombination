---@class EffectsManager
---@field new fun(self: EffectsManager): EffectsManager
---@field update fun(self: EffectsManager, dt: number)
---@field draw fun(self: EffectsManager)
---@field createFlash fun(self: EffectsManager, x: number, y: number, color: table, duration: number, size: number)
---@field createFade fun(self: EffectsManager, x: number, y: number, color: table, duration: number, size: number)
---@field createCombinationEffect fun(self: EffectsManager, x: number, y: number, duration: number)
---@field createElementEffect fun(self: EffectsManager, x: number, y: number, elementType: string, duration: number)
---@field clear fun(self: EffectsManager)

local EffectsManager = require("src.visualization.effects.manager")
local FlashEffect = require("src.visualization.effects.flash")
local FadeEffect = require("src.visualization.effects.fade")
local CombinationEffect = require("src.visualization.effects.combination")
local ElementEffect = require("src.visualization.effects.element")
local ElementColors = require("src.visualization.effects.element_colors")

-- Effects module for easy importing
local Effects = {
    Manager = EffectsManager,
    Flash = FlashEffect,
    Fade = FadeEffect,
    Combination = CombinationEffect,
    Element = ElementEffect,
    Colors = ElementColors
}

-- Return a new manager by default
return EffectsManager 