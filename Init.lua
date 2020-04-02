local CreateFrame = CreateFrame

local function ReinitializationNeeded()
    return PRD.currentSpecKey ~= PRD:GetConfigurationKey()
end

local function Initialize() 
    local container = _G["prd_bar_container"] or CreateFrame("Frame", "prd_bar_container")
    container:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
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
        if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_SPECIALIZATION_CHANGED" and ReinitializationNeeded()) then
            C_Timer.After(1, function() 
                PRD:InitializePersonalResourceDisplay()
            end)
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

function PRD:HandleCombatStateChangeEvent(event)
    local alpha = (event == "PLAYER_REGEN_DISABLED") and 1.0 or 0.5
    PRD.container:SetAlpha(alpha)
end

function PRD:HandleEvent(handlerConfigs, event, ...)
    if handlerConfigs == nil then return end

    for _, handlerConfig in ipairs(handlerConfigs) do
        if handlerConfig.updater(handlerConfig.eventHandler, handlerConfig.self, event, ...) then
            table.insert(PRD.frameUpdates, handlerConfig)
        end

        PRD:HandleEvent(handlerConfig.self.dependencyConfigs[handlerConfig.property], event, ...)
    end
end

function PRD:HandleFrameUpdates()
    local FRAME_UPDATE_EVENT = "FRAME_UPDATE"
    for index, handlerConfig in ipairs(PRD.frameUpdates) do
        if not handlerConfig.updater(handlerConfig.eventHandler, handlerConfig.self, FRAME_UPDATE_EVENT) then
            PRD.frameUpdates[index] = nil
        end

        PRD:HandleEvent(handlerConfig.self.dependencyConfigs[handlerConfig.property], FRAME_UPDATE_EVENT)
    end
end

Initialize() 