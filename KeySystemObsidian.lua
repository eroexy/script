local cloneref = cloneref or clonereference or function(v) return v end

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Workspace = cloneref(game:GetService("Workspace"))
local SoundService = cloneref(game:GetService("SoundService"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end
local setclipboard = setclipboard or nil

local KeySystem = {}
KeySystem.__index = KeySystem

KeySystem.DefaultConfig = {
	Title = "Key System",
	Subtitle = "Enter your key to unlock the script.",
	BadgeText = "secure access",
	Footer = "Ready",

	Size = UDim2.fromOffset(500, 430),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Center = true,
	Draggable = true,
	DisplayOrder = 999,
	Parent = nil,

	CustomBackground = true,
	BackgroundImage = "",
	BackgroundImageTransparency = 0.2,
	BackgroundDim = 0.68,
	BackgroundScaleType = Enum.ScaleType.Crop,

	FocusDarken = true,
	FocusDarkness = 0.76,
	FOVTween = true,
	FocusedFOV = 60,
	FOVTweenTime = 0.35,

	FocusAudio = true,
	FocusAudioVolume = 0.38,
	FocusAudioMuffle = true,
	FocusAudioLowGain = 0,
	FocusAudioMidGain = -16,
	FocusAudioHighGain = -38,
	FocusAudioVoiceChat = true,

	Shadow = true,
	ShadowSize = 5,
	ShadowTransparency = 0.72,
	CornerRadius = 12,

	KeyFile = "KeySystem/saved_key.txt",
	SaveKey = true,
	AutoLoadSavedKey = true,
	AutoCheckSavedKey = false,
	DeleteInvalidKey = true,
	ClearInputWhenInvalid = false,

	KeyPlaceholder = "key-xxxx-xxxx-xxxx",
	HideKeyText = false,

	ButtonIcons = true,
	IconSide = "Right",
	IconSize = 17,
	IconGap = 8,
	IconColor = Color3.fromRGB(245, 242, 255),
	LucideURL = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",

	MainButtonText = "Verify Key",
	MainButtonIcon = "arrow-right",
	GetKeyButtonText = "Get Key",
	GetKeyButtonIcon = "copy",
	DiscordButtonText = "Discord",
	DiscordButtonIcon = "message-circle",
	DeleteKeyButtonText = "Delete Saved Key",
	DeleteKeyButtonIcon = "trash-2",
	CloseButtonIcon = "x",

	KeyLink = "",
	Discord = "",

	ShowGetKeyButton = true,
	ShowDiscordButton = false,
	ShowDeleteKeyButton = true,
	ShowCloseButton = true,

	TweenTime = 0.2,
	OpenTweenTime = 0.36,
	CloseTweenTime = 0.28,

	StatusReady = "Ready",
	StatusChecking = "Verifying key...",
	StatusSuccess = "Authenticated",
	StatusInvalid = "Invalid key",
	StatusLoaded = "Loaded saved key",
	StatusDeleted = "Saved key deleted",
	StatusCopied = "Copied to clipboard",
	StatusCopyFail = "Clipboard unsupported",

	Theme = {
		Background = Color3.fromRGB(2, 0, 8),
		Card = Color3.fromRGB(8, 7, 13),
		CardTop = Color3.fromRGB(13, 11, 22),
		Panel = Color3.fromRGB(12, 10, 20),
		Input = Color3.fromRGB(4, 3, 9),
		Border = Color3.fromRGB(55, 42, 82),
		SoftBorder = Color3.fromRGB(35, 28, 52),
		Text = Color3.fromRGB(250, 247, 255),
		Muted = Color3.fromRGB(157, 143, 182),
		Primary = Color3.fromRGB(126, 65, 255),
		Primary2 = Color3.fromRGB(188, 72, 255),
		PrimaryDark = Color3.fromRGB(52, 24, 112),
		Success = Color3.fromRGB(80, 245, 170),
		Error = Color3.fromRGB(255, 93, 132),
		Warning = Color3.fromRGB(255, 202, 99),
		Font = Enum.Font.Gotham,
		MediumFont = Enum.Font.GothamMedium,
		BoldFont = Enum.Font.GothamBold,
		CodeFont = Enum.Font.Code,
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
	for k, v in pairs(base or {}) do
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
	if value:match("^rbxassetid://") or value:match("^rbxthumb://") or value:match("roblox%.com/asset") then return value end
	if tonumber(value) then return "rbxassetid://" .. value end
	return nil
end

local function MakeFolderPath(path)
	if not (isfolder and makefolder and path) then return end
	local parts = string.split(path, "/")
	local current = ""
	for i = 1, math.max(#parts - 1, 0) do
		current ..= parts[i]
		if current ~= "" and not isfolder(current) then pcall(makefolder, current) end
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
	if delfile and isfile and isfile(path) then return pcall(delfile, path) end
	if writefile and isfile and isfile(path) then return pcall(writefile, path, "") end
	return false
end

local function Tween(obj, info, props)
	if not obj then return end
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function Add(c, n)
	return Color3.fromRGB(
		math.clamp(c.R * 255 + n, 0, 255),
		math.clamp(c.G * 255 + n, 0, 255),
		math.clamp(c.B * 255 + n, 0, 255)
	)
end

function KeySystem:_LoadLucide()
	if self.LucideLoaded then return end
	self.LucideLoaded = true
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
		return { Url = asset, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
	end

	if typeof(icon) == "string" then
		self:_LoadLucide()
		if self.LucideIcons then
			local ok, data = pcall(self.LucideIcons.GetAsset, icon)
			if ok and data then return data end
		end
	end
end

function KeySystem:_SetStatus(text, color)
	self.Status.Text = tostring(text or "")
	self.Status.TextColor3 = color or self.Config.Theme.Muted
	self.Status.TextTransparency = 1
	Tween(self.Status, self.FastTween, { TextTransparency = 0 })
end

function KeySystem:_MakeIcon(parent, iconName, color)
	local data = self:_GetIcon(iconName)
	if not data then return end

	return New("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = data.Url,
		ImageRectOffset = data.ImageRectOffset or Vector2.zero,
		ImageRectSize = data.ImageRectSize or Vector2.zero,
		ImageColor3 = color or self.Config.IconColor,
		Size = UDim2.fromOffset(self.Config.IconSize, self.Config.IconSize),
		Parent = parent,
	})
end

function KeySystem:_Button(text, iconName, parent, accent, callback)
	local cfg = self.Config
	local C = cfg.Theme

	local btn = New("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = accent and C.Primary or C.Input,
		BorderSizePixel = 0,
		Font = accent and C.BoldFont or C.MediumFont,
		Text = "",
		TextColor3 = C.Text,
		TextSize = accent and 14 or 13,
		Size = UDim2.new(1, 0, 0, accent and 44 or 40),
		ClipsDescendants = true,
		Parent = parent,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })

	local stroke = New("UIStroke", {
		Color = accent and C.Primary2 or C.Border,
		Thickness = 1,
		Transparency = accent and 0.35 or 0.15,
		Parent = btn,
	})

	if accent then
		New("UIGradient", {
			Color = ColorSequence.new(C.Primary, C.Primary2),
			Rotation = 0,
			Parent = btn,
		})
	end

	local center = New("Frame", {
		Name = "Center",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(10, btn.Size.Y.Offset),
		Parent = btn,
	})

	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, cfg.IconGap),
		Parent = center,
	})

	local label = New("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, btn.Size.Y.Offset),
		Font = accent and C.BoldFont or C.MediumFont,
		Text = text,
		TextColor3 = C.Text,
		TextSize = accent and 14 or 13,
		Parent = center,
	})

	local icon
	if cfg.ButtonIcons then
		icon = self:_MakeIcon(center, iconName, cfg.IconColor)
		if icon then
			if cfg.IconSide == "Left" then
				icon.LayoutOrder = 1
				label.LayoutOrder = 2
			else
				label.LayoutOrder = 1
				icon.LayoutOrder = 2
			end
		end
	end

	local function resize()
		local width = label.TextBounds.X + 6
		if icon then width += cfg.IconSize + cfg.IconGap end
		center.Size = UDim2.fromOffset(width, btn.Size.Y.Offset)
	end
	resize()
	label:GetPropertyChangedSignal("TextBounds"):Connect(resize)

	btn.MouseEnter:Connect(function()
		Tween(btn, self.FastTween, { BackgroundColor3 = accent and Add(C.Primary, 10) or Add(C.Input, 12) })
		Tween(stroke, self.FastTween, { Color = C.Primary2, Transparency = 0 })
	end)

	btn.MouseLeave:Connect(function()
		Tween(btn, self.FastTween, { BackgroundColor3 = accent and C.Primary or C.Input })
		Tween(stroke, self.FastTween, { Color = accent and C.Primary2 or C.Border, Transparency = accent and 0.35 or 0.15 })
	end)

	btn.MouseButton1Down:Connect(function()
		Tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = btn.Position + UDim2.fromOffset(0, 1) })
	end)

	btn.MouseButton1Up:Connect(function()
		Tween(btn, self.FastTween, { Position = UDim2.fromOffset(0, btn.Position.Y.Offset - 1) })
	end)

	btn.MouseButton1Click:Connect(function()
		if callback then callback(btn, label) end
	end)

	return btn
