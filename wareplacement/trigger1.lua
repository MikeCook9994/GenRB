function(s, event, unit, arg1, arg2)
    if not s[""] then 
        local value, total = UnitPower("player") or 0,UnitPowerMax("player") or 1
        s[""] = {
            show = true,
            changed = true,
            progressType = "static",
            value = value,
            total = total,
            percent = Round(value/total*100),
            short = AbbreviateNumbers(value),
            type = UnitPowerType("player"),
            additionalProgress = {{},{},}
        }
    end
    if event == "UNIT_DISPLAYPOWER" or event == "LOAD" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" then
        
        s[""].type = UnitPowerType("player")
        s[""].value = UnitPower("player")
        s[""].total = UnitPowerMax("player")
        s[""].percent = Round(s[""].value/s[""].total*100)
        s[""].short = AbbreviateNumbers(s[""].value)
        s[""].changed = true
        
        aura_env.placeTicks()
        
    elseif event == "UNIT_POWER_FREQUENT" then
        local value = UnitPower("player")
        s[""].value = value
        s[""].short = AbbreviateNumbers(value)
        s[""].percent = Round(s[""].value/s[""].total*100)
        s[""].changed = true
        
    elseif event == "UNIT_MAXPOWER" then
        local value = UnitPower("player")
        s[""].value = value
        s[""].short = AbbreviateNumbers(value)
        s[""].total = UnitPowerMax("player")
        s[""].percent = Round(s[""].value/s[""].total*100)
        s[""].changed = true
        
    elseif event == "UNIT_SPELLCAST_START" then
        if aura_env.spells[arg2] then
            local incoming = type(aura_env.spells[arg2]) == "function" and aura_env.spells[arg2]() or aura_env.spells[arg2]
            s[""].additionalProgress[2] = {direction="forward", width=incoming}
            s[""].change = "(+"..AbbreviateNumbers(incoming)..")"
            s[""].changed = true
        else
            local cost
            local costTable = GetSpellPowerCost(arg2);
            if costTable then
                for _, costInfo in pairs(costTable) do
                    if costInfo.type == UnitPowerType("player") then
                        cost = costInfo.cost
                        break
                    end
                end
                if cost then
                    s[""].additionalProgress[1] = {direction="backward", width=cost}
                    s[""].change = "(-"..AbbreviateNumbers(cost)..")"
                    s[""].changed =  true
                end
            end
        end
        
    elseif event == "UNIT_SPELLCAST_STOP" then
        s[""].additionalProgress =  { {},{}, }
        s[""].change = ""
        s[""].changed = true
        
    end
    return true
end


