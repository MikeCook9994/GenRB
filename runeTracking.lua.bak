function InitializeRuneProgressBar(id, specBarConfig)
    local barPositionConfig = this.progressBarPositionAndSizeConfiguration[id]

    local progressBar = {}

    local xOffset = barPositionConfig.xOffset or 0
    local yOffset = barPositionConfig.yOffset
    local anchorPoint = barPositionConfig.anchorPoint
    local height = barPositionConfig.height
    local width = (barPositionConfig.width or this.region.bar:GetWidth()) / 6

    for runeId=1,6 do
        local start, duration, runeReady = GetRuneCooldown(runeId)
        local elapsedCooldown = GetTime() - start
        local runeIndex = 7 - runeId

        progressBar[runeIndex] = {}
        progressBar[runeIndex].main = InitializeStatusBar(runeIndex, this.region.bar, height, width, anchorPoint, xOffset, yOffset, "MEDIUM", specBarConfig.texture, ResolveColor(specBarConfig.color, Enum.PowerType.Runes, elapsedCooldown, duration), inverseFill)
        progressBar[runeIndex].background = InitializeBackground(runeIndex, progressBar[runeIndex].main)

        xOffset = xOffset + width

        if runeIndex ~= 6 then
            local tickMarkColor = ResolveColor(specBarConfig.tickMarks.color, Enum.PowerType.Runes, elapsedCooldown, duration)
            progressBar[runeIndex].tickMark = InitializeTickMark(runeIndex .. "_rune" .. runeIndex, progressBar[runeIndex].main, 0, barPositionConfig.tickWidth, specBarConfig.tickMarks.texture, tickMarkColor)
        end

        progressBar[runeIndex].text = InitializeText(runeIndex, progressBar[runeIndex].main, yOffset, specBarConfig.text, elapsedCooldown, duration)    
    end

    return progressBar
end
    
-- Rune tracking

function RefreshRuneText(textFrame, textConfig, elapsedCooldown, duration, opacityModifier)
    if ResolveEnabled(textConfig.enabled, elapsedCooldown, duration) then
        textFrame:Show()
        textFrame:SetText(GetText(textConfig.value, elapsedCooldown, duration))

        if type(textConfig.color) == "function" then
            local color = textConfig.color()
            textFrame:SetTextColor(color.r, color.g, color.b, color.a * opacityModifier)
        end
    else 
        textFrame:Hide()
    end
end

function ShowRuneBar(progressBar)
    for runeIndex = 1,6 do
        progressBar[runeIndex].main:Show()
        progressBar[runeIndex].background:Show()
        progressBar[runeIndex].text:Show()
        
        if progressBar[runeIndex].tickMark then
            progressBar[runeIndex].tickMark:Show()
        end
    end
end

function HideRuneBar(progressBar)
    for runeIndex = 1,6 do
        progressBar[runeIndex].main:Hide()
        progressBar[runeIndex].background:Hide()
        progressBar[runeIndex].text:Hide()
        
        if progressBar[runeIndex].tickMark then
            progressBar[runeIndex].tickMark:Hide()
        end
    end
end

function RefreshCurrentRune(rune, powerType, elapsedCooldown, duration, color, opacityModifier)
    rune:SetValue(elapsedCooldown / duration)
    local color = ResolveColor(color, ResolvePowerType(powerType), elapsedCooldown, duration)
    rune:SetStatusBarColor(color.r, color.g, color.b, color.a)
    rune:SetAlpha(opacityModifier)
end

function RefreshRuneProgressBar(progressBarName, progressBarConfig)
    local progressBar = this.progressBars[progressBarName]

    if ResolveEnabled(progressBarConfig.enabled, nil, nil) then
        local opacityModifier = UnitAffectingCombat("player") and 1.0 or progressBarConfig.OutOfCombatOpacityFactor or 0.4

        for runeIndex, runeProgressBar in pairs(progressBar) do
            local start, duration, runeReady = GetRuneCooldown(runeIndex)
            local elapsedCooldown =  start ~= 0 and (GetTime() - start) or duration

            RefreshCurrentRune(runeProgressBar.main, progressBarConfig.powerType, elapsedCooldown, duration, progressBarConfig.color, opacityModifier)
            RefreshRuneText(runeProgressBar.text, progressBarConfig.text or {}, elapsedCooldown, duration)

            runeProgressBar.background:SetAlpha(0.5 * opacityModifier)
        end
    else 
        HideRuneBar(progressBar)
    end
end