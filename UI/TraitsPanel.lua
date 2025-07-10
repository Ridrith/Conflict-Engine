local _, CE = ...

local TraitsPanel = {}
CE.UI = CE.UI or {}
CE.UI.TraitsPanel = TraitsPanel

function TraitsPanel:Initialize(parent)
    if not parent then return end
    
    self.parent = parent
    self.traitFrames = {}
    
    -- Title with character name
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("CHARACTER TRAITS")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Character name display
    local charName = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    charName:SetPoint("TOP", title, "BOTTOM", 0, -2)
    charName:SetText(CE.Database:GetCurrentCharacter())
    charName:SetTextColor(0.6, 0.6, 0.6)
    self.charNameText = charName
    
    -- Add trait button
    local addBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    addBtn:SetSize(100, 25)
    addBtn:SetPoint("TOPRIGHT", -20, -10)
    addBtn:SetText("Add Trait")
    addBtn:SetScript("OnClick", function()
        self:ShowAddTraitDialog()
    end)
    
    -- Traits scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 20)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(800, 1)
    scrollFrame:SetScrollChild(content)
    
    self.scrollContent = content
    self:RefreshTraits()
end

function TraitsPanel:ShowAddTraitDialog()
    if self.addDialog then
        self.addDialog:Show()
        return
    end
    
    -- Create dialog
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
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Title
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("Add New Trait")
    
    -- Name input
    local nameLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", 30, -50)
    nameLabel:SetText("Name:")
    
    local nameInput = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    nameInput:SetSize(200, 25)
    nameInput:SetPoint("LEFT", nameLabel, "RIGHT", 20, 0)
    nameInput:SetMaxLetters(30)
    nameInput:SetAutoFocus(true)
    
    -- Uses input
    local usesLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    usesLabel:SetPoint("TOPLEFT", 30, -80)
    usesLabel:SetText("Uses/Round:")
    
    local usesInput = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    usesInput:SetSize(50, 25)
    usesInput:SetPoint("LEFT", usesLabel, "RIGHT", 20, 0)
    usesInput:SetNumeric(true)
    usesInput:SetMaxLetters(3)
    usesInput:SetText("1")
    
    -- Description
    local descLabel = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descLabel:SetPoint("TOPLEFT", 30, -110)
    descLabel:SetText("Description:")
    
    -- Description scroll frame
    local descScroll = CreateFrame("ScrollFrame", nil, dialog, "InputScrollFrameTemplate")
    descScroll:SetSize(280, 60)
    descScroll:SetPoint("TOPLEFT", 30, -130)
    
    local descInput = descScroll.EditBox
    descInput:SetMaxLetters(200)
    descInput:SetWidth(280)
    
    -- Buttons
    local addBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    addBtn:SetSize(80, 25)
    addBtn:SetPoint("BOTTOMLEFT", 50, 20)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local name = nameInput:GetText()
        local uses = tonumber(usesInput:GetText()) or 1
        local desc = descInput:GetText()
        
        if name and name ~= "" then
            CE.Database:AddTrait({
                name = name,
                maxUses = uses,
                currentUses = uses,
                description = desc
            })
            self:RefreshTraits()
            dialog:Hide()
            
            -- Clear fields
            nameInput:SetText("")
            usesInput:SetText("1")
            descInput:SetText("")
        end
    end)
    
    local cancelBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 25)
    cancelBtn:SetPoint("BOTTOMRIGHT", -50, 20)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    
    self.addDialog = dialog
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
        yOffset = yOffset - 90
    end
    
    -- Update scroll frame height
    self.scrollContent:SetHeight(math.abs(yOffset) + 20)
end

function TraitsPanel:CreateTraitFrame(parent, trait, index)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetHeight(80)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Name
    local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", 10, -10)
    name:SetText(trait.name)
    name:SetTextColor(0.9, 0.75, 0.3)
    
    -- Uses
    local uses = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    uses:SetPoint("TOPRIGHT", -10, -10)
    uses:SetText(string.format("Uses: %d/%d", trait.currentUses or trait.maxUses, trait.maxUses))
    
    -- Update uses color based on remaining
    if trait.currentUses == 0 then
        uses:SetTextColor(0.8, 0.2, 0.2)
    elseif trait.currentUses <= trait.maxUses / 2 then
        uses:SetTextColor(0.9, 0.9, 0.2)
    else
        uses:SetTextColor(0.2, 0.8, 0.2)
    end
    
    -- Description
    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    desc:SetPoint("TOPLEFT", 10, -30)
    desc:SetPoint("RIGHT", -100, 0)
    desc:SetJustifyH("LEFT")
    desc:SetText(trait.description)
    desc:SetTextColor(0.7, 0.7, 0.7)
    
    -- Use button
    local useBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    useBtn:SetSize(50, 22)
    useBtn:SetPoint("BOTTOMRIGHT", -60, 8)
    useBtn:SetText("Use")
    useBtn:SetEnabled(trait.currentUses > 0)
    useBtn:SetScript("OnClick", function()
        self:UseTrait(index)
    end)
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetBtn:SetSize(22, 22)
    resetBtn:SetPoint("RIGHT", useBtn, "LEFT", -2, 0)
    resetBtn:SetText("R")
    resetBtn:SetScript("OnClick", function()
        trait.currentUses = trait.maxUses
        CE.Database:UpdateTrait(index, trait)
        self:RefreshTraits()
    end)
    
    -- Delete button
    local deleteBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    deleteBtn:SetSize(50, 22)
    deleteBtn:SetPoint("BOTTOMRIGHT", -5, 8)
    deleteBtn:SetText("Delete")
    deleteBtn:SetScript("OnClick", function()
        CE.Database:RemoveTrait(index)
        self:RefreshTraits()
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
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[Conflict Engine]|r This trait has no uses remaining!")
    end
end