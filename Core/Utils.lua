local _, CE = ...

CE.Utils = {}

function CE.Utils:RollDice(sides, count)
    count = count or 1
    local results = {}
    local total = 0
    
    for i = 1, count do
        local roll = math.random(1, sides)
        table.insert(results, roll)
        total = total + roll
    end
    
    return {
        rolls = results,
        total = total,
        sides = sides,
        count = count
    }
end

function CE.Utils:FormatCurrency(copper, silver, gold)
    local parts = {}
    
    if gold and gold > 0 then
        table.insert(parts, string.format("|cFFFFD700%dg|r", gold))
    end
    if silver and silver > 0 then
        table.insert(parts, string.format("|cFFC0C0C0%ds|r", silver))
    end
    if copper and copper > 0 then
        table.insert(parts, string.format("|cFFC46B35%dc|r", copper))
    end
    
    return table.concat(parts, " ") ~= "" and table.concat(parts, " ") or "0c"
end

function CE.Utils:ParseDiceString(str)
    -- Remove spaces
    str = str:gsub("%s+", "")
    
    -- Parse strings like "2d6+3" or "1d20-2" or "d20+5"
    local count, sides, modifier = str:match("^(%d*)d(%d+)([%+%-]?%d*)$")
    
    if not sides then
        -- Try uppercase D
        count, sides, modifier = str:match("^(%d*)D(%d+)([%+%-]?%d*)$")
    end
    
    if not sides then
        return nil
    end
    
    -- Default count to 1 if not specified
    count = count ~= "" and tonumber(count) or 1
    sides = tonumber(sides)
    
    -- Parse modifier
    local mod = 0
    if modifier and modifier ~= "" then
        mod = tonumber(modifier) or 0
    end
    
    return {
        count = count,
        sides = sides,
        modifier = mod
    }
end

function CE.Utils:CalculateDefense()
    local defense = CE.Database:GetDefense()
    local total = 0
    
    -- Base armor defense
    local armorData = CE.Constants.ARMOR_TYPES[defense.armorType]
    if armorData then
        total = total + armorData.defense
    end
    
    -- Equipment bonuses
    if defense.hasShield then
        total = total + CE.Constants.SHIELD_DR
    end
    if defense.hasHelm then
        total = total + CE.Constants.HELM_DEFENSE
    end
    
    -- Custom modifiers
    total = total + (defense.customDefense or 0)
    
    return total
end

function CE.Utils:GetDamageReduction()
    local defense = CE.Database:GetDefense()
    local dr = {}
    
    -- Armor DR
    local armorData = CE.Constants.ARMOR_TYPES[defense.armorType]
    if armorData and armorData.dr then
        table.insert(dr, armorData.dr)
    end
    
    -- Shield DR
    if defense.hasShield then
        table.insert(dr, tostring(CE.Constants.SHIELD_DR))
    end
    
    -- Custom DR
    if defense.customDR and defense.customDR > 0 then
        table.insert(dr, tostring(defense.customDR))
    end
    
    return table.concat(dr, "+")
end