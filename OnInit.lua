local this = {
    region = nil,
    currentSpecKey = nil,
    debugEnabled = true,
    progressBars = {},
    progressBarPositionAndSizeConfiguration = {},
    eventHandlers = {},
    dependencyHandlers = {},
    frameUpdates = {}
}

-- static value resolvers

function NormalizeTickMarkOffsets(configs, cache)
    local normalizedConfigs = {}
    
    for k, v in pairs(configs) do
        if type(v) == "table" then
            normalizedConfigs[k] = v
        else
            normalizedConfigs[v] = {
                resourceValue = v
            }
        end
    end

    return normalizedConfigs
end

-- Default handlers

function DefaultUpdateCurrentPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and aura_env.convertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.currentPower = UnitPower("player", cache.powerType)
        return true, cache.currentPower
    end

    return false
end

function DefaultUpdateMaxPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and aura_env.convertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.maxPower = UnitPowerMax("player", cache.powerType)
        return true, cache.maxPower
    end

    return false
end

function DefaultUpdateTextHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and aura_env.convertPowerTypeStringToEnumValue(powerType) == cache.powerType) then
        -- if it's mana power type, format as percent by default
        if cache.powerType == Enum.PowerType.Mana then
            return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
        end

        return true, cache.currentPower
    end

    return false, cache.currentPower
end

-- Bar initialization

function InitializeStatusBar(barName, bar, height, width, anchorPoint, xOffset, yOffset, frameStrata, texture, inverseFill, color)
    local frameName = aura_env.id .. "_" .. barName
    local statusBar = _G[frameName] or CreateFrame("StatusBar", frameName, bar)
    local color = (type(color) == "table" and color) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
    
    statusBar:SetWidth(width)
    statusBar:SetHeight(height)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetPoint(anchorPoint, bar, anchorPoint, xOffset, yOffset)
    statusBar:SetFrameStrata(frameStrata)
    statusBar:SetStatusBarTexture(texture or "Interface\\TargetingFrame\\UI-StatusBar")
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetReverseFill(inverseFill)
    statusBar:Show()
    return statusBar
end

function InitializeTickMark(name, bar, tickWidth, texture, color, resourceRatio)
    local frameName = aura_env.id .. "_" .. name
    local tickFrame = _G[frameName] or CreateFrame("Frame", frameName, bar)
    
    tickFrame:SetWidth(tickWidth)
    tickFrame:SetHeight(bar:GetHeight())
    tickFrame:SetPoint("LEFT", bar, "LEFT", resourceRatio * bar:GetWidth(), 0)
    tickFrame:SetFrameStrata("HIGH")
    
    tickFrame.texture = _G[frameName .. "_texture"] or tickFrame:CreateTexture(frameName .. "_texture")
    tickFrame.texture:SetAllPoints(tickFrame)
    tickFrame.texture:SetTexture(texture or "Interface/Addons/SharedMedia/statusbar/Aluminium")
    tickFrame.texture:SetVertexColor(color.r, color.g, color.b, color.a)
    tickFrame:Show()
    return tickFrame
end

function InitializeBackground(name, bar)
    local frameName = aura_env.id .. "_" .. name .. "_background"

    if _G[frameName] ~= nil then
        return _[frameName]
    end

    local backgroundFrame = CreateFrame("Frame", frameName, bar)
    
    backgroundFrame:SetWidth(bar:GetWidth())
    backgroundFrame:SetHeight(bar:GetHeight())
    backgroundFrame:SetPoint("CENTER", bar, "CENTER", 0, 0)
    backgroundFrame:SetFrameStrata("BACKGROUND")
    backgroundFrame:Show()
    
    backgroundFrame.texture = _G[frameName .. "_texture"] or backgroundFrame:CreateTexture(frameName .. "_texture")
    backgroundFrame.texture:SetAllPoints(backgroundFrame)
    backgroundFrame.texture:SetColorTexture(0.0, 0.0, 0.0, 0.6)

    return backgroundFrame
