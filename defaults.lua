local addonName, addon = ...
addon.DB_NAME = "DABC_DB"
addon.shortName = "DABC"
addon.longName = "Dave's Action Bar Customizer"
addon.isBarInversed = false
addon.themes = {"Default", "None", "Modern"}
addon.ColorThemes = {"Custom", "Black/Dark", "Blue", "Green", "Pink", "Red", "White"}
addon.ColorThemesRGB = {
    [1] = {r=0,g=0,b=0,a=1}, -- Custom
    [2] = {r=0,g=0,b=0,a=1}, -- Black/Dark
    [3] = {r=0,g=0,b=1,a=1}, -- Blue
    [4] = {r=0,g=1,b=1,a=1}, -- Green
    [5] = {r=1,g=.1,b=0.75,a=1}, -- Pink
    [6] = {r=1,g=0,b=0,a=1}, -- Red
    [7] = {r=1,g=1,b=1,a=1}, -- White
}
addon.version = "1.0.2"
addon.defaults = {
  profile = {
    keybindFont = "Friz Quadrata TT",
    keybindSize = 12,
    cdFont = "Friz Quadrata TT",
    cdSize = 10,
    macroFont = "Friz Quadrata TT",
    macroSize = 10,
    showMacro = true,
    bars = {
      ActionBar1 = true,
      ActionBar2 = true,
      ActionBar3 = true,
      ActionBar4 = true,
      ActionBar5 = true,
      ActionBar6 = true,
      ActionBar7 = true,
      ActionBar8 = true,
    },
    barColor = {r=0,g=0,b=0,a=1},
    buttonColor = {r=0,g=0,b=0,a=1},
    borderColor = {r=0,g=0,b=0,a=1},
    theme = 1,
    inverseBar = false,
    padding = 2
  }
}
