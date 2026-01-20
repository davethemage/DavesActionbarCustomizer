local addonName, DABC = ...
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

StaticPopupDialogs["DABC_RELOADUI"] = {
    text = "You need to reload the UI for changes to take effect. Reload now?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function fontValues()
    local fonts = LSM:HashTable("font")
    local values = {}
    for name, _ in pairs(fonts) do
        values[name] = name -- key = label
    end
    return values
end

function DABC:SetupOptions()
  local options = {
    name = DABC.longName,
    type = "group",
    childGroups = "tab",
    args = {
      profile = {
        type = "group",
        name = "Profiles",
        order = 100,
        args = {
          selectProfile = {
            type = "select",
            dialogControl = 'Dropdown',
            name = "Select Profile",
            order = 1,
            values = function()
              local profiles = {}
              for _, name in ipairs(DABC.db:GetProfiles()) do
                  profiles[name] = name
              end
              return profiles
            end,
            get = function() return DABC.db:GetCurrentProfile() end,
            set = function(info, value)
              DABC.db:SetProfile(value)
              StaticPopup_Show("DABC_RELOADUI")
            end,
          },
          newProfile = {
            type = "input",
            name = "New Profile",
            order = 2,
            get = function() return "" end,
            set = function(info, value)
              if value and value ~= "" then
                DABC.db:SetProfile(value)
                StaticPopup_Show("DABC_RELOADUI")
              end
            end,
          },
          deleteProfile = {
            type = "execute",
            name = "Delete Profile",
            order = 3,
            func = function()
              local current = DABC.db:GetCurrentProfile()
              DABC.db:SetProfile("Default")
              DABC.db:DeleteProfile(current)
              StaticPopup_Show("DABC_RELOADUI")
            end,
            confirm = function() return "Are you sure?" end,
            disabled = function() return DABC.db:GetCurrentProfile() == "Default" end,
          },
        },
      }, --end profile
      settings = {
        type = "group",
        name = "Action Bar Customizer",
        order = 1,
        args = {
          keybind = {
            name = "Font Options",
            type = "group",
            order = 10,
            args = {
              keyFont = {
                type = "select",
                name = "Keybind Font",
                order = 1,
                values = fontValues,
                get = function() return DABC.db.profile.keybindFont end,
                set = function(info, value) DABC.db.profile.keybindFont = value; DABC:UpdateActionBars() end,
              },
              keySize = {
                type = "range",
                name = "Keybind Size",
                order = 2,
                min = 6, max = 32, step = 1,
                get = function() return DABC.db.profile.keybindSize end,
                set = function(info, value) DABC.db.profile.keybindSize = value; DABC:UpdateActionBars() end,
              },
              spacer10 = {
                type = "description",
                name = " ",
                order = 10,
              },
              macroFont = {
                type = "select",
                name = "Macro Font",
                order = 11,
                values = fontValues,
                get = function() return DABC.db.profile.macroFont end,
                set = function(info, value) DABC.db.profile.macroFont = value; DABC:UpdateActionBars() end,
              },
              macroSize = {
                type = "range",
                name = "Macro Size",
                order = 12,
                min = 6, max = 32, step = 1,
                get = function() return DABC.db.profile.macroSize end,
                set = function(info, value) DABC.db.profile.macroSize = value; DABC:UpdateActionBars() end,
              },
              showMacro = {
                type = "toggle",
                name = "Show Macro Text",
                order = 13,
                get = function() return DABC.db.profile.showMacro end,
                set = function(info, value) DABC.db.profile.showMacro = value; DABC:UpdateActionBars() end,
              },
              spacer20 = {
                type = "description",
                name = " ",
                order = 20,
              },
              cdFont = {
                type = "select",
                name = "Cooldown Font",
                order = 21,
                values = fontValues,
                get = function() return DABC.db.profile.cdFont end,
                set = function(info, value) DABC.db.profile.cdFont = value; DABC:UpdateActionBars() end,
              },
              cdSize = {
                type = "range",
                name = "Cooldown Size",
                order = 22,
                min = 6, max = 32, step = 1,
                get = function() return DABC.db.profile.cdSize end,
                set = function(info, value) DABC.db.profile.cdSize = value; DABC:UpdateActionBars() end,
              },
              cdEnable = {
                type = "toggle",
                name = "Show Cooldown Numbers",
                width = "double",
                order = 23,
                get = function() return GetCVarBool("countdownForCooldowns") end,
                set = function(info, value) SetCVar("countdownForCooldowns", value and 1 or 0) end,
              },
            },
          },
          bars = {
            type = "group",
            name = "Enabled Bars",
            order = 1,
            args = {}
          },
          dispOpt = {
            type = "group",
            name = "Display Options",
            order = 2,
            args = {
              theme = {
                type = "select",
                name = "Theme(All bars)",
                order = 1,
                values = DABC.themes,
                get = function() return DABC.db.profile.theme end,
                set = function(info, value) 
                  DABC.db.profile.theme = value; 
                  -- if value > 2 then
                  --   DABC.db.profile.colorTheme = 1; 
                  -- end
                  StaticPopup_Show("DABC_RELOADUI")
                end
              },
              spacer10 = {
                type = "description",
                name = " ",
                order = 10,
              },
              colorTheme = {
                type = "select",
                name = "Color(non-default)",
                order = 11,
                values = DABC.ColorThemes,
                get = function() return DABC.db.profile.colorTheme end,
                set = function(info, value) 
                  if DABC.db.profile.theme == 1 or DABC.db.profile.theme == 2 then --default 
                    DABC.db.profile.theme = 3
                  end
                  DABC.db.profile.colorTheme = value; 
                  DABC.db.profile.buttonColor = DABC.ColorThemesRGB[value]
                  DABC.db.profile.borderColor = DABC.ColorThemesRGB[value]
                  StaticPopup_Show("DABC_RELOADUI")
                end
              },
              spacer17 = {
                type = "description",
                name = " ",
                order = 17,
              },
              colorizeButton = {
                type = "color",
                name = "Button Color",
                desc = "Custom color",
                order = 18,
                hasAlpha = true,
                get = function(info)
                  local color =  DABC.db.profile.buttonColor or {r=0,g=0,b=0,a=1}
                  return color.r, color.g, color.b, color.a
                end,
                set = function(info, r, g, b, a)
                  DABC.db.profile.buttonColor = { r = r, g = g, b = b, a = a }
                  if DABC.db.profile.theme == 1 or DABC.db.profile.theme == 2 then --default 
                    DABC.db.profile.theme = 3
                  end
                  StaticPopup_Show("DABC_RELOADUI")
                end, 
              },
              colorizeBorder = {
                type = "color",
                name = "Button Border Color",
                desc = "Custom color",
                order = 19,
                hasAlpha = true,
                get = function(info)
                  local color =  DABC.db.profile.borderColor or {r=0,g=0,b=0,a=1}
                  return color.r, color.g, color.b, color.a
                end,
                set = function(info, r, g, b, a)
                  DABC.db.profile.borderColor = { r = r, g = g, b = b, a = a }
                  if DABC.db.profile.theme == 1 or DABC.db.profile.theme == 2 then --default 
                    DABC.db.profile.theme = 3
                  end
                  StaticPopup_Show("DABC_RELOADUI")
                end, 
              },
              spacer20 = {
                type = "description",
                name = " ",
                order = 20,
              },
              invert= {
                type = "toggle",
                name = "Inverse vertical bars",
                order = 21,
                get = function() return DABC.db.profile.inverseBar end,
                set = function(info, value)
                  DABC.db.profile.inverseBar = value
                  DABC:inverseBars(value)
                end,
              },
              spacer30 = { 
                type = "description",
                name = " ",
                order = 30, 
              },
            }
          } --end dispOpt
        } --end settings->args
      } --end settings
    } --end options->args
  } --end options

  local bars = {"ActionBar1","ActionBar2","ActionBar3","ActionBar4","ActionBar5","ActionBar6","ActionBar7","ActionBar8"}

  -- "All Bars" toggle at the top
  local bars_args = options.args.settings.args.bars.args
  bars_args.allBars = {
    type = "toggle",
    name = "|cff00ff00All Bars|r",
    desc = "Toggle all action bars on or off.",
    order = 0,
    get = function()
      for _, bar in ipairs(bars) do
        if not DABC.db.profile.bars[bar] then
            return false
        end
      end
      return true
    end,
    set = function(info, value)
      for _, bar in ipairs(bars) do
        DABC.db.profile.bars[bar] = value
      end
      DABC:UpdateActionBars()
    end,
  }
  bars_args.spacer = {
    type = "description",
    name = " ",
    order = 1,
  }
  -- Individual bar toggles
  for i, bar in ipairs(bars) do
    bars_args[bar] = {
      type = "toggle",
      name = bar,
      order = i+10,
      get = function() return DABC.db.profile.bars[bar] end,
      set = function(info, value)
        DABC.db.profile.bars[bar] = value
        DABC:UpdateActionBars()
      end,
    }
  end
  
-- Register your main options
  local parent_name = "Blizzard Customizer"
  if not _G.DavesCustomizerParentRegistered then
    AceConfig:RegisterOptionsTable("Blizzard Customizer", {
        name = "Dave's " .. parent_name,
        type = "group",
        args = {
            description = {
                type = "description",
                name = "Customize default Blizzard UI",
            },
        },
    })
    AceConfigDialog:AddToBlizOptions(parent_name, parent_name)
    _G.DavesCustomizerParentRegistered = true
   end
   
  AceConfig:RegisterOptionsTable(DABC.shortName, options)
  AceConfigDialog:AddToBlizOptions(DABC.shortName, "Action Bar", parent_name)
end