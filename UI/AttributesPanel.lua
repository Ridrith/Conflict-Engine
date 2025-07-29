local _, CE = ...

local AttributesPanel = {}
CE.UI = CE.UI or {}
CE.UI.AttributesPanel = AttributesPanel

function AttributesPanel:Initialize(parent)
    if not parent then return end
    
    self.parent = parent
    
    -- Dark metallic header strip
    local headerBg = parent:CreateTexture(nil, "BACKGROUND")
    headerBg:SetHeight(50)
    headerBg:SetPoint("TOPLEFT", 0, 0)
    headerBg:SetPoint("TOPRIGHT", 0, 0)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    -- Burgundy accent line
    local accentLine = parent:CreateTexture(nil, "ARTWORK")
    accentLine:SetHeight(2)
    accentLine:SetPoint("TOPLEFT", headerBg, "BOTTOMLEFT", 20, 0)
    accentLine:SetPoint("TOPRIGHT", headerBg, "BOTTOMRIGHT", -20, 0)
    accentLine:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    -- Title with pale gold
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    local font, size = title:GetFont()
    title:SetFont("Fonts\\FRIZQT__.ttf", 20, "THICKOUTLINE")
    title:SetText("ATTRIBUTES")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)
    
    -- Decorative divider with dark silver
    local divider = CE.Style:CreateDivider(parent, 300)
    divider:SetPoint("TOP", title, "BOTTOM", 0, -5)
    divider:SetVertexColor(0.35, 0.35, 0.4, 0.6) -- Dark silver
    
    -- Create sections with proper spacing
    self:CreateAttributeGrid()
    self:CreateSummaryPanel()
    self:CreateActionBar()
    
    -- Initial update
    self:UpdateAllAttributes()
end

function AttributesPanel:CreateFlatButton(parent, text, width, height)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, height)
    
    -- Flat dark background
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    btn.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    -- Border
    btn.border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    btn.border:SetAllPoints()
    btn.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8) -- Dark silver
    
    -- Text
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("CENTER")
    btn.text:SetFont("Fonts\\FRIZQT__.ttf", height > 20 and 12 or 10, "OUTLINE")
    btn.text:SetText(text)
    btn.text:SetTextColor(0.65, 0.65, 0.7) -- Silver
    
    -- Hover effect
    btn:SetScript("OnEnter", function()
        btn.bg:SetVertexColor(0.15, 0.04, 0.06, 0.9) -- Dark burgundy
        btn.border:SetBackdropBorderColor(0.5, 0.12, 0.18, 1) -- Burgundy
        btn.text:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    end)
    
    btn:SetScript("OnLeave", function()
        btn.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
        btn.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
        btn.text:SetTextColor(0.65, 0.65, 0.7)
    end)
    
    btn:SetScript("OnMouseDown", function()
        btn.text:SetPoint("CENTER", 1, -1)
    end)
    
    btn:SetScript("OnMouseUp", function()
        btn.text:SetPoint("CENTER", 0, 0)
    end)
    
    return btn
end

function AttributesPanel:CreateAttributeGrid()
    -- Dark stone container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 20, -70)
    container:SetPoint("BOTTOMRIGHT", self.parent, "BOTTOMLEFT", 580, 130)

    CE.Style:ApplyBackdrop(container, "simple")
    container:SetBackdropColor(0.03, 0.03, 0.04, 0.95) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver border

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

    -- Create 3x3 grid layout, evenly spaced
    local spacingX = 175
    local spacingY = 95
    local startX = 15
    local startY = -15

    for i, data in ipairs(attributeData) do
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3

        local attrFrame = self:CreateAttributeFrame(container, data.name, data.icon)
        attrFrame:SetPoint("TOPLEFT", startX + col * spacingX, startY - row * spacingY)

        self.attributes[data.name] = attrFrame
    end
end

