PRD.configurations.priest_discipline = {
    primary = {
        color = { r = 1.0, g = 1.0, b = 1.0 }
    },
    top = {
        currentPower_events = { "SPELL_UPDATE_CHARGES" },
        currentPower = function(cache, event, ...)
            local currentCharges, maxCharges, start, duration = GetSpellCharges(194509)
            cache.currentCharges = currentCharges
            cache.start = start
            cache.duration = duration
            cache.currentPower = currentCharges == maxCharges and currentCharges or currentCharges + ((GetTime() - start) / duration)

            return true, cache.currentPower, currentCharges ~= maxCharges
        end,
        maxPower = 2,
        text = {
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...)
                local currentCharges = cache.currentCharges == 0 and " " or cache.currentCharges
                local cooldown = cache.currentCharges == 2 and "" or (("%%.%df"):format(0)):format((cache.duration - (GetTime() - cache.start)))
                return true, currentCharges .. " " .. cooldown
            end,
            size = 10,
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