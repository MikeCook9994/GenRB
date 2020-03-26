function()
    aura_env.specConfigurations.shaman_enhancement = {
        primary = {
            powerType = Enum.PowerType.Maelstrom,
            tickMarks = {
                offsets = {
                    stormstrike = {
                        resourceValue_events = { "PLAYER_TALENT_UPDATE" },
                        resourceValue = function(cache, event, ...) 
                            return true, select(4, GetTalentInfo(6, 2, 1)) and 40 or 30
                        end,
                        color = { r = 0.0, g = 0.75, b = 0.75, a = 1.0 }
                    },
                    cap = {
                        resourceValue = function(cache, event, ...)
                            if event == "INITIAL" or select(1, ...) == "player" then
                                return true, cache.maxPower - 30
                            end

                            return false
                        end,
                        color = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
                    }
                }
            },
            text = {
                enabled_dependencies = { "currentPower" },
                enabled = function(cache, event, ...)
                    if event == "INITIAL" or (select(1, ...) == "player" and aura_env.convertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                        return true, cache.currentPower > 0
                    end

                    return false
                end
            },
            color_dependencies = { "currentPower", "maxPower" },
            color = function(cache, event, ...)
                local r, g, b, _ =  GetClassColor(select(2, UnitClass("player")))
                local color = { r = r, g = g, b = b, a = 1.0 }

                if event == "INITIAL" or (select(1, ...) == "player" and aura_env.convertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                    if cache.currentPower == cache.maxPower then
                        return true, { r = 0.5, g = 0.0, b = 0.0, a = 1.0 }
                    elseif cache.currentPower >= cache.maxPower - 30 then
                        return true, { r = 1.0, g = 0.0, b = 0.0, a = 1.0 }
                    elseif cache.currentPower >= (select(4, GetTalentInfo(6, 2, 1)) and 50 or 40) then
                        return true, { r = 1.0, g = 0.25, b = 0.0, a = 1.0 }
                    end

                    return true, color
                end

                return false
            end
        },
        bottom = {
            powerType = Enum.PowerType.Mana,
            tickMarks = {
                color = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 },
                offsets = function(cache, event, ...)
                    if event == "INITIAL" or (select(1, ...) == "player" and aura_env.convertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                        local resourceValues = {}
                     
                        local healingSpellCost = GetSpellPowerCost(188070)[1].cost
                        local currentMaxTick = 0
                        
                        while currentMaxTick + healingSpellCost < cache.maxPower do
                            currentMaxTick = currentMaxTick + healingSpellCost
                            table.insert(resourceValues, currentMaxTick)
                        end
                        
                        return true, resourceValues
                    end

                    return false
                end
            },
            text = {
                value_dependencies = { "currentPower", "maxPower" },
                value = function(cache, event, ...)
                    if event == "INITIAL" or (select(1, ...) == "player" and aura_env.convertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                        local healingSpellCost = GetSpellPowerCost(188070)[1].cost
                        return true, math.floor(cache.currentPower / healingSpellCost)
                    end

                    return false
                end,
                xOffset = -110,
                yOffset = 5,
                size = 12
            },
            color_dependencies = { "currentPower", "maxPower" },
            color = function(cache, event, ...)
                if event == "INITIAL" or (select(1, ...) == "player" and aura_env.convertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                    local percent = cache.currentPower / cache.maxPower
                    return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent, a = 1.0 }
                end
                
                local r, g, b, _ = GetClassColor(select(2, UnitClass("player")))
                return false
            end
        }
    }
end