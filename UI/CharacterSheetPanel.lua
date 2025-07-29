local _, CE = ...

local CharacterSheetPanel = {}
CE.UI = CE.UI or {}
CE.UI.CharacterSheetPanel = CharacterSheetPanel

function CharacterSheetPanel:Initialize(parent)
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
    title:SetText("CHARACTER SHEET")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)
    
    -- Decorative divider with dark silver
    if CE.Style and CE.Style.CreateDivider then
        local divider = CE.Style:CreateDivider(parent, 300)
        divider:SetPoint("TOP", title, "BOTTOM", 0, -5)
        divider:SetVertexColor(0.35, 0.35, 0.4, 0.6) -- Dark silver
    end
    
    -- Create sections
    self:CreateAttributesSection()
    self:CreateStrikesSection()
    self:CreateCharacterInfoSection()
    
    -- Register for attribute updates
    if CE.Communication then
        CE.Communication:RegisterCallback("ATTRIBUTE_CHANGED", function()
            self:UpdateAllDisplays()
        end)
    end
    
    -- Initial update
    self:UpdateAllDisplays()
end

function CharacterSheetPanel:CreateFlatButton(parent, text, width, height)
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
    btn:SetScript("OnEnter", function(self)
        self.bg:SetVertexColor(0.15, 0.04, 0.06, 0.9) -- Dark burgundy
        self.border:SetBackdropBorderColor(0.5, 0.12, 0.18, 1) -- Burgundy
        self.text:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    end)
    
    btn:SetScript("OnLeave", function(self)
        self.bg:SetVertexColor(0.08, 0.08, 0.1, 0.9)
        self.border:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
        self.text:SetTextColor(0.65, 0.65, 0.7)
    end)
    
    btn:SetScript("OnMouseDown", function(self)
        self.text:SetPoint("CENTER", 1, -1)
    end)
    
    btn:SetScript("OnMouseUp", function(self)
        self.text:SetPoint("CENTER", 0, 0)
    end)
    
    return btn
end

function CharacterSheetPanel:CreateEditBox(parent, width, height, placeholder)
    local panelRef = self -- Store reference to the panel
    
    local inputBg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    inputBg:SetSize(width, height)
    inputBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    inputBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    inputBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local input = CreateFrame("EditBox", nil, inputBg)
    input:SetPoint("TOPLEFT", 5, -2)
    input:SetPoint("BOTTOMRIGHT", -5, 2)
    input:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    input:SetTextColor(0.85, 0.82, 0.75)
    input:SetAutoFocus(false)
    
    if placeholder then
        input:SetText(placeholder)
    end
    
    -- Focus border effects
    input:SetScript("OnEditFocusGained", function(self)
        inputBg:SetBackdropBorderColor(0.5, 0.12, 0.18, 1) -- Burgundy
        if self:GetText() == placeholder then
            self:SetText("")
        end
    end)
    
    input:SetScript("OnEditFocusLost", function(self)
        inputBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8) -- Back to dark silver
        if self:GetText() == "" and placeholder then
            self:SetText(placeholder)
        end
        -- Auto-save
        if panelRef.SaveCharacterData then
            panelRef:SaveCharacterData()
        end
    end)
    
    return input, inputBg
end

