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
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = { 1, 2, 3, 4 }
        }
    }
}