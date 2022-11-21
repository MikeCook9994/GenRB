PRD.configurations.druid_feral = {
    [2] = {
        heightWeight = 2,
        powerType = Enum.PowerType.ComboPoints,
        color = { r = 1.0, g = 0.65, b = 0.0 },
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = { 1, 2, 3, 4 }
        }
    },
    [1] = {
        heightWeight = 5,
        powerType_events = { "UPDATE_SHAPESHIFT_FORM" },
        powerType = function(cache, event, ...)
            if GetShapeshiftForm() == 1 then
                cache.powerType = Enum.PowerType.Rage
            else 
                cache.powerType = Enum.PowerType.Energy
            end

            return true, cache.powerType
        end,
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        },
        tickMarks = {
            width = 3,
            color = { r = 0.5, g = 0.5, b = 1.0},
            offsets = {
                ironFur_shred = {
                    enabled = true,
                    resourceValue = 40
                },
                frenziedRegen = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled_dependencies = { "powerType" },
                    enabled = function(cache, event, ...)
                        return true, GetShapeshiftForm() == 1
                    end,
                    resourceValue = 10
                }
            }
        },
    },
    [0] = {
        heightWeight = 1,
        enabled = true,
        powerType_events = { "UPDATE_SHAPESHIFT_FORM" },
        powerType = function(cache, event, ...)
            if GetShapeshiftForm() == 1 then
                cache.powerType = Enum.PowerType.Energy
            else 
                cache.powerType = Enum.PowerType.Mana
            end

            return true, cache.powerType
        end,
        tickMarks = {
            enabled_dependencies = { "powerType" },
            enabled = function(cache, event, ...)
                return true, cache.powerType == Enum.PowerType.Mana
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

                while currentMaxTick + spellCost + 100 < cache.maxPower do
                    currentMaxTick = currentMaxTick + spellCost
                    table.insert(resourceValues, currentMaxTick)
                end

                return true, resourceValues
            end
        },
        text = {
            enabled_dependencies = { "powerType" },
            enabled = function(cache, event, ...)
                return true, cache.powerType == Enum.PowerType.Mana
            end,
            value_dependencies = { "currentPower", "maxPower", "enabled" },
            value = function(cache, event, ...)
                if select(1, PRD:GetUnitBuff("player", 69369)) ~= nil then
                    return true, "Free"
                end

                local spellCost = GetSpellPowerCost(8936)[1].cost
                if (spellCost == 0) then
                    return true, ""
                end

                return true, math.floor(cache.currentPower / spellCost)
            end,
            xOffset = -220,
            yOffset = 6,
            size = 16
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local percent = cache.currentPower / cache.maxPower
            return true, { r = 1.0 * (1 - percent), g = 0.0, b = 1.0 * percent }
        end
    }
}