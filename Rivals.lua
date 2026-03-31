--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Locals

--// libary

local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/Polinorsik/Orion-Z-Library/refs/heads/main/README.md"))()

Orion.SelectedTheme = "Default"
local Window = Orion:MakeWindow({
  Name = "Rivals | by X3D",

  ConfigFolder = "X3D_Rivals",
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

--// ESP

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

_G.ESP_Settings = _G.ESP_Settings or {
    ESP = false,

    Box = true,
    Tracers = true,
    Health_Bar = true,

    TeamBoxes = true,

    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),

    Tracer_Thickness = 1,
    Box_Thickness = 1,

    Tracer_Origin = "Bottom",
    Tracer_FollowMouse = false
}

local Settings = _G.ESP_Settings

local TeamColor = false
local black = Color3.fromRGB(0, 0, 0)

local ESP_CACHE = {}
local OFF = Vector2.new(-9999, -9999)

--// Drawing constructors
local function NewQuad(t, c)
    local q = Drawing.new("Quad")
    q.Visible = false
    q.Filled = false
    q.Thickness = t
    q.Color = c
    return q
end

local function NewLine(t, c)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = t
    l.Color = c
    return l
end

--// HARD HIDE
local function Hide(lib)
    if lib.box then lib.box.Visible = false end
    if lib.boxBlack then lib.boxBlack.Visible = false end

    if lib.tracer then lib.tracer.Visible = false end
    if lib.tracerBlack then lib.tracerBlack.Visible = false end

    if lib.health then lib.health.Visible = false end
    if lib.healthBG then lib.healthBG.Visible = false end

    if lib.box then
        lib.box.PointA, lib.box.PointB, lib.box.PointC, lib.box.PointD = OFF, OFF, OFF, OFF
    end

    if lib.boxBlack then
        lib.boxBlack.PointA, lib.boxBlack.PointB, lib.boxBlack.PointC, lib.boxBlack.PointD = OFF, OFF, OFF, OFF
    end

    if lib.tracer then
        lib.tracer.From, lib.tracer.To = OFF, OFF
    end

    if lib.tracerBlack then
        lib.tracerBlack.From, lib.tracerBlack.To = OFF, OFF
    end

    if lib.health then
        lib.health.From, lib.health.To = OFF, OFF
    end

    if lib.healthBG then
        lib.healthBG.From, lib.healthBG.To = OFF, OFF
    end
end

--// COLOR SYSTEM (FIX)
local function ApplyColors(lib, plr)
    lib.box.Color = Settings.Box_Color
    lib.tracer.Color = Settings.Tracer_Color

    lib.boxBlack.Color = lib.box.Color
    lib.tracerBlack.Color = lib.tracer.Color
    lib.healthBG.Color = black

    if TeamColor and plr.TeamColor then
        local c = plr.TeamColor.Color
        lib.box.Color = c
        lib.tracer.Color = c
    end
end

--// CREATE ESP
local function CreateESP(plr)
    ESP_CACHE[plr] = {
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        tracerBlack = NewLine(Settings.Tracer_Thickness * 2, black),

        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        boxBlack = NewQuad(Settings.Box_Thickness * 2, black),

        healthBG = NewLine(3, black),
        health = NewLine(1.5, Color3.fromRGB(0,255,0))
    }

    ApplyColors(ESP_CACHE[plr], plr)

    plr.CharacterAdded:Connect(function()
        task.wait(0.2)
        if ESP_CACHE[plr] then
            ApplyColors(ESP_CACHE[plr], plr)
        end
    end)

    plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
        if ESP_CACHE[plr] then
            ApplyColors(ESP_CACHE[plr], plr)
        end
    end)
end

local function RemoveESP(plr)
    local lib = ESP_CACHE[plr]
    if lib then
        for _, v in pairs(lib) do
            v:Remove()
        end
        ESP_CACHE[plr] = nil
    end
end

