local _, CE = ...

CE.Style = {
    Colors = {
        Primary = {0.08, 0.08, 0.08, 0.92},
        Secondary = {0.15, 0.13, 0.11, 0.85},
        Tertiary = {0.22, 0.18, 0.15, 0.8},
        Parchment = {0.9, 0.85, 0.7, 0.9},

        Accent = {0.8, 0.65, 0.2, 1},
        AccentLight = {0.95, 0.8, 0.4, 1},
        AccentDark = {0.6, 0.45, 0.15, 1},

        TextPrimary = {0.95, 0.9, 0.85, 1},
        TextSecondary = {0.75, 0.7, 0.65, 1},
        TextAccent = {0.85, 0.7, 0.3, 1},
        TextDark = {0.2, 0.15, 0.1, 1},

        AttributeHigh = {0.3, 0.85, 0.3, 1},
        AttributeMid = {0.9, 0.85, 0.6, 1},
        AttributeLow = {0.85, 0.25, 0.25, 1},

        ButtonNormal = {0.4, 0.35, 0.3, 0.9},
        ButtonHover = {0.5, 0.45, 0.4, 1},
        ButtonPressed = {0.3, 0.25, 0.2, 1},

        Border = {0.4, 0.35, 0.3, 0.8},
        BorderLight = {0.6, 0.55, 0.5, 0.6},
        BorderGold = {0.8, 0.65, 0.2, 0.9}
    },

    Fonts = {
        title = {"Fonts\\FRIZQT__.ttf", 20, "THICKOUTLINE"},
        label = {"Fonts\\FRIZQT__.ttf", 14, ""},
        value = {"Fonts\\MORPHEUS.ttf", 18, "OUTLINE"},
        button = {"Fonts\\FRIZQT__.ttf", 12, "OUTLINE"},
    },

    Textures = {
        Stone = "Interface\\FrameGeneral\\UI-Background-Rock",
        Wood = "Interface\\Garrison\\WoodFrameDark",
        WoodLight = "Interface\\Garrison\\WoodFrameCorner",
        Parchment = "Interface\\QuestFrame\\QuestBG",
        ParchmentHoriz = "Interface\\AchievementFrame\\UI-GuildAchievement-Parchment-Horizontal-Desaturated",

        GoldBorder = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        WoodBorder = "Interface\\FriendsFrame\\UI-Toast-Border",
        SimpleBorder = "Interface\\Tooltips\\UI-Tooltip-Border",

        ButtonHighlight = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight",
        TabActive = "Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab",
        Divider = "Interface\\Common\\UI-TooltipDivider-Transparent",

        Shield = "Interface\\Achievements\\UI-Achievement-IconFrame",
        Corner = "Interface\\Artifacts\\Artifacts-PerkRing-Final-Mask",
        Ring = "Interface\\Common\\RingBorder"
    }
}

function CE.Style:ApplyBackdrop(frame, style)
    style = style or "primary"

    local backdropConfigs = {
        primary = {
            bgFile = self.Textures.Stone,
            edgeFile = self.Textures.GoldBorder,
            tile = true,
            tileSize = 256,
            edgeSize = 22,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        },
        wood = {
            bgFile = self.Textures.Wood,
            edgeFile = self.Textures.WoodBorder,
            tile = true,
            tileSize = 256,
            edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        },
        parchment = {
            bgFile = self.Textures.Parchment,
            edgeFile = self.Textures.SimpleBorder,
            tile = true,
            tileSize = 256,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        },
        simple = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = self.Textures.SimpleBorder,
            tile = true,
            tileSize = 32,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        }
    }

    local config = backdropConfigs[style] or backdropConfigs.primary
    frame:SetBackdrop(config)

    if style == "primary" then
        frame:SetBackdropColor(unpack(self.Colors.Primary))
        frame:SetBackdropBorderColor(unpack(self.Colors.BorderGold))
    elseif style == "wood" then
        frame:SetBackdropColor(unpack(self.Colors.Secondary))
        frame:SetBackdropBorderColor(unpack(self.Colors.Border))
    elseif style == "parchment" then
        frame:SetBackdropColor(unpack(self.Colors.Parchment))
        frame:SetBackdropBorderColor(unpack(self.Colors.BorderGold))
    elseif style == "simple" then
        frame:SetBackdropColor(unpack(self.Colors.Secondary))
        frame:SetBackdropBorderColor(unpack(self.Colors.Border))
    end