function CharacterSheetPanel:CreateAttributesSection()
    -- Compact vertical attributes display (left side)
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(150, 400)
    container:SetPoint("TOPLEFT", 20, -70)
    
    if CE.Style and CE.Style.ApplyBackdrop then
        CE.Style:ApplyBackdrop(container, "wood")
    end
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Header with burgundy accent
    local headerBg = container:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(25)
    headerBg:SetPoint("TOPLEFT", 4, -4)
    headerBg:SetPoint("TOPRIGHT", -4, -4)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local headerAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    headerAccent:SetHeight(2)
    headerAccent:SetPoint("BOTTOMLEFT", headerBg, 0, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", headerBg, 0, 0)
    headerAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("CENTER", headerBg, 0, 0)
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 12, "OUTLINE")
    sectionTitle:SetText("Attributes")
    sectionTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Create compact attribute list
    self.attributeFrames = {}
    local yOffset = -35
    
    if CE.Constants and CE.Constants.ATTRIBUTES then
        for i, attrName in ipairs(CE.Constants.ATTRIBUTES) do
            local attrFrame = CreateFrame("Frame", nil, container)
            attrFrame:SetSize(130, 30)
            attrFrame:SetPoint("TOP", 0, yOffset)
            
            -- Attribute name
            local nameText = attrFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameText:SetPoint("LEFT", 10, 0)
            nameText:SetFont("Fonts\\FRIZQT__.ttf", 11, "")
            nameText:SetText(attrName)
            nameText:SetTextColor(0.6, 0.6, 0.65) -- Silver
            
            -- Attribute value
            local valueText = attrFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            valueText:SetPoint("RIGHT", -10, 0)
            valueText:SetFont("Fonts\\FRIZQT__.ttf", 12, "OUTLINE")
            valueText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
            
            -- Store references
            attrFrame.nameText = nameText
            attrFrame.valueText = valueText
            self.attributeFrames[attrName] = attrFrame
            
            yOffset = yOffset - 35
        end
    end
    
    self.attributesContainer = container
end

function CharacterSheetPanel:CreateStrikesSection()
    -- Strikes/Health system (center-left)
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(250, 220)  -- Increased width and height
    container:SetPoint("TOPLEFT", 180, -70)
    
    if CE.Style and CE.Style.ApplyBackdrop then
        CE.Style:ApplyBackdrop(container, "wood")
    end
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Header with burgundy accent
    local headerBg = container:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(25)
    headerBg:SetPoint("TOPLEFT", 4, -4)
    headerBg:SetPoint("TOPRIGHT", -4, -4)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local headerAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    headerAccent:SetHeight(2)
    headerAccent:SetPoint("BOTTOMLEFT", headerBg, 0, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", headerBg, 0, 0)
    headerAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("CENTER", headerBg, 0, 0)
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 12, "OUTLINE")
    sectionTitle:SetText("Strikes")
    sectionTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Current/Max strikes display
    local strikesBg = container:CreateTexture(nil, "ARTWORK")
    strikesBg:SetSize(200, 30)
    strikesBg:SetPoint("TOP", headerBg, "BOTTOM", 0, -10)
    strikesBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    strikesBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip
    
    self.strikesText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.strikesText:SetPoint("CENTER", strikesBg, 0, 0)
    self.strikesText:SetFont("Fonts\\FRIZQT__.ttf", 16, "OUTLINE")
    self.strikesText:SetText("0 / 5")
    self.strikesText:SetTextColor(0.4, 0.85, 0.4) -- Green when healthy
    
    -- Max strikes setting
    local maxStrikesFrame = CreateFrame("Frame", nil, container)
    maxStrikesFrame:SetSize(200, 25)
    maxStrikesFrame:SetPoint("TOP", strikesBg, "BOTTOM", 0, -5)
    
    local maxLabel = maxStrikesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    maxLabel:SetPoint("LEFT", 20, 0)
    maxLabel:SetText("Max Strikes:")
    maxLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    self.maxStrikesInput, self.maxStrikesInputBg = self:CreateEditBox(maxStrikesFrame, 40, 20, "5")
    self.maxStrikesInputBg:SetPoint("LEFT", maxLabel, "RIGHT", 10, 0)
    self.maxStrikesInput:SetNumeric(true)
    self.maxStrikesInput:SetMaxLetters(2)
    self.maxStrikesInput:SetScript("OnTextChanged", function(self)
        local value = tonumber(self:GetText()) or 5
        if value < 1 then value = 1 end
        if value > 10 then value = 10 end
        if value ~= tonumber(self:GetText()) then
            self:SetText(tostring(value))
        end
        CharacterSheetPanel:SaveMaxStrikes(value)
        CharacterSheetPanel:UpdateStrikesDisplay()
    end)
    
    -- Visual strike boxes (10 boxes, arranged in 2 rows)
    self.strikeBoxes = {}
    local boxContainer = CreateFrame("Frame", nil, container)
    boxContainer:SetSize(200, 60)
    boxContainer:SetPoint("TOP", maxStrikesFrame, "BOTTOM", 0, -10)
    
    for i = 1, 10 do
        local box = boxContainer:CreateTexture(nil, "ARTWORK")
        box:SetSize(22, 22)
        
        -- Arrange in 2 rows of 5
        local row = math.floor((i - 1) / 5)
        local col = (i - 1) % 5
        box:SetPoint("TOPLEFT", 25 + col * 30, -row * 28)
        
        box:SetTexture("Interface\\Common\\indicator-gray")
        box:SetVertexColor(0.4, 0.85, 0.4) -- Green for healthy
        self.strikeBoxes[i] = box
    end
    
    -- Buttons for managing strikes
    local buttonContainer = CreateFrame("Frame", nil, container)
    buttonContainer:SetSize(200, 30)
    buttonContainer:SetPoint("BOTTOM", 0, 15)
    
    -- Take strike button
    local takeStrikeBtn = self:CreateFlatButton(buttonContainer, "Take Strike", 75, 25)
    takeStrikeBtn:SetPoint("LEFT", 25, 0)
    takeStrikeBtn:SetScript("OnClick", function()
        self:ModifyStrikes(1)
    end)
    
    -- Heal strike button
    local healStrikeBtn = self:CreateFlatButton(buttonContainer, "Heal Strike", 75, 25)
    healStrikeBtn:SetPoint("RIGHT", -25, 0)
    healStrikeBtn:SetScript("OnClick", function()
        self:ModifyStrikes(-1)
    end)
    
    self.strikesContainer = container
