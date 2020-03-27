-- Default handlers

local function DefaultUpdateCurrentPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and local function convertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.currentPower = UnitPower("player", cache.powerType)
        return true, cache.currentPower
    end

    return false
end

local function DefaultUpdateMaxPowerHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and local function convertPowerTypeStringToEnumValue(powerType) == cache.powerType) then 
        cache.maxPower = UnitPowerMax("player", cache.powerType)
        return true, cache.maxPower
    end

    return false
end

local function DefaultUpdateTextHandler(cache, event, unit, powerType)
    if event == "INITIAL" or (unit == "player" and local function convertPowerTypeStringToEnumValue(powerType) == cache.powerType) then
        -- if it's mana power type, format as percent by default
        if cache.powerType == Enum.PowerType.Mana then
            return true, (("%%.%df"):format(2):format((cache.currentPower / cache.maxPower)) * 100) .. "%"
        end

        return true, cache.currentPower
    end

    return false, cache.currentPower
end

-- Initial Setup functions

local function GetClassBarConfigurationKey()
    local className = strlower(UnitClass("player"):gsub(" ", ""))
    local specializationName = select(2, GetSpecializationInfo(GetSpecialization()))

    local specClassKey = className .. "_" .. strlower(specializationName)
    if local function specConfigurations[specClassKey] ~= nil then   
        return specClassKey
    elseif local function specConfigurations[className] ~= nil then
        return className
    end
    
    return nil
end

local function GetClassBarConfiguration()
    configKey = GetClassBarConfigurationKey()
    PRD.currentSpecKey = configKey

    local defaultPrimaryConfig = {
        powerType = UnitPowerType("player"),
        text = {}
    }

    if configKey == nil then
        return {
            primary = defaultPrimaryConfig
        }
    end

    local config = local function specConfigurations[configKey]

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

local function GetEventHandlers(bar, configuration, path)
    for property, value in pairs(configuration) do
        if IsPropertyEnabled(path, property, value) then
            -- there are a bunch of implicit events and dependencies
            -- * first three: we do not want any events/dependency handlers for disabled entities
            -- * powerType being specicified implicitly uses the default Current and Max Power updater
            -- * if not text value local function is provided we just use current power so it has a dependency on current power
            -- * all tick marks have a dependency on max power (even static tables)
            if property == "powerType" then
                CreatePowerTypeEventHandlers(bar)
            elseif property == "text" and configuration.text.value == nil then
                if PRD.dependencyHandlers.currentPower == nil then
                    PRD.dependencyHandlers.currentPower = {}
                end

                table.insert(PRD.dependencyHandlers.currentPower, {
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
        
                    if PRD.dependencyHandlers.maxPower == nil then
                        PRD.dependencyHandlers.maxPower = {}
                    end
                        
                    table.insert(PRD.dependencyHandlers.maxPower, {
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
                    if PRD.eventHandlers[event] == nil then
                        PRD.eventHandlers[event] = {}
                    end
                    
                    table.insert(PRD.eventHandlers[event], {
                        bar = bar,
                        path = path,
                        property = property,
                        handler = value,
                        updater = GetUpdater(path, property),
                    })
                end

                local dependentProperties = configuration[property .. "_dependencies"] or {}

                for i, dependentProperty in ipairs(dependentProperties) do
                    if PRD.dependencyHandlers[dependentProperty] == nil then
                        PRD.dependencyHandlers[dependentProperty] = {}
                    end

                    table.insert(PRD.dependencyHandlers[dependentProperty], {
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

local function IsPropertyEnabled(path, property, value) 
    if property == "prediction" and value.enabled == false then
        return false
    elseif string.find(path, "offsets") and type(value) == "table" and value.enabled == false then
        return false
    elseif property =="text" and value.enabled == false then
        return false
    end

    return true
end

local function ShouldRefreshOffsetsProperty(t)
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

local function CreatePowerTypeEventHandlers(bar)
    if PRD.eventHandlers["UNIT_POWER_FREQUENT"] == nil then
        PRD.eventHandlers["UNIT_POWER_FREQUENT"] = {}
    end
    
    table.insert(PRD.eventHandlers["UNIT_POWER_FREQUENT"], {
        bar = bar,
        path = "",
        property = "currentPower",
        handler = DefaultUpdateCurrentPowerHandler,
        updater = RefreshBarValue,
    })

    if PRD.eventHandlers["UNIT_MAXPOWER"] == nil then
        PRD.eventHandlers["UNIT_MAXPOWER"] = {}
    end
    
    table.insert(PRD.eventHandlers["UNIT_MAXPOWER"], {
        bar = bar,
        path = "",
        property = "maxPower",
        handler = DefaultUpdateMaxPowerHandler,
        updater = RefreshBarValue,
    })
end

local function GetUpdater(path, property)
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

local function InitializeBarProperties()
    -- intializes event handled properties
    for event, eventHandlerList in pairs(PRD.eventHandlers) do
        for index, handlerConfig in ipairs(eventHandlerList) do
            if handlerConfig.updater(handlerConfig.bar, PRD.progressBars[handlerConfig.bar], handlerConfig.path, handlerConfig.property, handlerConfig.handler, "INITIAL") then
                PRD.frameUpdates[handlerConfig.bar .. handlerConfig.path .. handlerConfig.property] = handlerConfig
            end
        end
    end

    -- initializes dependent properties, note that some values may get set twice. Not a big deal
    for dependentProperty, dependencyHandlerList in pairs(PRD.dependencyHandlers) do
        for index, dependencyConfig in ipairs(dependencyHandlerList) do
            if dependencyConfig.updater(dependencyConfig.bar, PRD.progressBars[dependencyConfig.bar], dependencyConfig.path, dependencyConfig.property, dependencyConfig.handler, "INITIAL") then
                PRD.frameUpdates[dependencyConfig.bar .. dependencyConfig.path .. dependencyConfig.property] = dependencyConfig
            end
        end
    end
end

local function CleanBarState()
    for barName, bar in pairs(PRD.progressBars) do
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

    PRD.eventHandlers = {}
    PRD.frameUpdates = {}
    PRD.progressBars = {}
    PRD.dependencyHandlers = {}
end

local function InitializeClassBar()
    local classBarConfiguration = GetClassBarConfiguration()

    CleanBarState()

    for progressBarName, progressBarConfig in pairs(classBarConfiguration) do
        if progressBarConfig.enabled == nil or (type(progressBarConfig.enabled) == "boolean" and progressBarConfig.enabled) then
            PRD.progressBars[progressBarName] = InitializeProgressBar(progressBarName, progressBarConfig)
            GetEventHandlers(progressBarName, progressBarConfig, "")
        end
    end

    InitializeBarProperties()
    local function handleCombatStateChangEvent("INITIAL")
end