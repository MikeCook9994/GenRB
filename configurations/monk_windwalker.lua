PRD.configurations.monk_windwalker = {
    [2] = {
        heightWeight = 2,
        powerType = Enum.PowerType.Chi,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        text = {
            size = 25
        },
        tickMarks = {
            offsets = { 1, 2, 3, 4, 5 }
        }
    },
    [1] = {
        heightWeight = 4,
        powerType = Enum.PowerType.Energy
    }
    [0] = {
        heightWeight = 1,
        powerType = Enum.PowerType.Mana,
        color = function(cache, event, ...)
            local r, g, b =  GetClassColor("MONK")
            return true, { r = r, g = g, b = b }
        end,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event, ...)
                local resourceValues = {}
                
                local spellCost = GetSpellPowerCost(8004)[1].cost
                if (spellCost == 0) then
                    return true, resourceValues
                end
                
                local currentMaxTick = 0
                
                while currentMaxTick + spellCost < cache.maxPower do
                    currentMaxTick = currentMaxTick + spellCost
                    table.insert(resourceValues, currentMaxTick)
                end
                
                return true, resourceValues
            end
        },
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                local spellCost = GetSpellPowerCost(8004)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end

                return true, math.floor(cache.currentPower / spellCost)
            end,
            xOffset = -220,
            yOffset = 6,
            size = 16
        }
    }
}