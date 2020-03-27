local PRD = PRD

-- Bar initialization

local function InitializeStatusBar(barName, bar, height, width, anchorPoint, xOffset, yOffset, frameStrata, texture, inverseFill, color)
    local frameName = id .. "_" .. barName
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

local function InitializeTickMark(name, bar, tickWidth, texture, color, resourceRatio)
    local frameName = id .. "_" .. name
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

local function InitializeBackground(name, bar)
    local frameName = id .. "_" .. name .. "_background"

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

local function InitializeText(name, bar, yOffset, text)
    local textFrameName = id .. "_" .. name .. "_text"
    local textFrame = _G[textFrameName] or bar:CreateFontString(textFrameName)

    text = text or {}

    local color = (type(text.color) == "table" and text.color) or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
    
    textFrame:SetFont(text.font or "Fonts\\FRIZQT__.TTF", text.size or 14, text.outline or "OUTLINE")
    textFrame:SetTextColor(color.r, color.g, color.b, color.a)
    textFrame:SetPoint("CENTER", bar, "CENTER", text.xOffset or 0, text.yOffset or 0)
    textFrame:SetText((type(text.value) == "string" and text.value) or "")
    return textFrame
end

local function InitializeCache(configuration)
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

local function InitializeProgressBar(id, specBarConfig)
    local progressBar = {
        cache = InitializeCache(specBarConfig)
    }

    local barPositionConfig = PRD.positionAndSizeConfig[id]
    local xOffset = barPositionConfig.xOffset or 0
    local yOffset = barPositionConfig.yOffset
    local anchorPoint = barPositionConfig.anchorPoint
    local height = barPositionConfig.height
    local width = barPositionConfig.width
    local inverseFill = barPositionConfig.inverseFill
    
    local powerTypeColor = PowerBarColor[progressBar.cache.powerType]
    local color = (type(specBarConfig.color) == "table" and specBarConfig.color) or { r = powerTypeColor.r, g = powerTypeColor.g, b = powerTypeColor.b, 1.0}
    progressBar.main = InitializeStatusBar(id, PRD.container, height, width, anchorPoint, xOffset, yOffset, "MEDIUM", specBarConfig.texture, inverseFill, color)
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
