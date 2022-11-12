local CreateFrame = CreateFrame

local PRD = PRD

function PRD:ReinitializationNeeded()
    return PRD.currentSpecKey ~= PRD:GetConfigurationKey()
end

function PRD:Initialize() 
    local container = _G["prd_bar_container"] or CreateFrame("Frame", "prd_bar_container", UIParent)
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

    -- automatically hide prd events
    container:RegisterEvent("CINEMATIC_START")
    container:RegisterEvent("CINEMATIC_STOP")
    container:RegisterEvent("PLAYER_FLAGS_CHANGED")

    container:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_SPECIALIZATION_CHANGED" and PRD:ReinitializationNeeded()) then
            PRD:Clean()
            C_Timer.After(.1, function()
                PRD:InitializePersonalResourceDisplay()
            end)
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            PRD:HandleCombatStateChangeEvent(event)
        elseif event == "CINEMATIC_START" then
            _G["prd_bar_container"]:Hide()
        elseif event == "CINEMATIC_STOP" then
            _G["prd_bar_container"]:Show()
        elseif event == "PLAYER_FLAGS_CHANGED" then
            if UnitIsAFK("player") then
                _G["prd_bar_container"]:Hide()
            else 
                _G["prd_bar_container"]:Show()
            end
        end
    end)

    C_Timer.NewTicker(.05, function()
        local PRD = PRD
        PRD:HandleFrameUpdates()
    end)

    PRD.container = container

    local weakAuraParent = _G["prd_weakaura_container"] or CreateFrame("Frame", "prd_weakaura_container", container)
    weakAuraParent:SetPoint("CENTER", container, "CENTER", 0, 0)
    weakAuraParent:SetHeight(PRD.height)
    weakAuraParent:SetWidth(PRD.width)
    weakAuraParent:SetFrameStrata("BACKGROUND")
    weakAuraParent:Show()
end

function PRD:HandleCombatStateChangeEvent(event)
    local alpha = (event == "PLAYER_REGEN_DISABLED") and 1.0 or 0.25 
    for _, bar in ipairs({ PRD.container:GetChildren() }) do
        for _, child in ipairs({ bar:GetChildren() }) do
            if string.find(child:GetName() or "", "_prediction_bar") then
                child:SetAlpha(alpha * .75)
            elseif string.find(child:GetName() or "", "_background_bar") then 
                child:SetAlpha(alpha * .5)
            elseif string.find(child:GetName() or "", "prd_") then
                child:SetAlpha(alpha)
            end
        end
    end
end

function PRD:CleanFrameState(frame)
    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(nil)
    frame.eventHandlers = {}
    frame.dependencyHandlers = {}
end

function PRD:Clean()
    for barName, frames in pairs(PRD.bars) do
        for frameName, frame in pairs(frames) do
            -- runes are a pain in the ass
            if not string.find(frameName, "prd_") then
                for runeFrameName, runeFrame in pairs(frame) do
                    PRD:CleanFrameState(runeFrame)
                end
            else
                PRD:CleanFrameState(frame)
            end
        end
    end

    PRD.frameUpdates = {}
    PRD.bars = {}
    PRD.currentSpecKey = nil
    PRD.selectedConfig = nil
end

function PRD:HandleEvent(handlerConfigs, event, ...)
    if handlerConfigs == nil then return end

    for _, handlerConfig in ipairs(handlerConfigs) do
        local frameUpdateKey = handlerConfig.property .. "_" .. handlerConfig.self:GetName()
        if handlerConfig:updater(handlerConfig.eventHandler, handlerConfig.self, event, ...) and PRD.frameUpdates[frameUpdateKey] == nil then
            PRD.frameUpdates[frameUpdateKey] = handlerConfig
        end

        if handlerConfig.self.dependencyHandlers then
            PRD:HandleEvent(handlerConfig.self.dependencyHandlers[handlerConfig.property], event, ...)
        end
    end
end

function PRD:HandleFrameUpdates()
    local FRAME_UPDATE_EVENT = "FRAME_UPDATE"
    for configKey, handlerConfig in pairs(PRD.frameUpdates) do
         if not handlerConfig:updater(handlerConfig.eventHandler, handlerConfig.self, FRAME_UPDATE_EVENT) then
            PRD.frameUpdates[configKey] = nil
        end

        if handlerConfig.self.dependencyHandlers then
            PRD:HandleEvent(handlerConfig.self.dependencyHandlers[handlerConfig.property], FRAME_UPDATE_EVENT)
        end
    end
end

PRD:Initialize() 