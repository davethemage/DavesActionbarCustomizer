local addonName, DABC_Addon = ...
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- ==============================
-- Slash command
-- ==============================
SLASH_DABC1 = "/" .. DABC_Addon.shortName:lower()
SlashCmdList[DABC_Addon.shortName] = function(msg)
    if DABC_Addon.shortName then
        AceConfigDialog:Open(DABC_Addon.shortName)
    else
        print(DABC_Addon.shortName .. ": Cannot open config")
    end
end
