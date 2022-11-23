PRD.configurations.mage_arcane = {
    [1] = {
        heightWeight = 1,
        powerType = Enum.PowerType.ArcaneCharges,
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            local name = PRD:GetPlayerBuff(264774)

            if name ~= nil then
                return true, { r = 0.75, g = 0.3, b = 1.0 }
            end

            return true, { r = 0.3, g = 0.3, b = 1.0 }
        end,
        tickMarks = {
            offsets = { 1, 2, 3 }
        }
    },
    [0] = {
        heightWeight = 5,
        color = { r = 0.5, g = 0.0, b = 1.0 },
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end,
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                local spellCost = GetSpellPowerCost(30451)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end

                return true, math.floor(cache.currentPower / spellCost)
            end
        },
    }
}