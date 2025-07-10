local _, CE = ...

local ConfigPanel = {}
CE.UI = CE.UI or {}
CE.UI.ConfigPanel = ConfigPanel

function ConfigPanel:Initialize(parent)
    if not parent then return end
    
    self.parent = parent
    
    -- Panel title
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("CONFIGURATION")
    title:SetTextColor(0.9, 0.75, 0.3)
    
    -- Create sections
    self:CreateOutputSection()
    self:CreateChatSection()
    self:CreateSoundSection()
    self:CreateProfileSection()
end

function ConfigPanel:CreateOutputSection()
    -- Output settings container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 120)
    container:SetPoint("TOPLEFT", 20, -50)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Title
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOP", 0, -10)
    sectionTitle:SetText("Output Settings")
    sectionTitle:SetTextColor(0.9, 0.75, 0.3)
    
    -- Show output window checkbox
    self.showOutputCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.showOutputCheck:SetPoint("TOPLEFT", 20, -35)
    self.showOutputCheck.text = self.showOutputCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.showOutputCheck.text:SetPoint("LEFT", self.showOutputCheck, "RIGHT", 5, 0)
    self.showOutputCheck.text:SetText("Show Output Window")
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
    self.lockOutputCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.lockOutputCheck:SetPoint("TOPLEFT", 20, -60)
    self.lockOutputCheck.text = self.lockOutputCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.lockOutputCheck.text:SetPoint("LEFT", self.lockOutputCheck, "RIGHT", 5, 0)
    self.lockOutputCheck.text:SetText("Lock Output Window")
    self.lockOutputCheck:SetChecked(CE.Database:GetSetting("outputWindowLocked"))
    self.lockOutputCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("outputWindowLocked", btn:GetChecked())
        CE.Communication:SetOutputLocked(btn:GetChecked())
    end)
    
    -- Show in chat checkbox
    self.showInChatCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.showInChatCheck:SetPoint("TOPLEFT", 20, -85)
    self.showInChatCheck.text = self.showInChatCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.showInChatCheck.text:SetPoint("LEFT", self.showInChatCheck, "RIGHT", 5, 0)
    self.showInChatCheck.text:SetText("Also Show Rolls in Chat")
    self.showInChatCheck:SetChecked(CE.Database:GetSetting("showInChat"))
    self.showInChatCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("showInChat", btn:GetChecked())
    end)
end

function ConfigPanel:CreateChatSection()
    -- Chat settings container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 120)
    container:SetPoint("TOPRIGHT", -20, -50)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Title
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOP", 0, -10)
    sectionTitle:SetText("Chat Settings")
    sectionTitle:SetTextColor(0.9, 0.75, 0.3)
    
    -- Colored output checkbox
    self.coloredOutputCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.coloredOutputCheck:SetPoint("TOPLEFT", 20, -35)
    self.coloredOutputCheck.text = self.coloredOutputCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.coloredOutputCheck.text:SetPoint("LEFT", self.coloredOutputCheck, "RIGHT", 5, 0)
    self.coloredOutputCheck.text:SetText("Use Colored Output")
    self.coloredOutputCheck:SetChecked(CE.Database:GetSetting("coloredOutput"))
    self.coloredOutputCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("coloredOutput", btn:GetChecked())
    end)
    
    -- Compact mode checkbox
    self.compactModeCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.compactModeCheck:SetPoint("TOPLEFT", 20, -60)
    self.compactModeCheck.text = self.compactModeCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.compactModeCheck.text:SetPoint("LEFT", self.compactModeCheck, "RIGHT", 5, 0)
    self.compactModeCheck.text:SetText("Compact Roll Messages")
    self.compactModeCheck:SetChecked(CE.Database:GetSetting("compactMode"))
    self.compactModeCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("compactMode", btn:GetChecked())
    end)
    
    -- Whisper rolls checkbox
    self.whisperRollsCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.whisperRollsCheck:SetPoint("TOPLEFT", 20, -85)
    self.whisperRollsCheck.text = self.whisperRollsCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.whisperRollsCheck.text:SetPoint("LEFT", self.whisperRollsCheck, "RIGHT", 5, 0)
    self.whisperRollsCheck.text:SetText("Whisper Rolls to GM")
    self.whisperRollsCheck:SetChecked(CE.Database:GetSetting("whisperRolls"))
    self.whisperRollsCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("whisperRolls", btn:GetChecked())
    end)
end

