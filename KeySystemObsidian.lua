local cloneref = cloneref or clonereference or function(x) return x end

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local function ParentGui(Gui)
    pcall(protectgui, Gui)

    local Success = pcall(function()
        Gui.Parent = gethui()
    end)

    if not Success or not Gui.Parent then
        Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local KeyUI = {}

KeyUI.Theme = {
    Background = Color3.fromRGB(13, 13, 18),
    Main = Color3.fromRGB(21, 21, 31),
    Main2 = Color3.fromRGB(30, 30, 44),
    Accent = Color3.fromRGB(125, 85, 255),
    Accent2 = Color3.fromRGB(170, 105, 255),
    Outline = Color3.fromRGB(52, 50, 68),
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(175, 175, 190),
    Red = Color3.fromRGB(255, 70, 70),
    Green = Color3.fromRGB(95, 255, 150),
    Dark = Color3.fromRGB(0, 0, 0),
}

local function Make(ClassName, Props)
    local Obj = Instance.new(ClassName)

    for Key, Value in pairs(Props or {}) do
        Obj[Key] = Value
    end

    return Obj
end

local function Corner(Parent, Radius)
    return Make("UICorner", {
        CornerRadius = UDim.new(0, Radius or 6),
        Parent = Parent,
    })
end

local function Stroke(Parent, Color, Thickness, Transparency)
    return Make("UIStroke", {
        Color = Color or KeyUI.Theme.Outline,
        Thickness = Thickness or 1,
        Transparency = Transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = Parent,
    })
end

local function Padding(Parent, Left, Right, Top, Bottom)
    return Make("UIPadding", {
        PaddingLeft = UDim.new(0, Left or 0),
        PaddingRight = UDim.new(0, Right or 0),
        PaddingTop = UDim.new(0, Top or 0),
        PaddingBottom = UDim.new(0, Bottom or 0),
        Parent = Parent,
    })
end

