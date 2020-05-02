PRD.configurations.priest_shadow = {
    primary = {
        powerType = Enum.PowerType.Insanity,
        color_dependencies = { "currentPower" },
        color_events = { "UNIT_AURA", "PLAYER_TALENT_UPDATE" },
        color = function(cache, event, ...) 
            local powerTypeColor = PowerBarColor[Enum.PowerType.Insanity]
            local defaultColor = { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b } 
            local VoidFormReadyColor = { r = 1.0, g = 1.0, b = 1.0 }

            if event == "INITIAL" or (event == "UNIT_AURA" and select(1, ...) == "player") then
                cache.voidFormActive = (select(1, PRD:GetUnitBuff("player", 194249)) ~= nil)
            end

            if (cache.currentPower >= (select(4, GetTalentInfo(7, 1, 1)) and 60 or 90)) and not cache.voidFormActive then
                return true, VoidFormReadyColor
            else
                return true, defaultColor
            end
        end,
        prediction = {
            color_dependencies = { "next" },
            color_events = { "UNIT_AURA", "PLAYER_TALENT_UPDATE" },
            color = function(cache, event, ...) 
                local powerTypeColor = PowerBarColor[Enum.PowerType.Insanity]
                local defaultColor = { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b } 
                local VoidFormReadyColor = { r = 1.0, g = 1.0, b = 1.0 }

                if event == "INITIAL" then
                    cache.voidFormActive = (select(1, PRD:GetUnitBuff("player", 194249)) ~= nil)
                elseif event == "UNIT_AURA" and select(1, ...) ~= "player" then
                    return false
                end

                cache.voidFormActive = select(1, PRD:GetUnitBuff("player", 194249)) ~= nil

                if (cache.predictedPower >= (select(4, GetTalentInfo(7, 1, 1)) and 60 or 90)) and not cache.voidFormActive then
                    return true, VoidFormReadyColor
                else
                    return true, defaultColor
                end
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
    
                    if SpellCast == 205351 then -- SW: Void
                        cache.predictedPowerGain = 15
                    elseif SpellCast == 32375 then -- Mass Dispel
                        cache.predictedPowerGain = 6
                    elseif SpellCast == 34914 then -- Vampric Touch
                        cache.predictedPowerGain = 6
                    elseif SpellCast == 263346 then -- Dark Void
                        cache.predictedPowerGain = 30
                    elseif SpellCast == 8092 then
                        if select(4, GetTalentInfo(1, 1, 1)) then
                            cache.predictedPowerGain = 12 * .2
                        end
                        
                        cache.predictedPowerGain = predictedPowerGain + 12 
                    end 
                    
                    -- memory buff
                    if PRD:GetUnitBuff("player", 193223) ~= nil then
                        cache.predictedPowerGain = cache.predictedPowerGain * 2
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
            end,
            value_events = { "UNIT_AURA" },
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...)
                if event == "INITIAL" or (event == "UNIT_AURA" and select(1, ...) == "player") then
                    local vfname, _, vfcount, _ = PRD:GetUnitBuff("player", 194249)

                    if vfname ~= nil then
                        cache.voidFormActive = true
                        cache.voidFormStacks = vfcount
                    else
                        cache.voidFormActive = false
                        cache.voidFormStacks = 0
                    end

                    local liname, _, licount, _ = PRD:GetUnitBuff("player", 197937)

                    if liname ~= nil then
                        cache.lingeringInsanityActive = true
                        cache.lingeringInsanityStacks = licount
                    else
                        cache.lingeringInsanityActive = false
                        cache.lingeringInsanityStacks = 0
                    end
                end

                if cache.voidFormActive == true then
                    return true, cache.currentPower .. "     " .. cache.voidFormStacks
                elseif cache.lingeringInsanityActive == true then
                    return true, cache.currentPower .. "    " .. cache.lingeringInsanityStacks
                end

                return true, cache.currentPower
            end,
            xOffset = -5
        },
        tickMarks = {
            color = { r = 1.0, g = 1.0, b = 1.0 },
            offsets = {
                voidForm = {
                    resourceValue_events = { "PLAYER_TALENT_UPDATE" },
                    resourceValue = function(cache, event, ...) 
                        return true, select(4, GetTalentInfo(7, 1, 1)) and 60 or 90                        
                    end,
                }
            }
        }
    },
    bottom = {
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
            xOffset = -65,
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