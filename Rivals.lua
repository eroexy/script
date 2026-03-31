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

local Settings = {
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Tracer_Origin = "Bottom",
    Box = true
    Health_Bar = true,
    Tracer_FollowMouse = false,
    Tracers = true
}

local Team_Settings = {
    TeamCheck = false,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

local TeamColor = true

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local function NewQuad(thickness, color)
    local quad = Drawing.new("Quad")
    quad.Visible = false
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Visibility(state, lib)
    for _, v in pairs(lib) do
        v.Visible = state
    end
end

local function Reset(lib)
    for _, v in pairs(lib) do
        if v.From then
            v.From = Vector2.new(-1000, -1000)
            v.To = Vector2.new(-1000, -1000)
        elseif v.PointA then
            v.PointA = Vector2.new(-1000, -1000)
            v.PointB = Vector2.new(-1000, -1000)
            v.PointC = Vector2.new(-1000, -1000)
            v.PointD = Vector2.new(-1000, -1000)
        end
        v.Visible = false
    end
end

local black = Color3.fromRGB(0,0,0)

local function ESP(plr)
    local library = {
        blacktracer = NewLine(Settings.Tracer_Thickness*2, black),
        tracer = NewLine(Settings.Tracer_Thickness, Settings.Tracer_Color),

        black = NewQuad(Settings.Box_Thickness*2, black),
        box = NewQuad(Settings.Box_Thickness, Settings.Box_Color),

        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, Color3.fromRGB(0,255,0))
    }

    local function Colorize(color)
        for _, v in pairs(library) do
            if v ~= library.healthbar and v ~= library.greenhealth and v ~= library.black and v ~= library.blacktracer then
                v.Color = color
            end
        end
    end

    local connection
    connection = RunService.RenderStepped:Connect(function()

        local character = plr.Character
        if not character or not character.Parent then
            Reset(library)
            return
        end

        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")

        if not humanoid or not root or not head or humanoid.Health <= 0 then
            Reset(library)
            return
        end

        local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)

        if not onScreen then
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
            local function SetBox(obj)
                obj.PointA = Vector2.new(rootPos.X + size, rootPos.Y - size*2)
                obj.PointB = Vector2.new(rootPos.X - size, rootPos.Y - size*2)
                .PointC = Vector2.new(rootPos.X - size, rootPos.Y + size*2)
                obj.PointD = Vector2.new(rootPos.X + size, rootPos.Y + size*2)
            end

            SetBox(library.box)
            SetBox(library.black)

            library.Box.Visible = true
            library.Box.Visible = true
        else
            library.Box.Visible = false
            library.Box.Visible = false
        end

        -- TRACER
        if Settings.Tracers then
            local origin = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)

            if Settings.Tracer_Origin == "Middle" then
                origin = camera.ViewportSize * 0.5
            end

            if Settings.Tracer_FollowMouse then
                origin = Vector2.new(mouse.X, mouse.Y + 36)
            end

            local to = Vector2.new(rootPos.X, rootPos.Y + size*2)

            library.tracer.From = origin
            library.tracer.To = to

            library.blacktracer.From = origin
            library.blacktracer.To = to

            library.tracer.Visible = true
            library.blacktracer.Visible = true
        else
            library.tracer.Visible = false
            library.blacktracer.Visible = false
        end

        -- HEALTH BAR
        if Settings.Health_Bar then
            local height = size * 4
            local ratio = humanoid.Health / humanoid.MaxHealth
            local healthHeight = height * ratio

            library.healthbar.From = Vector2.new(rootPos.X - size - 4, rootPos.Y + size*2)
            library.healthbar.To = Vector2.new(rootPos.X - size - 4, rootPos.Y - size*2)

            library.greenhealth.From = Vector2.new(rootPos.X - size - 4, rootPos.Y + size*2)
            library.greenhealth.To = Vector2.new(rootPos.X - size - 4, rootPos.Y + size*2 - healthHeight)

            library.greenhealth.Color = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), ratio)

            library.healthbar.Visible = true
            library.healthbar.Visible = true
        else
            library.healthbar.Visible = false
            library.healthbar.Visible = false
        end

        -- COLORS
        if Team_Settings.TeamCheck then
            if plr.TeamColor == player.TeamColor then
                Colorize(Team_Settings.Green)
            else
                Colorize(Team_Settings.Red)
            end
        else
            library.tracer.Color = Settings.Tracer_Color
            library.box.Color = Settings.Box_Color
        end

        if TeamColor then
            Colorize(plr.TeamColor.Color)
        end

        Visibility(true, library)
    end)

    -- RESPAWN FIX
    plr.CharacterAdded:Connect(function()
        Reset(library)
    end)

    -- CLEANUP
    plr.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Reset(library)
            if connection then
                connection:Disconnect()
            end
        end
    end)
end

-- INIT
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
  Name = "Toggle Box",
  Default = false,
  Icon = "",
  Color = Color3.fromRGB(9, 99, 195),
  Flag = "BoxESP",
  Save = false,
  Callback = function(Value)
    Settings.Box = Value
  end
})

local Section = Tab:AddSection({
  Name = "Team-Check"
})


local Section = Tab:AddSection({
  Name = "Color"
})



local Tab = Window:MakeTab({
  Name = "Map",
  Icon = "rbxassetid://10734886202",
  PremiumOnly = false
})

--// init
Orion:Init()
