local cloneref = cloneref or clonereference or function(v) return v end
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end
local setclipboard = setclipboard or nil

local KeySystem = {}
KeySystem.__index = KeySystem

KeySystem.DefaultConfig = {
    Title = "Key System",
    Description = "Enter your key to continue.",
    Footer = "Powered by KeySystemUI",

    Size = UDim2.fromOffset(520, 390),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Center = true,
    Draggable = true,
    CornerRadius = 8,
    StrokeThickness = 1,

    BackgroundImage = "",
    BackgroundImageTransparency = 0.15,
    BackgroundImageColor = Color3.fromRGB(255, 255, 255),
    BackgroundScaleType = Enum.ScaleType.Crop,
    BackgroundDim = 0.35,

    BlurBackground = false,
    DisplayOrder = 999,
    Parent = nil,

    KeyFile = "KeySystem/saved_key.txt",
    SaveKey = true,
    AutoLoadSavedKey = true,
    AutoCheckSavedKey = false,
    AutoDeleteInvalidKey = true,
    ClearInputWhenInvalid = false,

    KeyPlaceholder = "Paste key here...",
    KeyBoxHeight = 42,
    KeyBoxClearTextOnFocus = false,
    HideKeyText = false,

    ButtonIcons = true,
    IconSide = "Left", -- Left or Right. Content stays centered together.
    IconSize = 18,
    IconGap = 8,
    IconColor = Color3.fromRGB(255, 255, 255),
    LucideURL = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",

    MainButtonText = "Verify Key",
    MainButtonIcon = "key-round",
    GetKeyButtonText = "Get Key",
    GetKeyButtonIcon = "external-link",
    CopyDiscordButtonText = "Copy Discord",
    CopyDiscordButtonIcon = "copy",
    DeleteKeyButtonText = "Delete Saved Key",
    DeleteKeyButtonIcon = "trash-2",
    CloseButtonIcon = "x",

    KeyLink = "",
    Discord = "",

    ShowGetKeyButton = true,
    ShowDiscordButton = true,
    ShowDeleteKeyButton = true,
    ShowCloseButton = true,

    ButtonHeight = 38,
    ButtonGap = 8,

    TweenTime = 0.18,
    TweenStyle = Enum.EasingStyle.Quad,
    TweenDirection = Enum.EasingDirection.Out,

    StatusSuccess = "Key verified successfully.",
    StatusInvalid = "Invalid key.",
    StatusChecking = "Checking key...",
    StatusLoaded = "Loaded saved key.",
    StatusDeleted = "Saved key deleted.",
    StatusCopied = "Copied to clipboard.",
    StatusCopyFail = "Clipboard is not supported.",

    Theme = {
        BackgroundColor = Color3.fromRGB(14, 14, 18),
        MainColor = Color3.fromRGB(24, 24, 30),
        SecondColor = Color3.fromRGB(32, 32, 40),
        AccentColor = Color3.fromRGB(125, 85, 255),
        AccentHoverColor = Color3.fromRGB(145, 105, 255),
        OutlineColor = Color3.fromRGB(55, 55, 70),
        FontColor = Color3.fromRGB(255, 255, 255),
        MutedFontColor = Color3.fromRGB(175, 175, 190),
        ErrorColor = Color3.fromRGB(255, 70, 70),
        SuccessColor = Color3.fromRGB(70, 255, 150),
        WarningColor = Color3.fromRGB(255, 190, 70),
        ButtonTextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Code,
    },

    HoverTheme = {
        ButtonBackgroundColor = nil,
        ButtonTextColor = nil,
        ButtonIconColor = nil,
        OutlineColor = nil,
    },

    VerifyKey = function(key)
        return key == "test-key"
    end,

    OnSuccess = function(key, ui) end,
    OnInvalid = function(key, ui) end,
    OnClose = function(ui) end,
}

local function Merge(base, given)
    local out = {}
    for k, v in pairs(base) do
        if typeof(v) == "table" and typeof(given and given[k]) == "table" then
            out[k] = Merge(v, given[k])
        else
            out[k] = v
        end
    end
    if typeof(given) == "table" then
        for k, v in pairs(given) do
            if typeof(v) == "table" and typeof(out[k]) == "table" then
                out[k] = Merge(out[k], v)
            else
                out[k] = v
            end
        end
    end
    return out
