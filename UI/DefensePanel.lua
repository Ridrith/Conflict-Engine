local _, CE = ...

local DefensePanel = {}
CE.UI = CE.UI or {}
CE.UI.DefensePanel = DefensePanel

function DefensePanel:Initialize(parent)
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
    title:SetText("DEFENSE & DAMAGE REDUCTION")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)
    
    -- Decorative divider with dark silver
    local divider = CE.Style:CreateDivider(parent, 300)
    divider:SetPoint("TOP", title, "BOTTOM", 0, -5)
    divider:SetVertexColor(0.35, 0.35, 0.4, 0.6) -- Dark silver
    
    -- Create sections with better positioning
    self:CreateCurrentStatsSection()
    self:CreateArmorSection()
    self:CreateRollSection()
    self:CreateInfoSection()
end

function DefensePanel:CreateFlatButton(parent, text, width, height)
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
    btn.text:SetFont("Fonts\\FRIZQT__.ttf", 12, "OUTLINE")
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

function DefensePanel:CreateCurrentStatsSection()
    -- Stats display with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(280, 100)
    container:SetPoint("TOPLEFT", 20, -70)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Header with burgundy accent
    local headerBg = container:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(30)
    headerBg:SetPoint("TOPLEFT", 4, -4)
    headerBg:SetPoint("TOPRIGHT", -4, -4)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local headerAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    headerAccent:SetHeight(2)
    headerAccent:SetPoint("BOTTOMLEFT", headerBg, 0, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", headerBg, 0, 0)
    headerAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local headerText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerText:SetPoint("CENTER", headerBg, 0, 0)
    headerText:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
    headerText:SetText("Current Stats")
    headerText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Defense value - shows calculated score
    self.defenseText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.defenseText:SetPoint("TOP", 0, -45)
    self.defenseText:SetFont("Fonts\\FRIZQT__.ttf", 16, "OUTLINE")
    self.defenseText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- DR value with appropriate coloring
    self.drText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.drText:SetPoint("TOP", 0, -65)
    self.drText:SetFont("Fonts\\FRIZQT__.ttf", 16, "OUTLINE")
    self.drText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    self.statsContainer = container
end

function DefensePanel:CreateArmorSection()
    -- Armor configuration with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(280, 240)
    container:SetPoint("TOPLEFT", 20, -180)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Title with burgundy accent
    local titleBg = container:CreateTexture(nil, "ARTWORK")
    titleBg:SetHeight(30)
    titleBg:SetPoint("TOPLEFT", 4, -4)
    titleBg:SetPoint("TOPRIGHT", -4, -4)
    titleBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    titleBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local titleAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    titleAccent:SetHeight(2)
    titleAccent:SetPoint("BOTTOMLEFT", titleBg, 0, 0)
    titleAccent:SetPoint("BOTTOMRIGHT", titleBg, 0, 0)
    titleAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER", titleBg, 0, 0)
    title:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
    title:SetText("Equipment Configuration")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Armor type dropdown with dark styling
    local armorLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    armorLabel:SetPoint("TOPLEFT", 20, -45)
    armorLabel:SetText("Armor Type:")
    armorLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    local armorDropdown = CreateFrame("Frame", "CE_DefenseArmorDropdown", container, "UIDropDownMenuTemplate")
    armorDropdown:SetPoint("LEFT", armorLabel, "RIGHT", 10, -2)
    UIDropDownMenu_SetWidth(armorDropdown, 100)
    
    -- Style dropdown
    local dropdownBg = _G["CE_DefenseArmorDropdownMiddle"]
    if dropdownBg then
        dropdownBg:SetVertexColor(0.3, 0.3, 0.35)
    end
    local dropdownText = _G["CE_DefenseArmorDropdownText"]
    if dropdownText then
        dropdownText:SetTextColor(0.85, 0.82, 0.75)
    end
    
    UIDropDownMenu_Initialize(armorDropdown, function(frame, level)
        local info = UIDropDownMenu_CreateInfo()
        -- Updated armor types for new system
        local armorTypes = {"NONE", "LIGHT", "MEDIUM", "HEAVY"}
        for _, armorType in ipairs(armorTypes) do
            info.text = armorType
            info.value = armorType
            info.func = function()
                CE.Database:SetDefense("armorType", armorType)
                UIDropDownMenu_SetSelectedValue(armorDropdown, armorType)
                self:UpdateDisplay()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    UIDropDownMenu_SetSelectedValue(armorDropdown, CE.Database:GetDefense().armorType)
    
    -- Shield checkbox with custom styling
    local shieldCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    shieldCheck:SetPoint("TOPLEFT", 20, -80)
    shieldCheck:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.35)
    shieldCheck:GetHighlightTexture():SetVertexColor(0.5, 0.12, 0.18, 0.3)
    shieldCheck.text = shieldCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    shieldCheck.text:SetPoint("LEFT", shieldCheck, "RIGHT", 5, 0)
    shieldCheck.text:SetText("Using Shield (+1 DR)")
    shieldCheck.text:SetTextColor(0.65, 0.65, 0.7) -- Silver
    shieldCheck:SetChecked(CE.Database:GetDefense().hasShield)
    shieldCheck:SetScript("OnClick", function(btn)
        CE.Database:SetDefense("hasShield", btn:GetChecked())
        self:UpdateDisplay()
    end)
    
    -- Helm checkbox with custom styling
    local helmCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    helmCheck:SetPoint("TOPLEFT", 20, -110)
    helmCheck:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.35)
    helmCheck:GetHighlightTexture():SetVertexColor(0.5, 0.12, 0.18, 0.3)
    helmCheck.text = helmCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    helmCheck.text:SetPoint("LEFT", helmCheck, "RIGHT", 5, 0)
    helmCheck.text:SetText("Wearing Helm (+1 Defense)")
    helmCheck.text:SetTextColor(0.65, 0.65, 0.7) -- Silver
    helmCheck:SetChecked(CE.Database:GetDefense().hasHelm)
    helmCheck:SetScript("OnClick", function(btn)
        CE.Database:SetDefense("hasHelm", btn:GetChecked())
        self:UpdateDisplay()
    end)
    
    -- Custom modifiers section
    local customBg = container:CreateTexture(nil, "ARTWORK")
    customBg:SetHeight(60)
    customBg:SetPoint("TOPLEFT", 10, -140)
    customBg:SetPoint("TOPRIGHT", -10, -140)
    customBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    customBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip
    
    local customLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    customLabel:SetPoint("TOPLEFT", 20, -145)
    customLabel:SetText("Custom Modifiers:")
    customLabel:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Defense modifier with dark input
    local defModLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    defModLabel:SetPoint("TOPLEFT", 40, -170)
    defModLabel:SetText("Defense:")
    defModLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    -- Create dark styled edit box
    local defModBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
    defModBg:SetSize(40, 20)
    defModBg:SetPoint("LEFT", defModLabel, "RIGHT", 10, 0)
    defModBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    defModBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    defModBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    self.defModInput = CreateFrame("EditBox", nil, defModBg)
    self.defModInput:SetPoint("TOPLEFT", 3, -1)
    self.defModInput:SetPoint("BOTTOMRIGHT", -3, 1)
    self.defModInput:SetFont("Fonts\\FRIZQT__.ttf", 11, "")
    self.defModInput:SetTextColor(0.85, 0.82, 0.75)
    self.defModInput:SetAutoFocus(false)
    self.defModInput:SetNumeric(true)
    self.defModInput:SetMaxLetters(3)
    self.defModInput:SetText(CE.Database:GetDefense().customDefense or 0)
    self.defModInput:SetScript("OnTextChanged", function(editBox)
        local value = tonumber(editBox:GetText()) or 0
        CE.Database:SetDefense("customDefense", value)
        self:UpdateDisplay()
    end)
    
    -- DR modifier with dark input
    local drModLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    drModLabel:SetPoint("LEFT", defModBg, "RIGHT", 20, 0)
    drModLabel:SetText("DR:")
    drModLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    local drModBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
    drModBg:SetSize(40, 20)
    drModBg:SetPoint("LEFT", drModLabel, "RIGHT", 10, 0)
    drModBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    drModBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    drModBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    self.drModInput = CreateFrame("EditBox", nil, drModBg)
    self.drModInput:SetPoint("TOPLEFT", 3, -1)
    self.drModInput:SetPoint("BOTTOMRIGHT", -3, 1)
    self.drModInput:SetFont("Fonts\\FRIZQT__.ttf", 11, "")
    self.drModInput:SetTextColor(0.85, 0.82, 0.75)
    self.drModInput:SetAutoFocus(false)
    self.drModInput:SetNumeric(true)
    self.drModInput:SetMaxLetters(3)
    self.drModInput:SetText(CE.Database:GetDefense().customDR or 0)
    self.drModInput:SetScript("OnTextChanged", function(editBox)
        local value = tonumber(editBox:GetText()) or 0
        CE.Database:SetDefense("customDR", value)
        self:UpdateDisplay()
    end)
