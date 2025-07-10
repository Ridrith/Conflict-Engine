local _, CE = ...

local AttributesPanel = {}
CE.UI = CE.UI or {}
CE.UI.AttributesPanel = AttributesPanel

function AttributesPanel:Initialize(parent)
    if not parent then return end
    
    self.parent = parent
    
    -- Panel title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("CHARACTER ATTRIBUTES")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Create containers
    self:CreateAttributeSection()
    self:CreateSummarySection()
    self:CreateActionSection()
    
    -- Initial update
    self:UpdateAllAttributes()
end

function AttributesPanel:CreateAttributeSection()
    -- Main attribute container
    local container = CreateFrame("Frame", nil, self.parent)
    container:SetPoint("TOPLEFT", 20, -50)
    container:SetSize(500, 280)
    
    self.attributes = {}
    
    local attributeData = {
        {name = "Might", icon = "Interface\\Icons\\Ability_Warrior_StrengthOfArms"},
        {name = "Finesse", icon = "Interface\\Icons\\Ability_Rogue_Sprint"},
        {name = "Endurance", icon = "Interface\\Icons\\Spell_Holy_WordFortitude"},
        {name = "Insight", icon = "Interface\\Icons\\Spell_Nature_FocusedMind"},
        {name = "Resolve", icon = "Interface\\Icons\\Ability_Paladin_BeaconOfLight"},
        {name = "Presence", icon = "Interface\\Icons\\Achievement_Reputation_01"},
        {name = "Faith", icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing"},
        {name = "Magic", icon = "Interface\\Icons\\Spell_Arcane_MindMastery"},
        {name = "Luck", icon = "Interface\\Icons\\INV_Misc_Dice_01"}
    }
    
    -- Create 3x3 grid
    for i, data in ipairs(attributeData) do
        local row = math.floor((i-1) / 3)
        local col = (i-1) % 3
        
        local attrFrame = self:CreateAttributeFrame(container, data.name, data.icon)
        attrFrame:SetPoint("TOPLEFT", col * 170, -row * 90)
        
        self.attributes[data.name] = attrFrame
    end
end

function AttributesPanel:CreateAttributeFrame(parent, name, iconPath)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(160, 80)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Icon container
    local iconBg = frame:CreateTexture(nil, "BACKGROUND")
    iconBg:SetSize(40, 40)
    iconBg:SetPoint("LEFT", 8, 0)
    iconBg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER", iconBg)
    icon:SetTexture(iconPath)
    
    -- Icon border
    local iconBorder = frame:CreateTexture(nil, "OVERLAY")
    iconBorder:SetSize(44, 44)
    iconBorder:SetPoint("CENTER", iconBg)
    iconBorder:SetAtlas("talents-node-choiceflyout-square")
    iconBorder:SetVertexColor(0.5, 0.5, 0.5)
    
    -- Name
    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", iconBg, "TOPRIGHT", 8, -5)
    nameText:SetText(name)
    
    -- Value
    local valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    valueText:SetPoint("TOPLEFT", iconBg, "TOPRIGHT", 8, -22)
    valueText:SetTextColor(0.9, 0.75, 0.3)
    
    -- Button container
    local buttonFrame = CreateFrame("Frame", nil, frame)
    buttonFrame:SetPoint("BOTTOMRIGHT", -5, 5)
    buttonFrame:SetSize(90, 22)
    
    -- Minus button
    local minusBtn = CreateFrame("Button", nil, buttonFrame, "UIPanelButtonTemplate")
    minusBtn:SetSize(22, 22)
    minusBtn:SetPoint("LEFT", 0, 0)
    minusBtn:SetText("-")
    minusBtn:SetScript("OnClick", function()
        self:ModifyAttribute(name, -1)
    end)
    
    -- Plus button
    local plusBtn = CreateFrame("Button", nil, buttonFrame, "UIPanelButtonTemplate")
    plusBtn:SetSize(22, 22)
    plusBtn:SetPoint("LEFT", minusBtn, "RIGHT", 2, 0)
    plusBtn:SetText("+")
    plusBtn:SetScript("OnClick", function()
        self:ModifyAttribute(name, 1)
    end)
    
    -- Roll button
    local rollBtn = CreateFrame("Button", nil, buttonFrame, "UIPanelButtonTemplate")
    rollBtn:SetSize(40, 22)
    rollBtn:SetPoint("LEFT", plusBtn, "RIGHT", 2, 0)
    rollBtn:SetText("Roll")
    rollBtn:SetScript("OnClick", function()
        self:RollAttribute(name)
    end)
    
    -- Store elements
    frame.icon = icon
    frame.iconBorder = iconBorder
    frame.nameText = nameText
    frame.valueText = valueText
    frame.minusBtn = minusBtn
    frame.plusBtn = plusBtn
    frame.rollBtn = rollBtn
    
    return frame
end

function AttributesPanel:CreateSummarySection()
    local summary = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    summary:SetSize(220, 200)
    summary:SetPoint("TOPRIGHT", -20, -50)
    summary:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    summary:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    summary:SetBackdropBorderColor(0.6, 0.5, 0.2, 0.8)
    
    -- Title
    local title = summary:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("STATISTICS")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Stats
    local yOffset = -35
    
    summary.totalLabel = summary:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summary.totalLabel:SetPoint("TOPLEFT", 15, yOffset)
    summary.totalLabel:SetText("Total Points:")
    summary.totalLabel:SetTextColor(0.6, 0.6, 0.6)
    
    summary.totalValue = summary:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    summary.totalValue:SetPoint("TOPRIGHT", -15, yOffset)
    
    yOffset = yOffset - 30
    
    summary.avgLabel = summary:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summary.avgLabel:SetPoint("TOPLEFT", 15, yOffset)
    summary.avgLabel:SetText("Average:")
    summary.avgLabel:SetTextColor(0.6, 0.6, 0.6)
    
    summary.avgValue = summary:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    summary.avgValue:SetPoint("TOPRIGHT", -15, yOffset)
    
    self.summary = summary
end

function AttributesPanel:CreateActionSection()
    local actions = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    actions:SetSize(400, 60)
    actions:SetPoint("BOTTOM", 0, 20)
    actions:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    actions:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    actions:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Roll All button
    local rollAllBtn = CreateFrame("Button", nil, actions, "UIPanelButtonTemplate")
    rollAllBtn:SetSize(120, 30)
    rollAllBtn:SetPoint("LEFT", 20, 0)
    rollAllBtn:SetText("Roll All Stats")
    rollAllBtn:SetScript("OnClick", function()
        self:RollAllAttributes()
    end)
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, actions, "UIPanelButtonTemplate")
    resetBtn:SetSize(120, 30)
    resetBtn:SetPoint("RIGHT", -20, 0)
    resetBtn:SetText("Reset to 5")
    resetBtn:SetScript("OnClick", function()
        self:ResetAllAttributes()
    end)
