local _, CE = ...

local DicePanel = {}
CE.UI = CE.UI or {}
CE.UI.DicePanel = DicePanel

function DicePanel:Initialize(parent)
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
    title:SetText("DICE ROLLER")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)
    
    -- Decorative divider with dark silver
    local divider = CE.Style:CreateDivider(parent, 300)
    divider:SetPoint("TOP", title, "BOTTOM", 0, -5)
    divider:SetVertexColor(0.35, 0.35, 0.4, 0.6) -- Dark silver
    
    -- Create sections
    self:CreateDiceButtons()
    self:CreateCustomRollSection()
    self:CreateModifierSection()
    self:CreateHistorySection()
end

function DicePanel:CreateDiceButtons()
    -- Dark stone container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(400, 200)
    container:SetPoint("TOPLEFT", 20, -70)
    
    CE.Style:ApplyBackdrop(container, "simple")
    container:SetBackdropColor(0.03, 0.03, 0.04, 0.95) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver border
    
    -- Section title
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOP", 0, -10)
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
    sectionTitle:SetText("Quick Dice")
    sectionTitle:SetTextColor(0.7, 0.7, 0.75) -- Pale silver
    
    -- Create dice buttons in a grid
    local buttonSize = 60
    local spacing = 15
    local buttonsPerRow = 4
    
    for i, diceType in ipairs(CE.Constants.DICE_TYPES) do
        local row = math.floor((i-1) / buttonsPerRow)
        local col = (i-1) % buttonsPerRow
        
        local btn = self:CreateFlatButton(container, diceType.name, buttonSize, buttonSize)
        btn:SetPoint("TOPLEFT", col * (buttonSize + spacing) + 20, -40 - (row * (buttonSize + spacing)))
        
        btn:SetScript("OnClick", function()
            self:RollDice(diceType.sides, 1)
        end)
    end
end

function DicePanel:CreateCustomRollSection()
    -- Custom roll container with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 80)
    container:SetPoint("TOPLEFT", 20, -280)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Title with burgundy accent
    local titleBg = container:CreateTexture(nil, "ARTWORK")
    titleBg:SetHeight(25)
    titleBg:SetPoint("TOPLEFT", 4, -4)
    titleBg:SetPoint("TOPRIGHT", -4, -4)
    titleBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    titleBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip
    
    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleBg, "LEFT", 10, 0)
    title:SetFont("Fonts\\FRIZQT__.ttf", 13, "")
    title:SetText("Custom Roll")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Input background with dark theme
    local inputBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
    inputBg:SetSize(150, 30)
    inputBg:SetPoint("TOPLEFT", 15, -35)
    inputBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    inputBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9) -- Nearly black
    inputBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8) -- Dark silver
    
    -- Input box with pale text
    self.customInput = CreateFrame("EditBox", nil, inputBg)
    self.customInput:SetPoint("TOPLEFT", 5, -2)
    self.customInput:SetPoint("BOTTOMRIGHT", -5, 2)
    self.customInput:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    self.customInput:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    self.customInput:SetAutoFocus(false)
    self.customInput:SetMaxLetters(20)
    self.customInput:SetText("2d6+3")
    
    self.customInput:SetScript("OnEscapePressed", function(editBox) 
        editBox:ClearFocus() 
    end)
    
    self.customInput:SetScript("OnEnterPressed", function(editBox)
        self:RollCustom()
        editBox:ClearFocus()
    end)
    
    -- Roll button with flat style
    local rollBtn = self:CreateFlatButton(container, "Roll", 80, 30)
    rollBtn:SetPoint("LEFT", inputBg, "RIGHT", 10, 0)
    rollBtn:SetScript("OnClick", function()
        self:RollCustom()
    end)
    
    -- Example text with muted color
    local example = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    example:SetPoint("LEFT", rollBtn, "RIGHT", 10, 0)
    example:SetText("(e.g. 2d6+3, 1d20-2)")
    example:SetTextColor(0.5, 0.5, 0.55) -- Dark silver
end

