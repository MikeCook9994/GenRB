local PRD = PRD

local positionAndSizeConfig = {
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

-- Default Value Resolution Functions 

local function DefaultUpdateCurrentPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.currentPower = UnitPower("player", cache.powerType)
        return true, cache.currentPower
    end

    return false
end

local function DefaultUpdateMaxPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.maxPower = UnitPowerMax("player", cache.powerType)
        return true, cache.maxPower
    end

    return false
end

local function DefaultUpdateTextHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then
        -- if it's mana power type, format as percent by default
        if cache.powerType == Enum.PowerType.Mana then
            return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
        end

        return true, cache.currentPower
    end

    return false, cache.currentPower
end

-- Bar initialization
local function InitializeBarContainer(barName, parent, positionConfig)
    local frameName = "prd_" .. barName .. "_bar_container"
    local barContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    barContainer:SetWidth(positionConfig.width)
    barContainer:SetHeight(positionConfig.height)
    barContainer:SetPoint(positionConfig.anchorPoint, parent, positionConfig.anchorPoint, 0, positionConfig.yOffset)
    return barContainer
end

local function InitializeStatusBar(barName, parent, positionConfig, frameStrata, texture, color)
    local frameName = "prd_" .. barName .. "_main_bar"
    local statusBar = _G[frameName] or CreateFrame("StatusBar", frameName, parent)
    
    statusBar:SetWidth(positionConfig.width)
    statusBar:SetHeight(positionConfig.height)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetPoint("CENTER", parent, "CENTER", 0, 0)
    statusBar:SetFrameStrata(frameStrata)
    statusBar:SetStatusBarTexture(texture)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetReverseFill(positionConfig.inverseFill)
    statusBar.SetAlpha(0.5)
    statusBar:Show()
    return statusBar
end

local function InitializeBackground(barName, parent)
    local frameName = "prd_" .. barName .. "_background_bar"

    if _G[frameName] ~= nil then
        return _[frameName]
    end

    local backgroundFrame = CreateFrame("Frame", frameName, parent)
    
    backgroundFrame:SetWidth(PRD.width)
    backgroundFrame:SetHeight(PRD.height)
    backgroundFrame:SetPoint("CENTER", bar, "CENTER", 0, 0)
    backgroundFrame:SetFrameStrata("BACKGROUND")
    backgroundFrame:SetAlpha(0.5)
    backgroundFrame:Show()
    
    backgroundFrame.texture = _G[frameName .. "_texture"] or backgroundFrame:CreateTexture(frameName .. "_texture")
    backgroundFrame.texture:SetAllPoints(backgroundFrame)
    backgroundFrame.texture:SetColorTexture(0.0, 0.0, 0.0, 0.6)

    return backgroundFrame
end

local function InitializeTickMarkContainer(barName, parent, width, height)
    local frameName = "prd_" .. barName .. "_tick_mark_container"
    local tickMarkContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    tickMarkContainer:SetWidth(width)
    tickMarkContainer:SetHeight(height)
    tickMarkContainer:SetPoint("CENTER", bar, "CENTER", 0, 0)
    tickMarkContainer:SetFrameStrata("HIGH")
    tickMarkContainer.SetAlpha(0.5)
    tickMarkContainer:Show()
    return tickMarkContainer
end

local function InitializeTickMark(barName, tickId, parent, tickWidth, cache, texture, color, resourceRatio)
    local frameName = "prd_" .. barName .. "_tick_mark_" .. tickId
    local tickFrame = _G[frameName] or CreateFrame("Frame", frameName, parent)
    
    tickFrame:SetWidth(tickWidth)
    tickFrame:SetHeight(parent:GetHeight())
    tickFrame:SetPoint("LEFT", parent, "LEFT", resourceRatio * parent:GetWidth(), 0)
    tickFrame:SetFrameStrata("HIGH")
    
    tickFrame.texture = _G[frameName .. "_texture"] or tickFrame:CreateTexture(frameName .. "_texture")
    tickFrame.texture:SetAllPoints(tickFrame)
    tickFrame.texture:SetTexture(texture)
    tickFrame.texture:SetVertexColor(color.r, color.g, color.b, color.a)
    tickFrame:SetAlpha(0.5)
    tickFrame:Show()
    return tickFrame
end

local function InitializeText(barName, parent, positionConfig, font, size, flags, xOffset, yOffset, value, color)
    local frameName = "prd_" .. barName .. "_text_container"
    local textContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    textContainer:SetFrameStrata("DIALOG")
    textContainer:SetWidth(positionConfig.width)
    textContainer:SetHeight(positionConfig.height)
    textContainer:SetPoint(positionConfig.anchorPoint, parent, positionConfig.anchorPoint, 0, positionConfig.yOffset)
    textContainer:Show()

    local textFrameName = "prd_" .. barName .. "_text"
    local textFrame = _G[textFrameName] or textContainer:CreateFontString(textFrameName)

    textFrame:SetFont(font, size, flags)
    textFrame:SetTextColor(color.r, color.g, color.b, color.a)
    textFrame:SetPoint("CENTER", textContainer, "CENTER", xOffset, yOffset)
    textFrame:SetText(value)
    textFrame:SetAlpha(0.5)
    textFrame:Show()
    return textFrame
end

local function InitializeCache(configuration)
    local cache = {
        powerType = 0,
        currentPower = 0,
        maxPower = 0
    }

    cache.powerType = (type(configuration.powerType) == "function" and select(2, configuration.powerType(cache, "INITIAL"))) or configuration.powerType
    cache.currentPower = select(2, configuration.currentPower(cache, "INITIAL"))
    cache.maxPower = (type(configuration.maxPower) == "function" and select(2, configuration.maxPower(cache, "INITIAL"))) or configuration.maxPower
    return cache
end

local function InitializeProgressBar(barName, specBarConfig)
    local container = PRD.container
    local cache = InitializeCache(specBarConfig)
    local positionConfig = positionAndSizeConfig[barName]

    local barContainer = InitializeBarContainer(barName, container, positionConfig)

    local statusBarColor = type(specBarConfig.color) == "function" and select(2, specBarConfig.color(cache, "INITIAL")) or specBarConfig.color
    local statusBar = InitializeStatusBar(barName, barContainer, positionConfig, "MEDIUM", specBarConfig.texture, color)
    local backgroundBar = InitializeBackground(barName, barContainer)

    local text = specBarConfig.text
    local textEnabled = (type(text.enabled) == "function" and select(2, text.enabled(cache, "INITIAL"))) or text.enabled

    if textEnabled then
        local value = select(2, text.value(cache, "INITIAL"))
        local textColor = type(text.color) == "function" and select(2, text.color(cache, "INITIAL")) or text.color
        local textFrame = InitializeText(barName, barContainer, positionConfig, text.font, text.size, text.flags, text.xOffset, text.yOffset, value, textColor)
    end

    local predictionEnabled = (specBarConfig.prediction ~= nil) and (type(specBarConfig.prediction.enabled) == "function" and specBarConfig.prediction.enabled(cache, "INITIAL")) or specBarConfig.prediction.enabled
    if predictionEnabled then
        local statusBarColor = type(specBarConfig.color) == "function" and select(2, specBarConfig.color(cache, "INITIAL")) or specBarConfig.color
        local predictionBar = InitializeStatusBar(barName, barContainer, positionConfig, "LOW", specBarConfig.texture, color)
    end

    if specBarConfig.tickMarks ~= nil then
        local tickMarkContainer = InitializeTickMarkContainer(barName, barContainer, positionConfig.width, positionConfig.height)
        local texture = specBarConfig.tickMarks.texture
        local tickMarks = type(specBarConfig.tickMarks.offsets) == "function" and select(2, specBarConfig.tickMarks.offsets(cache, "INITIAL")) or specBarConfig.tickMarks.offsets

        for tickId, tickConfig in paris(tickMarks) do
            if tickConfig.enabled ~= false then
                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(specBarConfig.tickMarks.color) == "function" and specBarConfig.tickMarks.color(cache, "INITIAL")) or specBarConfig.tickMarks.color)
                local resourceRatio = ((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / cache.maxPower
                
                local tickMark = InitializeTickMark(barName, tickId, tickMarkContainer, positionConfig.tickWidth, texture, color, resourceRatio)
            end
        end
    end
end

local function NormalizeTickMarkOffsets(configs, commonColor)
    local normalizedConfigs = {}
    
    for k, v in pairs(configs) do
        if type(v) == "table" then
            v.enabled = v.enabled or true
            v.color = v.color or commonColor or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }

            if v.resourceValue_dependencies == nil then
                v.resourceValue_dependencies = { "maxPower" }
            else
                table.insert(v.resourceValue_dependencies, "maxPower")
            end

            normalizedConfigs[k] = v
        else
            normalizedConfigs[v] = {
                enabled = true,
                color = commonColor or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                resourceValue = v
            }
        end
    end

    return normalizedConfigs
end

local function GetConfiguration()
    configKey = PRD:GetConfigurationKey()
    PRD.currentSpecKey = configKey

    local playerPowerType = UnitPowerType("player")
    local powerTypeColor = PowerBarColor[playerPowerType]

    local defaultTextConfig = {
        enabled = true,
        value_dependencies = { "currentPower" },
        value = DefaultUpdateTextHandler,
        color = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
        font = "Fonts\\FRIZQT__.TTF",
        size = 14,
        flags = "OUTLINE",
        yOffset = 0,
        xOffset = 0
    } 

    local defaultPrimaryConfig = {
        enabled = true,
        powerType = playerPowerType,
        currentPower_events = { "UNIT_POWER_FREQUENT" },
        currentPower = DefaultUpdateCurrentPowerHandler,
        maxPower_events = { "UNIT_MAXPOWER" },
        maxPower = DefaultUpdateMaxPowerHandler,
        text = defaultTextConfig,
        color = { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, a = 1.0},
        texture = "Interface/Addons/SharedMedia/statusbar/Cilo"
    }

    if configKey == nil then
        return {
            primary = defaultPrimaryConfig
        }
    end

    local config = PRD.configurations[configKey]

    if config.primary == nil then
        config.primary = defaultPrimaryConfig
    elseif config.primary.text == nil then
        config.primary.text = defaultTextConfig
    end

    for barName, barConfig in pairs(config) do
        -- top level bar properties
        if barConfig.powerType == nil and barConfig.currentPower == nil and barConfig.maxPower == nil then
            barConfig.powerType = playerPowerType
        end

        if barConfig.currentPower == nil then
            barConfig.currentPower_events = { "UNIT_POWER_FREQUENT" }
            barConfig.currentPower = DefaultUpdateCurrentPowerHandler
        end
        
        if barConfig.maxPower == nil then
            barConfig.maxPower_events = { "UNIT_MAXPOWER" }
            barConfig.maxPower = DefaultUpdateMaxPowerHandler
        end

        -- if power type is a function current type must be reevaluated when it updates
        -- and maxPower must be reevaluated if it's a function. But I can't imagine
        -- a world where powerType is a function and maxPower isn't
        if (barConfig.powerType ~=nil and type(barConfig.powerType) == "function") then
            barConfig.currentPower_dependencies = { "powerType" }

            if type(barConfig.maxPower) == "function" then
                barConfig.maxPower_dependencies = { "powerType" }
            end
        end
        
        barConfig.color = barConfig.color == nil and { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, 1.0} or barConfig.color
        barConfig.texture = barConfig.texture == nil and "Interface/Addons/SharedMedia/statusbar/Cilo" or barConfig.texture

        -- prediction config defaults
        if barConfig.prediction ~= nil then
            local prediction = barConfig.prediction
            prediction.enabled = (prediction.enabled ~= nil and prediction.enabled) or true
            prediction.color = (prediction.color ~= nil and prediction.color) or { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, a = 0.75 }
        end

        -- text config defaults
        if barConfig.text ~= nil then
            local text = barConfig.text
            text.enabled = (text.enabled ~= nil and text.enabled) or true
            text.color = (text.color ~= nil and text.color) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
            text.font = (text.font ~= nil and text.font) or "Fonts\\FRIZQT__.TTF"
            text.size = (text.size ~= nil and text.size) or 14
            text.flags = (text.flags ~= nil and text.flags) or "OUTLINE"
            text.xOffset = (text.xOffset ~= nil and text.xOffset) or 0
            text.yOffset = (text.yOffset ~= nil and text.yOffset) or 0
            
            if text.value == nil then 
                text.value = DefaultUpdateTextHandler
                text.value_dependencies = { "currentPower" }
            end
        end

        -- tick mark config default
        if barConfig.tickMarks ~= nil then
            local tickMarks = barConfig.tickMarks
            tickMarks.texture = (tickMarks.texture ~= nil and tickMarks.texture) or "Interface/Addons/SharedMedia/statusbar/Aluminium"
            tickMarks.color = (tickMarks.color ~= nil and tickMarks.color) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }

            if type(tickMarks.offset) == "function" then
                if tickMarks.offsets_dependencies == nil then
                    tickMarks.offsets_dependencies = { "maxPower" }
                else
                    table.insert(tickMarks.offsets_dependencies, "maxPower")
                end
            elseif type(tickMarks.offsets) == "table" then
                tickMarks.offsets = NormalizeTickMarkOffsets(tickMarks.offsets, tickMarks.color)
            end
        end
    end
    
    return config
