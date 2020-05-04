PRD.configurations.warrior = {
    primary = {
        tickMarks = {
            offsets = {
                fury_rampage = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 72
                    end,
                    resourceValue = 85
                }
            }
        },
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        }
    },
    bottom = {
        currentPower_events = { "UNIT_HEALTH_FREQUENT" },
        currentPower = function(cache, event, ...) 
            if event == "UNIT_HEALTH_FREQUENT" and select(1, ...) ~= "player" then
                return false
            end

            cache.currentPower = UnitHealth("player")

            return true, cache.currentPower
        end,
        maxPower_events = { "UNIT_MAXHEALTH" },
        maxPower = function(cache, event, ...) 
            if event == "UNIT_MAXHEALTH" and select(1, ...) ~= "player" then
                return false
            end

            cache.maxPower = UnitHealthMax("player")

            return true, cache.maxPower
        end,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Cloud",
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                return true, string.format("%.0f%%", (cache.currentPower / cache.maxPower) * 100)
            end,
            xOffset = 65,
            yOffset = 2,
            size = 8
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local healthRatio = cache.currentPower / cache.maxPower
            return true, { r = 1.0 - healthRatio, g = healthRatio, b = 0.0 }
        end
    }
}