--//////////////////////////////////////////////////////////////////////////////
-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
--//////////////////////////////////////////////////////////////////////////////
-- Locals
local Player = Players.LocalPlayer
local mouse = Player:GetMouse()
local Char = Player.Character
local Hrp = Char:WaitForChild("HumanoidRootPart")
local Human = Char:WaitForChild("Humanoid")

--//////////////////////////////////////////////////////////////////////////////
-- Orion
local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()

Orion.SelectedTheme = "Default"
local Window = Orion:MakeWindow({
	Name = "VD Script",

	ConfigFolder = "eroexyXVD",
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

--//////////////////////////////////////////////////////////////////////////////
--// Survivor Tab
local Tab = Window:MakeTab({
	Name = "Survivor",
	Icon = "rbxassetid://10734920149",
	PremiumOnly = false
})
--//////////////////////////////////////////////////////////////////////////////



--//////////////////////////////////////////////////////////////////////////////
--// UI

--//////////////////////////////////////////////////////////////////////////////
--// Survivor Tab
local Tab = Window:MakeTab({
	Name = "Killer",
	Icon = "rbxassetid://10747374003",
	PremiumOnly = false
})
--//////////////////////////////////////////////////////////////////////////////



--//////////////////////////////////////////////////////////////////////////////
--// Player Tab
local Tab = Window:MakeTab({
	Name = "Player",
	Icon = "rbxassetid://10734920149",
	PremiumOnly = false
})
--//////////////////////////////////////////////////////////////////////////////

local NoClipToggle = false
local NoClipConnection

Player.CharacterAdded:Connect(function(newChar)
	Char = newChar
end)

local function StartNoClip()
	if NoClipConnection then return end
	
	NoClipConnection = RunService.RenderStepped:Connect(function()
		if not NoClipToggle or not Char then return end
		
		for _, part in ipairs(Char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end)
end

local function StopNoClip()
	if NoClipConnection then
		NoClipConnection:Disconnect()
		NoClipConnection = nil
	end
	
	if not Char then return end
	
	for _, part in ipairs(Char:GetDescendants()) do
		if part:IsA("HumanoidRootPart") then
			part.CanCollide = true
		end
	end
end

--//////////////////////////////////////////////////////////////////////////////
-- WalkSpeed

local WalkSpeedToggle = false
local WalkSpeedValue = 16
local MoveConnection

local function SetupCharacter(character)
	Char = character
	Hrp = Char:WaitForChild("HumanoidRootPart")
	Human = Char:WaitForChild("Humanoid")
end

if Player.Character then
	SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(SetupCharacter)

--//////////////////////////////////////////////////////////////////////////////
-- Jump Stuff

local JumpToggle = false
local JumpPowerValue = Human.JumpPower

UserInputService.JumpRequest:Connect(function()
	if JumpToggle then
		Human:ChangeState(Enum.HumanoidStateType.Jumping)
		Human.JumpPower = JumpPowerValue
	end
end)

--//////////////////////////////////////////////////////////////////////////////
-- Fov

local Camera = workspace.CurrentCamera
local DefaultFOV = Camera.FieldOfView
local SliderFovValue = 80
local FovToggle = false

--//////////////////////////////////////////////////////////////////////////////
-- UI

local Section = Tab:AddSection({Name = "Character"})

Tab:AddToggle({
	Name = "No-Clip",
	Default = false,
	Icon = "",
	Color = Color3.fromRGB(9, 99, 195),
	Flag = "NoClip",
	Save = true,
	Callback = function(Value)
		NoClipToggle = Value

		if Value then
			StartNoClip()
		else
			StopNoClip()
		end
	end
})

local Section = Tab:AddSection({Name = "Movement"})

Tab:AddToggle({
	Name = "Walkspeed",
	Default = false,
	Flag = "WalkSpeedToggle",
	Save = true,
	Callback = function(Value)
		WalkSpeedToggle = Value

		if MoveConnection then
			MoveConnection:Disconnect()
			MoveConnection = nil
		end

		if WalkSpeedToggle then
			MoveConnection = RunService.RenderStepped:Connect(function(delta)
				if Human and Hrp then
					local moveDir = Human.MoveDirection
					if moveDir.Magnitude > 0 then
						Hrp.CFrame += moveDir * WalkSpeedValue * delta
					end
				end
			end)
		end
	end
})

Tab:AddSlider({
	Name = "Walkspeed",
	Default = 16,
	Min = 5,
	Max = 300,
	Increment = 5,
	Flag = "WalkSpeedSlider",
	Save = true,
	Callback = function(Value)
		WalkSpeedValue = Value
	end
})


Tab:AddToggle({
	Name = "Infinite Jump",
	Default = false,
	Flag = "InfiniteJumpToggle",
	Save = true,
	Callback = function(Value)
		JumpToggle = Value
	end
})

Tab:AddSlider({
	Name = "Jump Power",
	Default = Human.JumpPower,
	Min = 0,
	Max = 300,
	Increment = 5,
	Flag = "JumpPowerSlider",
	Save = true,
	Callback = function(Value)
		JumpPowerValue = Value
		Human.JumpPower = JumpPowerValue
	end
})

local Section = Tab:AddSection({Name = "Camera"})

Tab:AddToggle({
	Name = "Toggle Fov",
	Default = false,
	Icon = "",
	Color = Color3.fromRGB(9, 99, 195),
	Flag = "FovToggle",
	Save = true,
	Callback = function(Value)
		FovToggle = Value
		if not FovToggle then
			Camera.FieldOfView = DefaultFOV
		else
			while true and FovToggle do

				Camera.FieldOfView = SliderValue
				task.wait(0)
			end
		end
	end
})

Tab:AddSlider({
	Name = "",
	Default = DefaultFOV,
	Min = 80,
	Max = 120,
	Increment = 1,
	Flag = "FovSlider",
	ValueName = "Fov",
	Color = Color3.fromRGB(9, 99, 195),
	Save = false,
	Callback = function(Value)
		SliderValue = Value
		if FovToggle then
			Camera.FieldOfView = SliderValue
		end
	end
})

--//////////////////////////////////////////////////////////////////////////////
--// ESP Tab
local Tab = Window:MakeTab({
	Name = "ESP",
	Icon = "rbxassetid://10723346959",
	PremiumOnly = false
})
--//////////////////////////////////////////////////////////////////////////////

local Killer = "Killer"
local Survivor = "Survivors"
local Spectator = "Spectator"

local KillerESP = false
local SurvivorESP = false
local SpectatorESP = false

local function RemoveESP(character)
	for _, v in ipairs(character:GetChildren()) do
		if v:IsA("Highlight") then
			v:Destroy()
		end
	end
end

local function CreateHighlight(character, name, color)
	local hl = Instance.new("Highlight")
	hl.Name = name
	hl.FillTransparency = 0.7
	hl.OutlineTransparency = 1
	hl.FillColor = color
	hl.Adornee = character
	hl.Parent = character
end

local function UpdateRole(plr, character)
	if plr == Player then return end
	if not character then return end

	local team = plr.Team
	if not team then return end

	RemoveESP(character)

	if team.Name == Killer and KillerESP then
		CreateHighlight(character, "KillerESP", team.TeamColor.Color)
		return
	end

	if (team.Name == Survivor or team.Name == Spectator) and SurvivorESP then
		CreateHighlight(character, "PlayerESP", team.TeamColor.Color)
	end
end

local function SetupPlayer(plr)
	if plr == Player then return end

	plr.CharacterAdded:Connect(function(character)
		UpdateRole(plr, character)
	end)

	plr:GetPropertyChangedSignal("Team"):Connect(function()
		if plr.Character then
			UpdateRole(plr, plr.Character)
		end
	end)

	if plr.Character then
		UpdateRole(plr, plr.Character)
	end
end

local function RefreshAll()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player and plr.Character then
			UpdateRole(plr, plr.Character)
		end
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	SetupPlayer(plr)
end

Players.PlayerAdded:Connect(SetupPlayer)

--//////////////////////////////////////////////////////////////////////////////
-- Map ESP

local Map = Workspace:WaitForChild("Map")

local ActiveHighlights = {}
local CachedModels = {
    Generator = {},
    Hook = {},
    Palletwrong = {},
    Window = {}
}

local ESPTypes = {
    Generator = {Color = Color3.fromRGB(235,235,235), Enabled = false},
    Hook = {Color = Color3.fromRGB(255,0,0), Enabled = false},
    Palletwrong = {Color = Color3.fromRGB(255,255,0), Enabled = false},
    Window = {Color = Color3.fromRGB(0,0,255), Enabled = false},
}

local function addHighlight(obj, color)
    if ActiveHighlights[obj] then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 1
    hl.Adornee = obj
    hl.Parent = obj
    ActiveHighlights[obj] = hl
end

local function removeHighlight(obj)
    local hl = ActiveHighlights[obj]
    if hl then
        hl:Destroy()
        ActiveHighlights[obj] = nil
    end
end

local function getWindowBottom(windowModel)
    return windowModel:FindFirstChild("Bottom", true)
end

local function cacheModel(model)
    if not CachedModels[model.Name] then return end
    if table.find(CachedModels[model.Name], model) then return end

    table.insert(CachedModels[model.Name], model)

    if ESPTypes[model.Name].Enabled then
        if model.Name == "Window" then
            local bottom = getWindowBottom(model)
            if bottom and bottom:IsA("BasePart") then
                addHighlight(bottom, ESPTypes.Window.Color)
            end
        else
            addHighlight(model, ESPTypes[model.Name].Color)
        end
    end
end

local function uncacheModel(model)
    if not CachedModels[model.Name] then return end

    local index = table.find(CachedModels[model.Name], model)
    if index then
        table.remove(CachedModels[model.Name], index)
    end

    if model.Name == "Window" then
        local bottom = getWindowBottom(model)
        if bottom then
            removeHighlight(bottom)
        end
    else
        removeHighlight(model)
    end
end

local function initialScan()
    for _, obj in ipairs(Map:GetDescendants()) do
        if obj:IsA("Model") then
            cacheModel(obj)
        end
    end
end

local function updateType(typeName)
    local config = ESPTypes[typeName]
    for _, model in ipairs(CachedModels[typeName]) do
        if model and model.Parent then
            if typeName == "Window" then
                local bottom = getWindowBottom(model)
                if bottom and bottom:IsA("BasePart") then
                    if config.Enabled then
                        addHighlight(bottom, config.Color)
                    else
                        removeHighlight(bottom)
                    end
                end
            else
                if config.Enabled then
                    addHighlight(model, config.Color)
                else
                    removeHighlight(model)
                end
            end
        end
    end
end

Map.ChildRemoved:Connect(function()
    if #Map:GetChildren() == 0 then
        for k in pairs(CachedModels) do
            CachedModels[k] = {}
        end
        for obj in pairs(ActiveHighlights) do
            removeHighlight(obj)
        end
    end
end)

Map.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        cacheModel(obj)
    end
end)

Map.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") then
        uncacheModel(obj)
    end
end)

initialScan()

--//////////////////////////////////////////////////////////////////////////////
-- UI

local Section = Tab:AddSection({Name = "Players"})

Tab:AddToggle({
	Name = "Player Chams",
	Default = false,
	Flag = "SurvivorESP",
	Save = true,
	Callback = function(Value)
		SurvivorESP = Value
		RefreshAll()
	end
})

local Section = Tab:AddSection({Name = "Killer"})

Tab:AddToggle({
	Name = "Killer Cham",
	Default = false,
	Flag = "KillerESP",
	Save = true,
	Callback = function(Value)
		KillerESP = Value
		RefreshAll()
	end
})

local Section = Tab:AddSection({Name = "Map"})

Tab:AddToggle({
    Name = "Generator Chams",
    Default = false,
    Color = Color3.fromRGB(128,128,128),
    Flag = "GeneratorESP",
    Save = false,
    Callback = function(Value)
        ESPTypes.Generator.Enabled = Value
        updateType("Generator")
    end
})

Tab:AddToggle({
    Name = "Hook Chams",
    Default = false,
    Color = Color3.fromRGB(255,0,0),
    Flag = "HookESP",
    Save = false,
    Callback = function(Value)
        ESPTypes.Hook.Enabled = Value
        updateType("Hook")
    end
})

Tab:AddToggle({
    Name = "Pallet Chams",
    Default = false,
    Color = Color3.fromRGB(255,255,0),
    Flag = "PalletwrongESP",
    Save = false,
    Callback = function(Value)
        ESPTypes.Palletwrong.Enabled = Value
        updateType("Palletwrong")
    end
})

Tab:AddToggle({
    Name = "Window Chams",
    Default = false,
    Color = Color3.fromRGB(0,0,255),
    Flag = "WindowESP",
    Save = false,
    Callback = function(Value)
        ESPTypes.Window.Enabled = Value
        updateType("Window")
    end
})

Orion:Init()
