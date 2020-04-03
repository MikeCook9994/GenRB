PRD.configurations.priest_discipline = {
    primary = {
        color = { r = 1.0, g = 1.0, b = 1.0 }
    },
    top = {
        currentPower_events = { "UNIT_SPELLCAST_SUCCEEDED" },
        currentPower = function(cache, event, ...)
            if event == "INITIAL" or event == "FRAME_UPDATE" or (event == "UNIT_SPELLCAST_SUCCEEDED" and select(1, ...) == "player" and select(3, ...) == 194509) then
                local currentCharges, _, start, duration = GetSpellCharges(194509)
                PRD:DebugPrint(event, select(3, ...))
                PRD:DebugPrint("current", currentCharges)
                PRD:DebugPrint("start", start)
                PRD:DebugPrint("duration", duration)

                cache.currentCharges = currentCharges
                cache.start = start
                cache.duration = duration

                if cache.currentCharges == 2 then
                    cache.currentPower = 2
                    return true, 2, false
                end

                cache.currentPower = currentCharges + ((GetTime() - start) / duration)
                PRD:DebugPrint("currentPower", cache.currentPower)
                return true, cache.currentPower, true
            end

            return false
        end,
        maxPower = 2,
        text_dependencies = { "currentPower" },
        text = {
            value = function(cache, event, ...)
                local currentCharges = cache.currentCharges == 0 and " " or cache.currentCharges
                local cooldown = cache.currentCharges == 2 and "" or (("%%.%df"):format(0)):format((cache.duration - (GetTime() - cache.start)))
                return true, currentCharges .. " " .. cooldown
            end,
            size = 8,
            xOffset = -65,
            yOffset = -3
        },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Glamour7",
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            if cache.currentCharges == 2 then
                return true, { r = 1.0, g = 0.9, b = 0.66 }
            elseif cache.currentCharges == 1 then
                return true, { r = 1.0, g = 0.75, b = 0.50 }
            end
            
            return true, { r = 1.0, g = 0.25, b = 0.15 }
        end,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = { 1 }
        }
    }
}