end

local function ToAsset(icon)
    if icon == nil or icon == "" then return nil end
    if typeof(icon) == "number" then return "rbxassetid://" .. tostring(icon) end
    if typeof(icon) ~= "string" then return nil end
    if icon:match("^rbxassetid://") or icon:match("^rbxthumb://") or icon:match("roblox%.com/asset") then
        return icon
    end
    if tonumber(icon) then
        return "rbxassetid://" .. icon
    end
    return nil
end

local function MakeFolderPath(path)
    if not (isfolder and makefolder) then return end
    local parts = string.split(path, "/")
    if #parts <= 1 then return end
    local current = ""
    for i = 1, #parts - 1 do
        current ..= parts[i]
        if current ~= "" and not isfolder(current) then
            pcall(makefolder, current)
        end
        current ..= "/"
    end
end

local function SaveFile(path, text)
    if not (writefile and path) then return false end
    MakeFolderPath(path)
    local ok = pcall(writefile, path, tostring(text or ""))
    return ok
end

local function ReadFile(path)
    if not (readfile and isfile and path and isfile(path)) then return nil end
    local ok, data = pcall(readfile, path)
    if ok then return data end
    return nil
end

local function DeleteFile(path)
    if delfile and isfile and path and isfile(path) then
        return pcall(delfile, path)
    end
    if writefile and isfile and path and isfile(path) then
        return pcall(writefile, path, "")
    end
    return false
end