function AttributesPanel:CreateAttributeFrame(parent, name, iconPath)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(165, 85)
    
    -- Dark metallic frame background
    CE.Style:ApplyBackdrop(frame, "wood")
    frame:SetBackdropColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    frame:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8) -- Dark silver
    
    -- Icon holder with dark background
    local iconHolder = frame:CreateTexture(nil, "BACKGROUND")
    iconHolder:SetSize(50, 50)
    iconHolder:SetPoint("LEFT", 10, 0)
    iconHolder:SetTexture("Interface\\Achievements\\UI-Achievement-IconFrame")
    iconHolder:SetVertexColor(0.15, 0.15, 0.18, 0.9) -- Dark grey
    
    -- Icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("CENTER", iconHolder, "CENTER", 0, -2)
    icon:SetTexture(iconPath)
    icon:SetVertexColor(0.85, 0.85, 0.9) -- Slightly bluish silver
    
    -- Icon quality border
    local iconBorder = frame:CreateTexture(nil, "OVERLAY")
    iconBorder:SetSize(50, 50)
    iconBorder:SetPoint("CENTER", iconHolder)
    iconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
    iconBorder:SetVertexColor(0.5, 0.5, 0.55) -- Silver
    
    -- Name with pale gold
    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", iconHolder, "TOPRIGHT", 10, -8)
    nameText:SetFont("Fonts\\FRIZQT__.ttf", 13, "")
    nameText:SetText(name)
    nameText:SetTextColor(0.7, 0.7, 0.75) -- Pale silver
    
    -- Value with improved position and size
    local valueText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    valueText:SetPoint("TOPLEFT", iconHolder, "TOPRIGHT", 10, -25)
    valueText:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
    valueText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Button container with better alignment
    local buttonFrame = CreateFrame("Frame", nil, frame)
    buttonFrame:SetPoint("BOTTOMRIGHT", -8, 8)
    buttonFrame:SetSize(82, 22)
    
    -- Minus button with flat style
    local minusBtn = self:CreateFlatButton(buttonFrame, "-", 22, 22)
    minusBtn:SetPoint("LEFT", 0, 0)
    minusBtn.text:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE") -- Larger font for symbols
    minusBtn:SetScript("OnClick", function()
        self:ModifyAttribute(name, -1)
    end)

    -- Plus button with flat style
    local plusBtn = self:CreateFlatButton(buttonFrame, "+", 22, 22)
    plusBtn:SetPoint("LEFT", minusBtn, "RIGHT", 2, 0)
    plusBtn.text:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE") -- Larger font for symbols
    plusBtn:SetScript("OnClick", function()
        self:ModifyAttribute(name, 1)
    end)

    -- Roll button with flat style
    local rollBtn = self:CreateFlatButton(buttonFrame, "Roll", 34, 22)
    rollBtn:SetPoint("LEFT", plusBtn, "RIGHT", 2, 0)
    rollBtn.text:SetFont("Fonts\\FRIZQT__.ttf", 10, "OUTLINE") -- Smaller font for text
    rollBtn:SetScript("OnClick", function()
        self:RollAttribute(name)
    end)

    -- Hover effect for frame with burgundy accent
    frame:SetScript("OnEnter", function()
        frame:SetBackdropBorderColor(0.5, 0.12, 0.18, 1) -- Burgundy highlight
        nameText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold on hover
    end)

    frame:SetScript("OnLeave", function()
        frame:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8) -- Back to dark silver
        nameText:SetTextColor(0.7, 0.7, 0.75) -- Back to pale silver
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

function AttributesPanel:CreateSummaryPanel()
    local summary = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    summary:SetSize(240, 150)
    summary:SetPoint("TOPRIGHT", -20, -70)

    -- Dark stone backdrop instead of parchment
    summary:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 64,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    summary:SetBackdropColor(0.05, 0.05, 0.07, 0.95) -- Nearly black
    summary:SetBackdropBorderColor(0.35, 0.35, 0.4, 0.9) -- Dark silver border
    
    -- Add subtle inner glow
    local innerGlow = summary:CreateTexture(nil, "BACKGROUND", nil, 1)
    innerGlow:SetPoint("TOPLEFT", 4, -4)
    innerGlow:SetPoint("BOTTOMRIGHT", -4, 4)
    innerGlow:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    innerGlow:SetVertexColor(0.4, 0.1, 0.15, 0.15) -- Very subtle burgundy glow
    innerGlow:SetBlendMode("ADD")

    -- Corner decorations with pale gold
    CE.Style:CreateCornerDecoration(summary, "TOPLEFT")
    CE.Style:CreateCornerDecoration(summary, "TOPRIGHT")
    local corners = {summary:GetRegions()}
    for _, region in ipairs(corners) do
        if region:GetObjectType() == "Texture" and region:GetTexture() and string.find(region:GetTexture(), "Corner") then
            region:SetVertexColor(0.65, 0.6, 0.45, 0.6) -- Pale gold
        end
    end

    -- Title Bar with pale gold text
    local title = summary:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOP", 0, -12)
    CE.Style:ApplyFontString(title, "title")
    title:SetText("Attribute Summary")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    title:SetShadowOffset(2, -2)

    -- Total Points with dark background
    local totalBg = summary:CreateTexture(nil, "ARTWORK")
    totalBg:SetSize(200, 32)
    totalBg:SetPoint("TOP", title, "BOTTOM", 0, -12)
    totalBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    totalBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip

    summary.totalLabel = summary:CreateFontString(nil, "OVERLAY")
    summary.totalLabel:SetPoint("LEFT", totalBg, "LEFT", 15, 0)
    CE.Style:ApplyFontString(summary.totalLabel, "label")
    summary.totalLabel:SetText("Total Points:")
    summary.totalLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver

    summary.totalValue = summary:CreateFontString(nil, "OVERLAY")
    summary.totalValue:SetPoint("RIGHT", totalBg, "RIGHT", -15, 0)
    CE.Style:ApplyFontString(summary.totalValue, "value")
    summary.totalValue:SetText("0")
    summary.totalValue:SetTextColor(0.85, 0.82, 0.75) -- Pale gold

    -- Average with dark background
    local avgBg = summary:CreateTexture(nil, "ARTWORK")
    avgBg:SetSize(200, 32)
    avgBg:SetPoint("TOP", totalBg, "BOTTOM", 0, -10)
    avgBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    avgBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip

    summary.avgLabel = summary:CreateFontString(nil, "OVERLAY")
    summary.avgLabel:SetPoint("LEFT", avgBg, "LEFT", 15, 0)
    CE.Style:ApplyFontString(summary.avgLabel, "label")
    summary.avgLabel:SetText("Average:")
    summary.avgLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver

    summary.avgValue = summary:CreateFontString(nil, "OVERLAY")
    summary.avgValue:SetPoint("RIGHT", avgBg, "RIGHT", -15, 0)
    CE.Style:ApplyFontString(summary.avgValue, "value")
    summary.avgValue:SetText("0.0")
    summary.avgValue:SetTextColor(0.85, 0.82, 0.75) -- Pale gold

    self.summary = summary
