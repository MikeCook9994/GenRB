PRD.configurations.mage_fire = {
    primary = {
        currentPower_events = { "SPELL_UPDATE_CHARGES" },
        currentPower = function(cache, event, ...)
            local currentCharges, maxCharges, start, duration = GetSpellCharges(108853)
            cache.start = start
            cache.duration = duration
            cache.currentPower = currentCharges == maxCharges and currentCharges or currentCharges + ((GetTime() - start) / duration)

            return true, cache.currentPower, currentCharges ~= maxCharges
        end,
        maxPower_events = { "SPELL_UPDATE_CHARGES" },
        maxPower = function(cache, event , ...) 
            cache.maxPower = select(2, GetSpellCharges(108853))
            return true, cache.maxPower
        end,
        text = {
            enabled_dependencies = { "currentPower", "maxPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower ~= cache.maxPower
            end,
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                return true, (("%%.%df"):format(0)):format((cache.duration - (GetTime() - cache.start)))
            end,
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...) 
            if cache.currentPower == cache.maxPower then
                return true, { r = 1.0, g = 0.25, b = 0.0 }
            elseif cache.currentPower + 1 >= cache.maxPower then
                return true, { r = 0.75, g = 0.125, b = 0.0 }
            elseif cache.currentPower > 1 then
                return true, { r = 0.5, g = 0.125, b = 0.0 }
            else
                return true, { r = 0.5, g = 0.0, b = 0.0 }
            end
        end,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event , ...) 
                local offsets = {}

                for i = 1, cache.maxPower - 1, 1 do
                    table.insert(offsets, i)
                end

                return true, offsets
            end
        }
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event, ...)
                local resourceValues = {}
                
                local spellCost = GetSpellPowerCost(30449)[1].cost
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
                local spellCost = GetSpellPowerCost(30449)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end

                return true, math.floor(cache.currentPower / spellCost)
            end,
            xOffset = -100,
            yOffset = 5,
            size = 15
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("MAGE")
            local percent = cache.currentPower / cache.maxPower
            return true, { r = r * (1 - percent), g = g, b = b * percent }
        end
    }
}