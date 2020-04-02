local PRD = PRD

local positionAndSizeConfig = {
    primary = {
        anchorPoint = "LEFT",
        tickWidth = 3,
        height = PRD.height,
        width = PRD.width,
        yOffset = 0,
        inverseFill = false
    },
    top = {
        anchorPoint = "TOP",
        tickWidth = 2,
        height = PRD.height / 4,
        yOffset = PRD.height / 4,
        width = PRD.width,
        inverseFill = false
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
        inverseFill = false
    },
    bottom = {
        tickWidth = 2,
        anchorPoint = "BOTTOM",
        height = PRD.height / 4,
        width = PRD.width,
        yOffset = (-1 * (PRD.height / 4)),
        inverseFill = false
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
        yOffset = (-1 * (PRD.height / 4)),
        inverseFill = false
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


local function InitializeBarContainer(barName, parent, positionConfig)
    local frameName = "prd_" .. barName .. "_bar_container"
    local barContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    barContainer:SetWidth(positionConfig.width)
    barContainer:SetHeight(positionConfig.height)
    barContainer:SetPoint(positionConfig.anchorPoint, parent, positionConfig.anchorPoint, 0, positionConfig.yOffset)
    return barContainer
end

local function InitializeStatusBar(barName, parent, positionConfig, frameStrata, texture, color, resourceRatio, isShown)
    local frameName = "prd_" .. barName
    local statusBar = _G[frameName] or CreateFrame("StatusBar", frameName, parent)
    
    statusBar:SetWidth(positionConfig.width)
    statusBar:SetHeight(positionConfig.height)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(resourceRatio)
    statusBar:SetPoint("CENTER", parent, "CENTER", 0, 0)
    statusBar:SetFrameStrata(frameStrata)
    statusBar:SetStatusBarTexture(texture)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetReverseFill(positionConfig.inverseFill)
    statusBar:SetAlpha(0.5)

    if isShown then
        statusBar:Show()
    else
        statusBar:Hide()
    end

    return statusBar
end

local function InitializeBackground(barName, parent, positionConfig)
    local frameName = "prd_" .. barName .. "_background_bar"
    local backgroundFrame =  _G[frameName] or CreateFrame("Frame", frameName, parent)
    
    backgroundFrame:SetWidth(positionConfig.width)
    backgroundFrame:SetHeight(positionConfig.height)
    backgroundFrame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    backgroundFrame:SetFrameStrata("BACKGROUND")
    backgroundFrame:SetAlpha(0.5)
    backgroundFrame:Show()
    
    backgroundFrame.texture = _G[frameName .. "_texture"] or backgroundFrame:CreateTexture(frameName .. "_texture")
    backgroundFrame.texture:SetAllPoints(backgroundFrame)
    backgroundFrame.texture:SetColorTexture(0.0, 0.0, 0.0, 0.6)

    return backgroundFrame
end

local function InitializeText(barName, parent, positionConfig, font, size, flags, xOffset, yOffset, value, color, isShown)
    local frameName = "prd_" .. barName .. "_text_container"
    local textContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    textContainer:SetFrameStrata("DIALOG")
    textContainer:SetWidth(positionConfig.width)
    textContainer:SetHeight(positionConfig.height)
    textContainer:SetPoint("CENTER", parent, "CENTER", 0, 0)
    textContainer:Show()

    local textFrameName = "prd_" .. barName .. "_text"
    local textFrame = _G[textFrameName] or textContainer:CreateFontString(textFrameName)

    textFrame:SetFont(font, size, flags)
    textFrame:SetTextColor(color.r, color.g, color.b, color.a)
    textFrame:SetPoint("CENTER", textContainer, "CENTER", xOffset, yOffset)
    textFrame:SetText(value)
    textFrame:SetAlpha(0.5)
    textFrame:Show()

    if isShown then
        textFrame:Show()
    else
        textFrame:Hide()
    end

    return textFrame
end

local function InitializeTickMarkContainer(barName, parent, width, height)
    local frameName = "prd_" .. barName .. "_tick_mark_container"
    local tickMarkContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    tickMarkContainer:SetWidth(width)
    tickMarkContainer:SetHeight(height)
    tickMarkContainer:SetPoint("CENTER", parent, "CENTER", 0, 0)
    tickMarkContainer:SetFrameStrata("HIGH")
    tickMarkContainer:SetAlpha(0.5)
    tickMarkContainer:Show()
    return tickMarkContainer
end

local function InitializeTickMark(barName, tickId, parent, tickWidth, texture, color, resourceRatio, isShown)
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

    if isShown then
        tickFrame:Show()
    else
        tickFrame:Hide()
    end

    return tickFrame
end

local function NormalizeTickMarkOffsets(configs, commonColor)
    local normalizedConfigs = {}
    
    for k, v in pairs(configs) do
        if type(v) == "table" then
            v.enabled = v.enabled == nil or v.enabled
            v.color = v.color or (type(commonColor) == "table" and commonColor) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }

            if v.resourceValue_dependencies == nil then
                v.resourceValue_dependencies = { "maxPower" }
            else
                table.insert(v.resourceValue_dependencies, "maxPower")
            end

            normalizedConfigs[k] = v
        else
            normalizedConfigs[v] = {
                enabled = true,
                color = (type(commonColor) == "table" and commonColor) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 },
                resourceValue = v
            }
        end
    end

    return normalizedConfigs
