local CreateFrame = CreateFrame

local function Initialize() 
    local container = _G["prd_bar_container"] or CreateFrame("Frame", "prd_bar_container")
    container:SetPoint("CENTER", parent, "CENTER", 0, 0)
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
        PRD:DebugPrint(event, ...)
        if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_SPECIALIZATION_CHANGED" and ReinitializationNeeded()) then
            PRD:InitializePersonalResourceDisplay()
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            PRD:HandleCombatStateChangeEvent(event)
        end
    end)

    container:SetScript("OnUpdate", function(self, event, ...)
        local PRD = PRD
        PRD:HandleFrameUpdates()
    end)

    PRD.container = container
end

local function ReinitializationNeeded()
    return PRD.currentSpecKey ~= PRD:GetConfigurationKey()
end

function PRD:HandleCombatStateChangeEvent(event)
    local alpha = (event == "PLAYER_REGEN_DISABLED") and 1.0 or 0.5
    PRD.container:SetAlpha(alpha)
end

function PRD:HandleFrameUpdates()
    for key, handlerConfig in pairs(PRD.frameUpdates) do
        if not handlerConfig.updater(handlerConfig.bar, PRD.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, "FRAME_UPDATE", nil) then
            PRD.frameUpdates[key] = nil
        end
    end
end



Initialize() 