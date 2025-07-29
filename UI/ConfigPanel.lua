local _, CE = ...

local ConfigPanel = {}
CE.UI = CE.UI or {}
CE.UI.ConfigPanel = ConfigPanel

function ConfigPanel:Initialize(parent)
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
    title:SetText("CONFIGURATION")
    title:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)
    
    -- Decorative divider with dark silver
    local divider = CE.Style:CreateDivider(parent, 300)
    divider:SetPoint("TOP", title, "BOTTOM", 0, -5)
    divider:SetVertexColor(0.35, 0.35, 0.4, 0.6) -- Dark silver
    
    -- Create sections
    self:CreateOutputSection()
    self:CreateChatSection()
    self:CreateSoundSection()
    self:CreateProfileSection()
end

function ConfigPanel:CreateFlatButton(parent, text, width, height)
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

function ConfigPanel:CreateStyledCheckbox(parent, text)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:GetNormalTexture():SetVertexColor(0.3, 0.3, 0.35)
    check:GetHighlightTexture():SetVertexColor(0.5, 0.12, 0.18, 0.3)
    check.text = check:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    check.text:SetPoint("LEFT", check, "RIGHT", 5, 0)
    check.text:SetFont("Fonts\\FRIZQT__.ttf", 12, "")
    check.text:SetText(text)
    check.text:SetTextColor(0.65, 0.65, 0.7) -- Silver
    
    -- Hover effect
    check:SetScript("OnEnter", function()
        check.text:SetTextColor(0.85, 0.82, 0.75) -- Pale gold on hover
    end)
    
    check:SetScript("OnLeave", function()
        check.text:SetTextColor(0.65, 0.65, 0.7) -- Back to silver
    end)
    
    return check
end

function ConfigPanel:CreateOutputSection()
    -- Output settings container with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 120)
    container:SetPoint("TOPLEFT", 20, -70)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Title with burgundy accent
    local titleBg = container:CreateTexture(nil, "ARTWORK")
    titleBg:SetHeight(25)
    titleBg:SetPoint("TOPLEFT", 4, -4)
    titleBg:SetPoint("TOPRIGHT", -4, -4)
    titleBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    titleBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local titleAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    titleAccent:SetHeight(2)
    titleAccent:SetPoint("BOTTOMLEFT", titleBg, 0, 0)
    titleAccent:SetPoint("BOTTOMRIGHT", titleBg, 0, 0)
    titleAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("CENTER", titleBg, 0, 0)
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
    sectionTitle:SetText("Output Settings")
    sectionTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Show output window checkbox
    self.showOutputCheck = self:CreateStyledCheckbox(container, "Show Output Window")
    self.showOutputCheck:SetPoint("TOPLEFT", 20, -35)
    self.showOutputCheck:SetChecked(CE.Database:GetSetting("showOutputWindow"))
    self.showOutputCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("showOutputWindow", btn:GetChecked())
        if btn:GetChecked() then
            CE.Communication:ShowOutput()
        else
            CE.Communication:HideOutput()
        end
    end)
    
    -- Lock output window checkbox
    self.lockOutputCheck = self:CreateStyledCheckbox(container, "Lock Output Window")
    self.lockOutputCheck:SetPoint("TOPLEFT", 20, -60)
    self.lockOutputCheck:SetChecked(CE.Database:GetSetting("outputWindowLocked"))
    self.lockOutputCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("outputWindowLocked", btn:GetChecked())
        CE.Communication:SetOutputLocked(btn:GetChecked())
    end)
    
    -- Show in chat checkbox
    self.showInChatCheck = self:CreateStyledCheckbox(container, "Also Show Rolls in Chat")
    self.showInChatCheck:SetPoint("TOPLEFT", 20, -85)
    self.showInChatCheck:SetChecked(CE.Database:GetSetting("showInChat"))
    self.showInChatCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("showInChat", btn:GetChecked())
    end)
end

