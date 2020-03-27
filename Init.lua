local CreateFrame = CreateFrame

PRD = {
    width = 250,
    height = 25,
    container = nil,
    currentSpecKey = nil,
    debugEnabled = true,
    progressBars = {},
    eventHandlers = {},
    dependencyHandlers = {},
    frameUpdates = {},
    configurations = {},
    positionAndSizeConfig = {
        primary = {
            anchorPoint = "LEFT",
            tickWidth = 3,
            height = PRD.height,
            yOffset = 0
        },
        top = {
            anchorPoint = "TOP",
            tickWidth = 2,
            height = PRD.height / 4,
            yOffset = PRD.height / 4
        },
        top_left = {
            anchorPoint = "TOPLEFT",
            tickWidth = 2,
            height = PRD.height / 4,
            width = PRD.width / 2,
            yOffset = PRD.height / 4,
            inverseFill = true
        },
        top_right = {
            anchorPoint = "TOPRIGHT",
            tickWidth = 2,
            height = PRD.height / 4,
            width = PRD.width / 2,
            yOffset = PRD.height / 4,
        },
        bottom = {
            tickWidth = 2,
            anchorPoint = "BOTTOM",
            height = PRD.height / 4,
            yOffset = (-1 * (PRD.height / 4))
        },
        bottom_left = {
            tickWidth = 2,
            anchorPoint = "BOTTOMLEFT",
            height = PRD.height / 4,
            width = PRD.width / 2,
            yOffset = (-1 * (PRD.height / 4)),
            inverseFill = true
        },
        bottom_right = {
            tickWidth = 2,
            anchorPoint = "BOTTOMRIGHT",
            height = PRD.height / 4,
            width = PRD.width / 2,
            yOffset = (-1 * (PRD.height / 4))
        }
    }
}

function PRD:Initialize() 
    local container = _G["prd_bar_container"] or CreateFrame("Frame")
    
    -- initialization events
    container:RegisterEvent("PLAYER_ENTERING_WORLD")
    container:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

    -- enter/exit combat events, used to adjust bar opacity
    container:RegisterEvent("PLAYER_REGEN_ENABLED")
    container:RegisterEvent("PLAYER_REGEN_DISABLED")

    conatiner:SetScript("OnEvent", function(self, event, ...)
        PRD:DebugPrint(event, ...)
        if event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_SPECIALIZATION_CHANGED" and ReinitializationNeeded()) then
            InitializeClassBar()
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            handleCombatStateChangEvent()
        end
    end)

    conatiner:SetScript("OnUpdate", function(self, event, ...)
        PRD:DebugPrint("FRAME_UPDATE", ...)
        PRD:handleFrameUpdates()
    end)

    PRD.container = container


end

local function HandleEvent(event, ...)
    for _, handlerConfig in ipairs(PRD.eventHandlers[event] or {}) do
        if handlerConfig.updater(handlerConfig.bar, PRD.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, event, ...) then
            PRD.frameUpdates[handlerConfig.bar .. handlerConfig.path .. handlerConfig.property] = handlerConfig
        end

        for _, dependencyConfig in ipairs(PRD.dependencyHandlers[handlerConfig.property] or {}) do
            if dependencyConfig.updater(dependencyConfig.bar, PRD.progressBars[dependencyConfig.bar], dependencyConfig.path, dependencyConfig.property, dependencyConfig.handler, event, ...) then
                PRD.frameUpdates[dependencyConfig.bar .. dependencyConfig.path .. dependencyConfig.property] = dependencyConfig
            end
        end
    end
end

local function HandleFrameUpdates()
    for key, handlerConfig in pairs(PRD.frameUpdates) do
        if not handlerConfig.updater(handlerConfig.bar, PRD.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, "FRAME_UPDATE", nil) then
            PRD.frameUpdates[key] = nil
        end
    end
end

local function HandleCombatStateChangEvent(event)
    local alpha = (event == "PLAYER_REGEN_DISABLED") and 1.0 or 0.5
    PRD.container:SetAlpha(alpha)
end

local function ReinitializationNeeded()
    return PRD.currentSpecKey ~= GetClassBarConfigurationKey()
end

function PRD:ConvertPowerTypeStringToEnumValue(powerType)
    return Enum.PowerType[((" " .. string.lower(powerType)):gsub("%W%l", string.upper):sub(2)):gsub("_", "")]
end
 
function PRD:DebugPrint(strName, data) 
    if ViragDevTool_AddData and PRD.debugEnabled then 
        ViragDevTool_AddData(data, strName) 
    end 
end