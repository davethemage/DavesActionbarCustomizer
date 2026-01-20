local addonName, addon = ...
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local DABC = AceAddon:NewAddon(addon, addonName, "AceConsole-3.0")

DABC.barButtons = {
    ActionBar1 = {"ActionButton", 12},
    ActionBar2 = {"MultiBarBottomLeftButton", 12},
    ActionBar3 = {"MultiBarBottomRightButton", 12},
    ActionBar4 = {"MultiBarRightButton", 12},
    ActionBar5 = {"MultiBarLeftButton", 12},
    ActionBar6 = {"MultiBar5Button", 12},
    ActionBar7 = {"MultiBar6Button", 12},
    ActionBar8 = {"MultiBar7Button", 12},
}

-- Keybind cleanup function
local function CleanKeybindText(text)
    if not text then return "" end
    text = text:upper()
    text = text:gsub("CTRL%-", "C")
    text = text:gsub("ALT%-", "A")
    text = text:gsub("SHIFT%-", "S")
    text = text:gsub("NUMPAD", "NP")
    text = text:gsub("BUTTON", "M")
    text = text:gsub("MOUSEWHEELUP", "MWU")
    text = text:gsub("MOUSEWHEELDOWN", "MWD")
    if text:sub(-1) == "-" then
        text = text:gsub("%-", "") .. "-"
    else
        text = text:gsub("%-", "")
    end
    text = text:gsub("%s", "")
    return text
end

function DABC:RefreshConfig()
    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0", true)
    local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)

    if AceConfigRegistry then
        AceConfigRegistry:NotifyChange(self.name or addon.shortName)
    end
    if AceConfigDialog and AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames[addon.shortName] then
        AceConfigDialog:SelectGroup(addon.shortName)
    end

    self:UpdateActionBars()
    self:inverseBars()

    -- user feedback
    --DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00["..addon.shortName.."]|r Profile loaded: " .. self.db:GetCurrentProfile())
end


function DABC:OnInitialize()
    -- Initialize DB with defaults
    self.db = AceDB:New("DABC_DB", addon.defaults, true)
    -- Register profile change callbacks
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileDeleted", "RefreshConfig")

    -- Initialize options GUI
    self:SetupOptions()
    
    -- Register slash command
    self:RegisterChatCommand(addon.shortName:lower(), "OpenOptions")
    
    -- Update action bars on load
    self:UpdateActionBars()
    -- print out status
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00["..addon.shortName.."]|r ".. addon.longName .." v".. addon.version .. " - |cff00ff00/".. addon.shortName:lower() .. "|r")
end

function DABC:OpenOptions()
    AceConfigDialog:Open(addon.shortName)
end

-- Update all bars
function DABC:UpdateActionBars()
    for bar, enabled in pairs(self.db.profile.bars) do
        if enabled then
            self:UpdateBar(bar)
        end
    end
end

function DABC:inverseBars()
    if DABC.db.profile.inverseBar ~= addon.isBarInversed then
        local bar_names = {
            [1] = 'MainActionBar',
            [2] = 'MultiBarBottomLeft',
            [3] = 'MultiBarBottomRight',
            [4] = 'MultiBarRight',
            [5] = 'MultiBarLeft',
            [6] = 'MultiBar5',
            [7] = 'MultiBar6',
            [8] = 'MultiBar7',
        }
        for _, bar in pairs(bar_names) do
            _G[bar].addButtonsToTop = not _G[bar].addButtonsToTop
            _G[bar]:UpdateGridLayout()
        end
        addon.isBarInversed = not addon.isBarInversed
    end
end

-- Update individual bar
function DABC:UpdateBar(barName)
    local data = self.barButtons[barName]
    if not data then return end
    local prefix, count = data[1], data[2]
    for i = 1, count do
        local button = _G[prefix..i]
        if button then
            if button.HotKey then
                button.HotKey:SetFont(LSM:Fetch("font", self.db.profile.keybindFont), self.db.profile.keybindSize, "OUTLINE")
                button.HotKey:SetText(CleanKeybindText(button.HotKey:GetText()))
                button.HotKey:SetJustifyH("RIGHT")
                button.HotKey:SetJustifyV("TOP")
                button.HotKey:SetWidth(64)
                button.HotKey:SetHeight(14)
                button.HotKey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -2)
            end
            if button.Count then
                button.Count:SetFont(LSM:Fetch("font", self.db.profile.keybindFont), self.db.profile.keybindSize, "OUTLINE")
            end
            if button.Name then
                if self.db.profile.showMacro then
                    button.Name:SetFont(LSM:Fetch("font", self.db.profile.macroFont), self.db.profile.macroSize, "OUTLINE")
                    button.Name:Show()
                else
                    button.Name:Hide()
                end
            end
            local cd = button.cooldown
            if cd and cd.GetRegions then
            for _, region in ipairs({ cd:GetRegions() }) do
                if region and region:GetObjectType() == "FontString" then
                    region:SetFont(LSM:Fetch("font", DABC.db.profile.cdFont), DABC.db.profile.cdSize, "OUTLINE")
                    end
                end
            end   
        end
    end
end

--Load on login
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    DABC:RefreshConfig()
end)