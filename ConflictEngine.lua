local addonName, CE = ...

-- Create addon using AceAddon
local ConflictEngine = LibStub("AceAddon-3.0"):NewAddon("ConflictEngine", "AceEvent-3.0")
CE.addon = ConflictEngine

-- Store core modules globally
_G.ConflictEngine = CE

function ConflictEngine:OnInitialize()
    -- Create the main frame
    local frame = CreateFrame("Frame", "CE_MainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(900, 600)
    frame:SetPoint("CENTER")
    frame:Hide()

    -- Init database
    CE.Database:Initialize()

    -- Init communication
    CE.Communication:Initialize()

    -- Init UI
    CE.UI.MainFrame:Initialize()

    -- Load saved position
    C_Timer.After(0.5, function()
        CE.UI.MainFrame:LoadPosition()
    end)

    -- Register slash commands after all modules are loaded
    C_Timer.After(1, function()
        SLASH_CONFLICTENGINE1 = "/ce"
        SLASH_CONFLICTENGINE2 = "/conflictengine"
        SlashCmdList["CONFLICTENGINE"] = function(msg)
            CE.UI.MainFrame:Toggle()
        end

        SLASH_CEROLL1 = "/ceroll"
        SlashCmdList["CEROLL"] = function(msg)
            if CE.DiceRoller and CE.DiceRoller.HandleSlashRoll then
                CE.DiceRoller:HandleSlashRoll(msg)
            else
                print("Conflict Engine: DiceRoller not initialized.")
            end
        end
    end)

    self:Print("Conflict Engine loaded! Type /ce to open.")
end

function ConflictEngine:OnEnable() end
function ConflictEngine:OnDisable() end

function ConflictEngine:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00BFFF[Conflict Engine]|r " .. message)
end

