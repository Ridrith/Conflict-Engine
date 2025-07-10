local _, CE = ...

local Database = {}
CE.Database = Database

local defaults = {
    global = {
        -- Global settings that apply to all characters
        settings = {
            outputChannel = "PARTY",
            coloredOutput = true,
            showOutputWindow = false,  -- Default to not showing the output window
            outputWindowLocked = false,
            playSounds = true,
            criticalSound = true,
            showInChat = true,
            whisperRolls = false,
            compactMode = false
        }
    },
    char = {
        -- Character-specific data
        attributes = {
            Might = 0,
            Finesse = 0,
            Endurance = 0,
            Insight = 0,
            Resolve = 0,
            Presence = 0,
            Faith = 0,
            Magic = 0,
            Luck = 0
        },
        currency = {
            gold = 0,
            silver = 0,
            copper = 0
        },
        traits = {},
        defense = {
            armorType = "NONE",
            hasShield = false,
            hasHelm = false,
            customDefense = 0,
            customDR = 0
        },
        rollHistory = {},
        ui = {
            position = {},
            scale = 1,
            outputPosition = {},
            mainWindowShown = false
        }
    },
    profile = {
        -- Profile-based settings (can be shared between characters)
        templates = {}
    }
}

function Database:Initialize()
    -- Initialize with per-character defaults
    self.db = LibStub("AceDB-3.0"):New("ConflictEngineDB", defaults, true)
    
    -- Get character info for display
    local name = UnitName("player")
    local realm = GetRealmName()
    self.characterName = name .. " - " .. realm
    
    -- Register for profile callbacks
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshUI")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshUI")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshUI")
end

function Database:RefreshUI()
    -- Refresh all UI panels when profile changes
    if CE.UI.AttributesPanel and CE.UI.AttributesPanel.UpdateAllAttributes then
        CE.UI.AttributesPanel:UpdateAllAttributes()
    end
    if CE.UI.TraitsPanel and CE.UI.TraitsPanel.RefreshTraits then
        CE.UI.TraitsPanel:RefreshTraits()
    end
    if CE.UI.DefensePanel and CE.UI.DefensePanel.UpdateDisplay then
        CE.UI.DefensePanel:UpdateDisplay()
    end
    if CE.UI.CurrencyDisplay and CE.UI.CurrencyDisplay.UpdateDisplay then
        CE.UI.CurrencyDisplay:UpdateDisplay()
    end
    if CE.UI.ConfigPanel and CE.UI.ConfigPanel.RefreshValues then
        CE.UI.ConfigPanel:RefreshValues()
    end
end

function Database:GetCurrentCharacter()
    return self.characterName
end

-- Settings functions
function Database:GetSetting(key)
    return self.db.global.settings[key]
end

function Database:SetSetting(key, value)
    self.db.global.settings[key] = value
end

function Database:GetAttribute(name)
    return self.db.char.attributes[name] or 0
end

function Database:SetAttribute(name, value)
    self.db.char.attributes[name] = math.max(CE.Constants.ATTRIBUTE_MIN, math.min(CE.Constants.ATTRIBUTE_MAX, value))
end

function Database:GetCurrency()
    return self.db.char.currency
end

function Database:SetCurrency(typeOrTable, amount)
    -- Handle both table and individual currency updates
    if type(typeOrTable) == "table" then
        -- Full currency update with table
        self.db.char.currency.gold = math.max(0, typeOrTable.gold or 0)
        self.db.char.currency.silver = math.max(0, typeOrTable.silver or 0)
        self.db.char.currency.copper = math.max(0, typeOrTable.copper or 0)
    else
        -- Individual currency type update
        if typeOrTable and amount then
            self.db.char.currency[typeOrTable] = math.max(0, amount)
        end
    end
end

function Database:AddCurrency(type, amount)
    self.db.char.currency[type] = math.max(0, (self.db.char.currency[type] or 0) + amount)
end

function Database:GetTraits()
    return self.db.char.traits
end

function Database:AddTrait(trait)
    table.insert(self.db.char.traits, trait)
end

function Database:RemoveTrait(index)
    table.remove(self.db.char.traits, index)
end

function Database:UpdateTrait(index, trait)
    if self.db.char.traits[index] then
        self.db.char.traits[index] = trait
    end
end

function Database:GetDefense()
    return self.db.char.defense
end

function Database:SetDefense(key, value)
    self.db.char.defense[key] = value
end

function Database:AddRollToHistory(rollData)
    table.insert(self.db.char.rollHistory, 1, rollData)
    -- Keep only last 100 rolls
    while #self.db.char.rollHistory > 100 do
        table.remove(self.db.char.rollHistory)
    end
end

function Database:GetRollHistory()
    return self.db.char.rollHistory
end

-- Profile management functions
function Database:GetProfiles()
    return self.db:GetProfiles()
end

function Database:SetProfile(name)
    self.db:SetProfile(name)
end

function Database:CopyProfile(name)
    self.db:CopyProfile(name)
end

function Database:DeleteProfile(name)
    self.db:DeleteProfile(name)
end

function Database:ResetProfile()
    self.db:ResetProfile()
end