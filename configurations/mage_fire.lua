PRD.configurations.mage_fire = {
    primary = {
        currentPower_events = { "UNIT_SPELLCAST_SUCCEEDED", "PLAYER_TALENT_UPDATE" },
        currentPower = function(cache, event, ...)
            if event == "UNIT_SPELLCAST_SUCCEEDED" and (select(1, ...) ~= "player" or select(3, ...) ~= 108853) then
                return false
            end

            local currentCharges, maxCharges, start, duration = GetSpellCharges(108853)
            cache.start = start
            cache.duration = duration

            PRD:DebugPrint("current charges", currentCharges)
            PRD:DebugPrint("max charges", maxCharges)
            PRD:DebugPrint("start", start)
            PRD:DebugPrint("duration", duration)

            cache.currentPower = currentCharges == maxCharges and maxCharges or currentCharges + ((GetTime() - cache.start) / cache.duration)
            PRD:DebugPrint("curent power", cache.currentPower)
            return true, cache.currentPower, cache.currentPower ~= cache.maxPower
        end,
        maxPower_events = { "PLAYER_TALENT_UPDATE" },
        maxPower = function(cache, event , ...) 
            return true, select(2, GetSpellCharges(108853))
        end,
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                if cache.currentPower == cache.maxPower then
                    return true, ""
                end

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
                local maxCharges = select(2, GetSpellCharges(108853))
                local offsets = {}

                for i = 1, maxCharges - 1, 1 do
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
                
                local healingSpellCost = GetSpellPowerCost(30449)[1].cost
                local currentMaxTick = 0
                
                while currentMaxTick + healingSpellCost < cache.maxPower do
                    currentMaxTick = currentMaxTick + healingSpellCost
                    table.insert(resourceValues, currentMaxTick)
                end
                
                return true, resourceValues
            end
        },
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                local castCost = GetSpellPowerCost(30449)[1].cost
                return true, math.floor(cache.currentPower / castCost)
            end,
            xOffset = -65,
            yOffset = 3,
            size = 8
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("MAGE")
            local percent = cache.currentPower / cache.maxPower
            return true, { r = r * (1 - percent), g = g, b = b * percent }
        end
    }
}