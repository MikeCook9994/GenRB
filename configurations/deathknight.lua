PRD.configurations.deathknight = {
    top = {
        powerType = Enum.PowerType.RunicPower,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Darkbottom",
        text = {
            xOffset = -140,
            yOffset = -5,
            size = 15
        },
        tickMarks = {
            offsets = {
                frost_strike = {
                    resourceValue = 25,
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                            return false
                        end

                        return true, 251 == select(1, GetSpecializationInfo(GetSpecialization()))
                    end,
                    color = { r = 0.75, g = 0.75, b = 1.0 }
                },
                glacial_advance_epidemic = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_TALENT_UPDATE" },
                    enabled = function(cache, event, ...) 
                        local specId = select(1, GetSpecializationInfo(GetSpecialization()))
                        local glacialAdvanceTalented = (251 == specId) and (select(4, GetTalentInfo(6, 2, 1)) and true or false)
                        return true, glacialAdvanceTalented or specId == 252
                    end,
                    resourceValue = 30,
                    color = { r = 0.75, g = 1.0, b = 1.0 }
                },
                death_coil = {
                    resourceValue = 40,
                    -- enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    -- enabled = function(cache, event, ...)
                    --     if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                    --         return false
                    --     end

                    --     return true, 252 == select(1, GetSpecializationInfo(GetSpecialization()))
                    -- end,
                    color = { r = 0.75, g = 1.0, b = 0.75 }
                },
                death_strike = {
                    resourceValue_events = { "UNIT_AURA" },
                    resourceValue = function(cache, event, ...)
                        if event == "UNIT_AURA" and select(1, ...) ~= "player" then
                            return false
                        end

                        return true, (250 ~= select(1, GetSpecializationInfo(GetSpecialization())) and 35) or select(1, PRD:GetUnitBuff('player', 219788)) == nil and 45 or 40
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
    },
    primary = {
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
            if cache.cooling then
                return true, { r = 0.5, g = 0.125, b = 0.125 }
            end

            local r, g, b = GetClassColor("DEATHKNIGHT")
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
            size = 12
        },
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 }
        }
    },
    bottom = {
        currentPower_events = { "UNIT_HEALTH" },
        currentPower = function(cache, event, ...) 
            if event == "UNIT_HEALTH" and select(1, ...) ~= "player" then
                return false
            end

            cache.currentPower = UnitHealth("player")

            return true, cache.currentPower
        end,
        maxPower_events = { "UNIT_MAXHEALTH" },
        maxPower = function(cache, event, ...) 
            if event == "UNIT_MAXHEALTH" and select(1, ...) ~= "player" then
                return false
            end

            cache.maxPower = UnitHealthMax("player")

            if cache.maxPower == nil then
                return false
            end

            return true, cache.maxPower
        end,
        prediction = {
            next_events = { "COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_SPECIALIZATION_CHANGED" },
            next_dependencies = { "currentPower", "maxPower" },
            next = function(cache, event, ...)
                if event == "INITIAL" then
                    cache.damageTaken = {}
                    cache.exclude = {
                        [223414] = true, --Parasitic Fetter
                        [204611] = true, --Crushing Grip
                        [204658] = true, --Crushing Grip
                        [240448] = true, --Quaking
                        [243237] = true, --Bursting
                        [258837] = true, --Rent Soul
                    }
                elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
                    if select(8, ...) ~= UnitGUID("player") then
                        return false
                    end
            
                    local subevent = select(2, ...)
            
                    --set selection offset to amount for baseline SWING_DAMAGE
                    local offset = 12
            
                    --handle SPELL_ABSORBED events
                    if subevent == "SPELL_ABSORBED" then
                        
                        --if a spell gets absorbed instead of a melee hit, there are 3 additional parameters regarding which spell got absorbed, so move the offset 3 more places
                        local spellid, spellname = select(offset, ...)
                        if GetSpellInfo(spellid) == spellname then
                            --check for excluded spellids before moving the offset
                            if cache.exclude[spellid] then
                                return false
                            end
                            offset = offset + 3
                        end
                        
                        --absorb value is 7 places further
                        offset = offset + 7
                        table.insert(cache.damageTaken, { timestamp = GetTime(), damage = (select(offset, ...)) })
                        
                        --handle regular XYZ_DAMAGE events
                    elseif subevent:find("_DAMAGE") then
                        
                        --don't include environmental damage (like falling etc)
                        if not subevent:find("ENVIRONMENTAL") then
                            
                            --move offset by 3 places for spell info for RANGE_ and SPELL_ prefixes
                            if subevent:find("SPELL") then
                                --check for excluded spellids before moving the offset
                                local spellid = select(offset, ...)
                                if cache.exclude[spellid] then
                                    return false
                                end
                                offset = offset + 3
                            elseif subevent:find("RANGE") then
                                offset = offset + 3
                            end
                            
                            --damage event
                            table.insert(cache.damageTaken, { timestamp = GetTime(), damage = (select(offset, ...)) })
                        end  
                    end
                end

                local specId = select(1, GetSpecializationInfo(GetSpecialization()))
                local minimumPercent = (specId == 250 and 0.07) or 0.1
                local damagePercent = (specId == 250 and 0.25) or (specId == 251 and 0.6) or (specId == 252 and 0.4) or .25
            
                -- clean out the table
                PRD:ArrayRemove(cache.damageTaken, function(t, i)
                    local current = GetTime()
                    return GetTime() <=  t[i].timestamp + 5
                end)
                
                local damageTaken = 0
                for i, damageEvent in ipairs(cache.damageTaken) do
                    damageTaken = damageTaken + damageEvent.damage
                end
            
                --Versatility
                local vers = 1 + ((GetCombatRatingBonus(29) + GetVersatilityBonus(30)) / 100)
                
                --Vampiric Blood
                local vamp = PRD.GetUnitBuff("player", 55233) and 1.3 or 1

                -- Unholy Dark Succor
                local darkSuccor = PRD.GetUnitBuff("player", 178819) and 10 or 0
                
                --Guardian Spirit
                local gs = 1 + (select(16, PRD.GetUnitBuff("player", 47788)) or 0) / 100
                
                --Divine Hymn
                local dh = PRD.GetUnitBuff("player", 64844) and 1.1 or 1
                
                --Hemostasis
                local haemo = 1 + 0.08 * (select(3, PRD.GetUnitBuff("player", 273947)) or 0)
                  
                local heal = damageTaken * damagePercent --damage taken * DS percentage
                local perc = heal / UnitHealthMax("player") --relative to maxHP
                perc = math.max(minimumPercent, perc) --minimum DS percentage
                perc = perc * vamp * vers * gs * dh * haemo --apply all multipliers
                perc = perc + darkSuccor -- apply unholy dk dark succor if present

                cache.predictedHeal = perc * UnitHealthMax("player") --get the actual heal value
                cache.predictedPower = cache.currentPower + cache.predictedHeal

                return true, cache.predictedPower, #cache.damageTaken > 0
            end,
            color_dependencies = { "next" },
            color = function(cache, event, ...) 
                local healthRatio = cache.predictedPower / cache.maxPower
                return true, { r = 0.5 + (0.5 * (1.0 - healthRatio)), g = 0.5 + (0.5 * healthRatio), b = 0.5 }
            end
        },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Cloud",
        text = {
            value_dependencies = { "next", "maxPower" },
            value = function(cache, event, ...)
                return true, string.format("%.1f%%", (cache.predictedHeal / cache.maxPower) * 100)
            end,
            xOffset = 140,
            yOffset = 5,
            size = 15
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local healthRatio = cache.currentPower / cache.maxPower
            return true, { r = 1.0 - healthRatio, g = healthRatio, b = 0.0 }
        end
    }
}