function ConfigPanel:CreateChatSection()
    -- Chat settings container with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 120)
    container:SetPoint("TOPRIGHT", -20, -70)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Title with burgundy accent
    local titleBg = container:CreateTexture(nil, "ARTWORK")
    titleBg:SetHeight(25)
    titleBg:SetPoint("TOPLEFT", 4, -4)
    titleBg:SetPoint("TOPRIGHT", -4, -4)
    titleBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    titleBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local titleAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    titleAccent:SetHeight(2)
    titleAccent:SetPoint("BOTTOMLEFT", titleBg, 0, 0)
    titleAccent:SetPoint("BOTTOMRIGHT", titleBg, 0, 0)
    titleAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("CENTER", titleBg, 0, 0)
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
    sectionTitle:SetText("Chat Settings")
    sectionTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Colored output checkbox
    self.coloredOutputCheck = self:CreateStyledCheckbox(container, "Use Colored Output")
    self.coloredOutputCheck:SetPoint("TOPLEFT", 20, -35)
    self.coloredOutputCheck:SetChecked(CE.Database:GetSetting("coloredOutput"))
    self.coloredOutputCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("coloredOutput", btn:GetChecked())
    end)
    
    -- Compact mode checkbox
    self.compactModeCheck = self:CreateStyledCheckbox(container, "Compact Roll Messages")
    self.compactModeCheck:SetPoint("TOPLEFT", 20, -60)
    self.compactModeCheck:SetChecked(CE.Database:GetSetting("compactMode"))
    self.compactModeCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("compactMode", btn:GetChecked())
    end)
    
    -- Whisper rolls checkbox
    self.whisperRollsCheck = self:CreateStyledCheckbox(container, "Whisper Rolls to GM")
    self.whisperRollsCheck:SetPoint("TOPLEFT", 20, -85)
    self.whisperRollsCheck:SetChecked(CE.Database:GetSetting("whisperRolls"))
    self.whisperRollsCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("whisperRolls", btn:GetChecked())
    end)
end

function ConfigPanel:CreateSoundSection()
    -- Sound settings container with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(780, 80)
    container:SetPoint("TOP", 0, -200)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.05, 0.05, 0.07, 0.9) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Title with burgundy accent
    local titleBg = container:CreateTexture(nil, "ARTWORK")
    titleBg:SetHeight(25)
    titleBg:SetPoint("TOPLEFT", 4, -4)
    titleBg:SetPoint("TOPRIGHT", -4, -4)
    titleBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    titleBg:SetVertexColor(0.08, 0.08, 0.1, 0.9) -- Dark grey-blue
    
    local titleAccent = container:CreateTexture(nil, "ARTWORK", nil, 1)
    titleAccent:SetHeight(2)
    titleAccent:SetPoint("BOTTOMLEFT", titleBg, 0, 0)
    titleAccent:SetPoint("BOTTOMRIGHT", titleBg, 0, 0)
    titleAccent:SetColorTexture(0.4, 0.1, 0.15, 0.8) -- Burgundy
    
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("CENTER", titleBg, 0, 0)
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 13, "OUTLINE")
    sectionTitle:SetText("Sound Settings")
    sectionTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Play sounds checkbox
    self.playSoundsCheck = self:CreateStyledCheckbox(container, "Play Roll Sounds")
    self.playSoundsCheck:SetPoint("TOPLEFT", 100, -40)
    self.playSoundsCheck:SetChecked(CE.Database:GetSetting("playSounds"))
    self.playSoundsCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("playSounds", btn:GetChecked())
    end)
    
    -- Critical sound checkbox
    self.criticalSoundCheck = self:CreateStyledCheckbox(container, "Play Critical Sounds (20s and 1s)")
    self.criticalSoundCheck:SetPoint("LEFT", self.playSoundsCheck, "RIGHT", 150, 0)
    self.criticalSoundCheck:SetChecked(CE.Database:GetSetting("criticalSound"))
    self.criticalSoundCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("criticalSound", btn:GetChecked())
    end)
end

