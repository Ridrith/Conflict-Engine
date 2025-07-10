local _, CE = ...

CE.Widgets = {}

-- Create a styled panel
function CE.Widgets:CreatePanel(parent, width, height, title)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(width, height)
    
    CE.Style:ApplyBackdrop(panel, "secondary")
    
    if title then
        -- Title bar
        local titleBar = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        titleBar:SetHeight(30)
        titleBar:SetPoint("TOPLEFT", 0, 0)
        titleBar:SetPoint("TOPRIGHT", 0, 0)
        
        CE.Style:ApplyBackdrop(titleBar, "accent")
        
        -- Title text
        titleBar.text = titleBar:CreateFontString(nil, "OVERLAY", "CE_Font_Header")
        titleBar.text:SetPoint("CENTER")
        titleBar.text:SetText(title)
        
        panel.titleBar = titleBar
    end
    
    return panel
end

-- Create attribute display
function CE.Widgets:CreateAttributeFrame(parent, name)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(220, 40)
    
    -- Background
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(unpack(CE.Style.Colors.Secondary))
    frame.bg:SetAlpha(0.3)
    
    -- Border glow
    frame.glow = frame:CreateTexture(nil, "BORDER")
    frame.glow:SetPoint("TOPLEFT", -2, 2)
    frame.glow:SetPoint("BOTTOMRIGHT", 2, -2)
    frame.glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    frame.glow:SetBlendMode("ADD")
    frame.glow:SetAlpha(0)
    
    -- Icon
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(32, 32)
    frame.icon:SetPoint("LEFT", 5, 0)
    frame.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
    
    -- Icon border
    frame.iconBorder = frame:CreateTexture(nil, "OVERLAY")
    frame.iconBorder:SetSize(36, 36)
    frame.iconBorder:SetPoint("CENTER", frame.icon)
    frame.iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    frame.iconBorder:SetVertexColor(unpack(CE.Style.Colors.Accent))
    
    -- Name
    frame.name = frame:CreateFontString(nil, "OVERLAY", "CE_Font_Normal")
    frame.name:SetPoint("LEFT", frame.icon, "RIGHT", 10, 5)
    frame.name:SetText(name)
    
    -- Value
    frame.value = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.value:SetPoint("LEFT", frame.icon, "RIGHT", 10, -8)
    frame.value:SetTextColor(unpack(CE.Style.Colors.AccentLight))
    
    -- Decrease button
    frame.decreaseBtn = CreateFrame("Button", nil, frame)
    frame.decreaseBtn:SetSize(20, 20)
    frame.decreaseBtn:SetPoint("RIGHT", -50, 0)
    CE.Style:StyleButton(frame.decreaseBtn, 20, 20)
    frame.decreaseBtn:SetText("-")
    
    -- Increase button
    frame.increaseBtn = CreateFrame("Button", nil, frame)
    frame.increaseBtn:SetSize(20, 20)
    frame.increaseBtn:SetPoint("LEFT", frame.decreaseBtn, "RIGHT", 2, 0)
    CE.Style:StyleButton(frame.increaseBtn, 20, 20)
    frame.increaseBtn:SetText("+")
    
    -- Roll button
    frame.rollBtn = CreateFrame("Button", nil, frame)
    frame.rollBtn:SetSize(20, 20)
    frame.rollBtn:SetPoint("LEFT", frame.increaseBtn, "RIGHT", 2, 0)
    CE.Style:StyleButton(frame.rollBtn, 20, 20)
    frame.rollBtn:SetText("⚀")
    frame.rollBtn:SetNormalFontObject("GameFontNormalLarge")
    
    -- Hover effect
    frame:SetScript("OnEnter", function(self)
        self.glow:SetAlpha(0.6)
        self.bg:SetAlpha(0.5)
    end)
    
    frame:SetScript("OnLeave", function(self)
        self.glow:SetAlpha(0)
        self.bg:SetAlpha(0.3)
    end)
    
    return frame
end

-- Create dice button
function CE.Widgets:CreateDiceButton(parent, diceType)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(80, 80)
    
    -- Background
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(unpack(CE.Style.Colors.Secondary))
    btn.bg:SetAlpha(0.5)
    
    -- Icon
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(60, 60)
    btn.icon:SetPoint("CENTER", 0, 5)
    
    -- Dice icons
    local diceIcons = {
        [4] = "Interface\\Icons\\INV_Misc_Dice_01",
        [6] = "Interface\\Icons\\INV_Misc_Dice_02",
        [8] = "Interface\\Icons\\Achievement_BG_KillXEnemies_GeneralHorde",
        [10] = "Interface\\Icons\\INV_Misc_Dice_01",
        [12] = "Interface\\Icons\\INV_Misc_Dice_02",
        [20] = "Interface\\Icons\\INV_Enchant_ShardPrismaticLarge",
        [100] = "Interface\\Icons\\INV_Enchant_VoidSphere"
    }
    
    btn.icon:SetTexture(diceIcons[diceType.sides] or diceIcons[6])
    
    -- Border
    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetSize(84, 84)
    btn.border:SetPoint("CENTER")
    btn.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    btn.border:SetVertexColor(unpack(CE.Style.Colors.Accent))
    btn.border:SetAlpha(0.8)
    
    -- Label
    btn.label = btn:CreateFontString(nil, "OVERLAY", "CE_Font_Header")
    btn.label:SetPoint("BOTTOM", 0, 5)
    btn.label:SetText(diceType.name)
    
    -- Glow effect
    btn.glow = btn:CreateTexture(nil, "OVERLAY")
    btn.glow:SetAllPoints()
    btn.glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    btn.glow:SetBlendMode("ADD")
    btn.glow:SetAlpha(0)
    
    -- Hover effects
    btn:SetScript("OnEnter", function(self)
        self.glow:SetAlpha(0.4)
        self.bg:SetAlpha(0.8)
        self.border:SetVertexColor(unpack(CE.Style.Colors.AccentLight))
    end)
    
    btn:SetScript("OnLeave", function(self)
        self.glow:SetAlpha(0)
        self.bg:SetAlpha(0.5)
        self.border:SetVertexColor(unpack(CE.Style.Colors.Accent))
    end)
    
    btn:SetScript("OnMouseDown", function(self)
        self.icon:SetPoint("CENTER", 0, 3)
    end)
    
    btn:SetScript("OnMouseUp", function(self)
        self.icon:SetPoint("CENTER", 0, 5)
    end)
    
    return btn