end

function CharacterSheetPanel:CreateCharacterInfoSection()
    -- Character information (right side)
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(350, 350)  -- Adjusted width
    container:SetPoint("TOPRIGHT", -20, -70)
    
    if CE.Style and CE.Style.ApplyBackdrop then
        CE.Style:ApplyBackdrop(container, "wood")
    end
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Header with burgundy accent
    local headerBg = container:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(25)
    headerBg:SetPoint("TOPLEFT", 4, -4)
    headerBg:SetPoint("TOPRIGHT", -4, -4)
    headerBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    headerBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local headerAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    headerAccent:SetHeight(2)
    headerAccent:SetPoint("BOTTOMLEFT", headerBg, 0, 0)
    headerAccent:SetPoint("BOTTOMRIGHT", headerBg, 0, 0)
    headerAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("CENTER", headerBg, 0, 0)
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 12, "OUTLINE")
    sectionTitle:SetText("Character Information")
    sectionTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Character Name
    local nameLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameLabel:SetPoint("TOPLEFT", 15, -40)
    nameLabel:SetText("Name:")
    nameLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    self.nameInput, self.nameInputBg = self:CreateEditBox(container, 150, 20, "Enter character name")
    self.nameInputBg:SetPoint("LEFT", nameLabel, "RIGHT", 10, 0)
    
    -- Character Title
    local titleLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleLabel:SetPoint("TOPLEFT", 15, -70)
    titleLabel:SetText("Title:")
    titleLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    self.titleInput, self.titleInputBg = self:CreateEditBox(container, 150, 20, "Enter title/rank")
    self.titleInputBg:SetPoint("LEFT", titleLabel, "RIGHT", 10, 0)
    
    -- Background/Class
    local backgroundLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    backgroundLabel:SetPoint("TOPLEFT", 15, -100)
    backgroundLabel:SetText("Background:")
    backgroundLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    self.backgroundInput, self.backgroundInputBg = self:CreateEditBox(container, 150, 20, "Enter background")
    self.backgroundInputBg:SetPoint("LEFT", backgroundLabel, "RIGHT", 10, 0)
    
    -- Age and Height (side by side)
    local ageLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ageLabel:SetPoint("TOPLEFT", 15, -130)
    ageLabel:SetText("Age:")
    ageLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    self.ageInput, self.ageInputBg = self:CreateEditBox(container, 60, 20, "25")
    self.ageInputBg:SetPoint("LEFT", ageLabel, "RIGHT", 20, 0)
    
    local heightLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    heightLabel:SetPoint("LEFT", self.ageInputBg, "RIGHT", 20, 0)
    heightLabel:SetText("Height:")
    heightLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    self.heightInput, self.heightInputBg = self:CreateEditBox(container, 60, 20, "6'0\"")
    self.heightInputBg:SetPoint("LEFT", heightLabel, "RIGHT", 10, 0)
    
    -- Notes area
    local notesLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    notesLabel:SetPoint("TOPLEFT", 15, -170)
    notesLabel:SetText("Notes:")
    notesLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    local notesBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
    notesBg:SetSize(310, 120)  -- Adjusted width
    notesBg:SetPoint("TOPLEFT", 15, -190)
    notesBg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    notesBg:SetBackdropColor(0.02, 0.02, 0.03, 0.9)
    notesBg:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
    
    local notesScroll = CreateFrame("ScrollFrame", nil, notesBg, "InputScrollFrameTemplate")
    notesScroll:SetPoint("TOPLEFT", 5, -5)
    notesScroll:SetPoint("BOTTOMRIGHT", -5, 5)
    
    self.notesInput = notesScroll.EditBox
    self.notesInput:SetMaxLetters(500)
    self.notesInput:SetWidth(300)  -- Adjusted width
    self.notesInput:SetFont("Fonts\\FRIZQT__.ttf", 11, "")
    self.notesInput:SetTextColor(0.85, 0.82, 0.75)
    self.notesInput:SetText("Enter character description and notes...")
    
    self.characterInfoContainer = container