end

function CE.Style:ApplyFontString(fontString, fontKey)
    if not fontString then return end

    local fontDef = self.Fonts[fontKey]
    if not fontDef then
        -- Fallback to a readable default if the key is missing
        fontString:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
        return
    end

    local font, size, outline = unpack(fontDef)
    fontString:SetFont(font, size, outline or "")
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 0.6)
end


function CE.Style:CreateFonts()
    local titleFont = CreateFont("CE_Font_Title")
    titleFont:SetFont("Fonts\\MORPHEUS.ttf", 24, "THICKOUTLINE")
    titleFont:SetTextColor(unpack(self.Colors.TextDark))
    titleFont:SetShadowOffset(2, -2)
    titleFont:SetShadowColor(0, 0, 0, 0.8)

    local headerFont = CreateFont("CE_Font_Header")
    headerFont:SetFont("Fonts\\MORPHEUS.ttf", 16, "OUTLINE")
    headerFont:SetTextColor(unpack(self.Colors.AccentLight))
    headerFont:SetShadowOffset(1, -1)
    headerFont:SetShadowColor(0, 0, 0, 0.8)

    local normalFont = CreateFont("CE_Font_Normal")
    normalFont:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    normalFont:SetTextColor(unpack(self.Colors.TextPrimary))
    normalFont:SetShadowOffset(1, -1)
    normalFont:SetShadowColor(0, 0, 0, 0.5)

    local smallFont = CreateFont("CE_Font_Small")
    smallFont:SetFont("Fonts\\FRIZQT__.ttf", 10, "")
    smallFont:SetTextColor(unpack(self.Colors.TextSecondary))

    local numberFont = CreateFont("CE_Font_Number")
    numberFont:SetFont("Fonts\\MORPHEUS.ttf", 20, "OUTLINE")
    numberFont:SetTextColor(unpack(self.Colors.AccentLight))
    numberFont:SetShadowOffset(2, -2)
    numberFont:SetShadowColor(0, 0, 0, 0.8)
end

function CE.Style:StyleButton(button, width, height)
    button:SetSize(width or 100, height or 30)

    button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    local normal = button:GetNormalTexture()
    normal:SetTexCoord(0, 0.625, 0, 0.6875)
    normal:SetVertexColor(0.7, 0.6, 0.5, 1)

    button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    local highlight = button:GetHighlightTexture()
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.3)

    button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    local pushed = button:GetPushedTexture()
    pushed:SetTexCoord(0, 0.625, 0, 0.6875)

    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetDisabledFontObject("GameFontDisable")

    button:HookScript("OnEnter", function(self)
        normal:SetVertexColor(0.85, 0.75, 0.65, 1)
    end)

    button:HookScript("OnLeave", function(self)
        normal:SetVertexColor(0.7, 0.6, 0.5, 1)
    end)
end

function CE.Style:CreateDivider(parent, width)
    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetSize(width or 200, 12)
    divider:SetTexture(self.Textures.Divider)
    divider:SetVertexColor(unpack(self.Colors.BorderGold))
    divider:SetAlpha(0.5)
    return divider
end

function CE.Style:CreateCornerDecoration(parent, corner)
    local decoration = parent:CreateTexture(nil, "OVERLAY")
    decoration:SetSize(32, 32)
    decoration:SetTexture(self.Textures.Corner)
    decoration:SetVertexColor(unpack(self.Colors.AccentDark))

    if corner == "TOPLEFT" then
        decoration:SetPoint("TOPLEFT", -5, 5)
    elseif corner == "TOPRIGHT" then
        decoration:SetPoint("TOPRIGHT", 5, 5)
        decoration:SetTexCoord(1, 0, 0, 1)
    elseif corner == "BOTTOMLEFT" then
        decoration:SetPoint("BOTTOMLEFT", -5, -5)
        decoration:SetTexCoord(0, 1, 1, 0)
    elseif corner == "BOTTOMRIGHT" then
        decoration:SetPoint("BOTTOMRIGHT", 5, -5)
        decoration:SetTexCoord(1, 0, 1, 0)
    end

    return decoration
end

function CE.Style:ApplyPanelStyle(frame)
    self:ApplyBackdrop(frame, "simple")
    frame:SetBackdropColor(unpack(self.Colors.Primary))
    frame:SetBackdropBorderColor(unpack(self.Colors.Border))
end

CE.Style:CreateFonts()