end

-- Create custom tab
function CE.Widgets:CreateTab(parent, id, text)
    -- Create unique name for the tab
    local tabName = nil
    if parent and parent.GetName and parent:GetName() then
        tabName = parent:GetName() .. "Tab" .. id
    end
    
    local tab = CreateFrame("Button", tabName, parent)
    tab:SetSize(120, 32)
    tab:SetID(id)
    
    -- Background
    tab.bg = tab:CreateTexture(nil, "BACKGROUND")
    tab.bg:SetAllPoints()
    tab.bg:SetColorTexture(unpack(CE.Style.Colors.Secondary))
    tab.bg:SetAlpha(0.6)
    
    -- Border
    tab.leftBorder = tab:CreateTexture(nil, "BORDER")
    tab.leftBorder:SetSize(2, 32)
    tab.leftBorder:SetPoint("LEFT")
    tab.leftBorder:SetColorTexture(unpack(CE.Style.Colors.Accent))
    tab.leftBorder:Hide()
    
    tab.rightBorder = tab:CreateTexture(nil, "BORDER")
    tab.rightBorder:SetSize(2, 32)
    tab.rightBorder:SetPoint("RIGHT")
    tab.rightBorder:SetColorTexture(unpack(CE.Style.Colors.Accent))
    tab.rightBorder:Hide()
    
    tab.bottomBorder = tab:CreateTexture(nil, "BORDER")
    tab.bottomBorder:SetSize(120, 2)
    tab.bottomBorder:SetPoint("BOTTOM")
    tab.bottomBorder:SetColorTexture(unpack(CE.Style.Colors.Accent))
    tab.bottomBorder:Hide()
    
    -- Text
    tab.text = tab:CreateFontString(nil, "OVERLAY", "CE_Font_Normal")
    tab.text:SetPoint("CENTER")
    tab.text:SetText(text)
    
    -- Icon (optional)
    tab.icon = tab:CreateTexture(nil, "ARTWORK")
    tab.icon:SetSize(20, 20)
    tab.icon:SetPoint("LEFT", 8, 0)
    tab.icon:Hide()
    
    -- Selection indicator
    tab.selected = tab:CreateTexture(nil, "ARTWORK")
    tab.selected:SetHeight(3)
    tab.selected:SetPoint("BOTTOMLEFT", 2, 0)
    tab.selected:SetPoint("BOTTOMRIGHT", -2, 0)
    tab.selected:SetColorTexture(unpack(CE.Style.Colors.AccentLight))
    tab.selected:Hide()
    
    return tab
end

-- Create a styled scroll frame
function CE.Widgets:CreateScrollFrame(parent, width, height)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width, height)
    
    -- Style the scroll bar
    local scrollBar = scrollFrame.ScrollBar
    if scrollBar then
        -- Style scroll bar background
        local bg = scrollBar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)
        
        -- Style thumb texture
        local thumb = scrollBar:GetThumbTexture()
        if thumb then
            thumb:SetColorTexture(unpack(CE.Style.Colors.Accent))
            thumb:SetSize(8, 30)
        end
    end
    
    -- Create scroll child
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(width - 20, height)
    scrollFrame:SetScrollChild(scrollChild)
    
    return scrollFrame, scrollChild
end

-- Create a styled input box
function CE.Widgets:CreateEditBox(parent, width, height, isMultiLine)
    local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    bg:SetSize(width, height)
    
    bg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    bg:SetBackdropColor(0, 0, 0, 0.5)
    bg:SetBackdropBorderColor(unpack(CE.Style.Colors.Border))
    
    local editBox = CreateFrame("EditBox", nil, bg)
    editBox:SetPoint("TOPLEFT", 5, -5)
    editBox:SetPoint("BOTTOMRIGHT", -5, 5)
    editBox:SetFontObject("CE_Font_Normal")
    editBox:SetAutoFocus(false)
    editBox:SetMultiLine(isMultiLine or false)
    
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    -- Focus effects
    editBox:SetScript("OnEditFocusGained", function(self)
        bg:SetBackdropBorderColor(unpack(CE.Style.Colors.Accent))
    end)
    
    editBox:SetScript("OnEditFocusLost", function(self)
        bg:SetBackdropBorderColor(unpack(CE.Style.Colors.Border))
    end)
    
    return editBox, bg
end

-- Create a checkbox with label
function CE.Widgets:CreateCheckBox(parent, label)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    
    if label then
        check.text = check:CreateFontString(nil, "OVERLAY", "CE_Font_Normal")
        check.text:SetPoint("LEFT", check, "RIGHT", 5, 0)
        check.text:SetText(label)
    end
    
    return check
end

-- Create a dropdown menu
function CE.Widgets:CreateDropdown(parent, width, items, onSelect)
    local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, width)
    
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, item in ipairs(items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item.text or item
            info.value = item.value or item
            info.func = function()
                UIDropDownMenu_SetSelectedValue(dropdown, info.value)
                if onSelect then
                    onSelect(info.value)
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    return dropdown
end