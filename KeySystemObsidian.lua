--[[
	KeySystem UI v2
	Loadstring compatible: loadstring(game:HttpGet(url))()
	
	Example usage:
	
	local KeySystem = loadstring(game:HttpGet("YOUR_RAW_URL"))()
	
	local ui = KeySystem.new({
		Title = "My Game",
		Description = "Enter your key below to access the script.",
		Footer = "discord.gg/yourserver",
		Links = {
			Key = "https://your-key-link.com",
			Discord = "discord.gg/yourserver",
		},
		VerifyKey = function(key)
			return key == "my-key-here"
		end,
		OnSuccess = function(key, ui)
			ui:Close()
			-- load your script here
		end,
	})
--]]

local cloneref = cloneref or clonereference or function(v) return v end
local Players         = cloneref(game:GetService("Players"))
local TweenService    = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService     = cloneref(game:GetService("HttpService"))
local TextService     = cloneref(game:GetService("TextService"))
local CoreGui         = cloneref(game:GetService("CoreGui"))
local SoundService    = cloneref(game:GetService("SoundService"))
local RunService      = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local protectgui  = protectgui or (syn and syn.protect_gui) or function() end
local gethui      = gethui or function() return CoreGui end
local setclipboard = setclipboard or nil

-- ─── Tween helpers ────────────────────────────────────────────────────────────

local function Tween(obj, info, props)
	if not obj or not obj.Parent then return end
	local ok, t = pcall(TweenService.Create, TweenService, obj, info, props)
	if ok and t then t:Play() return t end
end

local function Spring(obj, props, t, s, d)
	return Tween(obj, TweenInfo.new(t or 0.35, Enum.EasingStyle.Spring, Enum.EasingDirection.Out, 0, false, 0), props)
end

