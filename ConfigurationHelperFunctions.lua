local PRD = PRD

local UnitAura = UnitAura

-- Unit Aura functions that return info about the first Aura matching the spellName or spellID given on the unit.

function PRD:GetUnitAura(unit, spell, filter)
  if filter and not filter:upper():find("FUL") then
      filter = filter.."|HELPFUL"
  end
  for i = 1, 255 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitAura(unit, i, filter)
    if not name then return end
    if spell == spellId or spell == name then
      return UnitAura(unit, i, filter)
    end
  end
end

function PRD:GetUnitBuff(unit, spell, filter)
  filter = filter and filter.."|HELPFUL" or "HELPFUL"
  return PRD:GetUnitAura(unit, spell, filter)
end

function PRD:GetUnitDebuff(unit, spell, filter)
  filter = filter and filter.."|HARMFUL" or "HARMFUL"
  return PRD:GetUnitAura(unit, spell, filter)
end