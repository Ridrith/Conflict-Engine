local _, CE = ...

local Communication = {}
CE.Communication = Communication

function Communication:Initialize()
    self.prefix = CE.Constants.COMM_PREFIX
    C_ChatInfo.RegisterAddonMessagePrefix(self.prefix)
    
    -- Initialize callback system
    self.callbacks = {}
    
    -- Register event using the addon object that has AceEvent
    CE.addon:RegisterEvent("CHAT_MSG_ADDON", function(_, prefix, message, channel, sender)
        if prefix == self.prefix then
            self:HandleMessage(message, channel, sender)
        end
    end)
    
    -- Initialize output frame
    self:CreateOutputFrame()
    
    -- Check if we should show the output window
    if CE.Database:GetSetting("showOutputWindow") then
        self:ShowOutput()
    end
end

-- Callback system methods
function Communication:RegisterCallback(event, callback, owner)
    if not self.callbacks then
        self.callbacks = {}
    end
    
    if not self.callbacks[event] then
        self.callbacks[event] = {}
    end
    
    table.insert(self.callbacks[event], {
        callback = callback,
        owner = owner
    })
end

function Communication:UnregisterCallback(event, owner)
    if not self.callbacks or not self.callbacks[event] then
        return
    end
    
    for i = #self.callbacks[event], 1, -1 do
        if self.callbacks[event][i].owner == owner then
            table.remove(self.callbacks[event], i)
        end
    end
end

function Communication:TriggerCallback(event, ...)
    if not self.callbacks or not self.callbacks[event] then
        return
    end
    
    for _, callbackData in ipairs(self.callbacks[event]) do
        if callbackData.callback then
            local success, err = pcall(callbackData.callback, ...)
            if not success then
                print("|cFFFF0000[CE Error]|r Callback error:", err)
            end
        end
    end
end

function Communication:UnregisterAllCallbacks(owner)
    if not self.callbacks then
        return
    end
    
    for event, callbacks in pairs(self.callbacks) do
        for i = #callbacks, 1, -1 do
            if callbacks[i].owner == owner then
                table.remove(callbacks, i)
            end
        end
    end
end

-- FIXED: More robust player name checking
function Communication:IsPlayerSender(sender)
    local playerName = UnitName("player")
    
    -- Get the base name without server (everything before the dash)
    local playerBase = playerName:match("^([^-]+)")
    local senderBase = sender:match("^([^-]+)")
    
    -- Check exact matches first
    if sender == playerName then
        return true
    end
    
    -- Check if the base names match (handles server name variations)
    if playerBase and senderBase and playerBase == senderBase then
        return true
    end
    
    -- Additional check: try with full realm name
    local realmName = GetRealmName()
    local playerNameFull = playerName .. "-" .. realmName
    if sender == playerNameFull then
        return true
    end
    
    -- Check normalized realm name (replace spaces with nothing, etc.)
    local normalizedRealm = realmName:gsub("%s+", "")
    local playerNameNormalized = playerName .. "-" .. normalizedRealm
    if sender == playerNameNormalized then
        return true
    end
    
    return false
end

function Communication:HandleMessage(message, channel, sender)
    local success, data = pcall(function() return {strsplit("|", message)} end)
    if not success or not data[1] then return end
    
    -- FIXED: Skip messages from ourselves using robust name checking
    if self:IsPlayerSender(sender) then
        return
    end
    
    local messageType = data[1]
    
    if messageType == "ROLL" then
        local rollType = data[2]
        local detail = data[3]
        local total = tonumber(data[4])
        local modifier = tonumber(data[5])
        local rolls = {}
        
        for i = 6, #data do
            local roll = tonumber(data[i])
            if roll then
                table.insert(rolls, roll)
            end
        end
        
        self:DisplayRoll({
            type = rollType,
            detail = detail,
            total = total,
            modifier = modifier,
            rolls = rolls
        }, sender)
    elseif messageType == "TRAIT" then
        local traitName = data[2]
        local traitDesc = data[3]
        local usesLeft = tonumber(data[4])
        local maxUses = tonumber(data[5])
        
        self:DisplayTraitUsage({
            name = traitName,
            description = traitDesc,
            currentUses = usesLeft,
            maxUses = maxUses
        }, sender)
    end
end

