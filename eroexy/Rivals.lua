// Services

// Locals

// libary

local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()

local Window = Orion:MakeWindow({
  Name = "Orion",

  ConfigFolder = "X3Drivals",
  SaveConfig = true,

  HidePremium = false,
  IntroEnabled = false,

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

// init
Orion:Init()
