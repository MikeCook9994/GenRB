-- PLAYER_ENTERING_WORLD, PLAYER_REGEN_ENABLED, PLAYER_REGEN_DISABLED, PLAYER_SPECIALIZATION_CHANGED
-- admin related events, these trigger init and reinit of the bar as well as adjusting opacity when we enter and exit combat
function(event, ...)
    if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_SPECIALIZATION_CHANGED" and aura_env.ReinitializationNeeded()) then
        -- if event == "PLAYER_ENTERING_WORLD" then
        --     return true
        -- end

        -- aura_env.DebugPrint("WTF")
        aura_env.initialize()
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        aura_env.handleCombatStateChangEvent(event)
    end
    
    return true
end