PRD.configurations.druid = {
    primary = {
        powerType = function() 
            if PRD:GetUnitAura("player", 24858) ~= nil then
                return Enum.PowerType.LunarPower
            elseif PRD:GetUnitAura("player", 5487) ~= nil then
                return Enum.PowerType.Rage
            elseif PRD:GetUnitAura("player", 768) ~= nil then
                return Enum.PowerType.Energy
            end

            return Enum.PowerType.Mana
        end,
        tickMarks = {
            color = { r = 1.0, g = 1.0, b = 1.0},
            offsets = { 
                iron_fur_shred_starsurge = {
                    enabled = function(current, max)
                        local specializationId = GetInspectSpecialization("player")

                        local balanceWithGuardianAffinity = (specializationId == 102) and select(4, GetTalentInfo(3, 2, 1))
                        local feralWithGuardianAffinity = (specializationId == 103) and select(4, GetTalentInfo(3, 2, 1))
                        local restorationWithGuardianAffinity = (specializationId == 105) and select(4, GetTalentInfo(3, 3, 1))
                        local guardianSpec = specializationId == 104
                        local bearFormWithSpenders = (PRD:GetUnitAura("player", 5487) ~= nil) and (balanceWithGuardianAffinity or feralWithGuardianAffinity or restorationWithGuardianAffinity or guardianSpec)
                        
                        local balanceWithFeralAffinity = (specializationId == 102) and select(4, GetTalentInfo(3, 1, 1))
                        local guardianWithFeralAffinity = (specializationId == 105) and select(4, GetTalentInfo(3, 2, 1))
                        local restorationWithFeralAffinity = (specializationId == 104) and select(4, GetTalentInfo(3, 2, 1))
                        local feralSpec = specializationId == 103
                        local catFormWithComboPoints = (PRD:GetUnitAura("player", 768) ~= nil) and (balanceWithFeralAffinity or guardianWithFeralAffinity or restorationWithFeralAffinity or feralSpec)

                        local balanceSpecWithMoonkinForm = (specializationId == 102) and (PRD:GetUnitAura("player", 24858) ~= nil)
                        return bearFormWithSpenders or catFormWithComboPoints or balanceSpecWithMoonkinForm
                    end,
                    resourceValue = 40,
                    color = { r = 1.0, g = 1.0, b = 1.0}     
                },
                frenzied_regen = {
                    enabled = function(current, max)
                        local specializationId = GetInspectSpecialization("player")
                        
                        local balanceWithGuardianAffinity = (specializationId == 102) and select(4, GetTalentInfo(3, 2, 1))
                        local feralWithGuardianAffinity = (specializationId == 103) and select(4, GetTalentInfo(3, 2, 1))
                        local restorationWithGuardianAffinity = (specializationId == 105) and select(4, GetTalentInfo(3, 3, 1))
                        local guardianSpec = specializationId == 104
                        return (PRD:GetUnitAura("player", 5487) ~= nil) and (balanceWithGuardianAffinity or feralWithGuardianAffinity or restorationWithGuardianAffinity or guardianSpec)
                    end,
                    resourceValue = 10,
                    color = { r = 1.0, g = 1.0, b = 1.0}     
                }
            }
        },
        prediction = {
            enabled = function()
                return PRD:GetUnitAura("player", 24858) ~= nil
            end,
            color = function(predictedPower, maxPower) 
                local powerTypeColor = PowerBarColor[Enum.PowerType.LunarPower]
                return { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b } 
            end,
            next = function(currentPower, maxPower)
                local predictedPowerGain = 0
                
                local SpellCast = UnitCastingInfo('player')
                
                if select(1, SpellCast) == GetSpellInfo(190984) then -- SW
                    predictedPowerGain = 8
                elseif select(1, SpellCast) == GetSpellInfo(194153) then -- LS
                    predictedPowerGain = 12
                elseif select(1, SpellCast) == GetSpellInfo(202347) then -- SF
                    predictedPowerGain = 8
                elseif select(1, SpellCast) == GetSpellInfo(274281) then -- New Moon
                    predictedPowerGain = 10
                elseif select(1, SpellCast) == GetSpellInfo(274282) then -- Half Moon
                    predictedPowerGain = 20
                elseif select(1, SpellCast) == GetSpellInfo(274283) then -- Full Moon
                    predictedPowerGain = 40
                end 
                
                local predictedPower = currentPower + predictedPowerGain or 0   
                predictedPower = math.max(predictedPower, 0)
                predictedPower = math.min(predictedPower, maxPower)
                
                return predictedPower
            end
        },
        text = {
            value = function(currentPower, maxPower)
                if (PRD:GetUnitAura("player", 5487) ~= nil) or (PRD:GetUnitAura("player", 768) ~= nil) or (PRD:GetUnitAura("player", 24858) ~= nil) then
                    return currentPower
                end

                return (("%%.%df"):format(2):format((currentPower / maxPower)) * 100) .. "%"
            end
        }
    },
    top = {
        powerType = Enum.PowerType.ComboPoints,
        color = { r = 1.0, g = 0.65, b = 0.0 },
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = { 1, 2, 3, 4 }
        },
        text = {
            size = 12,
            yOffset = -4,
            xOffset = -105
        },
        enabled = function()
            local balanceWithFeralAffinity = (GetInspectSpecialization("player") == 102) and select(4, GetTalentInfo(3, 1, 1))
            local guardianWithFeralAffinity = (GetInspectSpecialization("player") == 104) and select(4, GetTalentInfo(3, 2, 1))
            local restorationWithFeralAffinity = (GetInspectSpecialization("player") == 105) and select(4, GetTalentInfo(3, 2, 1))
            local feralSpec = GetInspectSpecialization("player") == 103
            return (PRD:GetUnitAura("player", 768) ~= nil) and (feralSpec or balanceWithFeralAffinity or guardianWithFeralAffinity or restorationWithFeralAffinity) and true or false
        end
    },
    top_left = {
        enabled = function(current, max)
            return ((PRD:GetUnitAura("player", 24858) ~= nil) or (PRD:GetUnitAura("player", 197625) ~= nil)) and true or false
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
        currentPower = function()
            local name, _, count, _, duration, expirationTime = PRD:GetUnitAura("player", 164545)
            
            if name == nil then
                return 0
            end
            
            return ((count - 1) + ((expirationTime - GetTime()) / duration)) 
        end,
        text = {
            enabled = false
        },
    },
    top_right = {
        enabled = function(current, max)
            return ((PRD:GetUnitAura("player", 24858) ~= nil) or (PRD:GetUnitAura("player", 197625) ~= nil)) and true or false
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
        currentPower = function()
            local name, _, count, _, duration, expirationTime = PRD:GetUnitAura("player", 164547)
            
            if name == nil then
                return 0
            end
            
            return ((count - 1) + ((expirationTime - GetTime()) / duration))  
        end,
        text = {
            enabled = false
        },
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        enabled = function()
            return (PRD:GetUnitAura("player", 24858) ~= nil) or (PRD:GetUnitAura("player", 5487) ~= nil) or (PRD:GetUnitAura("player", 768) ~= nil and GetInspectSpecialization("player") ~= 103)
        end,
        tickMarks = {
            enabled = function(currentPower, maxPower)
                return GetInspectSpecialization("player") ~= 105
            end,
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function()
                local resourceValues = { }
                
                local maxMana = UnitPowerMax("player", Enum.PowerType.Mana)
                local healingSpellCost = GetSpellPowerCost(8936)[1].cost
                local currentMaxTick = 0
                
                while currentMaxTick + healingSpellCost <= maxMana do
                    currentMaxTick = currentMaxTick + healingSpellCost
                    table.insert(resourceValues, currentMaxTick)
                end
                
                return resourceValues
            end
        },
        text = {
            value = function(currentPower, maxPower)
                if GetInspectSpecialization("player") == 105 then
                    return (("%%.%df"):format(2):format((currentPower / maxPower)) * 100) .. "%"
                end

                local healingSpellCost = GetSpellPowerCost(8936)[1].cost
                return math.floor(currentPower / healingSpellCost)
            end,
            xOffset = -105,
            yOffset = 5,
            size = 12
        },
        color = function(currentPower, maxPower)
            local percent = currentPower / maxPower
            return { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}