function DicePanel:CreateModifierSection()
    -- Modifier container with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 100)
    container:SetPoint("TOPLEFT", 20, -370)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Title with burgundy accent
    local titleBg = container:CreateTexture(nil, "ARTWORK")
    titleBg:SetHeight(25)
    titleBg:SetPoint("TOPLEFT", 4, -4)
    titleBg:SetPoint("TOPRIGHT", -4, -4)
    titleBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    titleBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip
    
    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleBg, "LEFT", 10, 0)
    title:SetFont("Fonts\\FRIZQT__.ttf", 13, "")
    title:SetText("Quick Modifiers")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Modifier buttons
    local modifiers = {
        {text = "+1", value = 1},
        {text = "+2", value = 2},
        {text = "+3", value = 3},
        {text = "+5", value = 5},
        {text = "-1", value = -1},
        {text = "-2", value = -2},
        {text = "Adv", special = "advantage"},
        {text = "Dis", special = "disadvantage"}
    }
    
    local xOffset = 15
    local yOffset = -35
    
    for i, mod in ipairs(modifiers) do
        local btn = self:CreateFlatButton(container, mod.text, 40, 25)
        btn:SetPoint("TOPLEFT", xOffset, yOffset)
        
        if mod.special == "advantage" then
            btn:SetScript("OnClick", function()
                self:RollWithAdvantage()
            end)
        elseif mod.special == "disadvantage" then
            btn:SetScript("OnClick", function()
                self:RollWithDisadvantage()
            end)
        else
            btn:SetScript("OnClick", function()
                self.nextModifier = mod.value
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF8B6914[CE]|r Next roll will have %+d modifier", mod.value))
            end)
        end
        
        xOffset = xOffset + 45
        if i == 4 then
            xOffset = 15
            yOffset = -65
        end
    end
end

function DicePanel:CreateHistorySection()
    -- History container with dark stone theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(420, 420)
    container:SetPoint("TOPRIGHT", -20, -70)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.03, 0.03, 0.04, 0.95) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Header with burgundy accent
    local headerBg = container:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(35)
    headerBg:SetPoint("TOPLEFT", 4, -4)
    headerBg:SetPoint("TOPRIGHT", -4, -4)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local headerAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    headerAccent:SetHeight(2)
    headerAccent:SetPoint("BOTTOMLEFT", headerBg, 0, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", headerBg, 0, 0)
    headerAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    -- Title
    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER", headerBg, "CENTER", 0, 0)
    title:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
    title:SetText("Roll History")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Scroll frame with dark styling - give it a name
    local scrollFrame = CreateFrame("ScrollFrame", "CE_DiceHistoryScrollFrame", container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -45)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    -- Style scroll bar - now we can safely access it
    local scrollBar = scrollFrame.ScrollBar or _G["CE_DiceHistoryScrollFrameScrollBar"]
    if scrollBar then
        local thumb = scrollBar:GetThumbTexture()
        if thumb then
            thumb:SetVertexColor(0.3, 0.3, 0.35)
        end
        
        -- Style up/down buttons if they exist
        local upButton = scrollBar.ScrollUpButton or _G["CE_DiceHistoryScrollFrameScrollBarScrollUpButton"]
        if upButton then
            local normalTexture = upButton:GetNormalTexture()
            if normalTexture then
                normalTexture:SetVertexColor(0.3, 0.3, 0.35)
            end
        end
        
        local downButton = scrollBar.ScrollDownButton or _G["CE_DiceHistoryScrollFrameScrollBarScrollDownButton"]
        if downButton then
            local normalTexture = downButton:GetNormalTexture()
            if normalTexture then
                normalTexture:SetVertexColor(0.3, 0.3, 0.35)
            end
        end
    end
    
    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(370, 1)
    scrollFrame:SetScrollChild(content)
    
    self.historyContent = content
    self.historyEntries = {}
end

function DicePanel:CreateFlatButton(parent, text, width, height)
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
    btn.text:SetFont("Fonts\\FRIZQT__.ttf", height > 30 and 14 or 12, "OUTLINE")
    btn.text:SetText(text)
    btn.text:SetTextColor(0.65, 0.65, 0.7) -- Silver
    
    -- Hover effect
    btn:SetScript("OnEnter", function()
        btn.bg:SetVertexColor(0.15, 0.04, 0.06, 0.9) -- Dark burgundy
        btn.border:SetBackdropBorderColor(0.5, 0.12, 0.18, 1) -- Burgundy
        btn.text:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    end)
    
    btn:SetScript("OnLeave", function()
        btn.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Back to dark grey-blue
        btn.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8) -- Back to dark silver
        btn.text:SetTextColor(0.65, 0.65, 0.7) -- Back to silver
    end)
    
    btn:SetScript("OnMouseDown", function()
        btn.text:SetPoint("CENTER", 1, -1)
    end)
    
    btn:SetScript("OnMouseUp", function()
        btn.text:SetPoint("CENTER", 0, 0)
    end)
    
    return btn
end

