local cloneref = cloneref or clonereference or function(v) return v end

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end
local setclipboard = setclipboard or nil

local KeySystem = {}
KeySystem.__index = KeySystem

KeySystem.Version = "3.0.0"

KeySystem.DefaultConfig = {
    Title = "Nil Key System",
    Subtitle = "PRIVATE ACCESS",
    Description = "Paste your key below to unlock the script. Saved keys can be loaded automatically and invalid keys can be removed instantly.",
    Footer = "Protected by KeySystemUI Pro",
    Product = "KeySystemUI Pro",
    VersionText = "v3.0",

    Window = {
        Size = UDim2.fromOffset(610, 455),
        MinSize = UDim2.fromOffset(470, 340),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Center = true,
        Draggable = true,
        CornerRadius = 16,
        StrokeThickness = 1,
        DisplayOrder = 999,
        Parent = nil,
        IgnoreGuiInset = true,
        AutoScale = true,
        UIScale = 1,
        MinScale = 0.72,
        MaxScale = 1,
        ScalePadding = 64,
        ClipsDescendants = true,
        ShowConfigButton = true,
        ConfigButtonText = "Config",
    },

    Layout = {
        Padding = 16,
        TopbarHeight = 60,
        SidebarWidth = 142,
        ContentPadding = 16,
        ContentGap = 10,
        DescriptionHeight = 58,
        StatusHeight = 34,
        FooterHeight = 20,
        BadgeHeight = 24,
    },

    Logo = {
        Enabled = true,
        Text = "N",
        Image = "",
        Size = 42,
        CornerRadius = 12,
        Gradient = true,
        Stroke = true,
        Glow = true,
    },

    Background = {
        Image = "",
        ImageTransparency = 0.14,
        ImageColor = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Crop,
        Dim = 0.5,
        ContentTransparency = 0.02,
        SidebarTransparency = 0.03,
        TopbarTransparency = 0,
        PatternTransparency = 0.94,
    },

    Key = {
        File = "KeySystem/saved_key.txt",
        Save = true,
        AutoLoad = true,
        AutoCheck = false,
        AutoDeleteInvalid = true,
        ClearInputWhenInvalid = false,
        Placeholder = "Paste key here...",
        Height = 46,
        ClearTextOnFocus = false,
        HideText = false,
        SubmitOnEnter = true,
        Trim = true,
        FocusSelectAll = false,
        ShowKeyIcon = true,
        ShowKeyLength = true,
        MinLength = 1,
        MaxLength = 128,
    },

    Buttons = {
        Height = 41,
        Gap = 8,
        Icons = true,
        IconSide = "Right", -- "Left" or "Right"
        IconSize = 18,
        IconGap = 8,
        IconColor = nil,
        LucideURL = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",

        MainText = "Verify Key",
        MainIcon = "key-round",

        GetKeyText = "Get Key",
        GetKeyIcon = "external-link",

        DiscordText = "Copy Discord",
        DiscordIcon = "copy",

        DeleteKeyText = "Delete Saved Key",
        DeleteKeyIcon = "trash-2",

        CloseIcon = "x",
        ConfigIcon = "settings",
        EyeIcon = "eye",
        EyeOffIcon = "eye-off",

        ShowGetKey = true,
        ShowDiscord = true,
        ShowDeleteKey = true,
        ShowClose = true,
        ShowRevealKey = true,
    },

    Links = {
        Key = "",
        Discord = "",
    },

    Tween = {
        Time = 0.18,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out,
        OpenTime = 0.38,
        CloseTime = 0.18,
        HoverTime = 0.14,
        PressTime = 0.08,
        StatusTime = 0.22,
    },

    Effects = {
        Shadow = true,
        ShadowImage = "rbxassetid://1316045217",
        ShadowTransparency = 0.46,
        ShadowSize = 48,

        StrokeGlow = true,
        AnimatedGradient = true,
        GradientSpeed = 24,

        Particles = true,
        ParticleCount = 16,
        ParticleTransparency = 0.68,
        ParticleMinSize = 2,
        ParticleMaxSize = 5,
        ParticleSpeedMin = 3.2,
        ParticleSpeedMax = 7.8,

        MouseTilt = true,
        MouseTiltStrength = 1.25,

        ButtonShine = true,
        StatusPulse = true,
        OpenBounce = true,
    },

    Text = {
        Success = "Key verified successfully.",
        Invalid = "Invalid key.",
        Checking = "Checking key...",
        Loaded = "Loaded saved key.",
        Deleted = "Saved key deleted.",
        Copied = "Copied to clipboard.",
        CopyFail = "Clipboard is not supported.",
        NoKeyLink = "No key link configured.",
        NoDiscord = "No Discord configured.",
        EnterKey = "Enter a key first.",
        TooShort = "Key is too short.",
        TooLong = "Key is too long.",
        Ready = "Ready for verification.",
        Secure = "SECURE",
        Saved = "Saved",
        Unsaved = "Unsaved",
        ConfigTitle = "Runtime Config",
        ConfigHint = "Live options and current theme values.",
    },

    Theme = {
        BackgroundColor = Color3.fromRGB(10, 10, 15),
        TopbarColor = Color3.fromRGB(16, 16, 24),
        SidebarColor = Color3.fromRGB(18, 18, 28),
        ContentColor = Color3.fromRGB(18, 18, 27),
        CardColor = Color3.fromRGB(24, 24, 36),
        SecondColor = Color3.fromRGB(30, 30, 44),
        ThirdColor = Color3.fromRGB(38, 38, 56),

        AccentColor = Color3.fromRGB(125, 85, 255),
        AccentHoverColor = Color3.fromRGB(148, 112, 255),
        AccentSecondColor = Color3.fromRGB(92, 176, 255),

        ButtonHoverColor = nil,
        OutlineColor = Color3.fromRGB(60, 60, 82),
        SoftOutlineColor = Color3.fromRGB(38, 38, 55),

        FontColor = Color3.fromRGB(255, 255, 255),
        MutedFontColor = Color3.fromRGB(174, 174, 194),
        DarkFontColor = Color3.fromRGB(110, 110, 132),

        ErrorColor = Color3.fromRGB(255, 72, 96),
        SuccessColor = Color3.fromRGB(72, 255, 166),
        WarningColor = Color3.fromRGB(255, 195, 72),

        ButtonTextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamMedium,
        BoldFont = Enum.Font.GothamBold,
        MonoFont = Enum.Font.Code,
    },

    HoverTheme = {
        ButtonBackgroundColor = nil,
        ButtonTextColor = nil,
        ButtonIconColor = nil,
        OutlineColor = nil,
        CloseBackgroundColor = nil,
        CloseIconColor = nil,
        KeyStrokeColor = nil,
        CardStrokeColor = nil,
    },

    VerifyKey = function(key)
        return key == "test-key"
    end,

    OnSuccess = function(key, ui) end,
    OnInvalid = function(key, ui) end,
    OnClose = function(ui) end,
    OnOpen = function(ui) end,
    OnCopied = function(kind, value, ui) end,
    OnDeleteSavedKey = function(ui) end,
}

local function DeepMerge(base, given)
    local out = {}

    for k, v in pairs(base or {}) do
        if typeof(v) == "table" and typeof(given and given[k]) == "table" then
            out[k] = DeepMerge(v, given[k])
        else
            out[k] = v
        end
    end

    if typeof(given) == "table" then
        for k, v in pairs(given) do
            if typeof(v) == "table" and typeof(out[k]) == "table" then
                out[k] = DeepMerge(out[k], v)
            else
                out[k] = v
            end
        end
    end

    return out
end

local function ShallowClone(t)
    local out = {}
    for k, v in pairs(t or {}) do
        out[k] = v
    end
    return out
end

local function New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function ToAsset(value)
    if value == nil or value == "" then return nil end
    if typeof(value) == "number" then return "rbxassetid://" .. tostring(value) end
    if typeof(value) ~= "string" then return nil end
    if value:match("^rbxassetid://") or value:match("^rbxthumb://") or value:match("roblox%.com/asset") then
        return value
    end
    if tonumber(value) then
        return "rbxassetid://" .. value
    end
    return value
end

local function MakeFolderPath(path)
    if not (isfolder and makefolder and path) then return end
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
    if not (writefile and path and path ~= "") then return false end
    MakeFolderPath(path)
    local ok = pcall(writefile, path, tostring(text or ""))
    return ok
end

local function ReadFile(path)
    if not (readfile and isfile and path and path ~= "" and isfile(path)) then return nil end
    local ok, data = pcall(readfile, path)
    if ok then return data end
    return nil
end

