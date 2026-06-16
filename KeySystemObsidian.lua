local cloneref = cloneref or clonereference or function(v) return v end

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local SoundService = cloneref(game:GetService("SoundService"))
local RunService = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end
local setclipboard = setclipboard or nil

-- ════════════════════════════════════════════════════════
-- HELPERS
-- ════════════════════════════════════════════════════════
local function New(class, props)
    local obj = Instance.new(class)

    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end

    if props and props.Parent then
        obj.Parent = props.Parent
    end

    return obj
end

local function Tween(obj, info, props)
    if not obj or not obj.Parent then return nil end

    local ok, tw = pcall(function()
        return TweenService:Create(obj, info, props)
    end)

    if ok and tw then
        tw:Play()
        return tw
    end

    return nil
end

local function Q(obj, props, t, dir)
    return Tween(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function Sine(obj, props, t, dir)
    return Tween(obj, TweenInfo.new(t or 0.28, Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out), props)
end

local function Back(obj, props, t, dir)
    return Tween(obj, TweenInfo.new(t or 0.34, Enum.EasingStyle.Back, dir or Enum.EasingDirection.Out), props)
end

local function Quint(obj, props, t, dir)
    return Tween(obj, TweenInfo.new(t or 0.32, Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
end

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

local function ToAsset(v)
    if v == nil or v == "" then return nil end
    if typeof(v) == "number" then return "rbxassetid://" .. tostring(v) end
    if typeof(v) ~= "string" then return nil end

    if v:match("^rbxassetid://") or v:match("^rbxthumb://") or v:match("roblox%.com") then
        return v
    end

    if tonumber(v) then
        return "rbxassetid://" .. v
    end

    return nil
end

local function MakeFolderPath(path)
    if not (isfolder and makefolder and path and path ~= "") then return end

    local parts = string.split(path, "/")
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
    return pcall(writefile, path, tostring(text or ""))
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

local function Brighten(c, amt)
    return Color3.fromRGB(
        math.clamp(c.R * 255 + amt, 0, 255),
        math.clamp(c.G * 255 + amt, 0, 255),
        math.clamp(c.B * 255 + amt, 0, 255)
    )
end

local function TextBounds(text, font, size)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = tostring(text or "")
    params.RichText = true
    params.Font = typeof(font) == "Font" and font or Font.fromEnum(font or Enum.Font.GothamMedium)
    params.Size = size or 14
    params.Width = 9999

    local ok, result = pcall(function()
        return TextService:GetTextBoundsAsync(params)
    end)

    if ok then
        return result
    end

    return Vector2.new(#tostring(text or "") * (size or 14) * 0.55, size or 14)
end

local function SafeParent(gui, parent)
    pcall(protectgui, gui)

    local ok = pcall(function()
        gui.Parent = parent or gethui()
    end)

    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function CurrentCamera()
    return Workspace.CurrentCamera
end

-- ════════════════════════════════════════════════════════
-- AUDIO MANAGER
-- ════════════════════════════════════════════════════════
local AudioManager = {}
AudioManager.Active = false
AudioManager.StoredSounds = {}
AudioManager.StoredAudioObjects = {}
AudioManager.Connections = {}
AudioManager.EQTag = "__KS_MuffleEQ__"

function AudioManager:_HookSound(sound, cfg)
    if not self.Active then return end
    if not sound or not sound:IsA("Sound") then return end
    if self.StoredSounds[sound] then return end

    self.StoredSounds[sound] = {
        Volume = sound.Volume,
        Effects = {},
    }

    if cfg.Focus.MuffleAudio then
        local eq = New("EqualizerSoundEffect", {
            Name = self.EQTag,
            LowGain = cfg.Focus.AudioLowGain,
            MidGain = cfg.Focus.AudioMidGain,
            HighGain = cfg.Focus.AudioHighGain,
            Parent = sound,
        })

        table.insert(self.StoredSounds[sound].Effects, eq)
    end

    Q(sound, {
        Volume = sound.Volume * cfg.Focus.AudioVolumeMultiplier,
    }, cfg.Focus.AudioTweenTime)
end

function AudioManager:_HookAudioObject(obj, cfg)
    if not self.Active then return end
    if not cfg.Focus.TryVoiceChat then return end
    if not obj then return end

    local className = obj.ClassName

    if className ~= "AudioDeviceOutput" and className ~= "AudioEmitter" and className ~= "AudioListener" then
        return
    end

    if self.StoredAudioObjects[obj] then return end

    local props = {}

    pcall(function()
        props.Volume = obj.Volume
        obj.Volume = (props.Volume or 1) * cfg.Focus.AudioVolumeMultiplier
    end)

    if next(props) then
        self.StoredAudioObjects[obj] = props
    end
end

function AudioManager:Enter(cfg)
    if self.Active then return end

    self.Active = true
    self.StoredSounds = {}
    self.StoredAudioObjects = {}
    self.Connections = {}

    for _, obj in ipairs(game:GetDescendants()) do
        self:_HookSound(obj, cfg)
        self:_HookAudioObject(obj, cfg)
    end

    table.insert(self.Connections, game.DescendantAdded:Connect(function(obj)
        task.defer(function()
            if self.Active then
                self:_HookSound(obj, cfg)
                self:_HookAudioObject(obj, cfg)
            end
        end)
    end))
end

function AudioManager:Exit(cfg)
    if not self.Active then return end

    self.Active = false

    for _, conn in ipairs(self.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end

    self.Connections = {}

    for sound, data in pairs(self.StoredSounds) do
        if sound and sound.Parent then
            Q(sound, {
                Volume = data.Volume,
            }, cfg.Focus.AudioTweenTime)

            task.delay(cfg.Focus.AudioTweenTime + 0.05, function()
                if not sound or not sound.Parent then return end

                for _, fx in ipairs(data.Effects or {}) do
                    if fx and fx.Parent then
                        fx:Destroy()
                    end
                end

                local old = sound:FindFirstChild(self.EQTag)
                if old then old:Destroy() end
            end)
        end
    end

    for obj, props in pairs(self.StoredAudioObjects) do
        if obj and obj.Parent then
            for prop, value in pairs(props) do
                pcall(function()
                    obj[prop] = value
                end)
            end
        end
    end

    self.StoredSounds = {}
    self.StoredAudioObjects = {}
end

-- ════════════════════════════════════════════════════════
-- FOCUS EFFECT
-- ════════════════════════════════════════════════════════
local FocusEffect = {}
FocusEffect.Active = false
FocusEffect.Gui = nil
FocusEffect.Overlay = nil
FocusEffect.Vignette = nil
FocusEffect.Blur = nil
FocusEffect.ColorCorrection = nil
FocusEffect.OriginalFOV = nil

function FocusEffect:Enter(cfg)
    if self.Active or not cfg.Focus.Enabled then return end
    self.Active = true

    local cam = CurrentCamera()
    if cam then
        self.OriginalFOV = cam.FieldOfView

        if cfg.Focus.NarrowFOV then
            Sine(cam, {
                FieldOfView = self.OriginalFOV - cfg.Focus.FOVNarrow,
            }, cfg.Focus.FOVTweenTime)
        end
    end

    local gui = New("ScreenGui", {
        Name = "__KS_Focus_" .. HttpService:GenerateGUID(false):sub(1, 8),
        DisplayOrder = cfg.Window.DisplayOrder - 2,
        IgnoreGuiInset = cfg.Window.IgnoreGuiInset,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    SafeParent(gui, cfg.Window.Parent)
    self.Gui = gui

    self.Overlay = New("Frame", {
        Name = "Overlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 1,
        Parent = gui,
    })

    self.Vignette = New("ImageLabel", {
        Name = "Vignette",
        BackgroundTransparency = 1,
        Image = cfg.Focus.VignetteImage,
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Stretch,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        Parent = gui,
    })

    if cfg.Focus.Blur then
        local blur = Instance.new("BlurEffect")
        blur.Name = "__KS_Blur"
        blur.Size = 0
        blur.Parent = Lighting
        self.Blur = blur

        Sine(blur, {
            Size = cfg.Focus.BlurSize,
        }, cfg.Focus.FOVTweenTime)
    end

    if cfg.Focus.ColorCorrection then
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "__KS_ColorCorrection"
        cc.Saturation = 0
        cc.Contrast = 0
        cc.TintColor = Color3.fromRGB(255, 255, 255)
        cc.Parent = Lighting
        self.ColorCorrection = cc

        Sine(cc, {
            Saturation = cfg.Focus.Saturation,
            Contrast = cfg.Focus.Contrast,
            TintColor = cfg.Focus.TintColor,
        }, cfg.Focus.FOVTweenTime)
    end

    local dim = math.clamp(cfg.Focus.DimAmount or 0.6, 0, 0.94)
    local vig = math.clamp(cfg.Focus.VigAmount or 0.72, 0, 1)

    Q(self.Overlay, {
        BackgroundTransparency = 1 - dim,
    }, cfg.Focus.TweenTime)

    Q(self.Vignette, {
        ImageTransparency = 1 - vig,
    }, cfg.Focus.TweenTime)
end

function FocusEffect:Exit(cfg)
    if not self.Active then return end
    self.Active = false

    local cam = CurrentCamera()
    if cam and cfg.Focus.NarrowFOV and self.OriginalFOV then
        Sine(cam, {
            FieldOfView = self.OriginalFOV,
        }, cfg.Focus.FOVTweenTime)
    end

    if self.Overlay then
        Q(self.Overlay, {
            BackgroundTransparency = 1,
        }, cfg.Focus.TweenTime * 0.85)
    end

    if self.Vignette then
        Q(self.Vignette, {
            ImageTransparency = 1,
        }, cfg.Focus.TweenTime * 0.85)
    end

    if self.Blur then
        Sine(self.Blur, {
            Size = 0,
        }, cfg.Focus.FOVTweenTime)
    end

    if self.ColorCorrection then
        Sine(self.ColorCorrection, {
            Saturation = 0,
            Contrast = 0,
            TintColor = Color3.fromRGB(255, 255, 255),
        }, cfg.Focus.FOVTweenTime)
    end

    task.delay(math.max(cfg.Focus.TweenTime, cfg.Focus.FOVTweenTime) + 0.08, function()
        if self.Gui then self.Gui:Destroy() end
        if self.Blur then self.Blur:Destroy() end
        if self.ColorCorrection then self.ColorCorrection:Destroy() end

        self.Gui = nil
        self.Overlay = nil
        self.Vignette = nil
        self.Blur = nil
        self.ColorCorrection = nil
        self.OriginalFOV = nil
    end)
end

-- ════════════════════════════════════════════════════════
-- KEYSYSTEM CLASS
-- ════════════════════════════════════════════════════════
local KeySystem = {}
KeySystem.__index = KeySystem

KeySystem.DefaultConfig = {
    Title = "Key System",
    Description = "Enter your key to continue.",
    Footer = "Powered by KeySystem",
    BadgeText = "secure access",

    Window = {
        Size = UDim2.fromOffset(500, 390),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Center = true,
        CornerRadius = 14,
        StrokeThickness = 1,
        DisplayOrder = 999,
        Draggable = true,
        ClipsDescendants = true,
        AutoScale = true,
        UIScale = 1,
        Parent = nil,
        IgnoreGuiInset = true,

        Shadow = {
            Enabled = true,
            Size = 10,
            Opacity = 0.48,
            Layers = 5,
        },

        Background = {
            Enabled = false,
            Image = "",
            Transparency = 0.08,
            Color = Color3.fromRGB(255, 255, 255),
            ScaleType = Enum.ScaleType.Crop,
            DimAmount = 0.58,
            Parallax = false,
            ParallaxAmount = 0.012,
        },
    },

    Focus = {
        Enabled = true,
        DimAmount = 0.66,
        VigAmount = 0.72,
        VignetteImage = "rbxassetid://7912134082",

        NarrowFOV = true,
        FOVNarrow = 4,
        FOVTweenTime = 0.45,

        Blur = true,
        BlurSize = 6,
        ColorCorrection = true,
        Saturation = -0.12,
        Contrast = 0.08,
        TintColor = Color3.fromRGB(244, 235, 255),

        MuffleAudio = true,
        TryVoiceChat = true,
        AudioVolumeMultiplier = 0.35,
        AudioLowGain = -2,
        AudioMidGain = -10,
        AudioHighGain = -26,
        AudioTweenTime = 0.45,

        TweenTime = 0.48,
    },

    Key = {
        File = "KeySystem/saved_key.txt",
        Save = true,
        AutoLoad = true,
        AutoCheck = false,
        DeleteInvalidKey = true,
        ClearOnInvalid = false,
        Placeholder = "Paste your key here...",
        Height = 44,
        HideText = false,
        SubmitOnEnter = true,
        Trim = true,
    },

    Buttons = {
        Height = 40,
        Gap = 8,
        IconSize = 15,
        IconGap = 8,
        IconSide = "Right",
        LucideURL = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",

        MainText = "Continue",
        MainIcon = "arrow-right",

        GetKeyText = "Get Key",
        GetKeyIcon = "external-link",

        DiscordText = "Copy Discord",
        DiscordIcon = "copy",

        DeleteKeyText = "Delete Saved Key",
        DeleteKeyIcon = "trash-2",

        CloseIcon = "x",

        ShowGetKey = true,
        ShowDiscord = true,
        ShowDeleteKey = true,
        ShowClose = true,
    },

    Links = {
        Key = "",
        Discord = "",
    },

    Theme = {
        WindowBg = Color3.fromRGB(7, 7, 11),
        TopbarBg = Color3.fromRGB(11, 10, 17),
        PanelBg = Color3.fromRGB(12, 11, 18),
        InputBg = Color3.fromRGB(5, 4, 10),
        ButtonBg = Color3.fromRGB(17, 15, 26),

        Accent = Color3.fromRGB(126, 78, 255),
        Accent2 = Color3.fromRGB(190, 73, 255),
        AccentHover = Color3.fromRGB(148, 101, 255),

        Stroke = Color3.fromRGB(47, 38, 72),
        StrokeSoft = Color3.fromRGB(30, 25, 45),
        StrokeHover = Color3.fromRGB(126, 78, 255),

        TextPrimary = Color3.fromRGB(244, 240, 255),
        TextMuted = Color3.fromRGB(153, 142, 181),
        TextButton = Color3.fromRGB(250, 247, 255),

        Success = Color3.fromRGB(72, 235, 168),
        Error = Color3.fromRGB(255, 84, 124),
        Warning = Color3.fromRGB(255, 197, 86),

        Font = Enum.Font.GothamMedium,
        FontBold = Enum.Font.GothamBold,
        FontCode = Enum.Font.Code,
    },

    Text = {
        Success = "Key verified — loading...",
        Invalid = "Invalid key. Please try again.",
        Checking = "Checking...",
        Loaded = "Saved key loaded.",
        Deleted = "Saved key deleted.",
        Copied = "Copied to clipboard.",
        CopyFail = "Clipboard unavailable.",
        NoKeyLink = "No key link set.",
        NoDiscord = "No Discord set.",
        EnterKey = "Enter a key first.",
    },

    VerifyKey = function(key)
        return key == "test-key"
    end,

    OnSuccess = function(key, ui) end,
    OnInvalid = function(key, ui) end,
    OnClose = function(ui) end,
}

-- ════════════════════════════════════════════════════════
-- CONFIG NORMALIZATION
-- ════════════════════════════════════════════════════════
local function NormalizeTheme(theme)
    if typeof(theme) ~= "table" then return theme end

    local mapped = {}

    mapped.WindowBg = theme.WindowBg or theme.BackgroundColor
    mapped.TopbarBg = theme.TopbarBg or theme.MainColor
    mapped.PanelBg = theme.PanelBg or theme.MainColor
    mapped.InputBg = theme.InputBg or theme.SecondColor
    mapped.ButtonBg = theme.ButtonBg or theme.SecondColor

    mapped.Accent = theme.Accent or theme.AccentColor
    mapped.Accent2 = theme.Accent2 or theme.AccentColor
    mapped.AccentHover = theme.AccentHover or theme.AccentHoverColor

    mapped.Stroke = theme.Stroke or theme.OutlineColor
    mapped.StrokeSoft = theme.StrokeSoft or theme.OutlineColor
    mapped.StrokeHover = theme.StrokeHover or theme.AccentHoverColor or theme.AccentColor

    mapped.TextPrimary = theme.TextPrimary or theme.FontColor
    mapped.TextMuted = theme.TextMuted or theme.MutedFontColor
    mapped.TextButton = theme.TextButton or theme.ButtonTextColor or theme.FontColor

    mapped.Success = theme.Success or theme.SuccessColor
    mapped.Error = theme.Error or theme.ErrorColor
    mapped.Warning = theme.Warning or theme.WarningColor

    mapped.Font = theme.Font
    mapped.FontBold = theme.FontBold
    mapped.FontCode = theme.FontCode

    for k, v in pairs(theme) do
        if mapped[k] == nil then
            mapped[k] = v
        end
    end

    return mapped
end

local function NormalizeConfig(cfg)
    cfg = cfg or {}

    local nested = cfg.Window or cfg.Key or cfg.Buttons or cfg.Links or cfg.Focus

    if not nested then
        cfg = {
            Title = cfg.Title,
            Description = cfg.Description or cfg.Subtitle,
            Footer = cfg.Footer,
            BadgeText = cfg.BadgeText,

            Window = {
                Size = cfg.Size,
                Position = cfg.Position,
                AnchorPoint = cfg.AnchorPoint,
                Center = cfg.Center,
                CornerRadius = cfg.CornerRadius,
                DisplayOrder = cfg.DisplayOrder,
                Draggable = cfg.Draggable,
                Parent = cfg.Parent,

                Shadow = {
                    Enabled = cfg.Shadow,
                    Size = cfg.ShadowSize,
                    Opacity = cfg.ShadowOpacity or cfg.ShadowTransparency,
                    Layers = cfg.ShadowLayers,
                },

                Background = {
                    Enabled = cfg.CustomBackground or (cfg.BackgroundImage and cfg.BackgroundImage ~= ""),
                    Image = cfg.BackgroundImage,
                    Transparency = cfg.BackgroundImageTransparency,
                    DimAmount = cfg.BackgroundDim,
                    ScaleType = cfg.BackgroundScaleType,
                },
            },

            Focus = {
                Enabled = cfg.FocusDarken,
                DimAmount = cfg.FocusDarkness,
                NarrowFOV = cfg.FOVTween,
                FOVNarrow = cfg.FOVNarrow,
                FOVTweenTime = cfg.FOVTweenTime,
                MuffleAudio = cfg.FocusAudio,
                TryVoiceChat = cfg.FocusAudioVoiceChat,
                AudioVolumeMultiplier = cfg.FocusAudioVolume,
                AudioLowGain = cfg.FocusAudioLowGain,
                AudioMidGain = cfg.FocusAudioMidGain,
                AudioHighGain = cfg.FocusAudioHighGain,
            },

            Key = {
                File = cfg.KeyFile,
                Save = cfg.SaveKey,
                AutoLoad = cfg.AutoLoadSavedKey,
                AutoCheck = cfg.AutoCheckSavedKey,
                DeleteInvalidKey = cfg.DeleteInvalidKey ~= nil and cfg.DeleteInvalidKey or cfg.AutoDeleteInvalidKey,
                ClearOnInvalid = cfg.ClearInputWhenInvalid,
                Placeholder = cfg.KeyPlaceholder,
                HideText = cfg.HideKeyText,
            },

            Buttons = {
                IconSize = cfg.IconSize,
                IconGap = cfg.IconGap,
                IconSide = cfg.IconSide,
                MainText = cfg.MainButtonText,
                MainIcon = cfg.MainButtonIcon,
                GetKeyText = cfg.GetKeyButtonText,
                GetKeyIcon = cfg.GetKeyButtonIcon,
                DiscordText = cfg.DiscordButtonText or cfg.CopyDiscordButtonText,
                DiscordIcon = cfg.DiscordButtonIcon or cfg.CopyDiscordButtonIcon,
                DeleteKeyText = cfg.DeleteKeyButtonText,
                DeleteKeyIcon = cfg.DeleteKeyButtonIcon,
                CloseIcon = cfg.CloseButtonIcon,
                ShowGetKey = cfg.ShowGetKeyButton,
                ShowDiscord = cfg.ShowDiscordButton,
                ShowDeleteKey = cfg.ShowDeleteKeyButton,
                ShowClose = cfg.ShowCloseButton,
            },

            Links = {
                Key = cfg.KeyLink,
                Discord = cfg.Discord,
            },

            Theme = NormalizeTheme(cfg.Theme),

            VerifyKey = cfg.VerifyKey,
            OnSuccess = cfg.OnSuccess,
            OnInvalid = cfg.OnInvalid,
            OnClose = cfg.OnClose,
        }
    else
        cfg.Theme = NormalizeTheme(cfg.Theme)

        if cfg.Subtitle and not cfg.Description then
            cfg.Description = cfg.Subtitle
        end

        if cfg.Window and cfg.Window.Background and cfg.Window.Background.Image and cfg.Window.Background.Image ~= "" then
            if cfg.Window.Background.Enabled == nil then
                cfg.Window.Background.Enabled = true
            end
        end

        if cfg.Key then
            if cfg.Key.DeleteInvalidKey == nil then
                cfg.Key.DeleteInvalidKey = cfg.Key.AutoDeleteInvalid or cfg.Key.AutoDeleteInvalidKey
            end
            if cfg.Key.File == nil then
                cfg.Key.File = cfg.KeyFile
            end
        end
    end

    return DeepMerge(KeySystem.DefaultConfig, cfg)
end

-- ════════════════════════════════════════════════════════
-- LUCIDE / ICONS
-- ════════════════════════════════════════════════════════
function KeySystem:_LoadLucide()
    if self._lucideLoaded then return end
    self._lucideLoaded = true

    local url = self.Config.Buttons.LucideURL
    if not url or url == "" then return end

    local ok, mod = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if ok and typeof(mod) == "table" and typeof(mod.GetAsset) == "function" then
        self._lucide = mod
    end
end

function KeySystem:_GetIcon(name)
    local asset = ToAsset(name)

    if asset then
        return {
            Url = asset,
            Offset = Vector2.zero,
            Size = Vector2.zero,
        }
    end

    if typeof(name) == "string" and name ~= "" then
        self:_LoadLucide()

        if self._lucide then
            local ok, data = pcall(self._lucide.GetAsset, name)

            if ok and data then
                return {
                    Url = data.Url,
                    Offset = data.ImageRectOffset or Vector2.zero,
                    Size = data.ImageRectSize or Vector2.zero,
                }
            end
        end
    end

    return nil
end

-- ════════════════════════════════════════════════════════
-- TRACKING / THEME
-- ════════════════════════════════════════════════════════
function KeySystem:_Track(obj, props)
    if not obj then return obj end

    self._tracked[obj] = props or {}

    return obj
end

function KeySystem:_ApplyTheme()
    local th = self.Config.Theme

    if self._frame then self._frame.BackgroundColor3 = th.WindowBg end
    if self._topbar then self._topbar.BackgroundColor3 = th.TopbarBg end
    if self._panel then self._panel.BackgroundColor3 = th.PanelBg end
    if self._keyBox then
        self._keyBox.BackgroundColor3 = th.InputBg
        self._keyBox.TextColor3 = th.TextPrimary
        self._keyBox.PlaceholderColor3 = th.TextMuted
    end
    if self._windowStroke then self._windowStroke.Color = th.Stroke end
    if self._panelStroke then self._panelStroke.Color = th.StrokeSoft end
    if self._keyStroke then self._keyStroke.Color = th.Stroke end

    for obj, data in pairs(self._tracked) do
        if obj and obj.Parent then
            if data.TextColor then
                obj.TextColor3 = th[data.TextColor] or data.TextColor
            end
            if data.ImageColor then
                obj.ImageColor3 = th[data.ImageColor] or data.ImageColor
            end
            if data.BackgroundColor then
                obj.BackgroundColor3 = th[data.BackgroundColor] or data.BackgroundColor
            end
        end
    end
end

function KeySystem:SetTheme(theme)
    self.Config.Theme = DeepMerge(self.Config.Theme, NormalizeTheme(theme or {}))
    self:_ApplyTheme()
    return self
end

-- ════════════════════════════════════════════════════════
-- STATUS / PULSE
-- ════════════════════════════════════════════════════════
function KeySystem:_Status(text, color, flash)
    if not self._statusLabel then return end

    self._statusLabel.Text = tostring(text or "")
    self._statusLabel.TextColor3 = color or self.Config.Theme.TextMuted

    if flash then
        self._statusLabel.TextTransparency = 1
        Q(self._statusLabel, {
            TextTransparency = 0,
        }, 0.2)
    end
end

function KeySystem:_PulseStroke(color)
    if self._windowStroke then
        Q(self._windowStroke, { Color = color }, 0.1)
        task.delay(0.42, function()
            if self._windowStroke then
                Q(self._windowStroke, { Color = self.Config.Theme.Stroke }, 0.25)
            end
        end)
    end

    if self._panelStroke then
        Q(self._panelStroke, { Color = color }, 0.1)
        task.delay(0.42, function()
            if self._panelStroke then
                Q(self._panelStroke, { Color = self.Config.Theme.StrokeSoft }, 0.25)
            end
        end)
    end
end

function KeySystem:_ShakeKeyBox()
    if not self._keyBox then return end

    local box = self._keyBox
    local base = box.Position

    for i = 1, 5 do
        task.delay(i * 0.045, function()
            if not box or not box.Parent then return end

            local x = (i % 2 == 0) and 7 or -7
            Q(box, { Position = base + UDim2.fromOffset(x, 0) }, 0.04)

            task.delay(0.04, function()
                if box and box.Parent then
                    Q(box, { Position = base }, 0.04)
                end
            end)
        end)
    end
end

-- ════════════════════════════════════════════════════════
-- BUTTON FACTORY
-- ════════════════════════════════════════════════════════
function KeySystem:_MakeButton(opts)
    local cfg = self.Config
    local th = cfg.Theme
    local bcfg = cfg.Buttons
    local accent = opts.Accent == true

    local normalBg = accent and th.Accent or th.ButtonBg
    local hoverBg = accent and th.AccentHover or Brighten(th.ButtonBg, 16)

    local btn = New("TextButton", {
        Name = opts.Name or "Button",
        AutoButtonColor = false,
        BackgroundColor3 = normalBg,
        BorderSizePixel = 0,
        LayoutOrder = opts.Order or 0,
        Size = UDim2.new(1, 0, 0, bcfg.Height),
        Text = "",
        ZIndex = 20,
        Parent = self._btnHolder,
    })

    self:_Track(btn, { BackgroundColor = accent and "Accent" or "ButtonBg" })

    New("UICorner", {
        CornerRadius = UDim.new(0, math.max(6, cfg.Window.CornerRadius - 6)),
        Parent = btn,
    })

    local stroke = New("UIStroke", {
        Color = accent and th.Accent2 or th.Stroke,
        Thickness = 1,
        Transparency = accent and 0.25 or 0,
        Parent = btn,
    })

    if accent then
        New("UIGradient", {
            Color = ColorSequence.new(th.Accent, th.Accent2),
            Rotation = 0,
            Parent = btn,
        })
    end

    local scale = New("UIScale", {
        Scale = 1,
        Parent = btn,
    })

    local row = New("Frame", {
        Name = "Row",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, bcfg.Height),
        ZIndex = 21,
        Parent = btn,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, bcfg.IconGap),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = row,
    })

    local label = New("TextLabel", {
        Name = "Label",
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Font = accent and th.FontBold or th.Font,
        LayoutOrder = bcfg.IconSide == "Left" and 2 or 1,
        RichText = true,
        Text = opts.Text or "Button",
        TextColor3 = th.TextButton,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromOffset(0, bcfg.Height),
        ZIndex = 22,
        Parent = row,
    })

    self:_Track(label, { TextColor = "TextButton" })

    local iconImg
    local iconData = self:_GetIcon(opts.Icon)

    if iconData then
        iconImg = New("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Image = iconData.Url,
            ImageColor3 = th.TextButton,
            ImageRectOffset = iconData.Offset,
            ImageRectSize = iconData.Size,
            LayoutOrder = bcfg.IconSide == "Left" and 1 or 2,
            Size = UDim2.fromOffset(bcfg.IconSize, bcfg.IconSize),
            ZIndex = 22,
            Parent = row,
        })

        self:_Track(iconImg, { ImageColor = "TextButton" })
    end

    local function resize()
        local clean = label.Text:gsub("<.->", "")
        local bounds = TextBounds(clean, label.Font, label.TextSize)
        local width = math.ceil(bounds.X) + 4

        if iconImg then
            width += bcfg.IconSize + bcfg.IconGap
        end

        row.Size = UDim2.fromOffset(width, bcfg.Height)
    end

    resize()
    label:GetPropertyChangedSignal("Text"):Connect(resize)

    btn.MouseEnter:Connect(function()
        Q(btn, {
            BackgroundColor3 = hoverBg,
        }, 0.12)

        Q(stroke, {
            Color = accent and th.Accent2 or th.StrokeHover,
            Transparency = 0,
        }, 0.12)
    end)

    btn.MouseLeave:Connect(function()
        Q(btn, {
            BackgroundColor3 = normalBg,
        }, 0.16)

        Q(stroke, {
            Color = accent and th.Accent2 or th.Stroke,
            Transparency = accent and 0.25 or 0,
        }, 0.16)
    end)

    btn.MouseButton1Down:Connect(function()
        Back(scale, {
            Scale = 0.975,
        }, 0.1)
    end)

    btn.MouseButton1Up:Connect(function()
        Back(scale, {
            Scale = 1,
        }, 0.2)
    end)

    btn.MouseButton1Click:Connect(function()
        if typeof(opts.Callback) == "function" then
            opts.Callback(btn, label, iconImg)
        end
    end)

    table.insert(self._buttons, btn)

    return btn
end

-- ════════════════════════════════════════════════════════
-- VERIFY LOGIC
-- ════════════════════════════════════════════════════════
function KeySystem:_Verify(key, fromSaved)
    local cfg = self.Config
    local th = cfg.Theme

    key = tostring(key or (self._keyBox and self._keyBox.Text) or "")

    if cfg.Key.Trim then
        key = key:match("^%s*(.-)%s*$")
    end

    if key == "" then
        self:_Status(cfg.Text.EnterKey, th.Warning, true)
        self:_ShakeKeyBox()
        return false
    end

    self:_Status(cfg.Text.Checking, th.Warning, true)

    local verifyButton = self._buttons[1]
    local verifyIcon = verifyButton and verifyButton:FindFirstChild("Icon", true)
    local verifyLabel = verifyButton and verifyButton:FindFirstChild("Label", true)
    local oldText = verifyLabel and verifyLabel.Text

    if verifyLabel then
        verifyLabel.Text = cfg.Text.Checking
    end

    local spinConn

    if verifyIcon then
        local angle = 0
        spinConn = RunService.RenderStepped:Connect(function(dt)
            angle = (angle + dt * 360) % 360
            verifyIcon.Rotation = angle
        end)
    end

    local ok, valid, message = pcall(cfg.VerifyKey, key, self)
    valid = ok and valid == true

    if spinConn then spinConn:Disconnect() end
    if verifyIcon then verifyIcon.Rotation = 0 end
    if verifyLabel then verifyLabel.Text = oldText or cfg.Buttons.MainText end

    if valid then
        self.ValidatedKey = key

        if cfg.Key.Save then
            SaveFile(cfg.Key.File, key)
        end

        self:_Status(message or cfg.Text.Success, th.Success, true)
        self:_PulseStroke(th.Success)

        task.spawn(cfg.OnSuccess, key, self)
        return true
    end

    if cfg.Key.DeleteInvalidKey then
        DeleteFile(cfg.Key.File)
    end

    if cfg.Key.ClearOnInvalid and not fromSaved and self._keyBox then
        self._keyBox.Text = ""
    end

    self:_Status(message or cfg.Text.Invalid, th.Error, true)
    self:_PulseStroke(th.Error)
    self:_ShakeKeyBox()

    task.spawn(cfg.OnInvalid, key, self)
    return false
end

-- ════════════════════════════════════════════════════════
-- DRAGGING
-- ════════════════════════════════════════════════════════
function KeySystem:_SetupDrag()
    if not self.Config.Window.Draggable or not self._topbar then return end

    local dragging = false
    local startInput
    local startPosition
    local releaseConn

    self._topbar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch
        then
            return
        end

        dragging = true
        startInput = input.Position
        startPosition = self._holder.Position

        if releaseConn then
            releaseConn:Disconnect()
            releaseConn = nil
        end

        releaseConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false

                if releaseConn then
                    releaseConn:Disconnect()
                    releaseConn = nil
                end
            end
        end)
    end)

    self._dragConn = UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch
        then
            return
        end

        local delta = input.Position - startInput

        self._holder.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

        self._basePosition = self._holder.Position
    end)
end

-- ════════════════════════════════════════════════════════
-- SHOW / CLOSE
-- ════════════════════════════════════════════════════════
function KeySystem:Show()
    if self._shown then return self end
    self._shown = true

    local cfg = self.Config

    FocusEffect:Enter(cfg)

    if cfg.Focus.Enabled and cfg.Focus.MuffleAudio then
        AudioManager:Enter(cfg)
    end

    self._holder.Visible = true
    self._scale.Scale = 0.88
    self._holder.Position = self._basePosition + UDim2.fromOffset(0, 20)

    self._frame.BackgroundTransparency = 1
    self._topbar.BackgroundTransparency = 1
    self._panel.BackgroundTransparency = 1

    if self._windowStroke then self._windowStroke.Transparency = 1 end
    if self._panelStroke then self._panelStroke.Transparency = 1 end

    if self._accentBar then
        self._accentBar.Size = UDim2.new(0, 0, 0, 2)
    end

    for obj, data in pairs(self._fadeTargets) do
        if obj and obj.Parent then
            if data.TextTransparency ~= nil and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
                obj.TextTransparency = 1
            end
            if data.ImageTransparency ~= nil and obj:IsA("ImageLabel") then
                obj.ImageTransparency = 1
            end
            if data.BackgroundTransparency ~= nil then
                obj.BackgroundTransparency = 1
            end
        end
    end

    Back(self._scale, {
        Scale = 1,
    }, 0.42)

    Quint(self._holder, {
        Position = self._basePosition,
    }, 0.36)

    Q(self._frame, {
        BackgroundTransparency = 0,
    }, 0.22)

    Q(self._topbar, {
        BackgroundTransparency = 0,
    }, 0.22)

    Q(self._panel, {
        BackgroundTransparency = 0,
    }, 0.22)

    if self._windowStroke then
        Q(self._windowStroke, { Transparency = 0 }, 0.22)
    end

    if self._panelStroke then
        Q(self._panelStroke, { Transparency = 0 }, 0.22)
    end

    if self._accentBar then
        task.delay(0.08, function()
            if self._accentBar then
                Quint(self._accentBar, {
                    Size = UDim2.new(1, 0, 0, 2),
                }, 0.45)
            end
        end)
    end

    local trackedList = {}

    for obj, data in pairs(self._fadeTargets) do
        table.insert(trackedList, { obj = obj, data = data, order = data.Order or 0 })
    end

    table.sort(trackedList, function(a, b)
        return a.order < b.order
    end)

    for index, pack in ipairs(trackedList) do
        task.delay(0.1 + index * 0.015, function()
            local obj = pack.obj
            local data = pack.data

            if not obj or not obj.Parent then return end

            if data.TextTransparency ~= nil and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
                Q(obj, { TextTransparency = data.TextTransparency }, 0.18)
            end

            if data.ImageTransparency ~= nil and obj:IsA("ImageLabel") then
                Q(obj, { ImageTransparency = data.ImageTransparency }, 0.18)
            end

            if data.BackgroundTransparency ~= nil then
                Q(obj, { BackgroundTransparency = data.BackgroundTransparency }, 0.18)
            end
        end)
    end

    return self
end

function KeySystem:Close()
    if self._closed then return end
    self._closed = true

    local cfg = self.Config

    task.spawn(cfg.OnClose, self)

    if self._dragConn then
        self._dragConn:Disconnect()
        self._dragConn = nil
    end

    if cfg.Focus.Enabled then
        FocusEffect:Exit(cfg)

        if cfg.Focus.MuffleAudio then
            AudioManager:Exit(cfg)
        end
    end

    Back(self._scale, {
        Scale = 0.9,
    }, 0.22, Enum.EasingDirection.In)

    Quint(self._holder, {
        Position = self._basePosition + UDim2.fromOffset(0, 18),
    }, 0.22, Enum.EasingDirection.In)

    Q(self._frame, {
        BackgroundTransparency = 1,
    }, 0.2)

    Q(self._topbar, {
        BackgroundTransparency = 1,
    }, 0.2)

    Q(self._panel, {
        BackgroundTransparency = 1,
    }, 0.2)

    if self._windowStroke then
        Q(self._windowStroke, { Transparency = 1 }, 0.2)
    end

    if self._panelStroke then
        Q(self._panelStroke, { Transparency = 1 }, 0.2)
    end

    for obj, data in pairs(self._fadeTargets) do
        if obj and obj.Parent then
            if data.TextTransparency ~= nil and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
                Q(obj, { TextTransparency = 1 }, 0.16)
            end
            if data.ImageTransparency ~= nil and obj:IsA("ImageLabel") then
                Q(obj, { ImageTransparency = 1 }, 0.16)
            end
            if data.BackgroundTransparency ~= nil then
                Q(obj, { BackgroundTransparency = 1 }, 0.16)
            end
        end
    end

    task.delay(0.35, function()
        if self._gui then
            self._gui:Destroy()
        end
    end)
end

function KeySystem:Hide()
    if self._holder then
        self._holder.Visible = false
    end

    return self
end

function KeySystem:Destroy()
    if self._gui then
        self._gui:Destroy()
    end

    return self
end

-- ════════════════════════════════════════════════════════
-- PUBLIC API
-- ════════════════════════════════════════════════════════
function KeySystem:Verify(key)
    return self:_Verify(key or (self._keyBox and self._keyBox.Text), false)
end

function KeySystem:SetKey(key)
    if self._keyBox then
        self._keyBox.Text = tostring(key or "")
    end

    return self
end

function KeySystem:GetKey()
    return self._keyBox and self._keyBox.Text or ""
end

function KeySystem:SaveKey(key)
    return SaveFile(self.Config.Key.File, tostring(key or self:GetKey()))
end

function KeySystem:DeleteSavedKey()
    DeleteFile(self.Config.Key.File)

    if self._keyBox then
        self._keyBox.Text = ""
    end

    self:_Status(self.Config.Text.Deleted, self.Config.Theme.Warning, true)

    return self
end

function KeySystem:SetStatus(text, color)
    self:_Status(text, color or self.Config.Theme.TextMuted, true)
    return self
end

-- ════════════════════════════════════════════════════════
-- FADE TARGET HELPERS
-- ════════════════════════════════════════════════════════
function KeySystem:_Fade(obj, order)
    if not obj then return obj end

    local data = {
        Order = order or 0,
    }

    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        data.TextTransparency = obj.TextTransparency
    end

    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        data.ImageTransparency = obj.ImageTransparency
    end

    if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        data.BackgroundTransparency = obj.BackgroundTransparency
    end

    self._fadeTargets[obj] = data

    return obj
end

-- ════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ════════════════════════════════════════════════════════
function KeySystem.new(userConfig)
    local self = setmetatable({}, KeySystem)

    self.Config = NormalizeConfig(userConfig)
    self._buttons = {}
    self._tracked = {}
    self._fadeTargets = {}
    self._closed = false
    self._shown = false
    self._lucideLoaded = false
    self.ValidatedKey = nil

    local cfg = self.Config
    local th = cfg.Theme
    local wcfg = cfg.Window
    local bgcfg = wcfg.Background
    local shcfg = wcfg.Shadow

    -- Main ScreenGui
    local gui = New("ScreenGui", {
        Name = "KS_" .. HttpService:GenerateGUID(false):sub(1, 8),
        DisplayOrder = wcfg.DisplayOrder,
        IgnoreGuiInset = wcfg.IgnoreGuiInset,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    SafeParent(gui, wcfg.Parent)
    self._gui = gui

    local holder = New("Frame", {
        Name = "Holder",
        AnchorPoint = wcfg.AnchorPoint,
        BackgroundTransparency = 1,
        Position = wcfg.Center and UDim2.fromScale(0.5, 0.5) or wcfg.Position,
        Size = wcfg.Size,
        Visible = false,
        ZIndex = 10,
        Parent = gui,
    })

    self._holder = holder
    self._basePosition = holder.Position

    self._scale = New("UIScale", {
        Scale = wcfg.UIScale,
        Parent = holder,
    })

    -- Shadow follows draggable holder properly.
    if shcfg and shcfg.Enabled then
        local layers = math.clamp(shcfg.Layers or 5, 1, 8)
        local spread = shcfg.Size or 10
        local opacity = math.clamp(shcfg.Opacity or 0.48, 0, 1)

        for i = layers, 1, -1 do
            local frac = i / layers
            local expand = spread * frac
            local transparency = math.clamp(1 - opacity * (1 - frac * 0.72), 0, 1)

            local shadow = New("Frame", {
                Name = "ShadowLayer_" .. i,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = transparency,
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, expand * 2, 1, expand * 2),
                ZIndex = 10 - i,
                Parent = holder,
            })

            New("UICorner", {
                CornerRadius = UDim.new(0, wcfg.CornerRadius + expand),
                Parent = shadow,
            })
        end
    end

    -- Main window frame
    local frame = New("Frame", {
        Name = "Window",
        BackgroundColor3 = th.WindowBg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = wcfg.ClipsDescendants,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 20,
        Parent = holder,
    })

    self._frame = frame

    New("UICorner", {
        CornerRadius = UDim.new(0, wcfg.CornerRadius),
        Parent = frame,
    })

    self._windowStroke = New("UIStroke", {
        Color = th.Stroke,
        Thickness = wcfg.StrokeThickness,
        Transparency = 1,
        Parent = frame,
    })

    -- Custom window background
    if bgcfg and bgcfg.Enabled and bgcfg.Image and bgcfg.Image ~= "" then
        local bgImage = New("ImageLabel", {
            Name = "BackgroundImage",
            BackgroundTransparency = 1,
            Image = ToAsset(bgcfg.Image) or tostring(bgcfg.Image),
            ImageColor3 = bgcfg.Color,
            ImageTransparency = bgcfg.Transparency,
            ScaleType = bgcfg.ScaleType,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 20,
            Parent = frame,
        })

        local dim = New("Frame", {
            Name = "BackgroundDim",
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = math.clamp(1 - (bgcfg.DimAmount or 0.58), 0, 1),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 21,
            Parent = frame,
        })

        if bgcfg.Parallax then
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if not bgImage or not bgImage.Parent then return end

                local viewport = CurrentCamera() and CurrentCamera().ViewportSize or Vector2.new(1920, 1080)
                local x = (input.Position.X / viewport.X - 0.5) * bgcfg.ParallaxAmount
                local y = (input.Position.Y / viewport.Y - 0.5) * bgcfg.ParallaxAmount

                bgImage.Position = UDim2.fromScale(-x, -y)
                bgImage.Size = UDim2.fromScale(1 + bgcfg.ParallaxAmount * 2, 1 + bgcfg.ParallaxAmount * 2)
            end)
        end
    end

    -- Topbar
    local topbar = New("Frame", {
        Name = "Topbar",
        BackgroundColor3 = th.TopbarBg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52),
        ZIndex = 30,
        Parent = frame,
    })

    self._topbar = topbar

    New("UICorner", {
        CornerRadius = UDim.new(0, wcfg.CornerRadius),
        Parent = topbar,
    })

    New("Frame", {
        Name = "TopbarCover",
        BackgroundColor3 = th.TopbarBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -wcfg.CornerRadius),
        Size = UDim2.new(1, 0, 0, wcfg.CornerRadius),
        ZIndex = 31,
        Parent = topbar,
    })

    local accentBar = New("Frame", {
        Name = "AccentBar",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = th.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.new(0, 0, 0, 2),
        ZIndex = 35,
        Parent = topbar,
    })

    self._accentBar = accentBar

    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, th.Accent),
            ColorSequenceKeypoint.new(1, th.Accent2),
        }),
        Rotation = 0,
        Parent = accentBar,
    })

    local title = self:_Fade(New("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = th.FontBold,
        RichText = true,
        Text = cfg.Title,
        TextColor3 = th.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(18, 4),
        Size = UDim2.new(1, cfg.Buttons.ShowClose and -72 or -36, 0, 28),
        ZIndex = 34,
        Parent = topbar,
    }), 1)

    self:_Track(title, { TextColor = "TextPrimary" })

    local badge = self:_Fade(New("TextLabel", {
        Name = "Badge",
        BackgroundColor3 = th.ButtonBg,
        BackgroundTransparency = 0,
        Font = th.Font,
        RichText = true,
        Text = cfg.BadgeText,
        TextColor3 = th.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        Position = UDim2.fromOffset(18, 30),
        Size = UDim2.fromOffset(124, 17),
        ZIndex = 34,
        Parent = topbar,
    }), 2)

    self:_Track(badge, { TextColor = "TextMuted", BackgroundColor = "ButtonBg" })

    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = badge,
    })

    New("UIStroke", {
        Color = th.StrokeHover,
        Transparency = 0.58,
        Thickness = 1,
        Parent = badge,
    })

    -- Close button
    if cfg.Buttons.ShowClose then
        local closeBtn = New("TextButton", {
            Name = "CloseButton",
            AutoButtonColor = false,
            BackgroundColor3 = th.ButtonBg,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -44, 0.5, -15),
            Size = UDim2.fromOffset(30, 30),
            Text = "",
            ZIndex = 34,
            Parent = topbar,
        })

        New("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = closeBtn,
        })

        local closeIconData = self:_GetIcon(cfg.Buttons.CloseIcon)

        if closeIconData then
            local closeIcon = self:_Fade(New("ImageLabel", {
                Name = "CloseIcon",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = closeIconData.Url,
                ImageColor3 = th.TextMuted,
                ImageRectOffset = closeIconData.Offset,
                ImageRectSize = closeIconData.Size,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = 35,
                Parent = closeBtn,
            }), 3)

            self:_Track(closeIcon, { ImageColor = "TextMuted" })

            closeBtn.MouseEnter:Connect(function()
                Q(closeBtn, {
                    BackgroundTransparency = 0,
                }, 0.12)
                Q(closeIcon, {
                    ImageColor3 = th.Error,
                }, 0.12)
            end)

            closeBtn.MouseLeave:Connect(function()
                Q(closeBtn, {
                    BackgroundTransparency = 1,
                }, 0.12)
                Q(closeIcon, {
                    ImageColor3 = th.TextMuted,
                }, 0.12)
            end)
        else
            closeBtn.Text = "×"
            closeBtn.Font = th.FontBold
            closeBtn.TextColor3 = th.TextMuted
            closeBtn.TextSize = 18

            self:_Fade(closeBtn, 3)
        end

        closeBtn.MouseButton1Click:Connect(function()
            self:Close()
        end)
    end

    -- Panel
    local panel = New("Frame", {
        Name = "Panel",
        BackgroundColor3 = th.PanelBg,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 66),
        Size = UDim2.new(1, -28, 1, -82),
        ZIndex = 30,
        Parent = frame,
    })

    self._panel = panel

    New("UICorner", {
        CornerRadius = UDim.new(0, math.max(6, wcfg.CornerRadius - 4)),
        Parent = panel,
    })

    self._panelStroke = New("UIStroke", {
        Color = th.StrokeSoft,
        Thickness = 1,
        Transparency = 1,
        Parent = panel,
    })

    New("UIPadding", {
        PaddingTop = UDim.new(0, 18),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18),
        Parent = panel,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 11),
        Parent = panel,
    })

    local desc = self:_Fade(New("TextLabel", {
        Name = "Description",
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Font = th.Font,
        RichText = true,
        Text = cfg.Description,
        TextColor3 = th.TextMuted,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, 0, 0, 32),
        ZIndex = 32,
        Parent = panel,
    }), 4)

    self:_Track(desc, { TextColor = "TextMuted" })

    local divider = self:_Fade(New("Frame", {
        Name = "Divider",
        LayoutOrder = 2,
        BackgroundColor3 = th.Stroke,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 32,
        Parent = panel,
    }), 5)

    self:_Track(divider, { BackgroundColor = "Stroke" })

    local keyLabel = self:_Fade(New("TextLabel", {
        Name = "KeyLabel",
        LayoutOrder = 3,
        BackgroundTransparency = 1,
        Font = th.FontBold,
        Text = "ACCESS KEY",
        TextColor3 = th.TextMuted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 12),
        ZIndex = 32,
        Parent = panel,
    }), 6)

    self:_Track(keyLabel, { TextColor = "TextMuted" })

    local keyOuter = New("Frame", {
        Name = "KeyOuter",
        LayoutOrder = 4,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, cfg.Key.Height),
        ZIndex = 32,
        Parent = panel,
    })

    self._keyBox = self:_Fade(New("TextBox", {
        Name = "KeyBox",
        BackgroundColor3 = th.InputBg,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Font = th.FontCode,
        PlaceholderText = cfg.Key.Placeholder,
        PlaceholderColor3 = th.TextMuted,
        Text = "",
        TextColor3 = th.TextPrimary,
        TextSize = 14,
        TextTransparency = cfg.Key.HideText and 1 or 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 33,
        Parent = keyOuter,
    }), 7)

    self:_Track(self._keyBox, { TextColor = "TextPrimary", BackgroundColor = "InputBg" })

    New("UICorner", {
        CornerRadius = UDim.new(0, math.max(6, wcfg.CornerRadius - 6)),
        Parent = self._keyBox,
    })

    self._keyStroke = New("UIStroke", {
        Color = th.Stroke,
        Thickness = 1,
        Parent = self._keyBox,
    })

    New("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = self._keyBox,
    })

    self._keyBox.Focused:Connect(function()
        Back(self._keyBox, {
            Size = UDim2.new(1, 0, 1, 2),
        }, 0.18)

        Q(self._keyStroke, {
            Color = th.StrokeHover,
            Thickness = 2,
        }, 0.12)
    end)

    self._keyBox.FocusLost:Connect(function(enter)
        Back(self._keyBox, {
            Size = UDim2.fromScale(1, 1),
        }, 0.18)

        Q(self._keyStroke, {
            Color = th.Stroke,
            Thickness = 1,
        }, 0.12)

        if enter and cfg.Key.SubmitOnEnter then
            self:_Verify(self._keyBox.Text, false)
        end
    end)

    self._statusLabel = self:_Fade(New("TextLabel", {
        Name = "Status",
        LayoutOrder = 5,
        BackgroundTransparency = 1,
        Font = th.Font,
        RichText = true,
        Text = "",
        TextColor3 = th.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 16),
        ZIndex = 32,
        Parent = panel,
    }), 8)

    self:_Track(self._statusLabel, { TextColor = "TextMuted" })

    self._btnHolder = New("Frame", {
        Name = "Buttons",
        LayoutOrder = 6,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 32,
        Parent = panel,
    })

    local btnList = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, cfg.Buttons.Gap),
        Parent = self._btnHolder,
    })

    btnList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self._btnHolder.Size = UDim2.new(1, 0, 0, btnList.AbsoluteContentSize.Y)
    end)

    self:_MakeButton({
        Name = "Verify",
        Text = cfg.Buttons.MainText,
        Icon = cfg.Buttons.MainIcon,
        Accent = true,
        Order = 1,
        Callback = function()
            self:_Verify(self._keyBox.Text, false)
        end,
    })

    if cfg.Buttons.ShowGetKey then
        self:_MakeButton({
            Name = "GetKey",
            Text = cfg.Buttons.GetKeyText,
            Icon = cfg.Buttons.GetKeyIcon,
            Order = 2,
            Callback = function()
                local link = cfg.Links.Key

                if link ~= "" and setclipboard then
                    setclipboard(link)
                    self:_Status(cfg.Text.Copied, th.Success, true)
                elseif link ~= "" then
                    self:_Status(link, th.Warning, true)
                else
                    self:_Status(cfg.Text.NoKeyLink, th.Warning, true)
                end
            end,
        })
    end

    if cfg.Buttons.ShowDiscord then
        self:_MakeButton({
            Name = "Discord",
            Text = cfg.Buttons.DiscordText,
            Icon = cfg.Buttons.DiscordIcon,
            Order = 3,
            Callback = function()
                local discord = cfg.Links.Discord

                if discord ~= "" and setclipboard then
                    setclipboard(discord)
                    self:_Status(cfg.Text.Copied, th.Success, true)
                elseif discord ~= "" then
                    self:_Status(discord, th.Warning, true)
                else
                    self:_Status(cfg.Text.NoDiscord, th.Warning, true)
                end
            end,
        })
    end

    if cfg.Buttons.ShowDeleteKey then
        self:_MakeButton({
            Name = "DeleteKey",
            Text = cfg.Buttons.DeleteKeyText,
            Icon = cfg.Buttons.DeleteKeyIcon,
            Order = 4,
            Callback = function()
                self:DeleteSavedKey()
            end,
        })
    end

    task.defer(function()
        self._btnHolder.Size = UDim2.new(1, 0, 0, btnList.AbsoluteContentSize.Y)
    end)

    local footer = self:_Fade(New("TextLabel", {
        Name = "Footer",
        LayoutOrder = 7,
        BackgroundTransparency = 1,
        Font = th.Font,
        RichText = true,
        Text = cfg.Footer,
        TextColor3 = th.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.new(1, 0, 0, 14),
        ZIndex = 32,
        Parent = panel,
    }), 25)

    self:_Track(footer, { TextColor = "TextMuted" })

    self:_SetupDrag()

    local saved = cfg.Key.AutoLoad and ReadFile(cfg.Key.File)

    if saved and saved ~= "" then
        self._keyBox.Text = saved
        self:_Status(cfg.Text.Loaded, th.TextMuted, true)

        if cfg.Key.AutoCheck then
            task.defer(function()
                self:_Verify(saved, true)
            end)
        end
    else
        self:_Status(cfg.Footer or "", th.TextMuted, false)
    end

    self:Show()

    return self
end

KeySystem.Create = KeySystem.new

return KeySystem
