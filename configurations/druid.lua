PRD.configurations.druid = {
    primary = {
        powerType_events = { "UNIT_AURA" },
        powerType = function(cache, event, ...)
            if event == "INITIAL" or (event == "UNIT_AURA" and select(1, ...) == "player") then
                if PRD:GetUnitBuff("player", 24858) ~= nil then
                    cache.stanceId = 24858
                    cache.powerType = Enum.PowerType.LunarPower
                    return true, Enum.PowerType.LunarPower
                elseif PRD:GetUnitBuff("player", 5487) ~= nil then
                    cache.stanceId = 5487
                    cache.powerType = Enum.PowerType.Rage
                    return true, Enum.PowerType.Rage
                elseif PRD:GetUnitBuff("player", 768) ~= nil then
                    cache.stanceId = 768
                    cache.powerType = Enum.PowerType.Energy
                    return true, Enum.PowerType.Energy
                elseif PRD:GetUnitBuff("player", 197625) ~= nil then
                    cache.stanceId = 197625
                    cache.powerType = Enum.PowerType.Mana
                    return true, Enum.PowerType.Mana
                end

                cache.stanceId = nil
                cache.powerType = Enum.PowerType.Mana
                return true, Enum.PowerType.Mana
            end
            
            return false
        end,
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...) 
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        },
        prediction = {
            enabled_dependencies = { "powerType" },
            enabled = function(cache, event, ...)
                return true, cache.stanceId == 24858
            end,
            color = { 
                r = PowerBarColor[Enum.PowerType.LunarPower].r, 
                g = PowerBarColor[Enum.PowerType.LunarPower].g,
                b = PowerBarColor[Enum.PowerType.LunarPower].b
            },
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
                elseif event == "UNIT_AURA" then
                    return false
                end

                if select(1, ...) == "player" then
                    cache.predictedPowerGain = 0
                    local SpellCast = select(3, ...)
    
                    if SpellCast == 190984 then -- SW
                        cache.predictedPowerGain = 8
                    elseif SpellCast == 194153 then -- LS
                        cache.predictedPowerGain = 12
                    elseif SpellCast == 202347 then -- SF
                        cache.predictedPowerGain = 8
                    elseif SpellCast == 274281 then -- New Moon
                        cache.predictedPowerGain = 10
                    elseif SpellCast == 274282 then -- Half Moon
                        cache.predictedPowerGain = 20
                    elseif SpellCast == 274283 then -- Full Moon
                        cache.predictedPowerGain = 40
                    end 
    
                    cache.predictedPower = cache.currentPower + cache.predictedPowerGain   
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)
    
                    return true, cache.predictedPower
                end

                return false
            end
        },
        tickMarks = {
            color = { r = 1.0, g = 1.0, b = 1.0},
            offsets = { 
                iron_fur_shred_starsurge = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled_dependencies = { "powerType" },
                    enabled = function(cache, event, ...)
                        if event == "INITIAL" or event == "PLAYER_SPECIALIZATION_CHANGED" then
                            cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                        end

                        local balanceWithGuardianAffinity = (cache.specializationId == 102) and select(4, GetTalentInfo(3, 2, 1))
                        local feralWithGuardianAffinity = (cache.specializationId == 103) and select(4, GetTalentInfo(3, 2, 1))
                        local restorationWithGuardianAffinity = (cache.specializationId == 105) and select(4, GetTalentInfo(3, 3, 1))
                        local guardianSpec = cache.specializationId == 104
                        local bearFormWithSpenders = cache.stanceId == 5487 and (balanceWithGuardianAffinity or feralWithGuardianAffinity or restorationWithGuardianAffinity or guardianSpec)
                        
                        local balanceWithFeralAffinity = (cache.specializationId == 102) and select(4, GetTalentInfo(3, 1, 1))
                        local guardianWithFeralAffinity = (cache.specializationId == 105) and select(4, GetTalentInfo(3, 2, 1))
                        local restorationWithFeralAffinity = (cache.specializationId == 104) and select(4, GetTalentInfo(3, 2, 1))
                        local feralSpec = cache.specializationId == 103
                        local catFormWithComboPoints = cache.stanceId == 768 and (balanceWithFeralAffinity or guardianWithFeralAffinity or restorationWithFeralAffinity or feralSpec)

                        local balanceSpecWithMoonkinForm = (cache.specializationId == 102) and (cache.stanceId == 24858)
                        return true, bearFormWithSpenders or catFormWithComboPoints or balanceSpecWithMoonkinForm
                    end,
                    resourceValue = 40,
                    color = { r = 1.0, g = 1.0, b = 1.0}     
                },
                frenzied_regen = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled_dependencies = { "powerType" },
                    enabled = function(cache, event, ...)
                        if event == "INITIAL" or event == "PLAYER_SPECIALIZATION_CHANGED" then
                            cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                        end
                        
                        local balanceWithGuardianAffinity = (cache.specializationId == 102) and select(4, GetTalentInfo(3, 2, 1))
                        local feralWithGuardianAffinity = (cache.specializationId == 103) and select(4, GetTalentInfo(3, 2, 1))
                        local restorationWithGuardianAffinity = (cache.specializationId == 105) and select(4, GetTalentInfo(3, 3, 1))
                        local guardianSpec = cache.specializationId == 104
                        return true, (cache.stanceId == 5487) and (balanceWithGuardianAffinity or feralWithGuardianAffinity or restorationWithGuardianAffinity or guardianSpec)
                    end,
                    resourceValue = 10,
                    color = { r = 1.0, g = 1.0, b = 1.0}     
                }
            }
        },
    },
    top = {
        powerType = Enum.PowerType.ComboPoints,
        enabled_events = { "PLAYER_TALENT_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "UNIT_AURA" },
        enabled = function(cache, event, ...)
            if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "INITIAL" then
                cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
            end

            if (event == "UNIT_AURA" and select(1, ...) == "player") or event == "INITIAL" then
                cache.catFormActive = PRD:GetUnitBuff("player", 768) ~= nil
            end

            local balanceWithFeralAffinity = (cache.specializationId == 102) and select(4, GetTalentInfo(3, 1, 1))
            local guardianWithFeralAffinity = (cache.specializationId == 104) and select(4, GetTalentInfo(3, 2, 1))
            local restorationWithFeralAffinity = (cache.specializationId == 105) and select(4, GetTalentInfo(3, 2, 1))
            local feralSpec = cache.specializationId == 103
            return true, cache.catFormActive and (feralSpec or balanceWithFeralAffinity or guardianWithFeralAffinity or restorationWithFeralAffinity)
        end,
        color = { r = 1.0, g = 0.65, b = 0.0 },
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = { 1, 2, 3, 4 }
        },
        text = {
            size = 7,
            yOffset = -3,
            xOffset = -65
        }
    },
    top_left = {
        enabled_events = { "UNIT_AURA" },
        enabled = function(cache, event, ...)
            if event == "INITIAL" or (event == "UNIT_AURA" and select(1, ...) == "player") then
                return true, (select(1, PRD:GetUnitBuff("player", 24858)) ~= nil) or (select(1, PRD:GetUnitBuff("player", 197625)) ~= nil)
            end

            return false
        end,
        color = { r = 1.0, g = 1.0, b = 0.0},
        tickMarks = {
            offsets = {
                zero = {
                    color = { r = 0.5, g = 0.5, b = 0.5},
                    resourceValue = 0
                },
                one = {
                    color = { r = 1.0, g = 1.0, b = 1.0},
                    resourceValue = 1
                },
                two = {
                    color = { r = 1.0, g = 1.0, b = 1.0},
                    resourceValue = 2
                }
            }
        },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Perl",
        maxPower = 3,
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                return false
            end

            local name, _, count, _, duration, expirationTime = PRD:GetUnitBuff("player", 164545)
        
            if name == nil then
                cache.currentPower = 0
                return true, 0, false
            end

            cache.currentPower = (count - 1) + ((expirationTime - GetTime()) / duration)

            return true, cache.currentPower, count ~= 0
        end,
        text = {
            enabled = false
        },
    },
    top_right = {
        enabled_events = { "UNIT_AURA" },
        enabled = function(cache, event, ...)
            if event == "INITIAL" or (event == "UNIT_AURA" and select(1, ...) == "player") then
                return true, (select(1, PRD:GetUnitBuff("player", 24858)) ~= nil) or (select(1, PRD:GetUnitBuff("player", 197625)) ~= nil)
            end

            return false
        end,
        color = { r = 1.0, g = 0.0, b = 1.0},
        tickMarks = {
            offsets = {
                zero = {
                    color = { r = 0.5, g = 0.5, b = 0.5},
                    resourceValue = 0
                },
                one = {
                    color = { r = 1.0, g = 1.0, b = 1.0},
                    resourceValue = 1
                },
                two = {
                    color = { r = 1.0, g = 1.0, b = 1.0},
                    resourceValue = 2
                }
            }
        },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Perl",
        maxPower = 3,
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                return false
            end

            local name, _, count, _, duration, expirationTime = PRD:GetUnitBuff("player", 164547)
        
            if name == nil then
                cache.currentPower = 0
                return true, 0, false
            end

            cache.currentPower = (count - 1) + ((expirationTime - GetTime()) / duration)

            return true, cache.currentPower, count ~= 0
        end,
        text = {
            enabled = false
        },
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        enabled_events = { "UNIT_AURA", "PLAYER_SPECIALIZATION_CHANGED" },
        enabled = function(cache, event, ...)
            if event == "INITIAL" or event == "PLAYER_SPECIALIZATION_CHANGED" then 
                cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
            end

            if PRD:GetUnitBuff("player", 24858) ~= nil then
                cache.stanceId = 24858
                return true, true
            elseif PRD:GetUnitBuff("player", 5487) ~= nil then
                cache.stanceId = 5487
                return true, true
            elseif PRD:GetUnitBuff("player", 768) ~= nil then
                cache.stanceId = 768
                return true, true
            elseif PRD:GetUnitBuff("player", 197625) ~= nil then
                cache.stanceId = 197625
                if cache.specializationId == 102 then
                    return true, true
                end

                return true, false
            end

            return true, false
        end,
        tickMarks = {
            enabled_dependencies = { "enabled" },
            enabled = function(cache, event, ...)
                return true, cache.specializationId ~= 105
            end,
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets_dependencies = { "maxPower" },
            offsets = function(cache, event, ...)
                local resourceValues = { }

                if event == "UNIT_MAXPOWER" then
                    cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                end

                if cache.specializationId == 105 then
                    if event == "INITIAL" then
                        return true, resourceValues
                    end

                    return false
                end
                
                local healingSpellCost = GetSpellPowerCost(8936)[1].cost
                local currentMaxTick = 0
                
                while currentMaxTick + healingSpellCost <= cache.maxPower do
                    currentMaxTick = currentMaxTick + healingSpellCost
                    table.insert(resourceValues, currentMaxTick)
                end

                return true, resourceValues
            end
        },
        text = {
            value_dependencies = { "currentPower", "maxPower", "enabled" },
            value = function(cache, event, ...)
                if cache.specializationId == 105 then
                    return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
                end

                if select(1, PRD:GetUnitBuff("player", 69369)) ~= nil then
                    return true, "Free"
                end

                local healingSpellCost = GetSpellPowerCost(8936)[1].cost
                return true, math.floor(cache.currentPower / healingSpellCost)
            end,
            xOffset = -65,
            yOffset = 3,
            size = 7
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local percent = cache.currentPower / cache.maxPower
            return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}