function Communication:SendRoll(rollData)
    local message = string.format("ROLL|%s|%s|%d|%d|%s",
        rollData.type,
        rollData.detail,
        rollData.total,
        rollData.modifier,
        table.concat(rollData.rolls, "|")
    )
    
    local channel = self:GetChannel()
    if channel then
        C_ChatInfo.SendAddonMessage(self.prefix, message, channel)
    end
    
    -- Display to self
    self:DisplayRoll(rollData, UnitName("player"))
    
    -- Play sound if enabled
    if CE.Database:GetSetting("playSounds") then
        if #rollData.rolls == 1 then
            if rollData.rolls[1] == 20 and CE.Database:GetSetting("criticalSound") then
                PlaySound(888, "Master") -- Level up sound for nat 20
            elseif rollData.rolls[1] == 1 and CE.Database:GetSetting("criticalSound") then
                PlaySound(5274, "Master") -- Error sound for nat 1
            else
                PlaySound(3337, "Master") -- Normal dice sound
            end
        else
            PlaySound(3337, "Master") -- Normal dice sound
        end
    end
end

function Communication:SendTraitUsage(trait)
    local message = string.format("TRAIT|%s|%s|%d|%d",
        trait.name,
        trait.description or "",
        trait.currentUses,
        trait.maxUses
    )
    
    local channel = self:GetChannel()
    if channel then
        C_ChatInfo.SendAddonMessage(self.prefix, message, channel)
    end
    
    -- Display to self
    self:DisplayTraitUsage(trait, UnitName("player"))
end

function Communication:GetChannel()
    if IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    else
        return nil
    end
end

function Communication:DisplayRoll(rollData, sender)
    local useColors = CE.Database:GetSetting("coloredOutput")
    local colors = useColors and CE.Constants.ROLL_COLORS or {
        NORMAL = "",
        ATTRIBUTE = "",
        DICE = "",
        DEFENSE = "",
        DAMAGE = "",
        TRAIT = "",
        MODIFIER = "",
        TOTAL = "",
        SUCCESS = "",
        FAILURE = "",
        CRITICAL_SUCCESS = "",
        CRITICAL_FAILURE = ""
    }
    
    local msg = self:FormatRollMessage(rollData, sender, colors)
    
    -- Add to output window if enabled
    if CE.Database:GetSetting("showOutputWindow") then
        self:AddMessage(msg)
    end
    
    -- Also send to chat if enabled
    if CE.Database:GetSetting("showInChat") then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end

function Communication:DisplayTraitUsage(trait, sender)
    local useColors = CE.Database:GetSetting("coloredOutput")
    local colors = useColors and CE.Constants.ROLL_COLORS or {
        NORMAL = "",
        ATTRIBUTE = "",
        DICE = "",
        DEFENSE = "",
        DAMAGE = "",
        TRAIT = "",
        MODIFIER = "",
        TOTAL = "",
        SUCCESS = "",
        FAILURE = "",
        CRITICAL_SUCCESS = "",
        CRITICAL_FAILURE = ""
    }
    
    -- Format trait usage message
    local msg = string.format("%s[CE] %s%s uses %s%s%s: %s%s",
        colors.NORMAL,
        sender,
        colors.NORMAL,
        colors.TRAIT,
        trait.name,
        colors.NORMAL,
        colors.ATTRIBUTE,
        trait.description or "No description"
    )
    
    -- Add uses remaining
    if trait.currentUses and trait.maxUses then
        local usesColor = colors.SUCCESS
        if trait.currentUses == 0 then
            usesColor = colors.FAILURE
        elseif trait.currentUses <= trait.maxUses / 2 then
            usesColor = colors.MODIFIER
        end
        
        msg = msg .. string.format(" %s(%s%d/%d uses remaining%s)",
            colors.NORMAL,
            usesColor,
            trait.currentUses,
            trait.maxUses,
            colors.NORMAL
        )
    end
    
    -- Add to output window if enabled
    if CE.Database:GetSetting("showOutputWindow") then
        self:AddMessage(msg)
    end
    
    -- Also send to chat if enabled
    if CE.Database:GetSetting("showInChat") then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end

