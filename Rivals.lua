--// Services

--// Locals

--// libary

local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()

Orion.SelectedTheme = "Default"
local Window = Orion:MakeWindow({
  Name = "Rivals | by X3D",

  ConfigFolder = "X3D_Rivals",
  SaveConfig = false,

  HidePremium = false,

  IntroText = "Orion intro text",
  IntroEnabled = false,
  IntroIcon = "rbxassetid://8834748103",

  FreeMouse = false,
  KeyToOpenWindow = "RightShift",
  
  CloseCallback = function()
    
  end,

  ShowIcon = false,
  Icon = "rbxassetid://8834748103"
})

local Tab = Window:MakeTab({
  Name = "ESP",
  Icon = "rbxassetid://10723346959",
  PremiumOnly = false
})

--// init
Orion:Init()