end

function InitializeText(name, bar, yOffset, text)
    local textFrameName = aura_env.id .. "_" .. name .. "_text"
    local textFrame = _G[textFrameName] or bar:CreateFontString(textFrameName)

    text = text or {}

    local color = (type(text.color) == "table" and text.color) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
    
    textFrame:SetFont(text.font or "Fonts\\FRIZQT__.TTF", text.size or 14, text.outline or "OUTLINE")
    textFrame:SetTextColor(color.r, color.g, color.b, color.a)
    textFrame:SetPoint("CENTER", bar, "CENTER", text.xOffset or 0, text.yOffset or 0)
    textFrame:SetText((type(text.value) == "string" and text.value) or "")
    return textFrame
end

function InitializeCache(configuration)
    local cache = {
        powerType = 0,
        currentPower = 0,
        maxPower = 0
    }

    cache.powerType = (type(configuration.powerType) == "function" and select(2, configuration.powerType(cache, "INITIAL"))) or configuration.powerType or UnitPowerType("player")
    cache.currentPower = (configuration.currentPower ~= nil and select(2, configuration.currentPower(cache, "INITIAL"))) or UnitPower("player", cache.powerType)
    cache.maxPower = (type(configuration.maxPower) == "function" and select(2, configuration.maxPower(cache, "INITIAL"))) or (type(configuration.maxPower) == "number" and configuration.maxPower) or UnitPowerMax("player", cache.powerType)
    return cache
end

function InitializeProgressBar(id, specBarConfig)
    local progressBar = {
        cache = InitializeCache(specBarConfig)
    }

    local barPositionConfig = this.progressBarPositionAndSizeConfiguration[id]
    local xOffset = barPositionConfig.xOffset or 0
    local yOffset = barPositionConfig.yOffset
    local anchorPoint = barPositionConfig.anchorPoint
    local height = barPositionConfig.height
    local width = barPositionConfig.width or this.region.bar:GetWidth()
    local inverseFill = barPositionConfig.inverseFill
    
    local powerTypeColor = PowerBarColor[progressBar.cache.powerType]
    local color = (type(specBarConfig.color) == "table" and specBarConfig.color) or { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, 1.0}
    progressBar.main = InitializeStatusBar(id, this.region.bar, height, width, anchorPoint, xOffset, yOffset, "MEDIUM", specBarConfig.texture, inverseFill, color)
    progressBar.background = InitializeBackground(id, progressBar.main)
    
    if specBarConfig.prediction ~= nil and specBarConfig.prediction.enabled ~= false then
        local predictionColor = (type(specBarConfig.prediction.color) == "table" and color) or { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, 0.75}
        progressBar.prediction = InitializeStatusBar(id .. "_prediction", progressBar.main, height, width, anchorPoint, xOffset, yOffset, "LOW", specBarConfig.texture, inverseFill, predictionColor)
    end
    
    progressBar.tickMarks = {}
    if specBarConfig.tickMarks ~= nil and type(specBarConfig.tickMarks.offsets) == "table" then
        for tickId, tickConfig in pairs(NormalizeTickMarkOffsets(specBarConfig.tickMarks.offsets, progressBar.cache)) do
            if tickConfig.enabled ~= false then
                local tickColor = (type(tickConfig.color) == "table" and tickConfig.color) or (type(specBarConfig.tickMarks.color) == "table" and specBarConfig.tickMarks.color) or { r = 1.0, g = 1.0, g = 1.0, a = 1.0 }
                local resourceValue =  ((type(tickConfig.resourceValue) == "number") and tickConfig.resourceValue) or 0
                progressBar.tickMarks[tickId] = InitializeTickMark(id .. "_" .. tickId, progressBar.main, barPositionConfig.tickWidth, specBarConfig.tickMarks.texture, tickColor, resourceValue / progressBar.cache.maxPower)
            end
        end
    end
    
    if specBarConfig.text.enabled ~= false then
        progressBar.text = InitializeText(id, progressBar.main, yOffset, specBarConfig.text)    
    end
    
    return progressBar
