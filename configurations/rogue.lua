PRD.configurations.rogue = {
    [1] = {
        heightWeight = 2,
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
                        
                        return true, select(1, PRD:GetPlayerBuff(195627)) ~= nil and 20 or 40
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
    [0] = {
        heightWeight = 4,
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
    }
}