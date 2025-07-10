local _, CE = ...

local DicePanel = {}
CE.UI = CE.UI or {}
CE.UI.DicePanel = DicePanel

function DicePanel:Initialize(parent)
    if not parent then return end
    
    self.parent = parent
    
    -- Panel title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("DICE ROLLER")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Create sections
    self:CreateDiceButtons()
    self:CreateCustomRollSection()
    self:CreateModifierSection()
    self:CreateHistorySection()
end

function DicePanel:CreateDiceButtons()
    -- Container for dice buttons
    local container = CreateFrame("Frame", nil, self.parent)
    container:SetSize(400, 200)
    container:SetPoint("TOPLEFT", 20, -50)
    
    -- Title
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOP", 0, 0)
    sectionTitle:SetText("Quick Dice")
    sectionTitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Create dice buttons in a grid
    local buttonSize = 60  -- Smaller buttons
    local spacing = 15
    local buttonsPerRow = 4
    
    for i, diceType in ipairs(CE.Constants.DICE_TYPES) do
        local row = math.floor((i-1) / buttonsPerRow)
        local col = (i-1) % buttonsPerRow
        
        local btn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        btn:SetSize(buttonSize, buttonSize)
        btn:SetPoint("TOPLEFT", col * (buttonSize + spacing), -30 - (row * (buttonSize + spacing)))
        
        -- Set larger font for dice text
        local fontString = btn:GetFontString()
        local font, _, flags = fontString:GetFont()
        fontString:SetFont(font, 14, flags)
        btn:SetText(diceType.name)
        
        -- No icon - just the button
        
        btn:SetScript("OnClick", function()
            self:RollDice(diceType.sides, 1)
        end)
    end
end

function DicePanel:CreateCustomRollSection()
    -- Custom roll container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 80)
    container:SetPoint("TOPLEFT", 20, -280)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Title
    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Custom Roll")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Input background
    local inputBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
    inputBg:SetSize(150, 30)
    inputBg:SetPoint("TOPLEFT", 15, -35)
    inputBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBorder",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    inputBg:SetBackdropColor(0, 0, 0, 0.5)
    inputBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Input box
    self.customInput = CreateFrame("EditBox", nil, inputBg)
    self.customInput:SetPoint("TOPLEFT", 5, -2)
    self.customInput:SetPoint("BOTTOMRIGHT", -5, 2)
    self.customInput:SetFontObject("GameFontWhite")
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
    
    -- Roll button
    local rollBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    rollBtn:SetSize(80, 30)
    rollBtn:SetPoint("LEFT", inputBg, "RIGHT", 10, 0)
    rollBtn:SetText("Roll")
    rollBtn:SetScript("OnClick", function()
        self:RollCustom()
    end)
    
    -- Example text
    local example = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    example:SetPoint("LEFT", rollBtn, "RIGHT", 10, 0)
    example:SetText("(e.g. 2d6+3, 1d20-2)")
    example:SetTextColor(0.5, 0.5, 0.5)
end

function DicePanel:CreateModifierSection()
    -- Modifier container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 100)
    container:SetPoint("TOPLEFT", 20, -370)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Title
    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Quick Modifiers")
    title:SetTextColor(0.9, 0.75, 0.3)
    
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
        local btn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        btn:SetSize(40, 25)
        btn:SetPoint("TOPLEFT", xOffset, yOffset)
        btn:SetText(mod.text)
        
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
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00BFFF[CE]|r Next roll will have %+d modifier", mod.value))
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
    -- History container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(420, 420)
    container:SetPoint("TOPRIGHT", -20, -50)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Title
    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Roll History")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(370, 1)
    scrollFrame:SetScrollChild(content)
    
    self.historyContent = content
    self.historyEntries = {}
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
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFF[CE]|r Invalid dice format. Use format like: 2d6+3")
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
    
    -- Background
    local bg = entry:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
    
    -- Time
    local timeText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeText:SetPoint("LEFT", 5, 0)
    timeText:SetText(date("%H:%M:%S"))
    timeText:SetTextColor(0.5, 0.5, 0.5)
    
    -- Notation
    local notationText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    notationText:SetPoint("LEFT", 70, 0)
    notationText:SetText(notation)
    
    -- Result
    local resultText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    resultText:SetPoint("RIGHT", -10, 0)
    resultText:SetText("= " .. total)
    
    -- Color based on roll quality
    if #rolls == 1 and rolls[1] == 20 then
        resultText:SetTextColor(0.2, 1, 0.2)  -- Crit
    elseif #rolls == 1 and rolls[1] == 1 then
        resultText:SetTextColor(1, 0.2, 0.2)  -- Crit fail
    else
        resultText:SetTextColor(0.9, 0.75, 0.3)  -- Normal
    end
    
    -- Rolls detail
    if #rolls > 0 then
        local rollsText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rollsText:SetPoint("LEFT", notationText, "RIGHT", 10, 0)
        rollsText:SetText("(" .. table.concat(rolls, ", ") .. ")")
        rollsText:SetTextColor(0.6, 0.6, 0.6)
    end
    
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