local function DeleteFile(path)
    if not (path and path ~= "") then return false end
    if delfile and isfile and isfile(path) then
        return pcall(delfile, path)
    end
    if writefile and isfile and isfile(path) then
        return pcall(writefile, path, "")
    end
    return false
end

local function SafeTween(obj, info, props)
    if not obj then return end
    local ok, tween = pcall(TweenService.Create, TweenService, obj, info, props)
    if ok and tween then
        tween:Play()
        return tween
    end
end

local function ColorShift(color, add)
    return Color3.fromRGB(
        math.clamp(color.R * 255 + add, 0, 255),
        math.clamp(color.G * 255 + add, 0, 255),
        math.clamp(color.B * 255 + add, 0, 255)
    )
end

local function LerpColor(a, b, alpha)
    return Color3.new(
        a.R + (b.R - a.R) * alpha,
        a.G + (b.G - a.G) * alpha,
        a.B + (b.B - a.B) * alpha
    )
end

local function TextBounds(text, font, size)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = tostring(text or "")
    params.RichText = true
    params.Font = typeof(font) == "Font" and font or Font.fromEnum(font or Enum.Font.GothamMedium)
    params.Size = size or 16
    params.Width = 10000

    local ok, result = pcall(function()
        return TextService:GetTextBoundsAsync(params)
    end)

    if ok then return result end
    return Vector2.new(#tostring(text or "") * (size or 16) * 0.55, size or 16)
end

local function CleanRichText(text)
    return tostring(text or ""):gsub("<.->", "")
end

local function GetRootConfig(config)
    config = config or {}

    if config.Window or config.Key or config.Buttons or config.Background or config.Layout or config.Effects or config.Logo then
        return DeepMerge(KeySystem.DefaultConfig, config)
    end

    local converted = ShallowClone(config)

    converted.Window = {
        Size = config.Size,
        Position = config.Position,
        AnchorPoint = config.AnchorPoint,
        Center = config.Center,
        Draggable = config.Draggable,
        CornerRadius = config.CornerRadius,
        StrokeThickness = config.StrokeThickness,
        DisplayOrder = config.DisplayOrder,
        Parent = config.Parent,
        ShowConfigButton = config.ShowConfigButton,
    }

    converted.Background = {
        Image = config.BackgroundImage,
        ImageTransparency = config.BackgroundImageTransparency,
        ImageColor = config.BackgroundImageColor,
        ScaleType = config.BackgroundScaleType,
        Dim = config.BackgroundDim,
        ContentTransparency = config.BackgroundContentTransparency,
    }

    converted.Key = {
        File = config.KeyFile,
        Save = config.SaveKey,
        AutoLoad = config.AutoLoadSavedKey,
        AutoCheck = config.AutoCheckSavedKey,
        AutoDeleteInvalid = config.AutoDeleteInvalidKey,
        ClearInputWhenInvalid = config.ClearInputWhenInvalid,
        Placeholder = config.KeyPlaceholder,
        Height = config.KeyBoxHeight,
        ClearTextOnFocus = config.KeyBoxClearTextOnFocus,
        HideText = config.HideKeyText,
        SubmitOnEnter = config.SubmitOnEnter,
        Trim = config.TrimKey,
    }

    converted.Buttons = {
        Icons = config.ButtonIcons,
        IconSide = config.IconSide,
        IconSize = config.IconSize,
        IconGap = config.IconGap,
        IconColor = config.IconColor,
        LucideURL = config.LucideURL,
        MainText = config.MainButtonText,
        MainIcon = config.MainButtonIcon,
        GetKeyText = config.GetKeyButtonText,
        GetKeyIcon = config.GetKeyButtonIcon,
        DiscordText = config.CopyDiscordButtonText,
        DiscordIcon = config.CopyDiscordButtonIcon,
        DeleteKeyText = config.DeleteKeyButtonText,
        DeleteKeyIcon = config.DeleteKeyButtonIcon,
        CloseIcon = config.CloseButtonIcon,
        ShowGetKey = config.ShowGetKeyButton,
        ShowDiscord = config.ShowDiscordButton,
        ShowDeleteKey = config.ShowDeleteKeyButton,
        ShowClose = config.ShowCloseButton,
        Height = config.ButtonHeight,
        Gap = config.ButtonGap,
    }

    converted.Links = {
        Key = config.KeyLink,
        Discord = config.Discord,
    }

    converted.Tween = {
        Time = config.TweenTime,
        Style = config.TweenStyle,
        Direction = config.TweenDirection,
        OpenTime = config.OpenTime,
        CloseTime = config.CloseTime,
    }

    converted.Text = {
        Success = config.StatusSuccess,
        Invalid = config.StatusInvalid,
        Checking = config.StatusChecking,
        Loaded = config.StatusLoaded,
        Deleted = config.StatusDeleted,
        Copied = config.StatusCopied,
        CopyFail = config.StatusCopyFail,
        NoKeyLink = config.StatusNoKeyLink,
        NoDiscord = config.StatusNoDiscord,
    }

    return DeepMerge(KeySystem.DefaultConfig, converted)
end

function KeySystem:_Track(conn)
    if conn then
        table.insert(self.Connections, conn)
    end
    return conn
end

function KeySystem:_LoadLucide()
    if self.LucideLoaded then return end
    self.LucideLoaded = true

    local url = self.Config.Buttons.LucideURL
    if not url or url == "" then return end

    local ok, module = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if ok and typeof(module) == "table" and typeof(module.GetAsset) == "function" then
        self.LucideIcons = module
    end
end

function KeySystem:_GetIcon(icon)
    local asset = ToAsset(icon)
    if asset and (asset:match("^rbxassetid://") or asset:match("^rbxthumb://") or asset:match("roblox%.com/asset")) then
        return {
            Url = asset,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
        }
    end

    if typeof(icon) == "string" and icon ~= "" then
        self:_LoadLucide()
        if self.LucideIcons then
            local ok, data = pcall(self.LucideIcons.GetAsset, icon)
            if ok and data then return data end
        end
    end

    return nil
end

function KeySystem:_Tween(obj, props, time, style, direction)
    return SafeTween(
        obj,
        TweenInfo.new(
            time or self.Config.Tween.Time,
            style or self.Config.Tween.Style,
            direction or self.Config.Tween.Direction
        ),
        props
    )
end

function KeySystem:_MakeIcon(parent, name, iconName, size, color, zindex)
    local data = self:_GetIcon(iconName)
    if not data then return nil end

    return New("ImageLabel", {
        Name = name or "Icon",
        BackgroundTransparency = 1,
        Image = data.Url,
        ImageColor3 = color or self.Config.Theme.MutedFontColor,
        ImageRectOffset = data.ImageRectOffset or Vector2.zero,
        ImageRectSize = data.ImageRectSize or Vector2.zero,
        Size = UDim2.fromOffset(size or self.Config.Buttons.IconSize, size or self.Config.Buttons.IconSize),
        ZIndex = zindex or 10,
        Parent = parent,
    })
end

function KeySystem:_MakeStroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or self.Config.Theme.OutlineColor,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

function KeySystem:_MakeCorner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or self.Config.Window.CornerRadius),
        Parent = parent,
    })
end

function KeySystem:_MakeGradient(parent, colorA, colorB, rotation, transparency)
    return New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colorA or self.Config.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, colorB or self.Config.Theme.AccentSecondColor),
        }),
        Rotation = rotation or 0,
        Transparency = transparency or NumberSequence.new(0),
        Parent = parent,
    })
end