--// INITIAL PLAYERS
for _, v in pairs(Players:GetPlayers()) do
    if v ~= player then
        CreateESP(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= player then
        CreateESP(v)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()

    if not Settings.ESP then
        for _, lib in pairs(ESP_CACHE) do
            Hide(lib)
        end
        return
    end

    for plr, lib in pairs(ESP_CACHE) do

        local char = plr.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if not char or not hum or not root or not head or hum.Health <= 0 then
            Hide(lib)
            continue
        end

        local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
        if not onScreen or rootPos.Z <= 0 then
            Hide(lib)
            continue
        end

        local headPos = camera:WorldToViewportPoint(head.Position)

        local size = math.clamp(
            (Vector2.new(headPos.X, headPos.Y) - Vector2.new(rootPos.X, rootPos.Y)).Magnitude,
            2,
            300
        )

        -- BOX
        if Settings.Box then
            lib.box.PointA = Vector2.new(rootPos.X + size, rootPos.Y - size * 2)
            lib.box.PointB = Vector2.new(rootPos.X - size, rootPos.Y - size * 2)
            lib.box.PointC = Vector2.new(rootPos.X - size, rootPos.Y + size * 2)
            lib.box.PointD = Vector2.new(rootPos.X + size, rootPos.Y + size * 2)
            lib.box.Visible = true

            lib.boxBlack.PointA = lib.box.PointA
            lib.boxBlack.PointB = lib.box.PointB
            lib.boxBlack.PointC = lib.box.PointC
            lib.boxBlack.PointD = lib.box.PointD
            lib.boxBlack.Visible = true
        else
            lib.box.Visible = false
            lib.boxBlack.Visible = false
        end

        -- TRACERS
        if Settings.Tracers then
            local origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

            if Settings.Tracer_Origin == "Middle" then
                origin = camera.ViewportSize * 0.5
            end

            if Settings.Tracer_FollowMouse then
                origin = Vector2.new(mouse.X, mouse.Y + 36)
            end

            local target = Vector2.new(rootPos.X, rootPos.Y + size * 2)

            lib.tracer.From = origin
            lib.tracer.To = target
            lib.tracer.Visible = true

            lib.tracerBlack.From = origin
            lib.tracerBlack.To = target
            lib.tracerBlack.Visible = true
        else
            lib.tracer.Visible = false
            lib.tracerBlack.Visible = false
        end

        -- HEALTH
        if Settings.Health_Bar then
            local height = size * 4
            local ratio = hum.Health / hum.MaxHealth
            local fill = height * ratio

            lib.healthBG.From = Vector2.new(rootPos.X - size - 4, rootPos.Y + size * 2)
            lib.healthBG.To = Vector2.new(rootPos.X - size - 4, rootPos.Y - size * 2)
            lib.healthBG.Visible = true

            lib.health.From = Vector2.new(rootPos.X - size - 4, rootPos.Y + size * 2)
            lib.health.To = Vector2.new(rootPos.X - size - 4, rootPos.Y + size * 2 - fill)
            lib.health.Visible = true

            lib.health.Color = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), ratio)
        else
            lib.health.Visible = false
            lib.healthBG.Visible = false
        end

        ApplyColors(lib, plr)
    end
end)

------------------------------------------// ESP UI

local Tab = Window:MakeTab({
  Name = "ESP",
  Icon = "rbxassetid://10723346959",
  PremiumOnly = false
})

local Section = Tab:AddSection({
  Name = "ESP"
})

local Toggle = Tab:AddToggle({
  Name = "Toggle ESP",
  Default = false,
  Icon = "",
  Color = Color3.fromRGB(9, 99, 195),
  Flag = "ToggleESP",
  Save = true,
  Callback = function(Value)
    Settings.ESP = Value
  end
})

local Toggle = Tab:AddToggle({
  Name = "Toggle Box",
  Default = false,
  Icon = "",
  Color = Color3.fromRGB(9, 99, 195),
  Flag = "BoxESP",
  Save = true,
  Callback = function(Value)
    Settings.Box = Value
  end
})

local Toggle = Tab:AddToggle({
  Name = "Toggle Health",
  Default = false,
  Icon = "",
  Color = Color3.fromRGB(9, 99, 195),
  Flag = "HealthESP",
  Save = true,
  Callback = function(Value)
    Settings.Health_Bar = Value
  end
})

local Toggle = Tab:AddToggle({
  Name = "Toggle Tracers",
  Default = false,
  Icon = "",
  Color = Color3.fromRGB(9, 99, 195),
  Flag = "TracerESP",
  Save = true,
  Callback = function(Value)
    Settings.Tracers = Value
  end
})

local Section = Tab:AddSection({
  Name = "Team-Check"
})

local Toggle = Tab:AddToggle({
  Name = "Team (Colors)",
  Default = false,
  Icon = "",
  Color = Color3.fromRGB(9, 99, 195),
  Flag = "TeamColors",
  Save = true,
  Callback = function(Value)
    TeamColor = Value
  end
})

local Toggle = Tab:AddToggle({
  Name = "Team (Boxes)",
  Default = false,
  Icon = "",
  Color = Color3.fromRGB(9, 99, 195),
  Flag = "TeamCheckBox",
  Save = true,
  Callback = function(Value)
    Settings.TeamBoxes = Value
  end
})


local Section = Tab:AddSection({
  Name = "Color"
})

local ColorPicker = Tab:AddColorpicker({
  Name = "Box (General)",
  Default = Color3.fromRGB(255,255,255),
  Flag = "BoxColorGeneral",
  Save = true,
  Callback = function(Value)
    Settings.Box_Color = Value
  end
})

local ColorPicker = Tab:AddColorpicker({
  Name = "Tracers",
  Default = Color3.fromRGB(255,255,255),
  Flag = "TracersColor",
  Save = true,
  Callback = function(Value)
    Settings.Tracer_Color = Value
  end
})


local Tab = Window:MakeTab({
  Name = "Map",
  Icon = "rbxassetid://10734886202",
  PremiumOnly = false
})

--// init
Orion:Init()
