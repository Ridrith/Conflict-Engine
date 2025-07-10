local _, CE = ...

local MainFrame = {}
CE.UI = CE.UI or {}
CE.UI.MainFrame = MainFrame

function MainFrame:Initialize()
    -- Make sure frame exists with BackdropTemplate
    if not CE_MainFrame then
        -- Create frame with BackdropTemplate mixin
        local frame = CreateFrame("Frame", "CE_MainFrame", UIParent, "BackdropTemplate")
        frame:SetSize(900, 600)
        frame:SetPoint("CENTER")
        frame:Hide()
    end
    
    self.frame = CE_MainFrame
    
    -- Clear any existing points first
    self.frame:ClearAllPoints()
    
    -- Set frame properties
    self.frame:SetSize(900, 600)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.frame:SetMovable(true)
    self.frame:SetClampedToScreen(true)
    self.frame:SetFrameStrata("MEDIUM")
    self.frame:SetFrameLevel(1)
    
    -- Main backdrop
    self.frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self.frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    self.frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Create all UI elements
    self:CreateHeader()
    self:CreateTabButtons()
    self:CreateContentFrames()
    
    -- Initialize panels AFTER content frames are created
    C_Timer.After(0, function()
        CE.UI.AttributesPanel:Initialize(self.attributesFrame)
        CE.UI.DicePanel:Initialize(self.diceFrame)
        CE.UI.TraitsPanel:Initialize(self.traitsFrame)
        CE.UI.DefensePanel:Initialize(self.defenseFrame)
        CE.UI.ConfigPanel:Initialize(self.configFrame)
        
        -- Show first tab
        self:SelectTab(1)
    end)
    
    -- Make draggable
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(frame) 
        frame:StartMoving() 
    end)
    self.frame:SetScript("OnDragStop", function(frame) 
        frame:StopMovingOrSizing()
        self:SavePosition()
    end)
end

function MainFrame:CreateHeader()
    -- Header container
    local header = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    header:SetHeight(70)
    header:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -10)
    header:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -10, -10)
    header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    header:SetBackdropColor(0.05, 0.05, 0.05, 1)
    header:SetBackdropBorderColor(0.6, 0.5, 0.2, 1)
    
    -- Logo background
    local logoBg = header:CreateTexture(nil, "BACKGROUND")
    logoBg:SetSize(60, 60)
    logoBg:SetPoint("LEFT", header, "LEFT", 5, 0)
    logoBg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Logo
    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(50, 50)
    logo:SetPoint("CENTER", logoBg, "CENTER", 0, 0)
    logo:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    
    -- Logo border
    local logoBorder = header:CreateTexture(nil, "OVERLAY")
    logoBorder:SetSize(64, 64)
    logoBorder:SetPoint("CENTER", logo, "CENTER", 0, 0)
    logoBorder:SetAtlas("talents-node-choiceflyout-square")
    logoBorder:SetVertexColor(0.8, 0.6, 0.2)
    
    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logoBg, "RIGHT", 15, 10)
    local titleFont = {title:GetFont()}
    title:SetFont(titleFont[1], 22, "OUTLINE")
    title:SetText("CONFLICT ENGINE")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Subtitle
    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("LEFT", logoBg, "RIGHT", 15, -10)
    subtitle:SetText("Advanced Roleplaying System")
    subtitle:SetTextColor(0.6, 0.6, 0.6)
    
    -- Version
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -10, 5)
    version:SetText("v1.0.0")
    version:SetTextColor(0.4, 0.4, 0.4)
    
    -- Fixed close button to close entire frame
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", 5, 5)
    closeBtn:SetSize(30, 30)
    closeBtn:SetScript("OnClick", function()
        self.frame:Hide()  -- Hide the entire frame, not just the header
    end)
    
    -- Currency display
    CE.UI.CurrencyDisplay:Initialize(header)
    
    self.header = header
end

function MainFrame:CreateTabButtons()
    -- Tab container
    local tabContainer = CreateFrame("Frame", nil, self.frame)
    tabContainer:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -85)
    tabContainer:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -10, -85)
    tabContainer:SetHeight(35)
    
    -- Tab data - added Config tab
    self.tabData = {
        {
            id = 1,
            name = "Attributes",
            icon = "Interface\\Icons\\Spell_Holy_WordFortitude"
        },
        {
            id = 2,
            name = "Dice Roller",
            icon = "Interface\\Icons\\INV_Misc_Dice_01"
        },
        {
            id = 3,
            name = "Traits",
            icon = "Interface\\Icons\\INV_Misc_Book_07"
        },
        {
            id = 4,
            name = "Defense",
            icon = "Interface\\Icons\\INV_Shield_04"
        },
        {
            id = 5,
            name = "Config",
            icon = "Interface\\Icons\\Trade_Engineering"
        }
    }
    
    self.tabs = {}
    
    -- Create tabs
    for i, data in ipairs(self.tabData) do
        local tab = self:CreateTab(tabContainer, data, i)
        self.tabs[data.id] = tab
    end
end

