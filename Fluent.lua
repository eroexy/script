local Fluent = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local Teams = game:GetService("Teams")

local function IsMouseInFrame(frame, mousePos)
    local absPos, absSize = frame.AbsolutePosition, frame.AbsoluteSize
    return mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
        and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
end

local function GetTableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function Clamp(v, min, max) return math.max(min, math.min(max, v)) end

local function Round(v, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(v * mult + 0.5) / mult
end

local function DeepClone(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = DeepClone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local Scheme = {
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 38),
    Surface2 = Color3.fromRGB(40, 40, 50),
    Surface3 = Color3.fromRGB(50, 50, 62),
    Primary = Color3.fromRGB(0, 120, 255),
    PrimaryDark = Color3.fromRGB(0, 80, 200),
    PrimaryLight = Color3.fromRGB(50, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 190),
    TextDimmer = Color3.fromRGB(130, 130, 140),
    Outline = Color3.fromRGB(60, 60, 70),
    OutlineLight = Color3.fromRGB(80, 80, 90),
    Danger = Color3.fromRGB(220, 50, 50),
    DangerDark = Color3.fromRGB(170, 30, 30),
    Success = Color3.fromRGB(50, 200, 80),
    SuccessDark = Color3.fromRGB(30, 160, 60),
    Warning = Color3.fromRGB(255, 180, 50),
    WarningDark = Color3.fromRGB(200, 140, 30),
}

local Font = Font.fromEnum(Enum.Font.GothamMedium)
local FontBold = Font.fromEnum(Enum.Font.GothamBold)
local FontSemiBold = Font.fromEnum(Enum.Font.GothamSemibold)

local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k == "Parent" and not v then
            inst.Parent = ScreenGui
        else
            inst[k] = v
        end
    end
    return inst
end

local function AddCorner(frame, radius)
    local corner = frame:FindFirstChild("UICorner")
    if corner then corner:Destroy() end
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = frame
    })
end

local function AddStroke(frame, color, thickness, transparency)
    local stroke = frame:FindFirstChild("UIStroke")
    if stroke then stroke:Destroy() end
    return Create("UIStroke", {
        Color = color or Scheme.Outline,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = frame
    })
end

local function AddShadow(frame, size, transparency)
    local shadow = Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045237",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.6,
        Position = UDim2.fromOffset(size or 4, size or 4),
        Size = UDim2.new(1, (size or 4) * 2, 1, (size or 4) * 2),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(5, 5, 5, 5),
        ZIndex = 0,
        Parent = frame
    })
    return shadow
end

local function AddGradient(frame, color1, color2, rotation)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color1 or Scheme.Primary),
            ColorSequenceKeypoint.new(1, color2 or Scheme.PrimaryDark)
        },
        Rotation = rotation or 45,
        Parent = frame
    })
    return gradient
end

local function MakeDraggable(frame, dragFrame, callback)
    local dragging = false
    local dragInput, dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if callback then callback() end
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            if callback then callback() end
        end
    end)
end

local function MakeResizable(frame, corner, minSize, maxSize, callback)
    local dragging = false
    local dragStart, startSize
    
    minSize = minSize or Vector2.new(400, 300)
    maxSize = maxSize or Vector2.new(1200, 800)
    
    corner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startSize = frame.Size
        end
    end)
    
    corner.InputEnded:Connect(function()
        dragging = false
        if callback then callback() end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = math.max(minSize.X, math.min(maxSize.X, startSize.X.Offset + delta.X))
            local newY = math.max(minSize.Y, math.min(maxSize.Y, startSize.Y.Offset + delta.Y))
            frame.Size = UDim2.new(startSize.X.Scale, newX, startSize.Y.Scale, newY)
            if callback then callback() end
        end
    end)
end

local function GetTextBounds(text, font, size, width)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Font = font
    params.Size = size
    params.Width = width or 500
    return TextService:GetTextBoundsAsync(params)
end

local ScreenGui = Create("ScreenGui", {
    Name = "FluentUI",
    DisplayOrder = 999,
    ResetOnSpawn = false,
    Parent = (function()
        return CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    end)()
})

Fluent.Notifications = {}
Fluent.Dialogs = {}
Fluent.Objects = {}
Fluent.Configs = {}
Fluent.SaveManager = {}
Fluent.CustomThemes = {}

local function CreateAcrylic(parent, size, position, transparency)
    local blur = Create("ImageLabel", {
        Image = "rbxassetid://5553946806",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = transparency or 0.5,
        Position = position or UDim2.new(0, 0, 0, 0),
        Size = size or UDim2.new(1, 0, 1, 0),
        ScaleType = Enum.ScaleType.Crop,
        BackgroundTransparency = 1,
        Parent = parent
    })
    return blur
end

