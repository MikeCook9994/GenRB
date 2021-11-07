PRD.configurations.priest_shadow = {
    primary = {
        powerType = Enum.PowerType.Insanity,
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...) 
            local powerTypeColor = PowerBarColor[Enum.PowerType.Insanity]

            if cache.currentPower >= 50 then
                return true, { r = powerTypeColor.r + 0.25, g = powerTypeColor.g + 0.25, b = powerTypeColor.b + 0.25 } 
            end

            return true, { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b } 
        end,
        prediction = {
            color_dependencies = { "next" },
            color_events = { "UNIT_AURA", "PLAYER_TALENT_UPDATE" },
            color = function(cache, event, ...) 
                local powerTypeColor = PowerBarColor[Enum.PowerType.Insanity]

                if cache.currentPower >= 50 then
                    return true, { r = powerTypeColor.r + 0.25, g = powerTypeColor.g + 0.25, b = powerTypeColor.b + 0.25 } 
                end

                return true, { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b } 
            end,
            next_events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP" },
            next_dependencies = { "currentPower" },
            next = function(cache, event, ...)
                if event == "INITIAL" or (event == "UNIT_SPELLCAST_STOP" and select(1, ...) == "player") then
                    cache.predictedPower = 0
                    cache.predictedPowerGain = 0
                    return true, 0
                elseif event == "UNIT_POWER_FREQUENT" then
                    cache.predictedPower = cache.currentPower + (cache.predictedPowerGain or 0)
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
                    
                    return true, cache.predictedPower
                end
                
                if select(1, ...) == "player" then
                    cache.predictedPowerGain = 0                    
                    local SpellCast = select(3, ...)
    
                    if SpellCast == 8092 then -- Mind Blast
                        cache.predictedPowerGain = 9
                        if select(4, GetTalentInfo(1, 1, 1)) then
                            cache.predictedPowerGain = cache.predictedPowerGain + (9 * .2)
                        end
                    elseif SpellCast == 34914 then -- Vampric Touch
                        cache.predictedPowerGain = 5
                    elseif SpellCast == 263165 then -- Void Torrent
                        cache.predictedPowerGain = 30
                    end 
                    
                    -- stm buff
                    if PRD:GetUnitBuff("player", 298357) ~= nil then
                        cache.predictedPowerGain = cache.predictedPowerGain * 2
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
            end
        },
        tickMarks = {
            color = { r = 1.0, g = 1.0, b = 1.0 },
            offsets = {
                searingNightmare = {
                    enabled_events = { "PLAYER_TALENT_UPDATE" },
                    enabled = function(cache, event, ...) 
                        return true, select(4, GetTalentInfo(3, 3, 1)) and true or false                    
                    end,
                    resourceValue = 30
                },
                devouringPlague = {
                    resourceValue = 50,
                }
            }
        }
    },
    top = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets_dependencies = { "maxPower" },
            offsets = function(cache, event, ...)
                local resourceValues = { }

                local spellCost = GetSpellPowerCost(186263)[1].cost
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
                local spellCost = GetSpellPowerCost(186263)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end
                return true, math.floor(cache.currentPower / spellCost)
            end,
            xOffset = -140,
            yOffset = -5,
            size = 15
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local percent = cache.currentPower / cache.maxPower
            return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}