end

function KeySystem:_ApplyFocusAudio()
	if not self.Config.FocusAudio or self.AudioFocused then return end
	self.AudioFocused = true
	self.AudioRestore = { Sounds = {}, VoiceObjects = {} }

	local cfg = self.Config

	local group = Instance.new("SoundGroup")
	group.Name = "KeySystem_UnfocusedAudio"
	group.Volume = cfg.FocusAudioVolume
	group.Parent = SoundService
	self.FocusSoundGroup = group

	if cfg.FocusAudioMuffle then
		local eq = Instance.new("EqualizerSoundEffect")
		eq.Name = "Muffle"
		eq.LowGain = cfg.FocusAudioLowGain
		eq.MidGain = cfg.FocusAudioMidGain
		eq.HighGain = cfg.FocusAudioHighGain
		eq.Parent = group
	end

	local function hookSound(sound)
		if not sound:IsA("Sound") or self.AudioRestore.Sounds[sound] then return end
		self.AudioRestore.Sounds[sound] = { SoundGroup = sound.SoundGroup, Volume = sound.Volume }
		pcall(function() sound.SoundGroup = group end)
	end

	for _, obj in ipairs(game:GetDescendants()) do
		hookSound(obj)
	end

	self.AudioAddedConn = game.DescendantAdded:Connect(function(obj)
		task.defer(function()
			if self.AudioFocused then hookSound(obj) end
		end)
	end)

	if cfg.FocusAudioVoiceChat then
		for _, obj in ipairs(game:GetDescendants()) do
			if obj.ClassName == "AudioDeviceOutput" or obj.ClassName == "AudioEmitter" or obj.ClassName == "AudioListener" then
				local props = {}
				pcall(function()
					props.Volume = obj.Volume
					obj.Volume = cfg.FocusAudioVolume
				end)
				if next(props) then self.AudioRestore.VoiceObjects[obj] = props end
			end
		end
	end
