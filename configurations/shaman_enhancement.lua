PRD.configurations.shaman_enhancement = {
    primary = {
        powerType = Enum.PowerType.Maelstrom,
        tickMarks = {
            offsets = {
                stormstrike = {
                    resourceValue_events = { "PLAYER_TALENT_UPDATE" },
                    resourceValue = function(cache, event, ...) 
                        return true, select(4, GetTalentInfo(6, 2, 1)) and 40 or 30
                    end,
                    color = { r = 0.0, g = 0.75, b = 0.75 }
                },
                cap = {
                    resourceValue = function(cache, event, ...)
                        return true, cache.maxPower - 30
                    end,
                    color = { r = 1.0, g = 0.0, b = 0.0 }
                },
                spender = {
                    resourceValue_events = { "PLAYER_TALENT_UPDATE" },
                    resourceValue = function(cache, event, ...) 
                        return true, select(4, GetTalentInfo(6, 2, 1)) and 30 or 20
                    end,
                    color = { r = 1.0, g = 0.25, b = 0.0 }
                },
            }
        },
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b =  GetClassColor(select(2, UnitClass("player")))
            local color = { r = r, g = g, b = b }

            if cache.currentPower == cache.maxPower then
                color = { r = 0.5, g = 0.0, b = 0.0 }
            elseif cache.currentPower >= cache.maxPower - 30 then
                color = { r = 1.0, g = 0.0, b = 0.0 }
            elseif cache.currentPower >= (select(4, GetTalentInfo(6, 2, 1)) and 50 or 40) then
                color = { r = 1.0, g = 0.25, b = 0.0 }
            end

            return true, color
        end
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event, ...)
                local resourceValues = {}
                
                local healingSpellCost = GetSpellPowerCost(188070)[1].cost
                local currentMaxTick = 0
                
                while currentMaxTick + healingSpellCost < cache.maxPower do
                    currentMaxTick = currentMaxTick + healingSpellCost
                    table.insert(resourceValues, currentMaxTick)
                end
                
                return true, resourceValues
            end
        },
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                local healingSpellCost = GetSpellPowerCost(188070)[1].cost
                return true, math.floor(cache.currentPower / healingSpellCost)
            end,
            xOffset = -65,
            yOffset = 3,
            size = 8
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local percent = cache.currentPower / cache.maxPower
            return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}