function Fluent:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Fluent"
    local size = config.Size or UDim2.fromOffset(700, 500)
    local minSize = config.MinSize or Vector2.new(400, 300)
    local maxSize = config.MaxSize or Vector2.new(1200, 800)
    local accentColor = config.AccentColor or Scheme.Primary
    local theme = config.Theme or "Dark"
    local closable = config.Closable ~= false
    local resizable = config.Resizable ~= false
    local draggable = config.Draggable ~= false
    local acrylic = config.Acrylic ~= false
    
    local window = {}
    window.Tabs = {}
    window.Elements = {}
    window.Frames = {}
    window.Config = config
    window.Theme = theme
    
    local main = Create("Frame", {
        BackgroundColor3 = Scheme.Background,
        BackgroundTransparency = theme == "Transparent" and 0.1 or 0,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        Size = size,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    AddShadow(main, 8, 0.7)
    AddCorner(main, 12)
    AddStroke(main, Scheme.Outline, 1)
    
    if acrylic then
        CreateAcrylic(main, UDim2.new(1, 0, 1, 0), nil, 0.6)
    end
    
    local topBar = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 33),
        BackgroundTransparency = theme == "Transparent" and 0.5 or 0,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = main
    })
    
    local titleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace = FontBold,
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(0, 0, 1, 0),
        Text = title,
        TextColor3 = Scheme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = topBar
    })
    
    local windowControls = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.fromOffset(72, 50),
        Parent = topBar
    })
    
    local closeBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 60, 60),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "",
        Parent = windowControls
    })
    AddCorner(closeBtn, 4)
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
    end)
    
    local minimizeBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 180, 50),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(1, -28, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "",
        Parent = windowControls
    })
    AddCorner(minimizeBtn, 4)
    minimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    minimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
    end)
    
    local maximizeBtn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(50, 200, 80),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(1, -56, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "",
        Parent = windowControls
    })
    AddCorner(maximizeBtn, 4)
    maximizeBtn.MouseEnter:Connect(function()
        TweenService:Create(maximizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    maximizeBtn.MouseLeave:Connect(function()
        TweenService:Create(maximizeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
    end)
    
    local minimized = false
    local maximized = false
    local lastPos = main.Position
    local lastSize = main.Size
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, -150, 0.5, -10),
                Size = UDim2.fromOffset(300, 20)
            }):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = lastPos,
                Size = lastSize
            }):Play()
        end
    end)
    
    maximizeBtn.MouseButton1Click:Connect(function()
        maximized = not maximized
        if maximized then
            lastPos = main.Position
            lastSize = main.Size
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.new(1, 0, 1, 0)
            }):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = lastPos,
                Size = lastSize
            }):Play()
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        if window.OnClose then window.OnClose() end
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        main:Destroy()
    end)
    
    if draggable then
        MakeDraggable(main, topBar)
    end
    
    if resizable then
        local resizeCorner = Create("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.fromOffset(16, 16),
            Text = "",
            Parent = main
        })
        
        local resizeIcon = Create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "rbxassetid://6962738816",
            ImageColor3 = Scheme.TextDim,
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = resizeCorner
        })
        MakeResizable(main, resizeCorner, minSize, maxSize, function()
            for _, tab in pairs(window.Tabs) do
                if tab.OnResize then tab:OnResize() end
            end
        end)
    end
    
    local sidebar = Create("ScrollingFrame", {
        BackgroundColor3 = Color3.fromRGB(25, 25, 33),
        BackgroundTransparency = theme == "Transparent" and 0.4 or 0,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 180, 1, -50),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = main
    })
    
    local sidebarList = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = sidebar
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = sidebar
    })
    
    local contentContainer = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0, 50),
        Size = UDim2.new(1, -180, 1, -50),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Scheme.Outline,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = main
    })
    
    local contentList = Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = contentContainer
    })
    
    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = contentContainer
    })
    
    window.main = main
    window.sidebar = sidebar
    window.contentContainer = contentContainer
    window.accentColor = accentColor
    
    function window:UpdateTheme(newTheme)
        self.Theme = newTheme
        local trans = newTheme == "Transparent" and 0.1 or 0
        local topTrans = newTheme == "Transparent" and 0.5 or 0
        local sideTrans = newTheme == "Transparent" and 0.4 or 0
        
        TweenService:Create(main, TweenInfo.new(0.3), {
            BackgroundTransparency = trans
        }):Play()
        TweenService:Create(topBar, TweenInfo.new(0.3), {
            BackgroundTransparency = topTrans
        }):Play()
        TweenService:Create(sidebar, TweenInfo.new(0.3), {
            BackgroundTransparency = sideTrans
        }):Play()
    end
    
    function window:SelectTab(tabName)
        for name, tab in pairs(window.Tabs) do
            if name == tabName then
                tab.button.BackgroundTransparency = 0.85
                tab.button.TextColor3 = Scheme.Text
                tab.button.TextTransparency = 0
                if tab.buttonIcon then
                    tab.buttonIcon.ImageTransparency = 0
                    tab.buttonIcon.ImageColor3 = Scheme.Text
                end
                tab.frame.Visible = true
                window.activeTab = tab
                if tab.OnShow then tab:OnShow() end
            else
                tab.button.BackgroundTransparency = 1
                tab.button.TextColor3 = Scheme.TextDim
                tab.button.TextTransparency = 0.5
                if tab.buttonIcon then
                    tab.buttonIcon.ImageTransparency = 0.5
                    tab.buttonIcon.ImageColor3 = Scheme.TextDim
                end
                tab.frame.Visible = false
                if tab.OnHide then tab:OnHide() end
            end
        end
    end
    
    function window:AddTab(tabName, icon)
        local tab = {}
        tab.Name = tabName
        tab.Elements = {}
        tab.Sections = {}
        
        local button = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -12, 0, 38),
            Position = UDim2.fromOffset(6, 0),
            Text = "",
            Parent = sidebar
        })
        AddCorner(button, 8)
        
        local buttonContent = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = button
        })
        
        local buttonIcon
        if icon then
            buttonIcon = Create("ImageLabel", {
                BackgroundTransparency = 1,
                Image = icon,
                ImageColor3 = Scheme.TextDim,
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromOffset(18, 18),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = buttonContent
            })
        end
        
        local buttonLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Position = UDim2.fromOffset(icon and 38 or 12, 0),
            Size = UDim2.new(1, -(icon and 50 or 24), 1, 0),
            Text = tabName,
            TextColor3 = Scheme.TextDim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = buttonContent
        })
        
        local tabFrame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentContainer
        })
        
        local tabListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            Parent = tabFrame
        })
        
        tab.button = button
        tab.buttonIcon = buttonIcon
        tab.buttonLabel = buttonLabel
        tab.frame = tabFrame
        tab.listLayout = tabListLayout
        
        local function SelectSelf()
            window:SelectTab(tabName)
        end
        
        button.MouseButton1Click:Connect(SelectSelf)
        
        button.MouseEnter:Connect(function()
            if window.activeTab ~= tab then
                TweenService:Create(buttonLabel, TweenInfo.new(0.15), {
                    TextColor3 = Scheme.Text,
                    TextTransparency = 0
                }):Play()
                if buttonIcon then
                    TweenService:Create(buttonIcon, TweenInfo.new(0.15), {
                        ImageColor3 = Scheme.Text,
                        ImageTransparency = 0
                    }):Play()
                end
            end
        end)
        
        button.MouseLeave:Connect(function()
            if window.activeTab ~= tab then
                TweenService:Create(buttonLabel, TweenInfo.new(0.15), {
                    TextColor3 = Scheme.TextDim,
                    TextTransparency = 0.5
                }):Play()
                if buttonIcon then
                    TweenService:Create(buttonIcon, TweenInfo.new(0.15), {
                        ImageColor3 = Scheme.TextDim,
                        ImageTransparency = 0.5
                    }):Play()
                end
            end
        end)
        
        window.Tabs[tabName] = tab
        
        if GetTableSize(window.Tabs) == 1 then
            window:SelectTab(tabName)
        end
        
        return tab
    end
    
    function window:AddSection(tabName, sectionName)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section = {}
        section.Elements = {}
        section.Name = sectionName
        
        local frame = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
            BackgroundTransparency = theme == "Transparent" and 0.3 or 0,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = tab.frame
        })
        AddCorner(frame, 10)
        AddStroke(frame, Scheme.Outline, 0.5)
        AddShadow(frame, 2, 0.3)
        
        local header = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(35, 35, 45),
            BackgroundTransparency = theme == "Transparent" and 0.3 or 0,
            Size = UDim2.new(1, 0, 0, 40),
            Parent = frame
        })
        AddCorner(header, 10)
        
        local headerText = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = FontBold,
            Position = UDim2.fromOffset(16, 0),
            Size = UDim2.new(1, -32, 1, 0),
            Text = sectionName,
            TextColor3 = Scheme.Text,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header
        })
        
        local container = Create("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 40),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = frame
        })
        
        local containerList = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = container
        })
        
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 4),
            Parent = container
        })
        
        section.frame = frame
        section.header = header
        section.container = container
        section.containerList = containerList
        
        table.insert(tab.Sections, section)
        
        return section
    end
    
    function window:AddButton(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local button = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 34),
            Text = config.Title or "Button",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            FontFace = Font,
            AutoButtonColor = false,
            Parent = section.container
        })
        AddCorner(button, 8)
        
        if config.Icon then
            local icon = Create("ImageLabel", {
                BackgroundTransparency = 1,
                Image = config.Icon,
                ImageColor3 = Scheme.TextDim,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromOffset(16, 16),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = button
            })
        end
        
        local buttonText = config.Title or "Button"
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Position = UDim2.fromOffset(config.Icon and 36 or 12, 0),
            Size = UDim2.new(1, -(config.Icon and 48 or 24), 1, 0),
            Text = buttonText,
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button
        })
        
        local clickTween
        button.MouseButton1Click:Connect(function()
            if config.Callback then config.Callback() end
            if clickTween then clickTween:Cancel() end
            clickTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 0.8
            })
            clickTween:Play()
            clickTween.Completed:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.15), {
                    BackgroundTransparency = 0.5
                }):Play()
            end)
        end)
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.2,
                BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            }):Play()
            if config.OnHover then config.OnHover(true) end
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            }):Play()
            if config.OnHover then config.OnHover(false) end
        end)
        
        section.Elements[config.Title] = button
        
        return {
            SetText = function(text)
                label.Text = text
            end,
            SetEnabled = function(enabled)
                button.Active = enabled
                button.TextTransparency = enabled and 0 or 0.5
                button.BackgroundTransparency = enabled and 0.5 or 0.8
            end,
            Destroy = function()
                button:Destroy()
            end
        }
    end
    
    function window:AddToggle(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local value = config.Default or false
        local callback = config.Callback
        local onChanged = config.OnChanged
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = section.container
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -56, 1, 0),
            Text = config.Title or "Toggle",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local toggle = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Scheme.Surface2,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(44, 24),
            Text = "",
            AutoButtonColor = false,
            Parent = frame
        })
        AddCorner(toggle, 12)
        
        local indicator = Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Scheme.TextDim,
            Position = UDim2.fromOffset(2, 0.5),
            Size = UDim2.fromOffset(20, 20),
            Parent = toggle
        })
        AddCorner(indicator, 10)
        AddShadow(indicator, 1, 0.3)
        
        local function UpdateToggle()
            if value then
                TweenService:Create(toggle, TweenInfo.new(0.2), {
                    BackgroundColor3 = Scheme.Primary
                }):Play()
                TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Position = UDim2.fromOffset(22, 0.5)
                }):Play()
                TweenService:Create(indicator, TweenInfo.new(0.2), {
                    BackgroundColor3 = Scheme.Text
                }):Play()
            else
                TweenService:Create(toggle, TweenInfo.new(0.2), {
                    BackgroundColor3 = Scheme.Surface2
                }):Play()
                TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Position = UDim2.fromOffset(2, 0.5)
                }):Play()
                TweenService:Create(indicator, TweenInfo.new(0.2), {
                    BackgroundColor3 = Scheme.TextDim
                }):Play()
            end
        end
        
        UpdateToggle()
        
        toggle.MouseButton1Click:Connect(function()
            value = not value
            UpdateToggle()
            if callback then callback(value) end
            if onChanged then onChanged(value) end
        end)
        
        section.Elements[config.Title] = {toggle = toggle, indicator = indicator}
        
        return {
            SetValue = function(v)
                value = v
                UpdateToggle()
                if onChanged then onChanged(value) end
            end,
            GetValue = function() return value end,
            Toggle = function()
                value = not value
                UpdateToggle()
                if onChanged then onChanged(value) end
            end,
            Destroy = function()
                frame:Destroy()
            end
        }
    end
    
    function window:AddSlider(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local min = config.Min or 0
        local max = config.Max or 100
        local value = Clamp(config.Default or 50, min, max)
        local decimals = config.Decimals or 0
        local step = config.Step or (10 ^ -decimals)
        local callback = config.Callback
        local onChanged = config.OnChanged
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 52),
            Parent = section.container
        })
        
        local header = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Parent = frame
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Size = UDim2.new(1, -80, 1, 0),
            Text = config.Title or "Slider",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header
        })
        
        local valueLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            FontFace = FontBold,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(80, 1),
            Text = config.Format and config.Format(value) or tostring(Round(value, decimals)),
            TextColor3 = Scheme.Primary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = header
        })
        
        local sliderBar = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.fromOffset(0, 34),
            Text = "",
            AutoButtonColor = false,
            Parent = frame
        })
        AddCorner(sliderBar, 3)
        
        local fill = Create("Frame", {
            BackgroundColor3 = Scheme.Primary,
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            Parent = sliderBar
        })
        AddCorner(fill, 3)
        
        local dragging = false
        
        local function UpdateSlider(mouseX)
            local relX = Clamp((mouseX - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local rawValue = min + (max - min) * relX
            value = Round(rawValue / step) * step
            value = Clamp(value, min, max)
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            valueLabel.Text = config.Format and config.Format(value) or tostring(Round(value, decimals))
            if onChanged then onChanged(value) end
        end
        
        sliderBar.MouseButton1Down:Connect(function()
            dragging = true
            UpdateSlider(Mouse.X)
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                dragging = false
                if callback then callback(value) end
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input.Position.X)
            end
        end)
        
        section.Elements[config.Title] = {slider = sliderBar, fill = fill, valueLabel = valueLabel}
        
        return {
            SetValue = function(v)
                value = Clamp(Round(v / step) * step, min, max)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                valueLabel.Text = config.Format and config.Format(value) or tostring(Round(value, decimals))
                if onChanged then onChanged(value) end
            end,
            GetValue = function() return value end,
            SetMin = function(v)
                min = v
                value = Clamp(value, min, max)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                valueLabel.Text = config.Format and config.Format(value) or tostring(Round(value, decimals))
            end,
            SetMax = function(v)
                max = v
                value = Clamp(value, min, max)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                valueLabel.Text = config.Format and config.Format(value) or tostring(Round(value, decimals))
            end,
            Destroy = function()
                frame:Destroy()
            end
        }
    end
    
    function window:AddDropdown(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local items = config.Values or {}
        local value = config.Default or items[1]
        local multi = config.Multi or false
        local searchable = config.Searchable or false
        local selected = {}
        local callback = config.Callback
        local onChanged = config.OnChanged
        
        if multi then
            for _, v in pairs(config.Default or {}) do
                selected[v] = true
            end
            value = config.Default or {}
        end
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Parent = section.container
        })
        
        local dropdown = Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false,
            Parent = frame
        })
        AddCorner(dropdown, 8)
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(0, 0, 1, 0),
            Text = config.Title or "Dropdown",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = dropdown
        })
        
        local arrow = Create("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            FontFace = Font,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Text = "▾",
            TextColor3 = Scheme.TextDim,
            TextSize = 16,
            Parent = dropdown
        })
        
        local selectedLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            FontFace = Font,
            Position = UDim2.new(1, -32, 0.5, 0),
            Size = UDim2.fromOffset(100, 1),
            Text = multi and "" or tostring(value),
            TextColor3 = Scheme.TextDim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = dropdown
        })
        
        local searchBox
        if searchable then
            searchBox = Create("TextBox", {
                BackgroundColor3 = Color3.fromRGB(35, 35, 45),
                BackgroundTransparency = 0.5,
                FontFace = Font,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                Text = "",
                PlaceholderText = "Search...",
                TextColor3 = Scheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = dropdown
            })
            AddCorner(searchBox, 4)
        end
        
        local menuOpen = false
        local menuFrame
        local menuList
        
        local function CloseMenu()
            if menuFrame then
                menuFrame:Destroy()
                menuFrame = nil
                menuList = nil
            end
            menuOpen = false
            if searchBox then
                searchBox.Visible = false
                searchBox.Text = ""
                selectedLabel.Visible = true
                label.Visible = true
            end
            arrow.Rotation = 0
        end
        
        local function OpenMenu()
            CloseMenu()
            
            local maxHeight = math.min(#items * 32, 180)
            
            menuFrame = Create("ScrollingFrame", {
                BackgroundColor3 = Color3.fromRGB(35, 35, 45),
                BackgroundTransparency = 0.95,
                Position = UDim2.new(0, 0, 1, 2),
                Size = UDim2.new(1, 0, 0, maxHeight),
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Scheme.Outline,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ClipsDescendants = true,
                Parent = dropdown
            })
            AddCorner(menuFrame, 8)
            AddStroke(menuFrame, Scheme.Outline, 0.5)
            AddShadow(menuFrame, 2, 0.4)
            
            menuList = Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = menuFrame
            })
            
            if searchBox then
                searchBox.Visible = true
                selectedLabel.Visible = false
                label.Visible = false
                searchBox:CaptureFocus()
            end
            
            local function BuildMenu(filter)
                for _, child in pairs(menuFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                local filteredItems = items
                if filter and filter ~= "" then
                    filteredItems = {}
                    for _, item in pairs(items) do
                        if tostring(item):lower():find(filter:lower()) then
                            table.insert(filteredItems, item)
                        end
                    end
                end
                
                for _, item in pairs(filteredItems) do
                    local btn = Create("TextButton", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 30),
                        Text = "",
                        AutoButtonColor = false,
                        Parent = menuFrame
                    })
                    
                    local check = Create("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0.5),
                        FontFace = Font,
                        Position = UDim2.new(1, -12, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        Text = multi and (selected[item] and "✓" or "") or (value == item and "✓" or ""),
                        TextColor3 = Scheme.Primary,
                        TextSize = 16,
                        Parent = btn
                    })
                    
                    local btnLabel = Create("TextLabel", {
                        BackgroundTransparency = 1,
                        FontFace = Font,
                        Position = UDim2.fromOffset(12, 0),
                        Size = UDim2.new(1, -36, 1, 0),
                        Text = tostring(item),
                        TextColor3 = Scheme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = btn
                    })
                    
                    btn.MouseButton1Click:Connect(function()
                        if multi then
                            selected[item] = not selected[item]
                            local vals = {}
                            for k, v in pairs(selected) do
                                if v then table.insert(vals, k) end
                            end
                            value = vals
                            selectedLabel.Text = table.concat(vals, ", ")
                            if onChanged then onChanged(value) end
                            if callback then callback(value) end
                        else
                            value = item
                            selectedLabel.Text = tostring(item)
                            if onChanged then onChanged(value) end
                            if callback then callback(value) end
                            CloseMenu()
                        end
                        
                        for _, child in pairs(menuFrame:GetChildren()) do
                            if child:IsA("TextButton") then
                                local checkLabel = child:FindFirstChildOfClass("TextLabel")
                                if checkLabel then
                                    local itemValue = child:FindFirstChildOfClass("TextLabel").Text
                                    checkLabel.Text = multi and (selected[itemValue] and "✓" or "") or (value == itemValue and "✓" or "")
                                end
                            end
                        end
                    end)
                    
                    btn.MouseEnter:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
                    end)
                    btn.MouseLeave:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                    end)
                end
            end
            
            BuildMenu()
            
            if searchBox then
                searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    BuildMenu(searchBox.Text)
                end)
            end
            
            arrow.Rotation = 180
            menuOpen = true
        end
        
        dropdown.MouseButton1Click:Connect(function()
            if menuOpen then
                CloseMenu()
            else
                OpenMenu()
            end
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and menuOpen then
                if not IsMouseInFrame(dropdown, input.Position) and not IsMouseInFrame(menuFrame, input.Position) then
                    CloseMenu()
                end
            end
        end)
        
        section.Elements[config.Title] = {dropdown = dropdown, menu = menuFrame}
        
        return {
            SetValue = function(v)
                if multi then
                    selected = {}
                    for _, item in pairs(v or {}) do
                        selected[item] = true
                    end
                    value = v
                    selectedLabel.Text = table.concat(v, ", ")
                else
                    value = v
                    selectedLabel.Text = tostring(v)
                end
                if onChanged then onChanged(value) end
            end,
            GetValue = function() return value end,
            AddItem = function(item)
                table.insert(items, item)
            end,
            RemoveItem = function(item)
                for i, v in pairs(items) do
                    if v == item then
                        table.remove(items, i)
                        break
                    end
                end
            end,
            Destroy = function()
                frame:Destroy()
                if menuFrame then menuFrame:Destroy() end
            end
        }
    end
    
    function window:AddInput(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local value = config.Default or ""
        local placeholder = config.Placeholder or ""
        local numeric = config.Numeric or false
        local callback = config.Callback
        local onChanged = config.OnChanged
        local clearOnFocus = config.ClearOnFocus ~= false
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = section.container
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Size = UDim2.new(0.3, -8, 1, 0),
            Text = config.Title or "Input",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local input = Create("TextBox", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BackgroundTransparency = 0.5,
            FontFace = Font,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.7, -8, 0, 28),
            Text = tostring(value),
            PlaceholderText = placeholder,
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = clearOnFocus,
            Parent = frame
        })
        AddCorner(input, 6)
        AddStroke(input, Scheme.Outline, 0.5)
        
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            Parent = input
        })
        
        local function ValidateInput(text)
            if numeric then
                local num = tonumber(text)
                if num then
                    return tostring(num)
                else
                    return value
                end
            end
            return text
        end
        
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local newValue = ValidateInput(input.Text)
                input.Text = newValue
                value = newValue
                if onChanged then onChanged(value) end
                if callback then callback(value) end
            end
        end)
        
        input:GetPropertyChangedSignal("Text"):Connect(function()
            if not input:IsFocused() then
                local newValue = ValidateInput(input.Text)
                if newValue ~= input.Text then
                    input.Text = newValue
                end
                value = newValue
            end
        end)
        
        section.Elements[config.Title] = {input = input}
        
        return {
            SetValue = function(v)
                value = tostring(v)
                input.Text = value
                if onChanged then onChanged(value) end
            end,
            GetValue = function() return value end,
            Destroy = function()
                frame:Destroy()
            end
        }
    end
    
    function window:AddColorPicker(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local value = config.Default or Color3.fromRGB(255, 255, 255)
        local callback = config.Callback
        local onChanged = config.OnChanged
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = section.container
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Size = UDim2.new(1, -56, 1, 0),
            Text = config.Title or "Color Picker",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local colorButton = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = value,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(40, 24),
            Text = "",
            AutoButtonColor = false,
            Parent = frame
        })
        AddCorner(colorButton, 6)
        AddStroke(colorButton, Scheme.Outline, 1)
        
        local menuOpen = false
        local menuFrame
        local hue, sat, val = value:ToHSV()
        
        local function CloseMenu()
            if menuFrame then
                menuFrame:Destroy()
                menuFrame = nil
            end
            menuOpen = false
        end
        
        colorButton.MouseButton1Click:Connect(function()
            if menuOpen then
                CloseMenu()
                return
            end
            
            menuFrame = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(35, 35, 45),
                BackgroundTransparency = 0.95,
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.fromOffset(220, 210),
                Parent = colorButton
            })
            AddCorner(menuFrame, 10)
            AddStroke(menuFrame, Scheme.Outline, 0.5)
            AddShadow(menuFrame, 3, 0.5)
            
            local picker = Create("ImageButton", {
                BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                Position = UDim2.fromOffset(10, 10),
                Size = UDim2.fromOffset(150, 150),
                Image = "rbxassetid://4155801252",
                AutoButtonColor = false,
                Parent = menuFrame
            })
            AddCorner(picker, 6)
            
            local cursor = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Scheme.Text,
                Position = UDim2.fromScale(sat, 1 - val),
                Size = UDim2.fromOffset(8, 8),
                Parent = picker
            })
            AddCorner(cursor, 4)
            AddStroke(cursor, Scheme.Outline, 1)
            
            local hueBar = Create("ImageButton", {
                Position = UDim2.fromOffset(168, 10),
                Size = UDim2.fromOffset(20, 150),
                Image = "rbxassetid://5553946806",
                AutoButtonColor = false,
                Parent = menuFrame
            })
            AddCorner(hueBar, 4)
            
            local hueGradient = Create("UIGradient", {
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                },
                Rotation = 90,
                Parent = hueBar
            })
            
            local hueCursor = Create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Scheme.Text,
                Position = UDim2.fromScale(0.5, hue),
                Size = UDim2.new(1, 4, 0, 3),
                Parent = hueBar
            })
            AddStroke(hueCursor, Scheme.Outline, 1)
            
            local preview = Create("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = value,
                Position = UDim2.new(1, -10, 0, 10),
                Size = UDim2.fromOffset(32, 32),
                Parent = menuFrame
            })
            AddCorner(preview, 6)
            AddStroke(preview, Scheme.Outline, 1)
            
            local hexLabel = Create("TextBox", {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                BackgroundTransparency = 0.5,
                FontFace = Font,
                Position = UDim2.fromOffset(10, 165),
                Size = UDim2.fromOffset(200, 22),
                Text = value:ToHex(),
                TextColor3 = Scheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                ClearTextOnFocus = false,
                Parent = menuFrame
            })
            AddCorner(hexLabel, 4)
            AddStroke(hexLabel, Scheme.Outline, 0.5)
            
            local rgbLabel = Create("TextBox", {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                BackgroundTransparency = 0.5,
                FontFace = Font,
                Position = UDim2.fromOffset(10, 190),
                Size = UDim2.fromOffset(200, 22),
                Text = string.format("%d, %d, %d", 
                    math.floor(value.R * 255), 
                    math.floor(value.G * 255), 
                    math.floor(value.B * 255)),
                TextColor3 = Scheme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Center,
                ClearTextOnFocus = false,
                Parent = menuFrame
            })
            AddCorner(rgbLabel, 4)
            AddStroke(rgbLabel, Scheme.Outline, 0.5)
            
            local function UpdateColor(h, s, v)
                value = Color3.fromHSV(h, s, v)
                colorButton.BackgroundColor3 = value
                preview.BackgroundColor3 = value
                picker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                cursor.Position = UDim2.fromScale(s, 1 - v)
                hueCursor.Position = UDim2.fromScale(0.5, h)
                hexLabel.Text = value:ToHex()
                rgbLabel.Text = string.format("%d, %d, %d", 
                    math.floor(value.R * 255), 
                    math.floor(value.G * 255), 
                    math.floor(value.B * 255))
                if onChanged then onChanged(value) end
                if callback then callback(value) end
            end
            
            local dragging = false
            local dragType = nil
            
            picker.MouseButton1Down:Connect(function()
                dragging = true
                dragType = "picker"
            end)
            
            hueBar.MouseButton1Down:Connect(function()
                dragging = true
                dragType = "hue"
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if not menuOpen then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    if dragType == "picker" then
                        local pos = input.Position
                        local relX = Clamp((pos.X - picker.AbsolutePosition.X) / picker.AbsoluteSize.X, 0, 1)
                        local relY = Clamp((pos.Y - picker.AbsolutePosition.Y) / picker.AbsoluteSize.Y, 0, 1)
                        sat = relX
                        val = 1 - relY
                        UpdateColor(hue, sat, val)
                    elseif dragType == "hue" then
                        local pos = input.Position
                        local relY = Clamp((pos.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                        hue = relY
                        UpdateColor(hue, sat, val)
                    end
                end
            end)
            
            hexLabel.FocusLost:Connect(function()
                local success, color = pcall(Color3.fromHex, hexLabel.Text)
                if success then
                    local h, s, v = color:ToHSV()
                    hue, sat, val = h, s, v
                    UpdateColor(hue, sat, val)
                end
            end)
            
            rgbLabel.FocusLost:Connect(function()
                local r, g, b = rgbLabel.Text:match("(%d+),%s*(%d+),%s*(%d+)")
                if r and g and b then
                    local color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                    local h, s, v = color:ToHSV()
                    hue, sat, val = h, s, v
                    UpdateColor(hue, sat, val)
                end
            end)
            
            menuOpen = true
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and menuOpen then
                if not IsMouseInFrame(colorButton, input.Position) and not IsMouseInFrame(menuFrame, input.Position) then
                    CloseMenu()
                end
            end
        end)
        
        section.Elements[config.Title] = {colorButton = colorButton}
        
        return {
            SetValue = function(c)
                value = c
                colorButton.BackgroundColor3 = c
                local h, s, v = c:ToHSV()
                hue, sat, val = h, s, v
                if onChanged then onChanged(c) end
                if callback then callback(c) end
            end,
            GetValue = function() return value end,
            Destroy = function()
                frame:Destroy()
            end
        }
    end
    
    function window:AddLabel(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = config.Bold and FontBold or Font,
            Size = UDim2.new(1, 0, 0, config.Height or 22),
            Text = config.Title or "",
            TextColor3 = config.Color or Scheme.TextDim,
            TextSize = config.Size or 14,
            TextXAlignment = config.Align or Enum.TextXAlignment.Left,
            TextWrapped = config.Wrap or false,
            Parent = section.container
        })
        
        if config.Icon then
            Create("ImageLabel", {
                BackgroundTransparency = 1,
                Image = config.Icon,
                ImageColor3 = config.Color or Scheme.TextDim,
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.fromOffset(16, 16),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = label
            })
        end
        
        section.Elements[config.Title] = label
        
        return {
            SetText = function(text)
                label.Text = text
            end,
            SetColor = function(color)
                label.TextColor3 = color
            end,
            Destroy = function()
                label:Destroy()
            end
        }
    end
    
    function window:AddParagraph(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = section.container
        })
        
        local title = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = FontBold,
            Size = UDim2.new(1, 0, 0, 24),
            Text = config.Title or "",
            TextColor3 = Scheme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local desc = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Position = UDim2.fromOffset(0, 26),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = config.Description or "",
            TextColor3 = Scheme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = frame
        })
        
        section.Elements[config.Title] = {title = title, desc = desc}
        
        return {
            SetTitle = function(text)
                title.Text = text
            end,
            SetDescription = function(text)
                desc.Text = text
            end,
            Destroy = function()
                frame:Destroy()
            end
        }
    end
    
    function window:AddDivider(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local divider = Create("Frame", {
            BackgroundColor3 = Scheme.Outline,
            BackgroundTransparency = config.Transparency or 0.3,
            Size = UDim2.new(1, 0, 0, config.Thickness or 1),
            Parent = section.container
        })
        
        if config.Padding then
            Create("UIPadding", {
                PaddingTop = UDim.new(0, config.Padding),
                PaddingBottom = UDim.new(0, config.Padding),
                Parent = divider
            })
        end
        
        return divider
    end
    
    function window:AddKeybind(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local key = config.Default or "None"
        local mode = config.Mode or "Toggle"
        local callback = config.Callback
        local onChanged = config.OnChanged
        local held = false
        
        local frame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = section.container
        })
        
        local label = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Size = UDim2.new(1, -100, 1, 0),
            Text = config.Title or "Keybind",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local keyButton = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BackgroundTransparency = 0.5,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(90, 26),
            Text = key,
            TextColor3 = Scheme.Text,
            TextSize = 13,
            FontFace = Font,
            AutoButtonColor = false,
            Parent = frame
        })
        AddCorner(keyButton, 6)
        AddStroke(keyButton, Scheme.Outline, 0.5)
        
        local listening = false
        
        keyButton.MouseButton1Click:Connect(function()
            listening = true
            keyButton.Text = "..."
            keyButton.TextColor3 = Scheme.Primary
            keyButton.BackgroundColor3 = Scheme.PrimaryDark
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    local keyName = input.KeyCode.Name
                    if keyName ~= "Unknown" then
                        key = keyName
                        keyButton.Text = keyName
                        if onChanged then onChanged(key) end
                        if callback then callback(key) end
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.MouseButton2 then
                    key = input.UserInputType.Name
                    keyButton.Text = input.UserInputType.Name
                    if onChanged then onChanged(key) end
                    if callback then callback(key) end
                end
                listening = false
                keyButton.TextColor3 = Scheme.Text
                keyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end)
        
        if mode == "Hold" or mode == "Toggle" then
            local state = false
            local function UpdateState(active)
                if mode == "Toggle" then
                    state = not state
                else
                    state = active
                end
                if callback then callback(state) end
            end
            
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                    if mode == "Hold" then
                        held = true
                        UpdateState(true)
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                    if mode == "Hold" then
                        held = false
                        UpdateState(false)
                    end
                end
            end)
        end
        
        return {
            SetKey = function(newKey)
                key = newKey
                keyButton.Text = newKey
            end,
            GetKey = function() return key end,
            Destroy = function()
                frame:Destroy()
            end
        }
    end
    
    function window:AddList(tabName, sectionName, config)
        local tab = window.Tabs[tabName]
        if not tab then return end
        
        local section
        for _, s in pairs(tab.Sections) do
            if s.Name == sectionName then
                section = s
                break
            end
        end
        if not section then return end
        
        local items = config.Values or {}
        local callback = config.Callback
        local onChanged = config.OnChanged
        
        local frame = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
            BackgroundTransparency = theme == "Transparent" and 0.3 or 0,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = section.container
        })
        AddCorner(frame, 8)
        AddStroke(frame, Scheme.Outline, 0.5)
        
        local header = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = FontBold,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -24, 0, 32),
            Text = config.Title or "List",
            TextColor3 = Scheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame
        })
        
        local container = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.new(1, 0, 0, config.Height or 100),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Scheme.Outline,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = frame
        })
        
        local list = Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = container
        })
        
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            Parent = container
        })
        
        local function BuildList()
            for _, child in pairs(container:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            for i, item in pairs(items) do
                local btn = Create("TextButton", {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                    BackgroundTransparency = 0.3,
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = container
                })
                AddCorner(btn, 4)
                
                local label = Create("TextLabel", {
                    BackgroundTransparency = 1,
                    FontFace = Font,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -16, 1, 0),
                    Text = tostring(item),
                    TextColor3 = Scheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = btn
                })
                
                local removeBtn = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -4, 0.5, 0),
                    Size = UDim2.fromOffset(20, 20),
                    Text = "✕",
                    TextColor3 = Scheme.Danger,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = btn
                })
                
                removeBtn.MouseButton1Click:Connect(function()
                    table.remove(items, i)
                    BuildList()
                    if onChanged then onChanged(items) end
                    if callback then callback(items) end
                end)
                
                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.3
                    }):Play()
                end)
            end
        end
        
        BuildList()
        
        local addFrame = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Parent = frame
        })
        
        local addInput = Create("TextBox", {
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BackgroundTransparency = 0.5,
            FontFace = Font,
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(0.7, -12, 1, 0),
            Text = "",
            PlaceholderText = "Add item...",
            TextColor3 = Scheme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = addFrame
        })
        AddCorner(addInput, 4)
        
        local addBtn = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Scheme.Primary,
            BackgroundTransparency = 0.5,
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(50, 26),
            Text = "Add",
            TextColor3 = Scheme.Text,
            TextSize = 13,
            FontFace = Font,
            AutoButtonColor = false,
            Parent = addFrame
        })
        AddCorner(addBtn, 4)
        
        addBtn.MouseButton1Click:Connect(function()
            if addInput.Text ~= "" then
                table.insert(items, addInput.Text)
                addInput.Text = ""
                BuildList()
                if onChanged then onChanged(items) end
                if callback then callback(items) end
            end
        end)
        
        addInput.FocusLost:Connect(function(enter)
            if enter and addInput.Text ~= "" then
                table.insert(items, addInput.Text)
                addInput.Text = ""
                BuildList()
                if onChanged then onChanged(items) end
                if callback then callback(items) end
            end
        end)
        
        return {
            AddItem = function(item)
                table.insert(items, item)
                BuildList()
                if onChanged then onChanged(items) end
            end,
            RemoveItem = function(index)
                table.remove(items, index)
                BuildList()
                if onChanged then onChanged(items) end
            end,
            GetItems = function() return items end,
            Destroy = function()
                frame:Destroy()
            end
        }
    end
    
    function window:Notify(config)
        local notif = Create("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(25, 25, 33),
            BackgroundTransparency = 0.95,
            Position = UDim2.new(1, -12, 0, 12),
            Size = UDim2.fromOffset(320, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Parent = ScreenGui
        })
        AddCorner(notif, 10)
        AddStroke(notif, Scheme.Outline, 0.5)
        AddShadow(notif, 4, 0.5)
        
        if config.Acrylic then
            CreateAcrylic(notif, UDim2.new(1, 0, 1, 0), nil, 0.4)
        end
        
        local icon = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Position = UDim2.fromOffset(12, 12),
            Size = UDim2.fromOffset(24, 24),
            Text = config.Icon or "📢",
            TextColor3 = config.IconColor or Scheme.Text,
            TextSize = 18,
            Parent = notif
        })
        
        local title = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = FontBold,
            Position = UDim2.fromOffset(44, 8),
            Size = UDim2.new(1, -68, 0, 22),
            Text = config.Title or "Notification",
            TextColor3 = Scheme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif
        })
        
        local desc = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Position = UDim2.fromOffset(44, 30),
            Size = UDim2.new(1, -68, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = config.Description or "",
            TextColor3 = Scheme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = notif
        })
        
        local closeBtn = Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -8, 0, 8),
            Size = UDim2.fromOffset(20, 20),
            Text = "✕",
            TextColor3 = Scheme.TextDim,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = notif
        })
        AddCorner(closeBtn, 4)
        
        if config.Progress then
            local progressBar = Create("Frame", {
                BackgroundColor3 = Scheme.Surface2,
                Size = UDim2.new(1, 0, 0, 3),
                Position = UDim2.new(0, 0, 1, -3),
                Parent = notif
            })
            
            local progressFill = Create("Frame", {
                BackgroundColor3 = Scheme.Primary,
                Size = UDim2.new(0, 0, 1, 0),
                Parent = progressBar
            })
            AddCorner(progressFill, 2)
            
            notif.Progress = {
                SetValue = function(v)
                    local p = Clamp(v or 0, 0, 1)
                    TweenService:Create(progressFill, TweenInfo.new(0.3), {
                        Size = UDim2.new(p, 0, 1, 0)
                    }):Play()
                end
            }
        end
        
        notif.Position = UDim2.new(1, 12, 0, 12)
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -12, 0, 12)
        }):Play()
        
        local function Destroy()
            TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                Position = UDim2.new(1, 12, 0, 12)
            }):Play()
            task.wait(0.4)
            notif:Destroy()
        end
        
        closeBtn.MouseButton1Click:Connect(Destroy)
        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Scheme.Danger,
                BackgroundTransparency = 0.5
            }):Play()
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1
            }):Play()
        end)
        
        if config.Timeout then
            task.wait(config.Timeout)
            if notif.Parent then Destroy() end
        end
        
        table.insert(Fluent.Notifications, notif)
        
        return {
            Destroy = Destroy,
            SetProgress = function(v)
                if notif.Progress then
                    notif.Progress.SetValue(v)
                end
            end,
            SetTitle = function(text)
                title.Text = text
            end,
            SetDescription = function(text)
                desc.Text = text
            end
        }
    end
    
    function window:Dialog(config)
        local dialog = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 10000,
            Parent = ScreenGui
        })
        
        local dialogFrame = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
            BackgroundTransparency = 0.95,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(400, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true,
            Parent = dialog
        })
        AddCorner(dialogFrame, 12)
        AddStroke(dialogFrame, Scheme.Outline, 1)
        AddShadow(dialogFrame, 8, 0.6)
        
        if config.Acrylic then
            CreateAcrylic(dialogFrame, UDim2.new(1, 0, 1, 0), nil, 0.5)
        end
        
        local content = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = dialogFrame
        })
        
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 24),
            PaddingLeft = UDim.new(0, 24),
            PaddingRight = UDim.new(0, 24),
            PaddingTop = UDim.new(0, 24),
            Parent = content
        })
        
        local title = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = FontBold,
            Size = UDim2.new(1, 0, 0, 28),
            Text = config.Title or "Dialog",
            TextColor3 = Scheme.Text,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = content
        })
        
        local desc = Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace = Font,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = config.Description or "",
            TextColor3 = Scheme.TextDim,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = content
        })
        
        if config.Input then
            local inputBox = Create("TextBox", {
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                BackgroundTransparency = 0.5,
                FontFace = Font,
                Size = UDim2.new(1, 0, 0, 32),
                Position = UDim2.fromOffset(0, 8),
                Text = config.Input.Default or "",
                PlaceholderText = config.Input.Placeholder or "",
                TextColor3 = Scheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = content
            })
            AddCorner(inputBox, 6)
            AddStroke(inputBox, Scheme.Outline, 0.5)
            
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                Parent = inputBox
            })
        end
        
        local buttonContainer = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Position = UDim2.fromOffset(0, 8),
            Parent = content
        })
        
        local buttons = {}
        for i, btnConfig in pairs(config.Buttons or {}) do
            local btn = Create("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = btnConfig.Primary and Scheme.Primary or Color3.fromRGB(40, 40, 50),
                BackgroundTransparency = btnConfig.Primary and 0.2 or 0.5,
                Position = UDim2.new(1, -(i - 1) * 90 - 8, 0.5, 0),
                Size = UDim2.fromOffset(80, 32),
                Text = btnConfig.Text or "Button",
                TextColor3 = btnConfig.Primary and Scheme.Text or Scheme.Text,
                TextSize = 14,
                FontFace = Font,
                AutoButtonColor = false,
                Parent = buttonContainer
            })
            AddCorner(btn, 6)
            
            btn.MouseButton1Click:Connect(function()
                if btnConfig.Callback then
                    btnConfig.Callback()
                end
                if btnConfig.Close ~= false then
                    dialog:Destroy()
                end
            end)
            
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundTransparency = btnConfig.Primary and 0 or 0.2
                }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {
                    BackgroundTransparency = btnConfig.Primary and 0.2 or 0.5
                }):Play()
            end)
            
            table.insert(buttons, btn)
        end
        
        dialog.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Escape then
                dialog:Destroy()
            end
        end)
        
        return dialog
    end
    
    function window:Destroy()
        main:Destroy()
    end
    
    Fluent.Objects[title] = window
    
    return window