end

function KeySystem:_RestoreFocusAudio()
	if not self.AudioFocused then return end
	self.AudioFocused = false

	if self.AudioAddedConn then
		self.AudioAddedConn:Disconnect()
		self.AudioAddedConn = nil
	end

	if self.AudioRestore then
		for sound, data in pairs(self.AudioRestore.Sounds or {}) do
			if sound and sound.Parent then
				pcall(function()
					sound.SoundGroup = data.SoundGroup
					sound.Volume = data.Volume
				end)
			end
		end

		for obj, props in pairs(self.AudioRestore.VoiceObjects or {}) do
			if obj and obj.Parent then
				for prop, value in pairs(props) do
					pcall(function() obj[prop] = value end)
				end
			end
		end
	end

	if self.FocusSoundGroup then
		pcall(function() self.FocusSoundGroup:Destroy() end)
		self.FocusSoundGroup = nil
	end
	self.AudioRestore = nil
end

function KeySystem:_Verify(key, fromSaved)
	key = tostring(key or self.Input.Text or ""):gsub("%s+", "")

	if key == "" then
		self:_SetStatus("Enter your key first.", self.Config.Theme.Error)
		return false
	end

	self:_SetStatus(self.Config.StatusChecking, self.Config.Theme.Muted)
	self.VerifyLabel.Text = "Verifying..."

	local ok, valid, message = pcall(self.Config.VerifyKey, key, self)
	valid = ok and valid == true

	if valid then
		self.ValidatedKey = key
		if self.Config.SaveKey then SaveFile(self.Config.KeyFile, key) end

		self.VerifyLabel.Text = self.Config.MainButtonText
		self:_SetStatus(message or self.Config.StatusSuccess, self.Config.Theme.Success)
		Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Success })
		task.delay(0.35, function()
			if self.CardStroke then Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Border }) end
		end)

		self.Config.OnSuccess(key, self)
		return true
	end

	self.VerifyLabel.Text = self.Config.MainButtonText

	if self.Config.DeleteInvalidKey then DeleteFile(self.Config.KeyFile) end
	if self.Config.ClearInputWhenInvalid and not fromSaved then self.Input.Text = "" end

	self:_SetStatus(message or self.Config.StatusInvalid, self.Config.Theme.Error)
	Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Error })
	task.delay(0.35, function()
		if self.CardStroke then Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Border }) end
	end)

	self.Config.OnInvalid(key, self)
	return false
