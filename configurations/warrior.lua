PRD.configurations.warrior = {
    [0] = {
        tickMarks = {
            offsets = {
                fury_rampage = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 72
                    end,
                    resourceValue_events = { "PLAYER_TALENT_UPDATE" },
                    resourceValue = function(cache, event, ...) 
                        return true, (select(4, GetTalentInfo(5, 1, 1)) and 75) or (select(4, GetTalentInfo(5, 3, 1)) and 95) or 85
                    end
                },
                arms_slam = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 71
                    end,
                    resourceValue = 20
                },
                arms_mortal_strike = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 71
                    end,
                    resourceValue = 30
                },
                arms_execute = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 71
                    end,
                    resourceValue = 40
                }
            }
        },
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        }
    }
}