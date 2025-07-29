local _, CE = ...

local TraitsPanel = {}
CE.UI = CE.UI or {}
CE.UI.TraitsPanel = TraitsPanel

function TraitsPanel:Initialize(parent)
    if not parent then return end
    
    self.parent = parent
    self.traitFrames = {}
    
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
    title:SetText("CHARACTER TRAITS")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)
    
    -- Character name with silver
    local charName = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    charName:SetPoint("TOP", title, "BOTTOM", 0, -2)
    charName:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    charName:SetText(CE.Database:GetCurrentCharacter())
    charName:SetTextColor(0.6, 0.6, 0.65) -- Silver
    self.charNameText = charName
    
    -- Decorative divider with dark silver
    local divider = CE.Style:CreateDivider(parent, 300)
    divider:SetPoint("TOP", charName, "BOTTOM", 0, -5)
    divider:SetVertexColor(0.35, 0.35, 0.4, 0.6) -- Dark silver
    
    -- Add trait button with flat style
    local addBtn = self:CreateFlatButton(parent, "Add Trait", 100, 30)
    addBtn:SetPoint("TOPRIGHT", -20, -10)
    addBtn:SetScript("OnClick", function()
        self:ShowAddTraitDialog()
    end)
    
    -- Traits container with dark background
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 20, -70)
    container:SetPoint("BOTTOMRIGHT", -20, 20)
    
    CE.Style:ApplyBackdrop(container, "simple")
    container:SetBackdropColor(0.03, 0.03, 0.04, 0.95) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver border
    
    -- Traits scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "CE_TraitsScrollFrame", container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    -- Style scroll bar with dark silver
    local scrollBar = scrollFrame.ScrollBar or _G["CE_TraitsScrollFrameScrollBar"]
    if scrollBar then
        local thumb = scrollBar:GetThumbTexture()
        if thumb then
            thumb:SetVertexColor(0.3, 0.3, 0.35)
        end
    end
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(800, 1)
    scrollFrame:SetScrollChild(content)
    
    self.scrollContent = content
    self:RefreshTraits()
end

function TraitsPanel:CreateFlatButton(parent, text, width, height)
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

