PRD.configurations.shaman_enhancement = {
    primary = {
        color = function(cache, event, ...)
            local r, g, b =  GetClassColor(select(2, UnitClass("player")))
            return true, { r = r, g = g, b = b }
        end,
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "INITIAL" then
                cache.currentPower = 0
            elseif event == "UNIT_AURA" and select(1, ...) ~= "player" then  
                return false
            end

            local name, _, count, _ = PRD:GetUnitBuff("player", 187881)
        
            if name == nil then
                cache.currentPower = 0
                return true, 0, false
            end

            cache.currentPower = count

            return true, cache.currentPower, count ~= 0
        end,
        maxPower = 10,
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        },
        tickMarks = {
            offsets = { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
            color = { r = 1.0, g = 1.0, b = 1.0}
        }
    },
    top = {
        powerType = Enum.PowerType.Mana,
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
            xOffset = -140,
            yOffset = -5,
            size = 15
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local percent = cache.currentPower / cache.maxPower
            return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}