end

function AttributesPanel:CreateActionBar()
    local actions = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    actions:SetSize(800, 70)
    actions:SetPoint("BOTTOM", 0, 10)
    
    CE.Style:ApplyBackdrop(actions, "wood")
    actions:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    actions:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Roll All button with flat style
    local rollAllBtn = self:CreateFlatButton(actions, "Roll All Stats", 140, 35)
    rollAllBtn:SetPoint("LEFT", 100, 0)
    rollAllBtn:SetScript("OnClick", function()
        self:RollAllAttributes()
    end)
    
    -- Decorative separator with burgundy accent
    local separator = actions:CreateTexture(nil, "ARTWORK")
    separator:SetSize(2, 40)
    separator:SetPoint("CENTER")
    separator:SetTexture("Interface\\Common\\UI-TooltipDivider")
    separator:SetVertexColor(0.4, 0.1, 0.15, 0.6) -- Burgundy
    
    -- Reset button with flat style
    local resetBtn = self:CreateFlatButton(actions, "Reset to Default", 140, 35)
    resetBtn:SetPoint("RIGHT", -100, 0)
    resetBtn:SetScript("OnClick", function()
        self:ResetAllAttributes()
    end)
end

-- Rest of methods remain the same but with updated color values
function AttributesPanel:UpdateAllAttributes()
    local total = 0
    
    for _, attrName in ipairs(CE.Constants.ATTRIBUTES) do
        local value = CE.Database:GetAttribute(attrName)
        total = total + value
        
        local frame = self.attributes[attrName]
        if frame then
            local modifierText = value >= 0 and string.format("+%d", value) or tostring(value)
            frame.valueText:SetText(modifierText)
            
            -- Update colors with dark theme
            if value <= -2 then
                frame.valueText:SetTextColor(0.8, 0.25, 0.3) -- Dark red
                frame.iconBorder:SetVertexColor(0.7, 0.2, 0.25)
            elseif value >= 3 then
                frame.valueText:SetTextColor(0.4, 0.85, 0.4) -- Bright green
                frame.iconBorder:SetVertexColor(0.3, 0.7, 0.3)
            else
                frame.valueText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold (normal)
                frame.iconBorder:SetVertexColor(0.5, 0.5, 0.55) -- Silver
            end
            
            frame.minusBtn:SetEnabled(value > CE.Constants.ATTRIBUTE_MIN)
            frame.plusBtn:SetEnabled(value < CE.Constants.ATTRIBUTE_MAX)
            
            -- Update button states visually based on enabled/disabled
            if value <= CE.Constants.ATTRIBUTE_MIN then
                frame.minusBtn.bg:SetVertexColor(0.05, 0.05, 0.06, 0.9)
                frame.minusBtn.text:SetTextColor(0.3, 0.3, 0.35)
                frame.minusBtn.border:SetBackdropBorderColor(0.2, 0.2, 0.25, 0.8)
                -- Disable hover effects
                frame.minusBtn:SetScript("OnEnter", nil)
                frame.minusBtn:SetScript("OnLeave", nil)
            else
                frame.minusBtn.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
                frame.minusBtn.text:SetTextColor(0.65, 0.65, 0.7)
                frame.minusBtn.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
                -- Re-enable hover effects
                frame.minusBtn:SetScript("OnEnter", function()
                    frame.minusBtn.bg:SetVertexColor(0.15, 0.04, 0.06, 0.9)
                    frame.minusBtn.border:SetBackdropBorderColor(0.5, 0.12, 0.18, 1)
                    frame.minusBtn.text:SetTextColor(0.85, 0.82, 0.75)
                end)
                frame.minusBtn:SetScript("OnLeave", function()
                    frame.minusBtn.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
                    frame.minusBtn.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
                    frame.minusBtn.text:SetTextColor(0.65, 0.65, 0.7)
                end)
            end
            
            if value >= CE.Constants.ATTRIBUTE_MAX then
                frame.plusBtn.bg:SetVertexColor(0.05, 0.05, 0.06, 0.9)
                frame.plusBtn.text:SetTextColor(0.3, 0.3, 0.35)
                frame.plusBtn.border:SetBackdropBorderColor(0.2, 0.2, 0.25, 0.8)
                -- Disable hover effects
                frame.plusBtn:SetScript("OnEnter", nil)
                frame.plusBtn:SetScript("OnLeave", nil)
            else
                frame.plusBtn.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
                frame.plusBtn.text:SetTextColor(0.65, 0.65, 0.7)
                frame.plusBtn.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
                -- Re-enable hover effects
                frame.plusBtn:SetScript("OnEnter", function()
                    frame.plusBtn.bg:SetVertexColor(0.15, 0.04, 0.06, 0.9)
                    frame.plusBtn.border:SetBackdropBorderColor(0.5, 0.12, 0.18, 1)
                    frame.plusBtn.text:SetTextColor(0.85, 0.82, 0.75)
                end)
                frame.plusBtn:SetScript("OnLeave", function()
                    frame.plusBtn.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
                    frame.plusBtn.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
                    frame.plusBtn.text:SetTextColor(0.65, 0.65, 0.7)
                end)
            end
        end
    end
    
    if self.summary then
        self.summary.totalValue:SetText(total)
        self.summary.avgValue:SetText(string.format("%.1f", total / 9))
        
        if total > 18 then
            self.summary.totalValue:SetTextColor(0.4, 0.85, 0.4) -- Bright green
        elseif total < 0 then
            self.summary.totalValue:SetTextColor(0.8, 0.25, 0.3) -- Dark red
        else
            self.summary.totalValue:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
        end
    end
