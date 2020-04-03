PRD.configurations.shaman_elemental = {
    primary = {
        powerType = Enum.PowerType.Maelstrom,
        tickMarks = {
            offsets = {
                spender = {
                    resourceValue_events = { "PLAYER_TALENT_UPDATE" },
                    resourceValue = function(cache, event, ...) 
                        return true, select(4, GetTalentInfo(2, 2, 1)) and 50 or 60
                    end,
                    color = { r = 1.0, g = 0.6, b = 0.0 }
                },
                spender_2 = {
                    enabled_events = { "PLAYER_TALENT_UPDATE" },
                    enabled = function(cache, event, ...)
                        return true, select(4, GetTalentInfo(2, 2, 1)) and true or false
                    end,
                    resourceValue = 100,
                    color = { r = 1.0, g = 0.6, b = 0.0 }
                },
                cap = {
                    resourceValue = function(cache, event, ...)
                        if event == "INITIAL" or select(1, ...) == "player" then
                            return true, cache.maxPower - 10
                        end

                        return false
                    end,
                    color = { r = 0.6, g = 0.0, b = 0.0 }
                },
                surge_of_power_cap = {
                    enabled_events = { "PLAYER_TALENT_UPDATE" },
                    enabled = function(cache, event, ...) 
                        return true, select(4, GetTalentInfo(6, 1, 1)) and true or false
                    end,
                    resourceValue = 94,
                    color = { r = 1.0, g = 0.0, b = 0.0 }
                }
            }
        },
        prediction = {
            color_dependencies = { "next" },
            color = function(cache, event, ...)
                local r, g, b =  GetClassColor(select(2, UnitClass("player")))
                local color = { r = r, g = g, b = b }

                if event == "INITIAL" or select(1, ...) == "player" then
                    if cache.predictedPower == cache.maxPower then
                        color = { r = 0.39, g = 0.02, b = 0.0 }
                    elseif cache.predictedPower >= cache.maxPower - 10 then
                        color = { r = 1.0, g = 0.0, b = 0.0 }
                    elseif (cache.predictedPower >= (select(4, GetTalentInfo(2, 2, 1)) and 50 or 60)) then
                        color = { r = 0.56, g = 0.35, b = 0.0 }
                    end

                    return true, color
                end

                return false
            end,
            next_events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP" },
            next_dependencies = { "currentPower", "maxPower" },
            next = function(cache, event, ...)
                if event == "INITIAL" or event == "UNIT_SPELLCAST_STOP" then
                    cache.predictedPower = 0
                    cache.predictedPowerGain = 0
                    return true, 0
                elseif event == "UNIT_POWER_FREQUENT" then
                    cache.predictedPower = cache.currentPower + (cache.predictedPowerGain or 0)
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
                    
                    return true, cache.predictedPower
                end

                local unit = select(1, ...)
                if unit == "player" then
                    cache.predictedPowerGain = 0                    
                    local SpellCast = select(3, ...)

                    if SpellCast == 188196 then --LB
                        cache.predictedPowerGain = 8
                    elseif SpellCast == 51505 then --LvB
                        cache.predictedPowerGain = 10
                    elseif SpellCast == 210714 then --IF
                        cache.predictedPowerGain = 25
                    elseif SpellCast == 188443 then --CL
                        cache.predictedPowerGain = 12
                    end 
                    
                    cache.predictedPower = cache.currentPower + cache.predictedPowerGain   
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
                    
                    return true, cache.predictedPower
                end

                return false
            end
        },
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                if event == "INITIAL" or (select(1, ...) == "player" and PRD:ConvertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                    return true, cache.currentPower > 0
                end

                return false
            end
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b =  GetClassColor(select(2, UnitClass("player")))
            local color = { r = r, g = g, b = b }

            if event == "INITIAL" or (select(1, ...) == "player" and PRD:ConvertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                if cache.currentPower == cache.maxPower then
                    return true, { r = 0.39, g = 0.02, b = 0.0 }
                elseif cache.currentPower >= cache.maxPower - 10 then
                    return true, { r = 1.0, g = 0.0, b = 0.0 }
                elseif (cache.currentPower >= (select(4, GetTalentInfo(2, 2, 1)) and 50 or 60)) then
                    return true, { r = 0.56, g = 0.35, b = 0.0 }
                end

                return true, color
            end

            return false
        end
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event, ...)
                if event == "INITIAL" or (select(1, ...) == "player" and PRD:ConvertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                    local resourceValues = {}
                    
                    local healingSpellCost = GetSpellPowerCost(8004)[1].cost
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
                if event == "INITIAL" or (select(1, ...) == "player" and PRD:ConvertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                    local healingSpellCost = GetSpellPowerCost(8004)[1].cost
                    return true, math.floor(cache.currentPower / healingSpellCost)
                end

                return false
            end,
            xOffset = -65,
            yOffset = 3,
            size = 8
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            if event == "INITIAL" or (select(1, ...) == "player" and PRD:ConvertPowerTypeStringToEnumValue(select(2, ...)) == cache.powerType) then
                local percent = cache.currentPower / cache.maxPower
                return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
            end
            
            local r, g, b = GetClassColor(select(2, UnitClass("player")))
            return false
        end
    }
}