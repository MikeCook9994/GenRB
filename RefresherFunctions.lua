local PRD = PRD

function PRD:RefreshPowerType(eventHandler, self, event, ...)
    return false
end

function PRD:RefreshCurrentPowerValue(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetValue(newValue / self.cache.maxPower)
    end

    return shouldUpdate and frameUpdates
end

function PRD:RefreshMaxPowerValue(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetValue(self.cache.currentPower / newValue)
    end

    return shouldUpdate and frameUpdates
end

function PRD:RefreshText(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetText(newValue)
    end

    return shouldUpdate and frameUpdates
end

function PRD:RefreshEnabled(eventHandler, self, event, ...)
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

function PRD:RefreshBarColor(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

function PRD:RefreshTextColor(eventHandler, self, event, ...) 
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetTextColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

function PRD:RefreshTickMarksColor(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        for _, tickMark in ipairs({ self:GetChildren() }) do
            tickMark:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        end
    end

    return shouldUpdate and frameUpdates
end

function PRD:RefreshTickMarkColor(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)

    if shouldUpdate then
        self:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

function PRD:RefreshTickMarkXOffset(eventHandler, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, eventHandler, nil

    if type(eventHandler) == "function" then
        shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)
    end

    if shouldUpdate then
        self:SetPoint("LEFT", self:GetParent(), "LEFT", (newValue / self.cache.maxPower) * PRD.width, 0)
    end

    return shouldUpdate and frameUpdates
end

function PRD:GetExistingTickMark(name, self)
    for _, child in ipairs({ self:GetChildren() }) do
        if child:GetName() == name then
            return child
        end
    end

    return nil
end

function PRD:RefreshTickMarkOffsets(eventHandler, self, event, ...)
    local barPositionConfig = PRD.positionAndSizeConfig[self.barName]
    local barConfiguration = PRD:GetConfiguration()[self.barName]
    local shouldUpdate, newValue, frameUpdates = true, eventHandler, nil

    if type(eventHandler) == "function" then
        shouldUpdate, newValue, frameUpdates = eventHandler(self.cache, event, ...)
    end

    if shouldUpdate then
        for _, tickMark in ipairs({ self:GetChildren() }) do
            tickMark:Hide()
        end

        for index, tickConfig in pairs(PRD:NormalizeTickMarkOffsets(newValue, barConfiguration.tickMarks.color)) do
            local tickMarkName = "prd_" .. self.barName .. "_tick_mark_" .. index
            local tickMark = PRD:GetExistingTickMark(tickMarkName, self)
            local resourceRatio = ((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / self.cache.maxPower

            if tickMark == nil then
                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(barConfiguration.tickMarks.color) == "function" and barConfiguration.tickMarks.color(cache, "INITIAL")) or barConfiguration.tickMarks.color)
                local isShown = true 
                if type(tickConfig.enabled) == "function" then
                    isShown = select(2, tickConfig.enabled(cache, "INITIAL"))
                end

                local tickMark = PRD:InitializeTickMark(barName, tickId, tickMarkContainer, positionConfig.tickWidth, texture, color, resourceRatio, isShown)
                PRD.bars[barName][tickMark:GetName()] = tickMark
            else
                tickMark:SetPoint("LEFT", self, "LEFT", (index / self.cache.maxPower) * PRD.width, 0)
            end

        end
    end

    return shouldUpdate and frameUpdates
end