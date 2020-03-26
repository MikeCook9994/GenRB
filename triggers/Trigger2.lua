-- PLAYER_TALENT_UPDATE, UNIT_SPELLCAST_START:player, UNIT_POWER_FREQUENT:player, UNIT_MAXPOWER:player, UNIT_SPELLCAST_SUCCEEDED:player, UNIT_SPELLCAST_STOP:player, UNIT_SPELLCAST_SUCCEEDED:player, COMBAT_LOG_EVENT_UNFILTERED
-- passes registered events to the bar to update itself
function(event, ...)
    aura_env.handleEvent(event, ...)
    return true
end