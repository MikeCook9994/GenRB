PRD.configurations.deathknight = {
    top = {
        enabled = function(current, max)
            return current ~= 0 or UnitAffectingCombat("player")
        end,
        powerType = Enum.PowerType.RunicPower,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        text = {
            xOffset = -105,
            yOffset = -4,
            size = 13
        },
        tickMarks = {
            offsets = {
                heart_strike = {
                    resourceValue = function() 
                        return (select(1, PRD:GetUnitAura('player', 219788)) ~= nil) and 45 or 40
                    end,
                    color = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 }
                },
            }
        }
    },
    primary = {
        powerType = Enum.PowerType.Runes,
        text = {
            enabled = function(elapsedCooldown, duration)
                return elapsedCooldown < duration and duration - elapsedCooldown < duration
            end,
            value = function(elapsedCooldown, duration) 
                return (("%%d"):format(0):format(duration - elapsedCooldown))
            end,
            color = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
            size = 12
        },
        color = function(elapsedCooldown, duration)
            local r, g, b, a = GetClassColor("DEATHKNIGHT")
            return { r = r, g = g, b = b, a = a }
        end
    },
    bottom = {
        enabled = function(current, maxHealth) 
            return current ~= maxHealth or UnitAffectingCombat("player")
        end,
        currentPower = function() return UnitHealth("player", Enum.PowerType.SoulShards, true) end,
        maxPower = function() return UnitHealthMax("player", Enum.PowerType.SoulShards, true) end,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Cloud",
        text = {
            value = function(currentHealth, maxHealth) 
                return (("%%.%df"):format(2):format((currentHealth / maxHealth)) * 100) .. "%"
            end,
            xOffset = 105,
            yOffset = 3,
            size = 12
        },
        color = function(currentHealth, maxHealth)
            local healthRatio = currentHealth / maxHealth
            return { r = 1.0 - (1.0 * healthRatio), g = 1.0 * healthRatio, b = 0.0, a = 1.0}
        end
    }
}