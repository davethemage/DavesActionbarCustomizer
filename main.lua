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

-- Map ActionBar names to their bar objects
DABC.barNames = {
    ActionBar1 = "MainActionBar",
    ActionBar2 = "MultiBarBottomLeft",
    ActionBar3 = "MultiBarBottomRight",
    ActionBar4 = "MultiBarRight",
    ActionBar5 = "MultiBarLeft",
    ActionBar6 = "MultiBar5",
    ActionBar7 = "MultiBar6",
    ActionBar8 = "MultiBar7",
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

-- Update individual bar
function DABC:UpdateBar(barName)
    local data = self.barButtons[barName]
    if not data then return end
    local prefix, count = data[1], data[2]

    -- Get padding settings
    local overridePadding = self.db.profile.overridePadding
    local paddingValue = overridePadding and (self.db.profile.padding or 0) or 0

    -- Get the bar object to access row/button information
    local barObjName = self.barNames[barName]
    local bar = barObjName and _G[barObjName]

    local buttonsPerRow = 12
    if bar and bar.numRows and bar.numButtons then
        buttonsPerRow = math.ceil(bar.numButtons / bar.numRows)
    end

    -- When padding is disabled, reset the bar layout to Blizzard defaults
    if not overridePadding and bar then
        paddingValue = bar.buttonPadding or 2
    end

    -- Always loop from 1 to count
    for i = 1, count do
        local button = _G[prefix..i]
        if button then
            -- Clear existing anchor points to avoid circular dependencies
            button:ClearAllPoints()

            -- Calculate which row and position this button is in
            local buttonPosition = i - 1  -- 0-indexed position
            local row = math.floor(buttonPosition / buttonsPerRow)
            local col = buttonPosition % buttonsPerRow
            local isFirstInRow = (col == 0)

            -- Apply padding calculations
            if i == 1 then
                -- Button 1: anchor based on inverseBar setting
                if DABC.db.profile.inverseBar then
                    -- Anchor to top-left
                    button:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
                else
                    -- Anchor to bottom-left
                    button:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
                end
            elseif not isFirstInRow then
                -- Not first in row: anchor to previous button (grow right)
                local prevButton = _G[prefix..(i-1)]
                if DABC.db.profile.inverseBar then
                    button:SetPoint("TOPLEFT", prevButton, "TOPRIGHT", paddingValue, 0)
                else
                    button:SetPoint("BOTTOMLEFT", prevButton, "BOTTOMRIGHT", paddingValue, 0)
                end
            else
                -- First button of a new row: anchor to the button in the previous row
                local buttonInPrevRow = _G[prefix..(i - buttonsPerRow)]
                if buttonInPrevRow then
                    if DABC.db.profile.inverseBar then
                        -- Grow down
                        button:SetPoint("TOPLEFT", buttonInPrevRow, "BOTTOMLEFT", 0, -paddingValue)
                    else
                        -- Grow up
                        button:SetPoint("BOTTOMLEFT", buttonInPrevRow, "TOPLEFT", 0, paddingValue)
                    end
                end
            end

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

    -- Update bar size based on button layout
    if bar and overridePadding then
        local firstButton = _G[prefix.."1"]
        if firstButton then
            local scale = firstButton:GetParent():GetScale() or 1
            local buttonWidth = firstButton:GetWidth() * scale
            local buttonHeight = firstButton:GetHeight() * scale

            -- Calculate number of rows
            local numRows = math.ceil(count / buttonsPerRow)

            -- Calculate total width: (buttons * width) + (padding between buttons)
            local totalWidth = (buttonsPerRow * buttonWidth) + ((buttonsPerRow - 1) * paddingValue)

            -- Calculate total height: (rows * height) + (padding between rows)
            local totalHeight = (numRows * buttonHeight) + ((numRows - 1) * paddingValue)

            bar:SetWidth(totalWidth)
            bar:SetHeight(totalHeight)
        end
    end
end

--Load on login
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    DABC:RefreshConfig()
end)