end

function AttributesPanel:UpdateAllAttributes()
    local total = 0
    
    for _, attrName in ipairs(CE.Constants.ATTRIBUTES) do
        local value = CE.Database:GetAttribute(attrName)
        total = total + value
        
        local frame = self.attributes[attrName]
        if frame then
            -- Show modifier format
            local modifierText = value >= 0 and string.format("+%d", value) or tostring(value)
            frame.valueText:SetText(modifierText)
            
            -- Update colors
            if value <= -2 then
                frame.valueText:SetTextColor(0.8, 0.2, 0.2)
                frame.iconBorder:SetVertexColor(0.8, 0.2, 0.2)
            elseif value >= 3 then
                frame.valueText:SetTextColor(0.2, 0.8, 0.2)
                frame.iconBorder:SetVertexColor(0.2, 0.8, 0.2)
            else
                frame.valueText:SetTextColor(0.9, 0.75, 0.3)
                frame.iconBorder:SetVertexColor(0.5, 0.5, 0.5)
            end
            
            -- Update button states
            frame.minusBtn:SetEnabled(value > CE.Constants.ATTRIBUTE_MIN)
            frame.plusBtn:SetEnabled(value < CE.Constants.ATTRIBUTE_MAX)
        end
    end
    
    -- Update summary
    if self.summary then
        self.summary.totalValue:SetText(total)
        self.summary.avgValue:SetText(string.format("%.1f", total / 9))
        
        -- Color total
        if total > 18 then  -- Adjusted for modifier system
            self.summary.totalValue:SetTextColor(0.2, 0.8, 0.2)
        elseif total < 0 then
            self.summary.totalValue:SetTextColor(0.8, 0.2, 0.2)
        else
            self.summary.totalValue:SetTextColor(0.9, 0.75, 0.3)
        end
    end
end

function AttributesPanel:ModifyAttribute(name, delta)
    local current = CE.Database:GetAttribute(name)
    local new = current + delta
    
    if new >= CE.Constants.ATTRIBUTE_MIN and new <= CE.Constants.ATTRIBUTE_MAX then
        CE.Database:SetAttribute(name, new)
        self:UpdateAllAttributes()
    end
end

function AttributesPanel:RollAttribute(name)
    local modifier = CE.Database:GetAttribute(name)
    local result = CE.Utils:RollDice(20, 1)
    local total = result.total + modifier
    
    -- Format the modifier for display
    local modStr = modifier >= 0 and string.format("+%d", modifier) or tostring(modifier)
    
    CE.Communication:SendRoll({
        type = "attribute",
        detail = string.format("%s (1d20%s)", name, modStr),
        rolls = result.rolls,
        total = total,
        modifier = modifier
    })
end

function AttributesPanel:RollAllAttributes()
    for _, name in ipairs(CE.Constants.ATTRIBUTES) do
        self:RollAttribute(name)
    end
end

function AttributesPanel:ResetAllAttributes()
    for _, name in ipairs(CE.Constants.ATTRIBUTES) do
        CE.Database:SetAttribute(name, 0)  -- 0 modifier by default
    end
    self:UpdateAllAttributes()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFF[CE]|r All attributes reset to 0")
end