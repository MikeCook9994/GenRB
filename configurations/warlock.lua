PRD.configurations.warlock = {
    primary = {
        currentPower_events = { "UNIT_POWER_FREQUENT" },
        currentPower = function(cache, event, ...)
            cache.currentPower = UnitPower("player", Enum.PowerType.SoulShards, true) 
            return true, cache.currentPower
        end,
        maxPower = function(cache, event, ...) 
            cache.maxPower = UnitPowerMax("player", Enum.PowerType.SoulShards, true)
            return true, cache.maxPower
        end,
        tickMarks = {
            color = { r = 1.0, g = 1.0, b = 1.0, a = 1.0},
            offsets = { 10, 20, 30, 40 }
        },
        text = {
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...) 
                return true, cache.currentPower / 10
            end,
        },
        color_events = { "PLAYER_SPECIALIZATION_CHANGED" },
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            if event == "INITIAL" or select(1, ...) == "player" then
                if 267 == select(1, GetSpecializationInfo(GetSpecialization())) then
                    if cache.currentPower >= 45 then
                        return true, { r = 0.5, g = 0.0, b = 0.0 }
                    elseif cache.currentPower >= 40 then
                        return true, { r = 0.75, g = 0.5, b = 0.0 }
                    elseif cache.currentPower >= 20 then
                        return true, { r = 1.0, g = 0.5, b = 0.0 }
                    end    
                end
    
                return true, PowerBarColor[Enum.PowerType.SoulShards]
            end

            return false
        end 
    },
    bottom = {
        text = {
            enabled = false
        },
        powerType = Enum.PowerType.Mana,
        color = { r = 0.5, g = 0.25, b = 1.0, a = 1.0 }
    }
}