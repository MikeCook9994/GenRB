local PRD = PRD

function PRD:RefreshPowerType(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)
    return frameUpdates
end

function PRD:RefreshCurrentPowerValue(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)

    if shouldUpdate then
        thisBar:SetValue(newValue / (thisBar.cache.maxPower or 1))
    end

    return frameUpdates
end

function PRD:RefreshMaxPowerValue(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)

    if shouldUpdate then
        thisBar:SetValue(thisBar.cache.currentPower / newValue)
    end

    return frameUpdates
end

function PRD:RefreshText(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)

    if shouldUpdate then
        thisBar.text:SetText(newValue)
    end

    return frameUpdates
end

function PRD:RefreshEnabled(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)
    if shouldUpdate then
        if newValue then
            thisBar:Show()
        else
            thisBar:Hide()
        end
    end

    return frameUpdates
end

function RefreshBarHeightAndAnchors() 
    local config = PRD:GetConfiguration()
    local totalWeight = 0
    local barPriorities = {}
    
    for barPriority, progressBarConfig in pairs(config) do
        table.insert(barPriorities, barPriority)
        local bar = {}

        if progressBarConfig.powerType == Enum.PowerType.Runes then
            bar = PRD.bars[barPriority][0]["prd_" .. barPriority .. "_".. 0 .. "_bar_container"]
        else
            bar = PRD.bars[barPriority]["prd_" .. barPriority .. "_bar_container"]
        end

        if bar:IsVisible() then
            totalWeight = totalWeight + progressBarConfig.heightWeight
        end
    end

    table.sort(barPriorities)

    local processedWeight = 0
    for _, progressBarPriority in ipairs(barPriorities) do
        local progressBarConfig = config[progressBarPriority]
        local xOffset = 0
        local yOffset = PRD.height * (processedWeight / totalWeight)
        local barContainer = ""
        
        if progressBarConfig.powerType == Enum.PowerType.Runes then
            for runeIndex=1, 6 do
                xOffset = (runeIndex - 1) * (PRD.width / 6)
                barContainer = PRD.bars[progressBarPriority]["prd_" .. progressBarPriority .. "_".. runeIndex .. "_bar_container"]
            end
        else
            barContainer = PRD.bars[progressBarPriority]["prd_" .. progressBarPriority .. "_bar_container"]
        end

        barContainer:SetPoint("BOTTOMLEFT", PRD.container, "BOTTOMLEFT", xOffset, yOffset)

        local height = PRD.height * (progressBarConfig.heightWeight / totalWeight)
        RefreshBarHeights(barContainer, height)

        processedWeight = processedWeight + progressBarConfig.heightWeight
    end
end

function RefreshBarHeights(container, height)
    for _, bar in ipairs(container:GetChildren()) do
        bar:SetHeight(height)
        RefreshBarHeights(bar, height)
    end
end

function PRD:RefreshBarColor(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)

    if shouldUpdate then
        thisBar:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return frameUpdates
end

function PRD:RefreshTextColor(eventHandler, thisBar, event, ...) 
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)

    if shouldUpdate then
        thisBar.text:SetTextColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return frameUpdates
end

function PRD:RefreshTickMarksColor(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)

    if shouldUpdate then
        for _, tickMark in ipairs({ thisBar:GetChildren() }) do
            tickMark:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        end
    end

    return frameUpdates
end

function PRD:RefreshTickMarkColor(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)

    if shouldUpdate then
        thisBar:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return frameUpdates
end

function PRD:RefreshTickMarkXOffset(eventHandler, thisBar, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, eventHandler, nil

    if type(eventHandler) == "function" then
        shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)
    end

    if shouldUpdate then
        thisBar:SetPoint("LEFT", thisBar:GetParent(), "LEFT", ((newValue / thisBar.cache.maxPower) * PRD.width) - (thisBar:GetWidth() / 2), 0)
    end

    return frameUpdates
end

function PRD:GetExistingTickMark(name, thisBar)
    for _, child in ipairs({ thisBar:GetChildren() }) do
        if child:GetName() == name then
            return child
        end
    end

    return nil
end

function PRD:RefreshTickMarkOffsets(eventHandler, thisBar, event, ...)
    local barPriority = tonumber(string.sub(thisBar:GetName(), 5, 5))
    local barConfiguration = PRD.selectedConfig[barPriority]

    -- we have a race condition with max power changing before the new config is resolved
    if barConfiguration.tickMarks == nil then
        return false
    end

    local shouldUpdate, newValue, frameUpdates = true, eventHandler, nil

    if type(eventHandler) == "function" then
        shouldUpdate, newValue, frameUpdates = eventHandler(thisBar.cache, event, ...)
    end

    if shouldUpdate then
        for _, tickMark in ipairs({ thisBar:GetChildren() }) do
            tickMark:Hide()
        end

        for index, tickConfig in pairs(PRD:NormalizeTickMarkOffsets(newValue, barConfiguration.tickMarks.color)) do
            local tickMarkName = "prd_" .. barPriority .. "_tick_mark_" .. index
            local tickMark = PRD:GetExistingTickMark(tickMarkName, thisBar)

            if tickMark == nil then
                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(barConfiguration.tickMarks.color) == "function" and barConfiguration.tickMarks.color(cache, "INITIAL")) or barConfiguration.tickMarks.color)
                
                local resourceRatio = ((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / thisBar.cache.maxPower

                local isShown = true 
                if type(tickConfig.enabled) == "function" then
                    isShown = select(2, tickConfig.enabled(cache, "INITIAL"))
                end

                local tickMark = PRD:InitializeTickMark(barPriority, index, thisBar, barConfiguration.tickMarks.width, barConfiguration.tickMarks.texture, color, resourceRatio, isShown)
                PRD.bars[barPriority][tickMark:GetName()] = tickMark
            else
                tickMark:SetPoint("LEFT", thisBar, "LEFT", (index / thisBar.cache.maxPower) * PRD.width, 0)
                tickMark:Show()
            end

        end
    end

    return frameUpdates
end