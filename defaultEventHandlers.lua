local function DefaultUpdateCurrentPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.currentPower = UnitPower("player", cache.powerType)
        return true, cache.currentPower
    end

    return false
end

local function DefaultUpdateMaxPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.maxPower = UnitPowerMax("player", cache.powerType)
        return true, cache.maxPower
    end

    return false
end

local function DefaultUpdateTextHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then
        -- if it's mana power type, format as percent by default
        if cache.powerType == Enum.PowerType.Mana then
            return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
        end

        return true, cache.currentPower
    end

    return false, cache.currentPower
end