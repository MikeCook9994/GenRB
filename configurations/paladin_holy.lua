PRD.configurations.paladin_holy = {
    [1] = {
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
    [0] = {
        powerType = Enum.PowerType.Mana,
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("PALADIN")
            local percent = cache.currentPower / cache.maxPower
            return true, { r = r, g = g, b = b * percent }
        end,
        value_dependencies = { "currentPower", "maxPower" },
        value = function(cache, event, ...)
            return true, string.format("%.0f%%", (cache.currentPower / cache.maxPower) * 100)
        end,
    }
}