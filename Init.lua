local CreateFrame = CreateFrame

local PRD = PRD

function PRD:ReinitializationNeeded()
    return PRD.currentSpecKey ~= PRD:GetConfigurationKey()
end

function PRD:Initialize() 
    local container = _G["prd_bar_container"] or CreateFrame("Frame", "prd_bar_container")
    container:SetPoint("CENTER", UIParent, "CENTER", PRD.x, PRD.y)
    container:SetHeight(PRD.height)
    container:SetWidth(PRD.width)
    container:SetFrameStrata("BACKGROUND")
    container:Show()
    
    -- initialization events
    container:RegisterEvent("PLAYER_ENTERING_WORLD")
    container:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    -- enter/exit combat events, used to adjust bar opacity
    container:RegisterEvent("PLAYER_REGEN_ENABLED")
    container:RegisterEvent("PLAYER_REGEN_DISABLED")

    container:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_SPECIALIZATION_CHANGED" and PRD:ReinitializationNeeded()) then
            PRD:Clean()
            C_Timer.After(.1, function() 
                PRD:InitializePersonalResourceDisplay()
            end)
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            PRD:HandleCombatStateChangeEvent(event)
        end
    end)

    C_Timer.NewTicker(.05, function()
        local PRD = PRD
        PRD:HandleFrameUpdates()
    end)

    PRD.container = container
end

function PRD:HandleCombatStateChangeEvent(event)
    local alpha = (event == "PLAYER_REGEN_DISABLED") and 1.0 or 0.25 
    for _, bar in ipairs({ PRD.container:GetChildren() }) do
        for _, child in ipairs({ bar:GetChildren() }) do
            if string.find(child:GetName(), "_prediction_bar") then
                child:SetAlpha(alpha * .75)
            elseif string.find(child:GetName(), "_background_bar") then 
                child:SetAlpha(alpha * .5)
            else
                child:SetAlpha(alpha)
            end
        end
    end
end

function PRD:HandleEvent(handlerConfigs, event, ...)
    if handlerConfigs == nil then return end

    for _, handlerConfig in ipairs(handlerConfigs) do
        if handlerConfig:updater(handlerConfig.eventHandler, handlerConfig.self, event, ...) then
            PRD:DebugPrint("Adding frame update", handlerConfig)
            table.insert(PRD.frameUpdates, handlerConfig)
        end

        if handlerConfig.self.dependencyHandlers then
            PRD:HandleEvent(handlerConfig.self.dependencyHandlers[handlerConfig.property], event, ...)
        end
    end
end


function PRD:HandleFrameUpdates()
    local FRAME_UPDATE_EVENT = "FRAME_UPDATE"
    local n=#PRD.frameUpdates
    for i=1,n do
        local handlerConfig = PRD.frameUpdates[i]
        if not handlerConfig:updater(handlerConfig.eventHandler, handlerConfig.self, FRAME_UPDATE_EVENT) then
            PRD:DebugPrint("Removing frame update", handlerConfig)
            PRD.frameUpdates[i] = nil
        end

        if handlerConfig.self.dependencyHandlers then
            PRD:HandleEvent(handlerConfig.self.dependencyHandlers[handlerConfig.property], FRAME_UPDATE_EVENT)
        end
    end

    local j=0
    for i=1,n do
        if PRD.frameUpdates[i]~=nil then
                j=j+1
                PRD.frameUpdates[j]=PRD.frameUpdates[i]
        end
    end

    for i=j+1,n do
        PRD.frameUpdates[i]=nil
    end

    PRD:DebugPrint(PRD:TableCount(PRD.frameUpdates))
end

function PRD:TableCount(table)
    local count = 0

    for k, v in ipairs(PRD.frameUpdates) do
        count = count + 1
    end

    return count
end

PRD:Initialize() 