end

-- Initial Setup functions

function GetClassBarConfigurationKey()
    local className = strlower(UnitClass("player"):gsub(" ", ""))
    local specializationName = select(2, GetSpecializationInfo(GetSpecialization()))

    local specClassKey = className .. "_" .. strlower(specializationName)
    if aura_env.specConfigurations[specClassKey] ~= nil then   
        return specClassKey
    elseif aura_env.specConfigurations[className] ~= nil then
        return className
    end
    
    return nil
end

function GetClassBarConfiguration()
    configKey = GetClassBarConfigurationKey()
    this.currentSpecKey = configKey

    local defaultPrimaryConfig = {
        powerType = UnitPowerType("player"),
        text = {}
    }

    if configKey == nil then
        return {
            primary = defaultPrimaryConfig
        }
    end

    local config = aura_env.specConfigurations[configKey]

    if config.primary == nil then
        config.primary = defaultPrimaryConfig
    end

    if config.primary.text == nil then
        config.primary.text = {} 
    end

    if config.primary.currentPower == nil and config.primary.maxPower == nil and config.primary.powerType == nil then
        config.primary.powerType = UnitPowerType("player")
    end
    
    return config
end

function GetEventHandlers(bar, configuration, path)
    for property, value in pairs(configuration) do
        if IsPropertyEnabled(path, property, value) then
            -- there are a bunch of implicit events and dependencies
            -- * first three: we do not want any events/dependency handlers for disabled entities
            -- * powerType being specicified implicitly uses the default Current and Max Power updater
            -- * if not text value function is provided we just use current power so it has a dependency on current power
            -- * all tick marks have a dependency on max power (even static tables)
            if property == "powerType" then
                CreatePowerTypeEventHandlers(bar)
            elseif property == "text" and configuration.text.value == nil then
                if this.dependencyHandlers.currentPower == nil then
                    this.dependencyHandlers.currentPower = {}
                end

                table.insert(this.dependencyHandlers.currentPower, {
                    bar = bar,
                    path = property,
                    property = "value",
                    handler = DefaultUpdateTextHandler,
                    updater = RefreshText
                })
            elseif string.find(path, "tickMarks")  then
                if ((property == "offsets" and ShouldRefreshOffsetsProperty(value)) or property == "resourceValue") then
                    local updater = nil
                    if property == "offsets" then
                        updater = RefreshTickMarkOffsets
                    elseif property == "resourceValue" then
                        updater = RefreshTickMarkXOffset
                    end
        
                    if this.dependencyHandlers.maxPower == nil then
                        this.dependencyHandlers.maxPower = {}
                    end
                        
                    table.insert(this.dependencyHandlers.maxPower, {
                        bar = bar,
                        path = path,
                        property = property,
                        handler = value,
                        updater = updater
                    })
                end
            end

            if type(value) == "table" then
                GetEventHandlers(bar, value, path .. property)
            elseif type(value) == "function" then
                local events = configuration[property .. "_events"] or {}

                for i, event in ipairs(events or {}) do
                    if this.eventHandlers[event] == nil then
                        this.eventHandlers[event] = {}
                    end
                    
                    table.insert(this.eventHandlers[event], {
                        bar = bar,
                        path = path,
                        property = property,
                        handler = value,
                        updater = GetUpdater(path, property),
                    })
                end

                local dependentProperties = configuration[property .. "_dependencies"] or {}

                for i, dependentProperty in ipairs(dependentProperties) do
                    if this.dependencyHandlers[dependentProperty] == nil then
                        this.dependencyHandlers[dependentProperty] = {}
                    end

                    table.insert(this.dependencyHandlers[dependentProperty], {
                        bar = bar,
                        path = path,
                        property = property,
                        handler = value,
                        updater = GetUpdater(path, property),
                    })
                end
            end
        end
    end
