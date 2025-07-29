local _, CE = ...

local MainFrame = {}
CE.UI = CE.UI or {}
CE.UI.MainFrame = MainFrame

-- Minimum and maximum sizes for resizing
local MIN_WIDTH = 600
local MIN_HEIGHT = 400
local MAX_WIDTH = 1200
local MAX_HEIGHT = 800

function MainFrame:Initialize()
    self.frame = CreateFrame("Frame", "CE_MainFrame", UIParent, "BackdropTemplate")
    self.frame:SetSize(900, 600)
    self.frame:SetPoint("CENTER")
    
    -- Frame properties
    self.frame:SetMovable(true)
    self.frame:SetResizable(true)
    self.frame:SetClampedToScreen(true)
    self.frame:SetFrameStrata("MEDIUM")
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)
    self.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
    end)

    -- Set resize bounds with fallback
    if self.frame.SetResizeBounds then
        self.frame:SetResizeBounds(950, 650, 1500, 950)
    else
        -- Fallback for older clients
        self.frame:SetMinResize(950, 650)
        self.frame:SetMaxResize(1500, 950)
    end
    
    -- Dark obsidian background with silver border
    self.frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 256,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self.frame:SetBackdropColor(0.02, 0.02, 0.03, 0.98) -- Nearly black
    self.frame:SetBackdropBorderColor(0.6, 0.6, 0.65, 0.9) -- Pale silver
    
    -- Create resize button with silver tint
    local resizeButton = CreateFrame("Button", nil, self.frame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -6, 7)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:GetNormalTexture():SetVertexColor(0.5, 0.5, 0.55) -- Silver tint
    resizeButton:GetHighlightTexture():SetVertexColor(0.7, 0.65, 0.5) -- Pale gold highlight
    resizeButton:SetScript("OnMouseDown", function()
        self.frame:StartSizing("BOTTOMRIGHT")
    end)
    resizeButton:SetScript("OnMouseUp", function()
        self.frame:StopMovingOrSizing()
        self:SavePosition()
    end)
    
    -- Create all UI elements
    self:CreateHeader()
    self:CreateTabButtons()
    self:CreateContentArea()
    
    -- Initialize panels after frames exist
    C_Timer.After(0, function()
        if CE.UI.AttributesPanel then
            CE.UI.AttributesPanel:Initialize(self.attributesFrame)
        end
        if CE.UI.DicePanel then
            CE.UI.DicePanel:Initialize(self.diceFrame)
        end
        if CE.UI.TraitsPanel then
            CE.UI.TraitsPanel:Initialize(self.traitsFrame)
        end
        if CE.UI.DefensePanel then
            CE.UI.DefensePanel:Initialize(self.defenseFrame)
        end
        if CE.UI.ConfigPanel then
            CE.UI.ConfigPanel:Initialize(self.configFrame)
        end
        if CE.UI.CharacterSheetPanel then
            CE.UI.CharacterSheetPanel:Initialize(self.characterSheetFrame)
        end
        
        self:SelectTab(1)
    end)
    
    -- Dragging
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(frame) 
        frame:StartMoving() 
    end)
    self.frame:SetScript("OnDragStop", function(frame) 
        frame:StopMovingOrSizing()
        self:SavePosition()
    end)
    
    -- Handle resize events
    self.frame:SetScript("OnSizeChanged", function()
        self:OnResize()
    end)
end

