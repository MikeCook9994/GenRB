-- refresher functions

local function RefreshCurrentPowerValue(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.main:SetValue(newValue / self.cache.maxPower)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshNextValue(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.main:SetValue(self.cache.currentPower / newValue)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshMaxPowerValue(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.prediction:SetValue(newValue / self.cache.maxPower)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshText(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetText(newValue)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshEnabled(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        local frame = nil
        if path == "text" then
            frame = self.text
        elseif path == "prediction" then
            frame = self.prediction
        elseif path == nil then
            frame = self.main
        elseif string.find(path, "tickMarksoffsets") then
            frame = self.tickMarks[strsub(path, 17)]
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

local function RefreshBarColor(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        if path == 'prediction' then
            self.prediction:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        else
            self.main:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        end
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTextColor(self, path, resolver, event, ...) 
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetTextColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarkColor(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.tickMarks[strsub(path, 17)]:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarkXOffset(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, resolver, nil

    if type(resolver) == "function" then
        shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)
    end

    if shouldUpdate then
        local tickMark = self.tickMarks[strsub(path, 17)]
        if tickMark ~= nil then
            tickMark:SetPoint("LEFT", self.main, "LEFT", newValue / self.cache.maxPower * self.main:GetWidth(), 0)
        end
    end

    return shouldUpdate and frameUpdates
end

local function NormalizeTickMarkOffsets(configs, cache)
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

local function RefreshTickMarkOffsets(self, path, resolver, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, resolver, nil

    if type(resolver) == "function" then
        shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)
    end

    if shouldUpdate then
        for id, tickMark in pairs(self.tickMarks) do
            tickMark:Hide()
        end

        for index, tickConfig in pairs(NormalizeTickMarkOffsets(newValue, self.cache)) do
            if self.tickMarks[index] ~= nil then
                self.tickMarks[index]:Show()
            else
                local barPositionConfig = self.positionConfig
                local barConfiguration = self.configuration
                local color = (type(barConfiguration.tickMarks.color) == "table" and barConfiguration.tickMarks.color) or { r = 1.0, g = 1.0, g = 1.0, a = 1.0 }
                self.tickMarks[index] = InitializeTickMark(barName .. "_" .. index, self.main, barPositionConfig.tickWidth, barConfiguration.tickMarks.texture, color, 0)
            end

            self.tickMarks[index]:SetPoint("LEFT", self.main, "LEFT", (index / self.cache.maxPower) * self.main:GetWidth(), 0)
        end
    end

    return shouldUpdate and frameUpdates
end