end

function IsPropertyEnabled(path, property, value) 
    if property == "prediction" and value.enabled == false then
        return false
    elseif string.find(path, "offsets") and type(value) == "table" and value.enabled == false then
        return false
    elseif property =="text" and value.enabled == false then
        return false
    end

    return true
end

function ShouldRefreshOffsetsProperty(t)
    if type(t) == "function" then
        return true
    end

    for i, v in ipairs(t) do
        if type(v) == "number" then
            return true
        end

        return false
    end
end

function CreatePowerTypeEventHandlers(bar)
    if this.eventHandlers["UNIT_POWER_FREQUENT"] == nil then
        this.eventHandlers["UNIT_POWER_FREQUENT"] = {}
    end
    
    table.insert(this.eventHandlers["UNIT_POWER_FREQUENT"], {
        bar = bar,
        path = "",
        property = "currentPower",
        handler = DefaultUpdateCurrentPowerHandler,
        updater = RefreshBarValue,
    })

    if this.eventHandlers["UNIT_MAXPOWER"] == nil then
        this.eventHandlers["UNIT_MAXPOWER"] = {}
    end
    
    table.insert(this.eventHandlers["UNIT_MAXPOWER"], {
        bar = bar,
        path = "",
        property = "maxPower",
        handler = DefaultUpdateMaxPowerHandler,
        updater = RefreshBarValue,
    })
end

function GetUpdater(path, property)
    if property == "currentPower" or property == "maxPower" or (path == "prediction" and property == "next") then
        return RefreshBarValue
    elseif path == "text" and property == "value" then
        return RefreshText
    elseif property == "color" and string.find(path, "text") then
        return RefreshTextColor
    elseif property == "color" and string.find(path, "tickMarksoffsets") then
        return RefreshTickMarkColor
    elseif property == "color" then
        return RefreshBarColor
    elseif property == "resourceValue" and string.find(path, "tickMarksoffsets") then
        return RefreshTickMarkXOffset
    elseif property == "enabled" then
        return RefreshEnabled
    elseif path == "tickMarks" and property == "offsets" then
        return RefreshTickMarkOffsets
    end

    return function(progressBar, property, resolver, event, ...)
        return false
    end
end

function InitializeBarProperties()
    -- intializes event handled properties
    for event, eventHandlerList in pairs(this.eventHandlers) do
        for index, handlerConfig in ipairs(eventHandlerList) do
            if handlerConfig.updater(handlerConfig.bar, this.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, "INITIAL") then
                this.frameUpdates[handlerConfig.bar .. handlerConfig.path .. handlerConfig.property] = handlerConfig
            end
        end
    end

    -- initializes dependent properties, note that some values may get set twice. Not a big deal
    for dependentProperty, dependencyHandlerList in pairs(this.dependencyHandlers) do
        for index, dependencyConfig in ipairs(dependencyHandlerList) do
            if dependencyConfig.updater(dependencyConfig.bar, this.progressBars[dependencyConfig.bar], dependencyConfig.path, dependencyConfig.property, dependencyConfig.handler, "INITIAL") then
                this.frameUpdates[dependencyConfig.bar .. dependencyConfig.path .. dependencyConfig.property] = dependencyConfig
            end
        end
    end
end

function CleanBarState()
    for barName, bar in pairs(this.progressBars) do
        if bar ~= nil then
            bar.main:Hide()
            bar.background:Hide()
            
            if bar.text ~= nil then
                bar.text:Hide()
            end

            if bar.prediction ~= nil then
                bar.prediction:Hide()
            end

            for tickId, tickMark in pairs(bar.tickMarks or {}) do
                tickMark:Hide()
            end
        end
    end

    this.eventHandlers = {}
    this.frameUpdates = {}
    this.progressBars = {}
    this.dependencyHandlers = {}
end