function MainFrame:CreateHeader()
    -- Dark metallic header background
    local header = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    header:SetHeight(85)
    header:SetPoint("TOPLEFT", 15, -15)
    header:SetPoint("TOPRIGHT", -15, -15)
    header:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    header:SetBackdropColor(0.08, 0.08, 0.1, 0.95) -- Very dark grey-blue
    header:SetBackdropBorderColor(0.3, 0.25, 0.35, 1) -- Dark purple-grey border
    
    -- Burgundy accent strip at top
    local accentStrip = header:CreateTexture(nil, "ARTWORK")
    accentStrip:SetHeight(3)
    accentStrip:SetPoint("TOPLEFT", 1, -1)
    accentStrip:SetPoint("TOPRIGHT", -1, -1)
    accentStrip:SetColorTexture(0.4, 0.1, 0.15, 0.9) -- Burgundy
    
    -- Decorative corners with pale gold
    local cornerTL = header:CreateTexture(nil, "OVERLAY")
    cornerTL:SetSize(32, 32)
    cornerTL:SetPoint("TOPLEFT", -5, 5)
    cornerTL:SetTexture("Interface\\Artifacts\\Artifacts-PerkRing-Final-Mask")
    cornerTL:SetVertexColor(0.65, 0.6, 0.45, 0.6) -- Pale gold, subdued
    
    local cornerTR = header:CreateTexture(nil, "OVERLAY")
    cornerTR:SetSize(32, 32)
    cornerTR:SetPoint("TOPRIGHT", 5, 5)
    cornerTR:SetTexture("Interface\\Artifacts\\Artifacts-PerkRing-Final-Mask")
    cornerTR:SetTexCoord(1, 0, 0, 1)
    cornerTR:SetVertexColor(0.65, 0.6, 0.45, 0.6) -- Pale gold, subdued
    
    -- Dark shield emblem background
    local emblemBg = header:CreateTexture(nil, "BACKGROUND")
    emblemBg:SetSize(70, 70)
    emblemBg:SetPoint("LEFT", 10, 0)
    emblemBg:SetTexture("Interface\\Achievements\\UI-Achievement-IconFrame")
    emblemBg:SetVertexColor(0.15, 0.15, 0.18, 0.9) -- Dark grey-blue
    
    -- Icon with burgundy glow
    local iconGlow = header:CreateTexture(nil, "ARTWORK", nil, -1)
    iconGlow:SetSize(56, 56)
    iconGlow:SetPoint("CENTER", emblemBg, "CENTER", 0, -2)
    iconGlow:SetTexture("Interface\\Cooldown\\star4")
    iconGlow:SetVertexColor(0.4, 0.1, 0.15, 0.3) -- Burgundy glow
    iconGlow:SetBlendMode("ADD")
    
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(46, 46)
    icon:SetPoint("CENTER", emblemBg, "CENTER", 0, -2)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetVertexColor(0.85, 0.85, 0.9) -- Slightly bluish silver
    
    -- Title with silver gradient effect
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", emblemBg, "RIGHT", 15, 12)
    local font, size = title:GetFont()
    title:SetFont(font, 24, "THICKOUTLINE")
    title:SetText("CONFLICT ENGINE")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold-silver
    title:SetShadowOffset(3, -3)
    title:SetShadowColor(0, 0, 0, 1)
    
    -- Subtitle with darker silver
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("LEFT", emblemBg, "RIGHT", 15, -10)
    subtitle:SetText("Advanced Roleplaying System")
    subtitle:SetTextColor(0.55, 0.55, 0.6) -- Muted silver
    
    -- Separator line with burgundy accent
    local separator = header:CreateTexture(nil, "ARTWORK")
    separator:SetHeight(1)
    separator:SetPoint("BOTTOMLEFT", 20, 8)
    separator:SetPoint("BOTTOMRIGHT", -20, 8)
    separator:SetColorTexture(0.35, 0.08, 0.12, 0.6) -- Burgundy line
    
    -- Close button with custom dark style
    local closeBtn = CreateFrame("Button", nil, self.frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", 2, 2)
    closeBtn:GetNormalTexture():SetVertexColor(0.6, 0.6, 0.65) -- Silver
    closeBtn:GetHighlightTexture():SetVertexColor(0.85, 0.82, 0.75) -- Pale gold highlight
    closeBtn:SetScript("OnClick", function()
        self:Hide()
    end)
    
    -- Currency display
    if CE.UI.CurrencyDisplay then
        CE.UI.CurrencyDisplay:Initialize(header)
    end
    
    self.header = header
end

function MainFrame:CreateTabButtons()
    -- Tab bar with dark metallic background
    local tabBar = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    tabBar:SetHeight(40)
    tabBar:SetPoint("TOPLEFT", 15, -105)
    tabBar:SetPoint("TOPRIGHT", -15, -105)
    tabBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true,
        tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    tabBar:SetBackdropColor(0.05, 0.05, 0.07, 0.95) -- Nearly black
    tabBar:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver border
    
    self.tabData = {
        { id = 1, name = "Attributes", icon = "Interface\\Icons\\Spell_Holy_WordFortitude" },
        { id = 2, name = "Dice", icon = "Interface\\Icons\\INV_Misc_Dice_01" },
        { id = 3, name = "Traits", icon = "Interface\\Icons\\INV_Misc_Book_07" },
        { id = 4, name = "Defense", icon = "Interface\\Icons\\INV_Shield_04" },
        { id = 5, name = "Character", icon = "Interface\\Icons\\INV_Misc_Book_11" },
        { id = 6, name = "Settings", icon = "Interface\\Icons\\Trade_Engineering" }
    }
    
    self.tabs = {}
    self.tabBar = tabBar
    
    for i, data in ipairs(self.tabData) do
        local tab = self:CreateTab(tabBar, data, i)
        self.tabs[data.id] = tab
    end
end

function MainFrame:CreateTab(parent, data, index)
    local tab = CreateFrame("Button", nil, parent)
    tab:SetSize(140, 36)

    -- Background texture (unselected) - dark with subtle texture
    tab.bg = tab:CreateTexture(nil, "BACKGROUND")
    tab.bg:SetAllPoints()
    tab.bg:SetColorTexture(0.12, 0.12, 0.15, 0.4) -- Dark grey-blue
    tab.bg:Hide()

    -- Selected background - burgundy accent
    tab.selectedBg = tab:CreateTexture(nil, "BACKGROUND", nil, 1)
    tab.selectedBg:SetPoint("BOTTOMLEFT", 4, 2)
    tab.selectedBg:SetPoint("BOTTOMRIGHT", -4, 2)
    tab.selectedBg:SetHeight(2)
    tab.selectedBg:SetColorTexture(0.5, 0.12, 0.18, 0.9) -- Burgundy underline
    tab.selectedBg:Hide()

    -- Icon border with dark silver
    local iconBorder = tab:CreateTexture(nil, "ARTWORK")
    iconBorder:SetSize(28, 28)
    iconBorder:SetPoint("LEFT", 10, 0)
    iconBorder:SetTexture("Interface\\Common\\RingBorder")
    iconBorder:SetVertexColor(0.3, 0.3, 0.35) -- Dark silver

    -- Icon
    tab.icon = tab:CreateTexture(nil, "ARTWORK", nil, 1)
    tab.icon:SetSize(20, 20)
    tab.icon:SetPoint("CENTER", iconBorder)
    tab.icon:SetTexture(data.icon)
    tab.icon:SetVertexColor(0.5, 0.5, 0.55) -- Muted silver

    -- Text
    tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tab.text:SetPoint("LEFT", iconBorder, "RIGHT", 8, 1)
    tab.text:SetJustifyH("LEFT")
    tab.text:SetWidth(100)
    tab.text:SetText(data.name)
    tab.text:SetTextColor(0.6, 0.6, 0.65) -- Silver-grey

    -- Hover
    tab:SetScript("OnEnter", function()
        if not tab.isSelected then
            tab.bg:Show()
            tab.text:SetTextColor(0.85, 0.82, 0.75) -- Pale gold on hover
            tab.icon:SetVertexColor(0.7, 0.65, 0.5) -- Pale gold tint
        end
    end)

    tab:SetScript("OnLeave", function()
        if not tab.isSelected then
            tab.bg:Hide()
            tab.text:SetTextColor(0.6, 0.6, 0.65) -- Back to silver
            tab.icon:SetVertexColor(0.5, 0.5, 0.55) -- Back to silver
        end
    end)

    tab:SetScript("OnClick", function()
        self:SelectTab(data.id)
    end)

    tab.id = data.id
    return tab
end

function MainFrame:CreateContentArea()
    -- Main content with dark background
    local content = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    content:SetPoint("TOPLEFT", 15, -150)
    content:SetPoint("BOTTOMRIGHT", -15, 15)
    content:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 256,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    content:SetBackdropColor(0.02, 0.02, 0.03, 0.95) -- Nearly black
    content:SetBackdropBorderColor(0.25, 0.22, 0.28, 0.8) -- Dark purple-grey
    
    -- Subtle inner glow
    local innerGlow = content:CreateTexture(nil, "BACKGROUND", nil, 1)
    innerGlow:SetPoint("TOPLEFT", 4, -4)
    innerGlow:SetPoint("BOTTOMRIGHT", -4, 4)
    innerGlow:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    innerGlow:SetVertexColor(0.15, 0.12, 0.18, 0.2) -- Very subtle purple glow
    innerGlow:SetBlendMode("ADD")
    
    -- Content frames
    self.attributesFrame = CreateFrame("Frame", nil, content)
    self.attributesFrame:SetPoint("TOPLEFT", 10, -10)
    self.attributesFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    self.attributesFrame:Hide()
    
    self.diceFrame = CreateFrame("Frame", nil, content)
    self.diceFrame:SetPoint("TOPLEFT", 10, -10)
    self.diceFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    self.diceFrame:Hide()
    
    self.traitsFrame = CreateFrame("Frame", nil, content)
    self.traitsFrame:SetPoint("TOPLEFT", 10, -10)
    self.traitsFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    self.traitsFrame:Hide()
    
    self.defenseFrame = CreateFrame("Frame", nil, content)
    self.defenseFrame:SetPoint("TOPLEFT", 10, -10)
    self.defenseFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    self.defenseFrame:Hide()
    
    self.characterSheetFrame = CreateFrame("Frame", nil, content)
    self.characterSheetFrame:SetPoint("TOPLEFT", 10, -10)
    self.characterSheetFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    self.characterSheetFrame:Hide()
    
    self.configFrame = CreateFrame("Frame", nil, content)
    self.configFrame:SetPoint("TOPLEFT", 10, -10)
    self.configFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    self.configFrame:Hide()
    
    self.contentFrame = content
end

function MainFrame:SelectTab(id)
    -- Hide all content
    self.attributesFrame:Hide()
    self.diceFrame:Hide()
    self.traitsFrame:Hide()
    self.defenseFrame:Hide()
    self.characterSheetFrame:Hide()
    self.configFrame:Hide()
    
    -- Update tabs
    for tabId, tab in pairs(self.tabs) do
        if tabId == id then
            tab.isSelected = true
            tab.selectedBg:Show()
            tab.bg:Hide()
            tab.text:SetTextColor(0.95, 0.92, 0.85) -- Bright pale gold when selected
            tab.icon:SetVertexColor(0.85, 0.8, 0.65) -- Pale gold
            
            -- Add subtle glow to selected icon
            if not tab.iconGlow then
                tab.iconGlow = tab:CreateTexture(nil, "ARTWORK", nil, -1)
                tab.iconGlow:SetSize(32, 32)
                tab.iconGlow:SetPoint("CENTER", tab.icon)
                tab.iconGlow:SetTexture("Interface\\Cooldown\\star4")
                tab.iconGlow:SetBlendMode("ADD")
            end
            tab.iconGlow:SetVertexColor(0.5, 0.12, 0.18, 0.4) -- Burgundy glow
            tab.iconGlow:Show()
        else
            tab.isSelected = false
            tab.selectedBg:Hide()
            tab.bg:Hide()
            tab.text:SetTextColor(0.6, 0.6, 0.65) -- Silver when not selected
            tab.icon:SetVertexColor(0.5, 0.5, 0.55) -- Silver
            if tab.iconGlow then
                tab.iconGlow:Hide()
            end
        end
    end
    
    -- Show selected
    if id == 1 then
        self.attributesFrame:Show()
    elseif id == 2 then
        self.diceFrame:Show()
    elseif id == 3 then
        self.traitsFrame:Show()
    elseif id == 4 then
        self.defenseFrame:Show()
    elseif id == 5 then
        self.characterSheetFrame:Show()
    elseif id == 6 then
        self.configFrame:Show()
    end
    
    self.selectedTab = id
end

function MainFrame:OnResize()
    if self.tabBar and self.tabs then
        local tabWidth = 140         -- Matches your tab:SetSize
        local padding = 10           -- Space between tabs
        local count = #self.tabData

        -- Total width = all tabs + gaps between them
        local totalWidth = (tabWidth * count) + (padding * (count - 1))
        local barWidth = self.tabBar:GetWidth()

        -- Ensure it's centered, but clamp to avoid negative positioning
        local startX = math.max(10, math.floor((barWidth - totalWidth) / 2))

        for i, data in ipairs(self.tabData) do
            local tab = self.tabs[data.id]
            if tab then
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", self.tabBar, "TOPLEFT", startX + (i - 1) * (tabWidth + padding), 0)
            end
        end
    end
end

function MainFrame:Show()
    self.frame:Show()
    self:OnResize() -- Ensure tabs are positioned correctly
end

function MainFrame:Hide()
    self.frame:Hide()
end

function MainFrame:Toggle()
    if self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function MainFrame:SavePosition()
    local point, _, relPoint, x, y = self.frame:GetPoint()
    local width, height = self.frame:GetSize()
    
    if CE.Database and CE.Database.db and CE.Database.db.char then
        CE.Database.db.char.ui = CE.Database.db.char.ui or {}
        CE.Database.db.char.ui.position = {
            point = point,
            relPoint = relPoint,
            x = x,
            y = y,
            width = width,
            height = height
        }
    end
end

function MainFrame:LoadPosition()
    if CE.Database and CE.Database.db and CE.Database.db.char then
        local pos = CE.Database.db.char.ui and CE.Database.db.char.ui.position
        if pos then
            if pos.point then
                self.frame:ClearAllPoints()
                self.frame:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
            end
            if pos.width and pos.height then
                self.frame:SetSize(pos.width, pos.height)
            end
        end
    end
end