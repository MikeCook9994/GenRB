PRD.configurations.deathknight = {
    top = {
        enabled_dependencies = { "currentPower" },
        enabled = function(cache, event, ...)
            return true, current ~= 0 or UnitAffectingCombat("player")
        end,
        powerType = Enum.PowerType.RunicPower,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        text = {
            xOffset = -65,
            yOffset = -2,
            size = 8
        },
        tickMarks = {
            offsets = {
                heart_strike = {
                    resourceValue_events = { "UNIT_AURA" },
                    resourceValue = function(cache, event, ...)
                        if select(1, ...) ~= "player" then
                            return false
                        end

                        return true, (select(1, PRD:GetUnitBuff('player', 219788)) ~= nil) and 45 or 40
                    end,
                    color = { r = 0.5, g = 0.5, b = 0.5 }
                },
            }
        }
    },
    primary = {
        powerType = Enum.PowerType.Runes,
        currentPower_events = { "RUNE_POWER_UPDATE" },
        currentPower = function(cache, event, ...) 
            if select(1, ...) ~= cache.runeIndex then
                return false
            end 

            local start, duration, ready = GetRuneCooldown(cache.runeIndex)

            cache.elapsedCooldown = start ~= 0 and (GetTime() - start) or duration
            cache.duration = duration

            return true, cache.elapsedCooldown, not ready
        end,
        currentPower_events = { "RUNE_POWER_UPDATE" },
        currentPower = function(cache, event, ...) 
            if select(1, ...) ~= cache.runeIndex then
                return false
            end

            local start, duration, ready = GetRuneCooldown(cache.runeIndex)

            cache.elapsedCooldown = start ~= 0 and (GetTime() - start) or duration
            cache.duration = duration

            return true, duration, not ready
        end,
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("DEATHKNIGHT")
            return { r = r, g = g, b = b }
        end,
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return cache.elapsedCooldown < cache.duration and cache.duration - cache.elapsedCooldown < cache.duration
            end,
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...) 
                return (("%%d"):format(0):format(cache.duration - cache.elapsedCooldown))
            end
        },
        tickMarks = {
            enabled = function(cache, event, ...) 
                return true, cache.runeIndex ~= 6
            end,
            offsets = function(cache, event, ...)
                local duration = select(2, GetRuneCooldown(cache.runeIndex))
                return { duration }
            end,
            color = { r = 0.5, g = 0.5, b = 0.5 }
        }
    },
    bottom = {
        enabled_dependencies = { "currentPower", "maxPower" },
        enabled = function(cache, event, ...) 
            return true, current ~= maxHealth or UnitAffectingCombat("player")
        end,
        currentPower_dependencies = { "UNIT_HEALTH_FREQUENT" },
        currentPower = function(cache, event, ...) 
            if event == "UNIT_HEALTH_FREQUENT" and select(1, ...) ~= "player" then
                return false
            end

            return true, UnitHealth("player") 
        end,
        maxPower_dependencies = { "UNIT_MAXHEALTH" },
        maxPower = function(cache, event, ...) 
            if event == "UNIT_MAXHEALTH" and select(1, ...) ~= "player" then
                return false
            end

            return UnitHealthMax("player") 
        end,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Cloud",
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                return (("%%.%df"):format(2):format((currentHealth / maxHealth)) * 100) .. "%"
            end,
            xOffset = 65,
            yOffset = 3,
            size = 7
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local healthRatio = currentHealth / maxHealth
            return { r = 1.0 - (1.0 * healthRatio), g = 1.0 * healthRatio, b = 0.0}
        end
    }
}