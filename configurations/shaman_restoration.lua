PRD.configurations.shaman_restoration = {
    top = {
        currentPower_events = { "COMBAT_LOG_EVENT_UNFILTERED" },
        currentPower = function(cache, event, ...)
            if event == "FRAME_UPDATE" or event == "INITIAL" then
                if event == "INITIAL" then
                    cache.duration = 0
                    cache.expirationTime = 0
                    cache.count = 0
                end

                local name, _, count, _, duration, expirationTime = PRD:GetUnitAura("player", 53390)
            
                if name == nil then
                    cache.currentPower = 0
                    return true, 0, false
                end

                cache.duration = duration
                cache.expirationTime = expirationTime
                cache.count = count
                cache.currentPower = (expirationTime - GetTime()) / duration

                return true, cache.currentPower, count ~= 0
            elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and select(4, ...) == WeakAuras.myGUID and select(12, ...) == 53390 then  
                local subevent = select(2, ...)
                if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_APPLIED_DOSE" then
                    local count, _, duration, expirationTime = select(3, PRD:GetUnitAura("player", 53390))

                    cache.duration = duration
                    cache.expirationTime = expirationTime
                    cache.count = count
                    cache.currentPower = (expirationTime - GetTime()) / duration
                    return true, cache.currentPower, true
                elseif subevent == "SPELL_AURA_REMOVED" then
                    cache.duration = 0
                    cache.count = 0
                    cache.expirationTime = 0
                    cache.currentPower = 0
                    return true, 0, false
                end
            end

            return false
        end,
        maxPower = 1,
        text = {
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...)
                local currentStacks = cache.count == 0 and "" or cache.count .. ""
                local buffDuration = cache.duration == 0 and "" or (("%%.%df"):format(0)):format((cache.expirationTime - GetTime()))
                return true, currentStacks .. " " .. buffDuration
            end,
            size = 12,
            xOffset = -110,
            yOffset = -4
        },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            if cache.count > 1 then
                return true, { r = 0.0, g = 1.0, b = 0.25, a = 1.0 }
            end
            
            return true, { r = 0.0, g = 1.0, b = 1.0, a = 1.0 }
        end
    }
}