function ConfigPanel:CreateProfileSection()
    -- Profile management container with dark theme
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(780, 180)
    container:SetPoint("BOTTOM", 0, 20)
    
    CE.Style:ApplyBackdrop(container, "wood")
    container:SetBackdropColor(0.03, 0.03, 0.04, 0.95) -- Nearly black
    container:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.8) -- Dark silver
    
    -- Header with burgundy accent
    local headerBg = container:CreateTexture(nil, "ARTWORK")
    headerBg:SetHeight(35)
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
    sectionTitle:SetFont("Fonts\\FRIZQT__.ttf", 14, "OUTLINE")
    sectionTitle:SetText("Profile Management")
    sectionTitle:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Current profile display with dark background
    local profileBg = container:CreateTexture(nil, "ARTWORK")
    profileBg:SetHeight(30)
    profileBg:SetPoint("TOPLEFT", 20, -45)
    profileBg:SetPoint("TOPRIGHT", -20, -45)
    profileBg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    profileBg:SetVertexColor(0.1, 0.1, 0.12, 0.5) -- Dark background strip
    
    self.currentProfileText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.currentProfileText:SetPoint("LEFT", profileBg, 15, 0)
    self.currentProfileText:SetFont("Fonts\\FRIZQT__.ttf", 13, "")
    self.currentProfileText:SetText("Current Profile: " .. (CE.Database.db:GetCurrentProfile() or "Default"))
    self.currentProfileText:SetTextColor(0.85, 0.82, 0.75) -- Pale gold
    
    -- Profile dropdown with dark styling
    local profileLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileLabel:SetPoint("TOPLEFT", 35, -85)
    profileLabel:SetText("Select Profile:")
    profileLabel:SetTextColor(0.6, 0.6, 0.65) -- Silver
    
    self.profileDropdown = CreateFrame("Frame", "CE_ProfileDropdown", container, "UIDropDownMenuTemplate")
    self.profileDropdown:SetPoint("LEFT", profileLabel, "RIGHT", 10, -2)
    UIDropDownMenu_SetWidth(self.profileDropdown, 150)
    
    -- Style dropdown
    local dropdownBg = _G["CE_ProfileDropdownMiddle"]
    if dropdownBg then
        dropdownBg:SetVertexColor(0.3, 0.3, 0.35)
    end
    local dropdownText = _G["CE_ProfileDropdownText"]
    if dropdownText then
        dropdownText:SetTextColor(0.85, 0.82, 0.75)
    end
    
    UIDropDownMenu_Initialize(self.profileDropdown, function(frame, level)
        local profiles = CE.Database:GetProfiles()
        local currentProfile = CE.Database.db:GetCurrentProfile()
        
        for _, profile in ipairs(profiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = profile
            info.value = profile
            info.checked = (profile == currentProfile)
            info.func = function()
                CE.Database:SetProfile(profile)
                self:RefreshValues()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    UIDropDownMenu_SetSelectedValue(self.profileDropdown, CE.Database.db:GetCurrentProfile())
    
    -- Button container with proper spacing
    local buttonY = -120
    
    -- New profile button with flat style
    local newProfileBtn = self:CreateFlatButton(container, "New Profile", 100, 30)
    newProfileBtn:SetPoint("TOPLEFT", 120, buttonY)
    newProfileBtn:SetScript("OnClick", function()
        StaticPopup_Show("CE_NEW_PROFILE")
    end)
    
    -- Copy profile button with flat style
    local copyProfileBtn = self:CreateFlatButton(container, "Copy Profile", 100, 30)
    copyProfileBtn:SetPoint("LEFT", newProfileBtn, "RIGHT", 10, 0)
    copyProfileBtn:SetScript("OnClick", function()
        StaticPopup_Show("CE_COPY_PROFILE")
    end)
    
    -- Delete profile button with flat style
    local deleteProfileBtn = self:CreateFlatButton(container, "Delete Profile", 100, 30)
    deleteProfileBtn:SetPoint("LEFT", copyProfileBtn, "RIGHT", 10, 0)
    deleteProfileBtn:SetScript("OnClick", function()
        local currentProfile = CE.Database.db:GetCurrentProfile()
        if currentProfile ~= "Default" then
            StaticPopup_Show("CE_DELETE_PROFILE", currentProfile)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r Cannot delete the Default profile")
        end
    end)
    
    -- Reset profile button with flat style
    local resetProfileBtn = self:CreateFlatButton(container, "Reset Profile", 100, 30)
    resetProfileBtn:SetPoint("LEFT", deleteProfileBtn, "RIGHT", 10, 0)
    resetProfileBtn:SetScript("OnClick", function()
        StaticPopup_Show("CE_RESET_PROFILE")
    end)
    
    self:CreateStaticPopups()
end

function ConfigPanel:CreateStaticPopups()
    -- Style the popup dialogs to match dark theme
    local function StylePopup(dialogName)
        hooksecurefunc(StaticPopupDialogs[dialogName], "OnShow", function(self)
            if self.SetBackdrop then
                self:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                    tile = true, tileSize = 32, edgeSize = 32,
                    insets = { left = 11, right = 12, top = 12, bottom = 11 }
                })
                self:SetBackdropColor(0.02, 0.02, 0.03, 0.98)
                self:SetBackdropBorderColor(0.6, 0.6, 0.65, 0.9)
            end
        end)
    end
    
    -- New profile popup
    StaticPopupDialogs["CE_NEW_PROFILE"] = {
        text = "Enter name for new profile:",
        hasEditBox = true,
        maxLetters = 32,
        OnAccept = function(self)
            local text = self.editBox:GetText()
            if text and text ~= "" then
                CE.Database.db:SetProfile(text)
                CE.UI.ConfigPanel:RefreshValues()
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local text = self:GetText()
            if text and text ~= "" then
                CE.Database.db:SetProfile(text)
                CE.UI.ConfigPanel:RefreshValues()
            end
            self:GetParent():Hide()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        button1 = "Create",
        button2 = "Cancel"
    }
    
    -- Copy profile popup
    StaticPopupDialogs["CE_COPY_PROFILE"] = {
        text = "Copy settings from which profile?",
        hasEditBox = true,
        maxLetters = 32,
        OnAccept = function(self)
            local text = self.editBox:GetText()
            if text and text ~= "" then
                CE.Database:CopyProfile(text)
                CE.UI.ConfigPanel:RefreshValues()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        button1 = "Copy",
        button2 = "Cancel"
    }
    
    -- Delete profile popup - FIXED VERSION
    StaticPopupDialogs["CE_DELETE_PROFILE"] = {
        text = "Are you sure you want to delete the profile '%s'?",
        OnAccept = function(self, profile)
            -- Ensure we have a valid profile name
            if not profile or profile == "" then
                profile = CE.Database.db:GetCurrentProfile()
            end
            
            -- Double-check it's not nil and not Default
            if profile and profile ~= "" and profile ~= "Default" then
                local currentProfile = CE.Database.db:GetCurrentProfile()
                
                -- If trying to delete the current profile, switch to Default first
                if profile == currentProfile then
                    CE.Database.db:SetProfile("Default")
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r Switched to Default profile")
                end
                
                -- Now delete the profile
                CE.Database.db:DeleteProfile(profile)
                CE.UI.ConfigPanel:RefreshValues()
                DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r Profile '" .. profile .. "' deleted")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFF8B6914[CE]|r Error: Cannot delete Default profile or invalid profile name")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        button1 = "Delete",
        button2 = "Cancel"
    }
    
    -- Reset profile popup
    StaticPopupDialogs["CE_RESET_PROFILE"] = {
        text = "Are you sure you want to reset the current profile to defaults?",
        OnAccept = function()
            CE.Database:ResetProfile()
            CE.UI.ConfigPanel:RefreshValues()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        button1 = "Reset",
        button2 = "Cancel"
    }
end

function ConfigPanel:RefreshValues()
    -- Update all checkboxes
    self.showOutputCheck:SetChecked(CE.Database:GetSetting("showOutputWindow"))
    self.lockOutputCheck:SetChecked(CE.Database:GetSetting("outputWindowLocked"))
    self.showInChatCheck:SetChecked(CE.Database:GetSetting("showInChat"))
    self.coloredOutputCheck:SetChecked(CE.Database:GetSetting("coloredOutput"))
    self.compactModeCheck:SetChecked(CE.Database:GetSetting("compactMode"))
    self.whisperRollsCheck:SetChecked(CE.Database:GetSetting("whisperRolls"))
    self.playSoundsCheck:SetChecked(CE.Database:GetSetting("playSounds"))
    self.criticalSoundCheck:SetChecked(CE.Database:GetSetting("criticalSound"))
    
    -- Update profile info
    self.currentProfileText:SetText("Current Profile: " .. (CE.Database.db:GetCurrentProfile() or "Default"))
    UIDropDownMenu_SetSelectedValue(self.profileDropdown, CE.Database.db:GetCurrentProfile())
    UIDropDownMenu_Initialize(self.profileDropdown, self.profileDropdown.initialize)
end