PRD.configurations.evoker_preservation = {
    [1] = {
        heightWeight = 3,
        currentPower_events = { "UNIT_POWER_FREQUENT" },
        currentPower = function(cache, event, ...)
            if event == "UNIT_POWER_FREQUENT" and (select(1, ...) ~= "player" or select(2, ...) ~= "ESSENCE") then
                return false
            end

            cache.currentPower = UnitPower("player", Enum.PowerType.Essence)
            return true, cache.currentPower, cache.currentPower < cache.maxPower
        end,
        maxPower_events = { "UNIT_MAXPOWER" },
        maxPower = function(cache, event, ...)
            if event == "UNIT_POWER_FREQUENT" and (select(1, ...) ~= "player" or select(2, ...) ~= "ESSENCE") then
                return false
            end

            cache.maxPower = UnitPowerMax("player", Enum.PowerType.Essence)
            return true, cache.maxPower
        end,
        color = { r = 0.2, g = 0.58, b = 0.5 },
        tickMarks = {
            offsets_dependencies = { "maxPower" },
            offsets = function(cache, event, ...) 
                local offsets = { }

                for i = 1, cache.maxPower - 1, 1 do
                    table.insert(offsets, i)
                end

                return true, offsets
            end
        }
    },
    [0] = {
        heightWeight = 3,
        powerType = Enum.PowerType.Mana
    }
}