end

function DefensePanel:CreateRollSection()
    -- Roll buttons container
    local container = CreateFrame("Frame", nil, self.parent)
    container:SetSize(280, 50)
    container:SetPoint("TOPLEFT", 20, -430)
    
    -- Roll Defense button with flat style
    local rollDefBtn = self:CreateFlatButton(container, "Roll Defense", 130, 35)
    rollDefBtn:SetPoint("LEFT", 0, 0)
    rollDefBtn:SetScript("OnClick", function()
        self:RollDefense()
    end)
    
    -- Roll DR button with flat style
    local rollDRBtn = self:CreateFlatButton(container, "Roll DR", 130, 35)
    rollDRBtn:SetPoint("RIGHT", 0, 0)
    rollDRBtn:SetScript("OnClick", function()
        self:RollDR()
    end)
end

function DefensePanel:CreateInfoSection()
    -- Info panel with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(480, 420)
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
    title:SetPoint("CENTER", headerBg, 0, 0)
    title:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
    title:SetText("Defense & Damage Reduction Reference")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Create armor type cards with corrected system
    local armorTypes = {
        {name = "Light Armor", defense = "+4 Defense", dr = "1/6 chance", color = {0.4, 0.85, 0.4}},
        {name = "Medium Armor", defense = "+2 Defense", dr = "2/6 chance", color = {0.85, 0.82, 0.75}},
        {name = "Heavy Armor", defense = "-2 Defense", dr = "3/6 chance", color = {0.8, 0.25, 0.3}}
    }
    
    local yOffset = -50
    for _, armor in ipairs(armorTypes) do
        local card = CreateFrame("Frame", nil, container, "BackdropTemplate")
        card:SetSize(440, 80)
        card:SetPoint("TOP", 0, yOffset)
        card:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        card:SetBackdropColor(0.08, 0.08, 0.1, 0.5)
        card:SetBackdropBorderColor(0.2, 0.2, 0.25, 0.8)
        
        -- Armor name
        local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("TOPLEFT", 15, -10)
        nameText:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
        nameText:SetText(armor.name)
        nameText:SetTextColor(armor.color[1], armor.color[2], armor.color[3])
        
        -- Stats - updated for correct system
        local statsText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statsText:SetPoint("TOPLEFT", 15, -30)
        statsText:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
        statsText:SetText(string.format("Defense: %s  |  DR Success: %s", armor.defense, armor.dr))
        statsText:SetTextColor(0.65, 0.65, 0.7) -- Silver
        
        -- Additional explanation
        local explainText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        explainText:SetPoint("TOPLEFT", 15, -50)
        explainText:SetFont("Fonts\\FRIZQT__.ttf", 10, "")
        explainText:SetText("Defense = Finesse + 5 + Armor Bonus | DR ignores 1 strike")
        explainText:SetTextColor(0.5, 0.5, 0.55) -- Darker silver
        
        yOffset = yOffset - 90
    end
    
    -- Equipment bonuses section
    local bonusBg = container:CreateTexture(nil, "ARTWORK")
    bonusBg:SetHeight(100)
    bonusBg:SetPoint("BOTTOMLEFT", 20, 20)
    bonusBg:SetPoint("BOTTOMRIGHT", -20, 20)
    bonusBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    bonusBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip
    
    local bonusTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bonusTitle:SetPoint("TOP", bonusBg, "TOP", 0, -10)
    bonusTitle:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
    bonusTitle:SetText("Equipment Bonuses")
    bonusTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    local bonusText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bonusText:SetPoint("TOP", bonusTitle, "BOTTOM", 0, -10)
    bonusText:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    bonusText:SetText("Shield: +1 DR Chance\nHelm: +1 Defense")
    bonusText:SetTextColor(0.6, 0.6, 0.65) -- Silver
    bonusText:SetSpacing(5)
    
    self:UpdateDisplay()
