PRD.configurations.priest_discipline = {
    primary = {
        text = {
            value = function(currentPower, maxPower)
                return (("%%.%df"):format(2):format((currentPower / maxPower)) * 100) .. "%"
            end
        }
    },
    top = {
        currentPower = function()
            local currentCharges, maxCharges, start, duration = GetSpellCharges(194509)
            
            if currentCharges == maxCharges then
                return maxCharges
            end
            
            return currentCharges + ((GetTime() - start) / duration)
        end,
        maxPower = 2,
        text = {
            value = function(current, maxPower)
                local current, maxCharges, start, duration = GetSpellCharges(194509)
                local currentCharges = current == 0 and " " or current
                local cooldown = current == maxCharges and "" or (("%%.%df"):format(0)):format((duration - (GetTime() - start)))
                return currentCharges .. " " .. cooldown
            end,
            size = 12,
            xOffset = -110,
            yOffset = -4
        },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Glamour7",
        color = function(currentPower, maxPower)
            local currentCharges, maxCharges, start, duration = GetSpellCharges(194509)
            
            if currentCharges == maxCharges then
                return { r = 1.0, g = 0.9, b = 0.66 }
            elseif currentCharges == 1 then
                return { r = 1.0, g = 0.75, b = 0.50 }
            end
            
            return { r = 1.0, g = 0.25, b = 0.15 }
        end,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = { 1 }
        }
    }
}