local PRD = PRD

function PRD:RefreshPowerType(eventHandler, thisBar, event, ...)
    local shouldUpdate, _, frameUpdates = eventHandler(thisBar.cache, event, ...)
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
    local positionConfig = PRD.positionAndSizeConfig[thisBar.barName]
    local barConfiguration = PRD.selectedConfig[thisBar.barName]

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
            local tickMarkName = "prd_" .. thisBar.barName .. "_tick_mark_" .. index
            local tickMark = PRD:GetExistingTickMark(tickMarkName, thisBar)

            if tickMark == nil then
                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(barConfiguration.tickMarks.color) == "function" and barConfiguration.tickMarks.color(cache, "INITIAL")) or barConfiguration.tickMarks.color)
                
                local resourceRatio = ((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / thisBar.cache.maxPower
                if positionConfig.inverseFill then
                    resourceRatio = 1 - resourceRatio
                end

                local isShown = true 
                if type(tickConfig.enabled) == "function" then
                    isShown = select(2, tickConfig.enabled(cache, "INITIAL"))
                end

                local tickMark = PRD:InitializeTickMark(thisBar.barName, index, thisBar, positionConfig.tickWidth, barConfiguration.tickMarks.texture, color, resourceRatio, isShown)
                PRD.bars[thisBar.barName][tickMark:GetName()] = tickMark
            else
                tickMark:SetPoint("LEFT", thisBar, "LEFT", (index / thisBar.cache.maxPower) * PRD.width, 0)
                tickMark:Show()
            end

        end
    end

    return frameUpdates
end