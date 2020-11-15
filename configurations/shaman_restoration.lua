PRD.configurations.shaman_restoration = {
    top = {
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "INITIAL" then
                cache.duration = 0
                cache.expirationTime = 0
                cache.count = 0
            elseif event == "UNIT_AURA" and select(1, ...) ~= "player" then  
                return false
            end

            local name, _, count, _, duration, expirationTime = PRD:GetUnitBuff("player", 53390)
        
            if name == nil then
                cache.duration = 0
                cache.expirationTime = 0
                cache.count = 0
                cache.currentPower = 0
                return true, 0, false
            end

            cache.duration = duration
            cache.expirationTime = expirationTime
            cache.count = count
            cache.currentPower = (expirationTime - GetTime()) / duration

            return true, cache.currentPower, count ~= 0
        end,
        maxPower = 1,
        text = {
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...)
                local currentStacks = cache.count == 0 and "" or cache.count .. ""
                local buffDuration = cache.duration == 0 and "" or (("%%.%df"):format(0)):format((cache.expirationTime - GetTime()))
                return true, currentStacks .. " " .. buffDuration
            end,
            xOffset = 100,
            yOffset = 5,
            size = 15
        },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            if cache.count > 1 then
                return true, { r = 0.0, g = 1.0, b = 0.25 }
            end
            
            return true, { r = 0.0, g = 1.0, b = 1.0 }
        end
    }
}