function InitializeClassBar()
    local classBarConfiguration = GetClassBarConfiguration()

    CleanBarState()

    for progressBarName, progressBarConfig in pairs(classBarConfiguration) do
        if progressBarConfig.enabled == nil or (type(progressBarConfig.enabled) == "boolean" and progressBarConfig.enabled) then
            this.progressBars[progressBarName] = InitializeProgressBar(progressBarName, progressBarConfig)
            GetEventHandlers(progressBarName, progressBarConfig, "")
        end
    end

    InitializeBarProperties()
    aura_env.handleCombatStateChangEvent("INITIAL")
end

-- refresher functions

function RefreshBarValue(barName, progressBar, path, property, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)

    if shouldUpdate then
        if property == 'currentPower' then
            progressBar.main:SetValue(newValue / progressBar.cache.maxPower)
        elseif property == 'maxPower' then
            progressBar.main:SetValue(progressBar.cache.currentPower / newValue)
        elseif property == 'next' then
            progressBar.prediction:SetValue(newValue / progressBar.cache.maxPower)
        end
    end

    return shouldUpdate and frameUpdates
end

function RefreshText(barName, progressBar, path, property, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)

    if shouldUpdate then
        progressBar.text:SetText(newValue)
    end

    return shouldUpdate and frameUpdates
end

function RefreshEnabled(barName, progressBar, path, property, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)

    if shouldUpdate then
        local frame = nil
        if path == "text" then
            frame = progressBar.text
        elseif path == "prediction" then
            frame = progressBar.prediction
        elseif path == nil then
            frame = progressBar.main
        elseif string.find(path, "tickMarksoffsets") then
            frame = progressBar.tickMarks[strsub(path, 17)]
        end

        if frame ~= nil then
            if newValue then
                frame:Show()
            else 
                frame:Hide()
            end
        end
    end

    return shouldUpdate and frameUpdates
end

function RefreshBarColor(barName, progressBar, path, property, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)

    if shouldUpdate then
        if path == 'prediction' then
            progressBar.prediction:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        else
            progressBar.main:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        end
    end

    return shouldUpdate and frameUpdates
end

function RefreshTextColor(barName, progressBar, path, property, resolver, event, ...) 
    local shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)

    if shouldUpdate then
        progressBar.text:SetTextColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

function RefreshTickMarkColor(barName, progressBar, path, property, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)

    if shouldUpdate then
        progressBar.tickMarks[property]:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

function RefreshTickMarkXOffset(barName, progressBar, path, property, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, resolver, nil

    if type(resolver) == "function" then
        shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)
    end

    if shouldUpdate then
        local tickMark = progressBar.tickMarks[strsub(path, 17)]
        if tickMark ~= nil then
            tickMark:SetPoint("LEFT", progressBar.main, "LEFT", newValue / progressBar.cache.maxPower * progressBar.main:GetWidth(), 0)
        end
    end

    return shouldUpdate and frameUpdates
end