end

local function Clean()
    PRD.frameUpdates = {}

    for _, bar in ipairs({ PRD.container:GetChildren() }) do
        bar.dependencyHandlers = {}
        for _, frame in ipairs({ bar:GetChildren() }) do
            CleanFrameState(frame)
            if string.find(frame:GetName(), "tickMarkContainer") then
                for _, tickmark in ipairs({ frame:GetChildren() }) do
                    CleanFrameState(tickMark)
                end
            end
        end
    end
end

local function CleanFrameState(frame) 
    frame:UnregisterAllEvents()
    frame:Hide()
    frame.eventHandlers = {}
end

function PRD:GetConfigurationKey()
    local className = strlower(UnitClass("player"):gsub(" ", ""))
    local specializationName = select(2, GetSpecializationInfo(GetSpecialization()))

    local specClassKey = className .. "_" .. strlower(specializationName)
    if PRD.configurations[specClassKey] ~= nil then   
        return specClassKey
    elseif PRD.configurations[className] ~= nil then
        return className
    end
    
    return nil
end

function PRD:InitializePersonalResourceDisplay()
    Clean()

    local config = GetConfiguration()
    PRD:DebugPrint("normalized config", config)
    
    for progressBarName, progressBarConfig in pairs(config) do
        if type(progressBarConfig.enabled) == "function" or progressBarConfig.enabled then
            InitializeProgressBar(progressBarName, progressBarConfig)
        end
    end

    PRD:DebugPrint("PRD", PRD)
end