local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function TextBounds(text, font, size)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = tostring(text or "")
    params.Font = typeof(font) == "Font" and font or Font.fromEnum(font or Enum.Font.Code)
    params.Size = size or 16
    params.Width = 10000
    local ok, result = pcall(function()
        return TextService:GetTextBoundsAsync(params)
    end)
    if ok then return result end
    return Vector2.new(#tostring(text or "") * (size or 16) * 0.55, size or 16)
end

function KeySystem:_LoadLucide()
    if self.LucideLoaded then return end
    self.LucideLoaded = true
    self.LucideIcons = nil
    if not game.HttpGet then return end
    local ok, module = pcall(function()
        return loadstring(game:HttpGet(self.Config.LucideURL))()
    end)
    if ok and typeof(module) == "table" and typeof(module.GetAsset) == "function" then
        self.LucideIcons = module
    end
end

function KeySystem:_GetIcon(icon)
    local asset = ToAsset(icon)
    if asset then
        return { Url = asset, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
    end
    if typeof(icon) == "string" then
        self:_LoadLucide()
        if self.LucideIcons then
            local ok, data = pcall(self.LucideIcons.GetAsset, icon)
            if ok and data then return data end
        end
    end
    return nil
end

function KeySystem:_SetStatus(text, color, flash)
    self.StatusLabel.Text = text or ""
    self.StatusLabel.TextColor3 = color or self.Config.Theme.MutedFontColor
    if flash then
        self.StatusLabel.TextTransparency = 1
        Tween(self.StatusLabel, self.TweenInfo, { TextTransparency = 0 })
    end
end

function KeySystem:_ApplyTheme(theme)
    self.Config.Theme = Merge(self.Config.Theme, theme or {})
    local t = self.Config.Theme
    self.MainFrame.BackgroundColor3 = t.BackgroundColor
    self.Topbar.BackgroundColor3 = t.MainColor
    self.Content.BackgroundColor3 = t.MainColor
    self.TitleLabel.TextColor3 = t.FontColor
    self.DescriptionLabel.TextColor3 = t.MutedFontColor
    self.FooterLabel.TextColor3 = t.MutedFontColor
    self.KeyBox.BackgroundColor3 = t.SecondColor
    self.KeyBox.TextColor3 = t.FontColor
    self.KeyBox.PlaceholderColor3 = t.MutedFontColor
    self.StatusLabel.TextColor3 = t.MutedFontColor
    self.MainStroke.Color = t.OutlineColor
    self.ContentStroke.Color = t.OutlineColor
    self.KeyStroke.Color = t.OutlineColor
    for _, btn in ipairs(self.Buttons) do
        btn.BackgroundColor3 = btn:GetAttribute("IsAccent") and t.AccentColor or t.SecondColor
        local label = btn:FindFirstChild("Label")
        if label then label.TextColor3 = t.ButtonTextColor end
        local icon = btn:FindFirstChild("Icon")
        if icon then icon.ImageColor3 = self.Config.IconColor or t.ButtonTextColor end
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = t.OutlineColor end
    end
end

function KeySystem:SetTheme(theme)
    self:_ApplyTheme(theme)
end

function KeySystem:SetHoverTheme(theme)
    self.Config.HoverTheme = Merge(self.Config.HoverTheme, theme or {})
end

function KeySystem:_CreateButton(info)
    local cfg = self.Config
    local theme = cfg.Theme
    local button = New("TextButton", {
        Name = info.Name or "Button",
        AutoButtonColor = false,
        BackgroundColor3 = info.Accent and theme.AccentColor or theme.SecondColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, cfg.ButtonHeight),
        Text = "",
        Parent = self.ButtonHolder,
    })
    button:SetAttribute("IsAccent", info.Accent and true or false)

    New("UICorner", { CornerRadius = UDim.new(0, math.max(3, cfg.CornerRadius - 2)), Parent = button })
    New("UIStroke", { Color = theme.OutlineColor, Thickness = 1, Parent = button })

    local center = New("Frame", {
        Name = "Center",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, cfg.ButtonHeight),
        Parent = button,
    })

    local list = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, cfg.IconGap),
        Parent = center,
    })

    local iconData = cfg.ButtonIcons and self:_GetIcon(info.Icon)
    local icon
    local label = New("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = theme.Font,
        Text = info.Text or "Button",
        TextColor3 = theme.ButtonTextColor,
        TextSize = 15,
        TextTransparency = 0.05,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, cfg.ButtonHeight),
        Parent = center,
    })

    if iconData then
        icon = New("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = iconData.Url,
            ImageColor3 = cfg.IconColor or theme.ButtonTextColor,
            ImageRectOffset = iconData.ImageRectOffset or Vector2.zero,
            ImageRectSize = iconData.ImageRectSize or Vector2.zero,
            Size = UDim2.fromOffset(cfg.IconSize, cfg.IconSize),
            Parent = center,
        })
        if cfg.IconSide == "Right" then
            label.LayoutOrder = 1
            icon.LayoutOrder = 2
        else
            icon.LayoutOrder = 1
            label.LayoutOrder = 2
        end
    end

    local function resize()
        local bounds = TextBounds(label.Text, Font.fromEnum(theme.Font), label.TextSize)
        local width = bounds.X + 4
        if icon then width += cfg.IconSize + cfg.IconGap end
        center.Size = UDim2.fromOffset(width, cfg.ButtonHeight)
    end
    resize()
    label:GetPropertyChangedSignal("Text"):Connect(resize)

    local normalColor = button.BackgroundColor3
    local hoverTheme = cfg.HoverTheme or {}
    local hoverBg = hoverTheme.ButtonBackgroundColor or (info.Accent and theme.AccentHoverColor or Color3.fromRGB(
        math.clamp(normalColor.R * 255 + 12, 0, 255),
        math.clamp(normalColor.G * 255 + 12, 0, 255),
        math.clamp(normalColor.B * 255 + 12, 0, 255)
    ))
    local hoverText = hoverTheme.ButtonTextColor or theme.ButtonTextColor
    local hoverIcon = hoverTheme.ButtonIconColor or cfg.IconColor or theme.ButtonTextColor
    local hoverOutline = hoverTheme.OutlineColor or theme.AccentColor

    button.MouseEnter:Connect(function()
        Tween(button, self.TweenInfo, { BackgroundColor3 = hoverBg })
        Tween(label, self.TweenInfo, { TextColor3 = hoverText, TextTransparency = 0 })
        local stroke = button:FindFirstChildOfClass("UIStroke")
        if stroke then Tween(stroke, self.TweenInfo, { Color = hoverOutline }) end
        if icon then Tween(icon, self.TweenInfo, { ImageColor3 = hoverIcon, ImageTransparency = 0 }) end
    end)

    button.MouseLeave:Connect(function()
        Tween(button, self.TweenInfo, { BackgroundColor3 = button:GetAttribute("IsAccent") and self.Config.Theme.AccentColor or self.Config.Theme.SecondColor })
        Tween(label, self.TweenInfo, { TextColor3 = self.Config.Theme.ButtonTextColor, TextTransparency = 0.05 })
        local stroke = button:FindFirstChildOfClass("UIStroke")
        if stroke then Tween(stroke, self.TweenInfo, { Color = self.Config.Theme.OutlineColor }) end
        if icon then Tween(icon, self.TweenInfo, { ImageColor3 = self.Config.IconColor or self.Config.Theme.ButtonTextColor, ImageTransparency = 0 }) end
    end)

    button.MouseButton1Click:Connect(function()
        if info.Callback then info.Callback() end
    end)

    table.insert(self.Buttons, button)
    return button
