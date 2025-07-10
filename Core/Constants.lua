local _, CE = ...

CE.Constants = {
    -- Addon communication prefix
    COMM_PREFIX = "ConflictEngine",
    
    -- Attribute names
    ATTRIBUTES = {
        "Might", "Finesse", "Endurance",
        "Insight", "Resolve", "Presence",
        "Faith", "Magic", "Luck"
    },
    
    -- Attribute limits (now as modifiers)
    ATTRIBUTE_MIN = -3,
    ATTRIBUTE_MAX = 12,
    ATTRIBUTE_DEFAULT = 0,
    
    -- Dice types
    DICE_TYPES = {
        {name = "D2", sides = 2},
        {name = "D4", sides = 4},
        {name = "D6", sides = 6},
        {name = "D8", sides = 8},
        {name = "D10", sides = 10},
        {name = "D12", sides = 12},
        {name = "D20", sides = 20},
        {name = "D100", sides = 100}
    },
    
    -- Armor types
    ARMOR_TYPES = {
        NONE = {defense = 0, dr = ""},
        LIGHT = {defense = 3, dr = "D4"},
        MEDIUM = {defense = 2, dr = "D6"},
        HEAVY = {defense = -2, dr = "D8"}
    },
    
    -- Equipment bonuses
    SHIELD_DR = 1,
    HELM_DEFENSE = 1,
    
    -- Roll message colors
    ROLL_COLORS = {
        NORMAL = "|cFFFFFFFF",
        ATTRIBUTE = "|cFF00FF00",
        DICE = "|cFF00BFFF",
        DEFENSE = "|cFFFF7F00",
        DAMAGE = "|cFFFF0000",
        TRAIT = "|cFFFF00FF",
        MODIFIER = "|cFFFFFF00",
        TOTAL = "|cFFFFD700",
        SUCCESS = "|cFF00FF00",
        FAILURE = "|cFFFF0000",
        CRITICAL_SUCCESS = "|cFF00FFFF",
        CRITICAL_FAILURE = "|cFFFF00FF"
    }
}