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
            next_events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP" },
            next_dependencies = { "currentPower" },
            next = function(cache, event, ...)
                if event == "INITIAL" or (event == "UNIT_SPELLCAST_STOP" and select(1, ...) == "player") then
                    cache.predictedPower = cache.currentPower
                    cache.predictedPowerGain = 0
                    return true, cache.currentPower
                elseif event == "UNIT_POWER_FREQUENT" then
                    cache.predictedPower = cache.currentPower + (cache.predictedPowerGain or 0)
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
                    
                    return true, cache.predictedPower
                end

                if select(1, ...) == "player" then
                    cache.predictedPowerGain = 0                    
                    local SpellCast = select(3, ...)
    
                    if SpellCast == 56641 then --LB
                        cache.predictedPowerGain = 10
                    end 
                    
                    cache.predictedPower = cache.currentPower + cache.predictedPowerGain   
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
                    
                    return true, cache.predictedPower
                end

                return false
            end
        },
    }
}