local function Quad(obj, props, t, dir)
	return Tween(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function Back(obj, props, t)
	return Tween(obj, TweenInfo.new(t or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

-- ─── Audio muffling ───────────────────────────────────────────────────────────

local AudioManager = {}
do
	local EQ_TAG = "KeySystemEQ"
	local storedProps = {}

	local function getAllSounds()
		local sounds = {}
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Sound") and v.Playing then
				table.insert(sounds, v)
			end
		end
		for _, v in ipairs(SoundService:GetDescendants()) do
			if v:IsA("Sound") and v.Playing then
				table.insert(sounds, v)
			end
		end
		return sounds
	end

	function AudioManager.Muffle()
		storedProps = {}
		local sounds = getAllSounds()
		for _, snd in ipairs(sounds) do
			if not snd:FindFirstChild(EQ_TAG) then
				storedProps[snd] = { Volume = snd.Volume }

				-- Add EqualizerSoundEffect to cut highs (muffle effect)
				local eq = Instance.new("EqualizerSoundEffect")
				eq.Name = EQ_TAG
				eq.HighGain  = -18
				eq.MidGain   = -6
				eq.LowGain   = -3
				eq.Parent    = snd

				-- Softly reduce volume
				Quad(snd, { Volume = snd.Volume * 0.45 }, 0.5)
			end
		end
	end

	function AudioManager.Unmuffle()
		for snd, props in pairs(storedProps) do
			if snd and snd.Parent then
				Quad(snd, { Volume = props.Volume }, 0.4)
				task.delay(0.4, function()
					local eq = snd:FindFirstChild(EQ_TAG)
					if eq then eq:Destroy() end
				end)
			end
		end
		storedProps = {}
	end
end

-- ─── Utilities ────────────────────────────────────────────────────────────────

local function New(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = obj
	end
	return obj
end

local function DeepMerge(base, given)
	local out = {}
	for k, v in pairs(base or {}) do
		if typeof(v) == "table" and typeof((given or {})[k]) == "table" then
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
	if not v or v == "" then return nil end
	if typeof(v) == "number" then return "rbxassetid://" .. v end
	if typeof(v) ~= "string" then return nil end
	if v:match("^rbxassetid://") or v:match("^rbxthumb://") or v:match("roblox%.com/asset") then return v end
	if tonumber(v) then return "rbxassetid://" .. v end
	return nil
end

local function MakeFolderPath(path)
	if not (isfolder and makefolder and path) then return end
	local parts = string.split(path, "/")
	local cur = ""
	for i = 1, #parts - 1 do
		cur ..= parts[i]
		if cur ~= "" and not isfolder(cur) then pcall(makefolder, cur) end
		cur ..= "/"
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
	return ok and data or nil
end

local function DeleteFile(path)
	if not (path and path ~= "") then return false end
	if delfile and isfile and isfile(path) then return pcall(delfile, path) end
	if writefile and isfile and isfile(path) then return pcall(writefile, path, "") end
	return false
end

local function BetterColor(c, amt)
	return Color3.fromRGB(
		math.clamp(c.R * 255 + amt, 0, 255),
		math.clamp(c.G * 255 + amt, 0, 255),
		math.clamp(c.B * 255 + amt, 0, 255)
	)
end

local function TextBounds(text, font, size)
	local p = Instance.new("GetTextBoundsParams")
	p.Text = tostring(text or "")
	p.RichText = true
	p.Font = typeof(font) == "Font" and font or Font.fromEnum(font or Enum.Font.Code)
	p.Size = size or 16
	p.Width = 10000
	local ok, r = pcall(function() return TextService:GetTextBoundsAsync(p) end)
	return ok and r or Vector2.new(#tostring(text or "") * (size or 16) * 0.55, size or 16)
end

-- ─── Default Config ───────────────────────────────────────────────────────────

local KeySystem = {}
KeySystem.__index = KeySystem

KeySystem.DefaultConfig = {
	Title       = "Key System",
	Description = "Enter your key to continue.",
	Footer      = "Powered by KeySystem",

	Window = {
		Size             = UDim2.fromOffset(520, 390),
		Position         = UDim2.fromScale(0.5, 0.5),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Center           = true,
		Draggable        = true,
		CornerRadius     = 12,
		StrokeThickness  = 1,
		DisplayOrder     = 999,
		Parent           = nil,
		IgnoreGuiInset   = true,
		AutoScale        = true,
		UIScale          = 1,
		ClipsDescendants = true,
		MuffleAudio      = true,   -- blur background audio while open
	},

	Background = {
		Image               = "",
		ImageTransparency   = 0.12,
		ImageColor          = Color3.fromRGB(255, 255, 255),
		ScaleType           = Enum.ScaleType.Crop,
		Dim                 = 0.42,
		ContentTransparency = 0.04,
	},

	Key = {
		File                 = "KeySystem/saved_key.txt",
		Save                 = true,
		AutoLoad             = true,
		AutoCheck            = false,
		AutoDeleteInvalid    = true,
		ClearInputWhenInvalid = false,
		Placeholder          = "Paste key here...",
		Height               = 42,
		ClearTextOnFocus     = false,
		HideText             = false,
		SubmitOnEnter        = true,
		Trim                 = true,
	},

	Buttons = {
		Height       = 38,
		Gap          = 8,
		Icons        = true,
		IconSide     = "Right",
		IconSize     = 18,
		IconGap      = 8,
		IconColor    = nil,
		LucideURL    = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",

		MainText      = "Verify Key",
		MainIcon      = "key-round",
		GetKeyText    = "Get Key",
		GetKeyIcon    = "external-link",
		DiscordText   = "Copy Discord",
		DiscordIcon   = "copy",
		DeleteKeyText = "Delete Saved Key",
		DeleteKeyIcon = "trash-2",
		CloseIcon     = "x",

		ShowGetKey    = true,
		ShowDiscord   = true,
		ShowDeleteKey = true,
		ShowClose     = true,
	},

	Links = {
		Key     = "",
		Discord = "",
	},

	Tween = {
		Time      = 0.18,
		Style     = Enum.EasingStyle.Quad,
		Direction = Enum.EasingDirection.Out,
		OpenTime  = 0.42,  -- spring open
		CloseTime = 0.2,
	},

	Text = {
		Success   = "Key verified successfully.",
		Invalid   = "Invalid key.",
		Checking  = "Checking key...",
		Loaded    = "Loaded saved key.",
		Deleted   = "Saved key deleted.",
		Copied    = "Copied to clipboard.",
		CopyFail  = "Clipboard not supported.",
		NoKeyLink = "No key link configured.",
		NoDiscord = "No Discord configured.",
		EnterKey  = "Enter a key first.",
	},

	Theme = {
		BackgroundColor  = Color3.fromRGB(12, 12, 16),
		TopbarColor      = Color3.fromRGB(20, 20, 26),
		ContentColor     = Color3.fromRGB(20, 20, 26),
		SecondColor      = Color3.fromRGB(28, 28, 36),
		AccentColor      = Color3.fromRGB(120, 80, 255),
		AccentHoverColor = Color3.fromRGB(140, 100, 255),
		ButtonHoverColor = nil,
		OutlineColor     = Color3.fromRGB(48, 48, 62),
		FontColor        = Color3.fromRGB(240, 240, 248),
		MutedFontColor   = Color3.fromRGB(160, 160, 180),
		ErrorColor       = Color3.fromRGB(255, 65, 65),
		SuccessColor     = Color3.fromRGB(60, 220, 140),
		WarningColor     = Color3.fromRGB(255, 185, 60),
		ButtonTextColor  = Color3.fromRGB(255, 255, 255),
		Font             = Enum.Font.Code,
	},

	HoverTheme = {
		ButtonBackgroundColor = nil,
		ButtonTextColor       = nil,
		ButtonIconColor       = nil,
		OutlineColor          = nil,
		CloseBackgroundColor  = nil,
		CloseIconColor        = nil,
		KeyStrokeColor        = nil,
	},

	VerifyKey = function(key)
		return key == "test-key"
	end,

	OnSuccess = function(key, ui) end,
	OnInvalid = function(key, ui) end,
	OnClose   = function(ui) end,
}

-- ─── Config merging ───────────────────────────────────────────────────────────

local function GetRootConfig(config)
	config = config or {}
	if config.Window or config.Key or config.Buttons or config.Background then
		return DeepMerge(KeySystem.DefaultConfig, config)
	end

	-- flat legacy key mapping
	local c = table.clone(config)
	c.Window     = { Size = config.Size, Position = config.Position, AnchorPoint = config.AnchorPoint, Center = config.Center, Draggable = config.Draggable, CornerRadius = config.CornerRadius, StrokeThickness = config.StrokeThickness, DisplayOrder = config.DisplayOrder, Parent = config.Parent, MuffleAudio = config.MuffleAudio }
	c.Background = { Image = config.BackgroundImage, ImageTransparency = config.BackgroundImageTransparency, ImageColor = config.BackgroundImageColor, ScaleType = config.BackgroundScaleType, Dim = config.BackgroundDim }
	c.Key        = { File = config.KeyFile, Save = config.SaveKey, AutoLoad = config.AutoLoadSavedKey, AutoCheck = config.AutoCheckSavedKey, AutoDeleteInvalid = config.AutoDeleteInvalidKey, ClearInputWhenInvalid = config.ClearInputWhenInvalid, Placeholder = config.KeyPlaceholder, Height = config.KeyBoxHeight, ClearTextOnFocus = config.KeyBoxClearTextOnFocus, HideText = config.HideKeyText }
	c.Buttons    = { Icons = config.ButtonIcons, IconSide = config.IconSide, IconSize = config.IconSize, IconGap = config.IconGap, IconColor = config.IconColor, LucideURL = config.LucideURL, MainText = config.MainButtonText, MainIcon = config.MainButtonIcon, GetKeyText = config.GetKeyButtonText, GetKeyIcon = config.GetKeyButtonIcon, DiscordText = config.CopyDiscordButtonText, DiscordIcon = config.CopyDiscordButtonIcon, DeleteKeyText = config.DeleteKeyButtonText, DeleteKeyIcon = config.DeleteKeyButtonIcon, CloseIcon = config.CloseButtonIcon, ShowGetKey = config.ShowGetKeyButton, ShowDiscord = config.ShowDiscordButton, ShowDeleteKey = config.ShowDeleteKeyButton, ShowClose = config.ShowCloseButton, Height = config.ButtonHeight, Gap = config.ButtonGap }
	c.Links      = { Key = config.KeyLink, Discord = config.Discord }
	c.Tween      = { Time = config.TweenTime, Style = config.TweenStyle, Direction = config.TweenDirection }
	c.Text       = { Success = config.StatusSuccess, Invalid = config.StatusInvalid, Checking = config.StatusChecking, Loaded = config.StatusLoaded, Deleted = config.StatusDeleted, Copied = config.StatusCopied, CopyFail = config.StatusCopyFail }

	return DeepMerge(KeySystem.DefaultConfig, c)
end

-- ─── Lucide icons ─────────────────────────────────────────────────────────────

function KeySystem:_LoadLucide()
	if self.LucideLoaded then return end
	self.LucideLoaded = true
	local url = self.Config.Buttons.LucideURL
	if not url or url == "" then return end
	local ok, mod = pcall(function() return loadstring(game:HttpGet(url))() end)
	if ok and typeof(mod) == "table" and typeof(mod.GetAsset) == "function" then
		self.LucideIcons = mod
	end
end

function KeySystem:_GetIcon(icon)
	local asset = ToAsset(icon)
	if asset then return { Url = asset, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero } end
	if typeof(icon) == "string" and icon ~= "" then
		self:_LoadLucide()
		if self.LucideIcons then
			local ok, data = pcall(self.LucideIcons.GetAsset, icon)
			if ok and data then return data end
		end
	end
	return nil
end

-- ─── Status / strobe helpers ──────────────────────────────────────────────────

function KeySystem:_SetStatus(text, color, flash)
	if not self.StatusLabel then return end
	self.StatusLabel.Text = text or ""
	self.StatusLabel.TextColor3 = color or self.Config.Theme.MutedFontColor
	if flash then
		self.StatusLabel.TextTransparency = 1
		Quad(self.StatusLabel, { TextTransparency = 0 }, 0.22)
	end
end

function KeySystem:_PulseStroke(color)
	if not self.MainStroke then return end
	Quad(self.MainStroke, { Color = color }, 0.12)
	task.delay(0.35, function()
		if self.MainStroke then
			Quad(self.MainStroke, { Color = self.Config.Theme.OutlineColor }, 0.25)
		end
	end)
end

-- ─── Button theming ───────────────────────────────────────────────────────────

function KeySystem:_RefreshButtonTheme(button, hovering)
	local cfg   = self.Config
	local theme = cfg.Theme
	local hover = cfg.HoverTheme or {}
	local isAccent = button:GetAttribute("IsAccent") == true

	local normalBg = isAccent and theme.AccentColor or theme.SecondColor
	local hoverBg  = hover.ButtonBackgroundColor or theme.ButtonHoverColor
		or (isAccent and theme.AccentHoverColor or BetterColor(theme.SecondColor, 14))
	local textColor  = theme.ButtonTextColor
	local iconColor  = cfg.Buttons.IconColor or theme.ButtonTextColor
	local outline    = hovering and (hover.OutlineColor or theme.AccentColor) or theme.OutlineColor

	Quad(button, { BackgroundColor3 = hovering and hoverBg or normalBg }, 0.14)

	local label = button:FindFirstChild("Label", true)
	if label then
		Quad(label, { TextColor3 = textColor, TextTransparency = hovering and 0 or 0.05 }, 0.14)
	end

	local icon = button:FindFirstChild("Icon", true)
	if icon then
		Quad(icon, { ImageColor3 = iconColor, ImageTransparency = 0 }, 0.14)
	end

	local stroke = button:FindFirstChildOfClass("UIStroke")
	if stroke then
		Quad(stroke, { Color = outline }, 0.14)
	end
end

-- ─── Button factory ───────────────────────────────────────────────────────────

function KeySystem:_CreateButton(info)
	local cfg   = self.Config
	local theme = cfg.Theme

	local button = New("TextButton", {
		Name             = info.Name or "Button",
		AutoButtonColor  = false,
		BackgroundColor3 = info.Accent and theme.AccentColor or theme.SecondColor,
		BorderSizePixel  = 0,
		LayoutOrder      = info.LayoutOrder or 1,
		Size             = UDim2.new(1, 0, 0, cfg.Buttons.Height),
		Text             = "",
		ZIndex           = 8,
	})
	button:SetAttribute("IsAccent", info.Accent and true or false)
	button.Parent = self.ButtonHolder

	New("UICorner",   { CornerRadius = UDim.new(0, math.max(4, cfg.Window.CornerRadius - 4)), Parent = button })
	New("UIStroke",   { Color = theme.OutlineColor, Thickness = 1, Parent = button })

	local center = New("Frame", {
		Name                = "Center",
		AnchorPoint         = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position            = UDim2.fromScale(0.5, 0.5),
		Size                = UDim2.fromOffset(20, cfg.Buttons.Height),
		ZIndex              = 9,
		Parent              = button,
	})
	New("UIListLayout", {
		FillDirection       = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment   = Enum.VerticalAlignment.Center,
		SortOrder           = Enum.SortOrder.LayoutOrder,
		Padding             = UDim.new(0, cfg.Buttons.IconGap),
		Parent              = center,
	})

	local iconData = cfg.Buttons.Icons and self:_GetIcon(info.Icon)
	local icon

	local label = New("TextLabel", {
		Name              = "Label",
		AutomaticSize     = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font              = theme.Font,
		RichText          = true,
		Text              = info.Text or "Button",
		TextColor3        = theme.ButtonTextColor,
		TextSize          = 15,
		TextTransparency  = 0.05,
		TextXAlignment    = Enum.TextXAlignment.Center,
		TextYAlignment    = Enum.TextYAlignment.Center,
		Size              = UDim2.fromOffset(0, cfg.Buttons.Height),
		ZIndex            = 10,
		Parent            = center,
	})

	if iconData then
		icon = New("ImageLabel", {
			Name              = "Icon",
			BackgroundTransparency = 1,
			Image             = iconData.Url,
			ImageColor3       = cfg.Buttons.IconColor or theme.ButtonTextColor,
			ImageRectOffset   = iconData.ImageRectOffset or Vector2.zero,
			ImageRectSize     = iconData.ImageRectSize  or Vector2.zero,
			Size              = UDim2.fromOffset(cfg.Buttons.IconSize, cfg.Buttons.IconSize),
			ZIndex            = 10,
			Parent            = center,
		})
		if cfg.Buttons.IconSide == "Left" then
			icon.LayoutOrder = 1; label.LayoutOrder = 2
		else
			label.LayoutOrder = 1; icon.LayoutOrder = 2
		end
	end

	local function resize()
		local bounds = TextBounds(label.Text:gsub("<.->", ""), theme.Font, label.TextSize)
		local width  = math.ceil(bounds.X + 6)
		if icon then width += cfg.Buttons.IconSize + cfg.Buttons.IconGap end
		center.Size = UDim2.fromOffset(width, cfg.Buttons.Height)
	end
	resize()
	label:GetPropertyChangedSignal("Text"):Connect(resize)

	-- Hover / press interactions
	button.MouseEnter:Connect(function()
		self:_RefreshButtonTheme(button, true)
	end)
	button.MouseLeave:Connect(function()
		self:_RefreshButtonTheme(button, false)
	end)

	-- Press squish
	button.MouseButton1Down:Connect(function()
		Spring(button, { Size = UDim2.new(1, -6, 0, cfg.Buttons.Height - 2) }, 0.12)
	end)
	button.MouseButton1Up:Connect(function()
		Spring(button, { Size = UDim2.new(1, 0, 0, cfg.Buttons.Height) }, 0.28)
	end)
	button.MouseButton1Click:Connect(function()
		if typeof(info.Callback) == "function" then
			info.Callback()
		end
	end)

	table.insert(self.ButtonList, button)
	return button
end

-- ─── Verify logic ─────────────────────────────────────────────────────────────

function KeySystem:_Verify(key, fromSaved)
	key = tostring(key or self.KeyBox.Text or "")
	if self.Config.Key.Trim then key = key:match("^%s*(.-)%s*$") end

	if key == "" then
		self:_SetStatus(self.Config.Text.EnterKey, self.Config.Theme.WarningColor, true)
		-- shake the key box
		if self.KeyBox then
			local orig = self.KeyBox.Position
			for i = 1, 3 do
				task.delay(i * 0.06, function()
					local off = (i % 2 == 0) and 6 or -6
					Quad(self.KeyBox, { Position = UDim2.new(orig.X.Scale, off, orig.Y.Scale, orig.Y.Offset) }, 0.05)
					task.delay(0.05, function()
						Quad(self.KeyBox, { Position = orig }, 0.05)
					end)
				end)
			end
		end
		return false
	end

	self:_SetStatus(self.Config.Text.Checking, self.Config.Theme.WarningColor, true)

	-- Spin the verify button icon while checking
	local verifyBtn = self.ButtonList[1]
	local btnIcon   = verifyBtn and verifyBtn:FindFirstChild("Icon", true)
	local spinConn
	if btnIcon then
		local angle = 0
		spinConn = RunService.RenderStepped:Connect(function(dt)
			angle = (angle + dt * 300) % 360
			btnIcon.Rotation = angle
		end)
	end

	local ok, valid, message = pcall(self.Config.VerifyKey, key, self)
	valid = ok and valid == true

	if spinConn then spinConn:Disconnect() end
	if btnIcon then btnIcon.Rotation = 0 end

	if valid then
		self.ValidatedKey = key
		if self.Config.Key.Save then SaveFile(self.Config.Key.File, key) end
		self:_SetStatus(message or self.Config.Text.Success, self.Config.Theme.SuccessColor, true)
		self:_PulseStroke(self.Config.Theme.SuccessColor)
		-- Glow the content border green briefly
		if self.ContentStroke then
			Quad(self.ContentStroke, { Color = self.Config.Theme.SuccessColor }, 0.15)
			task.delay(0.5, function()
				if self.ContentStroke then Quad(self.ContentStroke, { Color = self.Config.Theme.OutlineColor }, 0.3) end
			end)
		end
		task.spawn(self.Config.OnSuccess, key, self)
		return true
	end

	if self.Config.Key.AutoDeleteInvalid then DeleteFile(self.Config.Key.File) end
	if self.Config.Key.ClearInputWhenInvalid and not fromSaved then self.KeyBox.Text = "" end
	self:_SetStatus(message or self.Config.Text.Invalid, self.Config.Theme.ErrorColor, true)
	self:_PulseStroke(self.Config.Theme.ErrorColor)
	task.spawn(self.Config.OnInvalid, key, self)
	return false
end

-- ─── Public API ───────────────────────────────────────────────────────────────

function KeySystem:Verify(key)    return self:_Verify(key or self.KeyBox.Text, false) end
function KeySystem:SetKey(key)    self.KeyBox.Text = tostring(key or "") return self end
function KeySystem:GetKey()       return self.KeyBox.Text end
function KeySystem:SaveKey(key)   return SaveFile(self.Config.Key.File, tostring(key or self.KeyBox.Text or "")) end

function KeySystem:DeleteSavedKey()
	DeleteFile(self.Config.Key.File)
	self:_SetStatus(self.Config.Text.Deleted, self.Config.Theme.WarningColor, true)
	return self
end

function KeySystem:SetStatus(text, color)
	self:_SetStatus(text, color or self.Config.Theme.MutedFontColor, true)
	return self
end

function KeySystem:SetTheme(theme)
	self.Config.Theme = DeepMerge(self.Config.Theme, theme or {})
	local t = self.Config.Theme
	if self.MainFrame     then self.MainFrame.BackgroundColor3    = t.BackgroundColor end
	if self.Topbar        then self.Topbar.BackgroundColor3       = t.TopbarColor end
	if self.TopbarCover   then self.TopbarCover.BackgroundColor3  = t.TopbarColor end
	if self.Content       then self.Content.BackgroundColor3      = t.ContentColor end
	if self.TitleLabel    then self.TitleLabel.TextColor3         = t.FontColor end
	if self.DescLabel     then self.DescLabel.TextColor3          = t.MutedFontColor end
	if self.FooterLabel   then self.FooterLabel.TextColor3        = t.MutedFontColor end
	if self.StatusLabel   then self.StatusLabel.TextColor3        = t.MutedFontColor end
	if self.KeyBox        then self.KeyBox.BackgroundColor3 = t.SecondColor; self.KeyBox.TextColor3 = t.FontColor; self.KeyBox.PlaceholderColor3 = t.MutedFontColor end
	if self.MainStroke    then self.MainStroke.Color               = t.OutlineColor end
	if self.ContentStroke then self.ContentStroke.Color            = t.OutlineColor end
	if self.KeyStroke     then self.KeyStroke.Color                = t.OutlineColor end
	for _, btn in ipairs(self.ButtonList or {}) do self:_RefreshButtonTheme(btn, false) end
	return self
end

function KeySystem:SetHoverTheme(theme)
	self.Config.HoverTheme = DeepMerge(self.Config.HoverTheme, theme or {})
	return self
end

function KeySystem:Show()
	if not self.MainFrame then return self end
	self.MainFrame.Visible = true

	local target = self.Config.Window.Size
	local startW = math.max(1, target.X.Offset * 0.88)
	local startH = math.max(1, target.Y.Offset * 0.88)
	self.MainFrame.Size = UDim2.fromOffset(startW, startH)
	self.MainFrame.BackgroundTransparency = 1

	-- Spring pop-in
	Back(self.MainFrame, { Size = target, BackgroundTransparency = 0 }, self.Config.Tween.OpenTime)

	-- Stagger the content children in
	task.delay(0.08, function()
		if self.Content then
			for i, child in ipairs(self.Content:GetChildren()) do
				if child:IsA("GuiObject") then
					child.BackgroundTransparency = child.BackgroundTransparency == 0 and 0 or child.BackgroundTransparency
					local origTrans = child:GetAttribute("OrigTransparency") or 0
					Quad(child, {}, 0) -- force property read
					task.delay((i - 1) * 0.04, function()
						Quad(child, { Position = child.Position }, 0.01)
					end)
				end
			end
		end
	end)

	if self.Config.Window.MuffleAudio then
		AudioManager.Muffle()
	end

	return self
end

function KeySystem:Hide()
	if self.MainFrame then self.MainFrame.Visible = false end
	return self
end

function KeySystem:Close()
	if self.Closed then return end
	self.Closed = true

	task.spawn(self.Config.OnClose, self)
	if self.DragConnection then self.DragConnection:Disconnect() end

	if self.Config.Window.MuffleAudio then
		AudioManager.Unmuffle()
	end

	if self.MainFrame then
		local w = math.max(1, self.MainFrame.AbsoluteSize.X * 0.94)
		local h = math.max(1, self.MainFrame.AbsoluteSize.Y * 0.94)
		Quad(self.MainFrame, { Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1 }, self.Config.Tween.CloseTime)
	end

	task.delay(self.Config.Tween.CloseTime + 0.04, function()
		if self.ScreenGui then self.ScreenGui:Destroy() end
	end)
end

function KeySystem:Destroy()
	if self.ScreenGui then self.ScreenGui:Destroy() end
end

-- ─── Dragging ─────────────────────────────────────────────────────────────────

function KeySystem:_SetupDragging()
	if not self.Config.Window.Draggable then return end

	local dragging, startPos, framePos, releaseConn = false, nil, nil, nil

	self.Topbar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
		   and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging  = true
		startPos  = input.Position
		framePos  = self.MainFrame.Position
		if releaseConn then releaseConn:Disconnect() end
		releaseConn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if releaseConn then releaseConn:Disconnect(); releaseConn = nil end
			end
		end)
	end)

	self.DragConnection = UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
		   and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - startPos
		self.MainFrame.Position = UDim2.new(
			framePos.X.Scale, framePos.X.Offset + delta.X,
			framePos.Y.Scale, framePos.Y.Offset + delta.Y
		)
	end)
end

-- ─── Constructor ──────────────────────────────────────────────────────────────

function KeySystem.new(config)
	local self = setmetatable({}, KeySystem)

	self.Config     = GetRootConfig(config)
	self.ButtonList = {}
	self.TweenInfo  = TweenInfo.new(self.Config.Tween.Time, self.Config.Tween.Style, self.Config.Tween.Direction)

	local cfg   = self.Config
	local theme = cfg.Theme

	local gui = New("ScreenGui", {
		Name             = "KeySystemUI_" .. HttpService:GenerateGUID(false),
		DisplayOrder     = cfg.Window.DisplayOrder,
		IgnoreGuiInset   = cfg.Window.IgnoreGuiInset,
		ResetOnSpawn     = false,
		ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
	})
	pcall(protectgui, gui)
	local parent = cfg.Window.Parent or gethui()
	local ok = pcall(function() gui.Parent = parent end)
	if not ok or not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	self.ScreenGui = gui

	-- Main window frame
	local frame = New("Frame", {
		Name                 = "Window",
		AnchorPoint          = cfg.Window.AnchorPoint,
		BackgroundColor3     = theme.BackgroundColor,
		BackgroundTransparency = 1,
		BorderSizePixel      = 0,
		ClipsDescendants     = cfg.Window.ClipsDescendants,
		Position             = cfg.Window.Center and UDim2.fromScale(0.5, 0.5) or cfg.Window.Position,
		Size                 = cfg.Window.Size,
		Visible              = true,
		ZIndex               = 1,
		Parent               = gui,
	})
	self.MainFrame = frame

	if cfg.Window.AutoScale then New("UIScale", { Scale = cfg.Window.UIScale, Parent = frame }) end
	New("UICorner", { CornerRadius = UDim.new(0, cfg.Window.CornerRadius), Parent = frame })
	self.MainStroke = New("UIStroke", { Color = theme.OutlineColor, Thickness = cfg.Window.StrokeThickness, Parent = frame })

	-- Optional background image
	if cfg.Background.Image and cfg.Background.Image ~= "" then
		New("ImageLabel", {
			Name               = "BackgroundImage",
			BackgroundTransparency = 1,
			Image              = ToAsset(cfg.Background.Image) or cfg.Background.Image,
			ImageTransparency  = cfg.Background.ImageTransparency,
			ImageColor3        = cfg.Background.ImageColor,
			ScaleType          = cfg.Background.ScaleType,
			Size               = UDim2.fromScale(1, 1),
			ZIndex             = 1,
			Parent             = frame,
		})
		New("Frame", {
			Name                 = "BackgroundDim",
			BackgroundColor3     = theme.BackgroundColor,
			BackgroundTransparency = math.clamp(1 - cfg.Background.Dim, 0, 1),
			BorderSizePixel      = 0,
			Size                 = UDim2.fromScale(1, 1),
			ZIndex               = 2,
			Parent               = frame,
		})
	end

	-- Topbar
	self.Topbar = New("Frame", {
		Name             = "Topbar",
		BackgroundColor3 = theme.TopbarColor,
		BorderSizePixel  = 0,
		Size             = UDim2.new(1, 0, 0, 52),
		ZIndex           = 5,
		Parent           = frame,
	})
	New("UICorner", { CornerRadius = UDim.new(0, cfg.Window.CornerRadius), Parent = self.Topbar })

	self.TopbarCover = New("Frame", {
		Name             = "TopbarCover",
		BackgroundColor3 = theme.TopbarColor,
		BorderSizePixel  = 0,
		Position         = UDim2.new(0, 0, 1, -cfg.Window.CornerRadius),
		Size             = UDim2.new(1, 0, 0, cfg.Window.CornerRadius),
		ZIndex           = 6,
		Parent           = self.Topbar,
	})

	-- Accent bar at top of topbar (decorative)
	local accentBar = New("Frame", {
		Name             = "AccentBar",
		BackgroundColor3 = theme.AccentColor,
		BorderSizePixel  = 0,
		Size             = UDim2.new(0, 0, 0, 2),
		Position         = UDim2.fromOffset(0, 0),
		ZIndex           = 10,
		Parent           = self.Topbar,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 2), Parent = accentBar })
	-- Animate the accent bar expanding on open
	task.delay(0.1, function()
		Spring(accentBar, { Size = UDim2.new(1, 0, 0, 2) }, 0.55)
	end)

	self.TitleLabel = New("TextLabel", {
		Name             = "Title",
		BackgroundTransparency = 1,
		Font             = theme.Font,
		RichText         = true,
		Text             = cfg.Title,
		TextColor3       = theme.FontColor,
		TextSize         = 18,
		TextXAlignment   = Enum.TextXAlignment.Left,
		TextYAlignment   = Enum.TextYAlignment.Center,
		Position         = UDim2.fromOffset(18, 0),
		Size             = UDim2.new(1, cfg.Buttons.ShowClose and -70 or -36, 1, 0),
		ZIndex           = 7,
		Parent           = self.Topbar,
	})

	-- Close button
	if cfg.Buttons.ShowClose then
		local close = New("TextButton", {
			Name             = "Close",
			AutoButtonColor  = false,
			BackgroundColor3 = theme.SecondColor,
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			Position         = UDim2.new(1, -44, 0, 8),
			Size             = UDim2.fromOffset(36, 36),
			Text             = "",
			ZIndex           = 8,
			Parent           = self.Topbar,
		})
		New("UICorner", { CornerRadius = UDim.new(0, 7), Parent = close })

		local closeIcon = self:_GetIcon(cfg.Buttons.CloseIcon)
		if closeIcon then
			local img = New("ImageLabel", {
				Name               = "Icon",
				AnchorPoint        = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image              = closeIcon.Url,
				ImageColor3        = theme.MutedFontColor,
				ImageRectOffset    = closeIcon.ImageRectOffset or Vector2.zero,
				ImageRectSize      = closeIcon.ImageRectSize  or Vector2.zero,
				Position           = UDim2.fromScale(0.5, 0.5),
				Size               = UDim2.fromOffset(17, 17),
				ZIndex             = 9,
				Parent             = close,
			})
			close.MouseEnter:Connect(function()
				Quad(close, { BackgroundTransparency = 0, BackgroundColor3 = cfg.HoverTheme.CloseBackgroundColor or theme.SecondColor }, 0.14)
				Quad(img,   { ImageColor3 = cfg.HoverTheme.CloseIconColor or theme.ErrorColor }, 0.14)
			end)
			close.MouseLeave:Connect(function()
				Quad(close, { BackgroundTransparency = 1 }, 0.14)
				Quad(img,   { ImageColor3 = theme.MutedFontColor }, 0.14)
			end)
			close.MouseButton1Down:Connect(function()
				Spring(close, { Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -42, 0, 10) }, 0.12)
			end)
			close.MouseButton1Up:Connect(function()
				Spring(close, { Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -44, 0, 8) }, 0.25)
			end)
		else
			close.Text = "X"; close.Font = theme.Font
			close.TextColor3 = theme.MutedFontColor; close.TextSize = 15
		end
		close.MouseButton1Click:Connect(function() self:Close() end)
	end

	-- Content area
	self.Content = New("Frame", {
		Name                 = "Content",
		BackgroundColor3     = theme.ContentColor,
		BackgroundTransparency = cfg.Background.ContentTransparency,
		BorderSizePixel      = 0,
		Position             = UDim2.fromOffset(14, 66),
		Size                 = UDim2.new(1, -28, 1, -90),
		ZIndex               = 5,
		Parent               = frame,
	})
	New("UICorner", { CornerRadius = UDim.new(0, math.max(5, cfg.Window.CornerRadius - 2)), Parent = self.Content })
	self.ContentStroke = New("UIStroke", { Color = theme.OutlineColor, Thickness = 1, Parent = self.Content })
	New("UIPadding", { PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = self.Content })

	New("UIListLayout", {
		FillDirection  = Enum.FillDirection.Vertical,
		SortOrder      = Enum.SortOrder.LayoutOrder,
		Padding        = UDim.new(0, 10),
		Parent         = self.Content,
	})

	self.DescLabel = New("TextLabel", {
		Name               = "Description",
		LayoutOrder        = 1,
		BackgroundTransparency = 1,
		Font               = theme.Font,
		RichText           = true,
		Text               = cfg.Description,
		TextColor3         = theme.MutedFontColor,
		TextSize           = 14,
		TextWrapped        = true,
		TextXAlignment     = Enum.TextXAlignment.Left,
		TextYAlignment     = Enum.TextYAlignment.Top,
		Size               = UDim2.new(1, 0, 0, 38),
		ZIndex             = 6,
		Parent             = self.Content,
	})

	-- Key input
	self.KeyBox = New("TextBox", {
		Name               = "KeyBox",
		LayoutOrder        = 2,
		BackgroundColor3   = theme.SecondColor,
		BorderSizePixel    = 0,
		ClearTextOnFocus   = cfg.Key.ClearTextOnFocus,
		Font               = theme.Font,
		PlaceholderText    = cfg.Key.Placeholder,
		PlaceholderColor3  = theme.MutedFontColor,
		Text               = "",
		TextColor3         = theme.FontColor,
		TextSize           = 15,
		TextXAlignment     = Enum.TextXAlignment.Left,
		Size               = UDim2.new(1, 0, 0, cfg.Key.Height),
		ZIndex             = 6,
		Parent             = self.Content,
	})
	self.KeyBox.TextTransparency = cfg.Key.HideText and 1 or 0

	New("UICorner", { CornerRadius = UDim.new(0, math.max(4, cfg.Window.CornerRadius - 5)), Parent = self.KeyBox })
	self.KeyStroke = New("UIStroke", { Color = theme.OutlineColor, Thickness = 1, Parent = self.KeyBox })
	New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = self.KeyBox })

	self.KeyBox.Focused:Connect(function()
		Spring(self.KeyBox, { Size = UDim2.new(1, 0, 0, cfg.Key.Height + 2) }, 0.22)
		Quad(self.KeyStroke, { Color = cfg.HoverTheme.KeyStrokeColor or theme.AccentColor }, 0.15)
	end)
	self.KeyBox.FocusLost:Connect(function(enter)
		Spring(self.KeyBox, { Size = UDim2.new(1, 0, 0, cfg.Key.Height) }, 0.22)
		Quad(self.KeyStroke, { Color = theme.OutlineColor }, 0.15)
		if enter and cfg.Key.SubmitOnEnter then
			self:_Verify(self.KeyBox.Text, false)
		end
	end)

	-- Status label
	self.StatusLabel = New("TextLabel", {
		Name               = "Status",
		LayoutOrder        = 3,
		BackgroundTransparency = 1,
		Font               = theme.Font,
		RichText           = true,
		Text               = "",
		TextColor3         = theme.MutedFontColor,
		TextSize           = 13,
		TextXAlignment     = Enum.TextXAlignment.Left,
		TextYAlignment     = Enum.TextYAlignment.Center,
		Size               = UDim2.new(1, 0, 0, 20),
		ZIndex             = 6,
		Parent             = self.Content,
	})

	-- Button holder
	self.ButtonHolder = New("Frame", {
		Name               = "Buttons",
		LayoutOrder        = 4,
		BackgroundTransparency = 1,
		BorderSizePixel    = 0,
		Size               = UDim2.new(1, 0, 0, 0),
		ZIndex             = 6,
		Parent             = self.Content,
	})
	local btnLayout = New("UIListLayout", {
		FillDirection  = Enum.FillDirection.Vertical,
		SortOrder      = Enum.SortOrder.LayoutOrder,
		Padding        = UDim.new(0, cfg.Buttons.Gap),
		Parent         = self.ButtonHolder,
	})
	btnLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ButtonHolder.Size = UDim2.new(1, 0, 0, btnLayout.AbsoluteContentSize.Y)
	end)

	-- Build buttons
	self:_CreateButton({ Name = "Verify", Text = cfg.Buttons.MainText, Icon = cfg.Buttons.MainIcon, Accent = true, LayoutOrder = 1, Callback = function() self:_Verify(self.KeyBox.Text, false) end })

	if cfg.Buttons.ShowGetKey then
		self:_CreateButton({ Name = "GetKey", Text = cfg.Buttons.GetKeyText, Icon = cfg.Buttons.GetKeyIcon, LayoutOrder = 2, Callback = function()
			if cfg.Links.Key ~= "" and setclipboard then
				setclipboard(cfg.Links.Key)
				self:_SetStatus(cfg.Text.Copied, theme.SuccessColor, true)
			elseif cfg.Links.Key ~= "" then
				self:_SetStatus(cfg.Links.Key, theme.WarningColor, true)
			else
				self:_SetStatus(cfg.Text.NoKeyLink, theme.WarningColor, true)
			end
		end })
	end

	if cfg.Buttons.ShowDiscord then
		self:_CreateButton({ Name = "Discord", Text = cfg.Buttons.DiscordText, Icon = cfg.Buttons.DiscordIcon, LayoutOrder = 3, Callback = function()
			if cfg.Links.Discord ~= "" and setclipboard then
				setclipboard(cfg.Links.Discord)
				self:_SetStatus(cfg.Text.Copied, theme.SuccessColor, true)
			elseif cfg.Links.Discord ~= "" then
				self:_SetStatus(cfg.Links.Discord, theme.WarningColor, true)
			else
				self:_SetStatus(cfg.Text.NoDiscord, theme.WarningColor, true)
			end
		end })
	end

	if cfg.Buttons.ShowDeleteKey then
		self:_CreateButton({ Name = "DeleteSavedKey", Text = cfg.Buttons.DeleteKeyText, Icon = cfg.Buttons.DeleteKeyIcon, LayoutOrder = 4, Callback = function()
			self:DeleteSavedKey()
			self.KeyBox.Text = ""
		end })
	end

	-- Footer
	self.FooterLabel = New("TextLabel", {
		Name               = "Footer",
		LayoutOrder        = 5,
		BackgroundTransparency = 1,
		Font               = theme.Font,
		RichText           = true,
		Text               = cfg.Footer,
		TextColor3         = theme.MutedFontColor,
		TextSize           = 12,
		TextXAlignment     = Enum.TextXAlignment.Center,
		TextYAlignment     = Enum.TextYAlignment.Center,
		Size               = UDim2.new(1, 0, 0, 16),
		ZIndex             = 6,
		Parent             = self.Content,
	})

	task.defer(function()
		self.ButtonHolder.Size = UDim2.new(1, 0, 0, btnLayout.AbsoluteContentSize.Y)
	end)

	self:_SetupDragging()

	-- Load saved key
	local saved = cfg.Key.AutoLoad and ReadFile(cfg.Key.File)
	if saved and saved ~= "" then
		self.KeyBox.Text = saved
		self:_SetStatus(cfg.Text.Loaded, theme.MutedFontColor, true)
		if cfg.Key.AutoCheck then
			task.defer(function() self:_Verify(saved, true) end)
		end
	end

	self:Show()
	return self
end

function KeySystem:Create(config)
	return KeySystem.new(config)
end

return KeySystem
