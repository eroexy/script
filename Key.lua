local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/eroexy/script/refs/heads/main/README.md"))()

Orion.SelectedTheme = "Default"
local Window = Orion:MakeWindow({
	Name = "Moon | by X3D",

	ConfigFolder = "X3D_Moon",
	SaveConfig = true,

	HidePremium = false,

	IntroText = "Orion intro text",
	IntroEnabled = false,
	IntroIcon = "rbxassetid://8834748103",

	FreeMouse = false,
	KeyToOpenWindow = "M",

	CloseCallback = function()

	end,

	ShowIcon = false,
	Icon = "rbxassetid://8834748103"
})
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local Tab = Window:MakeTab({
	Name = "Key",
	Icon = "",
	PremiumOnly = false
})