local function Tween(Obj, Time, Props)
    local T = TweenService:Create(
        Obj,
        TweenInfo.new(Time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Props
    )
    T:Play()
    return T
end

local function IsClick(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
end

local function MakeDraggable(Main, Drag)
    local Dragging = false
    local StartPos
    local StartFramePos
    local EndConnection

    Drag.InputBegan:Connect(function(Input)
        if not IsClick(Input) then return end

        Dragging = true
        StartPos = Input.Position
        StartFramePos = Main.Position

        if EndConnection then
            EndConnection:Disconnect()
        end

        EndConnection = Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
                if EndConnection then
                    EndConnection:Disconnect()
                    EndConnection = nil
                end
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if not Dragging then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end

        local Delta = Input.Position - StartPos
        Main.Position = UDim2.new(
            StartFramePos.X.Scale,
            StartFramePos.X.Offset + Delta.X,
            StartFramePos.Y.Scale,
            StartFramePos.Y.Offset + Delta.Y
        )
    end)
end

function KeyUI:CreateKeySystem(Options)
    Options = Options or {}

    local Window = {}
    Window.Options = Options
    Window.Key = Options.CorrectKey or Options.Key or "test"
    Window.RememberKey = Options.RememberKey == true
    Window.AutoDestroyOnSuccess = Options.AutoDestroyOnSuccess == true
    Window.Elements = {}
    Window.CurrentKeyText = ""

    local Gui = Make("ScreenGui", {
        Name = "KeySystemUI_" .. HttpService:GenerateGUID(false),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = Options.DisplayOrder or 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    ParentGui(Gui)
    Window.ScreenGui = Gui

    local Dim = Make("Frame", {
        Name = "Dim",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = Options.DimTransparency or 0.25,
        Size = UDim2.fromScale(1, 1),
        Parent = Gui,
    })

    local Main = Make("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = KeyUI.Theme.Background,
        Position = Options.Position or UDim2.fromScale(0.5, 0.5),
        Size = Options.Size or UDim2.fromOffset(430, 520),
        ClipsDescendants = true,
        Parent = Gui,
    })
    Window.Main = Main
    Corner(Main, Options.CornerRadius or 14)
    Stroke(Main, KeyUI.Theme.Outline, 1, 0)

    local Background = Make("ImageLabel", {
        Name = "CustomBackground",
        BackgroundTransparency = 1,
        Image = Options.Background or Options.BackgroundId or "",
        ImageTransparency = Options.BackgroundTransparency or 0.18,
        ScaleType = Options.BackgroundScaleType or Enum.ScaleType.Crop,
        Size = UDim2.fromScale(1, 1),
        Parent = Main,
    })
    Window.Background = Background

    local Shade = Make("Frame", {
        Name = "Shade",
        BackgroundColor3 = KeyUI.Theme.Background,
        BackgroundTransparency = Options.ShadeTransparency or 0.16,
        Size = UDim2.fromScale(1, 1),
        Parent = Main,
    })

    local TopBar = Make("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 62),
        Parent = Main,
    })

    local AccentLine = Make("Frame", {
        Name = "AccentLine",
        BackgroundColor3 = KeyUI.Theme.Accent,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Parent = TopBar,
    })

    local Title = Make("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Options.Font or Enum.Font.Code,
        Text = Options.Title or "Key System",
        TextColor3 = KeyUI.Theme.Text,
        TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(18, 8),
        Size = UDim2.new(1, -62, 0, 28),
        RichText = true,
        Parent = TopBar,
    })

    local Subtitle = Make("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Font = Options.Font or Enum.Font.Code,
        Text = Options.Subtitle or "Enter your key to unlock.",
        TextColor3 = KeyUI.Theme.MutedText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(18, 34),
        Size = UDim2.new(1, -62, 0, 20),
        RichText = true,
        Parent = TopBar,
    })

    local Close = Make("TextButton", {
        Name = "Close",
        AutoButtonColor = false,
        BackgroundColor3 = KeyUI.Theme.Main2,
        Font = Options.Font or Enum.Font.Code,
        Text = "×",
        TextColor3 = KeyUI.Theme.Text,
        TextSize = 20,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.fromOffset(32, 32),
        Parent = TopBar,
    })
    Corner(Close, 8)
    Stroke(Close, KeyUI.Theme.Outline, 1, 0.2)

    Close.MouseEnter:Connect(function()
        Tween(Close, 0.12, { BackgroundColor3 = KeyUI.Theme.Red })
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, 0.12, { BackgroundColor3 = KeyUI.Theme.Main2 })
    end)

    Close.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    local Content = Make("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(16, 78),
        Size = UDim2.new(1, -32, 1, -94),
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = KeyUI.Theme.Accent,
        Parent = Main,
    })
    Window.Content = Content

    local List = Make("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Content,
    })

    Padding(Content, 2, 2, 2, 12)
    MakeDraggable(Main, TopBar)

    function Window:Notify(Text, Duration, Color)
        Duration = Duration or 3

        local Note = Make("Frame", {
            Name = "Notification",
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = KeyUI.Theme.Main,
            Position = UDim2.new(1, -18, 0, 18),
            Size = UDim2.fromOffset(290, 58),
            BackgroundTransparency = 1,
            Parent = Gui,
        })
        Corner(Note, 10)
        Stroke(Note, Color or KeyUI.Theme.Accent, 1, 0.1)

        local Bar = Make("Frame", {
            BackgroundColor3 = Color or KeyUI.Theme.Accent,
            Size = UDim2.new(0, 4, 1, 0),
            Parent = Note,
        })
        Corner(Bar, 10)

        local TextLabel = Make("TextLabel", {
            BackgroundTransparency = 1,
            Font = Options.Font or Enum.Font.Code,
            Text = Text or "Notification",
            TextColor3 = KeyUI.Theme.Text,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Parent = Note,
        })

        Tween(Note, 0.18, { BackgroundTransparency = 0 })
        task.delay(Duration, function()
            if not Note or not Note.Parent then return end
            Tween(Note, 0.18, { BackgroundTransparency = 1 })
            task.wait(0.2)
            if Note then
                Note:Destroy()
            end
        end)
    end

    function Window:Dialog(DialogOptions)
        DialogOptions = DialogOptions or {}

        local Overlay = Make("Frame", {
            Name = "DialogOverlay",
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.35,
            Size = UDim2.fromScale(1, 1),
            Parent = Main,
        })

        local Box = Make("Frame", {
            Name = "Dialog",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = KeyUI.Theme.Main,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(340, 180),
            Parent = Overlay,
        })
        Corner(Box, 12)
        Stroke(Box, KeyUI.Theme.Outline, 1, 0)

        local DTitle = Make("TextLabel", {
            BackgroundTransparency = 1,
            Font = Options.Font or Enum.Font.Code,
            Text = DialogOptions.Title or "Dialog",
            TextColor3 = KeyUI.Theme.Text,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(16, 12),
            Size = UDim2.new(1, -32, 0, 26),
            Parent = Box,
        })

        local DDesc = Make("TextLabel", {
            BackgroundTransparency = 1,
            Font = Options.Font or Enum.Font.Code,
            Text = DialogOptions.Description or "Description",
            TextColor3 = KeyUI.Theme.MutedText,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromOffset(16, 44),
            Size = UDim2.new(1, -32, 0, 70),
            Parent = Box,
        })

        local ButtonHolder = Make("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 1, -50),
            Size = UDim2.new(1, -32, 0, 36),
            Parent = Box,
        })

        local ButtonList = Make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ButtonHolder,
        })

        local Buttons = DialogOptions.Buttons or {
            {
                Text = "OK",
                Callback = function() end
            }
        }

        for _, Info in ipairs(Buttons) do
            local Btn = Make("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Info.Color or KeyUI.Theme.Main2,
                Font = Options.Font or Enum.Font.Code,
                Text = Info.Text or "Button",
                TextColor3 = KeyUI.Theme.Text,
                TextSize = 13,
                Size = UDim2.fromOffset(92, 34),
                Parent = ButtonHolder,
            })
            Corner(Btn, 8)
            Stroke(Btn, KeyUI.Theme.Outline, 1, 0.2)

            Btn.MouseEnter:Connect(function()
                Tween(Btn, 0.12, { BackgroundColor3 = Info.HoverColor or KeyUI.Theme.Accent })
            end)

            Btn.MouseLeave:Connect(function()
                Tween(Btn, 0.12, { BackgroundColor3 = Info.Color or KeyUI.Theme.Main2 })
            end)

            Btn.MouseButton1Click:Connect(function()
                if Info.Callback then
                    task.spawn(Info.Callback, Window)
                end
                if Info.Close ~= false then
                    Overlay:Destroy()
                end
            end)
        end

        return Overlay
    end

    function Window:AddLabel(Text)
        local Label = Make("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Font = Options.Font or Enum.Font.Code,
            Text = Text or "Label",
            TextColor3 = KeyUI.Theme.MutedText,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, -4, 0, 20),
            RichText = true,
            Parent = Content,
        })

        table.insert(Window.Elements, Label)

        return {
            Instance = Label,
            SetText = function(_, NewText)
                Label.Text = NewText
            end,
            SetVisible = function(_, State)
                Label.Visible = State
            end
        }
    end

    function Window:AddTextbox(Info)
        Info = Info or {}

        local Holder = Make("Frame", {
            Name = "TextboxHolder",
            BackgroundColor3 = KeyUI.Theme.Main,
            Size = UDim2.new(1, -4, 0, Info.Height or 46),
            Parent = Content,
        })
        Corner(Holder, 10)
        Stroke(Holder, KeyUI.Theme.Outline, 1, 0.15)

        local Box = Make("TextBox", {
            Name = "Textbox",
            BackgroundTransparency = 1,
            ClearTextOnFocus = Info.ClearTextOnFocus ~= false,
            Font = Options.Font or Enum.Font.Code,
            PlaceholderText = Info.Placeholder or "Type here...",
            PlaceholderColor3 = KeyUI.Theme.MutedText,
            Text = Info.Default or "",
            TextColor3 = KeyUI.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        Padding(Box, 14, 14, 0, 0)

        local Object = {
            Type = "Textbox",
            Holder = Holder,
            Textbox = Box,
            Value = Box.Text,
        }

        function Object:SetText(NewText)
            Box.Text = tostring(NewText or "")
            Object.Value = Box.Text
        end

        function Object:GetText()
            return Box.Text
        end

        function Object:SetVisible(State)
            Holder.Visible = State
        end

        Box:GetPropertyChangedSignal("Text"):Connect(function()
            Object.Value = Box.Text
            Window.CurrentKeyText = Box.Text

            if Info.Changed then
                task.spawn(Info.Changed, Box.Text)
            end

            if Info.Callback and Info.Finished ~= true then
                task.spawn(Info.Callback, Box.Text)
            end
        end)

        Box.FocusLost:Connect(function(EnterPressed)
            Object.Value = Box.Text
            Window.CurrentKeyText = Box.Text

            if Info.Callback and Info.Finished == true then
                task.spawn(Info.Callback, Box.Text, EnterPressed)
            end
        end)

        table.insert(Window.Elements, Object)
        return Object
    end

    function Window:AddButton(Info)
        Info = Info or {}

        local Btn = Make("TextButton", {
            Name = "Button",
            AutoButtonColor = false,
            BackgroundColor3 = Info.Color or KeyUI.Theme.Main2,
            Font = Options.Font or Enum.Font.Code,
            Text = Info.Text or "Button",
            TextColor3 = KeyUI.Theme.Text,
            TextSize = 14,
            Size = UDim2.new(1, -4, 0, Info.Height or 42),
            Parent = Content,
        })
        Corner(Btn, 10)
        Stroke(Btn, KeyUI.Theme.Outline, 1, 0.15)

        Btn.MouseEnter:Connect(function()
            Tween(Btn, 0.12, { BackgroundColor3 = Info.HoverColor or KeyUI.Theme.Accent })
        end)

        Btn.MouseLeave:Connect(function()
            Tween(Btn, 0.12, { BackgroundColor3 = Info.Color or KeyUI.Theme.Main2 })
        end)

        Btn.MouseButton1Click:Connect(function()
            if Info.Callback then
                task.spawn(Info.Callback, Window)
            end
        end)

        local Object = {
            Type = "Button",
            Button = Btn,
            SetText = function(_, NewText)
                Btn.Text = tostring(NewText or "")
            end,
            SetVisible = function(_, State)
                Btn.Visible = State
            end
        }

        table.insert(Window.Elements, Object)
        return Object
    end

    function Window:AddToggle(Info)
        Info = Info or {}

        local Holder = Make("Frame", {
            Name = "ToggleHolder",
            BackgroundColor3 = KeyUI.Theme.Main,
            Size = UDim2.new(1, -4, 0, Info.Height or 42),
            Parent = Content,
        })
        Corner(Holder, 10)
        Stroke(Holder, KeyUI.Theme.Outline, 1, 0.15)

        local Label = Make("TextLabel", {
            BackgroundTransparency = 1,
            Font = Options.Font or Enum.Font.Code,
            Text = Info.Text or "Toggle",
            TextColor3 = KeyUI.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -72, 1, 0),
            Parent = Holder,
        })

        local Switch = Make("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = KeyUI.Theme.Main2,
            Text = "",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(42, 22),
            Parent = Holder,
        })
        Corner(Switch, 12)
        Stroke(Switch, KeyUI.Theme.Outline, 1, 0.15)

        local Dot = Make("Frame", {
            BackgroundColor3 = KeyUI.Theme.MutedText,
            Position = UDim2.fromOffset(3, 3),
            Size = UDim2.fromOffset(16, 16),
            Parent = Switch,
        })
        Corner(Dot, 10)

        local Object = {
            Type = "Toggle",
            Holder = Holder,
            Value = Info.Default == true,
        }

        function Object:SetValue(Value)
            Object.Value = Value == true

            if Object.Value then
                Tween(Switch, 0.12, { BackgroundColor3 = KeyUI.Theme.Accent })
                Tween(Dot, 0.12, {
                    BackgroundColor3 = KeyUI.Theme.Text,
                    Position = UDim2.fromOffset(23, 3)
                })
            else
                Tween(Switch, 0.12, { BackgroundColor3 = KeyUI.Theme.Main2 })
                Tween(Dot, 0.12, {
                    BackgroundColor3 = KeyUI.Theme.MutedText,
                    Position = UDim2.fromOffset(3, 3)
                })
            end

            if Info.Callback then
                task.spawn(Info.Callback, Object.Value)
            end
        end

        function Object:SetVisible(State)
            Holder.Visible = State
        end

        Switch.MouseButton1Click:Connect(function()
            Object:SetValue(not Object.Value)
        end)

        Holder.InputBegan:Connect(function(Input)
            if IsClick(Input) then
                Object:SetValue(not Object.Value)
            end
        end)

        Object:SetValue(Object.Value)

        table.insert(Window.Elements, Object)
        return Object
    end

    function Window:AddKeyBox(Info)
        Info = Info or {}

        local KeyBox = self:AddTextbox({
            Placeholder = Info.Placeholder or "Enter key...",
            ClearTextOnFocus = Info.ClearTextOnFocus ~= false,
            Default = Info.Default or "",
            Changed = function(Text)
                Window.CurrentKeyText = Text
                if Info.Changed then
                    Info.Changed(Text)
                end
            end,
            Finished = Info.Finished or false,
            Callback = Info.Callback
        })

        Window.KeyBox = KeyBox
        return KeyBox
    end

    function Window:CheckKey(Key)
        Key = tostring(Key or Window.CurrentKeyText or "")
        local Correct = false

        if typeof(Window.Key) == "table" then
            for _, ValidKey in ipairs(Window.Key) do
                if Key == tostring(ValidKey) then
                    Correct = true
                    break
                end
            end
        else
            Correct = Key == tostring(Window.Key)
        end

        if Options.Verify then
            local Success, Result = pcall(Options.Verify, Key, Window)
            Correct = Success and Result == true
        end

        if Correct then
            Window:Notify(Options.SuccessMessage or "Correct key. Access granted.", 3, KeyUI.Theme.Green)

            if Options.OnSuccess then
                task.spawn(Options.OnSuccess, Key, Window)
            end

            if Window.AutoDestroyOnSuccess then
                task.delay(0.6, function()
                    Window:Destroy()
                end)
            end
        else
            Window:Notify(Options.FailMessage or "Invalid key. Try again.", 3, KeyUI.Theme.Red)

            if Options.OnFail then
                task.spawn(Options.OnFail, Key, Window)
            end
        end

        return Correct
    end

    function Window:SetBackground(ImageId)
        Background.Image = tostring(ImageId or "")
    end

    function Window:SetTitle(NewTitle)
        Title.Text = tostring(NewTitle or "")
    end

    function Window:SetSubtitle(NewSubtitle)
        Subtitle.Text = tostring(NewSubtitle or "")
    end

    function Window:Destroy()
        if Gui then
            Gui:Destroy()
        end
    end

    if Options.DefaultElements ~= false then
        Window:AddLabel(Options.Description or "Paste your key below. You can customize every button, textbox, dialog, and the background image.")

        Window:AddKeyBox({
            Placeholder = Options.KeyPlaceholder or "Enter key..."
        })

        Window:AddButton({
            Text = Options.SubmitText or "Submit Key",
            Callback = function()
                Window:CheckKey()
            end
        })

        Window:AddButton({
            Text = Options.GetKeyText or "Get Key",
            Callback = function()
                if Options.GetKey then
                    task.spawn(Options.GetKey, Window)
                elseif Options.GetKeyURL then
                    if setclipboard then
                        setclipboard(Options.GetKeyURL)
                        Window:Notify("Key link copied.", 3)
                    else
                        Window:Notify(Options.GetKeyURL, 5)
                    end
                else
                    Window:Dialog({
                        Title = "Get Key",
                        Description = "Add GetKeyURL or GetKey = function(Window) to this button.",
                        Buttons = {
                            { Text = "OK" }
                        }
                    })
                end
            end
        })
    end

    task.defer(function()
        Main.Size = UDim2.fromOffset(Options.StartWidth or 390, Options.StartHeight or 470)
        Tween(Main, 0.22, { Size = Options.Size or UDim2.fromOffset(430, 520) })
    end)

    return Window
end

return KeyUI
