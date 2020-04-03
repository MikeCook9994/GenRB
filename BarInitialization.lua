local PRD = PRD

PRD.DefaultUpdateCurrentPowerHandler = function(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.currentPower = UnitPower("player", cache.powerType)
        return true, cache.currentPower
    end

    return false, cache.currentPower
end

PRD.DefaultUpdateMaxPowerHandler = function(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.maxPower = UnitPowerMax("player", cache.powerType)
        return true, cache.maxPower
    end

    return false, cache.maxPower
end

PRD.DefaultUpdateTextHandler = function(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and PRD:ConvertPowerTypeStringToEnumValue(powerType) == cache.powerType) then
        -- if it's mana power type, format as percent by default
        if cache.powerType == Enum.PowerType.Mana then
            return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
        end

        return true, cache.currentPower
    end

    return false, cache.currentPower
end

function PRD:NormalizeTickMarkOffsets(configs, commonColor)
    local normalizedConfigs = {}
    
    for k, v in pairs(configs) do
        if type(v) == "table" then
            v.enabled = v.enabled == nil or v.enabled
            v.color = v.color or (type(commonColor) == "table" and commonColor) or { r = 1.0, g = 1.0, b = 1.0 }

            if v.resourceValue_dependencies == nil then
                v.resourceValue_dependencies = { "maxPower" }
            else
                table.insert(v.resourceValue_dependencies, "maxPower")
            end

            normalizedConfigs[k] = v
        else
            normalizedConfigs[v] = {
                enabled = true,
                color = (type(commonColor) == "table" and commonColor) or { r = 1.0, g = 1.0, b = 1.0 },
                resourceValue = v
            }
        end
    end

    return normalizedConfigs
end

function PRD:GetConfiguration()
    configKey = PRD:GetConfigurationKey()
    PRD.currentSpecKey = configKey

    local playerPowerType = UnitPowerType("player")
    local powerTypeColor = PowerBarColor[playerPowerType]

    local defaultTextConfig = {
        enabled = true,
        value_dependencies = { "currentPower", "maxPower" },
        value = PRD.DefaultUpdateTextHandler,
        color = { r = 1.0, g = 1.0, b = 1.0 },
        font = "Fonts\\FRIZQT__.TTF",
        size = 10,
        flags = "OUTLINE",
        yOffset = 0,
        xOffset = 0
    } 

    local defaultPrimaryConfig = {
        enabled = true,
        powerType = playerPowerType,
        currentPower_events = { "UNIT_POWER_FREQUENT" },
        currentPower = PRD.DefaultUpdateCurrentPowerHandler,
        maxPower_events = { "UNIT_MAXPOWER" },
        maxPower = PRD.DefaultUpdateMaxPowerHandler,
        text = defaultTextConfig,
        color = { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b },
        texture = "Interface/Addons/SharedMedia/statusbar/Cilo",
        prediction = {
            enabled = false,
        },
        tickMarks = {
            enabled = false
        }
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
            barConfig.currentPower = PRD.DefaultUpdateCurrentPowerHandler
        end
        
        if barConfig.maxPower == nil then
            barConfig.maxPower_events = { "UNIT_MAXPOWER" }
            barConfig.maxPower = PRD.DefaultUpdateMaxPowerHandler
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
        barConfig.color = barConfig.color == nil and { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b } or barConfig.color
        barConfig.texture = barConfig.texture == nil and "Interface/Addons/SharedMedia/statusbar/Cilo" or barConfig.texture

        -- prediction config defaults
        if barConfig.prediction ~= nil then
            local prediction = barConfig.prediction
            prediction.enabled = prediction.enabled == nil or prediction.enabled
            prediction.color = (prediction.color ~= nil and prediction.color) or (type(barConfig.color) == "function" and barConfig.color) or { r = barConfig.color.r, g = barConfig.color.g, b = barConfig.color.b }
        else 
            barConfig.prediction = {
                enabled = false
            }
        end

        -- text config defaults
        if barConfig.text ~= nil then
            local text = barConfig.text

            text.enabled = text.enabled == nil or text.enabled
            text.color = (text.color ~= nil and text.color) or { r = 1.0, g = 1.0, b = 1.0 }
            text.font = (text.font ~= nil and text.font) or "Fonts\\FRIZQT__.TTF"
            text.size = (text.size ~= nil and text.size) or 10
            text.flags = (text.flags ~= nil and text.flags) or "OUTLINE"
            text.xOffset = (text.xOffset ~= nil and text.xOffset) or 0
            text.yOffset = (text.yOffset ~= nil and text.yOffset) or 0
            
            if text.value == nil then 
                text.value = PRD.DefaultUpdateTextHandler
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
            tickMarks.color = (tickMarks.color ~= nil and tickMarks.color) or { r = 1.0, g = 1.0, b = 1.0 }

            if type(tickMarks.offsets) == "function" then
                if tickMarks.offsets_dependencies == nil then
                    tickMarks.offsets_dependencies = { "maxPower" }
                else
                    table.insert(tickMarks.offsets_dependencies, "maxPower")
                end
            elseif type(tickMarks.offsets) == "table" then
                tickMarks.offsets = PRD:NormalizeTickMarkOffsets(tickMarks.offsets, tickMarks.color)
            end
        else 
            barConfig.tickMarks = {
                enabled = false
            }
        end
    end
    
    return config
end

function PRD:InitializeCache(configuration)
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

function PRD:InitializeBarContainer(barName, parent, positionConfig)
    local frameName = "prd_" .. barName .. "_bar_container"
    local barContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    barContainer:SetParent(parent)
    barContainer:SetWidth(positionConfig.width)
    barContainer:SetHeight(positionConfig.height)
    barContainer:SetPoint(positionConfig.anchorPoint, parent, positionConfig.anchorPoint, 0, positionConfig.yOffset)
    return barContainer
end

function PRD:InitializeStatusBar(barName, parent, positionConfig, frameStrata, texture, color, resourceRatio, isShown)
    local frameName = "prd_" .. barName
    local statusBar = _G[frameName] or CreateFrame("StatusBar", frameName, parent)
    
    statusBar:SetParent(parent)
    statusBar:SetWidth(positionConfig.width)
    statusBar:SetHeight(positionConfig.height)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(resourceRatio)
    statusBar:SetPoint("CENTER", parent, "CENTER", 0, 0)
    statusBar:SetFrameStrata(frameStrata)
    statusBar:SetStatusBarTexture(texture)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, 1.0)
    statusBar:SetReverseFill(positionConfig.inverseFill)

    if isShown then
        statusBar:Show()
    else
        statusBar:Hide()
    end

    return statusBar
end

function PRD:InitializeBackground(barName, parent, positionConfig)
    local frameName = "prd_" .. barName .. "_background_bar"
    local backgroundFrame =  _G[frameName] or CreateFrame("Frame", frameName, parent)
    
    backgroundFrame:SetParent(parent)
    backgroundFrame:SetWidth(positionConfig.width)
    backgroundFrame:SetHeight(positionConfig.height)
    backgroundFrame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    backgroundFrame:SetFrameStrata("BACKGROUND")
    backgroundFrame:Show()
    
    backgroundFrame.texture = _G[frameName .. "_texture"] or backgroundFrame:CreateTexture(frameName .. "_texture")
    backgroundFrame.texture:SetAllPoints(backgroundFrame)
    backgroundFrame.texture:SetColorTexture(0.0, 0.0, 0.0, 1.0)

    return backgroundFrame
end

function PRD:InitializeText(barName, parent, positionConfig, font, size, flags, xOffset, yOffset, value, color, isShown)
    local frameName = "prd_" .. barName .. "_text_container"
    local textContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    textContainer:SetParent(parent)
    textContainer:SetFrameStrata("DIALOG")
    textContainer:SetWidth(positionConfig.width)
    textContainer:SetHeight(positionConfig.height)
    textContainer:SetPoint("CENTER", parent, "CENTER", 0, 0)
    textContainer:Show()

    if isShown then
        textContainer:Show()
    else
        textContainer:Hide()
    end
    
    local textFrameName = "prd_" .. barName .. "_text"
    local textFrame = _G[textFrameName] or textContainer:CreateFontString(textFrameName)
    textContainer.text = textFrame

    textFrame:SetParent(textContainer)
    textFrame:SetFont(font, size, flags)
    textFrame:SetTextColor(color.r, color.g, color.b, 1.0)
    textFrame:SetPoint("CENTER", textContainer, "CENTER", xOffset, yOffset)
    textFrame:SetText(value)
    textFrame:Show()
    return textContainer
end

function PRD:InitializeTickMarkContainer(barName, parent, width, height)
    local frameName = "prd_" .. barName .. "_tick_mark_container"
    local tickMarkContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    tickMarkContainer:SetParent(parent)
    tickMarkContainer:SetWidth(width)
    tickMarkContainer:SetHeight(height)
    tickMarkContainer:SetPoint("CENTER", parent, "CENTER", 0, 0)
    tickMarkContainer:SetFrameStrata("HIGH")
    tickMarkContainer:Show()
    return tickMarkContainer
end

function PRD:InitializeTickMark(barName, tickId, parent, tickWidth, texture, color, resourceRatio, isShown)
    local frameName = "prd_" .. barName .. "_tick_mark_" .. tickId
    local tickFrame = _G[frameName] or CreateFrame("Frame", frameName, parent)
    
    tickFrame:SetParent(parent)
    tickFrame:SetWidth(tickWidth)
    tickFrame:SetHeight(parent:GetHeight())
    tickFrame:SetPoint("LEFT", parent, "LEFT", resourceRatio * parent:GetWidth(), 0)
    tickFrame:SetFrameStrata("HIGH")
    
    tickFrame.texture = _G[frameName .. "_texture"] or tickFrame:CreateTexture(frameName .. "_texture")
    tickFrame.texture:SetAllPoints(tickFrame)
    tickFrame.texture:SetTexture(texture)
    tickFrame.texture:SetVertexColor(color.r, color.g, color.b, 1.0)

    if isShown then
        tickFrame:Show()
    else
        tickFrame:Hide()
    end

    return tickFrame
end

function PRD:InitializeProgressBar(barName, specBarConfig)
    local container = PRD.container
    local cache = PRD:InitializeCache(specBarConfig)
    local positionConfig = PRD.positionAndSizeConfig[barName]
    local barContainer = PRD:InitializeBarContainer(barName, container, positionConfig)

    PRD.bars[barName] = {}

    -- initialize status bar
    local statusBarColor = type(specBarConfig.color) == "function" and select(2, specBarConfig.color(cache, "INITIAL")) or specBarConfig.color
    local statusBar = PRD:InitializeStatusBar(barName .. "_main_bar", barContainer, positionConfig, "MEDIUM", specBarConfig.texture, statusBarColor, cache.currentPower / cache.maxPower, true)
    statusBar.cache = cache
    PRD.bars[barName][statusBar:GetName()] = statusBar

    local backgroundBar = PRD:InitializeBackground(barName, barContainer, positionConfig)
    PRD.bars[barName][backgroundBar:GetName()] = backgroundBar


    local text = specBarConfig.text

    if text.enabled ~= false then
        local isShown = text.enabled
        if type(text.enabled) == "function" then
            isShown = select(2, text.enabled(cache, "INITIAL"))
        end

        local value = select(2, text.value(cache, "INITIAL"))
        local textColor = type(text.color) == "function" and select(2, text.color(cache, "INITIAL")) or text.color
        local textFrame = PRD:InitializeText(barName, barContainer, positionConfig, text.font, text.size, text.flags, text.xOffset, text.yOffset, value, textColor, isShown)
        textFrame.cache = cache
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
        local predictionBar = PRD:InitializeStatusBar(barName .. "_prediction_bar", barContainer, positionConfig, "LOW", specBarConfig.texture, predictionBarColor, predictionBarResourceRatio, isShown)
        predictionBar:SetAlpha(0.75)
        predictionBar.cache = cache
        PRD.bars[barName][predictionBar:GetName()] = predictionBar
    end

    if specBarConfig.tickMarks.enabled ~= false then
        local tickMarkContainer = PRD:InitializeTickMarkContainer(barName, barContainer, positionConfig.width, positionConfig.height)
        tickMarkContainer.barName = barName
        tickMarkContainer.cache = cache
        PRD.bars[barName][tickMarkContainer:GetName()] = tickMarkContainer
        
        local texture = specBarConfig.tickMarks.texture
        local tickMarks = (type(specBarConfig.tickMarks.offsets) == "function" and PRD:NormalizeTickMarkOffsets(select(2, specBarConfig.tickMarks.offsets(cache, "INITIAL")), specBarConfig.tickMarks.color)) or specBarConfig.tickMarks.offsets

        for tickId, tickConfig in pairs(tickMarks) do
            if tickConfig.enabled ~= false then
                local isShown = tickConfig.enabled
                if type(tickConfig.enabled) == "function" then
                    isShown = select(2, tickConfig.enabled(cache, "INITIAL"))
                end

                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(specBarConfig.tickMarks.color) == "function" and specBarConfig.tickMarks.color(cache, "INITIAL")) or specBarConfig.tickMarks.color)
                local resourceRatio = ((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / cache.maxPower
                local tickMark = PRD:InitializeTickMark(barName, tickId, tickMarkContainer, positionConfig.tickWidth, texture, color, resourceRatio, isShown)
                tickMark.cache = cache
                PRD.bars[barName][tickMark:GetName()] = tickMark
            end
        end
    end
end

function PRD:BuildEventAndDependencyConfigs(events, dependencies, frame, property, eventHandler, updater, barName)
    if events ~= nil then
        frame:SetScript("OnEvent", function(self, event, ...)
            if self.eventHandlers[event] == nil then return end
            
            if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                PRD:HandleEvent(self.eventHandlers[event], event, CombatLogGetCurrentEventInfo()) 
            end

            PRD:HandleEvent(self.eventHandlers[event], event, ...)
        end)

        if frame.eventHandlers == nil then frame.eventHandlers = {} end

        for _, event in ipairs(events) do
            if not frame:IsEventRegistered(event) then
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

function PRD:GatherEventAndDependencyHandlers(barName, barConfig)
    local mainBarFrame = PRD.bars[barName]["prd_" .. barName .. "_main_bar"]
    local predictionBarFrame = PRD.bars[barName]["prd_" .. barName .. "_prediction_bar"]
    local textContainerFrame = PRD.bars[barName]["prd_" .. barName .. "_text_container"]
    local tickMarkOffsetsFrame = PRD.bars[barName]["prd_" .. barName .. "_tick_mark_container"]

    -- Main
    if type(barConfig.powerType) == "function" then
        -- power type will never have dependencies
        PRD:BuildEventAndDependencyConfigs(barConfig.powerType_events, barConfig.powerType_dependencies, mainBarFrame, 'powerType', barConfig.powerType, PRD.RefreshPowerType, barName)
    end

    if type(barConfig.currentPower) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.currentPower_events, barConfig.currentPower_dependencies, mainBarFrame, 'currentPower', barConfig.currentPower, PRD.RefreshCurrentPowerValue, barName)
    end

    if type(barConfig.maxPower) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.maxPower_events, barConfig.maxPower_dependencies, mainBarFrame, 'maxPower', barConfig.maxPower, PRD.RefreshMaxPowerValue, barName)
    end

    if type(barConfig.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.color_events, barConfig.color_dependencies, mainBarFrame, 'mainColor', barConfig.color, PRD.RefreshBarColor, barName)
    end

    -- prediction
    if type(barConfig.prediction.enabled) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.prediction.enabled_events, barConfig.prediction.enabled_dependencies, predictionBarFrame, 'predictionEnabled', barConfig.prediction.enabled, PRD.RefreshEnabled, barName)
    end

    if type(barConfig.prediction.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.prediction.color_events, barConfig.prediction.color_dependencies, predictionBarFrame, 'predictionColor', barConfig.prediction.color, PRD.RefreshBarColor, barName)         
    end

    if type(barConfig.prediction.next) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.prediction.next_events, barConfig.prediction.next_dependencies, predictionBarFrame, 'next', barConfig.prediction.next, PRD.RefreshCurrentPowerValue, barName)
    end

    -- text
    if type(barConfig.text.enabled) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.text.enabled_events, barConfig.text.enabled_dependencies, textContainerFrame, 'textEnabled', barConfig.text.enabled, PRD.RefreshEnabled, barName)
    end

    if type(barConfig.text.value) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.text.value_events, barConfig.text.value_dependencies, textContainerFrame, 'textValue', barConfig.text.value, PRD.RefreshText, barName)
    end

    if type(barConfig.text.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.text.color_events, barConfig.text.color_dependencies, textContainerFrame, 'textColor', barConfig.text.color, PRD.RefreshTextColor, barName)
    end

    -- generic tick mark
    if type(barConfig.tickMarks.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.tickMarks.color_events, barConfig.tickMarks.color_dependencies, tickMarkOffsetsFrame, 'tickMarksColor', barConfig.tickMarks.color, PRD.RefreshTickMarksColor, barName)
    end

    if type(barConfig.tickMarks.offsets) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.tickMarks.offsets_events, barConfig.tickMarks.offsets_dependencies, tickMarkOffsetsFrame, 'offsets', barConfig.tickMarks.offsets, PRD.RefreshTickMarkOffsets, barName)
    elseif type(barConfig.tickMarks.offsets) == "table" then
        for tickId, tickConfig in pairs(barConfig.tickMarks.offsets) do
            local tickMarkFrame = PRD.bars[barName]["prd_" .. barName .. "_tick_mark_" .. tickId]

            -- all tick marks have a dependency on maxPower even if they are a static value
            PRD:BuildEventAndDependencyConfigs(tickConfig.resourceValue_events, tickConfig.resourceValue_dependencies, tickMarkFrame, tickId .. "ResourceValue", tickConfig.resourceValue, PRD.RefreshTickMarkXOffset, barName)

            -- individual tick marks
            if type(tickConfig.enabled) == "function" then
                PRD:BuildEventAndDependencyConfigs(tickConfig.enabled_events, tickConfig.enabled_dependencies, tickMarkFrame, tickId .. "Enabled", tickConfig.enabled, PRD.RefreshEnabled, barName)   
            end

            if type(tickConfig.color) == "function" then
                PRD:BuildEventAndDependencyConfigs(tickConfig.color_events, tickConfig.color_dependencies, tickMarkFrame, tickId .. "Color", tickConfig.color, PRD.RefreshTickMarkColor, barName)
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
            PRD:CleanFrameState(frame)
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
    for progressBarName, progressBarConfig in pairs(PRD:GetConfiguration()) do
        if type(progressBarConfig.enabled) == "function" or progressBarConfig.enabled then
            PRD:InitializeProgressBar(progressBarName, progressBarConfig)
            PRD:HandleCombatStateChangeEvent("INITAL")
            PRD:GatherEventAndDependencyHandlers(progressBarName, progressBarConfig)
        end
    end
end