function ConfigPanel:CreateSoundSection()
    -- Sound settings container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(380, 100)
    container:SetPoint("TOPLEFT", 20, -180)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Title
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOP", 0, -10)
    sectionTitle:SetText("Sound Settings")
    sectionTitle:SetTextColor(0.9, 0.75, 0.3)
    
    -- Play sounds checkbox
    self.playSoundsCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.playSoundsCheck:SetPoint("TOPLEFT", 20, -35)
    self.playSoundsCheck.text = self.playSoundsCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.playSoundsCheck.text:SetPoint("LEFT", self.playSoundsCheck, "RIGHT", 5, 0)
    self.playSoundsCheck.text:SetText("Play Roll Sounds")
    self.playSoundsCheck:SetChecked(CE.Database:GetSetting("playSounds"))
    self.playSoundsCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("playSounds", btn:GetChecked())
    end)
    
    -- Critical sound checkbox
    self.criticalSoundCheck = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    self.criticalSoundCheck:SetPoint("TOPLEFT", 20, -60)
    self.criticalSoundCheck.text = self.criticalSoundCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.criticalSoundCheck.text:SetPoint("LEFT", self.criticalSoundCheck, "RIGHT", 5, 0)
    self.criticalSoundCheck.text:SetText("Play Critical Sounds (20s and 1s)")
    self.criticalSoundCheck:SetChecked(CE.Database:GetSetting("criticalSound"))
    self.criticalSoundCheck:SetScript("OnClick", function(btn)
        CE.Database:SetSetting("criticalSound", btn:GetChecked())
    end)
end

function ConfigPanel:CreateProfileSection()
    -- Profile management container
    local container = CreateFrame("Frame", nil, self.parent, "BackdropTemplate")
    container:SetSize(780, 150)
    container:SetPoint("BOTTOM", 0, 20)
    container:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    
    -- Title
    local sectionTitle = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sectionTitle:SetPoint("TOP", 0, -10)
    sectionTitle:SetText("Profile Management")
    sectionTitle:SetTextColor(0.9, 0.75, 0.3)
    
    -- Current profile text
    self.currentProfileText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.currentProfileText:SetPoint("TOPLEFT", 20, -35)
    self.currentProfileText:SetText("Current Profile: " .. (CE.Database.db:GetCurrentProfile() or "Default"))
    
    -- Profile dropdown
    local profileLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileLabel:SetPoint("TOPLEFT", 20, -60)
    profileLabel:SetText("Select Profile:")
    
    self.profileDropdown = CreateFrame("Frame", "CE_ProfileDropdown", container, "UIDropDownMenuTemplate")
    self.profileDropdown:SetPoint("LEFT", profileLabel, "RIGHT", 10, -2)
    UIDropDownMenu_SetWidth(self.profileDropdown, 150)
    
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
    
    -- New profile button
    local newProfileBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    newProfileBtn:SetSize(100, 25)
    newProfileBtn:SetPoint("TOPLEFT", 20, -90)
    newProfileBtn:SetText("New Profile")
    newProfileBtn:SetScript("OnClick", function()
        StaticPopup_Show("CE_NEW_PROFILE")
    end)
    
    -- Copy profile button
    local copyProfileBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    copyProfileBtn:SetSize(100, 25)
    copyProfileBtn:SetPoint("LEFT", newProfileBtn, "RIGHT", 10, 0)
    copyProfileBtn:SetText("Copy Profile")
    copyProfileBtn:SetScript("OnClick", function()
        StaticPopup_Show("CE_COPY_PROFILE")
    end)
    
    -- Delete profile button
    local deleteProfileBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    deleteProfileBtn:SetSize(100, 25)
    deleteProfileBtn:SetPoint("LEFT", copyProfileBtn, "RIGHT", 10, 0)
    deleteProfileBtn:SetText("Delete Profile")
    deleteProfileBtn:SetScript("OnClick", function()
        local currentProfile = CE.Database.db:GetCurrentProfile()
        if currentProfile ~= "Default" then
            StaticPopup_Show("CE_DELETE_PROFILE", currentProfile)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFF[CE]|r Cannot delete the Default profile")
        end
    end)
    
    -- Reset profile button
    local resetProfileBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    resetProfileBtn:SetSize(100, 25)
    resetProfileBtn:SetPoint("LEFT", deleteProfileBtn, "RIGHT", 10, 0)
    resetProfileBtn:SetText("Reset Profile")
    resetProfileBtn:SetScript("OnClick", function()
        StaticPopup_Show("CE_RESET_PROFILE")
    end)
    
    self:CreateStaticPopups()
end

function ConfigPanel:CreateStaticPopups()
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
    
    -- Delete profile popup
    StaticPopupDialogs["CE_DELETE_PROFILE"] = {
        text = "Are you sure you want to delete the profile '%s'?",
        OnAccept = function(self, profile)
            CE.Database:DeleteProfile(profile)
            CE.UI.ConfigPanel:RefreshValues()
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