local _, CE = ...

CE.Style = {
    -- Colors
    Colors = {
        -- Main theme colors
        Primary = {0.15, 0.15, 0.15, 0.95},      -- Dark background
        Secondary = {0.25, 0.25, 0.25, 0.9},     -- Lighter background
        Accent = {0.8, 0.6, 0.2, 1},             -- Gold accent
        AccentLight = {0.9, 0.7, 0.3, 1},       -- Light gold
        
        -- Text colors
        TextPrimary = {0.9, 0.9, 0.9, 1},        -- White text
        TextSecondary = {0.7, 0.7, 0.7, 1},      -- Gray text
        TextAccent = {0.8, 0.6, 0.2, 1},         -- Gold text
        
        -- Attribute colors
        AttributeHigh = {0.2, 0.8, 0.2, 1},      -- Green
        AttributeMid = {0.9, 0.9, 0.9, 1},       -- White
        AttributeLow = {0.8, 0.2, 0.2, 1},       -- Red
        
        -- Button states
        ButtonNormal = {0.3, 0.3, 0.3, 0.9},
        ButtonHover = {0.4, 0.4, 0.4, 1},
        ButtonPressed = {0.2, 0.2, 0.2, 1},
        
        -- Border
        Border = {0.5, 0.5, 0.5, 0.8},
        BorderLight = {0.7, 0.7, 0.7, 0.5}
    },
    
    -- Fonts
    Fonts = {
        Title = "Interface\\AddOns\\ConflictEngine\\Media\\Fonts\\BigNoodleTitling.ttf",
        Normal = "Interface\\AddOns\\ConflictEngine\\Media\\Fonts\\PTSans.ttf",
        Bold = "Interface\\AddOns\\ConflictEngine\\Media\\Fonts\\PTSans-Bold.ttf"
    },
    
    -- Textures
    Textures = {
        Background = "Interface\\AddOns\\ConflictEngine\\Media\\Textures\\background",
        Border = "Interface\\AddOns\\ConflictEngine\\Media\\Textures\\border",
        Button = "Interface\\AddOns\\ConflictEngine\\Media\\Textures\\button",
        Tab = "Interface\\AddOns\\ConflictEngine\\Media\\Textures\\tab",
        Glow = "Interface\\AddOns\\ConflictEngine\\Media\\Textures\\glow"
    }
}

-- Create custom fonts
function CE.Style:CreateFonts()
    -- Title font
    local titleFont = CreateFont("CE_Font_Title")
    titleFont:SetFont(GameFontNormalLarge:GetFont())
    titleFont:SetTextColor(unpack(self.Colors.TextPrimary))
    titleFont:SetShadowOffset(2, -2)
    titleFont:SetShadowColor(0, 0, 0, 0.8)
    
    -- Header font
    local headerFont = CreateFont("CE_Font_Header")
    headerFont:SetFont(GameFontNormal:GetFont())
    local fontFile, _, flags = GameFontNormal:GetFont()
    headerFont:SetFont(fontFile, 16, flags)
    headerFont:SetTextColor(unpack(self.Colors.AccentLight))
    headerFont:SetShadowOffset(1, -1)
    headerFont:SetShadowColor(0, 0, 0, 0.8)
    
    -- Normal font
    local normalFont = CreateFont("CE_Font_Normal")
    normalFont:SetFont(GameFontNormal:GetFont())
    normalFont:SetTextColor(unpack(self.Colors.TextPrimary))
    
    -- Small font
    local smallFont = CreateFont("CE_Font_Small")
    smallFont:SetFont(GameFontNormalSmall:GetFont())
    smallFont:SetTextColor(unpack(self.Colors.TextSecondary))
end

-- Apply backdrop style
function CE.Style:ApplyBackdrop(frame, style)
    style = style or "primary"
    
    local backdropInfo = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    
    frame:SetBackdrop(backdropInfo)
    
    if style == "primary" then
        frame:SetBackdropColor(unpack(self.Colors.Primary))
        frame:SetBackdropBorderColor(unpack(self.Colors.Border))
    elseif style == "secondary" then
        frame:SetBackdropColor(unpack(self.Colors.Secondary))
        frame:SetBackdropBorderColor(unpack(self.Colors.BorderLight))
    elseif style == "accent" then
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        frame:SetBackdropBorderColor(unpack(self.Colors.Accent))
    end
end

-- Style a button
function CE.Style:StyleButton(button, width, height)
    button:SetSize(width or 100, height or 30)
    
    -- Normal texture
    button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    local normal = button:GetNormalTexture()
    normal:SetTexCoord(0, 0.625, 0, 0.6875)
    normal:SetVertexColor(unpack(self.Colors.ButtonNormal))
    
    -- Highlight texture
    button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    local highlight = button:GetHighlightTexture()
    highlight:SetTexCoord(0, 0.625, 0, 0.6875)
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.5)
    
    -- Pushed texture
    button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    local pushed = button:GetPushedTexture()
    pushed:SetTexCoord(0, 0.625, 0, 0.6875)
    
    -- Font
    button:SetNormalFontObject("CE_Font_Normal")
    button:SetHighlightFontObject("CE_Font_Normal")
    button:SetDisabledFontObject("GameFontDisable")
    
    -- Add glow effect on hover
    button:HookScript("OnEnter", function(self)
        normal:SetVertexColor(unpack(CE.Style.Colors.ButtonHover))
    end)
    
    button:HookScript("OnLeave", function(self)
        normal:SetVertexColor(unpack(CE.Style.Colors.ButtonNormal))
    end)
end

-- Initialize
CE.Style:CreateFonts()