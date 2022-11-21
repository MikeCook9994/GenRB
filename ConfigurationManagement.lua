local PRD = PRD

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
        font = "Interface\\AddOns\\SharedMediaAdditionalFonts\\fonts\\Accidental Presidency.ttf",
        size = 15,
        flags = "OUTLINE",
        yOffset = 0,
        xOffset = 0
    } 

    local defaultPrimaryConfig = {
        enabled = true,
        heightWeight = 5,
        powerType = playerPowerType,
        currentPower_events = { "UNIT_POWER_FREQUENT" },
        currentPower = PRD.DefaultUpdateCurrentPowerHandler,
        maxPower_events = { "UNIT_MAXPOWER" },
        maxPower = PRD.DefaultUpdateMaxPowerHandler,
        text = defaultTextConfig,
        color = { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b },
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Cilo",
        prediction = {
            enabled = false,
        },
        tickMarks = {
            enabled = false,
            width = 3
        }
    }

    if configKey == nil then
        return {
            [0] = defaultPrimaryConfig
        }
    end

    local config = PRD.configurations[configKey]

    if config[0] == nil then
        config[0] = defaultPrimaryConfig
    elseif config[0].text == nil then
        config[0].text = defaultTextConfig
    end

    for barPriority, barConfig in pairs(config) do
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
        -- a world where powerType is a function and maxPower isn't.
        -- Additionally, color should be updated with the new 
        if barConfig.powerType ~= nil and type(barConfig.powerType) == "function" then
            barConfig.currentPower_dependencies = { "powerType" }

            if type(barConfig.maxPower) == "function" then
                barConfig.maxPower_dependencies = { "powerType" }
            end

            if barConfig.color == nil then
                barConfig.color_dependencies = { "powerType" }
                barConfig.color = PRD.DefaultUpdateColorHandler
            end
        end

        barConfig.enabled = barConfig.enabled == nil or barConfig.enabled
        barConfig.heightWeight = (barConfig.heightWeight ~= nil and barConfig.heightWeight) or 1
        barConfig.color = (barConfig.color ~= nil and barConfig.color) or { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b }
        barConfig.texture = (barConfig.texture ~= nil and barConfig.texture) or "Interface\\Addons\\SharedMedia\\statusbar\\Cilo"

        -- prediction config defaults
        if barConfig.prediction ~= nil and barConfig.text.enabled ~= false then
            local prediction = barConfig.prediction
            prediction.enabled = prediction.enabled == nil or prediction.enabled
            prediction.color = (prediction.color ~= nil and prediction.color) or (type(barConfig.color) == "function" and barConfig.color) or { r = barConfig.color.r, g = barConfig.color.g, b = barConfig.color.b }
        else 
            barConfig.prediction = {
                enabled = false
            }
        end

        -- text config defaults
        if barConfig.text ~= nil and barConfig.text.enabled ~= false then
            local text = barConfig.text

            text.enabled = text.enabled == nil or text.enabled
            text.color = (text.color ~= nil and text.color) or { r = 1.0, g = 1.0, b = 1.0 }
            text.font = (text.font ~= nil and text.font) or "Interface\\AddOns\\SharedMediaAdditionalFonts\\fonts\\Accidental Presidency.ttf"
            text.size = (text.size ~= nil and text.size) or 20
            text.flags = (text.flags ~= nil and text.flags) or "OUTLINE"
            text.xOffset = (text.xOffset ~= nil and text.xOffset) or 0
            text.yOffset = (text.yOffset ~= nil and text.yOffset) or 0
            
            if text.value == nil then 
                text.value = PRD.DefaultUpdateTextHandler
                text.value_dependencies = { "currentPower", "maxPower" }
            end
        else 
            barConfig.text = {
                enabled = false
            }
        end

        -- tick mark config default
        if barConfig.tickMarks ~= nil then
            local tickMarks = barConfig.tickMarks
            tickMarks.enabled = tickMarks.enabled == nil or tickMarks.enabled 
            tickMarks.texture = (tickMarks.texture ~= nil and tickMarks.texture) or "Interface\\Addons\\SharedMedia\\statusbar\\Aluminium"
            tickMarks.color = (tickMarks.color ~= nil and tickMarks.color) or { r = 1.0, g = 1.0, b = 1.0 }
            tickMarks.width = (tickMarks.width ~= nil and tickMarks.width) or 2

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
    
    PRD.selectedConfig = config
    return config
end