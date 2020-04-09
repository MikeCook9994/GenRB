PRD.configurations.mage_arcane = {
    top = {
        powerType = Enum.PowerType.ArcaneCharges,
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            local name = PRD:GetUnitBuff("player", 264774)

            if name ~= nil then
                return true, { r = 0.75, g = 0.3, b = 1.0 }
            end

            return true, { r = 0.3, g = 0.3, b = 1.0 }
        end,
        tickMarks = {
            offsets = { 1, 2, 3 }
        }
    },
    primary = {
        color = { r = 0.5, g = 0.0, b = 1.0 }
    }
}