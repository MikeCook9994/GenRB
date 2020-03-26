-- runs every frame to update bars that track auras and other things that we can't listen to events for
function()
    aura_env.handleFrameUpdates()
    return true
end