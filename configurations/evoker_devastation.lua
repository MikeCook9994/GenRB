PRD.configurations.evoker_devastation = {
    [1] = {
        heightWeight = 5,
        powerType = Enum.PowerType.Essence,
        color = function(cache, event, ...)
            local r, g, b =  GetClassColor("EVOKER")
            return true, { r = r, g = g, b = b }
        end,
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
        heightWeight = 1,
        powerType = Enum.PowerType.Mana,
        text = {
            enabled = false
        }
    }
}