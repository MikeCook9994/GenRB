PRD.configurations.mage_frost = {
    [1] = {
        heightWeight = 5
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "UNIT_AURA" and select(1, ...) ~= "player" then  
                return false
            end

            local name, _, count, _, duration, expirationTime = PRD:GetPlayerBuff(205473)
        
            if name == nil then
                cache.currentPower = 0
                return true, 0, false
            end

            cache.currentPower = count

            return true, cache.currentPower
        end,
        maxPower = 5,
        color = { r = 0.0, g = 0.75, b = 1.0 },
        tickMarks = {
            offsets = { 1, 2, 3, 4 }
        }
    },
    [0] = {
        heightWeight = 1
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
            xOffset = -220,
            yOffset = 6,
            size = 16
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("MAGE")
            local percent = cache.currentPower / cache.maxPower
            return true, { r = r * (1 - percent), g = g, b = b * percent }
        end
    }
}