PRD.configurations.paladin_protection = {
    primary = {
        currentPower_events = { "SPELL_UPDATE_CHARGES" },
        currentPower = function(cache, event, ...)
            local currentCharges, maxCharges, start, duration = GetSpellCharges(53600)
            cache.start = start
            cache.duration = duration
            cache.currentPower = currentCharges == maxCharges and currentCharges or currentCharges + ((GetTime() - start) / duration)

            return true, cache.currentPower, currentCharges ~= maxCharges
        end,
        maxPower_events = { "SPELL_UPDATE_CHARGES" },
        maxPower = function(cache, event , ...) 
            cache.maxPower = select(2, GetSpellCharges(53600))
            return true, cache.maxPower
        end,
        color =  { r = 0.95, g = 0.91, b = 0.6, a = 1.0 },
        tickMarks = {
            offsets = { 1, 2 }
        },
        text = {
            enabled_dependencies = { "currentPower", "maxPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower ~= cache.maxPower
            end,
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                return true, (("%%.%df"):format(0)):format((cache.duration - (GetTime() - cache.start)))
            end,
        }
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event, ...)
                local resourceValues = {}
                
                local spellCost = GetSpellPowerCost(19750)[1].cost
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
                local spellCost = GetSpellPowerCost(19750)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end

                return true, math.floor(cache.currentPower / spellCost)
            end,
            xOffset = -65,
            yOffset = 3,
            size = 10
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("PALADIN")
            local percent = cache.currentPower / cache.maxPower
            return true, { r = r, g = g, b = b * percent }
        end
    }
}