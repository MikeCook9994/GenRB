local PRD = PRD

PRD.DefaultUpdateCurrentPowerHandler = function(cache, event, ...)
    if event == "UNIT_POWER_FREQUENT" and select(1, ...) ~= "player" then
        return false
    end

    cache.currentPower = UnitPower("player", cache.powerType)
    return true, cache.currentPower
end

PRD.DefaultUpdateMaxPowerHandler = function(cache, event, ...)
    if event == "UNIT_MAXPOWER" and select(1, ...) ~= "player" then
        return false
    end

    cache.maxPower = UnitPowerMax("player", cache.powerType)
    return true, cache.maxPower
end

PRD.DefaultUpdateColorHandler = function(cache, event, ...)
    return true, PowerBarColor[cache.powerType]
end

PRD.DefaultUpdateTextHandler = function(cache, event, ...)
    if (event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER") and select(1, ...) ~= "player" then
        return false
    end

    -- if it's mana power type, format as percent by default
    if cache.powerType == Enum.PowerType.Mana then
        return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
    end

    return true, cache.currentPower
end