end

function KeySystem:_Verify(key, fromSaved)
    key = tostring(key or self.KeyBox.Text or "")
    if key:gsub("%s+", "") == "" then
        self:_SetStatus("Enter a key first.", self.Config.Theme.WarningColor, true)
        return false
    end

    self:_SetStatus(self.Config.StatusChecking, self.Config.Theme.WarningColor, true)

    local ok, valid, extra = pcall(self.Config.VerifyKey, key, self)
    valid = ok and valid == true

    if valid then
        self.ValidatedKey = key
        if self.Config.SaveKey then
            SaveFile(self.Config.KeyFile, key)
        end
        self:_SetStatus(extra or self.Config.StatusSuccess, self.Config.Theme.SuccessColor, true)
        Tween(self.MainStroke, self.TweenInfo, { Color = self.Config.Theme.SuccessColor })
        task.delay(0.25, function()
            if self.MainStroke then Tween(self.MainStroke, self.TweenInfo, { Color = self.Config.Theme.OutlineColor }) end
        end)
        self.Config.OnSuccess(key, self)
        return true
    end

    if self.Config.AutoDeleteInvalidKey then
        DeleteFile(self.Config.KeyFile)
    end
    if self.Config.ClearInputWhenInvalid and not fromSaved then
        self.KeyBox.Text = ""
    end
    self:_SetStatus(extra or self.Config.StatusInvalid, self.Config.Theme.ErrorColor, true)
    Tween(self.MainStroke, self.TweenInfo, { Color = self.Config.Theme.ErrorColor })
    task.delay(0.25, function()
        if self.MainStroke then Tween(self.MainStroke, self.TweenInfo, { Color = self.Config.Theme.OutlineColor }) end
    end)
    self.Config.OnInvalid(key, self)
    return false
end

function KeySystem:DeleteSavedKey()
    DeleteFile(self.Config.KeyFile)
    self:_SetStatus(self.Config.StatusDeleted, self.Config.Theme.WarningColor, true)
end

function KeySystem:Close()
    self.Config.OnClose(self)
    if self.ScreenGui then
        Tween(self.MainFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(self.MainFrame.AbsoluteSize.X * 0.96, self.MainFrame.AbsoluteSize.Y * 0.96),
            BackgroundTransparency = 1,
        })
        task.delay(0.17, function()
            if self.ScreenGui then self.ScreenGui:Destroy() end
        end)
    end
end

function KeySystem:Show()
    self.MainFrame.Visible = true
    self.MainFrame.Size = UDim2.fromOffset(self.Config.Size.X.Offset * 0.96, self.Config.Size.Y.Offset * 0.96)
    Tween(self.MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = self.Config.Size })
end