function KeySystem:_SetVisibleConfig(open)
    self.ConfigOpen = open and true or false
    if not self.ConfigDrawer then return end

    self.ConfigDrawer.Visible = true

    local width = self.ConfigDrawer.AbsoluteSize.X
    if width <= 0 then width = 220 end

    self:_Tween(self.ConfigDrawer, {
        Position = open and UDim2.new(1, -width - 12, 0, 72) or UDim2.new(1, 14, 0, 72),
        BackgroundTransparency = open and 0.02 or 1,
    }, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    if self.ConfigButton then
        self.ConfigButton:SetAttribute("Active", open)
        self:_RefreshButtonTheme(self.ConfigButton, open)
    end

    if not open then
        task.delay(0.24, function()
            if self.ConfigDrawer and not self.ConfigOpen then
                self.ConfigDrawer.Visible = false
            end
        end)
    end
end

function KeySystem:_SetStatus(text, color, flash, icon)
    if not self.StatusLabel then return end

    local theme = self.Config.Theme
    color = color or theme.MutedFontColor

    self.StatusLabel.Text = text or ""
    self.StatusLabel.TextColor3 = color

    if self.StatusIcon then
        self.StatusIcon.ImageColor3 = color
    end

    if icon and self.StatusIcon then
        local data = self:_GetIcon(icon)
        if data then
            self.StatusIcon.Image = data.Url
            self.StatusIcon.ImageRectOffset = data.ImageRectOffset or Vector2.zero
            self.StatusIcon.ImageRectSize = data.ImageRectSize or Vector2.zero
        end
    end

    if self.StatusCard then
        local bg = LerpColor(theme.CardColor, color, 0.08)
        self:_Tween(self.StatusCard, { BackgroundColor3 = bg }, self.Config.Tween.StatusTime)
    end

    if self.StatusStroke then
        self:_Tween(self.StatusStroke, { Color = LerpColor(theme.OutlineColor, color, 0.55) }, self.Config.Tween.StatusTime)
    end

    if flash then
        self.StatusLabel.TextTransparency = 1
        if self.StatusIcon then self.StatusIcon.ImageTransparency = 1 end
        self:_Tween(self.StatusLabel, { TextTransparency = 0 }, self.Config.Tween.StatusTime)
        if self.StatusIcon then
            self:_Tween(self.StatusIcon, { ImageTransparency = 0 }, self.Config.Tween.StatusTime)
        end
    end
end

function KeySystem:_UpdateKeyMeta()
    if not self.KeyMeta then return end
    local key = self.KeyBox and self.KeyBox.Text or ""
    local length = #key
    local saved = self.Config.Key.Save and ReadFile(self.Config.Key.File)
    local savedText = saved and saved ~= "" and self.Config.Text.Saved or self.Config.Text.Unsaved

    if self.Config.Key.ShowKeyLength then
        self.KeyMeta.Text = tostring(length) .. "/" .. tostring(self.Config.Key.MaxLength) .. " • " .. savedText
    else
        self.KeyMeta.Text = savedText
    end
end

function KeySystem:_PulseStroke(color)
    if not self.MainStroke then return end

    self:_Tween(self.MainStroke, {
        Color = color,
        Transparency = 0,
        Thickness = math.max(1, self.Config.Window.StrokeThickness + 0.5),
    }, 0.12)

    task.delay(0.32, function()
        if self.MainStroke then
            self:_Tween(self.MainStroke, {
                Color = self.Config.Theme.OutlineColor,
                Thickness = self.Config.Window.StrokeThickness,
            }, 0.24)
        end
    end)
end

function KeySystem:_RefreshButtonTheme(button, hovering)
    if not button then return end

    local cfg = self.Config
    local theme = cfg.Theme
    local hover = cfg.HoverTheme or {}

    local isAccent = button:GetAttribute("IsAccent") == true
    local active = button:GetAttribute("Active") == true

    local normalBg = isAccent and theme.AccentColor or theme.SecondColor
    local hoverBg = hover.ButtonBackgroundColor or theme.ButtonHoverColor or (isAccent and theme.AccentHoverColor or ColorShift(theme.SecondColor, 10))
    local activeBg = isAccent and theme.AccentHoverColor or ColorShift(theme.SecondColor, 16)

    local targetBg = (hovering or active) and (active and activeBg or hoverBg) or normalBg
    local textColor = (hovering or active) and (hover.ButtonTextColor or theme.ButtonTextColor) or theme.ButtonTextColor
    local iconColor = (hovering or active) and (hover.ButtonIconColor or cfg.Buttons.IconColor or theme.ButtonTextColor) or (cfg.Buttons.IconColor or theme.ButtonTextColor)
    local outline = (hovering or active) and (hover.OutlineColor or theme.AccentColor) or theme.OutlineColor

    self:_Tween(button, { BackgroundColor3 = targetBg }, cfg.Tween.HoverTime)

    local label = button:FindFirstChild("Label", true)
    if label then
        self:_Tween(label, {
            TextColor3 = textColor,
            TextTransparency = hovering and 0 or 0.03,
        }, cfg.Tween.HoverTime)
    end

    local icon = button:FindFirstChild("Icon", true)
    if icon then
        self:_Tween(icon, {
            ImageColor3 = iconColor,
            ImageTransparency = 0,
        }, cfg.Tween.HoverTime)
    end

    local stroke = button:FindFirstChildOfClass("UIStroke")
    if stroke then
        self:_Tween(stroke, { Color = outline }, cfg.Tween.HoverTime)
    end
end

function KeySystem:_ApplyTheme(theme)
    self.Config.Theme = DeepMerge(self.Config.Theme, theme or {})
    local t = self.Config.Theme

    if self.MainFrame then self.MainFrame.BackgroundColor3 = t.BackgroundColor end
    if self.Topbar then self.Topbar.BackgroundColor3 = t.TopbarColor end
    if self.TopbarCover then self.TopbarCover.BackgroundColor3 = t.TopbarColor end
    if self.Sidebar then self.Sidebar.BackgroundColor3 = t.SidebarColor end
    if self.Content then self.Content.BackgroundColor3 = t.ContentColor end
    if self.KeyShell then self.KeyShell.BackgroundColor3 = t.SecondColor end
    if self.StatusCard then self.StatusCard.BackgroundColor3 = t.CardColor end
    if self.BackgroundDim then self.BackgroundDim.BackgroundColor3 = t.BackgroundColor end
    if self.ConfigDrawer then self.ConfigDrawer.BackgroundColor3 = t.CardColor end

    if self.TitleLabel then self.TitleLabel.TextColor3 = t.FontColor end
    if self.SubtitleLabel then self.SubtitleLabel.TextColor3 = t.MutedFontColor end
    if self.DescriptionLabel then self.DescriptionLabel.TextColor3 = t.MutedFontColor end
    if self.FooterLabel then self.FooterLabel.TextColor3 = t.DarkFontColor end
    if self.StatusLabel then self.StatusLabel.TextColor3 = t.MutedFontColor end
    if self.KeyMeta then self.KeyMeta.TextColor3 = t.DarkFontColor end

    if self.KeyBox then
        self.KeyBox.TextColor3 = t.FontColor
        self.KeyBox.PlaceholderColor3 = t.MutedFontColor
        self.KeyBox.Font = t.Font
    end

    if self.MainStroke then self.MainStroke.Color = t.OutlineColor end
    if self.SidebarStroke then self.SidebarStroke.Color = t.SoftOutlineColor end
    if self.ContentStroke then self.ContentStroke.Color = t.OutlineColor end
    if self.KeyStroke then self.KeyStroke.Color = t.OutlineColor end
    if self.StatusStroke then self.StatusStroke.Color = t.SoftOutlineColor end

    for _, label in ipairs(self.ThemeLabels or {}) do
        if label:GetAttribute("Muted") then
            label.TextColor3 = t.MutedFontColor
        elseif label:GetAttribute("Dark") then
            label.TextColor3 = t.DarkFontColor
        else
            label.TextColor3 = t.FontColor
        end
    end

    for _, button in ipairs(self.ButtonList or {}) do
        self:_RefreshButtonTheme(button, false)
    end
end

function KeySystem:SetTheme(theme)
    self:_ApplyTheme(theme)
    return self
end

function KeySystem:SetHoverTheme(theme)
    self.Config.HoverTheme = DeepMerge(self.Config.HoverTheme, theme or {})
    return self
end

function KeySystem:SetStatus(text, color)
    self:_SetStatus(text, color or self.Config.Theme.MutedFontColor, true, "info")
    return self
end

function KeySystem:SetKey(key)
    if self.KeyBox then
        self.KeyBox.Text = tostring(key or "")
        self:_UpdateKeyMeta()
    end
    return self
end

function KeySystem:GetKey()
    return self.KeyBox and self.KeyBox.Text or ""
end

function KeySystem:SaveKey(key)
    key = tostring(key or (self.KeyBox and self.KeyBox.Text) or "")
    local ok = SaveFile(self.Config.Key.File, key)
    self:_UpdateKeyMeta()
    return ok
end

function KeySystem:DeleteSavedKey()
    DeleteFile(self.Config.Key.File)
    self:_UpdateKeyMeta()
    self:_SetStatus(self.Config.Text.Deleted, self.Config.Theme.WarningColor, true, "trash-2")
    task.spawn(self.Config.OnDeleteSavedKey, self)
    return self
end

function KeySystem:ShowConfig(open)
    self:_SetVisibleConfig(open == nil and true or open)
    return self
end

function KeySystem:HideConfig()
    self:_SetVisibleConfig(false)
    return self
end

function KeySystem:_CreateButton(info)
    local cfg = self.Config
    local theme = cfg.Theme

    local button = New("TextButton", {
        Name = info.Name or "Button",
        AutoButtonColor = false,
        BackgroundColor3 = info.Accent and theme.AccentColor or theme.SecondColor,
        BorderSizePixel = 0,
        LayoutOrder = info.LayoutOrder or 1,
        Size = UDim2.new(1, 0, 0, info.Height or cfg.Buttons.Height),
        Text = "",
        ZIndex = info.ZIndex or 18,
        Parent = info.Parent or self.ButtonHolder,
    })

    button:SetAttribute("IsAccent", info.Accent and true or false)

    self:_MakeCorner(button, info.CornerRadius or math.max(7, cfg.Window.CornerRadius - 5))
    self:_MakeStroke(button, theme.OutlineColor, 1, 0)

    if cfg.Effects.ButtonShine and info.Accent then
        self:_MakeGradient(
            button,
            theme.AccentColor,
            theme.AccentSecondColor,
            0,
            NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.02),
                NumberSequenceKeypoint.new(1, 0.1),
            })
        )
    end

    local center = New("Frame", {
        Name = "Center",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, info.Height or cfg.Buttons.Height),
        ZIndex = (info.ZIndex or 18) + 1,
        Parent = button,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, cfg.Buttons.IconGap),
        Parent = center,
    })

    local iconData = cfg.Buttons.Icons and self:_GetIcon(info.Icon)
    local icon

    local label = New("TextLabel", {
        Name = "Label",
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Font = theme.BoldFont or theme.Font,
        RichText = true,
        Text = info.Text or "Button",
        TextColor3 = theme.ButtonTextColor,
        TextSize = info.TextSize or 14,
        TextTransparency = 0.03,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.fromOffset(0, info.Height or cfg.Buttons.Height),
        ZIndex = (info.ZIndex or 18) + 2,
        Parent = center,
    })

    if iconData then
        icon = New("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = iconData.Url,
            ImageColor3 = cfg.Buttons.IconColor or theme.ButtonTextColor,
            ImageRectOffset = iconData.ImageRectOffset or Vector2.zero,
            ImageRectSize = iconData.ImageRectSize or Vector2.zero,
            Size = UDim2.fromOffset(info.IconSize or cfg.Buttons.IconSize, info.IconSize or cfg.Buttons.IconSize),
            ZIndex = (info.ZIndex or 18) + 2,
            Parent = center,
        })

        if cfg.Buttons.IconSide == "Left" then
            icon.LayoutOrder = 1
            label.LayoutOrder = 2
        else
            label.LayoutOrder = 1
            icon.LayoutOrder = 2
        end
    end

    local function resize()
        local bounds = TextBounds(CleanRichText(label.Text), theme.BoldFont or theme.Font, label.TextSize)
        local width = math.ceil(bounds.X + 8)
        if icon then width += (info.IconSize or cfg.Buttons.IconSize) + cfg.Buttons.IconGap end
        center.Size = UDim2.fromOffset(width, info.Height or cfg.Buttons.Height)
    end

    resize()
    self:_Track(label:GetPropertyChangedSignal("Text"):Connect(resize))

    self:_Track(button.MouseEnter:Connect(function()
        self:_RefreshButtonTheme(button, true)
    end))

    self:_Track(button.MouseLeave:Connect(function()
        self:_RefreshButtonTheme(button, false)
    end))

    self:_Track(button.MouseButton1Down:Connect(function()
        self:_Tween(button, {
            Size = UDim2.new(1, -4, 0, info.Height or cfg.Buttons.Height),
        }, cfg.Tween.PressTime)
    end))

    self:_Track(button.MouseButton1Up:Connect(function()
        self:_Tween(button, {
            Size = UDim2.new(1, 0, 0, info.Height or cfg.Buttons.Height),
        }, cfg.Tween.PressTime)
    end))

    self:_Track(button.MouseButton1Click:Connect(function()
        if typeof(info.Callback) == "function" then
            info.Callback(button)
        end
    end))

    table.insert(self.ButtonList, button)
    return button
