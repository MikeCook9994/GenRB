PRD.configurations.deathknight = {
    top = {
        -- enabled_dependencies = { "currentPower" },
        -- enabled = function(cache, event, ...)
        --     return true, cache.currentPower ~= 0 or UnitAffectingCombat("player")
        -- end,
        powerType = Enum.PowerType.RunicPower,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        text = {
            xOffset = -65,
            yOffset = -3,
            size = 7
        },
        tickMarks = {
            offsets = {
                heart_strike = {
                    resourceValue_events = { "UNIT_AURA" },
                    resourceValue = function(cache, event, ...)
                        if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                            return false
                        end

                        return true, (select(1, PRD:GetUnitBuff('player', 219788)) == nil) and 45 or 40
                    end,
                    color = { r = 1.0, g = 1.0, b = 1.0 }
                },
            }
        }
    },
    primary = {
        powerType = Enum.PowerType.Runes,
        currentPower_events = { "RUNE_POWER_UPDATE" },
        currentPower = function(cache, event, ...) 
            if event == "RUNE_POWER_UPDATE" and select(1, ...) ~= cache.runeIndex then
                return false, nil, cache.cooling
            end

            local start, duration, ready = GetRuneCooldown(cache.runeIndex)

            cache.currentPower = start ~= 0 and (GetTime() - start) or duration
            cache.cooling = not ready

            return true, cache.currentPower, cache.cooling
        end,
        maxPower_events = { "RUNE_POWER_UPDATE" },
        maxPower = function(cache, event, ...) 
            if event == "RUNE_POWER_UPDATE" and select(1, ...) ~= cache.runeIndex then
                return false, nil, cache.cooling
            end

            cache.maxPower, ready = select(2, GetRuneCooldown(cache.runeIndex))
            cache.cooling = not ready
            return true, cache.maxPower, cache.cooling
        end,
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            if cache.cooling then
                return true, { r = 0.5, g = 0.125, b = 0.125 }
            end

            local r, g, b = GetClassColor("DEATHKNIGHT")
            return true, { r = r, g = g, b = b }
        end,
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower < cache.maxPower and cache.maxPower - cache.currentPower < cache.maxPower
            end,
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...) 
                return true, (("%%d"):format(0):format(cache.maxPower - cache.currentPower))
            end,
            size = 8
        },
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 }
        }
    },
    bottom = {
        currentPower_events = { "UNIT_HEALTH_FREQUENT" },
        currentPower = function(cache, event, ...) 
            if event == "UNIT_HEALTH_FREQUENT" and select(1, ...) ~= "player" then
                return false
            end

            return true, UnitHealth("player") 
        end,
        maxPower_events = { "UNIT_MAXHEALTH" },
        maxPower = function(cache, event, ...) 
            if event == "UNIT_MAXHEALTH" and select(1, ...) ~= "player" then
                return false
            end

            return true, UnitHealthMax("player") 
        end,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Cloud",
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
            end,
            xOffset = 65,
            yOffset = 2,
            size = 7
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local healthRatio = cache.currentPower / cache.maxPower
            return true, { r = 1.0 - (1.0 * healthRatio), g = 1.0 * healthRatio, b = 0.0}
        end
    }
}