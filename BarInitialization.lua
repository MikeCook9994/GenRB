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

-- Bar initialization

local function InitializeStatusBar(barName, parent, positionConfig, frameStrata, texture, color)
    local frameName = id .. "_" .. barName
    local statusBar = _G[frameName] or CreateFrame("StatusBar", frameName, parent)
    
    statusBar:SetWidth(positionConfig.width)
    statusBar:SetHeight(positionConfig.height)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetPoint(positionConfig.anchorPoint, parent, positionConfig.anchorPoint, 0, positionConfig.yOffset)
    statusBar:SetFrameStrata(frameStrata)
    statusBar:SetStatusBarTexture(texture)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetReverseFill(positionConfig.inverseFill)
    statusBar.SetAlpha(0.5)
    statusBar:Show()
    return statusBar
end

local function InitializeTickMark(name, parent, tickWidth, cache, texture, color, resourceValue)
    local frameName = id .. "_" .. name
    local tickFrame = _G[frameName] or CreateFrame("Frame", frameName, parent)
    
    tickFrame:SetWidth(tickWidth)
    tickFrame:SetHeight(parent:GetHeight())
    tickFrame:SetPoint("LEFT", parent, "LEFT", (resourceValue / cache.maxPower) * parent:GetWidth(), 0)
    tickFrame:SetFrameStrata("HIGH")
    
    tickFrame.texture = _G[frameName .. "_texture"] or tickFrame:CreateTexture(frameName .. "_texture")
    tickFrame.texture:SetAllPoints(tickFrame)
    tickFrame.texture:SetTexture(texture)
    tickFrame.texture:SetVertexColor(color.r, color.g, color.b, color.a)
    tickFrame:SetAlpha(0.5)
    tickFrame:Show()
    return tickFrame
end

local function InitializeBackground(name, parent)
    local frameName = id .. "_" .. name .. "_background"

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

local function InitializeText(name, parent, cache, font, size, flags, xOffset, yOffset, value, color)
    local textFrameName = id .. "_" .. name .. "_text"
    local textFrame = _G[textFrameName] or parent:CreateFontString(textFrameName)

    textFrame:SetFont(font, size, flags)
    textFrame:SetTextColor(color.r, color.g, color.b, color.a)
    textFrame:SetPoint("CENTER", parent, "CENTER", xOffset, yOffset)
    textFrame:SetText(value)
    textFrame:SetAlpha(0.5)
    return textFrame
end

function PRD:InitializeProgressBar(id, specBarConfig)
    local container = PRD.container
end

local function NormalizeTickMarkOffsets(configs, cache, commonColor)
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
    configKey = GetConfigurationKey()
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

    local config = specConfigurations[configKey]

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
        elseif barConfig.maxPower == nil then
            barConfig.maxPower_events = { "UNIT_MAXPOWER" }
            barConfig.maxPower = DefaultUpdateMaxPowerHandler
        elseif barConfig.color == nil then
            barConfig.color = { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, 1.0}
        elseif barConfig.texture == nil then
            barConfig.texture = "Interface/Addons/SharedMedia/statusbar/Cilo"

        -- prediction config defaults
        elseif barConfig.prediction ~= nil then
            for key, value in pairs(barConfig.prediction) do
                if value == nil then
                    if key == "enabled" then
                        value = true
                    elseif key == "color" then 
                        value = { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, a = 0.75 }
                    end
                end
            end

        -- text config defaults
        elseif barConfig.text ~= nil then
            for key, value in pairs(barConfig.text) do
                if value == nil then
                    if key == "enabled" then
                        value = true
                    elseif key == "value" then
                        barConfig.text.value_dependencies = { "currentPower" }
                        value = DefaultUpdateTextHandler
                    elseif key == "color" then
                        value = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
                    elseif key == "font" then
                        value = "Fonts\\FRIZQT__.TTF"
                    elseif key == "size" then
                        value = 14
                    elseif key == "flags" then
                        value = "OUTLINE"
                    elseif key == "xOffset" then
                        value = 0
                    elseif key == "yOffset" then
                        value = 0
                    end
                end
            end 

        -- tick mark config default
        elseif barConfig.tickMarks ~= nil then
            for key, value in pairs(propertyConfig.tickMarks) do
                if value == nil then
                    if key == "texture" then
                        value = "Interface/Addons/SharedMedia/statusbar/Aluminium"
                    elseif key == "color" then
                        value = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
                    end
                elseif key == "offsets" and type(value) == "function" then
                    if propertyConfig.tickMarks.offsets_dependencies == nil then
                        propertyConfig.tickMarks.offsets_dependencies = { "maxPower" }
                    else
                        table.insert(propertyConfig.tickMarks.offsets_dependencies, "maxPower")
                    end

                elseif key == "offsets" and type(value) == "table" then
                    propertyConfig.tickMarks.offsets = NormalizeTickMarkOffsets()
                end
            end
        end
    end
    
    return config
end

local function Clean()
    PRD.frameUpdates = {}

    for _, bar in ipairs(PRD.container:GetChildren()) do
        bar.dependencyHandlers = {}
        for _, frame in ipairs(bar:GetChildren()) do
            CleanFrameState(frame)
            if string.find(frame:GetName(), "tickMarkContainer") then
                for _, tickmark in ipairs(frame:GetChildren()) do
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

function PRD:GetConfigurationKey()
    local className = strlower(UnitClass("player"):gsub(" ", ""))
    local specializationName = select(2, GetSpecializationInfo(GetSpecialization()))

    local specClassKey = className .. "_" .. strlower(specializationName)
    if specConfigurations[specClassKey] ~= nil then   
        return specClassKey
    elseif specConfigurations[className] ~= nil then
        return className
    end
    
    return nil
end

function PRD:InitializePersonalResourceDisplay()
    Clean()

    for progressBarName, progressBarConfig in pairs(GetConfiguration()) do
        if type(progressBarConfig.enabled) == "function" or progressBarConfig.enabled then
            InitializeProgressBar(progressBarName, progressBarConfig)
        end
    end
end
