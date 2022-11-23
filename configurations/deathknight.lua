PRD.configurations.deathknight = {
    [0] = {
        heightWeight = 5,
        powerType = Enum.PowerType.Runes,
        currentPower_events = { "RUNE_POWER_UPDATE" },
        currentPower = function(cache, event, ...) 
            if event == "RUNE_POWER_UPDATE" and select(1, ...) ~= cache.runeIndex then
                return false, nil, cache.cooling
            end

            local start, duration, ready = GetRuneCooldown(cache.runeIndex)

            cache.currentPower = ((start ~= 0 and start ~= nil) and (GetTime() - start)) or duration or 0
            cache.cooling = not ready

            return true, cache.currentPower, cache.cooling
        end,
        maxPower_events = { "RUNE_POWER_UPDATE" },
        maxPower = function(cache, event, ...)
            if event == "RUNE_POWER_UPDATE" and select(1, ...) ~= cache.runeIndex then
                return false, nil, cache.cooling
            end

            cache.maxPower, ready = select(2, GetRuneCooldown(cache.runeIndex))
            cache.cooling = not ready

            if cache.maxPower == nil then
                return false, nil
            end

            return true, cache.maxPower, cache.cooling
        end,
        color_dependencies = { "currentPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("DEATHKNIGHT")

            if cache.cooling then
                return true, { r = r / 2, g = g / 2, b = b / 2 }
            end

            return true, { r = r, g = g, b = b }
        end,
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower < cache.maxPower and cache.maxPower - cache.currentPower < cache.maxPower
            end,
            value_dependencies = { "currentPower" },
            value = function(cache, event, ...) 
                return true, (("%%d"):format(0):format(cache.maxPower - cache.currentPower))
            end,
            size = 15
        },
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 }
        }
    },
    [1] = {
        heightWeight = 1,
        powerType = Enum.PowerType.RunicPower,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        text = {
            size = 25
        },
        tickMarks = {
            offsets = {
                frost_strike = {
                    resourceValue = 25,
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, 251 == select(1, GetSpecializationInfo(GetSpecialization()))
                    end,
                    color = { r = 0.75, g = 0.75, b = 1.0 }
                },
                death_coil = {
                    resourceValue = 40,
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, 252 == select(1, GetSpecializationInfo(GetSpecialization()))
                    end,
                    color = { r = 0.75, g = 1.0, b = 0.75 }
                },
                death_strike = {
                    resourceValue_events = { "UNIT_AURA" },
                    resourceValue = function(cache, event, ...)
                        if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                            return false
                        end

                        return true, (250 ~= select(1, GetSpecializationInfo(GetSpecialization())) and 35) or select(1, PRD:GetPlayerBuff(219788)) == nil and 45 or 40
                    end,
                    color = { r = 1.0, g = 0.75, b = 0.75 }
                },
                bonestorm = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled = function(cache, event, ...) 
                        return true, (250 == select(1, GetSpecializationInfo(GetSpecialization()))) and (select(4, GetTalentInfo(7, 3, 1)) and true or false)
                    end,
                    resourceValue = 100,
                    color = { r = 1.0, g = 1.0, b = 1.0 }
                }
            }
        }
    }
}