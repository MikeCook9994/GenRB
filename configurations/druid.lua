PRD.configurations.druid = {
    [1] = {
        heightWeight = 5,
        powerType_events = { "UPDATE_SHAPESHIFT_FORM" },
        powerType = function(cache, event, ...)
            if event == "INITIAL" or (event == "UPDATE_SHAPESHIFT_FORM") then
                if PRD:GetUnitBuff("player", 24858) ~= nil then
                    if cache.powerType == Enum.PowerType.LunarPower then
                        return false
                    end
                    
                    cache.stanceId = 24858
                    cache.powerType = Enum.PowerType.LunarPower
                    return true, Enum.PowerType.LunarPower
                elseif PRD:GetUnitBuff("player", 5487) ~= nil then
                    if cache.powerType == Enum.PowerType.Rage then
                        return false
                    end

                    cache.stanceId = 5487
                    cache.powerType = Enum.PowerType.Rage
                    return true, Enum.PowerType.Rage
                elseif PRD:GetUnitBuff("player", 768) ~= nil then
                    if cache.powerType == Enum.PowerType.Energy then
                        return false
                    end

                    cache.stanceId = 768
                    cache.powerType = Enum.PowerType.Energy
                    return true, Enum.PowerType.Energy
                elseif PRD:GetUnitBuff("player", 197625) ~= nil then
                    if cache.powerType == Enum.PowerType.Mana then
                        return false
                    end
                    
                    cache.stanceId = 197625
                    cache.powerType = Enum.PowerType.Mana
                    return true, Enum.PowerType.Mana
                end

                if cache.powerType == Enum.PowerType.Mana then
                    return false
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
                elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_AURA" then
                    cache.predictedPower = cache.currentPower + (cache.predictedPowerGain or 0)
                    cache.predictedPower = math.max(cache.predictedPower, 0)
                    cache.predictedPower = math.min(cache.predictedPower, cache.maxPower)

                    return true, cache.predictedPower
                end

                if select(1, ...) == "player" then
                    cache.predictedPowerGain = 0
                    local SpellCast = select(3, ...)

                    if SpellCast == 190984 then -- Wrath
                        cache.predictedPowerGain = 6
                    elseif SpellCast == 194153 then -- Starfire
                        cache.predictedPowerGain = 8
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
                ironFur_shred = {
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

                        return true, bearFormWithSpenders or catFormWithComboPoints or balanceSpecWithMoonkinForm
                    end,
                    resourceValue = 40,
                    color = { r = 1.0, g = 1.0, b = 1.0}
                },
                starsurge_30 = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled_dependencies = { "powerType" },
                    enabled = function(cache, event, ...)
                        if event == "INITIAL" or event == "PLAYER_SPECIALIZATION_CHANGED" then
                            cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                        end

                        return true, (cache.specializationId == 102) and (cache.stanceId == 24858)
                    end,
                    resourceValue = 30,
                    color = { r = 1.0, g = 1.0, b = 1.0}
                },
                starsurge_60 = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled_dependencies = { "powerType" },
                    enabled = function(cache, event, ...)
                        if event == "INITIAL" or event == "PLAYER_SPECIALIZATION_CHANGED" then
                            cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                        end

                        return true, (cache.specializationId == 102) and (cache.stanceId == 24858)
                    end,
                    resourceValue = 60,
                    color = { r = 1.0, g = 1.0, b = 1.0}
                },
                starsurge_90 = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled_dependencies = { "powerType" },
                    enabled = function(cache, event, ...)
                        if event == "INITIAL" or event == "PLAYER_SPECIALIZATION_CHANGED" then
                            cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                        end

                        return true, (cache.specializationId == 102) and (cache.stanceId == 24858)
                    end,
                    resourceValue = 90,
                    color = { r = 1.0, g = 1.0, b = 1.0}
                },
                starfall = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled_dependencies = { "powerType" },
                    enabled = function(cache, event, ...)
                        if event == "INITIAL" or event == "PLAYER_SPECIALIZATION_CHANGED" then
                            cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                        end

                        return true, (cache.specializationId == 102) and (cache.stanceId == 24858)
                    end,
                    resourceValue = 50,
                    color = { r = 1.0, g = 1.0, b = 1.0}
                },
                frenziedRegen = {
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
    [2] = {
        heightWeight = 1,
        powerType = Enum.PowerType.ComboPoints,
        enabled_events = { "UPDATE_SHAPESHIFT_FORM" },
        enabled = function(cache, event, ...)
            if event == "INITIAL" then
                cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                cache.formId = GetShapeshiftForm()
            end

            local specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
            local formId = GetShapeshiftForm()

            local isShowing = cache.specializationId == 103 or cache.formId == 2
            local shouldShow = specializationId == 103 or formId == 2
            
            if isShowing == shouldShow and event == "UPDATE_SHAPESHIFT_FORM" then
                return false
            end

            cache.specializationId = specializationId
            cache.formId = formId

            return true, shouldShow
        end,
        color = { r = 1.0, g = 0.65, b = 0.0 },
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = { 1, 2, 3, 4 }
        },
        text = {
            xOffset = 140,
            yOffset = -5,
            size = 15
        }
    },
    [0] = {
        heightWeight = 1,
        powerType = Enum.PowerType.Mana,
        enabled_events = { "UPDATE_SHAPESHIFT_FORM"  },
        enabled = function(cache, event, ...)
            if event == "INITIAL" then
                cache.specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
                cache.formId = GetShapeshiftForm()
            end

            local specializationId = select(1, GetSpecializationInfo(GetSpecialization()))
            local formId = GetShapeshiftForm()

            local isShowing = cache.specializationId ~= 105 or (cache.formId == 1 or cache.formId == 2)
            local shouldShow = specializationId ~= 105 or (formId == 1 or formId == 2)

            if isShowing == shouldShow and event == "UPDATE_SHAPESHIFT_FORM" then
                return false
            end

            cache.specializationId = specializationId
            cache.formId = formId

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

                local spellCost = GetSpellPowerCost(8936)[1].cost
                if (spellCost == 0) then
                    return true, resourceValues
                end

                local currentMaxTick = 0

                while currentMaxTick + spellCost < cache.maxPower do
                    currentMaxTick = currentMaxTick + spellCost
                    table.insert(resourceValues, currentMaxTick)
                end

                return true, resourceValues
            end
        },
        text = {
            value_dependencies = { "currentPower", "maxPower", "enabled" },
            value = function(cache, event, ...)
                if select(1, GetSpecializationInfo(GetSpecialization())) == 105 then
                    return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
                end

                if select(1, PRD:GetUnitBuff("player", 69369)) ~= nil then
                    return true, "Free"
                end

                local spellCost = GetSpellPowerCost(8936)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end

                return true, math.floor(cache.currentPower / spellCost)
            end,
            xOffset = -140,
            yOffset = 5,
            size = 15
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local percent = cache.currentPower / cache.maxPower
            return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}