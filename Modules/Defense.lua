local _, CE = ...
-- Defense.lua
local _, CE = ...
CE.Defense = CE.Defense or {}
local Defense = CE.Defense

Defense.ARMOR_TYPES = {
    Light =   { bonus = 3, soak = 1, capacity = 2 },
    Medium =  { bonus = 2, soak = 1, capacity = 4 },
    Heavy =   { bonus = 1, soak = 1, capacity = 6 },
}

-- Initialize armor state
function Defense:Initialize()
    CE.Database.db.char.defense = CE.Database.db.char.defense or {}
    local state = CE.Database.db.char.defense
    state.armorType = state.armorType or "Light"
    state.soakRemaining = state.soakRemaining or self:GetArmorData().capacity
end

-- Get current armor data
function Defense:GetArmorData()
    local state = CE.Database.db.char.defense or {}
    return self.ARMOR_TYPES[state.armorType] or self.ARMOR_TYPES["Light"]
end

-- Change armor type
function Defense:SetArmorType(newType)
    if self.ARMOR_TYPES[newType] then
        CE.Database.db.char.defense.armorType = newType
        CE.Database.db.char.defense.soakRemaining = self.ARMOR_TYPES[newType].capacity
    end
end

-- Get current soak remaining
function Defense:GetSoakRemaining()
    return CE.Database.db.char.defense.soakRemaining or 0
end

-- Attempt to soak damage
function Defense:TrySoakStrike()
    local state = CE.Database.db.char.defense
    local data = self:GetArmorData()

    if state.soakRemaining and state.soakRemaining > 0 then
        state.soakRemaining = state.soakRemaining - 1
        return true, data.soak  -- Soaked 1 Strike
    end
    return false, 0 -- No soak left
end

-- Reset soak after short rest (if allowed)
function Defense:ShortRestRepair()
    local state = CE.Database.db.char.defense
    local data = self:GetArmorData()
    state.soakRemaining = data.capacity
end

-- Return Defense score (10 + Finesse + Armor bonus)
function Defense:GetDefenseScore()
    local finesse = tonumber(CE.UI.AttributesPanel.attributes.Finesse.valueText:GetText()) or 0
    return 10 + finesse + self:GetArmorData().bonus
end

-- Debug/print helper
function Defense:PrintStatus()
    local type = CE.Database.db.char.defense.armorType
    local soak = self:GetSoakRemaining()
    local def = self:GetDefenseScore()
    print(string.format("|cFF00BFFF[Armor]|r %s Armor | Soak: %d | Defense: %d", type, soak, def))
end
