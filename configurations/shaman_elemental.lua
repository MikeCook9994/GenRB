PRD.configurations.shaman_elemental = {
    primary = {
        color = function(cache, event, ...)
            local r, g, b =  GetClassColor(select(2, UnitClass("player")))
            return true, { r = r, g = g, b = b }
        end,
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "INITIAL" then
                cache.currentPower = 0
            elseif event == "UNIT_AURA" and select(1, ...) ~= "player" then  
                return false
            end

            local name, _, count, _ = PRD:GetUnitBuff("player", 260111)
        
            if name == nil then
                cache.currentPower = 0
                return true, 0, false
            end

            cache.currentPower = count

            return true, cache.currentPower, count ~= 0
        end,
        maxPower = 8,
        prediction = {
            next_events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP" },
            next_dependencies = { "currentPower" },
            next = function(cache, event, ...)
                if event == "INITIAL" or (event == "UNIT_SPELLCAST_STOP" and select(1, ...) == "player") then
                    cache.predictedPower = cache.currentPower
                    cache.predictedPowerGain = 0
                    return true, cache.currentPower
                elseif event == "UNIT_AURA" and select(1, ...) == "player" then
                    local name, _, count, _ = PRD:GetUnitBuff("player", 260111)
                    cache.predictedPower = cache.predictedPowerGain + (count or 0)
                    return true, cache.predictedPower
                elseif select(1, ...) == "player" then
                    cache.predictedPowerGain = 0                    
                    local SpellCast = select(3, ...)
    
                    if SpellCast == 188196 then --LB
                        cache.predictedPowerGain = 1
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
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end,
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...)
                return true, cache.currentPower
            end,
        },
        tickMarks = {
            offsets = { 1, 2, 3, 4, 5, 6, 7 },
            color = { r = 1.0, g = 1.0, b = 1.0}
        }
    },
    top = {
        color = function(cache, event, ...)
            local r, g, b =  GetClassColor(select(2, UnitClass("player")))
            return true, { r = 0.75, g = 0.4, b = 0.2 }
        end,
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "INITIAL" then
                cache.currentPower = 0
            elseif event == "UNIT_AURA" and select(1, ...) ~= "player" then  
                return false
            end

            local name, _, count, _ = PRD:GetUnitBuff("player", 319343)
        
            if name == nil then
                cache.currentPower = 0
                return true, 0, false
            end

            cache.currentPower = count

            return true, cache.currentPower, count ~= 0
        end,
        maxPower = 5,
        prediction = {
            next_events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP" },
            next_dependencies = { "currentPower" },
            next = function(cache, event, ...)
                if event == "INITIAL" or (event == "UNIT_SPELLCAST_STOP" and select(1, ...) == "player") then
                    cache.predictedPower = cache.currentPower
                    cache.predictedPowerGain = 0
                    return true, cache.currentPower
                elseif event == "UNIT_AURA" and select(1, ...) == "player" then
                    local name, _, count, _ = PRD:GetUnitBuff("player", 319343)
                    cache.predictedPower = cache.predictedPowerGain + (count or 0)
                    return true, cache.predictedPower
                elseif select(1, ...) == "player" then
                    cache.predictedPowerGain = 0                    
                    local SpellCast = select(3, ...)
    
                    if SpellCast == 188443 then --LB
                        cache.predictedPowerGain = 1
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
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end,
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...)
                return true, cache.currentPower
            end,
            size = 10,
            xOffset = -65,
            yOffset = -3
        },
        tickMarks = {
            offsets = { 1, 2, 3, 4 },
            color = { r = 1.0, g = 1.0, b = 1.0}
        }
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event, ...)
                local resourceValues = {}
                
                local spellCost = GetSpellPowerCost(8004)[1].cost
                if (spellCost == 0) then
                    return true, resourceValues
                end
                
                local currentMaxTick = 0
                
                while currentMaxTick + spellCost < cache.maxPower do
                    currentMaxTick = currentMaxTick + spellCost
                    table.insert(resourceValues, currentMaxTick)
                end
                
                return true, resourceValues
            end
        },
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                local spellCost = GetSpellPowerCost(8004)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end

                return true, math.floor(cache.currentPower / spellCost)
            end,
            xOffset = 65,
            yOffset = 3,
            size = 10
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local percent = cache.currentPower / cache.maxPower
            return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}