end

function KeySystem:_ValidateKeyShape(key)
    if key == "" then
        return false, self.Config.Text.EnterKey, self.Config.Theme.WarningColor, "triangle-alert"
    end

    if self.Config.Key.MinLength and #key < self.Config.Key.MinLength then
        return false, self.Config.Text.TooShort, self.Config.Theme.WarningColor, "triangle-alert"
    end

    if self.Config.Key.MaxLength and #key > self.Config.Key.MaxLength then
        return false, self.Config.Text.TooLong, self.Config.Theme.WarningColor, "triangle-alert"
    end

    return true
end

function KeySystem:_Verify(key, fromSaved)
    key = tostring(key or (self.KeyBox and self.KeyBox.Text) or "")

    if self.Config.Key.Trim then
        key = key:match("^%s*(.-)%s*$")
    end

    local shapeOk, shapeMsg, shapeColor, shapeIcon = self:_ValidateKeyShape(key)
    if not shapeOk then
        self:_SetStatus(shapeMsg, shapeColor, true, shapeIcon)
        self:_PulseStroke(shapeColor)
        return false
    end

    self:_SetStatus(self.Config.Text.Checking, self.Config.Theme.WarningColor, true, "loader-circle")

    if self.ProgressFill then
        self.ProgressFill.Size = UDim2.fromScale(0, 1)
        self:_Tween(self.ProgressFill, { Size = UDim2.fromScale(0.72, 1) }, 0.18)
    end

    local ok, valid, message = pcall(self.Config.VerifyKey, key, self)
    valid = ok and valid == true

    if self.ProgressFill then
        self:_Tween(self.ProgressFill, { Size = UDim2.fromScale(1, 1) }, 0.12)
        task.delay(0.22, function()
            if self.ProgressFill then
                self:_Tween(self.ProgressFill, { Size = UDim2.fromScale(0, 1) }, 0.18)
            end
        end)
    end

    if valid then
        self.ValidatedKey = key

        if self.Config.Key.Save then
            SaveFile(self.Config.Key.File, key)
        end

        self:_UpdateKeyMeta()
        self:_SetStatus(message or self.Config.Text.Success, self.Config.Theme.SuccessColor, true, "badge-check")
        self:_PulseStroke(self.Config.Theme.SuccessColor)
        task.spawn(self.Config.OnSuccess, key, self)
        return true
    end

    if self.Config.Key.AutoDeleteInvalid then
        DeleteFile(self.Config.Key.File)
    end

    if self.Config.Key.ClearInputWhenInvalid and not fromSaved then
        self.KeyBox.Text = ""
    end

    self:_UpdateKeyMeta()
    self:_SetStatus(message or self.Config.Text.Invalid, self.Config.Theme.ErrorColor, true, "circle-x")
    self:_PulseStroke(self.Config.Theme.ErrorColor)
    task.spawn(self.Config.OnInvalid, key, self)
    return false
end

function KeySystem:Verify(key)
    return self:_Verify(key or self:GetKey(), false)
end

function KeySystem:Close()
    if self.Closed then return end
    self.Closed = true

    task.spawn(self.Config.OnClose, self)

    for _, conn in ipairs(self.Connections or {}) do
        pcall(function()
            conn:Disconnect()
        end)
    end

    if self.MainFrame then
        local targetSize = self.Config.Window.Size
        self:_Tween(self.MainFrame, {
            Size = UDim2.fromOffset(math.max(1, targetSize.X.Offset * 0.94), math.max(1, targetSize.Y.Offset * 0.94)),
            BackgroundTransparency = 1,
            Rotation = 0,
        }, self.Config.Tween.CloseTime, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    end

    if self.Shadow then
        self:_Tween(self.Shadow, { ImageTransparency = 1 }, self.Config.Tween.CloseTime)
    end

    task.delay(self.Config.Tween.CloseTime + 0.04, function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end)
end

function KeySystem:Show()
    if not self.MainFrame then return self end

    self.MainFrame.Visible = true

    local target = self.Config.Window.Size
    local startSize = UDim2.fromOffset(target.X.Offset * 0.92, target.Y.Offset * 0.92)

    self.MainFrame.Size = startSize
    self.MainFrame.BackgroundTransparency = 1

    if self.Shadow then
        self.Shadow.ImageTransparency = 1
        self:_Tween(self.Shadow, { ImageTransparency = self.Config.Effects.ShadowTransparency }, 0.28)
    end

    local style = self.Config.Effects.OpenBounce and Enum.EasingStyle.Back or Enum.EasingStyle.Quart
    self:_Tween(self.MainFrame, {
        Size = target,
        BackgroundTransparency = 0,
    }, self.Config.Tween.OpenTime, style, Enum.EasingDirection.Out)

    self:_SetStatus(self.Config.Text.Ready, self.Config.Theme.MutedFontColor, true, "shield-check")
    task.spawn(self.Config.OnOpen, self)

    return self
end

function KeySystem:Hide()
    if self.MainFrame then
        self.MainFrame.Visible = false
    end
    return self
end

function KeySystem:Destroy()
    self.Closed = true

    for _, conn in ipairs(self.Connections or {}) do
        pcall(function()
            conn:Disconnect()
        end)
    end

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function KeySystem:_SetupResponsiveScale()
    if not self.Config.Window.AutoScale or not self.Scale then return end

    local function update()
        local camera = Workspace.CurrentCamera
        if not camera then return end

        local view = camera.ViewportSize
        local size = self.Config.Window.Size
        local pad = self.Config.Window.ScalePadding or 64
        local sx = (view.X - pad) / math.max(1, size.X.Offset)
        local sy = (view.Y - pad) / math.max(1, size.Y.Offset)
        local scale = math.clamp(math.min(sx, sy, self.Config.Window.UIScale), self.Config.Window.MinScale, self.Config.Window.MaxScale)
        self.Scale.Scale = scale
    end

    update()

    local camera = Workspace.CurrentCamera
    if camera then
        self:_Track(camera:GetPropertyChangedSignal("ViewportSize"):Connect(update))
    end
end

function KeySystem:_SetupDragging()
    if not self.Config.Window.Draggable then return end
    if not self.Topbar or not self.MainFrame then return end

    local dragging = false
    local startPos
    local framePos
    local releaseConn

    self:_Track(self.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        startPos = input.Position
        framePos = self.MainFrame.Position

        if releaseConn then releaseConn:Disconnect() end
        releaseConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if releaseConn then
                    releaseConn:Disconnect()
                    releaseConn = nil
                end
            end
        end)
    end))

    self:_Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - startPos
        self.MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end))