end

function KeySystem:DeleteSavedKey()
	DeleteFile(self.Config.KeyFile)
	self.Input.Text = ""
	self:_SetStatus(self.Config.StatusDeleted, self.Config.Theme.Warning)
end

function KeySystem:Close()
	if self.Closing then return end
	self.Closing = true
	self.Config.OnClose(self)

	local camera = Workspace.CurrentCamera
	if self.Config.FOVTween and camera and self.OriginalFOV then
		Tween(camera, TweenInfo.new(self.Config.FOVTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { FieldOfView = self.OriginalFOV })
	end

	Tween(self.HolderScale, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Scale = 0.94 })
	Tween(self.Holder, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = self.StartPosition + UDim2.fromOffset(0, 18),
	})
	Tween(self.Card, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
	Tween(self.Topbar, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
	Tween(self.Panel, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
	Tween(self.Overlay, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })

	if self.Shadow then Tween(self.Shadow, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 1 }) end
	if self.CardStroke then Tween(self.CardStroke, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Transparency = 1 }) end

	for _, obj in ipairs(self.FadeObjects) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			Tween(obj, TweenInfo.new(self.Config.CloseTweenTime * 0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { TextTransparency = 1 })
		elseif obj:IsA("ImageLabel") then
			Tween(obj, TweenInfo.new(self.Config.CloseTweenTime * 0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { ImageTransparency = 1 })
		elseif obj:IsA("Frame") then
			Tween(obj, TweenInfo.new(self.Config.CloseTweenTime * 0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
		end
	end

	task.delay(self.Config.CloseTweenTime + 0.04, function()
		self:_RestoreFocusAudio()
		if self.ScreenGui then self.ScreenGui:Destroy() end
	end)
end

function KeySystem:Show()
	self:_ApplyFocusAudio()

	local camera = Workspace.CurrentCamera
	if self.Config.FOVTween and camera then
		self.OriginalFOV = camera.FieldOfView
		Tween(camera, TweenInfo.new(self.Config.FOVTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { FieldOfView = self.Config.FocusedFOV })
	end

	self.Holder.Visible = true
	self.HolderScale.Scale = 0.94
	self.Holder.Position = self.StartPosition + UDim2.fromOffset(0, 22)
	self.Card.BackgroundTransparency = 1
	self.Topbar.BackgroundTransparency = 1
	self.Panel.BackgroundTransparency = 1
	self.CardStroke.Transparency = 1

	if self.Shadow then self.Shadow.BackgroundTransparency = 1 end

	Tween(self.Overlay, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = self.Config.FocusDarken and (1 - self.Config.FocusDarkness) or 1,
	})
	Tween(self.HolderScale, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
	Tween(self.Holder, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = self.StartPosition })
	Tween(self.Card, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
	Tween(self.Topbar, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
	Tween(self.Panel, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.02 })
	Tween(self.CardStroke, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = 0 })

	if self.Shadow then
		Tween(self.Shadow, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = self.Config.ShadowTransparency })
	end

	for i, obj in ipairs(self.FadeObjects) do
		task.delay(i * 0.012, function()
			if not obj or not obj.Parent then return end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				Tween(obj, self.FastTween, { TextTransparency = 0 })
			elseif obj:IsA("ImageLabel") then
				Tween(obj, self.FastTween, { ImageTransparency = 0 })
			end
		end)
	end
end

function KeySystem.new(config)
	local self = setmetatable({}, KeySystem)
	self.Config = Merge(KeySystem.DefaultConfig, config or {})
	self.FastTween = TweenInfo.new(self.Config.TweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	self.FadeObjects = {}

	local cfg = self.Config
	local C = cfg.Theme

	local gui = New("ScreenGui", {
		Name = "KeySystemModern_" .. HttpService:GenerateGUID(false),
		DisplayOrder = cfg.DisplayOrder,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	})
	pcall(protectgui, gui)

	local ok = pcall(function() gui.Parent = cfg.Parent or gethui() end)
	if not ok or not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	self.ScreenGui = gui

	local overlay = New("Frame", {
		Name = "FocusOverlay",
		BackgroundColor3 = C.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		Parent = gui,
	})
	self.Overlay = overlay

	if cfg.CustomBackground and cfg.BackgroundImage and cfg.BackgroundImage ~= "" then
		New("ImageLabel", {
			Name = "CustomBackground",
			BackgroundTransparency = 1,
			Image = ToAsset(cfg.BackgroundImage) or cfg.BackgroundImage,
			ImageTransparency = cfg.BackgroundImageTransparency,
			ScaleType = cfg.BackgroundScaleType,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = overlay,
		})
		New("Frame", {
			Name = "BackgroundDim",
			BackgroundColor3 = C.Background,
			BackgroundTransparency = 1 - cfg.BackgroundDim,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2,
			Parent = overlay,
		})
	end

	local holder = New("Frame", {
		Name = "Holder",
		AnchorPoint = cfg.AnchorPoint,
		BackgroundTransparency = 1,
		Position = cfg.Center and UDim2.fromScale(0.5, 0.5) or cfg.Position,
		Size = cfg.Size,
		Visible = false,
		ZIndex = 10,
		Parent = gui,
	})
	self.Holder = holder
	self.StartPosition = holder.Position
	self.HolderScale = New("UIScale", { Scale = 0.94, Parent = holder })

	if cfg.Shadow then
		local shadow = New("Frame", {
			Name = "Shadow",
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(-cfg.ShadowSize, -cfg.ShadowSize),
			Size = UDim2.new(1, cfg.ShadowSize * 2, 1, cfg.ShadowSize * 2),
			ZIndex = 10,
			Parent = holder,
		})
		New("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius + 4), Parent = shadow })
		self.Shadow = shadow
	end

	local card = New("Frame", {
		Name = "Card",
		BackgroundColor3 = C.Card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 12,
		ClipsDescendants = true,
		Parent = holder,
	})
	self.Card = card
	New("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius), Parent = card })
	self.CardStroke = New("UIStroke", { Color = C.Border, Thickness = 1, Transparency = 1, Parent = card })

	local topbar = New("Frame", {
		Name = "Topbar",
		BackgroundColor3 = C.CardTop,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 62),
		ZIndex = 13,
		Parent = card,
	})
	self.Topbar = topbar
	New("UICorner", { CornerRadius = UDim.new(0, cfg.CornerRadius), Parent = topbar })
	New("Frame", {
		BackgroundColor3 = C.CardTop,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -cfg.CornerRadius),
		Size = UDim2.new(1, 0, 0, cfg.CornerRadius),
		ZIndex = 13,
		Parent = topbar,
	})

	local accentBar = New("Frame", {
		BackgroundColor3 = C.Primary,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 2),
		ZIndex = 16,
		Parent = topbar,
	})
	New("UIGradient", {
		Color = ColorSequence.new(C.Primary, C.Primary2),
		Rotation = 0,
		Parent = accentBar,
	})

	local title = New("TextLabel", {
		BackgroundTransparency = 1,
		Font = C.BoldFont,
		Text = cfg.Title,
		TextColor3 = C.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(20, 6),
		Size = UDim2.new(1, -72, 0, 34),
		ZIndex = 15,
		Parent = topbar,
	})
	table.insert(self.FadeObjects, title)

	local badge = New("TextLabel", {
		BackgroundColor3 = C.PrimaryDark,
		BorderSizePixel = 0,
		Font = C.MediumFont,
		Text = cfg.BadgeText,
		TextColor3 = C.Muted,
		TextSize = 10,
		Position = UDim2.fromOffset(20, 36),
		Size = UDim2.fromOffset(122, 18),
		ZIndex = 15,
		Parent = topbar,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badge })
	New("UIStroke", { Color = C.Primary, Transparency = 0.55, Thickness = 1, Parent = badge })
	table.insert(self.FadeObjects, badge)

	if cfg.ShowCloseButton then
		local close = New("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Font = C.MediumFont,
			Text = "×",
			TextColor3 = C.Muted,
			TextSize = 20,
			Position = UDim2.new(1, -42, 0, 13),
			Size = UDim2.fromOffset(28, 28),
			ZIndex = 15,
			Parent = topbar,
		})
		table.insert(self.FadeObjects, close)
		close.MouseEnter:Connect(function() Tween(close, self.FastTween, { TextColor3 = C.Text }) end)
		close.MouseLeave:Connect(function() Tween(close, self.FastTween, { TextColor3 = C.Muted }) end)
		close.MouseButton1Click:Connect(function() self:Close() end)
	end

	local panel = New("Frame", {
		Name = "Panel",
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 78),
		Size = UDim2.new(1, -32, 1, -96),
		ZIndex = 13,
		Parent = card,
	})
	self.Panel = panel
	New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = panel })
	New("UIStroke", { Color = C.SoftBorder, Thickness = 1, Transparency = 0.1, Parent = panel })
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 22),
		PaddingRight = UDim.new(0, 22),
		PaddingTop = UDim.new(0, 20),
		PaddingBottom = UDim.new(0, 18),
		Parent = panel,
	})

	local list = New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = panel,
	})

	local sub = New("TextLabel", {
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		Font = C.Font,
		Text = cfg.Subtitle,
		TextColor3 = C.Muted,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 34),
		ZIndex = 15,
		Parent = panel,
	})
	table.insert(self.FadeObjects, sub)

	local keyLabel = New("TextLabel", {
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Font = C.MediumFont,
		Text = "ACCESS KEY",
		TextColor3 = C.Muted,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 15,
		Parent = panel,
	})
	table.insert(self.FadeObjects, keyLabel)

	local input = New("TextBox", {
		LayoutOrder = 3,
		BackgroundColor3 = C.Input,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = C.CodeFont,
		PlaceholderText = cfg.KeyPlaceholder,
		PlaceholderColor3 = Color3.fromRGB(92, 77, 116),
		Text = "",
		TextColor3 = C.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 44),
		ZIndex = 15,
		Parent = panel,
	})
	input.TextTransparency = cfg.HideKeyText and 1 or 0
	self.Input = input
	table.insert(self.FadeObjects, input)
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = input })
	self.InputStroke = New("UIStroke", { Color = C.Border, Thickness = 1, Transparency = 0.05, Parent = input })
	New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = input })

	input.Focused:Connect(function() Tween(self.InputStroke, self.FastTween, { Color = C.Primary2, Thickness = 2 }) end)
	input.FocusLost:Connect(function(enter)
		Tween(self.InputStroke, self.FastTween, { Color = C.Border, Thickness = 1 })
		if enter then self:_Verify(input.Text, false) end
	end)

	local verify = self:_Button(cfg.MainButtonText, cfg.MainButtonIcon, panel, true, function(_, lbl)
		self.VerifyLabel = lbl
		self:_Verify(input.Text, false)
	end)
	verify.LayoutOrder = 4
	self.VerifyLabel = verify.Center.Label

	local divider = New("Frame", {
		LayoutOrder = 5,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		ZIndex = 15,
		Parent = panel,
	})
	local line1 = New("Frame", { BackgroundColor3 = C.Border, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0.42, 0, 0, 1), ZIndex = 15, Parent = divider })
	local orText = New("TextLabel", { BackgroundTransparency = 1, Font = C.Font, Text = "OR", TextColor3 = C.Muted, TextSize = 10, Position = UDim2.new(0.42, 0, 0, 0), Size = UDim2.new(0.16, 0, 1, 0), ZIndex = 15, Parent = divider })
	local line2 = New("Frame", { BackgroundColor3 = C.Border, BorderSizePixel = 0, Position = UDim2.new(0.58, 0, 0.5, 0), Size = UDim2.new(0.42, 0, 0, 1), ZIndex = 15, Parent = divider })
	table.insert(self.FadeObjects, line1)
	table.insert(self.FadeObjects, orText)
	table.insert(self.FadeObjects, line2)

	if cfg.ShowGetKeyButton then
		local get = self:_Button(cfg.GetKeyButtonText, cfg.GetKeyButtonIcon, panel, false, function()
			if cfg.KeyLink ~= "" and setclipboard then
				setclipboard(cfg.KeyLink)
				self:_SetStatus(cfg.StatusCopied, C.Success)
			elseif cfg.KeyLink ~= "" then
				self:_SetStatus(cfg.KeyLink, C.Warning)
			else
				self:_SetStatus("No key link configured.", C.Warning)
			end
		end)
		get.LayoutOrder = 6
	end

	if cfg.ShowDiscordButton then
		local discord = self:_Button(cfg.DiscordButtonText, cfg.DiscordButtonIcon, panel, false, function()
			if cfg.Discord ~= "" and setclipboard then
				setclipboard(cfg.Discord)
				self:_SetStatus(cfg.StatusCopied, C.Success)
			elseif cfg.Discord ~= "" then
				self:_SetStatus(cfg.Discord, C.Warning)
			else
				self:_SetStatus(cfg.StatusCopyFail, C.Error)
			end
		end)
		discord.LayoutOrder = 7
	end

	if cfg.ShowDeleteKeyButton then
		local del = self:_Button(cfg.DeleteKeyButtonText, cfg.DeleteKeyButtonIcon, panel, false, function()
			self:DeleteSavedKey()
		end)
		del.LayoutOrder = 8
	end

	local status = New("TextLabel", {
		LayoutOrder = 9,
		BackgroundTransparency = 1,
		Font = C.Font,
		Text = cfg.StatusReady,
		TextColor3 = C.Muted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 16),
		ZIndex = 15,
		Parent = panel,
	})
	self.Status = status
	table.insert(self.FadeObjects, status)

	if cfg.Draggable then
		local dragging = false
		local startPos
		local startFrame
		local dragInput

		topbar.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.Touch then return end
			dragging = true
			startPos = inputObject.Position
			startFrame = holder.Position
			inputObject.Changed:Connect(function()
				if inputObject.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end)

		UserInputService.InputChanged:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch then dragInput = inputObject end
			if dragging and inputObject == dragInput then
				local delta = inputObject.Position - startPos
				holder.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + delta.X, startFrame.Y.Scale, startFrame.Y.Offset + delta.Y)
				self.StartPosition = holder.Position
			end
		end)
	end

	for _, obj in ipairs(self.FadeObjects) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			obj.TextTransparency = 1
		elseif obj:IsA("ImageLabel") then
			obj.ImageTransparency = 1
		elseif obj:IsA("Frame") then
			obj.BackgroundTransparency = 1
		end
	end

	local saved = cfg.AutoLoadSavedKey and ReadFile(cfg.KeyFile)
	if saved and saved ~= "" then
		input.Text = saved:gsub("^%s*(.-)%s*$", "%1")
		self:_SetStatus(cfg.StatusLoaded, C.Muted)
		if cfg.AutoCheckSavedKey then
			task.defer(function() self:_Verify(input.Text, true) end)
		end
	end

	self:Show()
	return self
end

return KeySystem
