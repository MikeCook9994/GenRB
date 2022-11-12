-----------------------
-- DO NOT EDIT BELOW --
-----------------------
aura_env.spells = {
    -- Moonkin
    [190984] = function() return IsPlayerSpell(114107) and GetPlayerAuraBySpellID(48517) and 9 or 6 end,  -- Wrath
    [194153] = 8,  --  StarFire
    [214281] = 10, -- New Moon
    [274281] = 10, -- New Moon
    [214282] = 20, -- Half Moon
    [274282] = 20, -- Half Moon
    [274283] = 40, -- Full Moon
    [202347] = 8,  -- Stellar Flare
    -- Spriest
    [8092] = 12,   -- MB
    [205351] = 15, -- SW:V
    [585] = 12,    -- MF
    [48045] = 5,   -- * target hit  -- Mind Sear
    [34914] = 6,   -- VT
    -- Shaman
    [188196] = 8,
    [51505] = 10,
    [210714] = 15,
    [188443] = 4,
    --Hunter
    [56641] = 10,
    
}

local r = aura_env.region
local b = r.bar
local aura_env = aura_env

local indicators = {}
for _, settings in pairs(aura_env.config.ticks) do
    indicators[settings.type] = indicators[settings.type] or {}
    if settings.spec > 0 then
        indicators[settings.type][settings.spec] = indicators[settings.type][settings.spec] or {}
        table.insert(indicators[settings.type][settings.spec], settings.value)
    else
        indicators[settings.type].all = indicators[settings.type].all or {}
        table.insert(indicators[settings.type].all, settings.value)
    end
end

if not r.tickPool then 
    r.tickPool = CreateTexturePool(b, "ARTWORK",7,nil) 
end

aura_env.placeTicks = function()
    local powerID, powerType = UnitPowerType("player")
    local c = PowerBarColor[powerType]
    --r:Color(c.r, c.g, c.b, 1)
    local red, green, blue = c.r, c.g, c.b
    local col = aura_env.config.overrideTickCol and aura_env.config.tickCol or {1-red,1-green,1-blue,0.2}
    local maxWidth = b:GetWidth()
    local maxP = UnitPowerMax("player")
    local pix = maxWidth / maxP
    local specID = GetSpecializationInfo(GetSpecialization())
    r.tickPool:ReleaseAll();
    local indicatorTable = indicators[powerID] and indicators[powerID][specID] or indicators[powerID] and indicators[powerID].all or nil
    if indicatorTable then
        for i,v in pairs(indicatorTable) do
            local perc = v:match("(%d+)%%") 
            if perc then 
                v = maxP * (perc/100)
            end
            if pix*v < maxWidth then
                local tickB = r.tickPool:Acquire()
                b["tickB"..i] = tickB
                b["tickB"..i]:SetDrawLayer("ARTWORK", 3);
                b["tickB"..i]:SetColorTexture(unpack(col))
                b["tickB"..i]:SetWidth(2);
                b["tickB"..i]:SetHeight(b:GetHeight());
                b["tickB"..i]:ClearAllPoints()
                b["tickB"..i]:SetPoint("CENTER", b.fg, "LEFT", pix*v, 0)
                b["tickB"..i]:Show()
            end
        end
    end
end

if not b.BS then
    local BS = b:CreateTexture(nil, "ARTWORK")
    BS:SetColorTexture(1,1,1,1)
    BS:SetAlpha(0)
    b.BS = BS
end
b.BS:SetHeight(b:GetHeight())
b.BS.anim = b.BS:CreateAnimationGroup()
local anim = b.BS.anim:CreateAnimation("Alpha")
anim:SetFromAlpha(0.5)
anim:SetToAlpha(0)
anim:SetDuration(0.5)
anim:SetSmoothing("OUT")
if not aura_env.region.hooked then
    hooksecurefunc(b, "UpdateProgress", function()
            if b.previousValue 
            and math.abs(b.value - b.previousValue)/b.max > 0.1 then 
                local low = b.value > b.previousValue and b.previousValue or b.value
                local diff = math.abs(b.previousValue - b.value)
                b.BS:ClearAllPoints()
                b.BS:SetPoint("TOPLEFT", low/b.max*b:GetWidth(),0)
                b.BS:SetWidth(diff/b.max*b:GetWidth())
                b.BS.anim:Play()
            end
            b.previousValue = b.value
        end
    )
    aura_env.region.hooked = true
end

if not b.modelFrame then
    local modelFrame = CreateFrame("FRAME", nil, b)
    b.modelFrame = modelFrame
    local sparkle = CreateFrame("PlayerModel", nil, b.modelFrame)
    b.modelFrame.sparkle = sparkle
    b.modelFrame.sparkle:SetKeepModelOnHide(true)
end

b.modelFrame.sparkle:SetModel(1630153)
b.modelFrame.sparkle:ClearTransform()
b.modelFrame.sparkle:SetPosition(4,0.32,1.85,0)
local h = b:GetHeight()
b.modelFrame.sparkle:SetPoint("RIGHT", b.modelFrame)
b.modelFrame.sparkle:SetSize(h*2, h)
b.modelFrame.sparkle:SetAlpha(0.20)

b.modelFrame:SetAllPoints(b.fg)
b.modelFrame:SetClipsChildren(true)
if aura_env.config.useSpark then
    b.modelFrame:Show()
else 
    b.modelFrame:Hide()
end

