PRD.configurations.rogue = {
    [2] = {
        heightWeight = 2,
        text = {
            enabled = false
        },
        powerType = Enum.PowerType.ComboPoints,
        color = { r = 1.0, g = 0.65, b = 0.0 },
        tickMarks = {
            offsets_dependencies = { "maxPower" },
            offsets = function(cache, event, ...) 
                local offsets = { }

                for i = 1, cache.maxPower - 1, 1 do
                    table.insert(offsets, i)
                end

                return true, offsets
            end
        }
    },
    [1] = {
        heightWeight = 5,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = {
                pistol_shot = {
                    resourceValue_events = { "UNIT_AURA" },
                    resourceValue = function(cache, event, ...) 
                        if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                            return false  
                        end
                        
                        return true, select(1, PRD:GetPlayerBuff(195627)) ~= nil and 20 or 40
                    end
                },
                sinister_strike = {
                    resourceValue = 45
                }
            }
        }
    },
    [0] = {
        heightWeight = 1,
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