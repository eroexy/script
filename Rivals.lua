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

local Settings = {
    ESP = false,

    Box = true,
    Tracers = true,
    Health_Bar = true,

    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),

    Tracer_Thickness = 1,
    Box_Thickness = 1,

    Tracer_Origin = "Bottom",
    Tracer_FollowMouse = false
}

local Team_Settings = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

local TeamColor = true

--// Drawing helpers
local function NewQuad(thickness, color)
    local q = Drawing.new("Quad")
    q.Visible = false
    q.Filled = false
    q.Thickness = thickness
    q.Color = color
    q.Transparency = 1
    return q
end

local function NewLine(thickness, color)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = thickness
    l.Color = color
    l.Transparency = 1
    return l
end

local function Reset(lib)
    for _, v in pairs(lib) do
        v.Visible = false
    end
end

local black = Color3.fromRGB(0, 0, 0)

--// ESP CORE
local function ESP(plr)
    local library = {
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),
        tracerBlack = NewLine(Settings.Tracer_Thickness * 2, black),

        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),
        boxBlack = NewQuad(Settings.Box_Thickness * 2, black),

        healthBG = NewLine(3, black),
        health = NewLine(1.5, Color3.fromRGB(0, 255, 0))
    }

    local connection

    connection = RunService.RenderStepped:Connect(function()
        if not Settings.ESP then
            Reset(library)
            return
        end

        local character = plr.Character
        if not character then return Reset(library) end

        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")

        if not humanoid or not root or not head or humanoid.Health <= 0 then
            return Reset(library)
        end

        local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)

        local camPos = camera.CFrame.Position
        local toTarget = root.Position - camPos

        if not onScreen or toTarget.Magnitude <= 0 then
            Reset(library)
            return
        end

        local facing = camera.CFrame.LookVector:Dot(toTarget.Unit)
        if facing <= 0.15 then
            Reset(library)
            return
        end

        local headPos = camera:WorldToViewportPoint(head.Position)

        local size = math.clamp(
            (Vector2.new(headPos.X, headPos.Y) - Vector2.new(rootPos.X, rootPos.Y)).Magnitude,
            2,
            300
        )

        -- BOX

        if Settings.Box then
            local function setBox(obj)
                obj.PointA = Vector2.new(rootPos.X + size, rootPos.Y - size * 2)
                obj.PointB = Vector2.new(rootPos.X - size, rootPos.Y - size * 2)
                obj.PointC = Vector2.new(rootPos.X - size, rootPos.Y + size * 2)
                obj.PointD = Vector2.new(rootPos.X + size, rootPos.Y + size * 2)
                obj.Visible = true
            end

            if not library.box then
                library.box = NewQuad(Settings.Box_Thickness, Settings.Box_Color)
                library.boxBlack = NewQuad(Settings.Box_Thickness * 2, Color3.fromRGB(0,0,0))
            end

            setBox(library.box)
            setBox(library.boxBlack)

        else
            if library.box then
                library.box:Remove()
                library.boxBlack:Remove()

                library.box = nil
                library.boxBlack = nil
            end
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

            library.tracer.From = origin
            library.tracer.To = target
            library.tracer.Visible = true

            library.tracerBlack.From = origin
            library.tracerBlack.To = target
            library.tracerBlack.Visible = true
        else
            library.tracer.Visible = false
            library.tracerBlack.Visible = false
        end

        -- HEALTH

        if Settings.Health_Bar then
            local height = size * 4
            local ratio = humanoid.Health / humanoid.MaxHealth
            local fill = height * ratio

            library.healthBG.From = Vector2.new(rootPos.X - size - 4, rootPos.Y + size * 2)
            library.healthBG.To = Vector2.new(rootPos.X - size - 4, rootPos.Y - size * 2)
            library.healthBG.Visible = true

            library.health.From = Vector2.new(rootPos.X - size - 4, rootPos.Y + size * 2)
            library.health.To = Vector2.new(rootPos.X - size - 4, rootPos.Y + size * 2 - fill)
            library.health.Visible = true

            library.health.Color =
                Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), ratio)
        else
            library.healthBG.Visible = false
            library.health.Visible = false
        end

        -- TEAM COLORING

        if TeamColor then
            for _, v in pairs(library) do
                if v ~= library.health and v ~= library.healthBG and v ~= library.tracerBlack and v ~= library.boxBlack then
                    v.Color = plr.TeamColor.Color
                end
            end
        end
    end)

    plr.CharacterAdded:Connect(function()
        Reset(library)
    end)

    plr.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Reset(library)
            if connection then connection:Disconnect() end
        end
    end)
end

--// INIT PLAYERS
for _, v in pairs(Players:GetPlayers()) do
    if v ~= player then
        ESP(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= player then
        ESP(v)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if library and library.box then
        library.box:Remove()
        library.box = nil
    end

    if library and library.boxBlack then
        library.boxBlack:Remove()
        library.boxBlack = nil
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
  Name = "Toggle Tracer",
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


local Section = Tab:AddSection({
  Name = "Color"
})

local ColorPicker = Tab:AddColorpicker({
  Name = "Box Color",
  Default = Color3.fromRGB(255,255,255),
  Flag = "BoxColor",
  Save = true,
  Callback = function(Value)
    Settings.Box_Color = Value
  end
})



local Tab = Window:MakeTab({
  Name = "Map",
  Icon = "rbxassetid://10734886202",
  PremiumOnly = false
})

--// init
Orion:Init()
