PRD.configurations.paladin_holy = {
    primary = {
        powerType = Enum.PowerType.HolyPower,
        color =  { r = 0.95, g = 0.91, b = 0.6, a = 1.0 },
        tickMarks = {
            offsets = { 1, 2, 3, 4 }
        },
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        }
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("PALADIN")
            local percent = cache.currentPower / cache.maxPower
            return true, { r = r, g = g, b = b * percent }
        end
    },
    top = {
        currentPower_events = { "UNIT_HEALTH" },
        currentPower = function(cache, event, ...) 
            if event == "UNIT_HEALTH" and select(1, ...) ~= "player" then
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
            xOffset = 140,
            yOffset = -5,
            size = 15
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local healthRatio = cache.currentPower / cache.maxPower
            return true, { r = 1.0 - healthRatio, g = healthRatio, b = 0.0 }
        end
    }
}