function TraitsPanel:ShowIconPicker(currentIcon, callback)
    if self.iconPickerFrame then
        self.iconPickerFrame:Show()
        self.iconPickerCallback = callback
        return
    end
    
    -- Create icon picker dialog
    local picker = CreateFrame("Frame", "CE_IconPickerDialog", UIParent, "BackdropTemplate")
    picker:SetSize(700, 600)
    picker:SetPoint("CENTER")
    picker:SetFrameStrata("FULLSCREEN_DIALOG")
    picker:SetMovable(true)
    picker:EnableMouse(true)
    picker:RegisterForDrag("LeftButton")
    picker:SetScript("OnDragStart", picker.StartMoving)
    picker:SetScript("OnDragStop", picker.StopMovingOrSizing)
    
    picker:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    picker:SetBackdropColor(0.02, 0.02, 0.03, 0.98)
    picker:SetBackdropBorderColor(0.6, 0.6, 0.65, 0.9)
    
    -- Title
    local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetFont("Fonts\\FRIZQT__.ttf", 16, "OUTLINE")
    title:SetText("Choose Icon")
    title:SetTextColor(0.85, 0.82, 0.75)
    
    -- Use texture IDs for more reliable icon display
    local commonIcons = {
        -- Using texture IDs instead of file paths where possible
        -- Mixed approach: some working file paths + texture IDs
        134419, -- Spell_Nature_Lightning
        134400, -- Spell_Fire_FlameBolt
        135808, -- Spell_Holy_Heal
        136235, -- Ability_Warrior_Charge
        136173, -- Ability_Stealth
        136118, -- Ability_Warrior_BattleShout
        136048, -- Spell_Fire_Fireball
        135846, -- Spell_Frost_FrostBolt
        136048, -- Spell_Shadow_ShadowBolt
        135893, -- Ability_Paladin_Devotion
        132292, -- Ability_Rogue_Eviscerate
        132212, -- Ability_Hunter_AimedShot
        135736, -- Spell_Arcane_Blink
        132114, -- Ability_Druid_Bash
        135940, -- Spell_Holy_PowerWordShield
        132223, -- Ability_Warrior_WeaponMastery
        136145, -- Spell_Shadow_DeathCoil
        132154, -- Ability_Warrior_Intimidate
        135817, -- Spell_Fire_Incinerate
        135968, -- Spell_Holy_SealOfLight
        136071, -- Spell_Nature_Polymorph
        132353, -- Ability_Warrior_Revenge
        135955, -- Spell_Holy_Resurrection
        132291, -- Ability_Rogue_ShadowClone
        136116, -- Spell_Arcane_Explosion
        132329, -- Ability_Hunter_TrueShot
        135843, -- Spell_Frost_FrostArmor
        136052, -- Spell_Nature_Rejuvenation
        136206, -- Spell_Shadow_Possession
        
        -- Working file paths from your screenshot
        "Interface\\Icons\\Spell_Fire_Fireball",
        "Interface\\Icons\\Spell_Nature_Lightning",
        "Interface\\Icons\\Spell_Holy_Heal",
        "Interface\\Icons\\Ability_Warrior_Charge",
        "Interface\\Icons\\Ability_Stealth",
        "Interface\\Icons\\Ability_Warrior_BattleShout",
        "Interface\\Icons\\Spell_Frost_FrostBolt",
        "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        "Interface\\Icons\\Ability_Paladin_Devotion",
        "Interface\\Icons\\Ability_Rogue_Eviscerate",
        "Interface\\Icons\\Ability_Hunter_AimedShot",
        "Interface\\Icons\\Spell_Arcane_Blink",
        "Interface\\Icons\\Ability_Druid_Bash",
        "Interface\\Icons\\Spell_Holy_PowerWordShield",
        "Interface\\Icons\\Ability_Warrior_WeaponMastery",
        "Interface\\Icons\\Spell_Shadow_DeathCoil",
        "Interface\\Icons\\Ability_Warrior_Intimidate",
        "Interface\\Icons\\Spell_Fire_Incinerate",
        "Interface\\Icons\\Spell_Holy_SealOfLight",
        "Interface\\Icons\\Spell_Nature_Polymorph",
        "Interface\\Icons\\Ability_Warrior_Revenge",
        "Interface\\Icons\\Spell_Holy_Resurrection",
        "Interface\\Icons\\Ability_Rogue_ShadowClone",
        "Interface\\Icons\\Spell_Arcane_Explosion",
        "Interface\\Icons\\Ability_Hunter_TrueShot",
        "Interface\\Icons\\Spell_Frost_FrostArmor",
        "Interface\\Icons\\Spell_Nature_Rejuvenation",
        "Interface\\Icons\\Spell_Shadow_Possession",
        
        -- Additional reliable texture IDs
        132369, -- INV_Sword_04
        136103, -- Spell_Fire_MeteorStorm
        135895, -- Spell_Holy_Devotion
        136100, -- Spell_Nature_Stranglevines
        132290, -- Ability_Rogue_Ambush
        135932, -- Spell_Arcane_Intellect
        134335, -- INV_Misc_Gem_01
        134336, -- INV_Misc_Gem_02
        134337, -- INV_Misc_Gem_03
        134338, -- INV_Misc_Gem_04
        134339, -- INV_Misc_Gem_05
        134432, -- INV_Misc_Orb_01
        134433, -- INV_Misc_Orb_02
        134434, -- INV_Misc_Orb_03
        134435, -- INV_Misc_Orb_04
        134436, -- INV_Misc_Orb_05
        134419, -- INV_Misc_Rune_01
        134420, -- INV_Misc_Rune_02
        134421, -- INV_Misc_Rune_03
        134422, -- INV_Misc_Rune_04
        134423, -- INV_Misc_Rune_05
        133738, -- INV_Misc_Book_01
        133739, -- INV_Misc_Book_02
        133740, -- INV_Misc_Book_03
        133741, -- INV_Misc_Book_04
        133742, -- INV_Misc_Book_05
        133743, -- INV_Misc_Book_06
        133744, -- INV_Misc_Book_07
        133745, -- INV_Misc_Book_08
        133746, -- INV_Misc_Book_09
        133747, -- INV_Misc_Book_10
        133748, -- INV_Misc_Book_11
        133749, -- INV_Misc_Book_12
        133996, -- INV_Scroll_01
        133997, -- INV_Scroll_02
        133998, -- INV_Scroll_03
        133999, -- INV_Scroll_04
        134000, -- INV_Scroll_05
        
        -- More texture IDs for variety
        136243, -- Ability_Warrior_Taunt
        136201, -- Ability_Warrior_Sunder
        136105, -- Ability_Warrior_Cleave
        136224, -- Ability_Warrior_InnerRage
        132343, -- Ability_Warrior_Disarm
        132355, -- Ability_Warrior_PunishingBlow
        132091, -- Ability_Warrior_WarStomp
        136182, -- Ability_Warrior_ShockWave
        132356, -- Ability_Warrior_Victorious
        132110, -- Ability_Warrior_Vigilance
        136012, -- Ability_Warrior_Bloodbath
        132340, -- Ability_Warrior_SavageBlow
        132282, -- Ability_Warrior_DecisiveStrike
    }
    
    -- Scroll frame for icons
    local scrollFrame = CreateFrame("ScrollFrame", nil, picker, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -60)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 60)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(620, 1)
    scrollFrame:SetScrollChild(content)
    
    -- Create icon buttons
    local iconsPerRow = 10
    local iconSize = 45
    local padding = 8
    
    for i, iconData in ipairs(commonIcons) do
        local iconBtn = CreateFrame("Button", nil, content)
        iconBtn:SetSize(iconSize, iconSize)
        
        local row = math.floor((i - 1) / iconsPerRow)
        local col = (i - 1) % iconsPerRow
        
        iconBtn:SetPoint("TOPLEFT", col * (iconSize + padding), -row * (iconSize + padding))
        
        -- Icon background
        local bg = iconBtn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        bg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
        
        -- Border
        local border = CreateFrame("Frame", nil, iconBtn, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
        
        -- Icon
        local icon = iconBtn:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 4, -4)
        icon:SetPoint("BOTTOMRIGHT", -4, 4)
        
        -- Set texture using either ID or file path
        if type(iconData) == "number" then
            icon:SetTexture(iconData)
        else
            icon:SetTexture(iconData)
        end
        
        -- Hover effect
        iconBtn:SetScript("OnEnter", function()
            border:SetBackdropBorderColor(0.5, 0.12, 0.18, 1)
        end)
        
        iconBtn:SetScript("OnLeave", function()
            border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
        end)
        
        iconBtn:SetScript("OnClick", function()
            if self.iconPickerCallback then
                self.iconPickerCallback(iconData)
            end
            picker:Hide()
        end)
    end
    
    -- Update content height
    local totalRows = math.ceil(#commonIcons / iconsPerRow)
    content:SetHeight(totalRows * (iconSize + padding))
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, picker, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:GetNormalTexture():SetVertexColor(0.6, 0.6, 0.65)
    closeBtn:GetHighlightTexture():SetVertexColor(0.85, 0.82, 0.75)
    
    -- Cancel button
    local cancelBtn = self:CreateFlatButton(picker, "Cancel", 80, 25)
    cancelBtn:SetPoint("BOTTOM", 0, 20)
    cancelBtn:SetScript("OnClick", function()
        picker:Hide()
    end)
    
    self.iconPickerFrame = picker
    self.iconPickerCallback = callback
end

function TraitsPanel:ShowAddTraitDialog()
    if self.addDialog then
        self.addDialog:Show()
        return
    end
    
    -- Create dialog with dark theme
    local dialog = CreateFrame("Frame", "CE_AddTraitDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(350, 250)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    dialog:SetBackdropColor(0.02, 0.02, 0.03, 0.98) -- Nearly black
    dialog:SetBackdropBorderColor(0.6, 0.6, 0.65, 0.9) -- Pale silver
    
    -- Header background
    local headerBg = dialog:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(40)
    headerBg:SetPoint("TOPLEFT", 12, -12)
    headerBg:SetPoint("TOPRIGHT", -12, -12)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    -- Title with pale gold
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", headerBg, "CENTER", 0, 0)
    title:SetFont("Fonts\\FRIZQT__.ttf", 16, "OUTLINE")
    title:SetText("Add New Trait")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Name input with dark styling
    local nameLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", 30, -65)
    nameLabel:SetText("Name:")
    nameLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    local nameInputBg = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    nameInputBg:SetSize(200, 25)
    nameInputBg:SetPoint("LEFT", nameLabel, "RIGHT", 20, 0)
    nameInputBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    nameInputBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    nameInputBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local nameInput = CreateFrame("EditBox", nil, nameInputBg)
    nameInput:SetPoint("TOPLEFT", 5, -2)
    nameInput:SetPoint("BOTTOMRIGHT", -5, 2)
    nameInput:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    nameInput:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    nameInput:SetMaxLetters(30)
    nameInput:SetAutoFocus(true)
    
    -- Uses input with dark styling
    local usesLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    usesLabel:SetPoint("TOPLEFT", 30, -95)
    usesLabel:SetText("Uses/Round:")
    usesLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    local usesInputBg = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    usesInputBg:SetSize(50, 25)
    usesInputBg:SetPoint("LEFT", usesLabel, "RIGHT", 20, 0)
    usesInputBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    usesInputBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    usesInputBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local usesInput = CreateFrame("EditBox", nil, usesInputBg)
    usesInput:SetPoint("TOPLEFT", 5, -2)
    usesInput:SetPoint("BOTTOMRIGHT", -5, 2)
    usesInput:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    usesInput:SetTextColor(0.85, 0.82, 0.75)
    usesInput:SetNumeric(true)
    usesInput:SetMaxLetters(3)
    usesInput:SetText("1")
    
    -- Description with dark styling
    local descLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descLabel:SetPoint("TOPLEFT", 30, -125)
    descLabel:SetText("Description:")
    descLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    -- Description scroll frame with dark background
    local descScrollBg = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    descScrollBg:SetSize(280, 60)
    descScrollBg:SetPoint("TOPLEFT", 30, -145)
    descScrollBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    descScrollBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    descScrollBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local descScroll = CreateFrame("ScrollFrame", nil, descScrollBg, "InputScrollFrameTemplate")
    descScroll:SetPoint("TOPLEFT", 5, -5)
    descScroll:SetPoint("BOTTOMRIGHT", -5, 5)
    
    local descInput = descScroll.EditBox
    descInput:SetMaxLetters(200)
    descInput:SetWidth(270)
    descInput:SetFont("Fonts\\FRIZQT__.ttf", 11, "")
    descInput:SetTextColor(0.85, 0.82, 0.75)
    
    -- Buttons with flat style
    local addBtn = self:CreateFlatButton(dialog, "Add", 80, 25)
    addBtn:SetPoint("BOTTOMLEFT", 50, 20)
    addBtn:SetScript("OnClick", function()
        local name = nameInput:GetText()
        local uses = tonumber(usesInput:GetText()) or 1
        local desc = descInput:GetText()
        
        if name and name ~= "" then
            CE.Database:AddTrait({
                name = name,
                maxUses = uses,
                currentUses = uses,
                description = desc,
                icon = 133738 -- Default book icon using texture ID
            })
            self:RefreshTraits()
            dialog:Hide()
            
            -- Clear fields
            nameInput:SetText("")
            usesInput:SetText("1")
            descInput:SetText("")
        end
    end)
    
    local cancelBtn = self:CreateFlatButton(dialog, "Cancel", 80, 25)
    cancelBtn:SetPoint("BOTTOMRIGHT", -50, 20)
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    -- Close button with dark styling
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:GetNormalTexture():SetVertexColor(0.6, 0.6, 0.65)
    closeBtn:GetHighlightTexture():SetVertexColor(0.85, 0.82, 0.75)
    
    -- Store references
    dialog.nameInput = nameInput
    dialog.usesInput = usesInput
    dialog.descInput = descInput
    
    self.addDialog = dialog
end

function TraitsPanel:ShowEditTraitDialog(trait, index)
    if self.editDialog then
        self.editDialog:Show()
        -- Populate with current values
        self.editDialog.nameInput:SetText(trait.name or "")
        self.editDialog.usesInput:SetText(tostring(trait.maxUses or 1))
        self.editDialog.descInput:SetText(trait.description or "")
        self.editDialog.currentIcon = trait.icon or 133738
        
        -- Handle both texture ID and file path
        if type(self.editDialog.currentIcon) == "number" then
            self.editDialog.iconTexture:SetTexture(self.editDialog.currentIcon)
        else
            self.editDialog.iconTexture:SetTexture(self.editDialog.currentIcon)
        end
        
        self.editDialog.currentIndex = index
        return
    end
    
    -- Create edit dialog with dark theme
    local dialog = CreateFrame("Frame", "CE_EditTraitDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(350, 300)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    dialog:SetBackdropColor(0.02, 0.02, 0.03, 0.98)
    dialog:SetBackdropBorderColor(0.6, 0.6, 0.65, 0.9)
    
    -- Header background
    local headerBg = dialog:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(40)
    headerBg:SetPoint("TOPLEFT", 12, -12)
    headerBg:SetPoint("TOPRIGHT", -12, -12)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
    
    -- Title with pale gold
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", headerBg, "CENTER", 0, 0)
    title:SetFont("Fonts\\FRIZQT__.ttf", 16, "OUTLINE")
    title:SetText("Edit Trait")
    title:SetTextColor(0.85, 0.82, 0.75)
    
    -- Icon selection
    local iconLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    iconLabel:SetPoint("TOPLEFT", 30, -65)
    iconLabel:SetText("Icon:")
    iconLabel:SetTextColor(0.6, 0.6, 0.65)
    
    local iconBtn = CreateFrame("Button", nil, dialog)
    iconBtn:SetSize(40, 40)
    iconBtn:SetPoint("LEFT", iconLabel, "RIGHT", 10, 0)
    
    local iconBg = iconBtn:CreateTexture(nil, "BACKGROUND")
    iconBg:SetAllPoints()
    iconBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    iconBg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
    
    local iconBorder = CreateFrame("Frame", nil, iconBtn, "BackdropTemplate")
    iconBorder:SetAllPoints()
    iconBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    iconBorder:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local iconTexture = iconBtn:CreateTexture(nil, "ARTWORK")
    iconTexture:SetPoint("TOPLEFT", 4, -4)
    iconTexture:SetPoint("BOTTOMRIGHT", -4, 4)
    
    -- Handle both texture ID and file path for initial display
    if type(trait.icon) == "number" then
        iconTexture:SetTexture(trait.icon)
    else
        iconTexture:SetTexture(trait.icon or 133738)
    end
    
    dialog.iconTexture = iconTexture
    dialog.currentIcon = trait.icon or 133738
    
    iconBtn:SetScript("OnClick", function()
        self:ShowIconPicker(dialog.currentIcon, function(newIcon)
            dialog.currentIcon = newIcon
            if type(newIcon) == "number" then
                iconTexture:SetTexture(newIcon)
            else
                iconTexture:SetTexture(newIcon)
            end
        end)
    end)
    
    -- Name input
    local nameLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", 30, -115)
    nameLabel:SetText("Name:")
    nameLabel:SetTextColor(0.6, 0.6, 0.65)
    
    local nameInputBg = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    nameInputBg:SetSize(200, 25)
    nameInputBg:SetPoint("LEFT", nameLabel, "RIGHT", 20, 0)
    nameInputBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    nameInputBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    nameInputBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local nameInput = CreateFrame("EditBox", nil, nameInputBg)
    nameInput:SetPoint("TOPLEFT", 5, -2)
    nameInput:SetPoint("BOTTOMRIGHT", -5, 2)
    nameInput:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    nameInput:SetTextColor(0.85, 0.82, 0.75)
    nameInput:SetMaxLetters(30)
    nameInput:SetText(trait.name or "")
    
    -- Uses input
    local usesLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    usesLabel:SetPoint("TOPLEFT", 30, -145)
    usesLabel:SetText("Uses/Round:")
    usesLabel:SetTextColor(0.6, 0.6, 0.65)
    
    local usesInputBg = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    usesInputBg:SetSize(50, 25)
    usesInputBg:SetPoint("LEFT", usesLabel, "RIGHT", 20, 0)
    usesInputBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    usesInputBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    usesInputBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local usesInput = CreateFrame("EditBox", nil, usesInputBg)
    usesInput:SetPoint("TOPLEFT", 5, -2)
    usesInput:SetPoint("BOTTOMRIGHT", -5, 2)
    usesInput:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    usesInput:SetTextColor(0.85, 0.82, 0.75)
    usesInput:SetNumeric(true)
    usesInput:SetMaxLetters(3)
    usesInput:SetText(tostring(trait.maxUses or 1))
    
    -- Description input
    local descLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descLabel:SetPoint("TOPLEFT", 30, -175)
    descLabel:SetText("Description:")
    descLabel:SetTextColor(0.6, 0.6, 0.65)
    
    local descScrollBg = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    descScrollBg:SetSize(280, 60)
    descScrollBg:SetPoint("TOPLEFT", 30, -195)
    descScrollBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    descScrollBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    descScrollBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local descScroll = CreateFrame("ScrollFrame", nil, descScrollBg, "InputScrollFrameTemplate")
    descScroll:SetPoint("TOPLEFT", 5, -5)
    descScroll:SetPoint("BOTTOMRIGHT", -5, 5)
    
    local descInput = descScroll.EditBox
    descInput:SetMaxLetters(200)
    descInput:SetWidth(270)
    descInput:SetFont("Fonts\\FRIZQT__.ttf", 11, "")
    descInput:SetTextColor(0.85, 0.82, 0.75)
    descInput:SetText(trait.description or "")
    
    -- Buttons
    local saveBtn = self:CreateFlatButton(dialog, "Save", 80, 25)
    saveBtn:SetPoint("BOTTOMLEFT", 50, 20)
    saveBtn:SetScript("OnClick", function()
        local name = nameInput:GetText()
        local uses = tonumber(usesInput:GetText()) or 1
        local desc = descInput:GetText()
        
        if name and name ~= "" then
            local updatedTrait = {
                name = name,
                maxUses = uses,
                currentUses = trait.currentUses or uses,
                description = desc,
                icon = dialog.currentIcon
            }
            
            CE.Database:UpdateTrait(dialog.currentIndex, updatedTrait)
            self:RefreshTraits()
            dialog:Hide()
        end
    end)
    
    local cancelBtn = self:CreateFlatButton(dialog, "Cancel", 80, 25)
    cancelBtn:SetPoint("BOTTOMRIGHT", -50, 20)
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:GetNormalTexture():SetVertexColor(0.6, 0.6, 0.65)
    closeBtn:GetHighlightTexture():SetVertexColor(0.85, 0.82, 0.75)
    
    -- Store references
    dialog.nameInput = nameInput
    dialog.usesInput = usesInput
    dialog.descInput = descInput
    dialog.currentIndex = index
    
    self.editDialog = dialog
end

function TraitsPanel:RefreshTraits()
    -- Clear existing frames
    for _, frame in pairs(self.traitFrames) do
        frame:Hide()
    end
    self.traitFrames = {}
    
    -- Update character name if it changed
    if self.charNameText then
        self.charNameText:SetText(CE.Database:GetCurrentCharacter())
    end
    
    local traits = CE.Database:GetTraits()
    local yOffset = 0
    
    for i, trait in ipairs(traits) do
        local frame = self:CreateTraitFrame(self.scrollContent, trait, i)
        frame:SetPoint("TOPLEFT", 0, yOffset)
        frame:SetPoint("TOPRIGHT", 0, yOffset)
        
        self.traitFrames[i] = frame
        yOffset = yOffset - 100
    end
    
    -- Update scroll frame height
    self.scrollContent:SetHeight(math.abs(yOffset) + 20)
end

function TraitsPanel:CreateTraitFrame(parent, trait, index)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetHeight(90)
    
    CE.Style:ApplyBackdrop(frame, "wood")
    frame:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    frame:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Trait icon holder with dark background
    local iconHolder = frame:CreateTexture(nil, "BACKGROUND")
    iconHolder:SetSize(60, 60)
    iconHolder:SetPoint("LEFT", 10, 0)
    iconHolder:SetTexture("Interface\\Achievements\\UI-Achievement-IconFrame")
    iconHolder:SetVertexColor(0.15, 0.15, 0.18, 0.9) -- Dark grey
    
    -- Clickable icon button
    local iconBtn = CreateFrame("Button", nil, frame)
    iconBtn:SetSize(60, 60)
    iconBtn:SetPoint("CENTER", iconHolder)
    
    -- Trait icon
    local icon = iconBtn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(46, 46)
    icon:SetPoint("CENTER", 0, -2)
    
    -- Handle both texture ID and file path
    if type(trait.icon) == "number" then
        icon:SetTexture(trait.icon)
    else
        icon:SetTexture(trait.icon or 133738)
    end
    
    icon:SetVertexColor(0.85, 0.85, 0.9) -- Slightly bluish silver
    
    -- Icon quality border
    local iconBorder = frame:CreateTexture(nil, "OVERLAY")
    iconBorder:SetSize(60, 60)
    iconBorder:SetPoint("CENTER", iconHolder)
    iconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
    iconBorder:SetVertexColor(0.5, 0.5, 0.55) -- Silver
    
    -- Icon click handler - Fixed callback system
    iconBtn:SetScript("OnClick", function()
        self:ShowIconPicker(trait.icon, function(newIcon)
            trait.icon = newIcon
            if type(newIcon) == "number" then
                icon:SetTexture(newIcon)
            else
                icon:SetTexture(newIcon)
            end
            CE.Database:UpdateTrait(index, trait)
        end)
    end)
    
    -- Name with pale gold
    local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", iconHolder, "TOPRIGHT", 15, -10)
    name:SetFont("Fonts\\FRIZQT__.ttf", 14, "")
    name:SetText(trait.name)
    name:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Uses with colored indicators
    local usesFrame = CreateFrame("Frame", nil, frame)
    usesFrame:SetSize(120, 20)
    usesFrame:SetPoint("TOPRIGHT", -10, -10)
    
    -- Uses background
    local usesBg = usesFrame:CreateTexture(nil, "BACKGROUND")
    usesBg:SetAllPoints()
    usesBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    usesBg:SetVertexColor(0.1, 0.1, 0.12, 0.5)
    
    local uses = usesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    uses:SetPoint("CENTER")
    uses:SetFont("Fonts\\FRIZQT__.ttf", 12, "OUTLINE")
    uses:SetText(string.format("Uses: %d/%d", trait.currentUses or trait.maxUses, trait.maxUses))
    
    -- Update uses color based on remaining
    if trait.currentUses == 0 then
        uses:SetTextColor(0.8, 0.25, 0.3) -- Dark red
        iconBorder:SetVertexColor(0.7, 0.2, 0.25)
    elseif trait.currentUses <= trait.maxUses / 2 then
        uses:SetTextColor(0.9, 0.7, 0.3) -- Yellow
        iconBorder:SetVertexColor(0.8, 0.6, 0.2)
    else
        uses:SetTextColor(0.4, 0.85, 0.4) -- Bright green
        iconBorder:SetVertexColor(0.3, 0.7, 0.3)
    end
    
    -- Description with silver text
    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    desc:SetPoint("TOPLEFT", iconHolder, "TOPRIGHT", 15, -30)
    desc:SetPoint("RIGHT", -15, 0)
    desc:SetJustifyH("LEFT")
    desc:SetText(trait.description)
    desc:SetTextColor(0.6, 0.6, 0.65) -- Silver
    desc:SetHeight(40)
    
    -- Button container
    local buttonFrame = CreateFrame("Frame", nil, frame)
    buttonFrame:SetPoint("BOTTOMRIGHT", -10, 8)
    buttonFrame:SetSize(200, 25)
    
    -- Use button with flat style
    local useBtn = self:CreateFlatButton(buttonFrame, "Use", 50, 22)
    useBtn:SetPoint("RIGHT", 0, 0)
    useBtn:SetScript("OnClick", function()
        self:UseTrait(index)
    end)
    
    -- Disable if no uses
    if trait.currentUses == 0 then
        useBtn.bg:SetVertexColor(0.05, 0.05, 0.06, 0.9)
        useBtn.text:SetTextColor(0.3, 0.3, 0.35)
        useBtn:SetScript("OnEnter", nil)
        useBtn:SetScript("OnLeave", nil)
        useBtn:SetScript("OnClick", function()
            DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r This trait has no uses remaining!")
        end)
    end
    
    -- Reset button with proper styling
    local resetBtn = self:CreateFlatButton(buttonFrame, "Reset", 50, 22)
    resetBtn:SetPoint("RIGHT", useBtn, "LEFT", -2, 0)
    resetBtn:SetScript("OnClick", function()
        trait.currentUses = trait.maxUses
        CE.Database:UpdateTrait(index, trait)
        self:RefreshTraits()
    end)
    
    -- Edit button
    local editBtn = self:CreateFlatButton(buttonFrame, "Edit", 45, 22)
    editBtn:SetPoint("RIGHT", resetBtn, "LEFT", -2, 0)
    editBtn:SetScript("OnClick", function()
        self:ShowEditTraitDialog(trait, index)
    end)
    
    -- Delete button with flat style
    local deleteBtn = self:CreateFlatButton(buttonFrame, "Delete", 50, 22)
    deleteBtn:SetPoint("RIGHT", editBtn, "LEFT", -2, 0)
    deleteBtn:SetScript("OnClick", function()
        -- Confirm dialog
        StaticPopupDialogs["CE_DELETE_TRAIT"] = {
            text = "Are you sure you want to delete the trait '" .. trait.name .. "'?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                CE.Database:RemoveTrait(index)
                self:RefreshTraits()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("CE_DELETE_TRAIT")
    end)
    
    -- Hover effect for frame
    frame:SetScript("OnEnter", function()
        frame:SetBackdropBorderColor(0.5, 0.12, 0.18, 1) -- Burgundy highlight
        name:SetTextColor(0.95, 0.92, 0.85) -- Brighter pale gold
    end)
    
    frame:SetScript("OnLeave", function()
        frame:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Back to dark silver
        name:SetTextColor(0.85, 0.82, 0.75) -- Back to pale gold
    end)
    
    return frame
end

function TraitsPanel:UseTrait(index)
    local traits = CE.Database:GetTraits()
    local trait = traits[index]
    
    if trait and trait.currentUses > 0 then
        trait.currentUses = trait.currentUses - 1
        CE.Database:UpdateTrait(index, trait)
        
        -- Send trait usage with full details
        CE.Communication:SendTraitUsage(trait)
        
        self:RefreshTraits()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r This trait has no uses remaining!")
    end
end