end

-- Data management functions
function CharacterSheetPanel:GetCharacterData()
    -- Get character sheet data from database
    if CE.Database and CE.Database.GetCharacterSheet then
        return CE.Database:GetCharacterSheet()
    else
        -- Fallback if database functions aren't available
        return {
            currentStrikes = 0,
            maxStrikes = 5,
            name = "",
            title = "",
            background = "",
            age = "",
            height = "",
            notes = ""
        }
    end
end

function CharacterSheetPanel:SaveCharacterData()
    if not CE.Database or not CE.Database.SetCharacterSheetField then
        return
    end
    
    -- Save all input fields
    if self.nameInput then CE.Database:SetCharacterSheetField("name", self.nameInput:GetText()) end
    if self.titleInput then CE.Database:SetCharacterSheetField("title", self.titleInput:GetText()) end
    if self.backgroundInput then CE.Database:SetCharacterSheetField("background", self.backgroundInput:GetText()) end
    if self.ageInput then CE.Database:SetCharacterSheetField("age", self.ageInput:GetText()) end
    if self.heightInput then CE.Database:SetCharacterSheetField("height", self.heightInput:GetText()) end
    if self.notesInput then CE.Database:SetCharacterSheetField("notes", self.notesInput:GetText()) end
end

function CharacterSheetPanel:SaveMaxStrikes(value)
    if CE.Database and CE.Database.SetCharacterSheetField then
        CE.Database:SetCharacterSheetField("maxStrikes", value)
    end
end

