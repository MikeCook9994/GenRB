PRD.configurations.priest_discipline = {
    primary = {
        color = { r = 1.0, g = 1.0, b = 1.0 }
    },
    top = {
        currentPower_events = { "UNIT_SPELLCAST_SUCCEEDED" },
        currentPower = function(cache, event, ...)
            if event == "UNIT_SPELLCAST_SUCCEEDED" and (select(1, ...) ~= "player" or select(3, ...) ~= 194509) then
                return false
            end

            PRD:DebugPrint("FRAME_UPDATE")
            local currentCharges, _, start, duration = GetSpellCharges(194509)

            cache.currentCharges = currentCharges
            cache.start = start
            cache.duration = duration

            if event == "UNIT_SPELLCAST_SUCCEEDED" then
                return true, cache.currentPower, true
            elseif cache.currentCharges == 2 then
                cache.currentPower = 2
                return true, 2, false
            end

            cache.currentPower = currentCharges + ((GetTime() - start) / duration)
            return true, cache.currentPower, true
        end,
        maxPower = 2,
        text = {
            value_dependencies = { "currentPower" },
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