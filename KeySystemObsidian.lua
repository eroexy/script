local cloneref = cloneref or clonereference or function(v) return v end

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() return CoreGui end
local setclipboard = setclipboard or nil

local KeySystem = {}
KeySystem.__index = KeySystem

KeySystem.DefaultConfig = {
	Title = "Sign in to Your Hub",
	Subtitle = "Authenticate with your access key to continue.",
	BadgeText = "secure key system",
	Footer = "Ready",

	Size = UDim2.fromOffset(430, 405),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Center = true,
	Draggable = true,
	DisplayOrder = 999,
	Parent = nil,

	CustomBackground = true,
	BackgroundImage = "",
	BackgroundImageTransparency = 0.22,
	BackgroundDim = 0.55,
	BackgroundScaleType = Enum.ScaleType.Crop,

	FocusDarken = true,
	FocusDarkness = 0.82,
	FOVTween = true,
	FocusedFOV = 60,
	FOVTweenTime = 0.35,

	Shadow = true,
	ShadowSize = 7,
	ShadowTransparency = 0.68,
	CornerRadius = 14,

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
	IconColor = Color3.fromRGB(255, 255, 255),
	LucideURL = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",

	MainButtonText = "Verify access key",
	MainButtonIcon = "arrow-right",
	GetKeyButtonText = "Copy get-key link",
	GetKeyButtonIcon = "copy",
	DiscordButtonText = "Copy Discord",
	DiscordButtonIcon = "message-circle",
	DeleteKeyButtonText = "Delete saved key",
	DeleteKeyButtonIcon = "trash-2",
	CloseButtonIcon = "x",

	KeyLink = "",
	Discord = "",

	ShowGetKeyButton = true,
	ShowDiscordButton = false,
	ShowDeleteKeyButton = true,
	ShowCloseButton = true,

	TweenTime = 0.22,
	OpenTweenTime = 0.4,
	CloseTweenTime = 0.32,

	StatusReady = "● Ready",
	StatusChecking = "● Verifying...",
	StatusSuccess = "✓ Authenticated",
	StatusInvalid = "✕ Invalid key",
	StatusLoaded = "● Loaded saved key",
	StatusDeleted = "● Saved key deleted",
	StatusCopied = "✓ Copied to clipboard",
	StatusCopyFail = "✕ Clipboard unsupported",

	Theme = {
		Background = Color3.fromRGB(2, 6, 23),
		Card = Color3.fromRGB(15, 23, 42),
		Card2 = Color3.fromRGB(2, 6, 23),
		Border = Color3.fromRGB(51, 65, 85),
		SoftBorder = Color3.fromRGB(30, 41, 59),
		Text = Color3.fromRGB(248, 250, 252),
		Muted = Color3.fromRGB(148, 163, 184),
		Primary = Color3.fromRGB(139, 92, 246),
		Primary2 = Color3.fromRGB(217, 70, 239),
		Success = Color3.fromRGB(52, 211, 153),
		Error = Color3.fromRGB(248, 113, 113),
		Warning = Color3.fromRGB(251, 191, 36),
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
	if value:match("^rbxassetid://") or value:match("^rbxthumb://") or value:match("roblox%.com/asset") then
		return value
	end
	if tonumber(value) then
		return "rbxassetid://" .. value
	end
	return nil
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

local function Tween(obj, info, props)
	if not obj then return end
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function Brighten(c, n)
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
	self.Status.Text = text or ""
	self.Status.TextColor3 = color or self.Config.Theme.Muted
	self.Status.TextTransparency = 1
	self.Status.Position = UDim2.new(0, 0, 1, -16)
	Tween(self.Status, self.FastTween, {
		TextTransparency = 0,
		Position = UDim2.new(0, 0, 1, -18),
	})
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

function KeySystem:_Button(text, iconName, y, accent, callback)
	local cfg = self.Config
	local C = cfg.Theme

	local btn = New("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = accent and C.Primary or C.Card2,
		BorderSizePixel = 0,
		Font = accent and C.BoldFont or C.MediumFont,
		Text = "",
		TextColor3 = C.Text,
		TextSize = accent and 14 or 13,
		Position = UDim2.new(0, 0, 0, y),
		Size = UDim2.new(1, 0, 0, accent and 46 or 42),
		ClipsDescendants = true,
		Parent = self.Card,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })

	local stroke = New("UIStroke", {
		Color = accent and C.Primary or C.Border,
		Thickness = 1,
		Transparency = accent and 1 or 0,
		Parent = btn,
	})

	if accent then
		New("UIGradient", {
			Color = ColorSequence.new(C.Primary, C.Primary2),
			Rotation = 90,
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

	local list = New("UIListLayout", {
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
		local width = label.TextBounds.X + 4
		if icon then width += cfg.IconSize + cfg.IconGap end
		center.Size = UDim2.fromOffset(width, btn.Size.Y.Offset)
	end
	resize()
	label:GetPropertyChangedSignal("TextBounds"):Connect(resize)

	btn.MouseEnter:Connect(function()
		Tween(btn, self.FastTween, {
			BackgroundColor3 = accent and C.Primary or Brighten(C.Card2, 10),
			Size = UDim2.new(1, 0, 0, (accent and 46 or 42) + 1),
		})
		Tween(stroke, self.FastTween, {
			Color = accent and C.Primary2 or C.Primary,
			Transparency = accent and 0.35 or 0,
		})
	end)

	btn.MouseLeave:Connect(function()
		Tween(btn, self.FastTween, {
			BackgroundColor3 = accent and C.Primary or C.Card2,
			Size = UDim2.new(1, 0, 0, accent and 46 or 42),
		})
		Tween(stroke, self.FastTween, {
			Color = accent and C.Primary or C.Border,
			Transparency = accent and 1 or 0,
		})
	end)

	btn.MouseButton1Down:Connect(function()
		Tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, (accent and 46 or 42) - 1),
		})
	end)

	btn.MouseButton1Up:Connect(function()
		Tween(btn, self.FastTween, {
			Size = UDim2.new(1, 0, 0, accent and 46 or 42),
		})
	end)

	btn.MouseButton1Click:Connect(function()
		if callback then callback(btn, label) end
	end)

	return btn
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
		if self.Config.SaveKey then
			SaveFile(self.Config.KeyFile, key)
		end

		self.VerifyLabel.Text = self.Config.MainButtonText
		self:_SetStatus(message or self.Config.StatusSuccess, self.Config.Theme.Success)
		Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Success })
		task.delay(0.35, function()
			if self.CardStroke then
				Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Border })
			end
		end)

		self.Config.OnSuccess(key, self)
		return true
	end

	self.VerifyLabel.Text = self.Config.MainButtonText

	if self.Config.DeleteInvalidKey then
		DeleteFile(self.Config.KeyFile)
	end

	if self.Config.ClearInputWhenInvalid and not fromSaved then
		self.Input.Text = ""
	end

	self:_SetStatus(message or self.Config.StatusInvalid, self.Config.Theme.Error)
	Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Error })
	task.delay(0.35, function()
		if self.CardStroke then
			Tween(self.CardStroke, self.FastTween, { Color = self.Config.Theme.Border })
		end
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
		Tween(camera, TweenInfo.new(self.Config.FOVTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			FieldOfView = self.OriginalFOV,
		})
	end

	Tween(self.CardScale, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Scale = 0.94,
	})

	Tween(self.Card, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, -self.Config.Size.X.Offset / 2, 0.5, -self.Config.Size.Y.Offset / 2 + 16),
	})

	if self.Shadow then
		Tween(self.Shadow, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
		})
	end

	if self.Overlay then
		Tween(self.Overlay, TweenInfo.new(self.Config.CloseTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
	end

	for _, obj in ipairs(self.FadeObjects) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			Tween(obj, TweenInfo.new(self.Config.CloseTweenTime * 0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				TextTransparency = 1,
				BackgroundTransparency = obj.BackgroundTransparency == 1 and 1 or 1,
			})
		elseif obj:IsA("ImageLabel") then
			Tween(obj, TweenInfo.new(self.Config.CloseTweenTime * 0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				ImageTransparency = 1,
			})
		elseif obj:IsA("Frame") then
			Tween(obj, TweenInfo.new(self.Config.CloseTweenTime * 0.85, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
			})
		end
	end

	task.delay(self.Config.CloseTweenTime + 0.04, function()
		if self.ScreenGui then
			self.ScreenGui:Destroy()
		end
	end)
end

function KeySystem:Show()
	local camera = Workspace.CurrentCamera
	if self.Config.FOVTween and camera then
		self.OriginalFOV = camera.FieldOfView
		Tween(camera, TweenInfo.new(self.Config.FOVTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			FieldOfView = self.Config.FocusedFOV,
		})
	end

	self.Card.Visible = true
	self.Card.BackgroundTransparency = 1
	self.Card.Position = UDim2.new(0.5, -self.Config.Size.X.Offset / 2, 0.5, -self.Config.Size.Y.Offset / 2 + 20)
	self.CardScale.Scale = 0.94

	if self.Overlay then
		self.Overlay.BackgroundTransparency = 1
		Tween(self.Overlay, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1 - self.Config.FocusDarkness,
		})
	end

	if self.Shadow then
		self.Shadow.BackgroundTransparency = 1
		Tween(self.Shadow, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = self.Config.ShadowTransparency,
		})
	end

	Tween(self.CardScale, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	})

	Tween(self.Card, TweenInfo.new(self.Config.OpenTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
		Position = UDim2.new(0.5, -self.Config.Size.X.Offset / 2, 0.5, -self.Config.Size.Y.Offset / 2),
	})

	for i, obj in ipairs(self.FadeObjects) do
		task.delay(i * 0.018, function()
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

	local ok = pcall(function()
		gui.Parent = cfg.Parent or gethui()
	end)
	if not ok or not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	self.ScreenGui = gui

	local root = New("Frame", {
		Name = "Root",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = gui,
	})
	self.Root = root

	local overlay = New("Frame", {
		Name = "FocusOverlay",
		BackgroundColor3 = C.Background,
		BackgroundTransparency = cfg.FocusDarken and 1 or 0.2,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = root,
	})
	self.Overlay = overlay

	if cfg.CustomBackground and cfg.BackgroundImage and cfg.BackgroundImage ~= "" then
		local bg = New("ImageLabel", {
			Name = "CustomBackground",
			BackgroundTransparency = 1,
			Image = ToAsset(cfg.BackgroundImage) or cfg.BackgroundImage,
			ImageTransparency = cfg.BackgroundImageTransparency,
			ScaleType = cfg.BackgroundScaleType,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0,
			Parent = overlay,
		})

		New("Frame", {
			Name = "BackgroundDim",
			BackgroundColor3 = C.Background,
			BackgroundTransparency = 1 - cfg.BackgroundDim,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = overlay,
		})
	end

	local holder = New("Frame", {
		Name = "Holder",
		AnchorPoint = cfg.AnchorPoint,
		BackgroundTransparency = 1,
		Position = cfg.Center and UDim2.fromScale(0.5, 0.5) or cfg.Position,
		Size = cfg.Size,
		Parent = root,
	})
	self.Holder = holder

	if cfg.Shadow then
		local shadow = New("Frame", {
			Name = "Shadow",
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(-cfg.ShadowSize, -cfg.ShadowSize),
			Size = UDim2.new(1, cfg.ShadowSize * 2, 1, cfg.ShadowSize * 2),
			ZIndex = 1,
			Parent = holder,
		})
		New("UICorner", {
			CornerRadius = UDim.new(0, cfg.ShadowCornerRadius),
			Parent = shadow,
		})
		self.Shadow = shadow
	end

	local card = New("Frame", {
		Name = "Card",
		BackgroundColor3 = C.Card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		ClipsDescendants = true,
		Parent = holder,
	})
	self.Card = card
	self.CardScale = New("UIScale", { Scale = 0.94, Parent = card })

	New("UICorner", {
		CornerRadius = UDim.new(0, cfg.CornerRadius),
		Parent = card,
	})

	self.CardStroke = New("UIStroke", {
		Color = C.Border,
		Thickness = 1,
		Transparency = 0,
		Parent = card,
	})

	local pad = New("UIPadding", {
		PaddingLeft = UDim.new(0, 28),
		PaddingRight = UDim.new(0, 28),
		PaddingTop = UDim.new(0, 26),
		PaddingBottom = UDim.new(0, 22),
		Parent = card,
	})

	local badge = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(30, 27, 75),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(148, 24),
		Position = UDim2.fromOffset(0, 0),
		ZIndex = 5,
		Parent = card,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badge })
	New("UIStroke", {
		Color = C.Primary,
		Thickness = 1,
		Transparency = 0.62,
		Parent = badge,
	})
	table.insert(self.FadeObjects, badge)

	local dot = New("Frame", {
		BackgroundColor3 = C.Primary2,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.new(0, 12, 0.5, -3),
		ZIndex = 6,
		Parent = badge,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })

	local badgeText = New("TextLabel", {
		BackgroundTransparency = 1,
		Font = C.MediumFont,
		Text = cfg.BadgeText,
		TextColor3 = C.Muted,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(24, 0),
		Size = UDim2.new(1, -32, 1, 0),
		ZIndex = 6,
		Parent = badge,
	})
	table.insert(self.FadeObjects, badgeText)

	if cfg.ShowCloseButton then
		local close = New("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Font = C.MediumFont,
			Text = "×",
			TextColor3 = C.Muted,
			TextSize = 18,
			Position = UDim2.new(1, -22, 0, 0),
			Size = UDim2.fromOffset(22, 22),
			ZIndex = 6,
			Parent = card,
		})
		table.insert(self.FadeObjects, close)
		close.MouseEnter:Connect(function()
			Tween(close, self.FastTween, { TextColor3 = C.Text })
		end)
		close.MouseLeave:Connect(function()
			Tween(close, self.FastTween, { TextColor3 = C.Muted })
		end)
		close.MouseButton1Click:Connect(function()
			self:Close()
		end)
	end

	local title = New("TextLabel", {
		BackgroundTransparency = 1,
		Font = C.BoldFont,
		Text = cfg.Title,
		TextColor3 = C.Text,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Position = UDim2.fromOffset(0, 42),
		Size = UDim2.new(1, 0, 0, 32),
		ZIndex = 5,
		Parent = card,
	})
	table.insert(self.FadeObjects, title)

	local sub = New("TextLabel", {
		BackgroundTransparency = 1,
		Font = C.Font,
		Text = cfg.Subtitle,
		TextColor3 = C.Muted,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(0, 77),
		Size = UDim2.new(1, 0, 0, 32),
		ZIndex = 5,
		Parent = card,
	})
	table.insert(self.FadeObjects, sub)

	local label = New("TextLabel", {
		BackgroundTransparency = 1,
		Font = C.MediumFont,
		Text = "ACCESS KEY",
		TextColor3 = C.Muted,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(0, 118),
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 5,
		Parent = card,
	})
	table.insert(self.FadeObjects, label)

	local input = New("TextBox", {
		BackgroundColor3 = C.Card2,
		BorderSizePixel = 0,
		ClearTextOnFocus = cfg.KeyBoxClearTextOnFocus,
		Font = C.CodeFont,
		PlaceholderText = cfg.KeyPlaceholder,
		PlaceholderColor3 = Color3.fromRGB(71, 85, 105),
		Text = "",
		TextColor3 = C.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(0, 137),
		Size = UDim2.new(1, 0, 0, 44),
		ZIndex = 5,
		Parent = card,
	})
	input.TextTransparency = cfg.HideKeyText and 1 or 0
	self.Input = input
	table.insert(self.FadeObjects, input)

	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = input })
	self.InputStroke = New("UIStroke", {
		Color = C.Border,
		Thickness = 1,
		Parent = input,
	})
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = input,
	})

	input.Focused:Connect(function()
		Tween(self.InputStroke, self.FastTween, { Color = C.Primary, Thickness = 2 })
	end)
	input.FocusLost:Connect(function(enter)
		Tween(self.InputStroke, self.FastTween, { Color = C.Border, Thickness = 1 })
		if enter then
			self:_Verify(input.Text, false)
		end
	end)

	local verify = self:_Button(cfg.MainButtonText, cfg.MainButtonIcon, 196, true, function(_, lbl)
		self.VerifyLabel = lbl
		self:_Verify(input.Text, false)
	end)
	self.VerifyLabel = verify.Center.Label

	local y = 262
	if cfg.ShowGetKeyButton then
		local left = New("Frame", {
			BackgroundColor3 = C.Border,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 244),
			Size = UDim2.new(0.42, 0, 0, 1),
			ZIndex = 5,
			Parent = card,
		})
		local orText = New("TextLabel", {
			BackgroundTransparency = 1,
			Font = C.Font,
			Text = "OR",
			TextColor3 = C.Muted,
			TextSize = 10,
			Position = UDim2.new(0.42, 0, 0, 238),
			Size = UDim2.new(0.16, 0, 0, 14),
			ZIndex = 5,
			Parent = card,
		})
		local right = New("Frame", {
			BackgroundColor3 = C.Border,
			BorderSizePixel = 0,
			Position = UDim2.new(0.58, 0, 0, 244),
			Size = UDim2.new(0.42, 0, 0, 1),
			ZIndex = 5,
			Parent = card,
		})
		table.insert(self.FadeObjects, left)
		table.insert(self.FadeObjects, orText)
		table.insert(self.FadeObjects, right)

		self:_Button(cfg.GetKeyButtonText, cfg.GetKeyButtonIcon, y, false, function()
			if cfg.KeyLink ~= "" and setclipboard then
				setclipboard(cfg.KeyLink)
				self:_SetStatus(cfg.StatusCopied, C.Success)
			elseif cfg.KeyLink ~= "" then
				self:_SetStatus(cfg.KeyLink, C.Warning)
			else
				self:_SetStatus("No key link configured.", C.Warning)
			end
		end)
		y += 50
	end

	if cfg.ShowDiscordButton then
		self:_Button(cfg.DiscordButtonText, cfg.DiscordButtonIcon, y, false, function()
			if cfg.Discord ~= "" and setclipboard then
				setclipboard(cfg.Discord)
				self:_SetStatus(cfg.StatusCopied, C.Success)
			elseif cfg.Discord ~= "" then
				self:_SetStatus(cfg.Discord, C.Warning)
			else
				self:_SetStatus(cfg.StatusCopyFail, C.Error)
			end
		end)
		y += 50
	end

	if cfg.ShowDeleteKeyButton then
		self:_Button(cfg.DeleteKeyButtonText, cfg.DeleteKeyButtonIcon, y, false, function()
			self:DeleteSavedKey()
		end)
	end

	local status = New("TextLabel", {
		BackgroundTransparency = 1,
		Font = C.Font,
		Text = cfg.StatusReady,
		TextColor3 = C.Muted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 0, 1, -18),
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 5,
		Parent = card,
	})
	self.Status = status
	table.insert(self.FadeObjects, status)

	if cfg.Draggable then
		local dragging = false
		local startPos
		local startFrame
		local dragInput

		card.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 and inputObject.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local localY = inputObject.Position.Y - card.AbsolutePosition.Y
			if localY > 110 then return end

			dragging = true
			startPos = inputObject.Position
			startFrame = holder.Position

			inputObject.Changed:Connect(function()
				if inputObject.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end)

		UserInputService.InputChanged:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch then
				dragInput = inputObject
			end
			if dragging and inputObject == dragInput then
				local delta = inputObject.Position - startPos
				holder.Position = UDim2.new(
					startFrame.X.Scale,
					startFrame.X.Offset + delta.X,
					startFrame.Y.Scale,
					startFrame.Y.Offset + delta.Y
				)
			end
		end)
	end

	for _, obj in ipairs(self.FadeObjects) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			obj.TextTransparency = 1
		elseif obj:IsA("ImageLabel") then
			obj.ImageTransparency = 1
		end
	end

	local saved = cfg.AutoLoadSavedKey and ReadFile(cfg.KeyFile)
	if saved and saved ~= "" then
		input.Text = saved:gsub("^%s*(.-)%s*$", "%1")
		self:_SetStatus(cfg.StatusLoaded, C.Muted)
		if cfg.AutoCheckSavedKey then
			task.defer(function()
				self:_Verify(input.Text, true)
			end)
		end
	end

	self:Show()
	return self
end

return KeySystem
