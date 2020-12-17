PRD.configurations.hunter_marksmanship = {
    primary = {
        tickMarks = {
            offsets = {
                arcane_shot = {
                    resourceValue = 20,
                    color = { r = 0.6, g = 0.4, b = 1.0 }
                },
                aimed_shot = {
                    resourceValue = 35,
                    color = { r = 0.2, g = 0.4, b = 1.0 }
                }
            }
        },
        prediction = {
            next_events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP" },
            next_dependencies = { "currentPower" },
            next = function(cache, event, ...)
                if event == "INITIAL" or ((event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") and select(1, ...) == "player") then
                    cache.predictedPower = 0
                    cache.predictedCastGenGain = 0
                    return true, 0
                elseif event == "UNIT_POWER_FREQUENT" then
                    local endTimeMs, _ = select(5, UnitCastingInfo("player"))
                    local remainingCastTime = 0

                    if endTimeMs ~= nil then
                        remainingCastTime = (endTimeMs / 1000) - GetTime()
                    else 
                        endTimeMs = select(5, UnitChannelInfo("player"))

                        if endTimeMs ~= nil then
                            remainingCastTime = (endTimeMs / 1000) - GetTime()
                        end
                    end
                    
                    cache.predictedPower = cache.currentPower + (cache.predictedCastGenGain or 0) + (remainingCastTime * GetPowerRegen())
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
                    
                    return true, cache.predictedPower
                end

                if select(1, ...) == "player" then
                    local endTimeMs = 0
                    if event == "UNIT_SPELLCAST_START" then
                        endTimeMs = select(5, UnitCastingInfo("player"))
                    else
                        endTimeMs = select(5, UnitChannelInfo("player"))
                    end

                    local remainingCastTime = (endTimeMs / 1000) - GetTime()
                    local SpellId = select(3, ...)
    
                    if SpellId == 56641 then -- Steady Shot
                        cache.predictedCastGenGain = 10
                    end 

                    cache.predictedPower = cache.currentPower + cache.predictedCastGenGain + remainingCastTime * GetPowerRegen()
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
                    
                    return true, cache.predictedPower
                end

                return false
            end
        },
    }
}