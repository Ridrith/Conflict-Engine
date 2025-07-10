local _, CE = ...

local DefensePanel = {}
CE.UI = CE.UI or {}
CE.UI.DefensePanel = DefensePanel

function DefensePanel:Initialize(parent)
    if not parent then return end
    
    self.parent = parent
    
    -- Panel title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("DEFENSE & DAMAGE REDUCTION")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Create sections with better positioning
    self:CreateCurrentStatsSection()
    self:CreateArmorSection()
    self:CreateRollSection()
    self:CreateInfoSection()
end

function DefensePanel:CreateCurrentStatsSection()
    -- Stats display - moved to top left
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(280, 100)
    container:SetPoint("TOPLEFT", 20, -50)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    container:SetBackdropBorderColor(0.6, 0.5, 0.2, 0.8)
    
    -- Defense value
    self.defenseText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.defenseText:SetPoint("TOP", 0, -20)
    self.defenseText:SetTextColor(0.2, 0.8, 0.2)
    
    -- DR value
    self.drText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.drText:SetPoint("TOP", 0, -50)
    self.drText:SetTextColor(0.8, 0.2, 0.2)
    
    self.statsContainer = container
end

function DefensePanel:CreateArmorSection()
    -- Armor configuration - below stats on left
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(280, 200)
    container:SetPoint("TOPLEFT", 20, -160)
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
    title:SetText("Equipment Configuration")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Armor type dropdown
    local armorLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    armorLabel:SetPoint("TOPLEFT", 20, -35)
    armorLabel:SetText("Armor Type:")
    
    local armorDropdown = CreateFrame("Frame", "CE_DefenseArmorDropdown", container, "UIDropDownMenuTemplate")
    armorDropdown:SetPoint("LEFT", armorLabel, "RIGHT", 10, -2)
    UIDropDownMenu_SetWidth(armorDropdown, 100)
    
    UIDropDownMenu_Initialize(armorDropdown, function(frame, level)
        local info = UIDropDownMenu_CreateInfo()
        for armorType, data in pairs(CE.Constants.ARMOR_TYPES) do
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
    
    -- Shield checkbox
    local shieldCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    shieldCheck:SetPoint("TOPLEFT", 20, -70)
    shieldCheck.text = shieldCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    shieldCheck.text:SetPoint("LEFT", shieldCheck, "RIGHT", 5, 0)
    shieldCheck.text:SetText("Using Shield (+1 DR)")
    shieldCheck:SetChecked(CE.Database:GetDefense().hasShield)
    shieldCheck:SetScript("OnClick", function(btn)
        CE.Database:SetDefense("hasShield", btn:GetChecked())
        self:UpdateDisplay()
    end)
    
    -- Helm checkbox
    local helmCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    helmCheck:SetPoint("TOPLEFT", 20, -100)
    helmCheck.text = helmCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    helmCheck.text:SetPoint("LEFT", helmCheck, "RIGHT", 5, 0)
    helmCheck.text:SetText("Wearing Helm (+1 Defense)")
    helmCheck:SetChecked(CE.Database:GetDefense().hasHelm)
    helmCheck:SetScript("OnClick", function(btn)
        CE.Database:SetDefense("hasHelm", btn:GetChecked())
        self:UpdateDisplay()
    end)
    
    -- Custom modifiers
    local customLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    customLabel:SetPoint("TOPLEFT", 20, -130)
    customLabel:SetText("Custom Modifiers:")
    
    -- Defense modifier
    local defModLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    defModLabel:SetPoint("TOPLEFT", 40, -150)
    defModLabel:SetText("Defense:")
    
    -- Fixed edit box background
    self.defModInput = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    self.defModInput:SetSize(40, 20)
    self.defModInput:SetPoint("LEFT", defModLabel, "RIGHT", 10, 0)
    self.defModInput:SetAutoFocus(false)
    self.defModInput:SetNumeric(true)
    self.defModInput:SetMaxLetters(3)
    self.defModInput:SetText(CE.Database:GetDefense().customDefense or 0)
    self.defModInput:SetScript("OnTextChanged", function(editBox)
        local value = tonumber(editBox:GetText()) or 0
        CE.Database:SetDefense("customDefense", value)
        self:UpdateDisplay()
    end)
    
    -- DR modifier
    local drModLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    drModLabel:SetPoint("LEFT", self.defModInput, "RIGHT", 20, 0)
    drModLabel:SetText("DR:")
    
    -- Fixed edit box background
    self.drModInput = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    self.drModInput:SetSize(40, 20)
    self.drModInput:SetPoint("LEFT", drModLabel, "RIGHT", 10, 0)
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
    -- Roll buttons container - below equipment config
    local container = CreateFrame("Frame", nil, self.parent)
    container:SetSize(280, 50)
    container:SetPoint("TOPLEFT", 20, -370)
    
    -- Roll Defense button
    local rollDefBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    rollDefBtn:SetSize(130, 35)
    rollDefBtn:SetPoint("LEFT", 0, 0)
    rollDefBtn:SetText("Roll Defense")
    rollDefBtn:SetScript("OnClick", function()
        self:RollDefense()
    end)
    
    -- Roll DR button
    local rollDRBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    rollDRBtn:SetSize(130, 35)
    rollDRBtn:SetPoint("RIGHT", 0, 0)
    rollDRBtn:SetText("Roll DR")
    rollDRBtn:SetScript("OnClick", function()
        self:RollDR()
    end)
end

function DefensePanel:CreateInfoSection()
    -- Info panel - positioned to the right side
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(480, 320)
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
    title:SetText("Armor Types Reference")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Info text
    local infoText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoText:SetPoint("TOPLEFT", 20, -35)
    infoText:SetPoint("TOPRIGHT", -20, -35)
    infoText:SetJustifyH("LEFT")
    infoText:SetSpacing(3)
    infoText:SetText(
        "|cFFFFD700Light Armor:|r\n" ..
        "  +3 Defense, D4 Damage Reduction\n\n" ..
        "|cFFFFD700Medium Armor:|r\n" ..
        "  +2 Defense, D6 Damage Reduction\n\n" ..
        "|cFFFFD700Heavy Armor:|r\n" ..
        "  -2 Defense, D8 Damage Reduction\n\n" ..
        "|cFF00FF00Equipment Bonuses:|r\n" ..
        "  Shield: +1 Damage Reduction\n" ..
        "  Helm: +1 Defense"
    )
    
    self:UpdateDisplay()
end

-- Rest of the methods remain the same...
function DefensePanel:UpdateDisplay()
    local defense = CE.Utils:CalculateDefense()
    local dr = CE.Utils:GetDamageReduction()
    
    self.defenseText:SetText(string.format("Defense: %+d", defense))
    self.drText:SetText(string.format("Damage Reduction: %s", dr ~= "" and dr or "None"))
end

function DefensePanel:RollDefense()
    local defense = CE.Utils:CalculateDefense()
    local result = CE.Utils:RollDice(20, 1)
    local total = result.total + defense
    
    CE.Communication:SendRoll({
        type = "defense",
        detail = string.format("1d20%+d", defense),
        rolls = result.rolls,
        total = total,
        modifier = defense
    })
end

function DefensePanel:RollDR()
    local defense = CE.Database:GetDefense()
    local drRolls = {}
    local total = 0
    local drParts = {}
    
    -- Roll armor DR
    local armorData = CE.Constants.ARMOR_TYPES[defense.armorType]
    if armorData and armorData.dr then
        local sides = tonumber(armorData.dr:match("D(%d+)"))
        if sides then
            local result = CE.Utils:RollDice(sides, 1)
            total = total + result.total
            table.insert(drRolls, result.total)
            table.insert(drParts, armorData.dr)
        end
    end
    
    -- Add shield DR
    if defense.hasShield then
        total = total + CE.Constants.SHIELD_DR
        table.insert(drParts, "Shield(1)")
    end
    
    -- Add custom DR
    if defense.customDR and defense.customDR > 0 then
        total = total + defense.customDR
        table.insert(drParts, "Custom(" .. defense.customDR .. ")")
    end
    
    local drString = table.concat(drParts, "+")
    if drString == "" then
        drString = "No DR"
    end
    
    CE.Communication:SendRoll({
        type = "dr",
        detail = drString,
        rolls = drRolls,
        total = total,
        modifier = 0
    })
end