end

-- Helper function to get armor bonus
function DefensePanel:GetArmorBonus(armorType)
    local bonuses = {
        NONE = 0,
        LIGHT = 4,
        MEDIUM = 2,
        HEAVY = -2
    }
    return bonuses[armorType] or 0
end

-- Helper function to get DR chance based on armor type
function DefensePanel:GetDRChance(armorType)
    local drValues = {
        NONE = 0,
        LIGHT = 1,
        MEDIUM = 2,
        HEAVY = 3
    }
    return drValues[armorType] or 0
end

function DefensePanel:UpdateDisplay()
    local defense = CE.Database:GetDefense()
    local finesse = CE.Database:GetAttribute("Finesse") or 0
    local armorBonus = self:GetArmorBonus(defense.armorType)
    local customDefense = defense.customDefense or 0
    local helmBonus = defense.hasHelm and 1 or 0
    
    -- Calculate total defense score: Finesse + 5 + Armor + modifiers
    local totalDefense = finesse + 5 + armorBonus + customDefense + helmBonus
    
    self.defenseText:SetText(string.format("Defense Score: %d", totalDefense))
    self.defenseText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- DR display shows chance based on armor type
    local drChance = self:GetDRChance(defense.armorType)
    local customDR = defense.customDR or 0
    
    if defense.hasShield then
        drChance = drChance + 1
    end
    drChance = drChance + customDR
    
    local drString = "Damage Reduction: "
    if drChance > 0 then
        drString = drString .. string.format("%d/6 chance", math.min(drChance, 6))
    else
        drString = drString .. "None"
    end
    
    self.drText:SetText(drString)