end

function KeySystem:_SetupEffects()
    local cfg = self.Config
    local theme = cfg.Theme

    if cfg.Effects.AnimatedGradient or cfg.Effects.MouseTilt or cfg.Effects.Particles then
        local particles = self.Particles or {}

        self:_Track(RunService.RenderStepped:Connect(function(dt)
            if self.Closed or not self.MainFrame then return end

            self.EffectClock += dt

            if cfg.Effects.AnimatedGradient then
                local rot = (self.EffectClock * cfg.Effects.GradientSpeed) % 360

                if self.MainGradient then
                    self.MainGradient.Rotation = rot
                end
                if self.LogoGradient then
                    self.LogoGradient.Rotation = -rot
                end
                if self.AccentGradient then
                    self.AccentGradient.Rotation = rot + 35
                end
            end

            if cfg.Effects.MouseTilt then
                local mouse = UserInputService:GetMouseLocation()
                local camera = Workspace.CurrentCamera
                if camera then
                    local center = camera.ViewportSize / 2
                    local dx = math.clamp((mouse.X - center.X) / center.X, -1, 1)
                    local target = dx * cfg.Effects.MouseTiltStrength
                    self.MainFrame.Rotation = self.MainFrame.Rotation + (target - self.MainFrame.Rotation) * math.clamp(dt * 8, 0, 1)
                end
            end

            if cfg.Effects.Particles and #particles > 0 then
                for _, p in ipairs(particles) do
                    local y = p.Position.Y.Scale
                    y -= (p:GetAttribute("Speed") or 4) * dt / 100
                    if y < -0.05 then
                        y = 1.05
                        p.Position = UDim2.fromScale(math.random(4, 96) / 100, y)
                    else
                        p.Position = UDim2.fromScale(p.Position.X.Scale, y)
                    end

                    local pulse = (math.sin(self.EffectClock * 2 + (p:GetAttribute("Seed") or 0)) + 1) / 2
                    p.BackgroundTransparency = math.clamp(cfg.Effects.ParticleTransparency + pulse * 0.16, 0, 1)
                end
            end
        end))
    end

    if cfg.Effects.StrokeGlow and self.MainStroke then
        self.MainStroke.Color = theme.OutlineColor
    end
end

function KeySystem:_CreateParticles(parent)
    if not self.Config.Effects.Particles then return end

    local cfg = self.Config
    local theme = cfg.Theme

    self.Particles = {}

    for i = 1, cfg.Effects.ParticleCount do
        local size = math.random(cfg.Effects.ParticleMinSize, cfg.Effects.ParticleMaxSize)
        local dot = New("Frame", {
            Name = "Particle",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = LerpColor(theme.AccentColor, theme.AccentSecondColor, math.random()),
            BackgroundTransparency = cfg.Effects.ParticleTransparency,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(math.random(4, 96) / 100, math.random(4, 96) / 100),
            Size = UDim2.fromOffset(size, size),
            ZIndex = 3,
            Parent = parent,
        })

        dot:SetAttribute("Speed", math.random(math.floor(cfg.Effects.ParticleSpeedMin * 10), math.floor(cfg.Effects.ParticleSpeedMax * 10)) / 10)
        dot:SetAttribute("Seed", math.random() * 10)
        self:_MakeCorner(dot, size)

        table.insert(self.Particles, dot)
    end
end

function KeySystem:_CreateConfigDrawer()
    if not self.Config.Window.ShowConfigButton then return end

    local cfg = self.Config
    local theme = cfg.Theme

    local drawer = New("Frame", {
        Name = "ConfigDrawer",
        BackgroundColor3 = theme.CardColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 14, 0, 72),
        Size = UDim2.fromOffset(232, cfg.Window.Size.Y.Offset - 88),
        Visible = false,
        ZIndex = 35,
        Parent = self.MainFrame,
    })
    self.ConfigDrawer = drawer

    self:_MakeCorner(drawer, 12)
    self.ConfigDrawerStroke = self:_MakeStroke(drawer, theme.OutlineColor, 1, 0.05)

    New("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = drawer,
    })

    local list = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = drawer,
    })

    local title = New("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = theme.BoldFont,
        Text = cfg.Text.ConfigTitle,
        TextColor3 = theme.FontColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 20),
        ZIndex = 36,
        Parent = drawer,
    })
    table.insert(self.ThemeLabels, title)

    local hint = New("TextLabel", {
        Name = "Hint",
        BackgroundTransparency = 1,
        Font = theme.Font,
        Text = cfg.Text.ConfigHint,
        TextColor3 = theme.MutedFontColor,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, 0, 0, 32),
        ZIndex = 36,
        Parent = drawer,
    })
    hint:SetAttribute("Muted", true)
    table.insert(self.ThemeLabels, hint)

    local function row(name, value)
        local holder = New("Frame", {
            Name = name,
            BackgroundColor3 = theme.SecondColor,
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 34),
            ZIndex = 36,
            Parent = drawer,
        })
        self:_MakeCorner(holder, 8)
        self:_MakeStroke(holder, theme.SoftOutlineColor, 1, 0.2)

        local left = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = theme.Font,
            Text = name,
            TextColor3 = theme.MutedFontColor,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            ZIndex = 37,
            Parent = holder,
        })
        left:SetAttribute("Muted", true)
        table.insert(self.ThemeLabels, left)

        local right = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = theme.MonoFont,
            Text = tostring(value),
            TextColor3 = theme.FontColor,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            ZIndex = 37,
            Parent = holder,
        })
        table.insert(self.ThemeLabels, right)

        return right
    end

    row("Version", KeySystem.Version)
    row("SaveKey", tostring(cfg.Key.Save))
    row("AutoLoad", tostring(cfg.Key.AutoLoad))
    row("AutoCheck", tostring(cfg.Key.AutoCheck))
    row("DeleteInvalid", tostring(cfg.Key.AutoDeleteInvalid))
    row("Icons", tostring(cfg.Buttons.Icons))
    row("Particles", tostring(cfg.Effects.Particles))
    row("Gradient", tostring(cfg.Effects.AnimatedGradient))
    row("Draggable", tostring(cfg.Window.Draggable))

    task.defer(function()
        drawer.Size = UDim2.fromOffset(232, math.min(cfg.Window.Size.Y.Offset - 88, list.AbsoluteContentSize.Y + 24))
    end)
end

