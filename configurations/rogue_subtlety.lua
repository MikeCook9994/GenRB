PRD.configurations.rogue = {
    primary = {
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = {
                pistol_shot = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...) 
                        return true, 260 == select(1, GetSpecializationInfo(GetSpecialization()))
                    end,    
                    resourceValue_events = { "UNIT_AURA" },
                    resourceValue = function(cache, event, ...) 
                        if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                            return false  
                        end
                        
                        return true, select(1, PRD:GetUnitBuff("player", 195627)) ~= nil and 20 or 40
                    end
                },
                sinister_strike = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...) 
                        return true, 260 == select(1, GetSpecializationInfo(GetSpecialization()))
                    end,
                    resourceValue = 45
                }
            }
        }
    },
    top = {
        text = {
            enabled = false
        },
        powerType = Enum.PowerType.ComboPoints,
        color = { r = 1.0, g = 0.65, b = 0.0 },
        tickMarks = {
            offsets_events = { "PLAYER_TALENT_UPDATE" },
            offsets = function(cache, event, ...)
                if select(4, GetTalentInfo(3, 2, 1)) and true or false then
                    return true, { 1, 2, 3, 4, 5 }
                end

                return true, { 1, 2, 3, 4 }
            end
        }
    },
    bottom = {
        currentPower_events = { "COMBAT_LOG_EVENT_UNFILTERED" },
        currentPower = function(cache, event, ...)
            if event == "INITIAL" then
                cache.currentPower = 0
                return true, 0
            end

            local sourceGUID = select(4, ...)

            if sourceGUID == UnitGUID("player") then
                local subEvent = select(2, ...)
                local spellId = select(12, ...)
                
                if subEvent == "SWING_DAMAGE" then
                    cache.currentPower = cache.currentPower + 1
                    return true, cache.currentPower
                elseif subEvent == "SPELL_ENERGIZE" and spellId == 196911 then
                    cache.currentPower = 0
                    return true, 0
                end
            end

            return false
        end,
        maxPower = 3,
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            if cache.currentPower == 1 then
                return true, { r = 1.0, g = 0.00, b = 0.0 }
            elseif cache.currentPower == 2 then
                return true, { r = 1.0, g = 1.0, b = 0.0 }
            elseif cache.currentPower == 3 then
                return true, { r = 0.0, g = 1.0, b = 0.0 }
            else
                return true, { r = 0.0, g = 0.0, b = 0.0 }
            end
        end,
        tickMarks = {
            offsets = { 1, 2 }
        }
    }
}