end

function DefensePanel:RollDefense()
    local defense = CE.Database:GetDefense()
    local finesse = CE.Database:GetAttribute("Finesse") or 0
    local armorBonus = self:GetArmorBonus(defense.armorType)
    local customDefense = defense.customDefense or 0
    local helmBonus = defense.hasHelm and 1 or 0
    
    -- Calculate total defense score: Finesse + 5 + Armor + modifiers
    local totalDefense = finesse + 5 + armorBonus + customDefense + helmBonus
    
    -- Show the calculated defense score (no dice rolling)
    CE.Communication:SendRoll({
        type = "defense",
        detail = string.format("Defense Score (Finesse%+d + 5 + Armor%+d%s%s)", 
            finesse, 
            armorBonus, 
            customDefense ~= 0 and string.format("%+d", customDefense) or "",
            helmBonus > 0 and "+1" or ""
        ),
        rolls = {}, -- No dice rolled for defense
        total = totalDefense,
        modifier = 0
    })
end

function DefensePanel:RollDR()
    local defense = CE.Database:GetDefense()
    local drChance = self:GetDRChance(defense.armorType)
    local customDR = defense.customDR or 0
    
    -- Add shield bonus
    if defense.hasShield then
        drChance = drChance + 1
    end
    
    -- Add custom DR
    drChance = drChance + customDR
    
    if drChance <= 0 then
        CE.Communication:SendRoll({
            type = "dr",
            detail = "No Damage Reduction Available",
            rolls = {},
            total = 0,
            modifier = 0
        })
        return
    end
    
    -- Roll 1d6 and check if it's <= DR chance
    local result = CE.Utils:RollDice(6, 1)
    local roll = result.total
    local success = roll <= drChance
    local damageReduced = success and 1 or 0
    
    local drParts = {}
    if defense.armorType and defense.armorType ~= "NONE" then
        table.insert(drParts, defense.armorType .. "(" .. self:GetDRChance(defense.armorType) .. "/6)")
    end
    if defense.hasShield then
        table.insert(drParts, "Shield(+1)")
    end
    if customDR > 0 then
        table.insert(drParts, "Custom(+" .. customDR .. ")")
    end
    
    local detailString = table.concat(drParts, "+") .. string.format(" - Need %d or less", drChance)
    
    CE.Communication:SendRoll({
        type = "dr",
        detail = detailString,
        rolls = result.rolls,
        total = damageReduced,
        modifier = 0
    })
    
    -- Additional message about success/failure
    local successMsg = success and 
        string.format("|cFF00FF00SUCCESS!|r Damage reduced by 1 strike (rolled %d, needed %d or less)", roll, drChance) or
        string.format("|cFFFF0000FAILED!|r No damage reduction (rolled %d, needed %d or less)", roll, drChance)
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r " .. successMsg)
end