end

local function InitializeProgressBar(barName, specBarConfig)
    local container = PRD.container
    local cache = InitializeCache(specBarConfig)
    local positionConfig = positionAndSizeConfig[barName]
    local barContainer = InitializeBarContainer(barName, container, positionConfig)

    PRD.bars[barName] = {}

    -- initialize status bar 
    local statusBarColor = type(specBarConfig.color) == "function" and select(2, specBarConfig.color(cache, "INITIAL")) or specBarConfig.color
    local statusBar = InitializeStatusBar(barName .. "_main_bar", barContainer, positionConfig, "MEDIUM", specBarConfig.texture, statusBarColor, cache.currentPower / cache.maxPower, true)
    PRD.bars[barName][statusBar:GetName()] = statusBar

    local backgroundBar = InitializeBackground(barName, barContainer, positionConfig)

    local text = specBarConfig.text

    if text.enabled ~= false then
        local isShown = text.enabled
        if type(text.enabled) == "function" then
            isShown = select(2, text.enabled(cache, "INITIAL"))
        end

        local value = select(2, text.value(cache, "INITIAL"))
        local textColor = type(text.color) == "function" and select(2, text.color(cache, "INITIAL")) or text.color
        local textFrame = InitializeText(barName, barContainer, positionConfig, text.font, text.size, text.flags, text.xOffset, text.yOffset, value, textColor, isShown)
        PRD.bars[barName][textFrame:GetName()] = textFrame
    end

    local predictionBar = specBarConfig.prediction
    if predictionBar.enabled ~= false then
        local isShown = predictionBar.enabled
        if type(predictionBar.enabled) == "function" then
            isShown = select(2, predictionBar.enabled(cache, "INITIAL"))
        end

        local predictionBarResourceRatio = select(2, predictionBar.next(cache, "INITIAL")) / cache.maxPower
        local predictionBarColor = type(predictionBar.color) == "function" and select(2, predictionBar.color(cache, "INITIAL")) or predictionBar.color
        local predictionBar = InitializeStatusBar(barName .. "_prediction_bar", barContainer, positionConfig, "LOW", specBarConfig.texture, predictionBarColor, predictionBarResourceRatio, isShown)
        PRD.bars[barName][predictionBar:GetName()] = predictionBar
    end

    if specBarConfig.enabled ~= false then
        local tickMarkContainer = InitializeTickMarkContainer(barName, barContainer, positionConfig.width, positionConfig.height)
        tickMarkContainer.barName = barName
        PRD.bars[barName][tickMarkContainer:GetName()] = tickMarkContainer
        
        local texture = specBarConfig.tickMarks.texture
        local tickMarks = (type(specBarConfig.tickMarks.offsets) == "function" and NormalizeTickMarkOffsets(select(2, specBarConfig.tickMarks.offsets(cache, "INITIAL")), specBarConfig.tickMarks.color)) or specBarConfig.tickMarks.offsets

        for tickId, tickConfig in pairs(tickMarks) do
            if tickConfig.enabled ~= false then
                local isShown = tickConfig.enabled
                if type(tickConfig.enabled) == "function" then
                    isShown = select(2, tickConfig.enabled(cache, "INITIAL"))
                end

                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(specBarConfig.tickMarks.color) == "function" and specBarConfig.tickMarks.color(cache, "INITIAL")) or specBarConfig.tickMarks.color)
                local resourceRatio = ((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / cache.maxPower
                local tickMark = InitializeTickMark(barName, tickId, tickMarkContainer, positionConfig.tickWidth, texture, color, resourceRatio, isShown)
                PRD.bars[barName][tickMark:GetName()] = tickMark
            end
        end
    end
end

-- event and dependency setup
-- powerType function doesn't actually influence any properties directly
-- but current and max power are dependent on it so we need to trigger those
local function RefreshPowerType(eventHandler, self, event, ...)
    return false
end

local function RefreshCurrentPowerValue(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetValue(newValue / self.cache.maxPower)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshMaxPowerValue(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetValue(newValue / self.cache.maxPower)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshText(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetText(newValue)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshEnabled(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        if newValue then
            self:Show()
        else 
            self:Hide()
        end
    end

    return shouldUpdate and frameUpdates
end

local function RefreshBarColor(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTextColor(eventHandler, self, event, ...) 
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetTextColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarksColor(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        for _, tickMark in ipairs({ self:GetChildren() }) do
            tickMark:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        end
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarkColor(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarkXOffset(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, eventHandler, nil

    if type(eventHandler) == "function" then
        shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)
    end

    if shouldUpdate then
        self:SetPoint("LEFT", self.main, "LEFT", (newValue / self.cache.maxPower) * PRD.width, 0)
    end

    return shouldUpdate and frameUpdates
end

local function GetExistingTickMark(name, self)
    for _, child in ipairs({ self:GetChildren() }) do
        if child:GetName() == name then
            return child
        end
    end

    return child
end

local function RefreshTickMarkOffsets(eventHandler, self, event, ...)
    local barPositionConfig = positionAndSizeConfig[self.barName]
    local barConfiguration = GetConfiguration()[self.barName]
    local shouldUpdate, newValue, frameUpdates = true, eventHandler, nil

    if type(eventHandler) == "function" then
        shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)
    end

    if shouldUpdate then
        for _, tickMark in ipairs({ self:GetChildren() }) do
            tickMark:Hide()
        end

        for index, tickConfig in pairs(NormalizeTickMarkOffsets(newValue, barConfiguration.tickMarks.color)) do
            local tickMarkName = "prd_" .. self.barName .. "_tick_mark_" .. index
            local tickMark = GetExistingTickMark(tickMarkName, self)
            local resourceRatio = ((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / self.cache.maxPower

            if tickMark == nil then
                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(barConfiguration.tickMarks.color) == "function" and barConfiguration.tickMarks.color(cache, "INITIAL")) or barConfiguration.tickMarks.color)
                local isShown = true 
                if type(tickConfig.enabled) == "function" then
                    isShown = select(2, tickConfig.enabled(cache, "INITIAL"))
                end

                local tickMark = InitializeTickMark(barName, tickId, tickMarkContainer, positionConfig.tickWidth, texture, color, resourceRatio, isShown)
                PRD.bars[barName][tickMark:GetName()] = tickMark
            else
                tickMark:SetPoint("LEFT", parent, "LEFT", (index / self.cache.maxPower) * PRD.width, 0)
            end

        end
    end

    return shouldUpdate and frameUpdates
end

local function DistributeEvent(self, event, ...)
    if self.eventHandlers[event] == nil then return end
    PRD:HandleEvent(self.eventHandlers[event], event, ...)
end

local function BuildEventAndDependencyConfigs(events, dependencies, frame, property, eventHandler, updater, barName)
    if events ~= nil then
        frame:SetScript("OnEvent", DistributeEvent)

        if frame.eventHandlers == nil then frame.eventHandlers = {} end

        for _, event in ipairs(events) do
            if frame:IsEventRegistered(event) == nil then
                frame:RegisterEvent(event)
            end

            if frame.eventHandlers[event] == nil then
                frame.eventHandlers[event] = {}
            end

            table.insert(frame.eventHandlers[event], {
                property = property,
                eventHandler = eventHandler, 
                updater = updater,
                self = frame
            })
        end
    end 

    if dependencies ~= nil then 
        local mainBarFrame = PRD.bars[barName]["prd_" .. barName .. "_main_bar"]

        local sourceFrameMap = {
            powerType = mainBarFrame,
            currentPower = mainBarFrame,
            maxPower = mainBarFrame,
            next = PRD.bars[barName]["prd_" .. barName .. "_prediction_bar"]
        }
    
        for _, dependency in ipairs(dependencies) do
            local targetFrame = sourceFrameMap[dependency]
    
            if targetFrame.dependencyHandlers == nil then targetFrame.dependencyHandlers = {} end
    
            if targetFrame.dependencyHandlers[dependency] == nil then
                targetFrame.dependencyHandlers[dependency] = {}
            end
    
            table.insert(targetFrame.dependencyHandlers[dependency], {
                property = property,
                eventHandler = eventHandler, 
                updater = updater,
                self = frame
            })
        end
    end 
end

local function GatherEventAndDependencyHandlers(barName, barConfig)
    local mainBarFrame = PRD.bars[barName]["prd_" .. barName .. "_main_bar"]
    local predictionBarFrame = PRD.bars[barName]["prd_" .. barName .. "_prediction_bar"]
    local textFrame = PRD.bars[barName]["prd_" .. barName .. "_text"]
    local tickMarkOffsetsFrame = PRD.bars[barName]["prd_" .. barName .. "_tick_mark_container"]

    -- Main
    if type(barConfig.powerType) == "function" then
        -- power type will never have dependencies
        BuildEventAndDependencyConfigs(barConfig.powerType_events, barConfig.powerType_dependencies, mainBarFrame, 'powerType', barConfig.powerType, RefreshPowerType, barName)
    end

    if type(barConfig.currentPower) == "function" then
        BuildEventAndDependencyConfigs(barConfig.currentPower_events, barConfig.currentPower_dependencies, mainBarFrame, 'currentPower', barConfig.currentPower, RefreshCurrentPowerValue, barName)
    end

    if type(barConfig.maxPower) == "function" then
        BuildEventAndDependencyConfigs(barConfig.maxPower_events, barConfig.maxPower_dependencies, mainBarFrame, 'maxPower', barConfig.maxPower, RefreshMaxPowerValue, barName)
    end

    if type(barConfig.color) == "function" then
        BuildEventAndDependencyConfigs(barConfig.color_events, barConfig.color_dependencies, mainBarFrame, 'mainColor', barConfig.color, RefreshBarColor, barName)
    end

    -- prediction
    if type(barConfig.prediction.enabled) == "function" then
        BuildEventAndDependencyConfigs(barConfig.prediction.enabled_events, barConfig.prediction.enabled_dependencies, predictionBarFrame, 'predictionEnabled', barConfig.prediction.enabled, RefreshEnabled, barName)
    end

    if type(barConfig.prediction.color) == "function" then
        BuildEventAndDependencyConfigs(barConfig.prediction.color_events, barConfig.prediction.color_dependencies, predictionBarFrame, 'predictionColor', barConfig.prediction.color, RefreshBarColor, barName)         
    end

    if type(barConfig.prediction.next) == "function" then
        BuildEventAndDependencyConfigs(barConfig.prediction.next_events, barConfig.prediction.next_dependencies, predictionBarFrame, 'next', barConfig.prediction.next, RefreshCurrentPowerValue, barName)
    end

    -- text
    if type(barConfig.text.enabled) == "function" then
        BuildEventAndDependencyConfigs(barConfig.text.enabled_events, barConfig.text.enabled_dependencies, textFrame, 'textEnabled', barConfig.text.enabled, RefreshEnabled, barName)
    end

    if type(barConfig.text.value) == "function" then
        BuildEventAndDependencyConfigs(barConfig.text.value_events, barConfig.text.value_dependencies, textFrame, 'textValue', barConfig.text.value, RefreshText, barName)
    end

    if type(barConfig.text.color) == "function" then
        BuildEventAndDependencyConfigs(barConfig.text.color_events, barConfig.text.color_dependencies, textFrame, 'textColor', barConfig.text.color, RefreshTextColor, barName)
    end

    -- generic tick mark
    if type(barConfig.tickMarks.color) == "function" then
        BuildEventAndDependencyConfigs(barConfig.tickMarks.color_events, barConfig.tickMarks.color_dependencies, tickMarkOffsetsFrame, 'tickMarksColor', barConfig.tickMarks.color, RefreshTickMarksColor, barName)
    end

    if type(barConfig.tickMarks.offsets) == "function" then
        BuildEventAndDependencyConfigs(barConfig.tickMarks.offsets_events, barConfig.tickMarks.offsets_dependencies, tickMarkOffsetsFrame, 'offsets', barConfig.tickMarks.offsets, RefreshTickMarkOffsets, barName)
    elseif type(barConfig.tickMarks.offsets) == "table" then
        for tickId, tickConfig in pairs(barConfig.tickMarks.offsets) do
            local tickMarkFrame = PRD.bars[barName]["prd_" .. barName .. "_tick_mark_" .. tickId]

            -- all tick marks have a dependency on maxPower even if they are a static value
            BuildEventAndDependencyConfigs(tickConfig.resourceValue_events, tickConfig.resourceValue_dependencies, tickMarkFrame, tickId .. "ResourceValue", tickConfig.resourceValue, RefreshTickMarkXOffset, barName)

            -- individual tick marks
            if type(tickConfig.enabled) == "function" then
                BuildEventAndDependencyConfigs(tickConfig.enabled_events, tickConfig.enabled_dependencies, tickMarkFrame, tickId .. "Enabled", tickConfig.enabled, RefreshEnabled, barName)   
            end

            if type(tickConfig.color) == "function" then
                BuildEventAndDependencyConfigs(tickConfig.color_events, tickConfig.color_dependencies, tickMarkFrame, tickId .. "Color", tickConfig.color, RefreshTickMarkColor, barName)
            end
        end
    end
end

-- Getting and normalizing the configuration
local function GetConfiguration()
    configKey = PRD:GetConfigurationKey()
    PRD.currentSpecKey = configKey

    local playerPowerType = UnitPowerType("player")
    local powerTypeColor = PowerBarColor[playerPowerType]

    local defaultTextConfig = {
        enabled = true,
        value_dependencies = { "currentPower", "maxPower" },
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
        if (barConfig.powerType ~= nil and type(barConfig.powerType) == "function") then
            barConfig.currentPower_dependencies = { "powerType" }

            if type(barConfig.maxPower) == "function" then
                barConfig.maxPower_dependencies = { "powerType" }
            end
        end
        
        barConfig.enabled = barConfig.enabled == nil or barConfig.enabled
        barConfig.color = barConfig.color == nil and { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, 1.0} or barConfig.color
        barConfig.texture = barConfig.texture == nil and "Interface/Addons/SharedMedia/statusbar/Cilo" or barConfig.texture

        -- prediction config defaults
        if barConfig.prediction ~= nil then
            local prediction = barConfig.prediction
            prediction.enabled = prediction.enabled == nil or prediction.enabled
            prediction.color = (prediction.color ~= nil and prediction.color) or { r = barConfig.color.r, g = barConfig.color.g, b = barConfig.color.b, a = 0.75 }
        else 
            barConfig.prediction = {
                enabled = false
            }
        end

        -- text config defaults
        if barConfig.text ~= nil then
            local text = barConfig.text

            text.enabled = text.enabled == nil or text.enabled
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
        else 
            barConfig.text = {
                enabled = false
            }
        end

        -- tick mark config default
        if barConfig.tickMarks ~= nil then
            local tickMarks = barConfig.tickMarks
            tickMarks.texture = (tickMarks.texture ~= nil and tickMarks.texture) or "Interface/Addons/SharedMedia/statusbar/Aluminium"
            tickMarks.color = (tickMarks.color ~= nil and tickMarks.color) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }

            if type(tickMarks.offsets) == "function" then
                if tickMarks.offsets_dependencies == nil then
                    tickMarks.offsets_dependencies = { "maxPower" }
                else
                    table.insert(tickMarks.offsets_dependencies, "maxPower")
                end
            elseif type(tickMarks.offsets) == "table" then
                tickMarks.offsets = NormalizeTickMarkOffsets(tickMarks.offsets, tickMarks.color)
            end
        else 
            barConfig.tickMarks = {
                enabled = false
            }
        end
    end
    
    return config
end


local function CleanFrameState(frame) 
    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(nil)
    frame.eventHandlers = {}
    frame.dependencyHandlers = {}
end

local function Clean()
    for barName, frames in ipairs(PRD.bars) do
        for _, frame in pairs(frames) do
            CleanFrameState(frame)
            if string.find(frame:GetName(), "_tick_mark_container") then
                for _, tickMark in ipairs({ frame:GetChildren() }) do
                    CleanFrameState(tickMark)
                end
            end
        end
    end

    PRD.frameUpdates = {}
    PRD.bars = {}
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
    
    for progressBarName, progressBarConfig in pairs(config) do
        if type(progressBarConfig.enabled) == "function" or progressBarConfig.enabled then
            InitializeProgressBar(progressBarName, progressBarConfig)
            GatherEventAndDependencyHandlers(progressBarName, progressBarConfig)
        end
    end

    PRD:DebugPrint("PRD", PRD)
end