function DicePanel:RollDice(sides, count, modifier)
    modifier = modifier or self.nextModifier or 0
    self.nextModifier = nil  -- Clear modifier after use
    
    local result = CE.Utils:RollDice(sides, count)
    
    local notation = string.format("%dd%d", count, sides)
    if modifier ~= 0 then
        notation = notation .. (modifier > 0 and "+" or "") .. modifier
    end
    
    CE.Communication:SendRoll({
        type = "dice",
        detail = notation,
        rolls = result.rolls,
        total = result.total + modifier,
        modifier = modifier
    })
    
    self:AddToHistory(notation, result.total + modifier, result.rolls)
end

function DicePanel:RollCustom()
    local input = self.customInput:GetText()
    local parsed = CE.Utils:ParseDiceString(input)
    
    if parsed then
        self:RollDice(parsed.sides, parsed.count, parsed.modifier)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r Invalid dice format. Use format like: 2d6+3")
    end
end

function DicePanel:RollWithAdvantage()
    local r1 = CE.Utils:RollDice(20, 1)
    local r2 = CE.Utils:RollDice(20, 1)
    local higher = math.max(r1.total, r2.total)
    
    CE.Communication:SendRoll({
        type = "dice",
        detail = "1d20 (Advantage)",
        rolls = {r1.total, r2.total},
        total = higher,
        modifier = 0
    })
    
    self:AddToHistory("1d20 (Adv)", higher, {r1.total, r2.total})
end

function DicePanel:RollWithDisadvantage()
    local r1 = CE.Utils:RollDice(20, 1)
    local r2 = CE.Utils:RollDice(20, 1)
    local lower = math.min(r1.total, r2.total)
    
    CE.Communication:SendRoll({
        type = "dice",
        detail = "1d20 (Disadvantage)",
        rolls = {r1.total, r2.total},
        total = lower,
        modifier = 0
    })
    
    self:AddToHistory("1d20 (Dis)", lower, {r1.total, r2.total})
end

function DicePanel:AddToHistory(notation, total, rolls)
    -- Create history entry
    local entry = CreateFrame("Frame", nil, self.historyContent)
    entry:SetSize(360, 30)
    entry:SetPoint("TOP", 0, -((#self.historyEntries) * 35))
    
    -- Background with alternating shades
    local bg = entry:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if #self.historyEntries % 2 == 0 then
        bg:SetColorTexture(0.06, 0.06, 0.08, 0.5) -- Slightly lighter
    else
        bg:SetColorTexture(0.04, 0.04, 0.05, 0.5) -- Darker
    end
    
    -- Time with muted color
    local timeText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeText:SetPoint("LEFT", 5, 0)
    timeText:SetText(date("%H:%M:%S"))
    timeText:SetTextColor(0.4, 0.4, 0.45) -- Dark silver
    
    -- Notation with silver
    local notationText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    notationText:SetPoint("LEFT", 70, 0)
    notationText:SetText(notation)
    notationText:SetTextColor(0.65, 0.65, 0.7) -- Silver
    
    -- Result with appropriate coloring
    local resultText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    resultText:SetPoint("RIGHT", -10, 0)
    resultText:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
    resultText:SetText("= " .. total)
    
    -- Color based on roll quality
    if #rolls == 1 and rolls[1] == 20 then
        resultText:SetTextColor(0.4, 0.85, 0.4) -- Bright green for crit
    elseif #rolls == 1 and rolls[1] == 1 then
        resultText:SetTextColor(0.8, 0.25, 0.3) -- Dark red for crit fail
    else
        resultText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold for normal
    end
    
    -- Rolls detail with dark silver
    if #rolls > 0 then
        local rollsText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rollsText:SetPoint("LEFT", notationText, "RIGHT", 10, 0)
        rollsText:SetText("(" .. table.concat(rolls, ", ") .. ")")
        rollsText:SetTextColor(0.5, 0.5, 0.55) -- Muted silver
    end
    
    -- Hover effect for entry
    entry:SetScript("OnEnter", function()
        bg:SetColorTexture(0.4, 0.1, 0.15, 0.2) -- Burgundy highlight
    end)
    
    entry:SetScript("OnLeave", function()
        if #self.historyEntries % 2 == 0 then
            bg:SetColorTexture(0.06, 0.06, 0.08, 0.5)
        else
            bg:SetColorTexture(0.04, 0.04, 0.05, 0.5)
        end
    end)
    
    table.insert(self.historyEntries, entry)
    
    -- Update content height
    self.historyContent:SetHeight(math.max(1, #self.historyEntries * 35))
    
    -- Limit history to 20 entries
    if #self.historyEntries > 20 then
        self.historyEntries[1]:Hide()
        table.remove(self.historyEntries, 1)
        
        -- Reposition remaining entries
        for i, e in ipairs(self.historyEntries) do
            e:SetPoint("TOP", 0, -((i-1) * 35))
        end
    end
end