function Communication:FormatRollMessage(rollData, sender, colors)
    local compact = CE.Database:GetSetting("compactMode")
    local msg = "[CE] " .. sender .. " "
    
    if rollData.type == "attribute" then
        msg = msg .. "rolls " .. colors.ATTRIBUTE .. rollData.detail .. colors.NORMAL .. ": "
    elseif rollData.type == "dice" then
        msg = msg .. "rolls " .. colors.DICE .. rollData.detail .. colors.NORMAL .. ": "
    elseif rollData.type == "defense" then
        msg = msg .. "rolls " .. colors.DEFENSE .. "Defense: "
    elseif rollData.type == "dr" then
        msg = msg .. "rolls " .. colors.DAMAGE .. "Damage Reduction: "
    elseif rollData.type == "currency" then
        msg = msg .. "flips a coin: "
    elseif rollData.type == "trait" then
        msg = msg .. "uses trait " .. colors.TRAIT .. rollData.detail .. colors.NORMAL .. ": "
    else
        msg = msg .. "rolls: "
    end
    
    -- Add individual rolls (unless in compact mode)
    if rollData.rolls and #rollData.rolls > 0 and not compact then
        local rollsStr = {}
        for _, roll in ipairs(rollData.rolls) do
            local rollColor = colors.NORMAL
            if roll == 20 then
                rollColor = colors.CRITICAL_SUCCESS
            elseif roll == 1 then
                rollColor = colors.CRITICAL_FAILURE
            end
            table.insert(rollsStr, rollColor .. roll .. colors.NORMAL)
        end
        msg = msg .. "(" .. table.concat(rollsStr, ", ") .. ") "
    end
    
    -- Add modifier if any
    if rollData.modifier and rollData.modifier ~= 0 and not compact then
        local modStr = rollData.modifier > 0 and "+" .. rollData.modifier or tostring(rollData.modifier)
        msg = msg .. colors.MODIFIER .. modStr .. colors.NORMAL .. " "
    end
    
    -- Add total
    msg = msg .. "= " .. colors.TOTAL .. rollData.total .. colors.NORMAL
    
    -- Add critical indicators
    if #rollData.rolls == 1 then
        if rollData.rolls[1] == 20 then
            msg = msg .. " " .. colors.CRITICAL_SUCCESS .. "CRITICAL!" .. colors.NORMAL
        elseif rollData.rolls[1] == 1 then
            msg = msg .. " " .. colors.CRITICAL_FAILURE .. "FUMBLE!" .. colors.NORMAL
        end
    end
    
    return msg
end

function Communication:CreateOutputFrame()
    -- Create frame for roll output
    local frame = CreateFrame("Frame", "ConflictEngineOutputFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 300)
    frame:SetPoint("LEFT", UIParent, "LEFT", 20, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:Hide()
    
    -- Make it movable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        if not CE.Database:GetSetting("outputWindowLocked") then
            frame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Conflict Engine Output")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
        CE.Database:SetSetting("showOutputWindow", false)
        -- Update checkbox if config panel is open
        if CE.UI.ConfigPanel and CE.UI.ConfigPanel.showOutputCheck then
            CE.UI.ConfigPanel.showOutputCheck:SetChecked(false)
        end
    end)
    
    -- Clear button
    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(60, 20)
    clearBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        self:ClearMessages()
    end)
    
    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "CEOutputScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -35)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 35)
    
    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(350, 1)
    scrollFrame:SetScrollChild(content)
    
    self.outputFrame = frame
    self.scrollFrame = scrollFrame
    self.content = content
    self.messages = {}
end

function Communication:AddMessage(message)
    -- Add message to output window
    local msgFrame = self.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    msgFrame:SetPoint("TOPLEFT", 5, -(#self.messages * 15))
    msgFrame:SetPoint("RIGHT", -5, 0)
    msgFrame:SetJustifyH("LEFT")
    msgFrame:SetText(message)
    
    table.insert(self.messages, msgFrame)
    
    -- Update content height
    self.content:SetHeight(math.max(1, #self.messages * 15 + 10))
    
    -- Limit to 100 messages
    if #self.messages > 100 then
        self.messages[1]:Hide()
        table.remove(self.messages, 1)
        
        -- Reposition remaining messages
        for i, msg in ipairs(self.messages) do
            msg:SetPoint("TOPLEFT", 5, -((i-1) * 15))
        end
    end
    
    -- Scroll to bottom
    self.scrollFrame:SetVerticalScroll(self.scrollFrame:GetVerticalScrollRange())
end

function Communication:ClearMessages()
    -- Clear all messages
    for _, msg in ipairs(self.messages) do
        msg:Hide()
    end
    self.messages = {}
    self.content:SetHeight(1)
end

function Communication:ShowOutput()
    self.outputFrame:Show()
end

function Communication:HideOutput()
    self.outputFrame:Hide()
end

function Communication:ToggleOutput()
    if self.outputFrame:IsShown() then
        self:HideOutput()
    else
        self:ShowOutput()
    end
end

function Communication:SetOutputLocked(locked)
    -- Locked status is stored in database
end