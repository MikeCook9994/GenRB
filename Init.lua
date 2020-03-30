local CreateFrame = CreateFrame

PRD = {
    width = 250,
    height = 25,
    container = nil,
    currentSpecKey = nil,
    debugEnabled = true,
    frameUpdates = {},
    configurations = {},
}

function PRD:Initialize() 
    local container = _G["prd_bar_container"] or CreateFrame("Frame", "prd_bar_container")
    container:SetHeight(PRD.height)
    container:SetWidth(PRD.width)
    container:SetFrameStrata("BACKGROUND")
    
    -- initialization events
    container:RegisterEvent("PLAYER_ENTERING_WORLD")
    container:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    -- enter/exit combat events, used to adjust bar opacity
    container:RegisterEvent("PLAYER_REGEN_ENABLED")
    container:RegisterEvent("PLAYER_REGEN_DISABLED")

    conatiner:SetScript("OnEvent", function(self, event, ...)
        PRD:DebugPrint(event, ...)
        if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_SPECIALIZATION_CHANGED" and ReinitializationNeeded()) then
            PRD:InitializePersonalResourceDisplay()
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            PRD:HandleCombatStateChangEvent(event)
        end
    end)

    conatiner:SetScript("OnUpdate", function(self, event, ...)
        PRD:DebugPrint("FRAME_UPDATE", ...)
        PRD:HandleFrameUpdates()
    end)

    PRD.container = container
end

function PRD:HandleCombatStateChangEvent(event)
    local alpha = (event == "PLAYER_REGEN_DISABLED") and 1.0 or 0.5
    PRD.container:SetAlpha(alpha)
end

local function HandleFrameUpdates()
    for key, handlerConfig in pairs(PRD.frameUpdates) do
        if not handlerConfig.updater(handlerConfig.bar, PRD.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, "FRAME_UPDATE", nil) then
            PRD.frameUpdates[key] = nil
        end
    end
end

local function ReinitializationNeeded()
    return PRD.currentSpecKey ~= PRD:GetConfigurationKey()
end