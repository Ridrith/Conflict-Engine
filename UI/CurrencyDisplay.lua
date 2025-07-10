local _, CE = ...

local CurrencyDisplay = {}
CE.UI = CE.UI or {}
CE.UI.CurrencyDisplay = CurrencyDisplay

function CurrencyDisplay:Initialize(parent)
    self.parent = parent
    
    -- Create currency frame
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(200, 30)
    frame:SetPoint("RIGHT", -80, 0)
    
    -- Gold
    local goldIcon = frame:CreateTexture(nil, "ARTWORK")
    goldIcon:SetSize(16, 16)
    goldIcon:SetPoint("RIGHT", -120, 0)
    goldIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
    
    self.goldText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.goldText:SetPoint("RIGHT", goldIcon, "LEFT", -2, 0)
    self.goldText:SetTextColor(1, 0.82, 0)
    
    -- Silver
    local silverIcon = frame:CreateTexture(nil, "ARTWORK")
    silverIcon:SetSize(16, 16)
    silverIcon:SetPoint("RIGHT", -70, 0)
    silverIcon:SetTexture("Interface\\MoneyFrame\\UI-SilverIcon")
    
    self.silverText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.silverText:SetPoint("RIGHT", silverIcon, "LEFT", -2, 0)
    self.silverText:SetTextColor(0.75, 0.75, 0.75)
    
    -- Copper
    local copperIcon = frame:CreateTexture(nil, "ARTWORK")
    copperIcon:SetSize(16, 16)
    copperIcon:SetPoint("RIGHT", -20, 0)
    copperIcon:SetTexture("Interface\\MoneyFrame\\UI-CopperIcon")
    
    self.copperText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.copperText:SetPoint("RIGHT", copperIcon, "LEFT", -2, 0)
    self.copperText:SetTextColor(0.77, 0.42, 0.21)
    
    -- Edit button
    local editBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    editBtn:SetSize(40, 20)
    editBtn:SetPoint("RIGHT", 0, 0)
    editBtn:SetText("Edit")
    editBtn:GetFontString():SetFont(editBtn:GetFontString():GetFont(), 10)
    editBtn:SetScript("OnClick", function()
        self:ShowEditDialog()
    end)
    
    self.frame = frame
    self:UpdateDisplay()
end

function CurrencyDisplay:UpdateDisplay()
    local currency = CE.Database:GetCurrency()
    
    self.goldText:SetText(currency.gold or 0)
    self.silverText:SetText(currency.silver or 0)
    self.copperText:SetText(currency.copper or 0)
end

function CurrencyDisplay:ShowEditDialog()
    -- Create or show currency edit dialog
    if self.editDialog then
        self.editDialog:Show()
        return
    end
    
    local dialog = CreateFrame("Frame", "CE_CurrencyEditDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(250, 200)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Title
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Edit Currency")
    
    local currency = CE.Database:GetCurrency()
    
    -- Gold
    local goldLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    goldLabel:SetPoint("TOPLEFT", 30, -50)
    goldLabel:SetText("Gold:")
    
    local goldEdit = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    goldEdit:SetSize(80, 25)
    goldEdit:SetPoint("LEFT", goldLabel, "RIGHT", 20, 0)
    goldEdit:SetNumeric(true)
    goldEdit:SetMaxLetters(6)
    goldEdit:SetText(currency.gold or 0)
    goldEdit:SetAutoFocus(false)
    
    -- Silver
    local silverLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    silverLabel:SetPoint("TOPLEFT", 30, -80)
    silverLabel:SetText("Silver:")
    
    local silverEdit = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    silverEdit:SetSize(80, 25)
    silverEdit:SetPoint("LEFT", silverLabel, "RIGHT", 20, 0)
    silverEdit:SetNumeric(true)
    silverEdit:SetMaxLetters(6)
    silverEdit:SetText(currency.silver or 0)
    silverEdit:SetAutoFocus(false)
    
    -- Copper
    local copperLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    copperLabel:SetPoint("TOPLEFT", 30, -110)
    copperLabel:SetText("Copper:")
    
    local copperEdit = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    copperEdit:SetSize(80, 25)
    copperEdit:SetPoint("LEFT", copperLabel, "RIGHT", 20, 0)
    copperEdit:SetNumeric(true)
    copperEdit:SetMaxLetters(6)
    copperEdit:SetText(currency.copper or 0)
    copperEdit:SetAutoFocus(false)
    
    -- Save button
    local saveBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 25)
    saveBtn:SetPoint("BOTTOMLEFT", 30, 20)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        CE.Database:SetCurrency({
            gold = tonumber(goldEdit:GetText()) or 0,
            silver = tonumber(silverEdit:GetText()) or 0,
            copper = tonumber(copperEdit:GetText()) or 0
        })
        self:UpdateDisplay()
        dialog:Hide()
    end)
    
    -- Cancel button
    local cancelBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 25)
    cancelBtn:SetPoint("BOTTOMRIGHT", -30, 20)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    
    self.editDialog = dialog
end