end

-- UPDATED: ModifyAttribute now notifies DefensePanel specifically
function AttributesPanel:ModifyAttribute(name, delta)
    local current = CE.Database:GetAttribute(name)
    local new = current + delta
    
    if new >= CE.Constants.ATTRIBUTE_MIN and new <= CE.Constants.ATTRIBUTE_MAX then
        CE.Database:SetAttribute(name, new)
        self:UpdateAllAttributes()
        
        -- Notify Character Sheet Panel of the change
        if CE.UI.CharacterSheetPanel and CE.UI.CharacterSheetPanel.UpdateAllDisplays then
            CE.UI.CharacterSheetPanel:UpdateAllDisplays()
        end
        
        -- ADDED: Specifically update DefensePanel when Finesse changes
        if name == "Finesse" and CE.UI.DefensePanel and CE.UI.DefensePanel.UpdateDisplay then
            CE.UI.DefensePanel:UpdateDisplay()
        end
        
        -- Fire callback for any other listeners
        if CE.Communication then
            CE.Communication:TriggerCallback("ATTRIBUTE_CHANGED", name, new)
        end
    end
end

-- FIXED: Prevent duplicate rolls by checking if roll is already in progress
function AttributesPanel:RollAttribute(name)
    -- Prevent duplicate rolls
    if self.rollingAttribute == name then
        return
    end
    
    self.rollingAttribute = name
    
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
    
    -- Clear the rolling flag after a short delay
    C_Timer.After(0.1, function()
        self.rollingAttribute = nil
    end)
end

function AttributesPanel:RollAllAttributes()
    -- Prevent rapid-fire duplicate rolls
    if self.rollingAll then
        return
    end
    
    self.rollingAll = true
    
    for _, name in ipairs(CE.Constants.ATTRIBUTES) do
        self:RollAttribute(name)
    end
    
    -- Clear the rolling flag after a short delay
    C_Timer.After(1, function()
        self.rollingAll = nil
    end)
end

function AttributesPanel:ResetAllAttributes()
    for _, name in ipairs(CE.Constants.ATTRIBUTES) do
        CE.Database:SetAttribute(name, 0)
    end
    self:UpdateAllAttributes()
    
    -- Notify Character Sheet Panel of the change
    if CE.UI.CharacterSheetPanel and CE.UI.CharacterSheetPanel.UpdateAllDisplays then
        CE.UI.CharacterSheetPanel:UpdateAllDisplays()
    end
    
    -- ADDED: Update DefensePanel when all attributes are reset (includes Finesse)
    if CE.UI.DefensePanel and CE.UI.DefensePanel.UpdateDisplay then
        CE.UI.DefensePanel:UpdateDisplay()
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r All attributes reset to 0")
end