function CharacterSheetPanel:LoadCharacterData()
    local data = self:GetCharacterData()
    
    -- Load all input fields
    if self.nameInput and data.name and data.name ~= "" then 
        self.nameInput:SetText(data.name) 
    end
    if self.titleInput and data.title and data.title ~= "" then 
        self.titleInput:SetText(data.title) 
    end
    if self.backgroundInput and data.background and data.background ~= "" then 
        self.backgroundInput:SetText(data.background) 
    end
    if self.ageInput and data.age and data.age ~= "" then 
        self.ageInput:SetText(data.age) 
    end
    if self.heightInput and data.height and data.height ~= "" then 
        self.heightInput:SetText(data.height) 
    end
    if self.notesInput and data.notes and data.notes ~= "" then 
        self.notesInput:SetText(data.notes) 
    end
    if self.maxStrikesInput and data.maxStrikes then
        self.maxStrikesInput:SetText(tostring(data.maxStrikes))
    end
    
    self:UpdateStrikesDisplay()
end

function CharacterSheetPanel:ModifyStrikes(amount)
    if CE.Database and CE.Database.ModifyStrikes then
        CE.Database:ModifyStrikes(amount)
    end
    self:UpdateStrikesDisplay()
end

function CharacterSheetPanel:UpdateStrikesDisplay()
    local currentStrikes = 0
    local maxStrikes = tonumber(self.maxStrikesInput and self.maxStrikesInput:GetText()) or 5
    
    if CE.Database and CE.Database.GetStrikes then
        currentStrikes = CE.Database:GetStrikes()
    end
    
    -- Update text display
    if self.strikesText then
        self.strikesText:SetText(string.format("%d / %d", currentStrikes, maxStrikes))
        
        -- Color based on health percentage
        local healthPercent = 1 - (currentStrikes / maxStrikes)
        if healthPercent > 0.6 then
            self.strikesText:SetTextColor(0.4, 0.85, 0.4) -- Green (healthy)
        elseif healthPercent > 0.3 then
            self.strikesText:SetTextColor(0.9, 0.7, 0.3) -- Yellow (wounded)
        else
            self.strikesText:SetTextColor(0.8, 0.25, 0.3) -- Red (critical)
        end
    end
    
    -- Update visual boxes
    if self.strikeBoxes then
        for i = 1, 10 do
            if self.strikeBoxes[i] then
                if i <= maxStrikes then
                    -- Show box
                    self.strikeBoxes[i]:Show()
                    if i <= currentStrikes then
                        -- Taken strike (red X)
                        self.strikeBoxes[i]:SetTexture("Interface\\Common\\indicator-red")
                        self.strikeBoxes[i]:SetVertexColor(0.8, 0.25, 0.3)
                    else
                        -- Available health (green)
                        self.strikeBoxes[i]:SetTexture("Interface\\Common\\indicator-green")
                        self.strikeBoxes[i]:SetVertexColor(0.4, 0.85, 0.4)
                    end
                else
                    -- Hide boxes beyond max
                    self.strikeBoxes[i]:Hide()
                end
            end
        end
    end
end

function CharacterSheetPanel:UpdateAllDisplays()
    -- Update attributes display - this will now properly sync with the Attributes panel
    if CE.Constants and CE.Constants.ATTRIBUTES and CE.Database and CE.Database.GetAttribute then
        for _, attrName in ipairs(CE.Constants.ATTRIBUTES) do
            local value = CE.Database:GetAttribute(attrName)
            local frame = self.attributeFrames[attrName]
            if frame then
                local modifierText = value >= 0 and string.format("+%d", value) or tostring(value)
                frame.valueText:SetText(modifierText)
                
                -- Color based on value
                if value <= -2 then
                    frame.valueText:SetTextColor(0.8, 0.25, 0.3) -- Red
                elseif value >= 3 then
                    frame.valueText:SetTextColor(0.4, 0.85, 0.4) -- Green
                else
                    frame.valueText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
                end
            end
        end
    end
    
    -- Update strikes display
    self:UpdateStrikesDisplay()
    
    -- Load character data
    self:LoadCharacterData()
end

-- Simple test function
function CharacterSheetPanel:Test()
    print("|cFF00FF00[CE]|r CharacterSheetPanel loaded successfully!")
    return true
end