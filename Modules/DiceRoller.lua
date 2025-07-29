local _, CE = ...
CE.DiceRoller = CE.DiceRoller or {}

function CE.DiceRoller:HandleSlashRoll(msg)
    local expression = msg:match("^%s*(.-)%s*$")
    if expression == "" or not expression then
        print("|cffFFD700Usage: /ceroll 2d6+Might|r")
        return
    end

    local roll, errorMsg = self:ParseRollExpression(expression)
    if not roll then
        print("|cffff4444Error:|r " .. errorMsg)
        return
    end

    local resultText = self:EvaluateRoll(roll)
    print(string.format("|cff00ff00[CE Roll]|r %s = %s", expression, resultText))
end

-- Parses "2d6+Might" into a roll table
function CE.DiceRoller:ParseRollExpression(expr)
    local numDice, sides, modifierName = expr:match("^(%d+)[dD](%d+)%+?(%a*)$")
    if not numDice or not sides then
        return nil, "Invalid format. Use NdM or NdM+Stat (e.g., 2d6+Might)."
    end

    numDice = tonumber(numDice)
    sides = tonumber(sides)

    if numDice < 1 or sides < 1 then
        return nil, "Dice number and sides must be positive."
    end

    -- Normalize the modifier to capitalized form
    if modifierName and modifierName ~= "" then
        modifierName = modifierName:sub(1, 1):upper() .. modifierName:sub(2):lower()
    end

    return {
        numDice = numDice,
        sides = sides,
        modifierName = modifierName
    }
end


-- Evaluates the parsed expression
function CE.DiceRoller:EvaluateRoll(roll)
    local total = 0
    local rolls = {}

    for i = 1, roll.numDice do
        local r = math.random(1, roll.sides)
        table.insert(rolls, r)
        total = total + r
    end

    -- Pull modifier from Attributes if it exists
    local modifier = 0
    if roll.modifierName and roll.modifierName ~= "" then
        local attrFrames = CE.UI.AttributesPanel and CE.UI.AttributesPanel.attributes
        local frame = attrFrames and attrFrames[roll.modifierName]
        if frame and frame.valueText then
            modifier = tonumber(frame.valueText:GetText()) or 0
        else
            print(string.format("|cffffaaaaWarning: Stat '%s' not found. Assuming +0.|r", roll.modifierName))
        end
    end

    total = total + modifier

    return string.format("(%s) + %d = |cffFFD700%d|r", table.concat(rolls, ", "), modifier, total)
end