function KeySystem:_Build()
    local cfg = self.Config
    local theme = cfg.Theme

    local gui = New("ScreenGui", {
        Name = "KeySystemUIPro_" .. HttpService:GenerateGUID(false),
        DisplayOrder = cfg.Window.DisplayOrder,
        IgnoreGuiInset = cfg.Window.IgnoreGuiInset,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    pcall(protectgui, gui)

    local parent = cfg.Window.Parent or gethui()
    local ok = pcall(function()
        gui.Parent = parent
    end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.ScreenGui = gui

    local frame = New("Frame", {
        Name = "Window",
        AnchorPoint = cfg.Window.AnchorPoint,
        BackgroundColor3 = theme.BackgroundColor,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = cfg.Window.ClipsDescendants,
        Position = cfg.Window.Center and UDim2.fromScale(0.5, 0.5) or cfg.Window.Position,
        Size = cfg.Window.Size,
        Visible = false,
        ZIndex = 5,
        Parent = gui,
    })
    self.MainFrame = frame

    if cfg.Window.AutoScale then
        self.Scale = New("UIScale", {
            Scale = cfg.Window.UIScale,
            Parent = frame,
        })
    end

    if cfg.Effects.Shadow then
        local shadow = New("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = cfg.Effects.ShadowImage,
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = cfg.Effects.ShadowTransparency,
            Position = UDim2.fromScale(0.5, 0.5),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(10, 10, 118, 118),
            Size = UDim2.new(1, cfg.Effects.ShadowSize, 1, cfg.Effects.ShadowSize),
            ZIndex = 1,
            Parent = frame,
        })
        self.Shadow = shadow
    end

    self:_MakeCorner(frame, cfg.Window.CornerRadius)
    self.MainStroke = self:_MakeStroke(frame, theme.OutlineColor, cfg.Window.StrokeThickness, 0)

    self.MainGradient = self:_MakeGradient(
        frame,
        theme.BackgroundColor,
        ColorShift(theme.BackgroundColor, 12),
        0,
        NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(0.5, 0.28),
            NumberSequenceKeypoint.new(1, 0.05),
        })
    )

    if cfg.Background.Image and cfg.Background.Image ~= "" then
        self.BackgroundImage = New("ImageLabel", {
            Name = "BackgroundImage",
            BackgroundTransparency = 1,
            Image = ToAsset(cfg.Background.Image),
            ImageTransparency = cfg.Background.ImageTransparency,
            ImageColor3 = cfg.Background.ImageColor,
            ScaleType = cfg.Background.ScaleType,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 2,
            Parent = frame,
        })

        self.BackgroundDim = New("Frame", {
            Name = "BackgroundDim",
            BackgroundColor3 = theme.BackgroundColor,
            BackgroundTransparency = math.clamp(1 - cfg.Background.Dim, 0, 1),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 3,
            Parent = frame,
        })
    end

    local pattern = New("Frame", {
        Name = "Pattern",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = frame,
    })
    self.Pattern = pattern
    self:_CreateParticles(pattern)

    self.Topbar = New("Frame", {
        Name = "Topbar",
        BackgroundColor3 = theme.TopbarColor,
        BackgroundTransparency = cfg.Background.TopbarTransparency,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, cfg.Layout.TopbarHeight),
        ZIndex = 10,
        Parent = frame,
    })

    self:_MakeCorner(self.Topbar, cfg.Window.CornerRadius)

    self.TopbarCover = New("Frame", {
        Name = "TopbarBottomCover",
        BackgroundColor3 = theme.TopbarColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -cfg.Window.CornerRadius),
        Size = UDim2.new(1, 0, 0, cfg.Window.CornerRadius),
        ZIndex = 11,
        Parent = self.Topbar,
    })

    local accentBar = New("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = theme.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 25,
        Parent = frame,
    })
    self.AccentGradient = self:_MakeGradient(accentBar, theme.AccentColor, theme.AccentSecondColor, 0)

    local logoX = cfg.Layout.Padding
    if cfg.Logo.Enabled then
        local logo = New("Frame", {
            Name = "Logo",
            BackgroundColor3 = theme.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(cfg.Layout.Padding, math.floor((cfg.Layout.TopbarHeight - cfg.Logo.Size) / 2)),
            Size = UDim2.fromOffset(cfg.Logo.Size, cfg.Logo.Size),
            ZIndex = 15,
            Parent = self.Topbar,
        })
        self.LogoFrame = logo

        self:_MakeCorner(logo, cfg.Logo.CornerRadius)

        if cfg.Logo.Gradient then
            self.LogoGradient = self:_MakeGradient(logo, theme.AccentColor, theme.AccentSecondColor, 45)
        end

        if cfg.Logo.Stroke then
            self:_MakeStroke(logo, ColorShift(theme.AccentColor, 34), 1, 0.15)
        end

        if cfg.Logo.Image and cfg.Logo.Image ~= "" then
            New("ImageLabel", {
                Name = "LogoImage",
                BackgroundTransparency = 1,
                Image = ToAsset(cfg.Logo.Image),
                ImageColor3 = theme.ButtonTextColor,
                Position = UDim2.fromOffset(10, 10),
                Size = UDim2.new(1, -20, 1, -20),
                ZIndex = 17,
                Parent = logo,
            })
        else
            New("TextLabel", {
                Name = "LogoText",
                BackgroundTransparency = 1,
                Font = theme.BoldFont,
                Text = cfg.Logo.Text,
                TextColor3 = theme.ButtonTextColor,
                TextSize = 22,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 17,
                Parent = logo,
            })
        end

        logoX += cfg.Logo.Size + 12
    end

    self.TitleLabel = New("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = theme.BoldFont,
        RichText = true,
        Text = cfg.Title,
        TextColor3 = theme.FontColor,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        Position = UDim2.fromOffset(logoX, 8),
        Size = UDim2.new(1, cfg.Buttons.ShowClose and -210 or -154, 0, 26),
        ZIndex = 15,
        Parent = self.Topbar,
    })

    self.SubtitleLabel = New("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Font = theme.MonoFont,
        RichText = true,
        Text = string.upper(cfg.Subtitle or ""),
        TextColor3 = theme.MutedFontColor,
        TextSize = 11,
        TextTransparency = 0.1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(logoX, 35),
        Size = UDim2.new(1, cfg.Buttons.ShowClose and -210 or -154, 0, 18),
        ZIndex = 15,
        Parent = self.Topbar,
    })

    local badge = New("Frame", {
        Name = "SecureBadge",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = theme.SecondColor,
        BorderSizePixel = 0,
        Position = UDim2.new(1, cfg.Buttons.ShowClose and -58 or -16, 0.5, 0),
        Size = UDim2.fromOffset(86, cfg.Layout.BadgeHeight),
        ZIndex = 15,
        Parent = self.Topbar,
    })
    self:_MakeCorner(badge, 8)
    self:_MakeStroke(badge, theme.SoftOutlineColor, 1, 0.2)

    local badgeIcon = self:_MakeIcon(badge, "Icon", "shield-check", 14, theme.SuccessColor, 16)
    if badgeIcon then
        badgeIcon.AnchorPoint = Vector2.new(0, 0.5)
        badgeIcon.Position = UDim2.new(0, 9, 0.5, 0)
    end

    local badgeText = New("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Font = theme.MonoFont,
        Text = cfg.Text.Secure,
        TextColor3 = theme.SuccessColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Position = UDim2.fromOffset(27, 0),
        Size = UDim2.new(1, -36, 1, 0),
        ZIndex = 16,
        Parent = badge,
    })
    badgeText:SetAttribute("Muted", true)
    table.insert(self.ThemeLabels, badgeText)

    if cfg.Buttons.ShowClose then
        local close = New("TextButton", {
            Name = "Close",
            AutoButtonColor = false,
            BackgroundColor3 = theme.SecondColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -46, 0, 12),
            Size = UDim2.fromOffset(36, 36),
            Text = "",
            ZIndex = 18,
            Parent = self.Topbar,
        })
        self:_MakeCorner(close, 10)

        local closeIcon = self:_MakeIcon(close, "Icon", cfg.Buttons.CloseIcon, 18, theme.MutedFontColor, 19)
        if closeIcon then
            closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            closeIcon.Position = UDim2.fromScale(0.5, 0.5)
        else
            close.Text = "X"
            close.Font = theme.BoldFont
            close.TextColor3 = theme.MutedFontColor
            close.TextSize = 14
        end

        self:_Track(close.MouseEnter:Connect(function()
            self:_Tween(close, {
                BackgroundTransparency = 0,
                BackgroundColor3 = cfg.HoverTheme.CloseBackgroundColor or theme.SecondColor,
            }, cfg.Tween.HoverTime)
            if closeIcon then
                self:_Tween(closeIcon, {
                    ImageColor3 = cfg.HoverTheme.CloseIconColor or theme.FontColor,
                }, cfg.Tween.HoverTime)
            end
        end))

        self:_Track(close.MouseLeave:Connect(function()
            self:_Tween(close, { BackgroundTransparency = 1 }, cfg.Tween.HoverTime)
            if closeIcon then
                self:_Tween(closeIcon, { ImageColor3 = theme.MutedFontColor }, cfg.Tween.HoverTime)
            end
        end))

        self:_Track(close.MouseButton1Click:Connect(function()
            self:Close()
        end))
    end

    self.Sidebar = New("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.SidebarColor,
        BackgroundTransparency = cfg.Background.SidebarTransparency,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(cfg.Layout.Padding, cfg.Layout.TopbarHeight + cfg.Layout.Padding),
        Size = UDim2.new(0, cfg.Layout.SidebarWidth, 1, -(cfg.Layout.TopbarHeight + cfg.Layout.Padding * 2)),
        ZIndex = 10,
        Parent = frame,
    })
    self:_MakeCorner(self.Sidebar, math.max(8, cfg.Window.CornerRadius - 4))
    self.SidebarStroke = self:_MakeStroke(self.Sidebar, theme.SoftOutlineColor, 1, 0.12)

    New("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = self.Sidebar,
    })

    local sidebarList = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = self.Sidebar,
    })

    local product = New("TextLabel", {
        Name = "Product",
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Font = theme.BoldFont,
        Text = cfg.Product,
        TextColor3 = theme.FontColor,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 11,
        Parent = self.Sidebar,
    })
    table.insert(self.ThemeLabels, product)

    local version = New("TextLabel", {
        Name = "Version",
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Font = theme.MonoFont,
        Text = cfg.VersionText,
        TextColor3 = theme.DarkFontColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 11,
        Parent = self.Sidebar,
    })
    version:SetAttribute("Dark", true)
    table.insert(self.ThemeLabels, version)

    local sideLine = New("Frame", {
        Name = "Line",
        LayoutOrder = 3,
        BackgroundColor3 = theme.SoftOutlineColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 11,
        Parent = self.Sidebar,
    })

    local function miniItem(order, icon, text, value)
        local item = New("Frame", {
            Name = text,
            LayoutOrder = order,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            ZIndex = 11,
            Parent = self.Sidebar,
        })

        local ic = self:_MakeIcon(item, "Icon", icon, 16, theme.AccentColor, 12)
        if ic then
            ic.AnchorPoint = Vector2.new(0, 0.5)
            ic.Position = UDim2.new(0, 0, 0.5, 0)
        end

        local label = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = theme.Font,
            Text = text,
            TextColor3 = theme.MutedFontColor,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(24, 0),
            Size = UDim2.new(1, -24, 0, 16),
            ZIndex = 12,
            Parent = item,
        })
        label:SetAttribute("Muted", true)
        table.insert(self.ThemeLabels, label)

        local val = New("TextLabel", {
            BackgroundTransparency = 1,
            Font = theme.MonoFont,
            Text = value,
            TextColor3 = theme.FontColor,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.fromOffset(24, 16),
            Size = UDim2.new(1, -24, 0, 16),
            ZIndex = 12,
            Parent = item,
        })
        table.insert(self.ThemeLabels, val)

        return val
    end

    miniItem(4, "database", "Storage", cfg.Key.Save and "Enabled" or "Disabled")
    miniItem(5, "wand-sparkles", "Effects", cfg.Effects.Particles and "Animated" or "Clean")
    miniItem(6, "mouse-pointer-click", "Drag", cfg.Window.Draggable and "Unlocked" or "Locked")

    if cfg.Window.ShowConfigButton then
        self.ConfigButton = self:_CreateButton({
            Name = "ConfigToggle",
            Text = cfg.Window.ConfigButtonText,
            Icon = cfg.Buttons.ConfigIcon,
            Height = 34,
            TextSize = 12,
            LayoutOrder = 50,
            ZIndex = 12,
            Parent = self.Sidebar,
            Callback = function()
                self:_SetVisibleConfig(not self.ConfigOpen)
            end,
        })
    end

    self.Content = New("Frame", {
        Name = "Content",
        BackgroundColor3 = theme.ContentColor,
        BackgroundTransparency = cfg.Background.ContentTransparency,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(cfg.Layout.Padding + cfg.Layout.SidebarWidth + cfg.Layout.Padding, cfg.Layout.TopbarHeight + cfg.Layout.Padding),
        Size = UDim2.new(1, -(cfg.Layout.Padding * 3 + cfg.Layout.SidebarWidth), 1, -(cfg.Layout.TopbarHeight + cfg.Layout.Padding * 2)),
        ZIndex = 10,
        Parent = frame,
    })
    self:_MakeCorner(self.Content, math.max(8, cfg.Window.CornerRadius - 4))
    self.ContentStroke = self:_MakeStroke(self.Content, theme.OutlineColor, 1, 0.05)

    New("UIPadding", {
        PaddingTop = UDim.new(0, cfg.Layout.ContentPadding),
        PaddingBottom = UDim.new(0, cfg.Layout.ContentPadding),
        PaddingLeft = UDim.new(0, cfg.Layout.ContentPadding),
        PaddingRight = UDim.new(0, cfg.Layout.ContentPadding),
        Parent = self.Content,
    })

    local mainList = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, cfg.Layout.ContentGap),
        Parent = self.Content,
    })

    self.DescriptionLabel = New("TextLabel", {
        Name = "Description",
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Font = theme.Font,
        RichText = true,
        Text = cfg.Description,
        TextColor3 = theme.MutedFontColor,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, 0, 0, cfg.Layout.DescriptionHeight),
        ZIndex = 11,
        Parent = self.Content,
    })

    self.KeyShell = New("Frame", {
        Name = "KeyShell",
        LayoutOrder = 2,
        BackgroundColor3 = theme.SecondColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, cfg.Key.Height),
        ZIndex = 11,
        Parent = self.Content,
    })
    self:_MakeCorner(self.KeyShell, math.max(8, cfg.Window.CornerRadius - 6))
    self.KeyStroke = self:_MakeStroke(self.KeyShell, theme.OutlineColor, 1, 0)

    local keyIconOffset = cfg.Key.ShowKeyIcon and 42 or 12

    if cfg.Key.ShowKeyIcon then
        local keyIcon = self:_MakeIcon(self.KeyShell, "KeyIcon", "key-round", 18, theme.MutedFontColor, 13)
        self.KeyIcon = keyIcon
        if keyIcon then
            keyIcon.AnchorPoint = Vector2.new(0, 0.5)
            keyIcon.Position = UDim2.new(0, 14, 0.5, 0)
        end
    end

    self.KeyBox = New("TextBox", {
        Name = "KeyBox",
        BackgroundTransparency = 1,
        ClearTextOnFocus = cfg.Key.ClearTextOnFocus,
        Font = theme.Font,
        PlaceholderText = cfg.Key.Placeholder,
        PlaceholderColor3 = theme.MutedFontColor,
        Text = "",
        TextColor3 = theme.FontColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Position = UDim2.fromOffset(keyIconOffset, 0),
        Size = UDim2.new(1, cfg.Buttons.ShowRevealKey and -(keyIconOffset + 42) or -(keyIconOffset + 12), 1, 0),
        ZIndex = 13,
        Parent = self.KeyShell,
    })
    self.KeyBox.TextTransparency = cfg.Key.HideText and 1 or 0

    if cfg.Buttons.ShowRevealKey then
        local reveal = New("TextButton", {
            Name = "RevealKey",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(34, 34),
            ZIndex = 13,
            Parent = self.KeyShell,
        })
        self:_MakeCorner(reveal, 8)

        local eye = self:_MakeIcon(reveal, "Icon", cfg.Buttons.EyeIcon, 17, theme.MutedFontColor, 14)
        if eye then
            eye.AnchorPoint = Vector2.new(0.5, 0.5)
            eye.Position = UDim2.fromScale(0.5, 0.5)
        end

        self:_Track(reveal.MouseButton1Click:Connect(function()
            cfg.Key.HideText = not cfg.Key.HideText
            self.KeyBox.TextTransparency = cfg.Key.HideText and 1 or 0

            if eye then
                local data = self:_GetIcon(cfg.Key.HideText and cfg.Buttons.EyeIcon or cfg.Buttons.EyeOffIcon)
                if data then
                    eye.Image = data.Url
                    eye.ImageRectOffset = data.ImageRectOffset or Vector2.zero
                    eye.ImageRectSize = data.ImageRectSize or Vector2.zero
                end
            end
        end))

        self:_Track(reveal.MouseEnter:Connect(function()
            self:_Tween(reveal, { BackgroundTransparency = 0, BackgroundColor3 = theme.ThirdColor }, cfg.Tween.HoverTime)
            if eye then self:_Tween(eye, { ImageColor3 = theme.FontColor }, cfg.Tween.HoverTime) end
        end))

        self:_Track(reveal.MouseLeave:Connect(function()
            self:_Tween(reveal, { BackgroundTransparency = 1 }, cfg.Tween.HoverTime)
            if eye then self:_Tween(eye, { ImageColor3 = theme.MutedFontColor }, cfg.Tween.HoverTime) end
        end))
    end

    self.KeyMeta = New("TextLabel", {
        Name = "KeyMeta",
        LayoutOrder = 3,
        BackgroundTransparency = 1,
        Font = theme.MonoFont,
        Text = "",
        TextColor3 = theme.DarkFontColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(1, 0, 0, 13),
        ZIndex = 11,
        Parent = self.Content,
    })
    self.KeyMeta:SetAttribute("Dark", true)
    table.insert(self.ThemeLabels, self.KeyMeta)

    self.Progress = New("Frame", {
        Name = "Progress",
        LayoutOrder = 4,
        BackgroundColor3 = theme.SecondColor,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 5),
        ZIndex = 11,
        Parent = self.Content,
    })
    self:_MakeCorner(self.Progress, 5)

    self.ProgressFill = New("Frame", {
        Name = "Fill",
        BackgroundColor3 = theme.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        ZIndex = 12,
        Parent = self.Progress,
    })
    self:_MakeCorner(self.ProgressFill, 5)
    self:_MakeGradient(self.ProgressFill, theme.AccentColor, theme.AccentSecondColor, 0)

    self.StatusCard = New("Frame", {
        Name = "StatusCard",
        LayoutOrder = 5,
        BackgroundColor3 = theme.CardColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, cfg.Layout.StatusHeight),
        ZIndex = 11,
        Parent = self.Content,
    })
    self:_MakeCorner(self.StatusCard, 10)
    self.StatusStroke = self:_MakeStroke(self.StatusCard, theme.SoftOutlineColor, 1, 0.14)

    self.StatusIcon = self:_MakeIcon(self.StatusCard, "StatusIcon", "shield-check", 16, theme.MutedFontColor, 12)
    if self.StatusIcon then
        self.StatusIcon.AnchorPoint = Vector2.new(0, 0.5)
        self.StatusIcon.Position = UDim2.new(0, 12, 0.5, 0)
    end

    self.StatusLabel = New("TextLabel", {
        Name = "Status",
        BackgroundTransparency = 1,
        Font = theme.Font,
        RichText = true,
        Text = "",
        TextColor3 = theme.MutedFontColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Position = UDim2.fromOffset(38, 0),
        Size = UDim2.new(1, -50, 1, 0),
        ZIndex = 12,
        Parent = self.StatusCard,
    })

    self.ButtonHolder = New("Frame", {
        Name = "Buttons",
        LayoutOrder = 6,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 11,
        Parent = self.Content,
    })

    local buttonList = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, cfg.Buttons.Gap),
        Parent = self.ButtonHolder,
    })

    self:_Track(buttonList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ButtonHolder.Size = UDim2.new(1, 0, 0, buttonList.AbsoluteContentSize.Y)
    end))

    self:_CreateButton({
        Name = "Verify",
        Text = cfg.Buttons.MainText,
        Icon = cfg.Buttons.MainIcon,
        Accent = true,
        LayoutOrder = 1,
        Callback = function()
            self:_Verify(self.KeyBox.Text, false)
        end,
    })

    if cfg.Buttons.ShowGetKey then
        self:_CreateButton({
            Name = "GetKey",
            Text = cfg.Buttons.GetKeyText,
            Icon = cfg.Buttons.GetKeyIcon,
            LayoutOrder = 2,
            Callback = function()
                if cfg.Links.Key ~= "" and setclipboard then
                    setclipboard(cfg.Links.Key)
                    self:_SetStatus(cfg.Text.Copied, theme.SuccessColor, true, "copy-check")
                    task.spawn(cfg.OnCopied, "Key", cfg.Links.Key, self)
                elseif cfg.Links.Key ~= "" then
                    self:_SetStatus(cfg.Links.Key, theme.WarningColor, true, "external-link")
                else
                    self:_SetStatus(cfg.Text.NoKeyLink, theme.WarningColor, true, "triangle-alert")
                end
            end,
        })
    end

    if cfg.Buttons.ShowDiscord then
        self:_CreateButton({
            Name = "Discord",
            Text = cfg.Buttons.DiscordText,
            Icon = cfg.Buttons.DiscordIcon,
            LayoutOrder = 3,
            Callback = function()
                if cfg.Links.Discord ~= "" and setclipboard then
                    setclipboard(cfg.Links.Discord)
                    self:_SetStatus(cfg.Text.Copied, theme.SuccessColor, true, "copy-check")
                    task.spawn(cfg.OnCopied, "Discord", cfg.Links.Discord, self)
                elseif cfg.Links.Discord ~= "" then
                    self:_SetStatus(cfg.Links.Discord, theme.WarningColor, true, "external-link")
                else
                    self:_SetStatus(cfg.Text.NoDiscord, theme.WarningColor, true, "triangle-alert")
                end
            end,
        })
    end

    if cfg.Buttons.ShowDeleteKey then
        self:_CreateButton({
            Name = "DeleteSavedKey",
            Text = cfg.Buttons.DeleteKeyText,
            Icon = cfg.Buttons.DeleteKeyIcon,
            LayoutOrder = 4,
            Callback = function()
                self:DeleteSavedKey()
                self.KeyBox.Text = ""
                self:_UpdateKeyMeta()
            end,
        })
    end

    self.FooterLabel = New("TextLabel", {
        Name = "Footer",
        LayoutOrder = 7,
        BackgroundTransparency = 1,
        Font = theme.MonoFont,
        RichText = true,
        Text = cfg.Footer,
        TextColor3 = theme.DarkFontColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        Size = UDim2.new(1, 0, 0, cfg.Layout.FooterHeight),
        ZIndex = 11,
        Parent = self.Content,
    })
    self.FooterLabel:SetAttribute("Dark", true)
    table.insert(self.ThemeLabels, self.FooterLabel)

    self:_CreateConfigDrawer()

    self:_Track(self.KeyBox.Focused:Connect(function()
        self:_Tween(self.KeyStroke, {
            Color = cfg.HoverTheme.KeyStrokeColor or theme.AccentColor,
            Transparency = 0,
        }, cfg.Tween.HoverTime)
        if self.KeyIcon then
            self:_Tween(self.KeyIcon, { ImageColor3 = theme.AccentColor }, cfg.Tween.HoverTime)
        end
        if cfg.Key.FocusSelectAll then
            self.KeyBox.CursorPosition = #self.KeyBox.Text + 1
        end
    end))

    self:_Track(self.KeyBox.FocusLost:Connect(function(enter)
        self:_Tween(self.KeyStroke, {
            Color = theme.OutlineColor,
            Transparency = 0,
        }, cfg.Tween.HoverTime)
        if self.KeyIcon then
            self:_Tween(self.KeyIcon, { ImageColor3 = theme.MutedFontColor }, cfg.Tween.HoverTime)
        end
        if enter and cfg.Key.SubmitOnEnter then
            self:_Verify(self.KeyBox.Text, false)
        end
    end))

    self:_Track(self.KeyBox:GetPropertyChangedSignal("Text"):Connect(function()
        if cfg.Key.MaxLength and #self.KeyBox.Text > cfg.Key.MaxLength then
            self.KeyBox.Text = self.KeyBox.Text:sub(1, cfg.Key.MaxLength)
        end
        self:_UpdateKeyMeta()
    end))

    task.defer(function()
        self.ButtonHolder.Size = UDim2.new(1, 0, 0, buttonList.AbsoluteContentSize.Y)
        self:_UpdateKeyMeta()
    end)
end

function KeySystem.new(config)
    local self = setmetatable({}, KeySystem)

    self.Config = GetRootConfig(config)
    self.ButtonList = {}
    self.ThemeLabels = {}
    self.Connections = {}
    self.EffectClock = 0
    self.ConfigOpen = false
    self.Closed = false

    self.TweenInfo = TweenInfo.new(self.Config.Tween.Time, self.Config.Tween.Style, self.Config.Tween.Direction)

    self:_Build()
    self:_SetupResponsiveScale()
    self:_SetupDragging()
    self:_SetupEffects()

    local saved = self.Config.Key.AutoLoad and ReadFile(self.Config.Key.File)
    if saved and saved ~= "" then
        self.KeyBox.Text = saved
        self:_SetStatus(self.Config.Text.Loaded, self.Config.Theme.MutedFontColor, true, "database")

        if self.Config.Key.AutoCheck then
            task.defer(function()
                self:_Verify(saved, true)
            end)
        end
    end

    self:Show()

    return self
end

function KeySystem:Create(config)
    return KeySystem.new(config)
end

return KeySystem
