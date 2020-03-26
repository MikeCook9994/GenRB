aura_env.specConfigurations.priest_shadow = {
    primary = {
        powerType = Enum.PowerType.Insanity,
        text = {
            value = function(currentPower, maxPower)
                local vfname, _, vfcount, _ = WA_GetUnitAura("player", 194249)
                local liname, _, licount, _ = WA_GetUnitAura("player", 197937)

    
                if vfname ~= nil then
                    return vfcount .. '                 ' .. currentPower
                elseif liname ~= nil then
                    return licount .. '                 ' .. currentPower
                end
                
                return currentPower
            end,
            xOffset = -40,
        },
        tickMarks = {
            color = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
            offsets = {
                voidForm = {
                    resourceValue = function() 
                        return select(4, GetTalentInfo(7, 1, 1)) and 60 or 90                        
                    end,
                }
            }
        },
        prediction = {
            color = function(predictedPower, maxPower) 
                if (predictedPower >= (select(4, GetTalentInfo(7, 1, 1)) and 60 or 90)) and WA_GetUnitAura("player", 194249) == nil then
                    return { r = 1.0, g = 1.0, b = 1.0, a = 0.5}
                end
                
                local powerTypeColor = PowerBarColor[Enum.PowerType.Insanity]
                return { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, a = 0.5 } 
            end,
            next = function(currentPower, maxPower)
                local predictedPowerGain = 0
                
                local SpellCast = UnitCastingInfo('player')    
                
                if select(1, SpellCast) == GetSpellInfo(205351) then -- SW: Voidas
                    predictedPowerGain = 15
                elseif select(1, SpellCast) == GetSpellInfo(8092) then -- Mind Blast 
                    if select(4, GetTalentInfo(1, 1, 1)) then
                        predictedPowerGain = 2.4
                    end
                    
                    predictedPowerGain = predictedPowerGain + 12
                elseif select(1, SpellCast) == GetSpellInfo(34914) then -- Vampric Touch
                    predictedPowerGain = 6
                elseif select(1, SpellCast) == GetSpellInfo(263346) then -- Dark Void
                    predictedPowerGain = 30
                elseif select(1, SpellCast) == GetSpellInfo(32375) then -- Mass Dispel
                    predictedPowerGain = 6
                end 
                
                if WA_GetUnitAura("player", 193223) ~= nil then
                    predictedPowerGain = predictedPowerGain * 2
                end
                
                if WA_GetUnitAura("player", 298357) ~= nil then
                    predictedPowerGain = predictedPowerGain * 2
                end
                
                local predictedPower = currentPower + predictedPowerGain or 0   
                predictedPower = math.max(predictedPower, 0)
                predictedPower = math.min(predictedPower, maxPower)
                
                return predictedPower
            end
        },
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5, a = 1.0 },
            offsets = function()
                local resourceValues = { }
                
                local maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
                local castCost = GetSpellPowerCost(186263)[1].cost
                local currentMaxTick = 0
                
                while currentMaxTick + castCost <= maxMana do
                    currentMaxTick = currentMaxTick + castCost
                    table.insert(resourceValues, currentMaxTick)
                end
                
                return resourceValues
            end
        },
        text = {
            value = function(currentPower, maxPower) 
                local castCost = GetSpellPowerCost(186263)[1].cost
                return math.floor(currentPower / castCost)
            end,
            xOffset = -110,
            yOffset = 5,
            size = 12
        },
        color = function(currentPower, maxPower)
            local percent = currentPower / maxPower
            return { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent, a = 1.0 }
        end
    }
}