function MainFrame:CreateTab(parent, data, index)
    local tab = CreateFrame("Button", nil, parent)
    tab:SetSize(140, 35)  -- Slightly smaller to fit 5 tabs
    tab:SetPoint("LEFT", parent, "LEFT", (index - 1) * 145, 0)
    
    -- Tab background
    tab.bg = tab:CreateTexture(nil, "BACKGROUND")
    tab.bg:SetAllPoints()
    tab.bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
    
    -- Selected glow
    tab.selectedGlow = tab:CreateTexture(nil, "BACKGROUND", nil, 1)
    tab.selectedGlow:SetPoint("TOPLEFT", tab, "TOPLEFT", -2, 2)
    tab.selectedGlow:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 2, -2)
    tab.selectedGlow:SetColorTexture(0.8, 0.6, 0.2, 0.2)
    tab.selectedGlow:Hide()
    
    -- Border
    tab.border = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    tab.border:SetAllPoints()
    tab.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
    })
    tab.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Selected indicator
    tab.selectedBar = tab:CreateTexture(nil, "ARTWORK")
    tab.selectedBar:SetHeight(3)
    tab.selectedBar:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 4, 0)
    tab.selectedBar:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -4, 0)
    tab.selectedBar:SetColorTexture(0.8, 0.6, 0.2, 1)
    tab.selectedBar:Hide()
    
    -- Icon
    tab.icon = tab:CreateTexture(nil, "ARTWORK")
    tab.icon:SetSize(20, 20)
    tab.icon:SetPoint("LEFT", tab, "LEFT", 10, 0)
    tab.icon:SetTexture(data.icon)
    
    -- Text
    tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tab.text:SetPoint("LEFT", tab.icon, "RIGHT", 8, 0)
    tab.text:SetText(data.name)
    
    -- Hover effect
    tab:SetScript("OnEnter", function()
        if not tab.isSelected then
            tab.bg:SetColorTexture(0.2, 0.2, 0.2, 0.9)
            tab.border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        end
    end)
    
    tab:SetScript("OnLeave", function()
        if not tab.isSelected then
            tab.bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
            tab.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        end
    end)
    
    -- Click handler
    tab:SetScript("OnClick", function()
        self:SelectTab(data.id)
    end)
    
    tab.id = data.id
    return tab
end

function MainFrame:CreateContentFrames()
    -- Main content area
    local content = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    content:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -125)
    content:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -10, 10)
    content:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    content:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    content:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Create individual content frames for each tab
    self.attributesFrame = CreateFrame("Frame", nil, content)
    self.attributesFrame:SetAllPoints(content)
    self.attributesFrame:Hide()
    
    self.diceFrame = CreateFrame("Frame", nil, content)
    self.diceFrame:SetAllPoints(content)
    self.diceFrame:Hide()
    
    self.traitsFrame = CreateFrame("Frame", nil, content)
    self.traitsFrame:SetAllPoints(content)
    self.traitsFrame:Hide()
    
    self.defenseFrame = CreateFrame("Frame", nil, content)
    self.defenseFrame:SetAllPoints(content)
    self.defenseFrame:Hide()
    
    self.configFrame = CreateFrame("Frame", nil, content)
    self.configFrame:SetAllPoints(content)
    self.configFrame:Hide()
    
    self.contentFrame = content
end

function MainFrame:SelectTab(id)
    -- Hide all content frames
    self.attributesFrame:Hide()
    self.diceFrame:Hide()
    self.traitsFrame:Hide()
    self.defenseFrame:Hide()
    self.configFrame:Hide()
    
    -- Update tab appearance
    for tabId, tab in pairs(self.tabs) do
        if tabId == id then
            tab.isSelected = true
            tab.selectedGlow:Show()
            tab.selectedBar:Show()
            tab.bg:SetColorTexture(0.2, 0.2, 0.2, 1)
            tab.border:SetBackdropBorderColor(0.8, 0.6, 0.2, 1)
            tab.text:SetTextColor(0.9, 0.75, 0.3)
        else
            tab.isSelected = false
            tab.selectedGlow:Hide()
            tab.selectedBar:Hide()
            tab.bg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
            tab.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
            tab.text:SetTextColor(0.7, 0.7, 0.7)
        end
    end
    
    -- Show selected content
    if id == 1 then
        self.attributesFrame:Show()
    elseif id == 2 then
        self.diceFrame:Show()
    elseif id == 3 then
        self.traitsFrame:Show()
    elseif id == 4 then
        self.defenseFrame:Show()
    elseif id == 5 then
        self.configFrame:Show()
    end
    
    self.selectedTab = id
end

function MainFrame:Show()
    self.frame:Show()
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
    
    if CE.Database.db and CE.Database.db.char then
        CE.Database.db.char.ui.position = {
            point = point,
            relPoint = relPoint,
            x = x,
            y = y
        }
    end
end

function MainFrame:LoadPosition()
    if CE.Database.db and CE.Database.db.char then
        local pos = CE.Database.db.char.ui.position
        if pos and pos.point then
            self.frame:ClearAllPoints()
            self.frame:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
        end
    end
end