end

function Fluent:Notify(config)
    for _, obj in pairs(Fluent.Objects) do
        if obj.Notify then
            return obj:Notify(config)
        end
    end
end

function Fluent:Dialog(config)
    for _, obj in pairs(Fluent.Objects) do
        if obj.Dialog then
            return obj:Dialog(config)
        end
    end
end

function Fluent:CreateConfig(name)
    local config = {}
    config.Name = name
    config.Data = {}
    config.FilePath = "FluentConfig_" .. name .. ".json"
    
    function config:Save()
        if not writefile then return false end
        local success, err = pcall(function()
            writefile(self.FilePath, HttpService:JSONEncode(self.Data))
        end)
        return success
    end
    
    function config:Load()
        if not readfile then return false end
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(self.FilePath))
        end)
        if success and typeof(data) == "table" then
            self.Data = data
            return true
        end
        return false
    end
    
    function config:Set(key, value)
        self.Data[key] = value
    end
    
    function config:Get(key, default)
        return self.Data[key] or default
    end
    
    Fluent.Configs[name] = config
    return config
end

function Fluent:SetTheme(theme)
    for k, v in pairs(theme) do
        if Scheme[k] then
            Scheme[k] = v
        end
    end
    for _, obj in pairs(Fluent.Objects) do
        if obj.UpdateTheme then
            obj:UpdateTheme(obj.Theme or "Dark")
        end
    end
end

function Fluent:GetTheme()
    return DeepClone(Scheme)
end

function Fluent:Destroy()
    for _, obj in pairs(Fluent.Objects) do
        if obj.Destroy then
            obj:Destroy()
        end
    end
    ScreenGui:Destroy()
end

return Fluent
