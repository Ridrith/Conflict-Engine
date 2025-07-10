local addonName, CE = ...

-- Create addon using AceAddon
local ConflictEngine = LibStub("AceAddon-3.0"):NewAddon("ConflictEngine", "AceEvent-3.0")
CE.addon = ConflictEngine

-- Store core modules
_G.ConflictEngine = CE

function ConflictEngine:OnInitialize()
    -- Create the main frame from XML with BackdropTemplate
    local frame = CreateFrame("Frame", "CE_MainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(900, 600)
    frame:SetPoint("CENTER")
    frame:Hide()
    
    -- Initialize Database first
    CE.Database:Initialize()
    
    -- Initialize other modules
    CE.Communication:Initialize()
    
    -- Initialize UI
    CE.UI.MainFrame:Initialize()
    
    -- Register slash commands
    SLASH_CONFLICTENGINE1 = "/ce"
    SLASH_CONFLICTENGINE2 = "/conflictengine"
    SlashCmdList["CONFLICTENGINE"] = function(msg)
        CE.UI.MainFrame:Toggle()
    end
    
    -- Load saved position
    C_Timer.After(0.5, function()
        CE.UI.MainFrame:LoadPosition()
    end)
    
    self:Print("Conflict Engine loaded! Type /ce to open.")
end

function ConflictEngine:OnEnable()
    -- Addon enabled
end

function ConflictEngine:OnDisable()
    -- Addon disabled
end

-- Utility print function
function ConflictEngine:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFF[Conflict Engine]|r " .. message)
end