local function RefreshCurrentPowerValue(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self:SetValue(newValue / self.cache.maxPower)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshMaxPowerValue(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self:SetValue(newValue / self.cache.maxPower)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshText(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetText(newValue)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshEnabled(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        if newValue then
            frame:Show()
        else 
            frame:Hide()
        end
    end

    return shouldUpdate and frameUpdates
end

local function RefreshBarColor(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self:SetStatusBarColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTextColor(resolver, self, event, ...) 
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self.text:SetTextColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarksColor(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        for _, tickMark in ipairs(self:GetChildren()) do
            tickMark:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
        end
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarkColor(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)

    if shouldUpdate then
        self:SetVertexColor(newValue.r, newValue.g, newValue.b, newValue.a or 1.0)
    end

    return shouldUpdate and frameUpdates
end

local function RefreshTickMarkXOffset(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, resolver, nil

    if type(resolver) == "function" then
        shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)
    end

    if shouldUpdate then
        self:SetPoint("LEFT", self.main, "LEFT", (newValue / self.cache.maxPower) * PRD.width, 0)
    end

    return shouldUpdate and frameUpdates
end

local function NormalizeTickMarkOffsets(configs, cache, commonColor)
    local normalizedConfigs = {}
    
    for k, v in pairs(configs) do
        if type(v) == "table" then
            v.enabled = v.enabled or true
            v.color = v.color or commonColor or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }

            if v.resourceValue_dependencies == nil then
                
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

local function GetExistingTickMark(name, self)
    for _, child in ipairs(self:GetChildren()) do
        if child:GetName() == name then
            return child
        end
    end

    return child
end


-- TODO: Update to use new interface for tick initialization
local function RefreshTickMarkOffsets(resolver, self, event, ...)
    local shouldUpdate, newValue, frameUpdates = true, resolver, nil

    if type(resolver) == "function" then
        shouldUpdate, newValue, frameUpdates = resolver(self.cache, event, ...)
    end

    if shouldUpdate then
        for _, tickMark in ipairs(self:GetChildren()) do
            tickMark:Hide()
        end

        for index, tickConfig in pairs(NormalizeTickMarkOffsets(newValue, self.cache, barConfiguration.tickMarks.color)) do
            local tickMark = GetExistingTickMark(self:GetName() .. "_" .. index, self)
            if existingTickMark == nil then
                local barPositionConfig = self.positionConfig
                local barConfiguration = self.configuration
                local color = (type(barConfiguration.tickMarks.color) == "table" and barConfiguration.tickMarks.color) or { r = 1.0, g = 1.0, g = 1.0, a = 1.0 }
                tickMark = InitializeTickMark(self:GetName() .. "_" .. index, parent, barPositionConfig.tickWidth, barConfiguration.tickMarks.texture, color, tickConfig)
            else
                tickMark:SetPoint("LEFT", parent, "LEFT", (index / self.cache.maxPower) * PRD.width, 0)
            end

        end
    end

    return shouldUpdate and frameUpdates
end