function RefreshTickMarkOffsets(barName, progressBar, path, property, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, resolver, nil

    if type(resolver) == "function" then
        shouldUpdate, newValue, frameUpdates = resolver(progressBar.cache, event, ...)
    end

    if shouldUpdate then
        for id, tickMark in pairs(progressBar.tickMarks) do
            tickMark:Hide()
        end

        for index, tickConfig in pairs(NormalizeTickMarkOffsets(newValue, progressBar.cache)) do
            if progressBar.tickMarks[index] ~= nil then
                progressBar.tickMarks[index]:Show()
            else
                local barPositionConfig = this.progressBarPositionAndSizeConfiguration[barName]
                local barConfiguration = GetClassBarConfiguration()[barName]
                local color = (type(barConfiguration.tickMarks.color) == "table" and barConfiguration.tickMarks.color) or { r = 1.0, g = 1.0, g = 1.0, a = 1.0 }
                progressBar.tickMarks[index] = InitializeTickMark(barName .. "_" .. index, progressBar.main, barPositionConfig.tickWidth, barConfiguration.tickMarks.texture, color, 0)
            end

            progressBar.tickMarks[index]:SetPoint("LEFT", progressBar.main, "LEFT", (index / progressBar.cache.maxPower) * progressBar.main:GetWidth(), 0)
        end
    end

    return shouldUpdate and frameUpdates
end

-- main functions and publicly available methods

aura_env.initialize = function()
    this.region = WeakAuras.regions[aura_env.id].region
    local height = this.region:GetHeight()
    local width = this.region:GetWidth()
    
    this.region:Hide()

    this.progressBarPositionAndSizeConfiguration = {
        primary = {
            anchorPoint = "LEFT",
            tickWidth = 3,
            height = height,
            yOffset = 0
        },
        top = {
            anchorPoint = "TOP",
            tickWidth = 2,
            height = height / 4,
            yOffset = height / 4
        },
        top_left = {
            anchorPoint = "TOPLEFT",
            tickWidth = 2,
            height = height / 4,
            width = width / 2,
            yOffset = height / 4,
            inverseFill = true
        },
        top_right = {
            anchorPoint = "TOPRIGHT",
            tickWidth = 2,
            height = height / 4,
            width = width / 2,
            yOffset = height / 4,
        },
        bottom = {
            tickWidth = 2,
            anchorPoint = "BOTTOM",
            height = height / 4,
            yOffset = (-1 * (height / 4))
        },
        bottom_left = {
            tickWidth = 2,
            anchorPoint = "BOTTOMLEFT",
            height = height / 4,
            width = width / 2,
            yOffset = (-1 * (height / 4)),
            inverseFill = true
        },
        bottom_right = {
            tickWidth = 2,
            anchorPoint = "BOTTOMRIGHT",
            height = height / 4,
            width = width / 2,
            yOffset = (-1 * (height / 4))
        }
    }

    InitializeClassBar()
end

aura_env.ReinitializationNeeded = function()
    return this.currentSpecKey ~= GetClassBarConfigurationKey()
end

aura_env.handleEvent = function(event, ...)
    for _, handlerConfig in ipairs(this.eventHandlers[event] or {}) do
        if handlerConfig.updater(handlerConfig.bar, this.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, event, ...) then
            this.frameUpdates[handlerConfig.bar .. handlerConfig.path .. handlerConfig.property] = handlerConfig
        end

        for _, dependencyConfig in ipairs(this.dependencyHandlers[handlerConfig.property] or {}) do
            if dependencyConfig.updater(dependencyConfig.bar, this.progressBars[dependencyConfig.bar], dependencyConfig.path, dependencyConfig.property, dependencyConfig.handler, event, ...) then
                this.frameUpdates[dependencyConfig.bar .. dependencyConfig.path .. dependencyConfig.property] = dependencyConfig
            end
        end
    end
end

aura_env.handleFrameUpdates = function()
    for key, handlerConfig in pairs(this.frameUpdates) do
        if not handlerConfig.updater(handlerConfig.bar, this.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, "FRAME_UPDATE", nil) then
            this.frameUpdates[key] = nil
        end
    end
end

aura_env.handleCombatStateChangEvent = function(event)
    local inCombat = event == "PLAYER_REGEN_DISABLED"
    for barName, bar in pairs(this.progressBars) do
        bar.main:SetAlpha((inCombat and 1.0 or 0.5))
        
        if bar.background ~= nil then
            bar.background:SetAlpha(0.4)
        end

        if bar.prediction ~= nil then
            bar.prediction:SetAlpha(0.5)
        end
    end
end

aura_env.convertPowerTypeStringToEnumValue = function(powerType)
    return Enum.PowerType[((" " .. string.lower(powerType)):gsub("%W%l", string.upper):sub(2)):gsub("_", "")]
end

aura_env.specConfigurations = {}
 
aura_env.DebugPrint = function(strName, data) 
    if ViragDevTool_AddData and this.debugEnabled then 
        ViragDevTool_AddData(data, strName) 
    end 
end