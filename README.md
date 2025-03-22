# Alchemy Factory - README

## Overview

Alchemy Factory is an idle crafting game where players combine elemental resources to create complex materials. The core mechanics revolve around manual crafting, resource management, and automation through golems and alchemic machines. The game incorporates randomized mechanics to introduce variability, ensuring a dynamic experience.

## Game Concept

### Core Mechanics

- **Drag-and-Drop Crafting:** Players mix resources by dragging elements on top of each other, consuming them and producing new materials.
- **Resource Management:** Players must efficiently use resources to maximize output and profitability.
- **Selling System:** Crafted materials can be sold for gold, which is used to unlock new elements, upgrades, and automation tools.
- **Automation Progression:** Golems and automated cauldrons handle repetitive crafting processes, allowing the player to scale production.
- **RNG-Driven Events:** Randomized events influence production outcomes, introducing unpredictability.
- **Prestige System:** Players can reset their progress for permanent bonuses, unlocking hidden elements and improving efficiency.

### Resource Tiers

1. **Basic Elements:** Fire, Water, Earth, Air (starting materials)
2. **Intermediate Materials:** Metal, Steam, Mud, Plants
3. **Advanced Creations:** Gold, Magic Crystals, Philosopher’s Stones, Alchemical Golems

### Automation System

- **Early Game:** Players manually combine elements.
- **Mid-Game:** Unlock automation tools with randomized success rates.
- **Late Game:** Optimized systems reduce randomness and increase efficiency.

## Technical Architecture

### Code Structure

The game follows an **Entity-Component-System (ECS)** model to ensure modularity and maintainability.

#### Modules

1. **UI Layer**
   - Manages user interactions, including drag-and-drop functionality.
   - Uses an event-driven architecture to handle input and rendering.
   - Follows a rendering queue system for performance optimization.

```lua
-- Example: UI Drag and Drop System
local UI = {}

function UI:dragElement(element, x, y)
    element.x = x
    element.y = y
end

function UI:dropElement(element, target)
    if target:canCombineWith(element) then
        target:combine(element)
    end
end
```

2. **Simulation Layer**
   - Handles crafting logic, resource processing, and game progression.
   - Ensures separation from UI for scalability.

```lua
-- Example: Crafting System
local Crafting = {}

function Crafting:combine(element1, element2)
    local result = Recipes[element1][element2]
    if result then
        return result
    else
        return "Unknown Reaction"
    end
end
```

3. **Event Queue System**
   - Implements a buffered queue to handle event bursts.
   - Uses a time-based event scheduler for predictable simulation flow.
   - Ensures thread-safe operations for stability.

```lua
-- Example: Event Queue
local EventQueue = {}
EventQueue.queue = {}

function EventQueue:addEvent(event)
    table.insert(self.queue, event)
end

function EventQueue:processEvents()
    for _, event in ipairs(self.queue) do
        event:execute()
    end
    self.queue = {}  -- Clear processed events
end
```

4. **Data Management**
   - Uses Lua tables for efficient resource tracking.
   - Implements caching mechanisms for frequently accessed data.

```lua
-- Example: Resource Management
local Resources = { gold = 0, elements = {} }

function Resources:addElement(element, amount)
    self.elements[element] = (self.elements[element] or 0) + amount
end

function Resources:spendElement(element, amount)
    if self.elements[element] and self.elements[element] >= amount then
        self.elements[element] = self.elements[element] - amount
        return true
    end
    return false
end
```

## Coding Best Practices

The codebase adheres to the following principles:

- **Lua Best Practices**

  - Use local variables to minimize global namespace pollution.
  - Leverage metatables for object-oriented design.
  - Implement error handling with `pcall` for robustness.

- **UI Layer Best Practices**

  - Keep UI logic separate from the simulation layer.
  - Ensure modular, reusable UI components.

- **ECS Best Practices**
  - Use lightweight entity references.
  - Maintain component pools to optimize memory usage.
  - Separate logic into distinct systems.

## Development Roadmap

### Phase 1: Core Mechanics

- Implement basic element combination system.
- Set up UI with drag-and-drop functionality.
- Develop an event queue for game state updates.

### Phase 2: Resource Economy & Automation

- Introduce a marketplace for selling materials.
- Implement golem-based automation with RNG efficiency factors.
- Optimize event scheduling for performance.

### Phase 3: Endgame & Prestige

- Add a prestige system with permanent bonuses.
- Introduce rare alchemical recipes and unpredictable crafting outcomes.
- Finalize automation upgrades and late-game efficiency mechanics.

## Conclusion

Alchemy Factory is structured around maintainability, performance optimization, and modularity. The game’s architecture follows best practices for UI separation, event management, and efficient Lua programming. This document serves as a reference for development, ensuring consistency and scalability as the project evolves.