function KeySystem.new(config)
    local self = setmetatable({}, KeySystem)
    self.Config = Merge(KeySystem.DefaultConfig, config or {})
    self.Buttons = {}
    self.TweenInfo = TweenInfo.new(self.Config.TweenTime, self.Config.TweenStyle, self.Config.TweenDirection)

    local cfg = self.Config
    local theme = cfg.Theme

    local gui = New("ScreenGui", {
        Name = "KeySystemUI_" .. HttpService:GenerateGUID(false),
        DisplayOrder = cfg.DisplayOrder,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
    })
    pcall(protectgui, gui)
    local parent = cfg.Parent or gethui()
    local ok = pcall(function() gui.Parent = parent end)
    if not ok or not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    self.ScreenGui = gui

    local frame = New("Frame", {
        Name = "Window",
        AnchorPoint = cfg.AnchorPoint,
        BackgroundColor3 = theme.BackgroundColor,
        BorderSizePixel = 0,
        Position = cfg.Center and UDim2.fromScale(0.5, 0.5) or cfg.Position,
        Size = cfg.Size,
        Visible = false,
        Parent = gui,
    })
    self.MainFrame = frame
    New("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius), Parent = frame })
    self.MainStroke = New("UIStroke", { Color = theme.OutlineColor, Thickness = cfg.StrokeThickness, Parent = frame })

    if cfg.BackgroundImage and cfg.BackgroundImage ~= "" then
        New("ImageLabel", {
            Name = "BackgroundImage",
            BackgroundTransparency = 1,
            Image = ToAsset(cfg.BackgroundImage) or cfg.BackgroundImage,
            ImageTransparency = cfg.BackgroundImageTransparency,
            ImageColor3 = cfg.BackgroundImageColor,
            ScaleType = cfg.BackgroundScaleType,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 0,
            Parent = frame,
        })
        New("Frame", {
            Name = "BackgroundDim",
            BackgroundColor3 = theme.BackgroundColor,
            BackgroundTransparency = 1 - cfg.BackgroundDim,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 1,
            Parent = frame,
        })
    end

    local topbar = New("Frame", {
        Name = "Topbar",
        BackgroundColor3 = theme.MainColor,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 54),
        ZIndex = 2,
        Parent = frame,
    })
    self.Topbar = topbar
    New("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius), Parent = topbar })

    New("Frame", {
        Name = "TopbarCover",
        BackgroundColor3 = theme.MainColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -cfg.CornerRadius),
        Size = UDim2.new(1, 0, 0, cfg.CornerRadius),
        ZIndex = 2,
        Parent = topbar,
    })

    self.TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Font = theme.Font,
        Text = cfg.Title,
        TextColor3 = theme.FontColor,
        TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -70, 1, 0),
        ZIndex = 3,
        Parent = topbar,
    })

    if cfg.ShowCloseButton then
        local closeIconData = self:_GetIcon(cfg.CloseButtonIcon)
        local close = New("TextButton", {
            Name = "Close",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -46, 0, 9),
            Size = UDim2.fromOffset(36, 36),
            Text = "",
            ZIndex = 3,
            Parent = topbar,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = close })
        if closeIconData then
            New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = closeIconData.Url,
                ImageColor3 = theme.MutedFontColor,
                ImageRectOffset = closeIconData.ImageRectOffset or Vector2.zero,
                ImageRectSize = closeIconData.ImageRectSize or Vector2.zero,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(18, 18),
                Parent = close,
            })
        else
            close.Text = "X"
            close.Font = theme.Font
            close.TextColor3 = theme.MutedFontColor
            close.TextSize = 16
        end
        close.MouseEnter:Connect(function()
            Tween(close, self.TweenInfo, { BackgroundTransparency = 0, BackgroundColor3 = theme.SecondColor })
        end)
        close.MouseLeave:Connect(function()
            Tween(close, self.TweenInfo, { BackgroundTransparency = 1 })
        end)
        close.MouseButton1Click:Connect(function() self:Close() end)
    end

    local content = New("Frame", {
        Name = "Content",
        BackgroundColor3 = theme.MainColor,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 68),
        Size = UDim2.new(1, -28, 1, -92),
        ZIndex = 2,
        Parent = frame,
    })
    self.Content = content
    New("UICorner", { CornerRadius = UDim.new(0, math.max(4, cfg.CornerRadius - 2)), Parent = content })
    self.ContentStroke = New("UIStroke", { Color = theme.OutlineColor, Thickness = 1, Parent = content })
    New("UIPadding", { PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = content })

    local list = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = content,
    })

    self.DescriptionLabel = New("TextLabel", {
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Font = theme.Font,
        Text = cfg.Description,
        TextColor3 = theme.MutedFontColor,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 42),
        Parent = content,
    })

    self.KeyBox = New("TextBox", {
        LayoutOrder = 2,
        BackgroundColor3 = theme.SecondColor,
        ClearTextOnFocus = cfg.KeyBoxClearTextOnFocus,
        Font = theme.Font,
        PlaceholderText = cfg.KeyPlaceholder,
        PlaceholderColor3 = theme.MutedFontColor,
        Text = "",
        TextColor3 = theme.FontColor,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, cfg.KeyBoxHeight),
        Parent = content,
    })
    self.KeyBox.TextTransparency = cfg.HideKeyText and 1 or 0
    New("UICorner", { CornerRadius = UDim.new(0, math.max(3, cfg.CornerRadius - 3)), Parent = self.KeyBox })
    self.KeyStroke = New("UIStroke", { Color = theme.OutlineColor, Thickness = 1, Parent = self.KeyBox })
    New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = self.KeyBox })

    self.KeyBox.Focused:Connect(function()
        Tween(self.KeyStroke, self.TweenInfo, { Color = theme.AccentColor })
    end)
    self.KeyBox.FocusLost:Connect(function(enter)
        Tween(self.KeyStroke, self.TweenInfo, { Color = theme.OutlineColor })
        if enter then self:_Verify(self.KeyBox.Text, false) end
    end)

    self.StatusLabel = New("TextLabel", {
        LayoutOrder = 3,
        BackgroundTransparency = 1,
        Font = theme.Font,
        Text = "",
        TextColor3 = theme.MutedFontColor,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 22),
        Parent = content,
    })

    self.ButtonHolder = New("Frame", {
        LayoutOrder = 4,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = content,
    })
    local buttonList = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, cfg.ButtonGap),
        Parent = self.ButtonHolder,
    })
    buttonList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ButtonHolder.Size = UDim2.new(1, 0, 0, buttonList.AbsoluteContentSize.Y)
    end)

    self:_CreateButton({ Name = "Verify", Text = cfg.MainButtonText, Icon = cfg.MainButtonIcon, Accent = true, Callback = function()
        self:_Verify(self.KeyBox.Text, false)
    end })

    if cfg.ShowGetKeyButton then
        self:_CreateButton({ Name = "GetKey", Text = cfg.GetKeyButtonText, Icon = cfg.GetKeyButtonIcon, Callback = function()
            if cfg.KeyLink ~= "" and setclipboard then
                setclipboard(cfg.KeyLink)
                self:_SetStatus(cfg.StatusCopied, theme.SuccessColor, true)
            elseif cfg.KeyLink ~= "" then
                self:_SetStatus(cfg.KeyLink, theme.WarningColor, true)
            else
                self:_SetStatus("No key link configured.", theme.WarningColor, true)
            end
        end })
    end

    if cfg.ShowDiscordButton then
        self:_CreateButton({ Name = "Discord", Text = cfg.CopyDiscordButtonText, Icon = cfg.CopyDiscordButtonIcon, Callback = function()
            if cfg.Discord ~= "" and setclipboard then
                setclipboard(cfg.Discord)
                self:_SetStatus(cfg.StatusCopied, theme.SuccessColor, true)
            elseif cfg.Discord ~= "" then
                self:_SetStatus(cfg.Discord, theme.WarningColor, true)
            else
                self:_SetStatus(cfg.StatusCopyFail, theme.ErrorColor, true)
            end
        end })
    end

    if cfg.ShowDeleteKeyButton then
        self:_CreateButton({ Name = "DeleteSavedKey", Text = cfg.DeleteKeyButtonText, Icon = cfg.DeleteKeyButtonIcon, Callback = function()
            self:DeleteSavedKey()
            self.KeyBox.Text = ""
        end })
    end

    self.FooterLabel = New("TextLabel", {
        LayoutOrder = 5,
        BackgroundTransparency = 1,
        Font = theme.Font,
        Text = cfg.Footer,
        TextColor3 = theme.MutedFontColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.new(1, 0, 0, 18),
        Parent = content,
    })

    if cfg.Draggable then
        local dragging, startPos, framePos, changed
        topbar.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            dragging = true
            startPos = input.Position
            framePos = frame.Position
            changed = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if changed then changed:Disconnect() changed = nil end
                end
            end)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local delta = input.Position - startPos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end)
    end

    local saved = cfg.AutoLoadSavedKey and ReadFile(cfg.KeyFile)
    if saved and saved ~= "" then
        self.KeyBox.Text = saved
        self:_SetStatus(cfg.StatusLoaded, theme.MutedFontColor, true)
        if cfg.AutoCheckSavedKey then
            task.defer(function()
                self:_Verify(saved, true)
            end)
        end
    end

    self:Show()
    return self
end

return KeySystem
