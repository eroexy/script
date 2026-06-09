-------------------------->> [Check Running Script] <<--------------------------
if _G.SCRIPT then
	return
end

loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-infinite-yield-131626"))()
YXZ = loadstring(game:HttpGet("https://raw.githubusercontent.com/eroexy/script/refs/heads/main/TestObsidianMX"))()

_G.SCRIPT = true

-------------------------->> [Services] <<--------------------------

Players = game.Players
ReplicatedStorage = game.ReplicatedStorage
Workspace = game.Workspace
RunService = game.RunService
UserInputService = game.UserInputService
HttpService = game.HttpService
Debris = game.Debris
CoreGui = game.CoreGui
Stats = game.Stats
TweenService = game.TweenService

-------------------------->> [Player] <<--------------------------

player = Players.LocalPlayer
char = player.Character or player.CharacterAdded:Wait()
human = char:WaitForChild("Humanoid")
hrp = char:WaitForChild("HumanoidRootPart")
torso = char:WaitForChild("Torso")
head = char:WaitForChild("Head")
camera = Workspace.CurrentCamera
mouse = player:GetMouse()

held = player.IsHeld

-------------------------->> [Game Remotes] <<--------------------------

SpawnToy = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
Destroy = ReplicatedStorage.MenuToys.DestroyToy
GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
SetOwner = GrabEvents:WaitForChild("SetNetworkOwner")
DestroyOwner = GrabEvents:WaitForChild("DestroyGrabLine")
CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
ExtendLine = GrabEvents:WaitForChild("ExtendGrabLine")
use = ReplicatedStorage:WaitForChild("HoldEvents"):WaitForChild("Use")
CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
Struggle = CharacterEvents:WaitForChild("Struggle")
Ragdoll = CharacterEvents:WaitForChild("RagdollRemote")
BombEvents = ReplicatedStorage:WaitForChild("BombEvents")
BombExplode = BombEvents:WaitForChild("BombExplode")

-------------------------->> [Script Functions] <<--------------------------

-- whitelist

WhitelistedPlayers = {}

function GetWhitelistedPlayers()
	local list = {}

	for _, plr in pairs(WhitelistedPlayers) do
		if plr and plr.Parent == Players then
			table.insert(list, plr)
		end
	end

	return list
end

function IsWhitelisted(plr)
	return plr and WhitelistedPlayers[plr.UserId] ~= nil
end

-- player toys

function BackPack(plr)
	plr = plr or player
	local plotItems = game.Workspace:FindFirstChild("PlotItems")
	local playersInPlots = plotItems and plotItems:FindFirstChild("PlayersInPlots")

	if plotItems and playersInPlots then
		for _, value in ipairs(playersInPlots:GetDescendants()) do
			if value:IsA("ObjectValue") and value.Value == plr then
				local plots = game.Workspace:FindFirstChild("Plots")
				if plots then
					for _, plot in ipairs(plots:GetChildren()) do
						local owners = plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("ThisPlotsOwners")
						if owners then
							for _, owner in ipairs(owners:GetDescendants()) do
								if owner:IsA("ObjectValue") and owner.Value == plr then
									local plotBackPack = plotItems:FindFirstChild(plot.Name)
									if plotBackPack then
										return plotBackPack
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return game.Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
end

function GetToyAllContainers()
	local containers = {}

	for _, plrs in ipairs(Players:GetPlayers()) do
		if plrs ~= player then
			local container = nil

			if game.Workspace.PlotItems.PlayersInPlots:FindFirstChild(plrs.Name) then
				for _, plot in pairs(game.Workspace.Plots:GetChildren()) do
					local owners = plot:FindFirstChild("PlotSign")
						and plot.PlotSign:FindFirstChild("ThisPlotsOwners")

					if owners then
						for _, v in pairs(owners:GetChildren()) do
							if v.Value == plrs.Name then
								container = game.Workspace.PlotItems:FindFirstChild(plot.Name)
								break
							end
						end
					end

					if container then
						break
					end
				end
			end

			if not container then
				container = game.Workspace:FindFirstChild(plrs.Name .. "SpawnedInToys")
			end

			if container then
				table.insert(containers, container)
			end
		end
	end

	return containers
end

function GetToyAllContainersWlp()
	local containers = {}

	for _, plrs in ipairs(Players:GetPlayers()) do
		local container = nil

		if game.Workspace.PlotItems.PlayersInPlots:FindFirstChild(plrs.Name) then
			for _, plot in pairs(game.Workspace.Plots:GetChildren()) do
				local owners = plot:FindFirstChild("PlotSign")
					and plot.PlotSign:FindFirstChild("ThisPlotsOwners")

				if owners then
					for _, v in pairs(owners:GetChildren()) do
						if v.Value == plrs.Name then
							container = game.Workspace.PlotItems:FindFirstChild(plot.Name)
							break
						end
					end
				end

				if container then
					break
				end
			end
		end

		if not container then
			container = game.Workspace:FindFirstChild(plrs.Name .. "SpawnedInToys")
		end

		if container then
			table.insert(containers, container)
		end
	end

	return containers
end

function IsOwned()
	local owner = player.Character
		and player.Character:FindFirstChild("Head")
		and player.Character.Head:FindFirstChild("PartOwner")

	if not owner or owner.Value == "" then
		return false
	end

	return true
end

-- cam stuff

-- use
-- StartCamPart()
-- StopCamPart("Default", true)

CamPartSpeed = 24

CamParts = CamParts or {}
CamPartConns = CamPartConns or {}
CamPartHidden = CamPartHidden or {}

function StartCamPart(tag)
	tag = tag or "Default"
	if CamPartConns[tag] then return end

	camera = game.Workspace.CurrentCamera
	CamPartHidden[tag] = CamPartHidden[tag] or {}

	char = player.Character
	if not char then return end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			if v.Transparency < 1 then
				CamPartHidden[tag][v] = v.Transparency
				v.Transparency = 1
			end
		end
	end

	local camPart = Instance.new("Part")
	camPart.Name = "CamPart_" .. tag
	camPart.Size = Vector3.new(1, 1, 1)
	camPart.Transparency = 1
	camPart.Anchored = false
	camPart.CanCollide = false
	camPart.CanTouch = false
	camPart.CanQuery = false
	camPart.CFrame = camera.CFrame
	camPart.Parent = game.Workspace

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Velocity = Vector3.zero
	bv.Parent = camPart

	CamParts[tag] = {Part = camPart, BV = bv}

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = camPart

	CamPartConns[tag] = RunService.RenderStepped:Connect(function()
		char = player.Character
		human = char and char:FindFirstChildOfClass("Humanoid")
		camera = game.Workspace.CurrentCamera

		local data = CamParts[tag]
		if not human or not data or not data.Part or not data.Part.Parent then return end

		local move = human.MoveDirection * CamPartSpeed
		data.BV.Velocity = Vector3.new(move.X, 0, move.Z)

		data.Part.AssemblyLinearVelocity = Vector3.new(
			data.Part.AssemblyLinearVelocity.X,
			0,
			data.Part.AssemblyLinearVelocity.Z
		)

		if camera.CameraSubject ~= data.Part then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = data.Part
		end

		char = player.Character
		if not char then return end

		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then
				if v.Transparency < 1 then
					CamPartHidden[tag][v] = v.Transparency
					v.Transparency = 1
				end
			end
		end
	end)
end

function StopCamPart(tag, teleportToCam)
	tag = tag or "Default"

	local data = CamParts[tag]

	if teleportToCam and data and data.Part then
		local char = player.Character
		local human = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if human and hrp then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.CFrame = data.Part.CFrame * CFrame.new(0, -1.5, 0)
			task.wait()
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.Anchored = false
		end
	end

	if CamPartConns[tag] then
		CamPartConns[tag]:Disconnect()
		CamPartConns[tag] = nil
	end

	if data and data.Part then
		data.Part:Destroy()
	end

	CamParts[tag] = nil

	if CamPartHidden[tag] then
		for v, old in pairs(CamPartHidden[tag]) do
			if v and v.Parent then
				v.Transparency = old
			end
		end
	end

	CamPartHidden[tag] = nil

	local stillActive = false
	for _, activeData in pairs(CamParts) do
		if activeData and activeData.Part and activeData.Part.Parent then
			stillActive = true
			break
		end
	end

	if not stillActive then
		local char = player.Character
		local human = char and char:FindFirstChildOfClass("Humanoid")
		local camera = workspace.CurrentCamera

		if human and camera then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = human
		end
	end
end

-- character

NoClipConn = nil

function StartNoClip()
	local char = player.Character or player.CharacterAdded:Wait()
	NoClipConn = RunService.RenderStepped:Connect(function()
		for _, p in pairs(char:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end)
end

function StopNoClip()
	local char = player.Character or player.CharacterAdded:Wait()

	if NoClipConn then
		NoClipConn:Disconnect()
		NoClipConn = nil
	end

	for _, p in pairs(char:GetChildren()) do
		if p.Name == "HumanoidRootPart" then
			p.CanCollide = true
		end
	end
end
-------------------------->> [Notifs] <<--------------------------

function NormalNotif()
	local sound = Instance.new("Sound")
	sound.Name = "TargetNotif"
	sound.SoundId = "rbxassetid://137874566525685"
	sound.Volume = 1
	sound.Parent = workspace
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function ChatNotif(text)
	pcall(function()
		local TextChatService = game:GetService("TextChatService")
		local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")

		if channel then
			channel:DisplaySystemMessage(tostring(text))
		end
	end)
end

-------------------------->> [Get Executor] <<--------------------------

ExecutorName = "nil"

pcall(function()
	ExecutorName = identifyexecutor()
	if ExecutorName == "nil" then
		ExecutorName = getexecutorname()
	end
end)

-------------------------->> [Loading Libary] <<--------------------------

local WindowSize = UDim2.fromOffset(944, 600)

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	WindowSize = UDim2.fromOffset(622, 300)
else
	WindowSize = UDim2.fromOffset(944, 600)
end

Window = YXZ:CreateWindow({
	Title = "",
	Footer = "<font color='#59b0e2'>YXZ</font>",
	Icon = 72415097921680,

	Size = WindowSize,
	SidebarWidth = 40,

	NotifySide = "Right",
	GlobalSearch = true,
	SidebarCompacted = true,

	ToggleKeybind = Enum.KeyCode.RightShift,
	BackgroundImage = "rbxassetid://94123336211556",
})

Window:SetCornerRadius(16)
Window:SetSidebarWidth(40)

-------------------------->> [Tabs] <<--------------------------

Tab = {
	Main = Window:AddTab("Home", "house"),
	Combat = Window:AddTab("Combat", "swords"),
	Defence = Window:AddTab("Defence", "shield"),
	Aura = Window:AddTab("Aura", "hand"),
	Target = Window:AddTab("Target", "crosshair"),
	Visual = Window:AddTab("Visual", "eye"),
	Misc = Window:AddTab("Misc", "clipboard"),
	Keybind = Window:AddTab("Keybinds", "keyboard"),
	Teleport = Window:AddTab("Teleport", "map"),
	Server = Window:AddTab("Server", "server"),
}

-------------------------->> [FPS/PING WATCH] <<--------------------------

DraggableLabel = YXZ:AddDraggableLabel("YXZ")
DraggableLabel:SetVisible(true)

local frameTimes = {}
local maxSamples = 120

currentFPS = 0
currentPing = 0

RunService.RenderStepped:Connect(function(dt)
	table.insert(frameTimes, dt)

	if #frameTimes > maxSamples then
		table.remove(frameTimes, 1)
	end

	local total = 0

	for i = 1, #frameTimes do
		total += frameTimes[i]
	end

	local avg = total / #frameTimes

	if avg > 0 then
		currentFPS = math.floor((1 / avg) + 0.5)
	end
end)

task.spawn(function()
	while task.wait(0.25) do
		pcall(function()
			local pingString = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()

			currentPing = tonumber(pingString:match("[%d%.]+")) or 0
			currentPing = math.floor(currentPing + 0.5)
		end)

		DraggableLabel:SetText(
			("FPS: %d | Ping: %d ms")
				:format(currentFPS, currentPing)
		)
	end
end)

-------------------------->> [Welcome Message] <<--------------------------

Dialog = Window:AddDialog("WelcomePlayer", {
	Title = "YXZ",
	Description = "you're gay",
	AutoDismiss = true,
	OutsideClickDismiss = true,
	FooterButtons = {
		Confirm = {
			Title = "Confirm",
			Variant = "Primary",
			WaitTime = 0,
			Order = 4,
			Callback = function(self)
				Dialog:Dismiss()
			end
		}
	}
})

-------------------------->> [Home] <<--------------------------

PlayerSection = Tab.Main:AddRightGroupbox("User Info")

MainUser = PlayerSection:AddLabel("User: " .. player.Name)
MainUserAge = PlayerSection:AddLabel("Account age: " .. player.AccountAge .. " Days")
ExecutorHome = PlayerSection:AddLabel("Executor: " .. ExecutorName)

-------------------------->> [Movement] <<--------------------------

MovementSection = Tab.Main:AddRightGroupbox("Movement")

WalkSpeedValue = 16
JumpPowerValue = 24

JPConnection = nil
WSConnection = nil

WalkSpeedSlider = MovementSection:AddSlider("WalkSpeedSlider", {
	Text = "Walkspeed",
	Default = WalkSpeedValue,
	Min = 16,
	Max = 1000,
	Rounding = 0,
	Compact = false,
	Callback = function(Value)
		WalkSpeedValue = Value

		if WSConnection then
			WSConnection:Disconnect()
			WSConnection = nil
		end

		WSConnection = RunService.Stepped:Connect(function()
			local char = player.Character
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum then return end

			local stand = player.PlayerGui:FindFirstChild("ControlsGui")
				and player.PlayerGui.ControlsGui:FindFirstChild("PCFrame")
				and player.PlayerGui.ControlsGui.PCFrame:FindFirstChild("Stand")

			local moveSpeed = stand and stand.Visible and 5 or WalkSpeedValue

			if moveSpeed == 16 then
				return
			end

			local moveDir = hum.MoveDirection

			hrp.Velocity = Vector3.new(
				moveDir.X * moveSpeed,
				hrp.Velocity.Y,
				moveDir.Z * moveSpeed
			)
		end)
	end
})

InfiniteJumpToggle = MovementSection:AddToggle("InfiniteJump", {
	Text = "Infinite Jump",
	Save = true,
	Default = false,
	Callback = function(Value)
		if JPConnection then
			JPConnection:Disconnect()
			JPConnection = nil
		end

		if Value then
			JPConnection = UserInputService.JumpRequest:Connect(function()
				local char = player.Character
				if not char then return end

				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end
	end
})

JumpPowerSlider = MovementSection:AddSlider("JumpPowerSlider", {
	Text = "JumpPower",
	Default = JumpPowerValue,
	Min = 24,
	Max = 1000,
	Rounding = 0,
	Compact = false,
	Callback = function(Value)
		JumpPowerValue = Value

		local char = player.Character
		local hum = char:WaitForChild("Humanoid")

		if hum then
			hum.JumpPower = Value
		end
	end
})

MovementSection:AddButton({
	Text = "Reset Movement",
	Func = function()
		WalkSpeedValue = 16
		JumpPowerValue = 24

		WalkSpeedSlider:SetValue(16)
		JumpPowerSlider:SetValue(24)
	end,
})

-------------------------->> [Character] <<--------------------------

CharacterSection = Tab.Main:AddLeftGroupbox("Character")

CharacterNoClipToggle = false

CharacterNoClipToggle = CharacterSection:AddToggle("CharacterNoClip", {
	Text = "No-Clip",
	Save = true,
	Default = false,
	Callback = function(Value)
		CharacterNoClipToggle = Value
		if CharacterNoClipToggle then
			StartNoClip()
		else
			StopNoClip()
		end
	end
})

player.CharacterAdded:Connect(function(char)
	if CharacterNoClipToggle then
		StartNoClip()
	end
end)

-------------------------->> [Camera] <<--------------------------

CameraSection = Tab.Main:AddLeftGroupbox("Camera")

local SavedTransparency = {}

local function SnapCharacter()
	local char = player.Character
	if not char then return end

	table.clear(SavedTransparency)

	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "TypingKeyboardMyWorld" and part.Transparency < 1 then
			SavedTransparency[part] = part.Transparency
		end
	end
end

local function MakeMeInvisible()
	for part in pairs(SavedTransparency) do
		if part and part.Parent then
			part.Transparency = 1
		end
	end
end

local function MakeMeVisible()
	for part, transparency in pairs(SavedTransparency) do
		if part and part.Parent then
			part.Transparency = transparency
		end
	end
end

SnapCharacter()

ThirdPersonToggle = false
ThirdPersonConn = nil

ThirdPersonToggle = CameraSection:AddToggle("ThirdPerson", {
	Text = "3rd person",
	Default = false,
	Save = true,

	Callback = function(Value)
		_G.ThirdPerson = Value

		if ThirdPersonConn then
			ThirdPersonConn:Disconnect()
			ThirdPersonConn = nil
		end

		if Value then
			SnapCharacter()

			ThirdPersonConn = RunService.Heartbeat:Connect(function()
				player.CameraMode = Enum.CameraMode.Classic
				player.CameraMinZoomDistance = 16
				player.CameraMaxZoomDistance = 120
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

				if player.CameraMinZoomDistance < 1 then
					MakeMeInvisible()
				else
					MakeMeVisible()
				end
			end)
		else
			MakeMeInvisible()

			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			player.CameraMinZoomDistance = 0.5
			player.CameraMaxZoomDistance = 0.5
			player.CameraMode = Enum.CameraMode.LockFirstPerson
		end
	end
})

CameraFOVSlider = CameraSection:AddSlider("CameraFOV", {
	Text = "fov",
	Default = camera and camera.FieldOfView or 70,
	Save = true,
	Min = 30,
	Max = 120,
	Rounding = 0,
	Compact = false,
	Callback = function(Value)
		camera = workspace.CurrentCamera
		if camera then
			camera.FieldOfView = Value
		end
	end
})

CameraSection:AddButton({
	Text = "Reset Settings",
	Func = function()
		camera = workspace.CurrentCamera

		if camera then
			camera.FieldOfView = 70
		end

		CameraFOVSlider:SetValue(70)
	end,
})

-------------------------->> [Combat] <<--------------------------

StrengthSection = Tab.Combat:AddRightGroupbox("Strength")
LineSection = Tab.Combat:AddRightGroupbox("Line")

GrabsSection = Tab.Combat:AddLeftGroupbox("Grabs")

-------------------------->> [Strength] <<--------------------------

Strength = 2500

StrengthEnabled = false
MasslessEnabled = false

StrengthToggle = nil
MasslessToggle = nil

StrengthGrabConn = nil
StrengthHeartbeatConn = nil

StrengthCurrentGrabParts = nil
StrengthCurrentVelocity = nil
StrengthCurrentGrabbed = nil
StrengthOverlay = nil
StrengthOverlayConn = nil

function PosString(pos)
	return tostring(pos.X) .. ", " .. tostring(pos.Y) .. ", " .. tostring(pos.Z)
end

function CleanupStrengthOverlay()
	if StrengthOverlayConn then
		StrengthOverlayConn:Disconnect()
		StrengthOverlayConn = nil
	end

	if StrengthOverlay then
		StrengthOverlay:Destroy()
		StrengthOverlay = nil
	end
end

function ApplyStrengthVelocity(velocity)
	if not velocity or not velocity.Parent then return end
	if not StrengthEnabled then return end

	velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	velocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * Strength

	Debris:AddItem(velocity, 1)
end

function SetOwnerAndExtend(part)
	if not part or not part:IsA("BasePart") then return end

	local pos = part.Position

	pcall(function()
		SetOwner:FireServer(part, part.CFrame)
	end)

	pcall(function()
		ExtendLine:FireServer(part, PosString(pos))
	end)
end

function GetThrowButtonByPosition()
	local success, button = pcall(function()
		return Players.LocalPlayer.PlayerGui.ContextActionGui.ContextButtonFrame:GetChildren()[3]
	end)

	if not success or not button or not button:IsA("GuiObject") then
		return nil
	end

	local pos = button.AbsolutePosition

	if math.floor(pos.X) == 664 and math.floor(pos.Y) == 207 then
		return button
	end

	return nil
end

function CreateThrowOverlay(button)
	if not button or not button:IsA("GuiObject") then return end
	if StrengthOverlay and StrengthOverlay.Parent == button then return end

	CleanupStrengthOverlay()

	StrengthOverlay = Instance.new("TextButton")
	StrengthOverlay.Name = "StrengthThrowOverlay"
	StrengthOverlay.BackgroundTransparency = 1
	StrengthOverlay.TextTransparency = 1
	StrengthOverlay.Text = ""
	StrengthOverlay.AutoButtonColor = false
	StrengthOverlay.BorderSizePixel = 0
	StrengthOverlay.Size = UDim2.fromScale(1, 1)
	StrengthOverlay.Position = UDim2.fromScale(0, 0)
	StrengthOverlay.ZIndex = 999999
	StrengthOverlay.Active = true
	StrengthOverlay.Parent = button

	button.Active = true

	StrengthOverlayConn = StrengthOverlay.MouseButton1Down:Connect(function()
		if not StrengthEnabled then return end
		if not StrengthCurrentVelocity then return end

		local grabbed = StrengthCurrentGrabbed or StrengthCurrentVelocity.Parent
		if not grabbed or not grabbed:IsA("BasePart") then return end

		SetOwnerAndExtend(grabbed)
		ApplyStrengthVelocity(StrengthCurrentVelocity)
	end)
end

if StrengthHeartbeatConn then
	StrengthHeartbeatConn:Disconnect()
	StrengthHeartbeatConn = nil
end

StrengthHeartbeatConn = RunService.Heartbeat:Connect(function()
	if not StrengthEnabled then
		CleanupStrengthOverlay()
		return
	end

	if not StrengthCurrentGrabParts or not StrengthCurrentGrabParts.Parent then
		CleanupStrengthOverlay()
		return
	end

	local button = GetThrowButtonByPosition()

	if button then
		CreateThrowOverlay(button)
	else
		CleanupStrengthOverlay()
	end
end)

if StrengthGrabConn then
	StrengthGrabConn:Disconnect()
	StrengthGrabConn = nil
end

StrengthGrabConn = workspace.ChildAdded:Connect(function(GParts)
	if not StrengthEnabled then return end
	if GParts.Name ~= "GrabParts" then return end

	local grabPart = GParts:WaitForChild("GrabPart", 1)
	if not grabPart then return end

	local weld = grabPart:WaitForChild("WeldConstraint", 1)
	if not weld or not weld.Part1 or not weld.Part1:IsA("BasePart") then return end

	local grabbed = weld.Part1

	local velocity = Instance.new("BodyVelocity")
	velocity.Name = "SuperStrength"
	velocity.MaxForce = Vector3.new(0, 0, 0)
	velocity.Velocity = Vector3.new(0, 0, 0)
	velocity.Parent = grabbed

	StrengthCurrentGrabParts = GParts
	StrengthCurrentGrabbed = grabbed
	StrengthCurrentVelocity = velocity

	local parentConn
	parentConn = GParts:GetPropertyChangedSignal("Parent"):Connect(function()
		if GParts.Parent == nil then
			if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 and StrengthEnabled then
				SetOwnerAndExtend(grabbed)
				task.wait()
				ApplyStrengthVelocity(velocity)
			else
				if velocity and velocity.Parent then
					velocity:Destroy()
				end
			end

			CleanupStrengthOverlay()

			if StrengthCurrentGrabParts == GParts then
				StrengthCurrentGrabParts = nil
				StrengthCurrentGrabbed = nil
				StrengthCurrentVelocity = nil
			end

			if parentConn then
				parentConn:Disconnect()
				parentConn = nil
			end
		end
	end)
end)

StrengthSlider = StrengthSection:AddSlider("StrengthPower", {
	Text = "Power",
	Save = true,
	Default = Strength,
	Min = 100,
	Max = 10000,
	Rounding = 0,
	Compact = false,
	Callback = function(v)
		Strength = v
	end
})

StrengthToggle = StrengthSection:AddToggle("Strength", {
	Text = "Strength",
	Save = true,
	Default = false,
	Callback = function(v)
		StrengthEnabled = v

		if not StrengthEnabled then
			CleanupStrengthOverlay()

			if StrengthCurrentVelocity and StrengthCurrentVelocity.Parent then
				StrengthCurrentVelocity:Destroy()
			end

			StrengthCurrentGrabParts = nil
			StrengthCurrentGrabbed = nil
			StrengthCurrentVelocity = nil
		end
	end
})

function ApplyMassless(dragPart)
	if not dragPart or not dragPart:IsA("BasePart") then return end
	if not MasslessEnabled then return end

	local alignO = dragPart:FindFirstChild("AlignOrientation")
	local alignP = dragPart:FindFirstChild("AlignPosition")

	if alignO then
		alignO.MaxTorque = math.huge
		alignO.Responsiveness = 200
	end

	if alignP then
		alignP.MaxForce = math.huge
		alignP.Responsiveness = 200
	end
end

workspace.ChildAdded:Connect(function(GParts)
	if not MasslessEnabled then return end
	if GParts.Name ~= "GrabParts" then return end

	local dragPart = GParts:WaitForChild("DragPart", 1)
	if dragPart then
		ApplyMassless(dragPart)
	end
end)

MasslessToggle = StrengthSection:AddToggle("Massless", {
	Text = "Massless",
	Save = true,
	Default = false,
	Callback = function(v)
		MasslessEnabled = v
	end
})

-------------------------->> [Grabs] <<--------------------------

NoClipGrabConn = nil
NoClipGrabLoop = nil
NoClipGrabSaved = {}
NoClipGrabSeen = {}

function NoClipGrabIgnored(obj)
	while obj and obj ~= game.Workspace do
		if obj.Name == "Map" or obj.Name == "Plots" or obj.Name == "Slots" or obj.Name == "Bubble" then
			return true
		end
		obj = obj.Parent
	end
end

function NoClipGrabPart(part)
	if not part or not part:IsA("BasePart") or NoClipGrabIgnored(part) then return end
	if NoClipGrabSaved[part] == nil then NoClipGrabSaved[part] = part.CanCollide end
	NoClipGrabSeen[part] = tick()
	part.CanCollide = false
end

function NoClipGrabScan(obj)
	if not _G.NoClipGrabToggle or not obj or obj.Name ~= "GrabParts" then return end

	for _, v in ipairs(obj:GetDescendants()) do
		NoClipGrabPart(v)
	end

	local grab = obj:FindFirstChild("GrabPart")
	local weld = grab and grab:FindFirstChild("WeldConstraint")
	local held = weld and weld.Part1

	if held and held.Parent then
		for _, v in ipairs(held.Parent:GetDescendants()) do
			NoClipGrabPart(v)
		end
	end
end

NoClipGrabToggle = GrabsSection:AddToggle("NoClipGrab", {
	Text = "No-Clip",
	Save = true,
	Default = false,
	Callback = function(v)
		_G.NoClipGrabToggle = v

		if NoClipGrabConn then NoClipGrabConn:Disconnect() NoClipGrabConn = nil end
		if NoClipGrabLoop then NoClipGrabLoop:Disconnect() NoClipGrabLoop = nil end

		if not v then
			for part, old in pairs(NoClipGrabSaved) do
				if part and part.Parent then part.CanCollide = old end
			end
			NoClipGrabSaved = {}
			NoClipGrabSeen = {}
			return
		end

		NoClipGrabConn = game.Workspace.ChildAdded:Connect(function(obj)
			task.wait()
			NoClipGrabScan(obj)
		end)

		NoClipGrabLoop = RunService.Heartbeat:Connect(function()
			for _, obj in ipairs(game.Workspace:GetChildren()) do
				NoClipGrabScan(obj)
			end

			for part, t in pairs(NoClipGrabSeen) do
				if tick() - t > 0.5 then
					if part and part.Parent and NoClipGrabSaved[part] ~= nil then
						part.CanCollide = NoClipGrabSaved[part]
					end
					NoClipGrabSaved[part] = nil
					NoClipGrabSeen[part] = nil
				end
			end
		end)
	end
})

-------------------------->> [Death Grab] <<--------------------------

bodyparts = {
	"Head",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
	"Torso",
	"HumanoidRootPart"
}

DeathGrabConn = nil

DeathGrabToggle = GrabsSection:AddToggle("DeathGrab", {
	Text = "Death",
	Save = true,
	Default = false,
	Callback = function(v)
		DeathGrabToggle = v

		if not DeathGrabToggle then
			if DeathGrabConn then
				DeathGrabConn:Disconnect()
				DeathGrabConn = nil
			end
			return
		end

		DeathGrabConn = game.Workspace.ChildAdded:Connect(function(GParts)
			if GParts.Name ~= "GrabParts" then return end

			local grabPart = GParts:WaitForChild("GrabPart", 1)
			if not grabPart then return end

			local weld = grabPart:WaitForChild("WeldConstraint", 1)
			if not weld or not weld.Part1 then return end

			local grabbed = weld.Part1
			if not grabbed or not table.find(bodyparts, grabbed.Name) then return end

			if DeathGrabToggle then
				local tHUM = grabbed.Parent and grabbed.Parent:FindFirstChildOfClass("Humanoid")

				task.spawn(function()
					tHUM.BreakJointsOnDeath = false
					tHUM.Health = 0

					task.wait(0.05)

					pcall(function()
						SetOwner:FireServer(grabbed)
					end)

					task.wait(0.05)

					pcall(function()
						DestroyOwner:FireServer(grabbed)
					end)

					task.wait(1)

					tHUM.Health = 100
				end)
			end
		end)
	end
})

-------------------------->> [Heaven Grab] <<--------------------------

HeavenGrabConn = nil

HeavenGrabToggle = GrabsSection:AddToggle("HeavenGrab", {
	Text = "Heaven ( <font color=\"rgb(219, 30, 30)\">KICK</font> )",
	Default = false,
	Save = true,
	Callback = function(v)
		HeavenGrabToggle = v
		
		if not HeavenGrabToggle then
			if HeavenGrabConn then
				HeavenGrabConn:Disconnect()
				HeavenGrabConn = nil
			end
			return
		end
		
		HeavenGrabConn = game.Workspace.ChildAdded:Connect(function(GParts)
			if GParts.Name ~= "GrabParts" then return end

			local grabPart = GParts:WaitForChild("GrabPart", 1)
			if not grabPart then return end

			local weld = grabPart:WaitForChild("WeldConstraint", 1)
			if not weld or not weld.Part1 then return end

			local grabbed = weld.Part1
			if not grabbed or not table.find(bodyparts, grabbed.Name) then return end

			if HeavenGrabToggle then
				local tHUM = grabbed.Parent and grabbed.Parent:FindFirstChildOfClass("Humanoid")

				task.spawn(function()
					pcall(function()
						DestroyOwner:FireServer(grabbed)
					end)

					task.wait(0.05)

					pcall(function()
						SetOwner:FireServer(grabbed)
					end)

					grabbed.CFrame = CFrame.new (0, 1e9, 0)
				end)
			end
		end)
	end
})

-------------------------->> [Invisible Line] <<--------------------------

_G.InvisbleLineToggle = false
InvisbleLineConn = nil

InvisibleLineToggle = LineSection:AddToggle("InvisibleLine", {
	Text = "Invisible Line",
	Default = false,
	Save = true,
	Callback = function(Value)
		_G.InvisbleLineToggle = Value

		if Value then
			if InvisbleLineConn then
				InvisbleLineConn:Disconnect()
				InvisbleLineConn = nil
			end

			InvisbleLineConn = RunService.Heartbeat:Connect(function()
				for _, grabParts in ipairs(game.Workspace:GetChildren()) do
					if grabParts.Name == "GrabParts" then
						local gp = grabParts:FindFirstChild("GrabPart")

						if gp then
							pcall(function()
								DestroyOwner:FireServer(gp)
							end)
						end
					end
				end
			end)
		else
			if InvisbleLineConn then
				InvisbleLineConn:Disconnect()
				InvisbleLineConn = nil
			end
		end
	end
})

-------------------------->> [Defence] <<--------------------------

ProtectionSection = Tab.Defence:AddLeftGroupbox("Protection")

ThirdPartyProtectionSection = Tab.Defence:AddRightGroupbox("Third Party Protection")

AntiGrabGucciSection = Tab.Defence:AddRightGroupbox("Gucci")

AntiKickSection = Tab.Defence:AddLeftGroupbox("Anti-Kick")

AutoSpawnSection = Tab.Defence:AddLeftGroupbox("Spawn Location")

AntiInputSection = Tab.Defence:AddRightGroupbox("Anti-Input")

AntiLagSection = Tab.Defence:AddRightGroupbox("Anti-Lag")

-------------------------->> [Anti-Grab] <<--------------------------

AntiGrabToggle = false
AntiGrabConn = nil

function PerformEscape()
	local hrp = player.Character:WaitForChild("HumanoidRootPart")
	StartCamPart("AntiGrab")

	hrp.Anchored = true
	hrp.AssemblyLinearVelocity = Vector3.zero

	Struggle:FireServer()
	Ragdoll:FireServer(hrp, 0)
end

function PerformRestore()
	local hrp = player.Character:WaitForChild("HumanoidRootPart")
	hrp.Anchored = false
	StopCamPart("AntiGrab", true)
end

AntiGrabToggle = ProtectionSection:AddToggle("AntiGrab", {
	Text = "Anti-Grab",
	Save = true,
	Default = false,
	Callback = function(Value)
		AntiGrabToggle = Value

		if AntiGrabConn then
			AntiGrabConn:Disconnect()
			AntiGrabConn = nil
		end

		AntiGrabConn = RunService.Stepped:Connect(function()
			if AntiGrabToggle then
				local hum = player.Character:WaitForChild("Humanoid")
				if hum.Health ~= 0 then

					local hrp = player.Character:WaitForChild("HumanoidRootPart")
					if not hrp then return end

					if IsOwned() or held.Value == true then
						PerformEscape()
					else
						PerformRestore()
					end
				end
			end
		end)
	end
})

-------------------------->> [Anti-Blobman] <<--------------------------

antiblob = false
antiblobConn = nil

AntiBlobmanToggle = ProtectionSection:AddToggle("AntiBlobman", {
	Text = "Anti-Blobman",
	Save = true,
	Default = false,
	Callback = function(v)
		antiblob = v

		if antiblobConn then
			antiblobConn:Disconnect()
			antiblobConn = nil
		end

		if v then
			task.spawn(function()
				while antiblob do
					local char = player.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")

					if char and hrp then
						local tp = char:FindFirstChild("TruePositionPart") or Instance.new("Part")
						tp.Name = "TruePositionPart"
						tp.Anchored = true
						tp.CanCollide = false
						tp.Transparency = 1
						tp.Size = Vector3.new(1, 1, 1)
						tp.CFrame = CFrame.new(0, -100, 0)
						tp.Parent = char

						for _, p in pairs(char:GetChildren()) do
							if p:IsA("BasePart") and p.Massless then
								p.Massless = false

								for _, folder in pairs(game.Workspace.PlotItems:GetChildren()) do
									if folder.Name ~= "PlayersInPlots" then
										for _, blob in pairs(folder:GetChildren()) do
											if blob.Name == "CreatureBlobman" then
												pcall(function()
													local s = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
													local d = blob:FindFirstChild("RightDetector")
													local drop = s and s:FindFirstChild("CreatureDrop")
													local weld = d and d:FindFirstChild("RightWeld")
													if drop and weld then
														drop:FireServer(weld, hrp)
														ReplicatedStorage.CharacterEvents.Struggle:FireServer(player)
													end
												end)
											end
										end
									end
								end

								for _, plr in pairs(Players:GetPlayers()) do
									local toys = game.Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
									if toys then
										for _, blob in pairs(toys:GetChildren()) do
											if blob.Name == "CreatureBlobman" then
												pcall(function()
													local s = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
													local d = blob:FindFirstChild("RightDetector")
													local drop = s and s:FindFirstChild("CreatureDrop")
													local weld = d and d:FindFirstChild("RightWeld")
													if drop and weld then
														drop:FireServer(weld, hrp)
														ReplicatedStorage.CharacterEvents.Struggle:FireServer(player)
													end
												end)
											end
										end
									end
								end
							end
						end

						local att = hrp:FindFirstChild("RootAttachment")
						if att and not tp:FindFirstChild("RootAttachment") then
							task.wait(0.2)
							att.Parent = tp
						end
					end

					task.wait(0.1)
				end
			end)

			antiblobConn = player.CharacterAdded:Connect(function()
				task.wait(1)
			end)
		else
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local tp = char and char:FindFirstChild("TruePositionPart")
			local att = tp and tp:FindFirstChild("RootAttachment")

			if hrp and att then
				att.Parent = hrp
			end

			if tp then
				tp:Destroy()
			end
		end
	end
})

-------------------------->> [Anti-Banana] <<--------------------------

_G.DestroyLimbsConn = nil
_G.DestroyLegsToggle = false
_G.AntiBananaBusy = false

AntiBananaToggle = ProtectionSection:AddToggle("AntiBanana", {
	Text = "Anti-Banana",
	Save = true,
	Default = false,

	Callback = function(v)
		_G.DestroyLegsToggle = v

		char = player.Character
		human = char and char:FindFirstChild("Humanoid")
		hrp = char and char:FindFirstChild("HumanoidRootPart")

		if not v then return end

		if v and not _G.AntiBananaBusy then
			_G.AntiBananaBusy = true

			if char and human and hrp and (char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")) then
				local savedCF = hrp.CFrame

				Ragdoll:FireServer(hrp, 0.5)
				task.wait(0.3)

				for _, name in ipairs({"Right Leg", "Left Leg"}) do
					local leg = char:FindFirstChild(name)
					if leg then
						leg.CFrame = CFrame.new(leg.Position.X, -100000, leg.Position.Z)
					end
				end

				task.wait(0.2)

				hrp.Anchored = true
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero

				human.Sit = false
				human.PlatformStand = false
				human.AutoRotate = true
				human.HipHeight = 2

				hrp.CFrame = savedCF

				task.wait()

				hrp.Anchored = false
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero

				SetOwner:FireServer(hrp, hrp.CFrame)
			end

			_G.AntiBananaBusy = false
		end

		if not _G.DestroyLimbsConn then
			_G.DestroyLimbsConn = RunService.Heartbeat:Connect(function()
				char = player.Character
				human = char and char:FindFirstChild("Humanoid")
				hrp = char and char:FindFirstChild("HumanoidRootPart")

				if not char or not human then return end

				local hasLegs = char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")

				if hasLegs then
					human.HipHeight = 0

					if not _G.DestroyLegsToggle then
						_G.DestroyLimbsConn:Disconnect()
						_G.DestroyLimbsConn = nil
					end

					return
				end

				local stand = player.PlayerGui:FindFirstChild("ControlsGui")
					and player.PlayerGui.ControlsGui:FindFirstChild("PCFrame")
					and player.PlayerGui.ControlsGui.PCFrame:FindFirstChild("Stand")

				local newHeight = stand and stand.Visible == false and 2 or 0
				human.HipHeight = newHeight

				if newHeight == 2 then
					human.PlatformStand = false
					human.AutoRotate = true
				end

				if _G.DestroyLegsToggle and human.Health <= 0 and not _G.AntiBananaBusy then
					_G.AntiBananaBusy = true
					task.wait(0.5)

					char = player.Character
					human = char and char:FindFirstChild("Humanoid")
					hrp = char and char:FindFirstChild("HumanoidRootPart")

					if char and human and hrp and (char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")) then
						local savedCF = hrp.CFrame

						Ragdoll:FireServer(hrp, 0.5)
						task.wait(0.3)

						for _, name in ipairs({"Right Leg", "Left Leg"}) do
							local leg = char:FindFirstChild(name)
							if leg then
								leg.CFrame = CFrame.new(leg.Position.X, -100000, leg.Position.Z)
							end
						end

						task.wait(0.2)

						hrp.Anchored = true
						human.HipHeight = 2
						hrp.CFrame = savedCF
						task.wait()
						hrp.Anchored = false
						SetOwner:FireServer(hrp, hrp.CFrame)
					end

					_G.AntiBananaBusy = false
				end
			end)
		end
	end
})

-------------------------->> [Anti-Explode] <<--------------------------

AntiExplosionToggle = false
AntiExplodeConn = nil
AntiExplodeBusy = false

AntiExplodeToggle = ProtectionSection:AddToggle("AntiExplosion", {
	Text = "Anti-Explode",
	Save = true,
	Default = false,

	Callback = function(v)
		AntiExplosionToggle = v

		if AntiExplodeConn then
			AntiExplodeConn:Disconnect()
			AntiExplodeConn = nil
		end

		if not v then
			StopCamPart("AntiExplode", false)
			return
		end

		AntiExplodeConn = game.Workspace.ChildAdded:Connect(function(model)
			if not AntiExplosionToggle or AntiExplodeBusy then return end
			if not model:IsA("BasePart") then return end

			char = player.Character
			human = char and char:FindFirstChildOfClass("Humanoid")
			hrp = char and char:FindFirstChild("HumanoidRootPart")
			head = char and char:FindFirstChild("Head")

			if not char or not human or not hrp or not head then return end
			if (model.Position - hrp.Position).Magnitude > 20 then return end

			AntiExplodeBusy = true

			hrp.Anchored = true
			task.wait()
			if not AntiGrabGucciToggle or ztp then
				StartCamPart("AntiExplode")
			end

			local ball
			local t = 0

			repeat
				head = char and char:FindFirstChild("Head")
				ball = head and head:FindFirstChild("BallSocketConstraint")
				t += task.wait()
			until not AntiExplosionToggle or (ball and ball.Enabled) or t > 0.5

			t = 0

			repeat
				head = char and char:FindFirstChild("Head")
				ball = head and head:FindFirstChild("BallSocketConstraint")
				t += task.wait()
			until not AntiExplosionToggle or (ball and not ball.Enabled) or t > 1.5

			if not AntiGrabGucciToggle or ztp then
				StopCamPart("AntiExplode", true)
			end

			AntiExplodeBusy = false
		end)
	end,
})

-------------------------->> [AntiGrabGucci] <<--------------------------

AntiGrabGucciMode = AntiGrabGucciMode or "Blobman"
_G.AntiGrabGucciToggle = false
_G.AntiGrabGucciToken = _G.AntiGrabGucciToken or 0

AntiGrabGucciConn = nil
AntiGrabGucciWatchDeath = nil
AntiGrabGucciWatchItem = nil
AntiGrabGucciItem = nil
AntiGrabGucciSetupDone = false
AntiGrabGucciRestarting = false
AntiGrabGucciSpawnedToy = false

AntiGrabGucciDropdown = AntiGrabGucciSection :AddDropdown("AntiGrabGucciMode", {
	Text = "Gucci Method",
	Save = true,
	Values = {"Blobman", "TractorGreen", "TractorOrange", "TractorRed", "Train", "Farm Tractor"},
	Default = 1,
	Multi = false,
})

AntiGrabGucciDropdown:OnChanged(function(v)
	AntiGrabGucciMode = v

	if _G.AntiGrabGucciToggle then
		_G.AntiGrabGucciToken += 1

		if AntiGrabGucciConn then AntiGrabGucciConn:Disconnect() AntiGrabGucciConn = nil end
		if AntiGrabGucciWatchDeath then AntiGrabGucciWatchDeath:Disconnect() AntiGrabGucciWatchDeath = nil end
		if AntiGrabGucciWatchItem then AntiGrabGucciWatchItem:Disconnect() AntiGrabGucciWatchItem = nil end

		StopCamPart("AntiGrabGucci", false)

		AntiGrabGucciToggle:SetValue(false)
		task.wait(0.04)
		AntiGrabGucciToggle:SetValue(true)
	end
end)

AntiGrabGucciToggle = AntiGrabGucciSection :AddToggle("AntiGrabGucci", {
	Text = "AntiGrabGucci",
	Save = true,
	Default = false,

	Callback = function(v)
		_G.AntiGrabGucciToggle = v
		_G.AntiGrabGucciToken += 1

		local token = _G.AntiGrabGucciToken

		if AntiGrabGucciConn then AntiGrabGucciConn:Disconnect() AntiGrabGucciConn = nil end
		if AntiGrabGucciWatchDeath then AntiGrabGucciWatchDeath:Disconnect() AntiGrabGucciWatchDeath = nil end
		if AntiGrabGucciWatchItem then AntiGrabGucciWatchItem:Disconnect() AntiGrabGucciWatchItem = nil end

		StopCamPart("AntiGrabGucci", false)

		local ch = player.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local root = ch and ch:FindFirstChild("HumanoidRootPart")

		if root then
			root.Anchored = false
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end

		if not v then
			if hum then
				for i = 1, 30 do
					hum.Sit = true
					task.wait()
					hum.Sit = false
				end
			end

			if AntiGrabGucciItem and AntiGrabGucciItem.Parent and AntiGrabGucciSpawnedToy then
				pcall(function()
					Destroy:FireServer(AntiGrabGucciItem)
				end)
			end

			AntiGrabGucciItem = nil
			AntiGrabGucciSetupDone = false
			AntiGrabGucciRestarting = false
			AntiGrabGucciSpawnedToy = false
			return
		end

		AntiGrabGucciItem = nil
		AntiGrabGucciSetupDone = false
		AntiGrabGucciRestarting = false
		AntiGrabGucciSpawnedToy = false

		task.spawn(function()
			ch = player.Character or player.CharacterAdded:Wait()
			hum = ch:WaitForChild("Humanoid")
			root = ch:WaitForChild("HumanoidRootPart")

			local inv = BackPack(player)
			if not inv then return end

			local function getMain(model)
				return model and (
					model:FindFirstChild("Main", true)
						or model.PrimaryPart
						or model:FindFirstChildWhichIsA("BasePart", true)
				)
			end

			local function findSeat(model)
				if not model then return end

				for _, x in ipairs(model:GetDescendants()) do
					if (x:IsA("Seat") or x:IsA("VehicleSeat")) and not x.Occupant then
						return x
					end
				end
			end

			local function setupSeat(item, seat)
				if not _G.AntiGrabGucciToggle or _G.AntiGrabGucciToken ~= token then return end

				ch = player.Character or player.CharacterAdded:Wait()
				hum = ch:WaitForChild("Humanoid")
				root = ch:WaitForChild("HumanoidRootPart")

				local safeCF = root.CFrame

				StartCamPart("AntiGrabGucci")

				root.Anchored = true
				root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero

				task.wait()

				root.Anchored = false
				seat:Sit(hum)

				if AntiGrabGucciConn then AntiGrabGucciConn:Disconnect() AntiGrabGucciConn = nil end

				AntiGrabGucciConn = RunService.Heartbeat:Connect(function()
					if not _G.AntiGrabGucciToggle or _G.AntiGrabGucciToken ~= token then return end
					pcall(function()
						Ragdoll:FireServer(root, 0)
					end)
				end)

				task.delay(0.12, function()
					if not _G.AntiGrabGucciToggle or _G.AntiGrabGucciToken ~= token then return end
					if not item or not item.Parent or not root or not hum then return end

					hum:ChangeState(Enum.HumanoidStateType.Jumping)
					repeat
						task.wait()
					until not hum.Sit

					task.wait(0.02)

					root.Anchored = true
					root.CFrame = safeCF
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero

					task.delay(0.06, function()
						if not item or not item.Parent then return end

						hum.Sit = false
						hum:ChangeState(Enum.HumanoidStateType.Jumping)

						task.wait(0.3)

						if AntiGrabGucciMode == "Blobman" then
							local currentSeat = item:FindFirstChild("VehicleSeat")
							if currentSeat then
								currentSeat:Destroy()
							end
						end

						if AntiGrabGucciConn then
							AntiGrabGucciConn:Disconnect()
							AntiGrabGucciConn = nil
						end

						root.Anchored = false
						root.CFrame = safeCF
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero

						StopCamPart("AntiGrabGucci", false)

						AntiGrabGucciSetupDone = true
					end)
				end)
			end

			if AntiGrabGucciMode == "Train" then
				local map = game.Workspace:FindFirstChild("Map")
				local always = map and map:FindFirstChild("AlwaysHereTweenedObjects")
				local train = always and always:FindFirstChild("Train")
				local obj = train and train:FindFirstChild("Object")
				local trainModel = obj and obj:FindFirstChild("ObjectModel")
				local seat = findSeat(trainModel)

				if trainModel and seat then
					AntiGrabGucciItem = trainModel
					AntiGrabGucciSpawnedToy = false
					setupSeat(trainModel, seat)
				end

				return
			end

			if AntiGrabGucciMode == "Farm Tractor" then
				local farm = game.Workspace:FindFirstChild("Farm")
				local tractor = farm and farm:FindFirstChild("TractorGreen")
				local seat = findSeat(tractor)

				if tractor and seat then
					AntiGrabGucciItem = tractor
					AntiGrabGucciSpawnedToy = false

					pcall(function()
						tractor:PivotTo(CFrame.new(0, 1e18, 0))
					end)

					local main = getMain(tractor)
					if main then
						for i = 1, 5 do
							main.Anchored = true
							main.AssemblyLinearVelocity = Vector3.zero
							main.AssemblyAngularVelocity = Vector3.zero
							RunService.Heartbeat:Wait()
						end
					end

					setupSeat(tractor, seat)
				end

				return
			end

			local toyName = AntiGrabGucciMode == "Blobman" and "CreatureBlobman" or AntiGrabGucciMode
			local old = {}

			for _, x in ipairs(inv:GetChildren()) do
				if x.Name == toyName or x.Name == "AntiGrabGucci" then
					old[x] = true
				end
			end

			task.spawn(function()
				pcall(function()
					SpawnToy:InvokeServer(toyName, CFrame.new(0, 50, 1e9), Vector3.new(0, 60, 0))
				end)
			end)

			local start = tick()

			repeat
				for _, x in ipairs(inv:GetChildren()) do
					if x.Name == toyName and not old[x] and x:FindFirstChild("VehicleSeat") then
						AntiGrabGucciItem = x
						break
					end
				end

				RunService.Heartbeat:Wait()
			until AntiGrabGucciItem or tick() - start > 0.7 or not _G.AntiGrabGucciToggle or _G.AntiGrabGucciToken ~= token

			if not _G.AntiGrabGucciToggle or _G.AntiGrabGucciToken ~= token then
				StopCamPart("AntiGrabGucci", false)
				return
			end

			if not AntiGrabGucciItem then
				StopCamPart("AntiGrabGucci", false)
				return
			end

			task.wait(0.03)

			AntiGrabGucciSpawnedToy = true
			AntiGrabGucciItem.Name = "AntiGrabGucci"

			local main = getMain(AntiGrabGucciItem)
			if main and AntiGrabGucciMode ~= "Blobman" then
				for i = 1, 5 do
					main.Anchored = true
					main.AssemblyLinearVelocity = Vector3.zero
					main.AssemblyAngularVelocity = Vector3.zero
					RunService.Heartbeat:Wait()
				end
			end

			local seat = AntiGrabGucciItem:FindFirstChild("VehicleSeat")
			if not seat then
				StopCamPart("AntiGrabGucci", false)
				return
			end

			setupSeat(AntiGrabGucciItem, seat)
		end)

		AntiGrabGucciWatchDeath = hum and hum.Died:Connect(function()
			if not _G.AntiGrabGucciToggle or AntiGrabGucciRestarting then return end
			AntiGrabGucciRestarting = true

			if AntiGrabGucciConn then AntiGrabGucciConn:Disconnect() AntiGrabGucciConn = nil end
			StopCamPart("AntiGrabGucci", false)

			if AntiGrabGucciItem and AntiGrabGucciItem.Parent and AntiGrabGucciSpawnedToy then
				pcall(function()
					Destroy:FireServer(AntiGrabGucciItem)
				end)
			end

			AntiGrabGucciItem = nil
			AntiGrabGucciSetupDone = false
			AntiGrabGucciSpawnedToy = false

			player.CharacterAdded:Wait()
			task.wait(0.05)

			if _G.AntiGrabGucciToggle and _G.AntiGrabGucciToken == token then
				AntiGrabGucciToggle:SetValue(false)
				task.wait(0.04)
				AntiGrabGucciToggle:SetValue(true)
			end

			AntiGrabGucciRestarting = false
		end)

		AntiGrabGucciWatchItem = RunService.Heartbeat:Connect(function()
			if not _G.AntiGrabGucciToggle or AntiGrabGucciRestarting then return end
			if not AntiGrabGucciItem then return end

			local exists = AntiGrabGucciItem and AntiGrabGucciItem.Parent

			if AntiGrabGucciSpawnedToy then
				exists = AntiGrabGucciItem and AntiGrabGucciItem.Parent and AntiGrabGucciItem.Name == "AntiGrabGucci"
			end

			if not exists then
				AntiGrabGucciRestarting = true

				if AntiGrabGucciConn then AntiGrabGucciConn:Disconnect() AntiGrabGucciConn = nil end
				StopCamPart("AntiGrabGucci", false)

				local currentChar = player.Character
				local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")

				if currentHum and AntiGrabGucciSetupDone then
					for i = 1, 30 do
						currentHum.Sit = true
						task.wait()
						currentHum.Sit = false
					end
				end

				AntiGrabGucciItem = nil
				AntiGrabGucciSetupDone = false
				AntiGrabGucciSpawnedToy = false

				task.wait(0.05)

				if _G.AntiGrabGucciToggle and _G.AntiGrabGucciToken == token then
					AntiGrabGucciToggle:SetValue(false)
					task.wait()
					AntiGrabGucciToggle:SetValue(true)
				end

				AntiGrabGucciRestarting = false
			end
		end)
	end
})

-------------------------->> [Anti-Burn] <<--------------------------

local AntiFirePart = game.Workspace.Map.FactoryIsland.PoisonContainer.ExtinguishPart

AntiBurnToggle = false
AntiBurnConn = nil

local oldABPcf = AntiFirePart.CFrame
local oldABPsize = AntiFirePart.Size

AntiBurnToggle = ProtectionSection:AddToggle("AntiBurn", {
	Text = "Anti-Burn",
	Save = true,
	Default = false,
	Callback = function(Value)
		AntiBurnToggle = Value

		if AntiBurnConn then
			AntiBurnConn:Disconnect()
			AntiBurnConn = nil
		end

		local BurnAnim = char:FindFirstChild("OnFireAnimationScript")

		if BurnAnim then
			BurnAnim.Disabled = Value
		end

		AntiBurnConn = RunService.Heartbeat:Connect(function()
			if AntiBurnToggle then
				local char = player.Character
				local OnFire = char:WaitForChild("HumanoidRootPart"):WaitForChild("FirePlayerPart").CanBurn.Value

				if OnFire then
					task.wait()
					AntiFirePart.Size = Vector3.new(0.1, 0.1, 0.1)
					AntiFirePart.CFrame = char:WaitForChild("HumanoidRootPart").CFrame
				else
					AntiFirePart.CFrame = oldABPcf
					AntiFirePart.Size = oldABPsize
				end
			end
		end)
	end
})

-------------------------->> [Anti-Poison] <<--------------------------

AntiPoisonToggle = false

local SavedPoisonCF = {}
local PoisonClones = {}

AntiPoisonToggle = ProtectionSection:AddToggle("AntiPoison", {
	Text = "Anti-Poison",
	Save = true,
	Default = false,
	Callback = function(Value)
		AntiPoisonToggle = Value

		local islandfolder = workspace.Map.FactoryIsland
		local holesfolder = workspace.Map.Hole

		if AntiPoisonToggle then
			for _, hole in pairs(holesfolder:GetChildren()) do
				if hole.Name == "PoisonBigHole" or hole.Name == "PoisonSmallHole" then
					for _, part in pairs(hole:GetDescendants()) do
						if (part.Name == "PoisonHurtPart" or part.Name == "PaintPlayerPart") then
							if not SavedPoisonCF[part] then
								SavedPoisonCF[part] = part.CFrame

								local fake = part:Clone()
								fake.Parent = islandfolder
								table.insert(PoisonClones, fake)

								part.CFrame = part.CFrame + Vector3.new(0, 1e9, 1e9)
							end
						end
					end
				end
			end

			for _, PoisonHolder in pairs(islandfolder:GetChildren()) do
				if PoisonHolder.Name == "PoisonContainer" then
					for _, part in pairs(PoisonHolder:GetDescendants()) do
						if (part.Name == "PoisonHurtPart" or part.Name == "PaintPlayerPart") then
							if not SavedPoisonCF[part] then
								SavedPoisonCF[part] = part.CFrame

								local fake = part:Clone()
								fake.Parent = islandfolder
								table.insert(PoisonClones, fake)

								part.CFrame = part.CFrame + Vector3.new(0, 1e9, 1e9)
							end
						end
					end
				end
			end
		else
			for part, cf in pairs(SavedPoisonCF) do
				if part and part.Parent then
					part.CFrame = cf
				end
			end

			for _, clone in ipairs(PoisonClones) do
				if clone and clone.Parent then
					clone:Destroy()
				end
			end

			table.clear(SavedPoisonCF)
			table.clear(PoisonClones)
		end
	end
})

-------------------------->> [Anti-Paint] <<--------------------------

_G.AntiPaintToggle = false
AntiPaintConn = nil

AntiPaintToggle = ProtectionSection:AddToggle("AntiPaint", {
	Text = "Anti-Paint",
	Save = true,
	Default = false,
	Callback = function(v)
		_G.AntiPaintToggle = v

		if AntiPaintConn then
			AntiPaintConn:Disconnect()
			AntiPaintConn = nil
		end

		if not v then return end

		AntiPaintConn = RunService.Heartbeat:Connect(function()
			for _, invP in ipairs(GetToyAllContainers()) do
				if invP then
					for _, b in ipairs(invP:GetChildren()) do
						if b.Name == "BucketPaint" then
							for _, p in ipairs(b:GetDescendants()) do
								if p.Name == "PaintPlayerPart" and p:IsA("BasePart") then
									p.CanTouch = false
								end
							end
						end
					end
				end
			end
			task.wait(0.5)
		end)
	end
})

-------------------------->> [Anti-Stick] <<--------------------------


AntiStickToggle = false
AntiStickConn = nil

local AntiStickyParts = {
	Head = true,
	Torso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	HumanoidRootPart = true,
	FirePlayerPart = true
}

function DoesOwnObj(obj)
	local owner = obj and obj:FindFirstChild("PartOwner")
	if owner and owner.Value == player.Name then
		return true
	end
	return false
end

AntiStickToggle = ProtectionSection:AddToggle("AntiStick", {
	Text = "Anti-Stick",
	Save = true,
	Default = false,
	Callback = function(Value)
		AntiStickToggle = Value

		if AntiStickConn then
			AntiStickConn:Disconnect()
			AntiStickConn = nil
		end

		if not AntiStickToggle then return end

		AntiStickConn = RunService.Heartbeat:Connect(function()
			for _, inv in ipairs(GetToyAllContainersWlp()) do
				if inv then
					for _, obj in ipairs(inv:GetChildren()) do
						if obj.Name == "ToolPickaxe" or obj.Name == "NinjaKatana" or obj.Name == "NinjaKunai" or obj.Name == "NinjaShuriken" or obj.Name == "ToolCleaver" or obj.Name == "ToolDiggingForkRusty" or obj.Name == "ToolPencil" then
							local stickyPart = obj:FindFirstChild("StickyPart")
							local Sticky = stickyPart and stickyPart:FindFirstChild("StickyWeld")

							if Sticky and Sticky.Part1 then
								if Sticky.Part1:IsDescendantOf(player.Character) then
									local grabpart = obj:FindFirstChild("SoundPart")
									if not grabpart then continue end

									repeat
										SetOwner:FireServer(grabpart, grabpart.Position)

										task.wait(0.02)
									until not AntiStickToggle or not obj.Parent or DoesOwnObj(grabpart) or not Sticky.Part1 or not AntiStickyParts[Sticky.Part1.Name]

									for _, part in ipairs(obj:GetChildren()) do
										if part:IsA("BasePart") then
											part.CanCollide = false
										end
									end
								end
							end
						end
					end
				end
			end
			task.wait(0.5)
		end)
	end
})

-------------------------->> [Anti-Attacker] <<--------------------------

AntiAttackerConn = nil
AntiAttackerBusy = false
AntiAttackerMethodValue = AntiAttackerMethodValue or "Ching Chong Land"

AntiAttackerSpots = {
	["Ching Chong Land"] = CFrame.new(591.889709, 153.338577, -92.1728058),
	["Spawn Slot"] = CFrame.new(52.5844078, -6.11595154, -121.83712),
	["Poison Hole"] = CFrame.new(63.5574722, -18.3638039, 268.490967),
	["Island (Inside)"] = CFrame.new(138.220047, 328.33728, 328.569),
	["???"] = CFrame.new(107.141991, -37.7959671, 263.77359),
	["??? 2.0"] = CFrame.new(167.527084, -7.35040283, -306.880371),
}

function ownsPart(part)
	local owner = part and part:FindFirstChild("PartOwner")
	return owner and owner.Value == player.Name
end

function StopAntiAttackerConn()
	if AntiAttackerConn then
		AntiAttackerConn:Disconnect()
		AntiAttackerConn = nil
	end

	AntiAttackerBusy = false

	pcall(function()
		StopCamPart("AntiAttacker", true)
	end)

	pcall(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Anchored = false
		end
	end)
end

function ExtendGrab(part)
    if not part or not part.Parent then return end

    pcall(function()
        CreateLine:FireServer(part, false)
        ExtendLine:FireServer(part)
        SetOwner:FireServer(part, part.CFrame)
    end)
end

function MoveAttacker(hrp, hum)
	if not hrp or not hrp.Parent then return end

	local spot = AntiAttackerSpots[AntiAttackerMethodValue]

	if spot then
		hrp.CFrame = spot
		return
	end

	if AntiAttackerMethodValue == "Heaven" or AntiAttackerMethodValue == "Death" then
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.new(0, 1e18, 0)
		bv.Parent = hrp

		task.delay(0.2, function()
			if bv then
				bv:Destroy()
			end
		end)

		if AntiAttackerMethodValue == "Death" and hum then
			hum.BreakJointsOnDeath = false
			hum.Health = 0
		end
	end
end

function StartAntiAttackerConn()
	StopAntiAttackerConn()

	AntiAttackerConn = RunService.Heartbeat:Connect(function()
		if AntiAttackerBusy or not _G.AntiAttackerToggle then return end

		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if not head or not hrp or not hum or hum.Health <= 0 then return end

		local owner = head:FindFirstChild("PartOwner")
		local attackerName = owner and owner.Value
		local attacker = attackerName and Players:FindFirstChild(attackerName)

		if not attacker or attacker == player then return end

		local attackerChar = attacker.Character
		local attackerHrp = attackerChar and attackerChar:FindFirstChild("HumanoidRootPart")
		local attackerHead = attackerChar and attackerChar:FindFirstChild("Head")
		local attackerHum = attackerChar and attackerChar:FindFirstChildOfClass("Humanoid")

		if not attackerHrp or not attackerHead or not attackerHum or attackerHum.Health <= 0 then return end

		AntiAttackerBusy = true

		task.spawn(function()
			local oldAnchored = hrp.Anchored

			StartCamPart("AntiAttacker")
			task.wait()

			hrp.Anchored = true

			while _G.AntiAttackerToggle and head and head.Parent do
				owner = head:FindFirstChild("PartOwner")

				if not owner or owner.Value ~= attackerName then
					break
				end

				pcall(function()
					Struggle:FireServer()
					Ragdoll:FireServer(hrp, 0)
				end)

				task.wait()
			end

			if hrp and hrp.Parent then
				hrp.Anchored = oldAnchored
			end

			StopCamPart("AntiAttacker", true)

			repeat
				if not attackerHead or not attackerHead.Parent then
					break
				end

				pcall(function()
					SetOwner:FireServer(attackerHead, attackerHead.CFrame)
				end)

				task.wait()
			until not _G.AntiAttackerToggle or ownsPart(attackerHead)

			if _G.AntiAttackerToggle and ownsPart(attackerHead) then
				ExtendGrab(attackerHead)
				ExtendGrab(attackerHrp)

				task.wait(0.05)

				MoveAttacker(attackerHrp, attackerHum)

				task.wait(0.05)

				pcall(function()
					DestroyOwner:FireServer(attackerHrp)
					DestroyOwner:FireServer(attackerHead)
				end)
			end

			AntiAttackerBusy = false
		end)
	end)
end

AntiAttackerMethod = ProtectionSection:AddDropdown("AntiAttackerMethodDropdown", {
	Text = "Anti-Attacker Method",
	Save = true,
	Values = {
		"??? 2.0",
		"???",
		"Ching Chong Land",
		"Island (Inside)",
		"Spawn Slot",
		"Poison Hole",
		"Heaven",
		"Death"
	},
	Default = AntiAttackerMethodValue,
	Multi = false,
	Callback = function(Value)
		AntiAttackerMethodValue = Value
	end
})

AntiAttackerToggle = ProtectionSection:AddToggle("AntiAttacker", {
	Text = "Anti-Attacker",
	Save = true,
	Default = false,
	Callback = function(v)
		_G.AntiAttackerToggle = v

		if v then
			StartAntiAttackerConn()
		else
			StopAntiAttackerConn()
		end
	end
})

-------------------------->> [Break PCLD] <<--------------------------

AutoBreakPCLD = false
PCLDCharAdded = nil
PCLDRewatch = nil
PCLDDeathConn = nil

AutoBreakPCLDToggle = AntiKickSection:AddToggle("AutoBreakPCLD", {
	Text = "Break PCLD",
	Default = false,
	Callback = function(v)
		AutoBreakPCLD = v

		if _G.PCLDCharAdded then
			_G.PCLDCharAdded:Disconnect()
			_G.PCLDCharAdded = nil
		end

		if _G.PCLDRewatch then
			_G.PCLDRewatch:Disconnect()
			_G.PCLDRewatch = nil
		end

		if _G.PCLDDeathConn then
			_G.PCLDDeathConn:Disconnect()
			_G.PCLDDeathConn = nil
		end

		if not v then return end

		local processing = false
		local waiting = false

		local function reset()
			if not AutoBreakPCLD or processing then return end

			processing = true
			waiting = false

			if _G.PCLDDeathConn then
				_G.PCLDDeathConn:Disconnect()
				_G.PCLDDeathConn = nil
			end

			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Dead)
			end

			if _G.PCLDCharAdded then
				_G.PCLDCharAdded:Disconnect()
			end

			_G.PCLDCharAdded = player.CharacterAdded:Connect(function(c)
				if not AutoBreakPCLD then
					processing = false
					return
				end

				task.wait(0.2)

				local h = c:WaitForChild("Humanoid", 1)

				if h then
					h:ChangeState(Enum.HumanoidStateType.Dead)
				end

				if _G.PCLDCharAdded then
					_G.PCLDCharAdded:Disconnect()
					_G.PCLDCharAdded = nil
				end

				processing = false
				waiting = true

				YXZ:Notify("Done!", 4)
			end)
		end

		local function watch(char)
			if not AutoBreakPCLD or processing or not waiting then return end

			local hum = char and char:WaitForChild("Humanoid", 1)
			if not hum then return end

			if _G.PCLDDeathConn then
				_G.PCLDDeathConn:Disconnect()
			end

			_G.PCLDDeathConn = hum.Died:Connect(function()
				if not AutoBreakPCLD or processing or not waiting then return end

				task.wait(0.1)
				reset()
			end)
		end

		reset()

		task.spawn(function()
			while AutoBreakPCLD do
				task.wait(0.5)

				if waiting and not processing and player.Character then
					watch(player.Character)
				end
			end
		end)

		_G.PCLDRewatch = player.CharacterAdded:Connect(function(char)
			if AutoBreakPCLD and waiting and not processing then
				task.wait(0.5)
				watch(char)
			end
		end)

		YXZ:Notify("ehh.. Working", 2)
	end
})


-------------------------->> [Anti-Kick] <<--------------------------

AntiKickToggle = false
AntiKickThread = nil

AntiKickToggle = AntiKickSection:AddToggle("AntiKick", {
	Text = "Anti-Kick",
	Default = false,
	Callback = function(v)
		AntiKickToggle = v

		if AntiKickThread then
			task.cancel(AntiKickThread)
			AntiKickThread = nil
		end

		local inv = BackPack()

		local function clearKunai()
			if inv and Destroy then
				for _, k in pairs(inv:GetChildren()) do
					if k.Name == "AntiKick" or k.Name == "NinjaShuriken" then
						pcall(function()
							Destroy:FireServer(k)
						end)
					end
				end
			end
		end

		if not v then
			clearKunai()
			return
		end

		local setOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
		local stickyEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
		local canSpawn = player:WaitForChild("CanSpawnToy")

		AntiKickThread = task.spawn(function()
			while AntiKickToggle do
				task.wait(0.1)

				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local hrp = char and char:FindFirstChild("HumanoidRootPart")

				if not hum or hum.Health <= 0 or not hrp then
					continue
				end

				local kunai = inv and (inv:FindFirstChild("AntiKick") or inv:FindFirstChild("NinjaShuriken"))

				if not kunai and canSpawn.Value then
					task.spawn(function()
						pcall(function()
							SpawnToy:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 12, 20), Vector3.zero)
						end)
					end)

					task.wait()

					kunai = inv and inv:FindFirstChild("NinjaShuriken")

					if not kunai and game.Workspace.PlotItems.PlayersInPlots:FindFirstChild(player.Name) then
						for _, plot in pairs(game.Workspace.Plots:GetChildren()) do
							local owners = plot:FindFirstChild("PlotSign")
								and plot.PlotSign:FindFirstChild("ThisPlotsOwners")

							if owners then
								for _, owner in pairs(owners:GetChildren()) do
									if owner.Value == player.Name then
										local house = game.Workspace.PlotItems:FindFirstChild(plot.Name)
										kunai = house and house:FindFirstChild("NinjaShuriken")
										break
									end
								end
							end

							if kunai then break end
						end
					end
				end

				if kunai then
					kunai.Name = "AntiKick"

					repeat
						char = player.Character
						hrp = char and char:FindFirstChild("HumanoidRootPart")

						if kunai and kunai:FindFirstChild("StickyPart") and hrp then
							local sound = kunai:FindFirstChild("SoundPart")
							local owner = sound and sound:FindFirstChild("PartOwner")

							if sound and (not owner or owner.Value ~= player.Name) then
								pcall(function()
									setOwner:FireServer(sound, sound.CFrame)
								end)
							end

							local firePart = hrp:FindFirstChild("FirePlayerPart") or hrp:WaitForChild("FirePlayerPart", 5)

							if firePart then
								stickyEvent:FireServer(
									kunai.StickyPart,
									firePart,
									CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90))
								)
							end

							if not kunai:FindFirstChild("KunaiHL") then
								local hl = Instance.new("Highlight")
								hl.Name = "KunaiHL"
								hl.FillColor = Color3.fromRGB(255, 255, 255)
								hl.OutlineColor = Color3.fromRGB(255, 255, 255)
								hl.FillTransparency = 0.4
								hl.OutlineTransparency = 0
								hl.Adornee = kunai
								hl.Parent = kunai
							end

							for _, obj in pairs(kunai:GetChildren()) do
								if obj:IsA("BasePart") then
									obj.CanTouch = false
									obj.CanCollide = false
									obj.CanQuery = false
								end
							end
						end

						task.wait(0.08)
					until not AntiKickToggle
						or not kunai
						or not kunai:FindFirstChild("StickyPart")
						or not hrp
						or (hrp.Position - kunai.StickyPart.Position).Magnitude >= 20

					if kunai and kunai:FindFirstChild("StickyPart") and hrp
						and (hrp.Position - kunai.StickyPart.Position).Magnitude >= 20 then
						clearKunai()
					end
				end
			end

			clearKunai()
		end)
	end
})

-------------------------->> [Auto-Enable] <<--------------------------

_G.AutoEnableConn = nil
AutoEnable = false

local function SetAutoEnable(Value)
	AutoEnable = Value

	if _G.AutoEnableConn then
		_G.AutoEnableConn:Disconnect()
		_G.AutoEnableConn = nil
	end

	if not AutoEnable then return end

	_G.AutoEnableConn = ReplicatedStorage.GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(message)
		if message == "Flying" then
			YXZ:Notify("Enabled Anti-Kick", 3)
			task.wait()
			AntiKickToggle:SetValue(true)
		end
	end)
end

AutoEnableToggle = AntiKickSection:AddToggle("AutoEnable", {
	Text = "Auto-Enable",
	Save = true,
	Default = true,
	Callback = SetAutoEnable
})

-------------------------->> [Auto-Reset] <<--------------------------

AutoResetConn = nil

AutoBreakPCLDToggle = AntiKickSection:AddToggle("AutoReset", {
	Text = "Auto-Reset",
	Save = true,
	Default = true,
	Callback = function(v)
		if AutoResetConn then
			AutoResetConn:Disconnect()
			AutoResetConn = nil
		end

		if not v then return end

		AutoResetConn = ReplicatedStorage.GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(message)
			if message == "Flying" then
				YXZ:Notify("Kick Frame!", 2)

				char = player.Character
				human = char and char:FindFirstChildOfClass("Humanoid")

				if human and human.Health > 0 then
					human:ChangeState(Enum.HumanoidStateType.Dead)
					human.Health = 0
				end
			end
		end)
	end
})

-------------------------->> [Anti-Lag] <<--------------------------

AntiLagToggle = false
AutoAntiLagToggle = true

AutoAntiLagConn = nil
AutoAntiLagThread = nil
AntiLagToggle = nil
AutoAntiLagToggle = nil
LagPlayer = nil
hasTriggered = false
manualOffUntil = 0

FPS_THRESHOLD = 5
BEAM_DISTANCE = 40

function setAntiLag(v)
	AntiLagToggle = v

	local ps = player:FindFirstChild("PlayerScripts")
	local lagScript = ps and ps:FindFirstChild("CharacterAndBeamMove")

	if lagScript then
		lagScript.Disabled = v
	end
end

function findBeamPart(gp)
	return gp:FindFirstChild("BeamPart", true)
		or gp:FindFirstChild("GrabPart", true)
		or gp:FindFirstChildWhichIsA("BasePart", true)
end

function GetLagPlayer()
	local bestPlr = nil
	local bestDist = BEAM_DISTANCE

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local gp = plr.Character:FindFirstChild("GrabParts", true)

			if phrp and gp then
				local beam = findBeamPart(gp)
				if beam then
					local dist = (beam.Position - phrp.Position).Magnitude

					if dist > bestDist then
						bestDist = dist
						bestPlr = plr
					end
				end
			end
		end
	end

	return bestPlr, bestDist
end

function cleanGrabParts()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			for _, obj in ipairs(plr.Character:GetDescendants()) do
				if obj.Name == "GrabParts" then
					obj:Destroy()
				end
			end
		end
	end
end

function StopAutoAntiLag()
	if AutoAntiLagConn then
		AutoAntiLagConn:Disconnect()
		AutoAntiLagConn = nil
	end

	if AutoAntiLagThread then
		task.cancel(AutoAntiLagThread)
		AutoAntiLagThread = nil
	end
end

function StartAutoAntiLag()
	StopAutoAntiLag()

	AutoAntiLagThread = task.spawn(function()
		task.wait(2)

		if not AutoAntiLagToggle then
			return
		end

		AutoAntiLagConn = RunService.RenderStepped:Connect(function(dt)
			if not AutoAntiLagToggle then return end
			if AntiLagToggle then return end
			if os.clock() < manualOffUntil then return end

			local fps = 1 / math.max(dt, 0.0001)

			if fps < FPS_THRESHOLD then
				local found, dist = GetLagPlayer()

				if found then
					LagPlayer = found
					hasTriggered = true

					if AntiLagToggle then
						AntiLagToggle:SetValue(true)
					else
						setAntiLag(true)
					end

					YXZ:Notify("<font color='#c21f1f'>" .. found.Name .. "</font> lagged the game.", 5)
				end
			end
		end)
	end)
end

AntiLagToggle = AntiLagSection:AddToggle("AntiLag", {
	Text = "Anti-Lag",
	Default = false,
	Callback = function(v)
		setAntiLag(v)

		if not v then
			manualOffUntil = os.clock() + 2
			hasTriggered = false
			LagPlayer = nil
			cleanGrabParts()
		end
	end
})

AutoAntiLagToggle = AntiLagSection:AddToggle("AutoAntiLag", {
	Text = "Auto Anti-Lag",
	Save = true,
	Default = true,
	Callback = function(v)
		AutoAntiLagToggle = v

		StopAutoAntiLag()
		hasTriggered = false

		if v then
			StartAutoAntiLag()
		end
	end
})

-------------------------->> [Anti-Input] <<--------------------------

_G.AntiInputToggle = false
_G.AntiInputItem = "FoodHamburger"
_G.AntiInputThread = nil
_G.AntiInputToken = _G.AntiInputToken or 0
AntiInputDelay = AntiInputDelay or 0.05

AntiInputItemD = AntiInputSection:AddDropdown("AntiInputItemDropdown", {
	Text = "Item",
	Save = true,
	Values = {"PoopPileSparkle", "FoodSodaCan", "FoodCakePink", "FoodHamburger", "FoodBanana", "InstrumentVoiceMicrophone"},
	Default = _G.AntiInputItem,
	Multi = false,
})

AntiInputItemD:OnChanged(function(Value)
	_G.AntiInputItem = Value

	if _G.AntiInputToggle then
		_G.AntiInputToken += 1

		if _G.AntiInputThread then
			task.cancel(_G.AntiInputThread)
			_G.AntiInputThread = nil
		end

		AntiInputToggle:SetValue(false)
		task.wait()
		AntiInputToggle:SetValue(true)
	end
end)

AntiInputToggle = AntiInputSection:AddToggle("AntiInput", {
	Text = "Anti-Input",
	Save = true,
	Default = false,
	Callback = function(Value)
		_G.AntiInputToggle = Value
		_G.AntiInputToken = (_G.AntiInputToken or 0) + 1

		local token = _G.AntiInputToken
		local item = _G.AntiInputItem

		if _G.AntiInputThread then
			task.cancel(_G.AntiInputThread)
			_G.AntiInputThread = nil
		end

		local function inv()
			return BackPack(player)
		end

		local function isToy(toy, name)
			return toy and name and (
				toy.Name == name or
					toy.Name == "AntiInput" or
					toy:GetAttribute("OriginalToyName") == name
			)
		end

		local function destroyToy(toy)
			if toy and toy.Parent then
				task.spawn(function()
					pcall(function()
						Destroy:FireServer(toy)
					end)
				end)
			end
		end

		local function getHold(toy)
			local hp = toy and toy:FindFirstChild("HoldPart")
			return hp, hp and hp:FindFirstChild("HoldItemRemoteFunction"), hp and hp:FindFirstChild("DropItemRemoteFunction")
		end

		local function heldByMe(toy, ch)
			local hp = toy and toy:FindFirstChild("HoldPart")
			local rc = hp and hp:FindFirstChild("RigidConstraint")
			local grip = rc and rc.Attachment1
			return grip and ch and grip:IsDescendantOf(ch)
		end

		local function heldByOther(toy, ch)
			local hp = toy and toy:FindFirstChild("HoldPart")
			local rc = hp and hp:FindFirstChild("RigidConstraint")
			local grip = rc and rc.Attachment1
			return grip and ch and not grip:IsDescendantOf(ch)
		end

		local function dropToy(toy, ch, root)
			if not toy or not toy.Parent or not ch or not root then return end
			local hp, hold, drop = getHold(toy)

			if drop and heldByMe(toy, ch) then
				pcall(function()
					drop:InvokeServer(toy, root.CFrame * CFrame.new(0, -2000, 0), Vector3.zero)
				end)
			end
		end

		local function setupToy(toy, name)
			if not toy or not toy.Parent then return end

			pcall(function()
				toy:SetAttribute("OriginalToyName", name)
				toy.Name = "AntiInput"
			end)

			for _, v in ipairs(toy:GetDescendants()) do
				if v:IsA("BasePart") and v.Transparency ~= 1 then
					v.Transparency = 0.8
				end
			end
		end

		local function getToy(name)
			local folder = inv()
			if not folder then return end

			for _, toy in ipairs(folder:GetChildren()) do
				if isToy(toy, name) then
					return toy
				end
			end
		end

		local function destroyExtras(name, keep)
			local folder = inv()
			if not folder then return end

			for _, toy in ipairs(folder:GetChildren()) do
				if toy ~= keep and isToy(toy, name) then
					destroyToy(toy)
				end
			end
		end

		local function spawnToy(name, root)
			local canSpawn = player:FindFirstChild("CanSpawnToy")

			while _G.AntiInputToggle and token == _G.AntiInputToken and _G.AntiInputItem == name do
				local toy = getToy(name)
				if toy and toy.Parent then
					return toy
				end

				if canSpawn and canSpawn.Value and root then
					task.spawn(function()
						pcall(function()
							SpawnToy:InvokeServer(name, root.CFrame * CFrame.new(0, 1e9, 0), Vector3.new(0, 60, 0))
						end)
					end)

					for i = 1, 10 do
						task.wait(0.03)

						if not _G.AntiInputToggle or token ~= _G.AntiInputToken or _G.AntiInputItem ~= name then
							return
						end

						toy = getToy(name)
						if toy and toy.Parent then
							toy:SetAttribute("AntiInputGrace", os.clock() + 0.05)
							setupToy(toy, name)
							return toy
						end
					end
				end

				task.wait(0.03)
			end
		end

		local function crack(toy, name, ch, root)
			if not toy or not toy.Parent then return end
			if not _G.AntiInputToggle or token ~= _G.AntiInputToken or _G.AntiInputItem ~= name then return end

			local hp, hold, drop = getHold(toy)
			if not hp or not hold or not drop then return end

			if heldByOther(toy, ch) then
				destroyToy(toy)
				return
			end

			pcall(function()
				hold:InvokeServer(toy, ch)
			end)

			task.wait()

			if not _G.AntiInputToggle or token ~= _G.AntiInputToken or _G.AntiInputItem ~= name then
				dropToy(toy, ch, root)
				return
			end

			pcall(function()
				drop:InvokeServer(toy, root.CFrame * CFrame.new(0, 2000, 0), Vector3.zero)
			end)
		end

		if not Value then
			local ch = player.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart")
			local toy = getToy(item)

			dropToy(toy, ch, root)
			destroyExtras(item)
			return
		end

		_G.AntiInputThread = task.spawn(function()
			local lastItem
			local lastToy
			local busy = false

			while _G.AntiInputToggle and token == _G.AntiInputToken do
				task.wait(AntiInputDelay or 0.05)

				if busy then continue end
				busy = true

				local name = _G.AntiInputItem
				local ch = player.Character
				local root = ch and ch:FindFirstChild("HumanoidRootPart")

				if lastItem and lastItem ~= name then
					dropToy(lastToy, ch, root)
					destroyExtras(lastItem)
					lastToy = nil
				end

				lastItem = name

				if not name or name == "" or not ch or not root then
					busy = false
					continue
				end

				local toy = getToy(name)

				if lastToy and lastToy.Parent and lastToy ~= toy then
					dropToy(lastToy, ch, root)
				end

				if toy and toy.Parent and heldByOther(toy, ch) and os.clock() > (toy:GetAttribute("AntiInputGrace") or 0) then
					destroyToy(toy)
					toy = nil
				end

				if not toy or not toy.Parent then
					toy = spawnToy(name, root)
				end

				if toy and toy.Parent and _G.AntiInputItem == name then
					lastToy = toy
					setupToy(toy, name)
					destroyExtras(name, toy)

					task.spawn(function()
						crack(toy, name, ch, root)
					end)
				end

				busy = false
			end

			local ch = player.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart")

			dropToy(lastToy, ch, root)

			if lastItem then
				destroyExtras(lastItem)
			end
		end)
	end
})

AntiInputSpeedSlider = AntiInputSection:AddSlider("AntiInputSpeed", {
	Text = "Delay",
	Save = true,
	Default = 0.05,
	Min = 0.03,
	Max = 0.1,
	Rounding = 2,
	Compact = false,
	Callback = function(v)
		AntiInputDelay = v
	end
})

-------------------------->> [Auto Spawn] <<--------------------------

PlotNames = {"Purple", "Blue", "Green", "Yellow", "Pink"}
SelectedPlotValue = "Purple"

AutoTeleportPlotToggle = false
AutoTeleportPlotConn = nil

local function TeleportToSelectedPlot()
	if not AutoTeleportPlotToggle then
		return
	end

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local cf = PlotCFrames[SelectedPlotValue]

	if cf then
		hrp.CFrame = cf
	end
end

local function OnCharacterAdded()
	task.defer(function()
		task.wait(0.1)
		TeleportToSelectedPlot()
	end)
end

SelectedPlotDropdown = AutoSpawnSection:AddDropdown("SelectedPlot", {
	Text = "Auto-Spawn Location",
	Save = true,
	Values = PlotNames,
	Default = SelectedPlotValue,
	Multi = false,
	Callback = function(Value)
		SelectedPlotValue = Value
	end
})

AutoTeleportPlotToggle = AutoSpawnSection:AddToggle("AutoTeleportPlot", {
	Text = "Auto-Spawn",
	Save = true,
	Default = false,
	Callback = function(Value)
		AutoTeleportPlotToggle = Value

		if AutoTeleportPlotConn then
			AutoTeleportPlotConn:Disconnect()
			AutoTeleportPlotConn = nil
		end

		if Value then
			AutoTeleportPlotConn = player.CharacterAdded:Connect(OnCharacterAdded)
		end
	end
})

-------------------------->> [Third Party Protection] <<--------------------------

_G.AntiKickTargets = {}
_G.AntiKickProtectPlayerToggle = false
_G.AntiGrabProtectedPlayers = false
_G.TeleportProtectedBack = false
_G.firingOwners = {}

ProtectedPlayers = {}
AntiKickThread = nil
AntiKickKunais = {}
AntiKickSettingUp = {}
AntiKickWaitingPlot = {}

local function getHRP(plr)
	local char = plr and plr.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function isProtected(name)
	for _, v in pairs(ProtectedPlayers or {}) do
		if tostring(v) == tostring(name) then
			return true
		end
	end
	return false
end

local function inPlayersInPlots(name)
	local folder = workspace:FindFirstChild("PlotItems")
		and workspace.PlotItems:FindFirstChild("PlayersInPlots")

	if not folder then
		return false
	end

	return folder:FindFirstChild(tostring(name)) ~= nil
end

local function ownsPart(part)
	local owner = part and part:FindFirstChild("PartOwner")
	return owner and tostring(owner.Value) == player.Name
end

local function badOwner(part)
	local owner = part and part:FindFirstChild("PartOwner")
	return owner and tostring(owner.Value) ~= player.Name
end

local function destroyToy(obj)
	if not obj or not obj.Parent then return end

	pcall(function()
		if Destroy then
			Destroy:FireServer(obj)
		else
			obj:Destroy()
		end
	end)
end

local function clean(kunai)
	if not kunai then return end

	for _, obj in ipairs(kunai:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CanCollide = false
			obj.CanTouch = false
			obj.CanQuery = false
		end
	end
end

local function destroyAntiKick(name)
	name = tostring(name)

	destroyToy(AntiKickKunais[name])
	AntiKickKunais[name] = nil
	AntiKickSettingUp[name] = nil
	AntiKickWaitingPlot[name] = nil

	local inv = BackPack()
	if inv then
		for _, toy in ipairs(inv:GetChildren()) do
			if toy.Name == "AntiKick(" .. name .. ")" then
				destroyToy(toy)
			end
		end
	end
end

local function destroyAllAntiKick()
	for name in pairs(AntiKickKunais) do
		destroyAntiKick(name)
	end

	local inv = BackPack()
	if inv then
		for _, toy in ipairs(inv:GetChildren()) do
			if toy.Name:match("^AntiKick%(") then
				destroyToy(toy)
			end
		end
	end

	table.clear(AntiKickKunais)
	table.clear(AntiKickSettingUp)
	table.clear(AntiKickWaitingPlot)
end

local function findExisting(name)
	local inv = BackPack()
	if not inv then return nil end

	local targetName = "AntiKick(" .. tostring(name) .. ")"
	local found

	for _, toy in ipairs(inv:GetChildren()) do
		if toy.Name == targetName then
			if not found then
				found = toy
			else
				destroyToy(toy)
			end
		end
	end

	return found
end

local function getSticky(kunai)
	return kunai and kunai:FindFirstChild("StickyPart", true)
end

local function getFirePart(char, hrp)
	return hrp and (hrp:FindFirstChild("FirePlayerPart") or char:FindFirstChild("FirePlayerPart", true))
end

local function isAttached(sticky, fire)
	return sticky and fire and (sticky.Position - fire.Position).Magnitude <= 1.5
end

local function validateKunai(name, kunai, sticky, fire)
	if not kunai or not kunai.Parent or not sticky or not fire then
		destroyAntiKick(name)
		return false
	end

	if badOwner(sticky) then
		destroyAntiKick(name)
		return false
	end

	if not isAttached(sticky, fire) and sticky:FindFirstChild("PartOwner") and not ownsPart(sticky) then
		destroyAntiKick(name)
		return false
	end

	return true
end

ProtectedPlayersDropdown = ThirdPartyProtectionSection:AddPlayerDropdown("ProtectedPlayersDropdown", {
	Text = "Select Player",
	Save = true,
	Multi = true,
	Callback = function(Value)
		ProtectedPlayers = {}

		for name, enabled in pairs(Value) do
			if enabled then
				table.insert(ProtectedPlayers, tostring(name))
			end
		end

		_G.AntiKickTargets = ProtectedPlayers
	end
})

local saved = {}

for _, name in pairs(ProtectedPlayers) do
	saved[name] = true
end

ProtectedPlayersDropdown:SetValue(saved)

ThirdPartyAntiKickToggle = ThirdPartyProtectionSection:AddToggle("ThirdPartyAntiKick", {
	Text = "Anti-Kick",
	Default = false,
	Callback = function(Value)
		_G.AntiKickProtectPlayerToggle = Value

		if AntiKickThread then
			task.cancel(AntiKickThread)
			AntiKickThread = nil
		end

		if not Value then
			destroyAllAntiKick()
			return
		end

		AntiKickThread = task.spawn(function()
			while _G.AntiKickProtectPlayerToggle do
				for name in pairs(AntiKickKunais) do
					if not isProtected(name) then
						destroyAntiKick(name)
					end
				end

				for _, rawName in pairs(ProtectedPlayers or {}) do
					local name = tostring(rawName)

					if AntiKickSettingUp[name] then
						continue
					end

					if inPlayersInPlots(name) then
						AntiKickWaitingPlot[name] = true
						destroyAntiKick(name)
						continue
					elseif AntiKickWaitingPlot[name] then
						AntiKickWaitingPlot[name] = nil

						local target = Players:FindFirstChild(name)
						local hrp = getHRP(target)

						if hrp then
							pcall(function()
								hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 75, hrp.Position.Z)
							end)
						end
					end

					local target = Players:FindFirstChild(name)
					local char = target and target.Character
					local tHRP = getHRP(target)
					local hum = char and char:FindFirstChildOfClass("Humanoid")

					if not target or not char or not tHRP or not hum or hum.Health <= 0 then
						destroyAntiKick(name)
						continue
					end

					local kunai = AntiKickKunais[name] or findExisting(name)

					if kunai and kunai.Parent then
						AntiKickKunais[name] = kunai
						clean(kunai)
					end

					local sticky = getSticky(kunai)
					local fire = getFirePart(char, tHRP)

					if validateKunai(name, kunai, sticky, fire) and isAttached(sticky, fire) then
						clean(kunai)
						continue
					end

					AntiKickSettingUp[name] = true
					destroyAntiKick(name)

					if not isProtected(name) or inPlayersInPlots(name) then
						AntiKickSettingUp[name] = nil
						continue
					end

					local canSpawn = player:FindFirstChild("CanSpawnToy")
					local myHRP = getHRP(player)
					local inv = BackPack()

					if not canSpawn or not canSpawn.Value or not myHRP or not inv then
						AntiKickSettingUp[name] = nil
						continue
					end

					local old = {}

					for _, obj in ipairs(inv:GetChildren()) do
						old[obj] = true
					end

					task.spawn(function()
						pcall(function()
							SpawnToy:InvokeServer(
								"NinjaShuriken",
								myHRP.CFrame * CFrame.new(0, 18, 20),
								Vector3.zero
							)
						end)
					end)

					local started = os.clock()
					kunai = nil

					repeat
						if not _G.AntiKickProtectPlayerToggle or not isProtected(name) or inPlayersInPlots(name) then
							break
						end

						inv = BackPack()

						if inv then
							for _, toy in ipairs(inv:GetChildren()) do
								if toy.Name == "NinjaShuriken" and not old[toy] then
									kunai = toy
									break
								end
							end
						end

						task.wait(0.02)
					until kunai or os.clock() - started > 1.5

					if not kunai or not kunai.Parent or not isProtected(name) or inPlayersInPlots(name) then
						destroyToy(kunai)
						AntiKickSettingUp[name] = nil
						continue
					end

					kunai.Name = "AntiKick(" .. name .. ")"
					AntiKickKunais[name] = kunai
					clean(kunai)

					sticky = getSticky(kunai)
					fire = getFirePart(char, tHRP)

					if not validateKunai(name, kunai, sticky, fire) then
						AntiKickSettingUp[name] = nil
						continue
					end

					local hl = kunai:FindFirstChild("KunaiHL")

					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "KunaiHL"
						hl.FillColor = Color3.fromRGB(255, 255, 255)
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
						hl.FillTransparency = 0.4
						hl.OutlineTransparency = 0
						hl.Adornee = kunai
						hl.Parent = kunai
					end

					local ownerStarted = os.clock()

					repeat
						if not _G.AntiKickProtectPlayerToggle or not isProtected(name) or inPlayersInPlots(name) then
							destroyAntiKick(name)
							break
						end

						if badOwner(sticky) then
							destroyAntiKick(name)
							break
						end

						pcall(function()
							CreateLine:FireServer(sticky, false)
							ExtendLine:FireServer(sticky)
							SetOwner:FireServer(sticky, sticky.CFrame)
						end)

						task.wait(0.03)
					until ownsPart(sticky) or os.clock() - ownerStarted > 1

					if not ownsPart(sticky) then
						destroyAntiKick(name)
						AntiKickSettingUp[name] = nil
						continue
					end

					local attached = false

					for i = 1, 6 do
						if not _G.AntiKickProtectPlayerToggle or not isProtected(name) or inPlayersInPlots(name) then
							destroyAntiKick(name)
							break
						end

						target = Players:FindFirstChild(name)
						char = target and target.Character
						tHRP = getHRP(target)
						sticky = getSticky(kunai)
						fire = char and tHRP and getFirePart(char, tHRP)

						if not validateKunai(name, kunai, sticky, fire) then
							break
						end

						if not ownsPart(sticky) then
							destroyAntiKick(name)
							break
						end

						pcall(function()
							kunai:PivotTo(tHRP.CFrame * CFrame.new(0, 10, 0))
						end)

						task.wait(0.03)

						pcall(function()
							ReplicatedStorage.PlayerEvents.StickyPartEvent:FireServer(
								sticky,
								fire,
								CFrame.new(0, 0, 0.1) * CFrame.Angles(0, math.rad(90), math.rad(90))
							)
						end)

						task.wait(0.05)

						if isAttached(sticky, fire) then
							attached = true
							break
						end
					end

					if not attached then
						destroyAntiKick(name)
					end

					AntiKickSettingUp[name] = nil
					task.wait()
				end

				task.wait(0.05)
			end
		end)
	end
})

-------------------------->> [Target] <<--------------------------

BlobmanTargetSection = Tab.Target:AddRightGroupbox("Blobman Target")

BlobmanSettingsSection = Tab.Target:AddRightGroupbox("Blobman Settings")

PlayerTargetSection = Tab.Target:AddLeftGroupbox("Player Target")

-------------------------->> [Select Targets] <<--------------------------

TargetPlayers = {}
BlobmanTargetLeft = nil
BlobmanTargetRight = nil

TargetPlayersDropdown = PlayerTargetSection:AddPlayerDropdown("TargetPlayersDropdown", {
	Text = "Select Targets",
	Multi = true,
	Callback = function(Value)
		TargetPlayers = {}

		for name, enabled in pairs(Value) do
			if enabled then
				table.insert(TargetPlayers, tostring(name))
			end
		end
	end
})

BlobmanTargetLeftDropdown = BlobmanTargetSection:AddPlayerDropdown("BlobmanTargetLeftDropdown", {
	Text = "Left Target",
	Multi = false,
	Callback = function(Value)
		BlobmanTargetLeft = Value
	end
})

BlobmanTargetRightDropdown = BlobmanTargetSection:AddPlayerDropdown("BlobmanTargetRightDropdown", {
	Text = "Right Target",
	Multi = false,
	Callback = function(Value)
		BlobmanTargetRight = Value
	end
})

PlayerTargetSection:AddDivider("Methods")
BlobmanTargetSection:AddDivider("Methods")

-------------------------->> [Loop Apply Methods] <<--------------------------

LoopApplyMethodTarget = false

TargetPlayers = {}
TargetPlayerMethods = {}

LoopMethodTargetThread = nil
LoopGrabConn = nil
LoopGrabTarget = nil
LoopGrabLastGrab = 0
LoopGrabLastDestroy = 0
TargetMethodBusy = false
TargetMethodNoClip = nil
TargetMethodReturnCFrame = nil
TargetMethodTeleported = false

AntiMethodWatchConns = {}
AntiMethodWatchedFolders = {}
AntiInputBusy = {}
AntiKickBusy = {}

BreakGucci = "Break Gucci"
BreakGucciToys = {
	TractorGreen = true,
	TractorOrange = true,
	TractorRed = true,
	CreatureBlobman = true,
	Train = true
}

BreakGucciConns = {}
BreakGucciListeningContainers = {}
BreakGucciToken = 0
BreakGucciSavedCF = nil
BreakGucciQueue = {}
BreakGucciQueueRunning = false
BreakGucciRememberedSeats = {}
BreakGucciNoclipSaved = {}
BreakGucciNoclipConn = nil

TargetMethodConfig = {
	Offset = CFrame.new(0, -8, 3),
	TeleportWait = 0.15,
	OwnerTimeout = 2.5,
	GrabRate = 0.0043,
	DestroyRate = 0.0056,
	LockOffset = CFrame.new(0, 20, 0),
	NearDistance = 30,
	MaxDistance = 1500,
	CamTag = "TargetMethods"
}

Heaven = 'Heaven ( <font color="rgb(219, 30, 30)">KICK</font> )'
KickOwnership = 'Kick ( <font color="rgb(73, 230, 133)">Ownership</font> )'

function MultiToList(v)
	local list = {}

	if typeof(v) == "table" then
		for k, enabled in pairs(v) do
			if enabled == true then
				table.insert(list, tostring(k))
			elseif typeof(enabled) == "string" then
				table.insert(list, tostring(enabled))
			end
		end
	elseif v then
		table.insert(list, tostring(v))
	end

	return list
end

function HasMethod(method)
	for _, v in pairs(TargetPlayerMethods) do
		if v == method then
			return true
		end
	end
	return false
end

function RefreshTargetCharacter()
	char = player.Character
	hrp = char and char:FindFirstChild("HumanoidRootPart")
	human = char and char:FindFirstChildOfClass("Humanoid")
	return char and hrp and human
end

function ZeroVelocity(part)
	if part then
		part.AssemblyLinearVelocity = Vector3.zero
		part.AssemblyAngularVelocity = Vector3.zero
	end
end

function IsDead()
	RefreshTargetCharacter()
	return not human or human.Health <= 0
end

function StartTargetNoClip()
	if TargetMethodNoClip then return end

	TargetMethodNoClip = RunService.Stepped:Connect(function()
		local ch = player.Character
		if ch then
			for _, p in pairs(ch:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
				end
			end
		end
	end)
end

function StopTargetNoClip()
	if TargetMethodNoClip then
		TargetMethodNoClip:Disconnect()
		TargetMethodNoClip = nil
	end
end

function InPlot(plr)
	return plr and Workspace:FindFirstChild("PlotItems")
		and Workspace.PlotItems:FindFirstChild("PlayersInPlots")
		and Workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name)
end

function FindTargetPlayer(name)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Name == name or plr.DisplayName == name then
			return plr
		end
	end
end

function IsGoodTarget(plr)
	RefreshTargetCharacter()

	local ch = plr and plr.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")

	if not (plr and plr ~= player and root and hum and hum.Health > 0 and hrp) then
		return false
	end

	if InPlot(plr) then return false end
	if WhitelistPlayers and WhitelistPlayers[plr.Name] then return false end
	if (root.Position - hrp.Position).Magnitude > TargetMethodConfig.MaxDistance then return false end

	return true
end

function OwnsTarget(plr)
	local head = plr and plr.Character and plr.Character:FindFirstChild("Head")
	local owner = head and head:FindFirstChild("PartOwner")
	return owner and owner.Value == player.Name
end

function TargetDistance(root)
	RefreshTargetCharacter()
	if not hrp or not root then return math.huge end
	return (hrp.Position - root.Position).Magnitude
end

function SetOwnerLine(part, cf, destroyLine)
	if not part or not part.Parent then return end

	pcall(function()
		SetOwner:FireServer(part, cf or part.CFrame)
		ExtendLine:FireServer(30)
		CreateLine:FireServer(part, Vector3.zero, (cf and cf.Position) or part.Position, destroyLine or false)
	end)
end

function DestroyOwnerLine(part)
	if not part or not part.Parent then return end

	pcall(function()
		DestroyOwner:FireServer(part)
		ExtendLine:FireServer(30)
		CreateLine:FireServer(part, Vector3.zero, part.Position, true)
	end)
end

function StartTargetTeleportMode()
	if TargetMethodTeleported then return end
	if not RefreshTargetCharacter() then return end

	TargetMethodTeleported = true
	TargetMethodReturnCFrame = hrp.CFrame

	StartCamPart(TargetMethodConfig.CamTag)
	StartTargetNoClip()
end

function TeleportUnderTarget(root)
	if not RefreshTargetCharacter() then return false end
	if not root or not root.Parent then return false end

	StartTargetTeleportMode()

	hrp.CFrame = root.CFrame * TargetMethodConfig.Offset
	ZeroVelocity(hrp)

	task.wait(TargetMethodConfig.TeleportWait)

	return true
end

function TeleportIfFar(root)
	if not root then return false end

	if TargetDistance(root) > TargetMethodConfig.NearDistance then
		return TeleportUnderTarget(root)
	end

	return true
end

function ReturnFromTargets()
	RefreshTargetCharacter()

	if TargetMethodTeleported and hrp and TargetMethodReturnCFrame and not IsDead() then
		hrp.CFrame = TargetMethodReturnCFrame
		ZeroVelocity(hrp)
		hrp.Anchored = false
	end

	if TargetMethodTeleported then
		StopCamPart(TargetMethodConfig.CamTag, false)
	end

	StopTargetNoClip()

	TargetMethodTeleported = false
	TargetMethodReturnCFrame = nil
end

function HeavenTarget(root)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(0, 1e18, 0)
	bv.Velocity = Vector3.new(0, tonumber(launchVel) or 1e18, 0)
	bv.P = 12500
	bv.Parent = root
	Debris:AddItem(bv, 0.35)
end

function GetTargetToyContainer(plr)
	if not plr then return nil end

	local plotItems = Workspace:FindFirstChild("PlotItems")
	local playersInPlots = plotItems and plotItems:FindFirstChild("PlayersInPlots")

	if plotItems and playersInPlots and playersInPlots:FindFirstChild(plr.Name) then
		local plots = Workspace:FindFirstChild("Plots")

		if plots then
			for _, plot in ipairs(plots:GetChildren()) do
				local owners = plot:FindFirstChild("PlotSign")
					and plot.PlotSign:FindFirstChild("ThisPlotsOwners")

				if owners then
					for _, v in ipairs(owners:GetChildren()) do
						if v.Value == plr.Name then
							return plotItems:FindFirstChild(plot.Name)
						end
					end
				end
			end
		end
	end

	return Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
end

function GetAllTargets()
	local list = {}

	for _, name in pairs(TargetPlayers) do
		local plr = FindTargetPlayer(name)

		if IsGoodTarget(plr) then
			table.insert(list, plr)
		end
	end

	return list
end

function IsSelectedTarget(plr)
	if not plr then return false end

	for _, target in pairs(GetAllTargets()) do
		if target == plr then
			return true
		end
	end

	return false
end

function FastHoldItem(obj)
	if not obj or not obj:IsA("Model") then return end
	if AntiInputBusy[obj] then return end

	local hold = obj:FindFirstChild("HoldPart")
	local grab = hold and hold:FindFirstChild("HoldItemRemoteFunction")

	if not grab then return end

	AntiInputBusy[obj] = true

	task.spawn(function()
		pcall(function()
			grab:InvokeServer(obj, player.Character)
		end)

		task.wait(0.02)
		AntiInputBusy[obj] = nil
	end)
end

function StickyAttachedToTarget(sticky)
	local weld = sticky and sticky:FindFirstChild("StickyWeld")
	if not weld or not weld.Part1 then return false end

	local ch = weld.Part1:FindFirstAncestorOfClass("Model")
	local plr = ch and Players:GetPlayerFromCharacter(ch)

	return plr and IsSelectedTarget(plr)
end

function FastAntiKickToy(toy)
	if not toy or not toy:IsA("Model") then return end
	if AntiKickBusy[toy] then return end

	local sticky = toy:FindFirstChild("StickyPart", true)
	if not sticky or not sticky:IsA("BasePart") then return end

	RefreshTargetCharacter()
	if not hrp then return end

	local closeToMe = (sticky.Position - hrp.Position).Magnitude <= 30
	if not closeToMe then return end

	local closeToTarget = false
	local attachedToTarget = StickyAttachedToTarget(sticky)

	for _, target in pairs(GetAllTargets()) do
		local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if root and (sticky.Position - root.Position).Magnitude <= 30 then
			closeToTarget = true
			break
		end
	end

	if not closeToTarget and not attachedToTarget then
		return
	end

	AntiKickBusy[toy] = true

	task.spawn(function()
		while LoopApplyMethodTarget
			and HasMethod("Anti Anti-Kick")
			and toy
			and toy.Parent
			and sticky
			and sticky.Parent do

			RefreshTargetCharacter()
			if not hrp then break end

			local meNear = (sticky.Position - hrp.Position).Magnitude <= 30
			local targetNear = false
			local stillAttached = StickyAttachedToTarget(sticky)

			for _, target in pairs(GetAllTargets()) do
				local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
				if root and (sticky.Position - root.Position).Magnitude <= 30 then
					targetNear = true
					break
				end
			end

			if not meNear then break end
			if not targetNear and not stillAttached then break end

			for _, part in ipairs(toy:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
					part.AssemblyLinearVelocity = Vector3.new(0, -150, 0)
					part.AssemblyAngularVelocity = Vector3.zero
				end
			end

			pcall(function()
				SetOwner:FireServer(sticky, sticky.CFrame)
				ExtendLine:FireServer(30)
				CreateLine:FireServer(sticky, Vector3.zero, sticky.Position, false)
			end)

			sticky.AssemblyLinearVelocity = Vector3.new(0, -200, 0)
			sticky.AssemblyAngularVelocity = Vector3.zero

			task.wait(0.018)
		end

		AntiKickBusy[toy] = nil
	end)
end

function ClearAntiMethodWatchers()
	for _, c in pairs(AntiMethodWatchConns) do
		pcall(function()
			c:Disconnect()
		end)
	end

	AntiMethodWatchConns = {}
	AntiMethodWatchedFolders = {}
	AntiInputBusy = {}
	AntiKickBusy = {}
end

function WatchAntiInputFolder(folder)
	if not folder or AntiMethodWatchedFolders[folder] then return end

	AntiMethodWatchedFolders[folder] = true

	for _, obj in ipairs(folder:GetChildren()) do
		FastHoldItem(obj)
	end

	table.insert(AntiMethodWatchConns, folder.ChildAdded:Connect(function(obj)
		if not LoopApplyMethodTarget then return end
		if not HasMethod("Anti Anti-Input") then return end

		task.defer(function()
			FastHoldItem(obj)
		end)
	end))

	table.insert(AntiMethodWatchConns, folder.DescendantAdded:Connect(function(obj)
		if not LoopApplyMethodTarget then return end
		if not HasMethod("Anti Anti-Input") then return end

		local model = obj:FindFirstAncestorOfClass("Model")
		if model then
			task.defer(function()
				FastHoldItem(model)
			end)
		end
	end))
end

function WatchAntiKickFolder(folder)
	if not folder or AntiMethodWatchedFolders[folder] then return end

	AntiMethodWatchedFolders[folder] = true

	for _, toy in ipairs(folder:GetChildren()) do
		FastAntiKickToy(toy)
	end

	table.insert(AntiMethodWatchConns, folder.ChildAdded:Connect(function(toy)
		if not LoopApplyMethodTarget then return end
		if not HasMethod("Anti Anti-Kick") then return end

		task.defer(function()
			FastAntiKickToy(toy)
		end)
	end))

	table.insert(AntiMethodWatchConns, folder.DescendantAdded:Connect(function(obj)
		if not LoopApplyMethodTarget then return end
		if not HasMethod("Anti Anti-Kick") then return end

		local toy = obj:FindFirstAncestorOfClass("Model")
		if toy then
			task.defer(function()
				FastAntiKickToy(toy)
			end)
		end
	end))
end

function RefreshAntiMethodWatchers()
	ClearAntiMethodWatchers()

	if not LoopApplyMethodTarget then return end

	if HasMethod("Anti Anti-Input") then
		for _, plr in pairs(GetAllTargets()) do
			local folder = GetTargetToyContainer(plr)
			WatchAntiInputFolder(folder)
		end
	end

	if HasMethod("Anti Anti-Kick") then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player then
				local folder = GetTargetToyContainer(plr)
				WatchAntiKickFolder(folder)
			end
		end
	end
end

function ApplyAntiAntiInput(plr)
	local folder = GetTargetToyContainer(plr)
	if not folder then return end

	for _, obj in ipairs(folder:GetChildren()) do
		FastHoldItem(obj)
	end
end

function ApplyAntiAntiKick(plr)
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local folder = GetTargetToyContainer(other)

			if folder then
				for _, toy in ipairs(folder:GetChildren()) do
					FastAntiKickToy(toy)
				end
			end
		end
	end
end

-------------------------->> [Break Gucci Exact Logic] <<--------------------------

function SafeDisconnectBreakGucci(c)
	pcall(function()
		if c then
			c:Disconnect()
		end
	end)
end

function RefreshBreakGucciChar()
	char = player.Character
	if not char then return end

	human = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2)
	hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 2)

	return char and human and hrp
end

function BreakGucciSetCFrame(part, cf)
	if not part or not cf then return end

	pcall(function()
		if NoFlashSetCFrame and human then
			NoFlashSetCFrame(part, cf, human)
		else
			part.CFrame = cf
		end
	end)
end

function ClearBreakGucciConns()
	for _, c in pairs(BreakGucciConns) do
		SafeDisconnectBreakGucci(c)
	end

	BreakGucciConns = {}
	BreakGucciListeningContainers = {}
end

function StopBreakGucciNoclip()
	SafeDisconnectBreakGucci(BreakGucciNoclipConn)
	BreakGucciNoclipConn = nil

	for part, old in pairs(BreakGucciNoclipSaved) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = old
			end)
		end
	end

	BreakGucciNoclipSaved = {}
end

function StartBreakGucciNoclip()
	if BreakGucciNoclipConn then return end

	BreakGucciNoclipSaved = {}

	BreakGucciNoclipConn = RunService.RenderStepped:Connect(function()
		pcall(function()
			char = player.Character
			if not char then return end

			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					if BreakGucciNoclipSaved[part] == nil then
						BreakGucciNoclipSaved[part] = part.CanCollide
					end

					part.CanCollide = false
				end
			end
		end)
	end)
end

function StopBreakGucciAll()
	BreakGucciToken = BreakGucciToken + 1
	BreakGucciQueue = {}
	BreakGucciQueueRunning = false
	BreakGucciRememberedSeats = {}

	StopBreakGucciNoclip()
	ClearBreakGucciConns()

	pcall(function()
		RefreshBreakGucciChar()

		if human then
			human.Sit = false
			human.Jump = true
			human.PlatformStand = false
		end

		if hrp then
			hrp.Anchored = false
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero

			if BreakGucciSavedCF then
				BreakGucciSetCFrame(hrp, BreakGucciSavedCF)
			end
		end
	end)
end

function IsBreakGucciToy(toy)
	return toy and BreakGucciToys[toy.Name] == true
end

function GetBreakGucciPlotContainer(plr)
	if not plr then return end
	if not Workspace:FindFirstChild("PlotItems") then return end
	if not Workspace.PlotItems:FindFirstChild("PlayersInPlots") then return end
	if not Workspace.PlotItems.PlayersInPlots:FindFirstChild(plr.Name) then return end
	if not Workspace:FindFirstChild("Plots") then return end

	for _, plot in pairs(Workspace.Plots:GetChildren()) do
		local owners = plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("ThisPlotsOwners")

		if owners then
			for _, owner in pairs(owners:GetChildren()) do
				if owner.Value == plr.Name then
					return Workspace.PlotItems:FindFirstChild(plot.Name)
				end
			end
		end
	end
end

function GetBreakGucciContainers(plr)
	local containers = {}

	if not plr then return containers end

	local inv = Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
	local plot = GetBreakGucciPlotContainer(plr)

	if inv then
		table.insert(containers, inv)
	end

	if plot then
		table.insert(containers, plot)
	end

	return containers
end

function RememberBreakGucciSeat(toy, thuman)
	if not toy or not thuman then return end

	local seat = thuman.SeatPart
	if seat and seat.Parent and seat:IsDescendantOf(toy) and (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then
		BreakGucciRememberedSeats[toy] = seat
		return seat
	end
end

function GetBreakGucciSeat(toy, thuman)
	if not toy then return end

	local remembered = BreakGucciRememberedSeats[toy]
	if remembered and remembered.Parent and remembered:IsDescendantOf(toy) then
		return remembered
	end

	local exact = RememberBreakGucciSeat(toy, thuman)
	if exact then
		return exact
	end

	for _, seat in pairs(toy:GetDescendants()) do
		if seat:IsA("VehicleSeat") then
			BreakGucciRememberedSeats[toy] = seat
			return seat
		end
	end

	for _, seat in pairs(toy:GetDescendants()) do
		if seat:IsA("Seat") then
			BreakGucciRememberedSeats[toy] = seat
			return seat
		end
	end
end

function IsBreakGucciInVoid(toy)
	if not toy or not toy.Parent then return true end

	for _, part in pairs(toy:GetDescendants()) do
		if part:IsA("BasePart") then
			return math.abs(part.Position.X) >= 9000
				or math.abs(part.Position.Z) >= 9000
				or part.Position.Y <= -5000
		end
	end

	return false
end

function IsBreakGucciSeatOccupied(seat)
	if not seat then return false end

	pcall(RefreshBreakGucciChar)

	if not seat.Occupant then return false end
	if human and seat.Occupant == human then return false end

	return true
end

function WaitBreakGucciSeatFree(seat, maxTime, token)
	local start = tick()

	while tick() - start < maxTime do
		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then return false end
		if not seat or not seat.Parent then return false end
		if not IsBreakGucciSeatOccupied(seat) then return true end

		task.wait(0.01)
	end

	return false
end

function WaitBreakGucciUnsit(thuman, maxTime, token)
	local start = tick()

	while tick() - start < maxTime do
		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then return false end
		if not thuman or not thuman.Parent then return true end
		if not thuman.Sit and not thuman.SeatPart then return true end

		task.wait(0.03)
	end

	return false
end

function TeleportAndSitBreakGucci(seat, token)
	if not seat or not seat.Parent then return false end
	if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then return false end

	pcall(function()
		RefreshBreakGucciChar()
		if not hrp or not human then return end

		if human.SeatPart == seat then
			return
		end

		human.Sit = false
		human.Jump = true
		human.PlatformStand = false

		hrp.Anchored = false
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero

		BreakGucciSetCFrame(hrp, seat.CFrame * CFrame.new(0, 2, 0))
	end)

	task.wait(0.04)

	local start = tick()

	repeat
		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then return false end
		if not seat or not seat.Parent then return false end

		pcall(function()
			RefreshBreakGucciChar()
			if not human then return end

			if human.SeatPart == seat then
				return
			end

			human.Sit = false
			task.wait()
			seat:Sit(human)
		end)

		pcall(RefreshBreakGucciChar)
		task.wait(0.015)
	until (human and human.SeatPart == seat) or tick() - start > 3

	pcall(RefreshBreakGucciChar)
	return human and human.SeatPart == seat
end

function UnsitAndReturnBreakGucci(savedCF, token)
	local start = tick()

	repeat
		pcall(function()
			RefreshBreakGucciChar()

			if human then
				human.Sit = false
				human.Jump = true
				human.PlatformStand = false
			end
		end)

		task.wait(0.005)
		pcall(RefreshBreakGucciChar)
	until (human and not human.SeatPart) or tick() - start > 2

	StopBreakGucciNoclip()

	pcall(function()
		RefreshBreakGucciChar()
		if not hrp or not savedCF then return end

		if human then
			human.Sit = false
			human.Jump = true
			human.PlatformStand = false
			pcall(function()
				human:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end

		hrp.Anchored = false
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		BreakGucciSetCFrame(hrp, savedCF)

		task.wait()

		if token == BreakGucciToken then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			BreakGucciSetCFrame(hrp, savedCF)
		end
	end)
end

function VoidBreakGucciToy(toy, token)
	for i = 1, 45 do
		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then return end
		if not toy or not toy.Parent then return end

		pcall(function()
			for _, part in pairs(toy:GetDescendants()) do
				if part:IsA("BasePart") then
					part.AssemblyLinearVelocity = Vector3.zero
					part.AssemblyAngularVelocity = Vector3.zero
				end
			end

			toy:PivotTo(CFrame.new(9e9, 0, 9e9))
		end)

		if IsBreakGucciInVoid(toy) then return true end

		task.wait(0.003)
	end

	return IsBreakGucciInVoid(toy)
end

function DestroyBreakGucciToy(toy, tplr, token)
	if not toy or not toy.Parent then return end
	if not IsBreakGucciToy(toy) then return end
	if IsBreakGucciInVoid(toy) then return end

	local tchar = tplr and tplr.Character
	local thuman = tchar and tchar:FindFirstChildOfClass("Humanoid")

	local seat = GetBreakGucciSeat(toy, thuman)
	if not seat then return end

	RefreshBreakGucciChar()
	if not hrp or not human then return end

	if IsBreakGucciSeatOccupied(seat) and not WaitBreakGucciSeatFree(seat, 8, token) then
		return
	end

	if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then return end

	local savedCF = hrp.CFrame
	BreakGucciSavedCF = savedCF

	StartBreakGucciNoclip()

	if seat:IsA("VehicleSeat") then
		local seated = TeleportAndSitBreakGucci(seat, token)

		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then
			UnsitAndReturnBreakGucci(savedCF, token)
			return
		end

		if seated then
			VoidBreakGucciToy(toy, token)
		end

		UnsitAndReturnBreakGucci(savedCF, token)
	else
		if thuman and (thuman.Sit or thuman.SeatPart) then
			RememberBreakGucciSeat(toy, thuman)

			if not WaitBreakGucciUnsit(thuman, 8, token) then
				UnsitAndReturnBreakGucci(savedCF, token)
				return
			end
		end

		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) or token ~= BreakGucciToken then
			UnsitAndReturnBreakGucci(savedCF, token)
			return
		end

		local seated = TeleportAndSitBreakGucci(seat, token)

		if seated then
			VoidBreakGucciToy(toy, token)
		end

		UnsitAndReturnBreakGucci(savedCF, token)
	end
end

function QueueBreakGucciToy(toy, tplr)
	if not toy or not toy.Parent then return end
	if not IsBreakGucciToy(toy) then return end

	for _, queued in ipairs(BreakGucciQueue) do
		if queued.Toy == toy then return end
	end

	table.insert(BreakGucciQueue, {
		Toy = toy,
		Player = tplr
	})

	if BreakGucciQueueRunning then return end

	BreakGucciQueueRunning = true

	local token = BreakGucciToken

	task.spawn(function()
		while #BreakGucciQueue > 0 and LoopApplyMethodTarget and HasMethod(BreakGucci) and token == BreakGucciToken do
			local data = table.remove(BreakGucciQueue, 1)
			local queuedToy = data and data.Toy
			local queuedPlayer = data and data.Player

			if queuedToy and queuedToy.Parent and IsBreakGucciToy(queuedToy) and not IsBreakGucciInVoid(queuedToy) then
				pcall(function()
					DestroyBreakGucciToy(queuedToy, queuedPlayer, token)
				end)

				task.wait(0.15)
			end
		end

		BreakGucciQueueRunning = false
	end)
end

function CheckBreakGucciSeatPart(tplr)
	if not LoopApplyMethodTarget or not HasMethod(BreakGucci) then return end
	if not tplr then return end

	local tchar = tplr.Character
	local thuman = tchar and tchar:FindFirstChildOfClass("Humanoid")
	local tseat = thuman and thuman.SeatPart

	if not tseat then return end

	local obj = tseat

	while obj and obj ~= Workspace do
		if IsBreakGucciToy(obj) then
			RememberBreakGucciSeat(obj, thuman)
			QueueBreakGucciToy(obj, tplr)
			return
		end

		obj = obj.Parent
	end

	local objectModel = tseat:FindFirstAncestor("ObjectModel")

	if objectModel then
		obj = objectModel

		while obj and obj ~= Workspace do
			if IsBreakGucciToy(obj) then
				RememberBreakGucciSeat(obj, thuman)
				QueueBreakGucciToy(obj, tplr)
				return
			end

			obj = obj.Parent
		end
	end
end

function ScanAndQueueAllBreakGuccis(tplr)
	if not tplr then return end

	local thuman = tplr.Character and tplr.Character:FindFirstChildOfClass("Humanoid")

	for _, container in pairs(GetBreakGucciContainers(tplr)) do
		for _, toy in pairs(container:GetChildren()) do
			if IsBreakGucciToy(toy) and not IsBreakGucciInVoid(toy) then
				RememberBreakGucciSeat(toy, thuman)
				QueueBreakGucciToy(toy, tplr)
			end
		end
	end
end

function ListenBreakGucciContainer(container, tplr)
	if not container then return end
	if BreakGucciListeningContainers[container] then return end

	BreakGucciListeningContainers[container] = true

	table.insert(BreakGucciConns, container.ChildAdded:Connect(function(toy)
		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) then return end

		task.spawn(function()
			task.wait(0.08)

			if toy and toy.Parent and IsBreakGucciToy(toy) and not IsBreakGucciInVoid(toy) then
				local thuman = tplr and tplr.Character and tplr.Character:FindFirstChildOfClass("Humanoid")
				RememberBreakGucciSeat(toy, thuman)
				QueueBreakGucciToy(toy, tplr)
			end
		end)
	end))
end

function HookBreakGucciHumanoid(thuman, tplr)
	if not thuman then return end

	table.insert(BreakGucciConns, thuman:GetPropertyChangedSignal("SeatPart"):Connect(function()
		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) then return end

		task.spawn(function()
			task.wait(0.05)
			CheckBreakGucciSeatPart(tplr)
		end)
	end))
end

function ListenBreakGucciTarget(tplr)
	if not tplr then return end

	if tplr.Character then
		local thuman = tplr.Character:FindFirstChildOfClass("Humanoid")

		if thuman then
			HookBreakGucciHumanoid(thuman, tplr)
			CheckBreakGucciSeatPart(tplr)
		end
	end

	table.insert(BreakGucciConns, tplr.CharacterAdded:Connect(function(c)
		if not LoopApplyMethodTarget or not HasMethod(BreakGucci) then return end

		task.spawn(function()
			local thuman = c:WaitForChild("Humanoid", 10)
			if not thuman or not LoopApplyMethodTarget or not HasMethod(BreakGucci) then return end

			HookBreakGucciHumanoid(thuman, tplr)

			task.wait(0.1)
			CheckBreakGucciSeatPart(tplr)
			ScanAndQueueAllBreakGuccis(tplr)
		end)
	end))
end

function RefreshBreakGucciWatchers()
	BreakGucciToken = BreakGucciToken + 1
	BreakGucciQueue = {}
	BreakGucciQueueRunning = false
	BreakGucciRememberedSeats = {}

	ClearBreakGucciConns()
	StopBreakGucciNoclip()

	if not LoopApplyMethodTarget or not HasMethod(BreakGucci) then return end

	for _, tplr in pairs(GetAllTargets()) do
		ListenBreakGucciTarget(tplr)

		for _, container in pairs(GetBreakGucciContainers(tplr)) do
			ListenBreakGucciContainer(container, tplr)
		end

		ScanAndQueueAllBreakGuccis(tplr)
		CheckBreakGucciSeatPart(tplr)
	end
end

function ApplyBreakGucciMulti()
	if not LoopApplyMethodTarget or not HasMethod(BreakGucci) then return end

	for _, tplr in pairs(GetAllTargets()) do
		ScanAndQueueAllBreakGuccis(tplr)
		CheckBreakGucciSeatPart(tplr)
	end
end


function ForceOwnership(plr)
	if not IsGoodTarget(plr) then return false end
	if OwnsTarget(plr) then return true end

	local ch = plr.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	if not root then return false end

	if not TeleportIfFar(root) then return false end

	local started = os.clock()

	while LoopApplyMethodTarget
		and IsGoodTarget(plr)
		and not OwnsTarget(plr)
		and os.clock() - started < TargetMethodConfig.OwnerTimeout do

		RefreshTargetCharacter()

		ch = plr.Character
		root = ch and ch:FindFirstChild("HumanoidRootPart")

		if IsDead() or not hrp or not root then
			return false
		end

		if TargetDistance(root) > TargetMethodConfig.NearDistance then
			if not TeleportUnderTarget(root) then
				return false
			end
		end

		SetOwnerLine(root, root.CFrame, false)

		task.wait(0.006)
	end

	return OwnsTarget(plr)
end

function ApplyKill(plr)
	local ch = plr.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")

	if not root or not hum then return end

	hum.BreakJointsOnDeath = false
	hum.Health = 0

	HeavenTarget(root)

	task.wait()

	DestroyOwnerLine(root)
end

function ApplyHeaven(plr)
	local ch = plr.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")

	if not root or not hum then return end

	hum.BreakJointsOnDeath = false

	HeavenTarget(root)

	task.wait()

	DestroyOwnerLine(root)
end

function StopLoopGrab()
	if LoopGrabConn then
		LoopGrabConn:Disconnect()
		LoopGrabConn = nil
	end

	LoopGrabTarget = nil
	LoopGrabLastGrab = 0
	LoopGrabLastDestroy = 0
end

function StartLoopGrab(plr)
	if not LoopApplyMethodTarget then return end
	if not HasKickOwnership() then
		StopLoopGrab()
		return
	end
	if not IsGoodTarget(plr) then
		StopLoopGrab()
		return
	end
	if not OwnsTarget(plr) then
		StopLoopGrab()
		return
	end

	LoopGrabTarget = plr
	LoopGrabLastGrab = 0
	LoopGrabLastDestroy = 0

	if LoopGrabConn then return end

	LoopGrabConn = RunService.Heartbeat:Connect(function()
		if not LoopApplyMethodTarget or not HasKickOwnership() then
			StopLoopGrab()
			return
		end

		local target = LoopGrabTarget
		if not target or not IsGoodTarget(target) or not OwnsTarget(target) then
			StopLoopGrab()
			return
		end

		RefreshTargetCharacter()

		local ch = target.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")

		if not root or not hum then
			StopLoopGrab()
			return
		end

		local baseCF = TargetMethodReturnCFrame or (hrp and hrp.CFrame) or root.CFrame
		local lockCF = baseCF * TargetMethodConfig.LockOffset
		local now = os.clock()

		hum.PlatformStand = true
		hum.Sit = false

		root.CFrame = lockCF
		ZeroVelocity(root)

		if now - LoopGrabLastGrab >= TargetMethodConfig.GrabRate then
			LoopGrabLastGrab = now
			SetOwnerLine(root, lockCF, true)
		end

		if now - LoopGrabLastDestroy >= TargetMethodConfig.DestroyRate then
			LoopGrabLastDestroy = now
			DestroyOwnerLine(root)
		end
	end)
end

function ApplyKickOwnership(plr)
	if not IsGoodTarget(plr) then
		StopLoopGrab()
		return
	end

	local ch = plr.Character
	local root = ch and ch:FindFirstChild("HumanoidRootPart")
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")

	if not root or not hum then
		StopLoopGrab()
		return
	end

	if not OwnsTarget(plr) then
		if not ForceOwnership(plr) then
			StopLoopGrab()
			return
		end
	end

	StartLoopGrab(plr)
end

function ApplyTargetMethods(plr)
	if not IsGoodTarget(plr) then return end

	for _, method in pairs(TargetPlayerMethods) do
		if method == "Kill" then
			if OwnsTarget(plr) then
				ApplyKill(plr)
			end

		elseif method == Heaven then
			if OwnsTarget(plr) then
				ApplyHeaven(plr)
			end

		elseif method == KickOwnership then
			ApplyKickOwnership(plr)

		elseif method == BreakGucci then
			ApplyBreakGucciMulti()

		elseif method == "Anti Anti-Kick" then
			ApplyAntiAntiKick(plr)

		elseif method == "Anti Anti-Input" then
			ApplyAntiAntiInput(plr)
		end
	end
end

function HasKickOwnership()
	for _, method in pairs(TargetPlayerMethods) do
		if method == KickOwnership then
			return true
		end
	end
	return false
end

function HasOwnerNeededMethod()
	for _, method in pairs(TargetPlayerMethods) do
		if method == "Kill" or method == Heaven or method == KickOwnership then
			return true
		end
	end
	return false
end

function GetFirstTarget()
	local name = TargetPlayers and TargetPlayers[1]

	if not name then
		return nil
	end

	local plr = FindTargetPlayer(name)

	if IsGoodTarget(plr) then
		return plr
	end
end

function RunTargetMethodsOnce()
	if TargetMethodBusy then return end
	if not RefreshTargetCharacter() then return end
	if #TargetPlayers <= 0 or #TargetPlayerMethods <= 0 then return end

	TargetMethodBusy = true

	if HasMethod(BreakGucci) then
		ApplyBreakGucciMulti()
	end

	if HasMethod("Anti Anti-Input") or HasMethod("Anti Anti-Kick") then
		for _, plr in pairs(GetAllTargets()) do
			if not LoopApplyMethodTarget then break end

			if HasMethod("Anti Anti-Input") then
				ApplyAntiAntiInput(plr)
			end

			if HasMethod("Anti Anti-Kick") then
				ApplyAntiAntiKick(plr)
			end
		end
	end

	if not HasOwnerNeededMethod() then
		TargetMethodBusy = false
		return
	end

	if HasKickOwnership() then
		local plr = GetFirstTarget()

		if plr then
			if OwnsTarget(plr) or ForceOwnership(plr) then
				ReturnFromTargets()
				ApplyKickOwnership(plr)
			else
				StopLoopGrab()
				ReturnFromTargets()
			end
		else
			StopLoopGrab()
		end

		TargetMethodBusy = false
		return
	end

	local owned = {}

	for _, plr in pairs(GetAllTargets()) do
		if not LoopApplyMethodTarget then break end

		if ForceOwnership(plr) then
			table.insert(owned, plr)
		end
	end

	ReturnFromTargets()

	task.wait(0.03)

	for _, plr in pairs(owned) do
		if not LoopApplyMethodTarget then break end

		ApplyTargetMethods(plr)

		task.wait(0.02)
	end

	TargetMethodBusy = false
end

function StopTargetMethods()
	LoopApplyMethodTarget = false

	if LoopMethodTargetThread then
		task.cancel(LoopMethodTargetThread)
		LoopMethodTargetThread = nil
	end

	TargetMethodBusy = false

	StopLoopGrab()
	ClearAntiMethodWatchers()
	StopBreakGucciAll()
	ReturnFromTargets()
end

TargetPlayerMethodsDropdown = PlayerTargetSection:AddDropdown("TargetPlayerMethodsDropdown", {
	Text = "Methods",
	Values = {"Kill", Heaven, KickOwnership, BreakGucci, "Anti Anti-Kick", "Anti Anti-Input"},
	Default = nil,
	Multi = true,
	Callback = function(Value)
		TargetPlayerMethods = MultiToList(Value)

		if not HasKickOwnership() then
			StopLoopGrab()
		end

		RefreshAntiMethodWatchers()
		RefreshBreakGucciWatchers()

		if RagdollTargetToggle then
			local show = HasKickOwnership()
			RagdollTargetToggle:SetVisible(show)
		end
	end
})

LoopApplyMethodTarget = PlayerTargetSection:AddToggle("LoopApplyMethodTarget", {
	Text = "Loop Method",
	Default = false,
	Callback = function(state)
		LoopApplyMethodTarget = state

		if not state then
			StopTargetMethods()
			return
		end

		RefreshAntiMethodWatchers()
		RefreshBreakGucciWatchers()

		if LoopMethodTargetThread then return end

		LoopMethodTargetThread = task.spawn(function()
			while LoopApplyMethodTarget do
				RunTargetMethodsOnce()
				task.wait(0.035)
			end

			LoopMethodTargetThread = nil
		end)
	end
})

Players.PlayerAdded:Connect(function()
	task.wait(0.05)
	RefreshAntiMethodWatchers()
	RefreshBreakGucciWatchers()
end)

Players.PlayerRemoving:Connect(function()
	task.wait()
	RefreshAntiMethodWatchers()
	RefreshBreakGucciWatchers()
end)

player.CharacterRemoving:Connect(function()
	StopTargetMethods()
end)

player.CharacterAdded:Connect(function(newChar)
	task.wait(0.05)

	char = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
	human = newChar:WaitForChild("Humanoid")

	RefreshAntiMethodWatchers()
	RefreshBreakGucciWatchers()
end)

-------------------------->> [Ragdoll Target] <<--------------------------

PalletForRagdoll = nil
RagdollConnection = nil
RagdollThread = nil
RagdollAttackThread = nil
RagdollSpawnBusy = false
RagdollLastSpawn = 0
RagdollLastMissingTarget = 0
RagdollTargetToggle = false

function IsTargetRagdolled(plr)
	local ch = plr and plr.Character
	local head = ch and ch:FindFirstChild("Head")
	local socket = head and head:FindFirstChild("BallSocketConstraint")
	return socket and socket.Enabled == true
end

function GetRagdollTarget()
	if typeof(Target) == "table" then
		for name, enabled in pairs(Target) do
			if enabled then
				local plr = FindTargetPlayer(tostring(name))
				if plr then
					return plr
				end
			end
		end
	elseif Target then
		return FindTargetPlayer(tostring(Target))
	end

	if TargetPlayers and TargetPlayers[1] then
		return FindTargetPlayer(tostring(TargetPlayers[1]))
	end
end

function GetRagdollPallet()
	local Container = BackPack()
	if not Container then return nil end

	for _, v in ipairs(Container:GetChildren()) do
		if (v.Name == "RagdollPallet" or v.Name == "PalletLightBrown") and v:FindFirstChild("SoundPart") then
			v.Name = "RagdollPallet"
			return v
		end
	end
end

function DestroyRagdollPallet()
	if PalletForRagdoll and PalletForRagdoll.Parent then
		pcall(function()
			Destroy:FireServer(PalletForRagdoll)
		end)
	end

	local Container = BackPack()
	if Container then
		for _, v in ipairs(Container:GetChildren()) do
			if v.Name == "RagdollPallet" or v.Name == "PalletLightBrown" then
				pcall(function()
					Destroy:FireServer(v)
				end)
			end
		end
	end

	PalletForRagdoll = nil
end

function SpawnRagdollPallet()
	if RagdollSpawnBusy then return nil end
	if os.clock() - RagdollLastSpawn < 1 then return nil end

	local oldPallet = GetRagdollPallet()
	if oldPallet then
		PalletForRagdoll = oldPallet
		return oldPallet
	end

	RagdollSpawnBusy = true
	RagdollLastSpawn = os.clock()

	char = player.Character
	hrp = char and char:FindFirstChild("HumanoidRootPart")

	local Container = BackPack()
	if not Container or not hrp or not RagdollTargetToggle or not HasKickOwnership() then
		RagdollSpawnBusy = false
		return nil
	end

	if player:FindFirstChild("CanSpawnToy") then
		local startWait = os.clock()
		while RagdollTargetToggle and not player.CanSpawnToy.Value and os.clock() - startWait < 2 do
			task.wait(0.05)
		end
	end

	local old = {}
	for _, v in ipairs(Container:GetChildren()) do
		old[v] = true
	end

	task.spawn(function()
		pcall(function()
			SpawnToy:InvokeServer("PalletLightBrown", hrp.CFrame * CFrame.new(0, 12, 17), Vector3.new(0, 60, 0))
		end)
	end)

	local start = os.clock()
	local newPallet = nil

	while RagdollTargetToggle and HasKickOwnership() and os.clock() - start < 2 do
		Container = BackPack()

		if Container then
			for _, v in ipairs(Container:GetChildren()) do
				if v.Name == "PalletLightBrown" and not old[v] and v:FindFirstChild("SoundPart") then
					newPallet = v
					break
				end
			end
		end

		if newPallet then break end
		task.wait(0.03)
	end

	if newPallet and newPallet.Parent then
		newPallet.Name = "RagdollPallet"
		PalletForRagdoll = newPallet
	end

	RagdollSpawnBusy = false
	return newPallet
end

function SetupRagdollPallet(pallet)
	if not pallet or not pallet.Parent or not pallet:FindFirstChild("SoundPart") then
		return false
	end

	for _, v in ipairs(pallet:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.CanQuery = false
			v.Transparency = 1
		end
	end

	local soundPart = pallet.SoundPart
	local owner = soundPart:FindFirstChild("PartOwner")

	if owner and owner.Value == player.Name then
		return true
	end

	local start = os.clock()

	while RagdollTargetToggle and HasKickOwnership() and pallet.Parent and soundPart.Parent and os.clock() - start < 3 do
		owner = soundPart:FindFirstChild("PartOwner")

		if owner and owner.Value == player.Name then
			return true
		end

		pcall(function()
			SetOwner:FireServer(soundPart, soundPart.CFrame)
		end)

		task.wait(0.05)
	end

	return false
end

function ParkRagdollPallet()
	char = player.Character
	hrp = char and char:FindFirstChild("HumanoidRootPart")

	local pallet = PalletForRagdoll
	local soundPart = pallet and pallet.Parent and pallet:FindFirstChild("SoundPart")

	if soundPart and hrp then
		soundPart.CFrame = hrp.CFrame * CFrame.new(0, 1e6, 0)
		soundPart.AssemblyLinearVelocity = Vector3.zero
		soundPart.AssemblyAngularVelocity = Vector3.zero
	end
end

RagdollTargetToggle = PlayerTargetSection:AddToggle("RagdollTarget", {
	Text = "Ragdoll | Target",
	Default = false,

	Callback = function(Value)
		RagdollTargetToggle = Value

		if RagdollConnection then
			RagdollConnection:Disconnect()
			RagdollConnection = nil
		end

		if RagdollThread then
			task.cancel(RagdollThread)
			RagdollThread = nil
		end

		if RagdollAttackThread then
			task.cancel(RagdollAttackThread)
			RagdollAttackThread = nil
		end

		if not Value then
			RagdollSpawnBusy = false
			DestroyRagdollPallet()
			return
		end

		RagdollThread = task.spawn(function()
			while RagdollTargetToggle do
				if not HasKickOwnership() then
					ParkRagdollPallet()
					task.wait(0.2)
					continue
				end

				local pallet = PalletForRagdoll

				if not pallet or not pallet.Parent or not pallet:FindFirstChild("SoundPart") then
					pallet = GetRagdollPallet()
				end

				if not pallet or not pallet.Parent or not pallet:FindFirstChild("SoundPart") then
					pallet = SpawnRagdollPallet()
				end

				if pallet and pallet.Parent and pallet:FindFirstChild("SoundPart") then
					PalletForRagdoll = pallet
					SetupRagdollPallet(pallet)
				end

				task.wait(0.15)
			end
		end)

		RagdollAttackThread = task.spawn(function()
			while RagdollTargetToggle do
				if not HasKickOwnership() then
					task.wait(0.15)
					continue
				end

				local targetPlr = GetRagdollTarget()

				if not targetPlr then
					if os.clock() - RagdollLastMissingTarget > 0.5 then
						RagdollLastMissingTarget = os.clock()
						ParkRagdollPallet()
					end

					task.wait(0.2)
					continue
				end

				char = player.Character
				hrp = char and char:FindFirstChild("HumanoidRootPart")

				local targetChar = targetPlr.Character
				local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
				local targetHead = targetChar and targetChar:FindFirstChild("Head")
				local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

				if not hrp or not targetHum or targetHum.Health <= 0 or not targetHead or not targetHRP then
					ParkRagdollPallet()
					task.wait(0.15)
					continue
				end

				local pallet = PalletForRagdoll
				local soundPart = pallet and pallet.Parent and pallet:FindFirstChild("SoundPart")

				if not soundPart then
					task.wait(0.1)
					continue
				end

				if not LoopApplyMethodTarget or (targetHRP.Position - hrp.Position).Magnitude > 30 or IsTargetRagdolled(targetPlr) then
					ParkRagdollPallet()
					task.wait(0.08)
					continue
				end

				local owner = soundPart:FindFirstChild("PartOwner")
				if not owner or owner.Value ~= player.Name then
					SetupRagdollPallet(pallet)
					task.wait(0.08)
					continue
				end

				while RagdollTargetToggle
					and HasKickOwnership()
					and targetPlr.Parent
					and soundPart.Parent
					and targetHead.Parent
					and not IsTargetRagdolled(targetPlr)
				do
					char = player.Character
					hrp = char and char:FindFirstChild("HumanoidRootPart")
					targetChar = targetPlr.Character
					targetHead = targetChar and targetChar:FindFirstChild("Head")
					targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

					if not hrp or not targetHead or not targetHRP then break end
					if not LoopApplyMethodTarget then break end
					if (targetHRP.Position - hrp.Position).Magnitude > 30 then break end

					soundPart.CFrame = targetHead.CFrame * CFrame.new(0, 0.35, 0)
					soundPart.AssemblyLinearVelocity = Vector3.new(0, -1e9, 0)
					soundPart.AssemblyAngularVelocity = Vector3.zero
					task.wait()
					soundPart.CFrame = targetHead.CFrame * CFrame.new(0, 1e9, 0)
					soundPart.CFrame = targetHead.CFrame * CFrame.new(0, 1e18, 0)
				end

				ParkRagdollPallet()
				task.wait(0.05)
			end

			ParkRagdollPallet()
		end)
	end
})

RagdollTargetToggle:SetVisible(false)

if HasKickOwnership() then
	RagdollTargetToggle:SetVisible(true)
end

-------------------------->> [Blobman Methods] <<--------------------------

BlobmanMethod = "Bring"
BlobmanTargetLeft = nil
BlobmanTargetRight = nil

BlobmanMethodLoop = false

BlobmanLoopThread = nil
BlobmanLoopBusy = false
BlobmanLoopToken = 0
BlobmanCompletedChars = {}
BlobmanRespawnConns = {}
BlobmanLastSeenChars = {}

BlobmanNoClipConn = nil
BlobmanNoClipSaved = {}
BlobmanReturnBV = nil
BlobmanCamTag = "BlobmanTargets"
BlobHipHeightLoop = false
BlobHipHeightLoopThread = BlobHipHeightLoopThread or nil

FAST_LOOP_WAIT = 0.02
FAST_RESPAWN_WAIT = 0.02
SAFE_RETURN_TRIES = 10
BLOB_SEAT_TIMEOUT = 1.75
BLOB_SPAWN_TIMEOUT = 3
BLOB_TARGET_UNDER_OFFSET = CFrame.new(0, -30, 0)

function GetBlobTarget(v)
	if typeof(v) == "Instance" and v:IsA("Player") then
		return v
	end

	if typeof(v) == "table" then
		for _, x in pairs(v) do
			local found = GetBlobTarget(x)
			if found then return found end
		end
	end

	if v == nil then return nil end

	local txt = tostring(v)
	if txt == "" or txt == "nil" then return nil end

	local direct = Players:FindFirstChild(txt)
	if direct then return direct end

	txt = string.lower(txt)

	for _, plr in ipairs(Players:GetPlayers()) do
		if string.lower(plr.Name) == txt or string.lower(plr.DisplayName) == txt then
			return plr
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(plr.Name), txt, 1, true) or string.find(string.lower(plr.DisplayName), txt, 1, true) then
			return plr
		end
	end
end

function GetBlobTarget1()
	return GetBlobTarget(BlobmanTargetLeft)
end

function GetBlobTarget2()
	return GetBlobTarget(BlobmanTargetRight)
end

function RefreshBlobChar()
	char = player.Character or player.CharacterAdded:Wait()
	human = char:FindFirstChildOfClass("Humanoid")
	hrp = char:FindFirstChild("HumanoidRootPart")
	return char, human, hrp
end

function SelfAlive()
	RefreshBlobChar()
	return char and human and hrp and human.Health > 0
end

function AliveBlobPlayer(plr)
	local c = plr and plr.Character
	local h = c and c:FindFirstChildOfClass("Humanoid")
	local r = c and c:FindFirstChild("HumanoidRootPart")
	return c and h and r and h.Health > 0
end

function ZeroBlobPart(part)
	if not part then return end
	part.AssemblyLinearVelocity = Vector3.zero
	part.AssemblyAngularVelocity = Vector3.zero
end

function SetBlobCF(part, cf)
	if not part or not cf then return end
	part.CFrame = cf
	ZeroBlobPart(part)
end

function SaveBlobNoClip(part)
	if part and part:IsA("BasePart") and BlobmanNoClipSaved[part] == nil then
		BlobmanNoClipSaved[part] = part.CanCollide
	end
end

function GetCurrentBlob()
	RefreshBlobChar()

	if human and human.SeatPart then
		local blob = human.SeatPart:FindFirstAncestorWhichIsA("Model")

		if blob and blob.Name:find("CreatureBlobman") then
			return blob
		end
	end
end

function GetBlobHumanoid(blob)
	if not blob then return end

	local hum = blob:FindFirstChildOfClass("Humanoid")
	if hum then return hum end

	return blob:FindFirstChildWhichIsA("Humanoid", true)
end

function IsTargetAlive(tHRP)
	local hum = tHRP and tHRP.Parent and tHRP.Parent:FindFirstChildOfClass("Humanoid")
	return tHRP and tHRP.Parent and hum and hum.Health > 0
end

function ForceBlobHipHeight(blob, height, seconds)
	seconds = seconds or 0.25
	local started = os.clock()

	while os.clock() - started < seconds do
		blob = GetCurrentBlob() or blob

		if not blob or not blob.Parent or not IsOnBlob(blob) then
			return nil
		end

		local hum = GetBlobHumanoid(blob)

		if hum then
			hum.HipHeight = height
			_G.BlobLoopHum = hum
		end

		RunService.Heartbeat:Wait()
	end

	blob = GetCurrentBlob() or blob

	if blob and blob.Parent and IsOnBlob(blob) then
		local hum = GetBlobHumanoid(blob)

		if hum then
			hum.HipHeight = height
			_G.BlobLoopHum = hum
			return hum
		end
	end
end

function StopBlobHipHeightLoop()
	BlobHipHeightLoop = false

	if BlobHipHeightLoopThread then
		task.cancel(BlobHipHeightLoopThread)
		BlobHipHeightLoopThread = nil
	end

	if _G.BlobLoopHum and _G.BlobOldHipHeight then
		pcall(function()
			_G.BlobLoopHum.HipHeight = _G.BlobOldHipHeight
		end)
	end
end

function FindBlobInInv(inv)
	if not inv then return end

	for _, v in ipairs(inv:GetChildren()) do
		if v.Name:find("CreatureBlobman") then
			return v
		end
	end
end

function GetAnyBlob()
	local current = GetCurrentBlob()
	if current then return current end

	local inv = Workspace:FindFirstChild(player.Name .. "SpawnedInToys")
	if not inv then return end

	return FindBlobInInv(inv)
end

function StartBlobNoclip()
	if BlobmanNoClipConn then return end

	BlobmanNoClipSaved = {}

	BlobmanNoClipConn = RunService.RenderStepped:Connect(function()
		RefreshBlobChar()

		local blob = GetCurrentBlob() or GetAnyBlob()

		for _, model in ipairs({char, blob}) do
			if model then
				for _, v in ipairs(model:GetDescendants()) do
					if v:IsA("BasePart") then
						SaveBlobNoClip(v)
						v.CanCollide = false
					end
				end
			end
		end
	end)
end

function StopBlobNoclip()
	if BlobmanNoClipConn then
		BlobmanNoClipConn:Disconnect()
		BlobmanNoClipConn = nil
	end

	for part, old in pairs(BlobmanNoClipSaved) do
		if part and part.Parent and part:IsA("BasePart") then
			part.CanCollide = old
		end
	end

	BlobmanNoClipSaved = {}
end

function StartReturnBV()
	RefreshBlobChar()
	if not hrp then return end

	if BlobmanReturnBV then
		BlobmanReturnBV:Destroy()
	end

	BlobmanReturnBV = Instance.new("BodyVelocity")
	BlobmanReturnBV.Name = "BlobmanReturnBV"
	BlobmanReturnBV.MaxForce = Vector3.new(0, math.huge, 0)
	BlobmanReturnBV.Velocity = Vector3.zero
	BlobmanReturnBV.Parent = hrp
end

function StopReturnBV()
	if BlobmanReturnBV then
		BlobmanReturnBV:Destroy()
		BlobmanReturnBV = nil
	end
end

function ForceBlobCameraBack()
	RefreshBlobChar()

	if human and Workspace.CurrentCamera then
		Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		Workspace.CurrentCamera.CameraSubject = human
	end
end

function StopBlobCam()
	if StopCamPart then
		StopCamPart(BlobmanCamTag, false)
	end

	ForceBlobCameraBack()
end

function SafeBlobReturn(cf)
	if not cf then return end

	for i = 1, SAFE_RETURN_TRIES do
		RefreshBlobChar()

		if hrp then
			hrp.Anchored = true
			SetBlobCF(hrp, cf + Vector3.new(0, 0.5, 0))
		end

		RunService.Heartbeat:Wait()
	end

	RefreshBlobChar()

	if hrp then
		hrp.Anchored = false
		ZeroBlobPart(hrp)
	end
end

function BlobCleanup(oldCF)
	SafeBlobReturn(oldCF)

	StopBlobCam()
	StopBlobNoclip()
	StopReturnBV()
	ForceBlobCameraBack()
	StopBlobHipHeightLoop()

	BlobmanLoopBusy = false
end

function IsOnBlob(blob)
	RefreshBlobChar()

	local seat = blob and blob:FindFirstChildWhichIsA("VehicleSeat", true)
	return human and seat and human.SeatPart == seat
end

function SeatBlobFast(blob, timeout)
	RefreshBlobChar()

	if not blob or not human or not hrp then return end

	local seat = blob:FindFirstChildWhichIsA("VehicleSeat", true)
	if not seat then return end

	local started = os.clock()

	while BlobmanMethodLoop and os.clock() - started < timeout do
		RefreshBlobChar()

		if not SelfAlive() or not blob.Parent or not seat.Parent then
			return
		end

		if human.SeatPart == seat then
			return blob
		end

		StartBlobNoclip()

		hrp.Anchored = false
		human.PlatformStand = false
		human.Sit = false

		SetBlobCF(hrp, seat.CFrame * CFrame.new(0, 3, 0))
		seat:Sit(human)

		task.wait(FAST_LOOP_WAIT)
	end
end

function SpawnBlobmanAsync()
	RefreshBlobChar()
	if not hrp then return end

	task.spawn(function()
		pcall(function()
			Spawn:InvokeServer("CreatureBlobman", hrp.CFrame * CFrame.new(0, 0, 14), Vector3.new(0, 60, 0))
		end)
	end)
end

function QuickSeat()
	RefreshBlobChar()
	if not human or not hrp then return end

	local currentBlob = GetCurrentBlob()
	if currentBlob and IsOnBlob(currentBlob) then
		return currentBlob
	end

	local inv = Workspace:FindFirstChild(player.Name .. "SpawnedInToys") or Workspace:WaitForChild(player.Name .. "SpawnedInToys", 2)
	if not inv then return end

	local oldBlob = FindBlobInInv(inv)

	if oldBlob then
		local seated = SeatBlobFast(oldBlob, BLOB_SEAT_TIMEOUT)
		if seated and IsOnBlob(seated) then
			return seated
		end
	end

	SpawnBlobmanAsync()

	local spawnedBlob
	local start = os.clock()

	repeat
		spawnedBlob = FindBlobInInv(inv)
		task.wait()
	until spawnedBlob or os.clock() - start > BLOB_SPAWN_TIMEOUT or not BlobmanMethodLoop or not SelfAlive()

	if not spawnedBlob then return end

	local seated = SeatBlobFast(spawnedBlob, BLOB_SEAT_TIMEOUT)

	if seated and IsOnBlob(seated) then
		return seated
	end

	return GetCurrentBlob()
end

function EnsureBlobSeated()
	while BlobmanMethodLoop and SelfAlive() do
		local blob = GetCurrentBlob()

		if blob and IsOnBlob(blob) then
			return blob
		end

		blob = QuickSeat()

		if blob and IsOnBlob(blob) then
			return blob
		end

		task.wait(FAST_RESPAWN_WAIT)
	end
end

function ForceBlobAndSelfNoClipNow(blob)
	RefreshBlobChar()
	blob = blob or GetCurrentBlob() or GetAnyBlob()

	for _, model in ipairs({char, blob}) do
		if model then
			for _, v in ipairs(model:GetDescendants()) do
				if v:IsA("BasePart") then
					SaveBlobNoClip(v)
					v.CanCollide = false
					ZeroBlobPart(v)
				end
			end
		end
	end
end

function GetBlobMainPart(blob)
	if not blob then return end

	return blob.PrimaryPart
		or blob:FindFirstChild("HumanoidRootPart", true)
		or blob:FindFirstChild("MainPart", true)
		or blob:FindFirstChildWhichIsA("VehicleSeat", true)
		or blob:FindFirstChildWhichIsA("BasePart", true)
end

function MoveSelfNearTarget(plr, offset)
	RefreshBlobChar()

	local tChar = plr and plr.Character
	local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")

	if not hrp or not tHRP then return end

	StartBlobNoclip()

	local blob = GetCurrentBlob() or GetAnyBlob()
	ForceBlobAndSelfNoClipNow(blob)

	offset = offset or BLOB_TARGET_UNDER_OFFSET
	local targetCF = tHRP.CFrame * offset

	SetBlobCF(hrp, targetCF)

	if blob then
		local blobMain = GetBlobMainPart(blob)
		if blobMain then
			SetBlobCF(blobMain, targetCF)
		end
	end

	ForceBlobAndSelfNoClipNow(blob)

	return tHRP
end

function GetHeldHRP(hand)
	local blob = GetCurrentBlob()
	if not blob then return end

	local welds

	if hand == 1 or hand == "Left" then
		welds = {
			blob:FindFirstChild("LeftDetector") and blob.LeftDetector:FindFirstChild("LeftWeld")
		}
	elseif hand == 2 or hand == "Right" then
		welds = {
			blob:FindFirstChild("RightDetector") and blob.RightDetector:FindFirstChild("RightWeld")
		}
	else
		welds = {
			blob:FindFirstChild("LeftDetector") and blob.LeftDetector:FindFirstChild("LeftWeld"),
			blob:FindFirstChild("RightDetector") and blob.RightDetector:FindFirstChild("RightWeld")
		}
	end

	for _, weld in ipairs(welds) do
		if weld and weld.Attachment0 and weld.Attachment0.Name == "RootAttachment" then
			local heldHRP = weld.Attachment0.Parent

			if heldHRP and heldHRP.Name == "HumanoidRootPart" then
				return heldHRP
			end
		end
	end
end

function R6JointsBroken(plr)
	local c = plr and plr.Character
	if not c then return false end

	local hum = c:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then return false end

	local torso = c:FindFirstChild("Torso")
	local root = c:FindFirstChild("HumanoidRootPart")

	if not torso then return true end

	for _, data in ipairs({
		{torso, "Neck"},
		{torso, "Left Shoulder"},
		{torso, "Right Shoulder"},
		{torso, "Left Hip"},
		{torso, "Right Hip"},
		{root, "RootJoint"}
	}) do
		local joint = data[1] and data[1]:FindFirstChild(data[2])

		if joint and joint:IsA("Motor6D") and joint.Part0 and joint.Part1 then
			return false
		end
	end

	return true
end

function BlobGrabOnce(blob, tHRP, hand)
	local s = blob and blob:FindFirstChild("BlobmanSeatAndOwnerScript")
	local grab = s and s:FindFirstChild("CreatureGrab")

	if not grab or not tHRP then return end

	local side = (hand == 2 or hand == "Right") and "Right" or "Left"
	local det = blob:FindFirstChild(side .. "Detector")
	local weld = det and det:FindFirstChild(side .. "Weld")

	if det and weld then
		grab:FireServer(det, tHRP, weld)
	end
end

function BlobDropOnce(blob, tHRP, hand)
	local ds = blob and blob:FindFirstChild("BlobmanSeatAndOwnerScript")
	local drop = ds and ds:FindFirstChild("CreatureDrop")

	if not drop or not tHRP then return end

	local side = (hand == 2 or hand == "Right") and "Right" or "Left"
	local det = blob:FindFirstChild(side .. "Detector")
	local weld = det and det:FindFirstChild(side .. "Weld")

	if weld then
		pcall(function()
			drop:FireServer(weld, tHRP)
		end)
	end
end

function BlobGrabRelease(blob, tHRP, hand)
	local s = blob and blob:FindFirstChild("BlobmanSeatAndOwnerScript")
	local grab = s and s:FindFirstChild("CreatureGrab")
	local release = s and s:FindFirstChild("CreatureRelease")

	if not grab or not release or not tHRP then return end

	local sides = hand and {((hand == 2 or hand == "Right") and "Right" or "Left")} or {"Left", "Right"}

	for _, side in ipairs(sides) do
		local det = blob:FindFirstChild(side .. "Detector")
		local weld = det and det:FindFirstChild(side .. "Weld")

		if det and weld then
			grab:FireServer(det, tHRP, weld)
			task.wait()
			release:FireServer(weld, tHRP)
		end
	end
end

function DoBlobBring(blob, plr, hand)
	for i = 1, 20 do
		if not BlobmanMethodLoop or not SelfAlive() then return false end
		if not AliveBlobPlayer(plr) then return true end

		blob = GetCurrentBlob()
		if not blob or not IsOnBlob(blob) then return false end

		local tHRP = MoveSelfNearTarget(plr)
		if not tHRP then return false end

		BlobGrabOnce(blob, tHRP, hand)

		if GetHeldHRP(hand) == tHRP then
			return true
		end

		task.wait(FAST_LOOP_WAIT)
	end

	return false
end

function DoBlobKill(blob, plr, hand)
	for i = 1, 8 do
		if not BlobmanMethodLoop or not SelfAlive() then return false end
		if not plr.Parent or not plr.Character or R6JointsBroken(plr) then return true end

		blob = GetCurrentBlob()
		if not blob or not IsOnBlob(blob) then return false end

		local tHRP = MoveSelfNearTarget(plr)
		if not tHRP then return false end

		BlobGrabRelease(blob, tHRP, hand)

		task.spawn(function()
			local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if h then
				h.BreakJointsOnDeath = false
				h.Health = 0
			end
		end)

		if R6JointsBroken(plr) then
			return true
		end

		task.wait(FAST_LOOP_WAIT)
	end

	return R6JointsBroken(plr)
end

function DoBlobFreeze(blob, plr, hand)
	for i = 1, 8 do
		if not BlobmanMethodLoop or not SelfAlive() then return false end
		if not AliveBlobPlayer(plr) then return true end

		blob = GetCurrentBlob()
		if not blob or not IsOnBlob(blob) then return false end

		local tHRP = MoveSelfNearTarget(plr)
		if not tHRP then return false end

		BlobGrabRelease(blob, tHRP, hand)

		task.wait(FAST_LOOP_WAIT)
	end

	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")

	if hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	end

	return true
end

function RunLockedBlobKick(targets)
	if not targets or #targets <= 0 then return false end

	local t1 = targets[1] and targets[1].Player
	local t2 = targets[2] and targets[2].Player

	if not AliveBlobPlayer(t1) then return false end

	RefreshBlobChar()
	if not hrp then return false end

	local oldCF = hrp.CFrame
	local cleaned = false
	local blob

	local function cleanup()
		if cleaned then return end
		cleaned = true
		BlobCleanup(oldCF)
	end

	if StartCamPart then
		StartCamPart(BlobmanCamTag)
	end

	StartBlobNoclip()
	StartReturnBV()

	blob = EnsureBlobSeated()

	if not blob or not IsOnBlob(blob) then
		cleanup()
		return false
	end

	local function requireBlob()
		local b = GetCurrentBlob()

		if not b or not IsOnBlob(b) then
			cleanup()
			return nil
		end

		blob = b
		return b
	end

	local function grabTarget(plr, hand)
		if not AliveBlobPlayer(plr) then return true end

		for i = 1, 8 do
			if not BlobmanMethodLoop or not SelfAlive() then return false end

			blob = requireBlob()
			if not blob then return false end

			local tHRP = MoveSelfNearTarget(plr, BLOB_TARGET_UNDER_OFFSET)
			if not tHRP then return false end

			BlobGrabRelease(blob, tHRP, hand)

			task.wait(FAST_LOOP_WAIT)
		end

		return true
	end

	if t2 then
		if not grabTarget(t1, "Left") then return false end
		task.wait(FAST_LOOP_WAIT)
		if not grabTarget(t2, "Right") then return false end
	else
		if not grabTarget(t1, nil) then return false end
	end

	SafeBlobReturn(oldCF)

	task.wait(0.1)

	blob = requireBlob()
	if not blob then return false end

	RefreshBlobChar()
	if not hrp then
		cleanup()
		return false
	end

	local t1HRP = t1 and t1.Character and t1.Character:FindFirstChild("HumanoidRootPart")
	local t2HRP = t2 and t2.Character and t2.Character:FindFirstChild("HumanoidRootPart")

	if not t1HRP or (t2 and not t2HRP) then
		cleanup()
		return false
	end

	if t2HRP then
		SetBlobCF(t1HRP, hrp.CFrame * CFrame.new(-5, 30, 0))
		SetBlobCF(t2HRP, hrp.CFrame * CFrame.new(5, 30, 0))
	else
		SetBlobCF(t1HRP, hrp.CFrame * CFrame.new(0, 30, 0))
	end

	task.wait(0.08)

	for i = 1, 8 do
		blob = requireBlob()
		if not blob then return false end

		pcall(function()
			SetOwner:FireServer(t1HRP, t1HRP.CFrame)
			if t2HRP then
				SetOwner:FireServer(t2HRP, t2HRP.CFrame)
			end
		end)

		task.wait(0.01)
	end

	pcall(function()
		if DestroyOwner then
			DestroyOwner:FireServer(t1HRP)
			if t2HRP then
				DestroyOwner:FireServer(t2HRP)
			end
		end
	end)

	task.wait()

	blob = requireBlob()
	if not blob then return false end

	BlobGrabOnce(blob, t1HRP, "Left")

	if t2HRP then
		task.wait()
		BlobGrabOnce(blob, t2HRP, "Right")
	end

	task.wait(0.1)

	pcall(function()
		Destroy:FireServer(blob)
	end)

	cleanup()

	return true
end

function RunBlobKickV2(targets)
	if not targets or #targets <= 0 then return false end

	RefreshBlobChar()
	if not hrp then return false end

	local oldCF = hrp.CFrame
	local blob
	local t1 = targets[1] and targets[1].Player
	local t2 = targets[2] and targets[2].Player
	local t1HRP
	local t2HRP

	if not AliveBlobPlayer(t1) then return true end

	if StartCamPart then
		StartCamPart(BlobmanCamTag)
	end

	StartBlobNoclip()
	StartReturnBV()

	local function fail()
		StopBlobHipHeightLoop()
		StopBlobCam()
		StopBlobNoclip()
		StopReturnBV()
		SafeBlobReturn(oldCF)
		ForceBlobCameraBack()
		return false
	end

	blob = EnsureBlobSeated()

	if not blob or not blob.Parent or not IsOnBlob(blob) then
		return fail()
	end

	local function grabUnder(plr, hand)
		if not AliveBlobPlayer(plr) then return true end

		for i = 1, 40 do
			if not BlobmanMethodLoop or not WaitBlobSelfAlive() then return false end

			blob = GetCurrentBlob() or blob

			if not blob or not blob.Parent or not IsOnBlob(blob) then return false end
			if not AliveBlobPlayer(plr) then return true end

			local tHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

			if tHRP then
				SetBlobCF(hrp, tHRP.CFrame * BLOB_TARGET_UNDER_OFFSET)
				BlobGrabOnce(blob, tHRP, hand)
			end

			task.wait(0.025)

			if tHRP and GetHeldHRP(hand) == tHRP then
				return tHRP
			end
		end

		return false
	end

	t1HRP = grabUnder(t1, "Left")

	if t1HRP == false then
		return fail()
	end

	if t2 and AliveBlobPlayer(t2) then
		t2HRP = grabUnder(t2, "Right")

		if t2HRP == false then
			t2HRP = nil
		end
	end

	SafeBlobReturn(oldCF)
	StopBlobCam()
	StopBlobNoclip()
	StopReturnBV()
	ForceBlobCameraBack()
	task.wait(0.05)

	blob = GetCurrentBlob() or blob

	if not blob or not blob.Parent or not IsOnBlob(blob) then
		return fail()
	end

	_G.BlobLoopHum = GetBlobHumanoid(blob)
	_G.BlobOldHipHeight = _G.BlobLoopHum and _G.BlobLoopHum.HipHeight or nil

	if not _G.BlobLoopHum then
		return fail()
	end

	_G.BlobLoopHum = ForceBlobHipHeight(blob, 33, 0.2)

	if not _G.BlobLoopHum then
		return fail()
	end

	task.wait(0.15)

	if t1HRP and IsTargetAlive(t1HRP) then BlobDropOnce(blob, t1HRP, "Left") end
	if t2HRP and IsTargetAlive(t2HRP) then BlobDropOnce(blob, t2HRP, "Right") end

	task.wait(0.2)

	blob = GetCurrentBlob() or blob

	if not blob or not blob.Parent or not IsOnBlob(blob) then
		return fail()
	end

	if t1HRP and IsTargetAlive(t1HRP) then BlobGrabOnce(blob, t1HRP, "Left") end
	if t2HRP and IsTargetAlive(t2HRP) then BlobGrabOnce(blob, t2HRP, "Right") end

	if _G.BlobOldHipHeight then
		ForceBlobHipHeight(blob, _G.BlobOldHipHeight, 0.15)
	end

	while BlobmanMethodLoop and WaitBlobSelfAlive() do
		blob = GetCurrentBlob() or blob

		if not blob or not blob.Parent or not IsOnBlob(blob) then break end

		local anyAlive = false

		if t1HRP and IsTargetAlive(t1HRP) then
			anyAlive = true
			BlobGrabOnce(blob, t1HRP, "Left")
			task.wait(0.025)
			BlobDropOnce(blob, t1HRP, "Left")
		end

		if t2HRP and IsTargetAlive(t2HRP) then
			anyAlive = true
			BlobGrabOnce(blob, t2HRP, "Right")
			task.wait(0.025)
			BlobDropOnce(blob, t2HRP, "Right")
		end

		if not anyAlive then break end

		task.wait(0.025)
	end

	if _G.BlobLoopHum and _G.BlobOldHipHeight then
		pcall(function()
			_G.BlobLoopHum.HipHeight = _G.BlobOldHipHeight
		end)
	end

	StopBlobCam()
	ForceBlobCameraBack()
	return true
end

function RunBlobTargetOnce(plr, hand)
	if not plr or not AliveBlobPlayer(plr) then
		return false
	end

	while BlobmanMethodLoop and SelfAlive() and AliveBlobPlayer(plr) do
		RefreshBlobChar()
		if not hrp then return false end

		local oldCF = hrp.CFrame
		local cleaned = false

		local function cleanup()
			if cleaned then return end
			cleaned = true
			BlobCleanup(oldCF)
		end

		if StartCamPart then
			StartCamPart(BlobmanCamTag)
		end

		StartBlobNoclip()
		StartReturnBV()

		local blob = EnsureBlobSeated()

		if not blob or not IsOnBlob(blob) then
			cleanup()
			task.wait(FAST_RESPAWN_WAIT)
			continue
		end

		local completed = false

		if BlobmanMethod == "Bring" then
			completed = DoBlobBring(blob, plr, hand)
		elseif BlobmanMethod == "Kill" then
			completed = DoBlobKill(blob, plr, hand)
		elseif BlobmanMethod == "Freeze" then
			completed = DoBlobFreeze(blob, plr, hand)
		else
			completed = DoBlobBring(blob, plr, hand)
		end

		cleanup()

		if completed or not AliveBlobPlayer(plr) then
			return true
		end

		task.wait(FAST_RESPAWN_WAIT)
	end

	return false
end

function GetBlobTargetsList()
	local list = {}

	local t1 = GetBlobTarget1()
	local t2 = GetBlobTarget2()

	if t1 and t1 ~= player then
		table.insert(list, {
			Player = t1,
			Hand = "Left"
		})
	end

	if t2 and t2 ~= player and t2 ~= t1 then
		table.insert(list, {
			Player = t2,
			Hand = "Right"
		})
	end

	return list
end

function ClearBlobCompleted(plr)
	if plr then
		BlobmanCompletedChars[plr] = nil
		BlobmanLastSeenChars[plr] = nil
	end
end

function WatchBlobTarget(plr)
	if not plr or plr == player or BlobmanRespawnConns[plr] then return end

	BlobmanLastSeenChars[plr] = plr.Character

	BlobmanRespawnConns[plr] = plr.CharacterAdded:Connect(function(newChar)
		BlobmanCompletedChars[plr] = nil
		BlobmanLastSeenChars[plr] = newChar

		task.spawn(function()
			local hum = newChar:WaitForChild("Humanoid", 5)
			newChar:WaitForChild("HumanoidRootPart", 5)

			if hum then
				repeat
					task.wait(FAST_RESPAWN_WAIT)
				until not BlobmanMethodLoop or hum.Health > 0
			end

			if BlobmanMethodLoop then
				RunSelectedBlobmanMethod()
			end
		end)
	end)
end

function RefreshBlobTargetWatchers(targets)
	local wanted = {}

	for _, data in ipairs(targets or {}) do
		local plr = data.Player

		if plr and plr ~= player then
			wanted[plr] = true
			WatchBlobTarget(plr)

			if BlobmanLastSeenChars[plr] ~= plr.Character then
				BlobmanCompletedChars[plr] = nil
				BlobmanLastSeenChars[plr] = plr.Character
			end
		end
	end

	for plr, conn in pairs(BlobmanRespawnConns) do
		if not wanted[plr] or not plr.Parent then
			conn:Disconnect()
			BlobmanRespawnConns[plr] = nil
			BlobmanCompletedChars[plr] = nil
			BlobmanLastSeenChars[plr] = nil
		end
	end
end

function StopBlobTargetWatchers()
	for plr, conn in pairs(BlobmanRespawnConns) do
		conn:Disconnect()
		BlobmanRespawnConns[plr] = nil
	end

	table.clear(BlobmanLastSeenChars)
end

function WaitBlobSelfAlive()
	while BlobmanMethodLoop and not SelfAlive() do
		StopBlobCam()
		StopBlobNoclip()
		StopReturnBV()
		ForceBlobCameraBack()
		task.wait(FAST_RESPAWN_WAIT)
	end

	return BlobmanMethodLoop and SelfAlive()
end

function ShouldRunBlobTarget(plr)
	if not plr or plr == player or not plr.Parent then return false end

	local c = plr.Character
	if not c then return false end

	local h = c:FindFirstChildOfClass("Humanoid")
	local r = c:FindFirstChild("HumanoidRootPart")

	if not h or not r or h.Health <= 0 then
		BlobmanCompletedChars[plr] = nil
		return false
	end

	if BlobmanCompletedChars[plr] == c then
		return false
	end

	return true
end

function RunSelectedBlobmanMethod()
	if BlobmanLoopBusy then return end
	BlobmanLoopBusy = true

	task.spawn(function()
		if not WaitBlobSelfAlive() then
			BlobmanLoopBusy = false
			return
		end

		local targets = GetBlobTargetsList()
		RefreshBlobTargetWatchers(targets)

		if #targets <= 0 then
			BlobmanLoopBusy = false
			return
		end

		if BlobmanMethod == "Kick" then
			local needKick = {}

			for _, data in ipairs(targets) do
				local plr = data.Player

				if ShouldRunBlobTarget(plr) then
					table.insert(needKick, data)
				end
			end

			if #needKick > 0 then
				local done = RunLockedBlobKick(needKick)

				if done then
					for _, data in ipairs(needKick) do
						if data.Player and data.Player.Character and AliveBlobPlayer(data.Player) then
							BlobmanCompletedChars[data.Player] = data.Player.Character
							BlobmanLastSeenChars[data.Player] = data.Player.Character
						end
					end
				else
					for _, data in ipairs(needKick) do
						ClearBlobCompleted(data.Player)
					end
				end
			end

			BlobmanLoopBusy = false
			return
		end

		if BlobmanMethod == "Kick V2" then
			local needKick = {}

			for _, data in ipairs(targets) do
				local plr = data.Player

				if ShouldRunBlobTarget(plr) then
					table.insert(needKick, data)
				end
			end

			if #needKick > 0 then
				local done = RunBlobKickV2(needKick)

				if done then
					for _, data in ipairs(needKick) do
						if data.Player and data.Player.Character and not AliveBlobPlayer(data.Player) then
							BlobmanCompletedChars[data.Player] = data.Player.Character
							BlobmanLastSeenChars[data.Player] = data.Player.Character
						end
					end
				else
					for _, data in ipairs(needKick) do
						ClearBlobCompleted(data.Player)
					end
				end
			end

			BlobmanLoopBusy = false
			return
		end

		for _, data in ipairs(targets) do
			if not BlobmanMethodLoop then
				break
			end

			if not WaitBlobSelfAlive() then
				break
			end

			local plr = data.Player
			local hand = data.Hand

			if ShouldRunBlobTarget(plr) then
				local runChar = plr.Character
				local done = RunBlobTargetOnce(plr, hand)

				if done and plr.Character == runChar and AliveBlobPlayer(plr) then
					BlobmanCompletedChars[plr] = runChar
					BlobmanLastSeenChars[plr] = runChar
				else
					ClearBlobCompleted(plr)
				end
			end
		end

		BlobmanLoopBusy = false
	end)
end

function StartBlobmanMethodLoop()
	if BlobmanLoopThread then return end

	BlobmanLoopToken += 1
	local myToken = BlobmanLoopToken

	BlobmanLoopThread = task.spawn(function()
		while BlobmanMethodLoop and BlobmanLoopToken == myToken do
			local targets = GetBlobTargetsList()
			RefreshBlobTargetWatchers(targets)

			if WaitBlobSelfAlive() then
				for _, data in ipairs(targets) do
					if ShouldRunBlobTarget(data.Player) then
						RunSelectedBlobmanMethod()
						break
					end
				end
			end

			task.wait(FAST_RESPAWN_WAIT)
		end

		BlobmanLoopThread = nil
		BlobmanLoopBusy = false

		StopBlobTargetWatchers()
		StopBlobHipHeightLoop()
		StopBlobCam()
		StopBlobNoclip()
		StopReturnBV()
		ForceBlobCameraBack()
	end)
end

function StopBlobmanMethodLoop()
	BlobmanMethodLoop = false
	BlobmanLoopToken += 1

	if BlobmanLoopThread then
		task.cancel(BlobmanLoopThread)
		BlobmanLoopThread = nil
	end

	BlobmanLoopBusy = false
	table.clear(BlobmanCompletedChars)
	StopBlobTargetWatchers()
	StopBlobHipHeightLoop()

	StopBlobCam()
	StopBlobNoclip()
	StopReturnBV()
	ForceBlobCameraBack()
end

BlobmanMethodDropdown = BlobmanTargetSection:AddDropdown("BlobmanMethodDropdown", {
	Text = "Blobman Method",
	Values = {"Bring", "Freeze", "Kill", "Kick", "Kick V2"},
	Default = 1,
	Multi = false,
	Callback = function(v)
		BlobmanMethod = v
		table.clear(BlobmanCompletedChars)
	end
})

BlobmanLoopToggle = BlobmanTargetSection:AddToggle("BlobmanLoopMethodToggle", {
	Text = "Loop Apply Method",
	Default = false,
	Callback = function(v)
		if not v then
			StopBlobmanMethodLoop()
			return
		end

		table.clear(BlobmanCompletedChars)
		BlobmanMethodLoop = true
		StartBlobmanMethodLoop()
	end
})

BlobmanRunOnceButton = BlobmanTargetSection:AddButton({
	Text = "Apply Method Once",
	Func = function()
		if BlobmanLoopBusy then return end

		table.clear(BlobmanCompletedChars)

		local oldLoop = BlobmanMethodLoop
		BlobmanMethodLoop = true

		task.spawn(function()
			RunSelectedBlobmanMethod()

			repeat
				task.wait()
			until not BlobmanLoopBusy

			BlobmanMethodLoop = oldLoop

			if not oldLoop then
				StopBlobHipHeightLoop()
				StopBlobCam()
				StopBlobNoclip()
				StopReturnBV()
				ForceBlobCameraBack()
			end
		end)
	end
})

-------------------------->> [Blobman Settings] <<--------------------------

BlobmanSettingsSection:AddDivider("Blobman")

-------------------------->> [Auto-Seat] <<--------------------------

AutoSeatBlobConn = nil
AutoSeatBlobCharConn = nil
isSitting = false
spawnedBlob = nil

function UpdateCharRefs()
	char = player.Character or player.CharacterAdded:Wait()
	human = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
	head = char:WaitForChild("Head")
end

function FindMyBlob()
	local inv = BackPack(player)
	if not inv then return end

	for _, v in ipairs(inv:GetChildren()) do
		if v.Name == "CreatureBlobman"
			and v:FindFirstChild("VehicleSeat")
			and v:FindFirstChild("HumanoidRootPart") then
			return v
		end
	end
end

function WaitUntilNotHeld()
	repeat
		task.wait()
	until not _G.AutoSeatBlobToggle
		or not (player:FindFirstChild("IsHeld") and player.IsHeld.Value)
end

function IsSeatedInBlob()
	UpdateCharRefs()

	local seat = human and human.SeatPart

	return seat
		and seat.Name == "VehicleSeat"
		and seat.Parent
		and seat.Parent.Name == "CreatureBlobman"
end

function SpawnBlob()
	if not (player:FindFirstChild("CanSpawnToy") and player.CanSpawnToy.Value) then
		return
	end

	UpdateCharRefs()

	task.spawn(function()
		pcall(function()
			SpawnToy:InvokeServer(
				"CreatureBlobman",
				hrp.CFrame * CFrame.new(0, 5, 10),
				Vector3.new(0, 59.667, 0)
			)
		end)
	end)

	local t = tick()

	repeat
		task.wait(0.05)
		spawnedBlob = FindMyBlob()
	until spawnedBlob
		or not _G.AutoSeatBlobToggle
		or tick() - t > 4

	return spawnedBlob
end

function ForceSeat(seat)
	local t = tick()

	repeat
		task.wait()

		if not _G.AutoSeatBlobToggle then break end

		UpdateCharRefs()

		if player:FindFirstChild("IsHeld") and player.IsHeld.Value then
			WaitUntilNotHeld()
		end

		if not IsSeatedInBlob() then
			hrp.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero

			seat:Sit(human)
		end

	until IsSeatedInBlob() or tick() - t > 3
end

AutoSeatBlobToggle = BlobmanSettingsSection:AddToggle("AutoSeatBlobToggle", {
	Text = "Auto-Seat",
	Default = false,
	Save = true,
	Callback = function(v)
		_G.AutoSeatBlobToggle = v

		if AutoSeatBlobConn then
			AutoSeatBlobConn:Disconnect()
			AutoSeatBlobConn = nil
		end

		if AutoSeatBlobCharConn then
			AutoSeatBlobCharConn:Disconnect()
			AutoSeatBlobCharConn = nil
		end

		isSitting = false

		if not v then return end

		UpdateCharRefs()

		AutoSeatBlobCharConn = player.CharacterAdded:Connect(function()
			task.wait(0.25)
			UpdateCharRefs()
			isSitting = false
		end)

		AutoSeatBlobConn = RunService.Heartbeat:Connect(function()
			if not _G.AutoSeatBlobToggle then return end
			if isSitting then return end
			if IsSeatedInBlob() then return end

			isSitting = true

			task.spawn(function()
				UpdateCharRefs()

				WaitUntilNotHeld()

				local blob = FindMyBlob()

				if not blob then
					blob = SpawnBlob()
				end

				if blob and blob.Parent then
					local seat = blob:FindFirstChild("VehicleSeat")

					if seat then
						ForceSeat(seat)
					end
				end

				isSitting = false
			end)
		end)
	end
})

-------------------------->> [anti-grab blob] <<--------------------------

AntiGrabBlobConn = nil

AntiGrabBlobToggle = BlobmanSettingsSection:AddToggle("AntiGrabBlob", {
	Text = "Anti-Grab Blobman",
	Save = true,
	Default = false,
	Callback = function(Value)
		if AntiGrabBlobConn then
			AntiGrabBlobConn:Disconnect()
			AntiGrabBlobConn = nil
		end

		if not Value then
			return
		end

		local tried = {}
		local launched = {}

		AntiGrabBlobConn = RunService.Heartbeat:Connect(function()
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local myHRP = char and char:FindFirstChild("HumanoidRootPart")

			if not hum or not hum.SeatPart or not hum.SeatPart:FindFirstAncestor("CreatureBlobman") or not myHRP then
				table.clear(tried)
				table.clear(launched)
				return
			end

			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local head = plr.Character:FindFirstChild("Head")
					local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
					local key = plr.UserId

					if head and hrp and (hrp.Position - myHRP.Position).Magnitude <= 30 then
						local owner = head:FindFirstChild("PartOwner")

						if owner and owner.Value == player.Name then
							tried[key] = nil

							if not launched[key] then
								launched[key] = true

								local dir = hrp.Position - myHRP.Position

								if dir.Magnitude <= 0 then
									dir = myHRP.CFrame.LookVector
								end

								local bv = Instance.new("BodyVelocity")
								bv.Name = "AntiGrabBlobLaunch"
								bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
								bv.Velocity = dir.Unit * 60 + Vector3.new(0, 85, 0)
								bv.Parent = hrp

								Debris:AddItem(bv, 0.2)
							end
						elseif not tried[key] then
							tried[key] = true

							CreateLine:FireServer(head, false)
							task.wait(0.05)
							ExtendLine:FireServer(head)
							task.wait(0.05)
							SetOwner:FireServer(head, head.CFrame)
						end
					else
						tried[key] = nil
						launched[key] = nil
					end
				end
			end
		end)
	end
})

-------------------------->> [Fat Blobman] <<--------------------------

HeavyBlobEnabled = false
HeavyBlobConn = nil
HeavyBlobWeight = nil
HeavyBlobOldProps = nil

function GetMyHumanoid()
	char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChildOfClass("Humanoid")
end

function GetSatBlobman()
	local hum = GetMyHumanoid()
	local seat = hum and hum.SeatPart
	local blob = seat and seat.Parent

	if blob and blob.Name == "CreatureBlobman" then
		return blob
	end
end

function GetSatBlobHumanoid()
	local blob = GetSatBlobman()
	return blob and blob:FindFirstChildOfClass("Humanoid")
end

function GetBlobWeight()
	local blob = GetSatBlobman()
	if not blob then return end

	local weight = blob:FindFirstChild("Weight", true)

	if weight and weight:IsA("BasePart") then
		return weight
	end
end

HeavyBlobToggle = BlobmanSettingsSection:AddToggle("HeavyBlobToggle", {
	Text = "Heavy Blobman",
	Default = false,
	Save = true,
	Callback = function(v)
		HeavyBlobEnabled = v

		if HeavyBlobConn then
			HeavyBlobConn:Disconnect()
			HeavyBlobConn = nil
		end

		if not v then
			if HeavyBlobWeight and HeavyBlobWeight.Parent then
				HeavyBlobWeight.CustomPhysicalProperties = HeavyBlobOldProps
			end

			HeavyBlobWeight = nil
			HeavyBlobOldProps = nil
			return
		end

		HeavyBlobConn = RunService.Heartbeat:Connect(function()
			local weight = GetBlobWeight()
			if not weight then return end

			if HeavyBlobWeight ~= weight then
				if HeavyBlobWeight and HeavyBlobWeight.Parent then
					HeavyBlobWeight.CustomPhysicalProperties = HeavyBlobOldProps
				end

				HeavyBlobWeight = weight
				HeavyBlobOldProps = weight.CustomPhysicalProperties
			end

			weight.CustomPhysicalProperties = PhysicalProperties.new(
				math.huge,
				math.huge,
				0,
				math.huge,
				0
			)
		end)
	end
})

-------------------------->> [V Fly] <<--------------------------

Vfly = false
VflySpeed = 3

VflyKeyDown = nil
VflyKeyUp = nil
VflyGyro = nil
VflyVelocity = nil

function GetVflyRoot()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChild("HumanoidRootPart")
end

function StartVfly()
	StopVfly()

	local root = GetVflyRoot()
	if not root then return end

	local control = {
		F = 0,
		B = 0,
		L = 0,
		R = 0,
		Q = 0,
		E = 0
	}

	Vfly = true

	VflyGyro = Instance.new("BodyGyro")
	VflyGyro.P = 9e4
	VflyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	VflyGyro.CFrame = root.CFrame
	VflyGyro.Parent = root

	VflyVelocity = Instance.new("BodyVelocity")
	VflyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	VflyVelocity.Velocity = Vector3.zero
	VflyVelocity.Parent = root

	VflyKeyDown = mouse.KeyDown:Connect(function(key)
		key = key:lower()

		if key == "w" then
			control.F = VflySpeed
		elseif key == "s" then
			control.B = -VflySpeed
		elseif key == "a" then
			control.L = -VflySpeed
		elseif key == "d" then
			control.R = VflySpeed
		elseif key == "e" then
			control.Q = VflySpeed * 2
		elseif key == "q" then
			control.E = -VflySpeed * 2
		end

		pcall(function()
			workspace.CurrentCamera.CameraType = Enum.CameraType.Track
		end)
	end)

	VflyKeyUp = mouse.KeyUp:Connect(function(key)
		key = key:lower()

		if key == "w" then
			control.F = 0
		elseif key == "s" then
			control.B = 0
		elseif key == "a" then
			control.L = 0
		elseif key == "d" then
			control.R = 0
		elseif key == "e" then
			control.Q = 0
		elseif key == "q" then
			control.E = 0
		end
	end)

	task.spawn(function()
		while Vfly do
			task.wait()

			local cam = workspace.CurrentCamera
			local char = player.Character

			if not cam or not char or not root or not root.Parent then
				break
			end

			if VflyVelocity and VflyGyro then
				local moving = control.F + control.B ~= 0
					or control.L + control.R ~= 0
					or control.Q + control.E ~= 0

				if moving then
					VflyVelocity.Velocity = (
						(cam.CFrame.LookVector * (control.F + control.B)) +
							((cam.CFrame * CFrame.new(
								control.L + control.R,
								(control.F + control.B + control.Q + control.E) * 0.2,
								0
								)).Position - cam.CFrame.Position)
					) * 50
				else
					VflyVelocity.Velocity = Vector3.zero
				end

				VflyGyro.CFrame = cam.CFrame
			end
		end

		StopVfly()
	end)
end

function StopVfly()
	Vfly = false

	if VflyKeyDown then
		VflyKeyDown:Disconnect()
		VflyKeyDown = nil
	end

	if VflyKeyUp then
		VflyKeyUp:Disconnect()
		VflyKeyUp = nil
	end

	if VflyGyro then
		VflyGyro:Destroy()
		VflyGyro = nil
	end

	if VflyVelocity then
		VflyVelocity:Destroy()
		VflyVelocity = nil
	end

	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end

VflyToggle = BlobmanSettingsSection:AddToggle("Vfly", {
	Text = "Vfly",
	Default = false,
	Save = true,
	Callback = function(Value)
		if Value then
			StartVfly()
		else
			StopVfly()
		end
	end
})

-------------------------->> [Blobman Movement Settings] <<--------------------------

BlobmanSettingsSection:AddDivider("Movement")

-------------------------->> [Blobman WalkSpeed] <<--------------------------

BWalkSpeed = 20
BWalkSpeedConn = BWalkSpeedConn or nil

function UpdateBlobWalkSpeed()
	local hum = GetSatBlobHumanoid()

	if hum then
		hum.WalkSpeed = BWalkSpeed
	end
end

function StartBlobWalkSpeedLoop()
	if BWalkSpeedConn then
		BWalkSpeedConn:Disconnect()
		BWalkSpeedConn = nil
	end

	if BWalkSpeed == 20 then
		UpdateBlobWalkSpeed()
		return
	end

	BWalkSpeedConn = RunService.Heartbeat:Connect(function()
		UpdateBlobWalkSpeed()
	end)
end

BWalkSpeedSlider = BlobmanSettingsSection:AddSlider("BWalkSpeed", {
	Text = "WalkSpeed",
	Default = BWalkSpeed,
	Min = 0,
	Max = 250,
	Rounding = 0,
	Compact = false,
	Callback = function(v)
		BWalkSpeed = v
		StartBlobWalkSpeedLoop()
	end
})

BlobmanResetWalkSpeedButton = BlobmanSettingsSection:AddButton({
	Text = "Reset WalkSpeed",
	Func = function()
		BWalkSpeed = 20

		if BWalkSpeedSlider and BWalkSpeedSlider.SetValue then
			BWalkSpeedSlider:SetValue(20)
		end

		StartBlobWalkSpeedLoop()
	end
})

-------------------------->> [Visual] <<--------------------------

PlayerVisualSection = Tab.Visual:AddLeftGroupbox("Player ESP")

ObjectVisualSection = Tab.Visual:AddLeftGroupbox("Object ESP")

-------------------------->> [Player ESP] <<--------------------------

local PlayerColorESP = Color3.fromRGB(235, 235, 235)
local PlayerColorTransESP = 0.7
local PlayerOutlineColorTransESP = 0

local PlayerESPEnabled = false
local PlayerESPConnections = {}

local function UpdateHighlight()
	if PlayerESPEnabled then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then continue end
			local char = plr.Character

			if char:FindFirstChild("PlayerESP") then
				local esp = char:FindFirstChild("PlayerESP")
				if esp then
					highlight.FillColor = PlayerColorESP
					highlight.FillTransparency = PlayerColorTransESP
					highlight.OutlineTransparency = PlayerOutlineColorTransESP
				end
			end
		end
	end
end

local function AddHighlight(plr)
	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local old = char:FindFirstChild("PlayerESP")
	if old then
		old:Destroy()
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerESP"
	highlight.FillColor = PlayerColorESP
	highlight.FillTransparency = PlayerColorTransESP
	highlight.OutlineTransparency = PlayerOutlineColorTransESP
	highlight.Parent = char
end

local function RemoveHighlight(plr)
	local char = plr.Character
	if not char then return end

	local highlight = char:FindFirstChild("PlayerESP")
	if highlight then
		highlight:Destroy()
	end
end

local function HighlightAllPlayers()
	for _, plr in ipairs(Players:GetPlayers()) do
		AddHighlight(plr)
	end
end

local function DestroyAllPlayerHighlights()
	for _, plr in ipairs(Players:GetPlayers()) do
		RemoveHighlight(plr)
	end
end

local function SetupPlayer(plr)
	if plr == player then return end
	if PlayerESPConnections[plr] then return end

	PlayerESPConnections[plr] = plr.CharacterAdded:Connect(function()
		task.wait(0.2)

		if PlayerESPEnabled then
			AddHighlight(plr)
		end
	end)
end

for _, plr in ipairs(Players:GetPlayers()) do
	SetupPlayer(plr)
end

Players.PlayerAdded:Connect(function(plr)
	SetupPlayer(plr)

	if PlayerESPEnabled then
		task.wait(0.2)
		AddHighlight(plr)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	RemoveHighlight(plr)

	if PlayerESPConnections[plr] then
		PlayerESPConnections[plr]:Disconnect()
		PlayerESPConnections[plr] = nil
	end
end)

PlayerESPToggle = PlayerVisualSection:AddToggle("PlayerESP", {
	Text = "Highlight",
	Save = true,
	Default = false,
	Callback = function(Value)
		PlayerESPEnabled = Value

		if PlayerESPEnabled then
			HighlightAllPlayers()
		else
			DestroyAllPlayerHighlights()
		end
	end
})

PlayerESPToggle:AddColorPicker("PlayerHighlightDecider", {
	Default = Color3.fromRGB(235, 235, 235),
	Save = true,
	Title = "Color",
	Callback = function(Value)
		PlayerColorESP = Value
		UpdateHighlight()
	end
})

-------------------------->> [Object ESP] <<--------------------------

local ObjectColorESP = Color3.fromRGB(235, 235, 235)
local ObjectColorTransESP = 0.7
local ObjectOutlineColorTransESP = 0

local ObjectESPEnabled = false
local ObjectESPConnections = {}

local function AddObjectHighlight(toy)
	if not toy then return end
	if toy:FindFirstChild("ObjectESP") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ObjectESP"
	highlight.Parent = toy
	highlight.FillColor = ObjectColorESP
	highlight.FillTransparency = ObjectColorTransESP
	highlight.OutlineTransparency = ObjectOutlineColorTransESP
end

local function HighlightObject()
	local toycontainers = GetToyAllContainers()

	for _, container in ipairs(toycontainers) do
		for _, toy in ipairs(container:GetChildren()) do
			AddObjectHighlight(toy)
		end
	end
end

local function DestroyHighlightObject()
	local toycontainers = GetToyAllContainers()

	for _, container in ipairs(toycontainers) do
		for _, toy in ipairs(container:GetChildren()) do
			local highlight = toy:FindFirstChild("ObjectESP")
			if highlight then
				highlight:Destroy()
			end
		end
	end
end

local function DisconnectObjectESP()
	for _, conn in ipairs(ObjectESPConnections) do
		if conn then
			conn:Disconnect()
		end
	end

	table.clear(ObjectESPConnections)
end

local function ConnectObjectContainers()
	DisconnectObjectESP()

	for _, container in ipairs(GetToyAllContainers()) do
		table.insert(ObjectESPConnections, container.ChildAdded:Connect(function(toy)
			if not ObjectESPEnabled then return end

			task.wait()

			AddObjectHighlight(toy)
		end))
	end
end

ObjectESPToggle = ObjectVisualSection:AddToggle("ObjectESP", {
	Text = "Highlight",
	Save = true,
	Default = false,
	Callback = function(Value)
		ObjectESPEnabled = Value

		DisconnectObjectESP()

		if ObjectESPEnabled then
			HighlightObject()
			ConnectObjectContainers()
		else
			DestroyHighlightObject()
		end
	end
})

-------------------------->> [Notifications] <<--------------------------

NotificationSection = Tab.Misc:AddLeftGroupbox("Notifications")

Flags = {}
KickedPlayers = {}
KickNotifyConn = nil
PlayerJoinConn = nil
PlayerLeaveConn = nil

Flags.PlayerNotifcations = true
Flags.TargetNotifcations = true
Flags.BlobmanTargetEvents = true
Flags.FriendNotifcations = true
Flags.KickNotifcations = true

function Notify(txt, time)
	YXZ:Notify(tostring(txt), time or 5)
end

function Display(plr)
	if not plr then return "Unknown" end
	if plr.DisplayName and plr.DisplayName ~= plr.Name then
		return plr.DisplayName .. " (@" .. plr.Name .. ")"
	end
	return plr.DisplayName or plr.Name
end

function SamePlayerValue(plr, value)
	if not plr or not value then return false end
	value = tostring(value)

	return value == tostring(plr.Name)
		or value == tostring(plr.DisplayName)
		or value == tostring(plr.UserId)
end

function TableHasPlayerValue(tbl, plr)
	if not tbl or not plr then return false end

	for k, v in pairs(tbl) do
		if v == true and SamePlayerValue(plr, k) then
			return true
		end

		if SamePlayerValue(plr, v) then
			return true
		end
	end

	return false
end

function IsFriend(plr)
	if not plr or plr == player then return false end

	local ok, result = pcall(function()
		return player:IsFriendsWith(plr.UserId)
	end)

	return ok and result == true
end

function IsTarget(plr)
	if not plr or plr == player then return false end

	return TableHasPlayerValue(TargetPlayers, plr)
end

function IsBlobTarget(plr)
	if not plr or plr == player then return false end

	return SamePlayerValue(plr, BlobmanTargetLeft)
		or SamePlayerValue(plr, BlobmanTargetRight)
end

function IsNormalPlayer(plr)
	return plr and plr ~= player and not IsTarget(plr) and not IsBlobTarget(plr) and not IsFriend(plr)
end

function NotifyJoin(plr)
	if not plr or plr == player then return end

	if Flags.TargetNotifcations and IsTarget(plr) then
		Notify("Target joined: <font color='#c21f1f'>" .. Display(plr) .. "</font>", 5)
		NormalNotif()
	elseif Flags.BlobmanTargetEvents and IsBlobTarget(plr) then
		Notify("Blobman Target joined: <font color='#c21f1f'>" .. Display(plr) .. "</font>", 5)
		NormalNotif()
	elseif Flags.FriendNotifcations and IsFriend(plr) then
		Notify("Friend joined: <font color='#0f99cf'>" .. Display(plr) .. "</font>", 5)
		ChatNotif("Just letting you know your friend Joined: <font color='#0f99cf'>" .. Display(plr) .. "</font>")
	elseif Flags.PlayerNotifcations and IsNormalPlayer(plr) then
		Notify("Player joined: " .. Display(plr), 5)
	end
end

function NotifyLeave(plr)
	if not plr or plr == player then return end
	if KickedPlayers[plr.UserId] then return end

	if Flags.TargetNotifcations and IsTarget(plr) then
		Notify("Target left: <font color='#c21f1f'>" .. Display(plr) .. "</font>", 5)
		NormalNotif()
	elseif Flags.BlobmanTargetEvents and IsBlobTarget(plr) then
		Notify("Blobman Target left: <font color='#c21f1f'>" .. Display(plr) .. "</font>", 5)
		NormalNotif()
	elseif Flags.FriendNotifcations and IsFriend(plr) then
		Notify("Friend Left: <font color='#0f99cf'>" .. Display(plr) .. "</font>", 5)
		ChatNotif("Just letting you know your friend left: <font color='#0f99cf'>" .. Display(plr) .. "</font>")
	elseif Flags.PlayerNotifcations and IsNormalPlayer(plr) then
		Notify("Player left: " .. Display(plr), 5)
	end
end

function IsKickLeaving()
	return game.Workspace:FindFirstChild("BlackHoleKick") ~= nil
end

function NotifyKick(plr)
	if not plr or plr == player then return end

	KickedPlayers[plr.UserId] = true

	if Flags.KickNotifcations then
		Notify("Player kicked: " .. Display(plr), 5)
	end

	local kickPart = game.Workspace:FindFirstChild("BlackHoleKick")
	if kickPart then
		pcall(function()
			kickPart.Name = Display(plr) .. " KICK"
		end)
	end

	task.delay(3, function()
		KickedPlayers[plr.UserId] = nil
	end)
end

NotificationSection:AddToggle("PlayerNotifications", {
	Text = "Player Notifications",
	Default = true,
	Save = true,
	Callback = function(state)
		Flags.PlayerNotifcations = state
	end
})

NotificationSection:AddToggle("TargetNotifications", {
	Text = "Target Notifications",
	Default = true,
	Save = true,
	Callback = function(state)
		Flags.TargetNotifcations = state
	end
})

NotificationSection:AddToggle("BlobTargetNotifications", {
	Text = "Blobman Target Notifications",
	Default = true,
	Save = true,
	Callback = function(state)
		Flags.BlobmanTargetEvents = state
	end
})

NotificationSection:AddToggle("FriendNotifications", {
	Text = "Friend Notifications",
	Default = true,
	Save = true,
	Callback = function(state)
		Flags.FriendNotifcations = state
	end
})

NotificationSection:AddToggle("KickNotifications", {
	Text = "Kick Notifications",
	Default = true,
	Save = true,
	Callback = function(state)
		Flags.KickNotifcations = state
	end
})

if PlayerJoinConn then PlayerJoinConn:Disconnect() end
if PlayerLeaveConn then PlayerLeaveConn:Disconnect() end
if KickNotifyConn then KickNotifyConn:Disconnect() end

PlayerJoinConn = Players.PlayerAdded:Connect(function(plr)
	task.wait(0.2)
	NotifyJoin(plr)
end)

PlayerLeaveConn = Players.PlayerRemoving:Connect(function(plr)
	if IsKickLeaving() then
		NotifyKick(plr)
	else
		NotifyLeave(plr)
	end
end)

NotificationSection:AddToggle("LagNotifications", {
	Text = "Line Lag Notification",
	Default = true,
	Save = true,
	Callback = function(state)
		Flags.LagNotifcations = state
	end
})

_G.SentPacketsNotif = true
activepackets = false

NotificationSection:AddToggle("DetectPackets", {
	Text = "Detect Packets",
	Default = true,
	Save = true,
	Callback = function(state)
		_G.SentPacketsNotif = state
	end
})

if DetectPacketConn then
	DetectPacketConn:Disconnect()
end

DetectPacketConn = ExtendLine.OnClientEvent:Connect(function(plr, args)
	if not _G.SentPacketsNotif then return end
	if activepackets then return end
	if not plr or not plr.Name then return end

	if typeof(args) == "string" and #args > 300 then
		activepackets = true

		local mb = math.round((#args / 1048576) * 1000) / 1000
		Notify("<font color='#c21f1f'>" .. Display(plr) .. "</font>" .. " Sent Packet Size: " .. tostring(mb) .. " MB", 4)
		NormalNotif()

		task.delay(4, function()
			activepackets = false
		end)
	end
end)

-------------------------->> [GamePass] <<--------------------------

GamePassSection = Tab.Misc:AddLeftGroupbox("Game Passes")

-------------------------->> [Further Reach] <<--------------------------

local Notifier = ReplicatedStorage:WaitForChild("GamepassEvents"):FindFirstChild("FurtherReachBoughtNotifier")
if Notifier and getconnections then
	for _, connection in ipairs(getconnections(Notifier.OnClientEvent)) do
		pcall(connection.Function)
	end
end

FurtherReachToggle = GamePassSection:AddToggle("FurtherReach", {
	Text = "Further Reach",
	Save = true,
	Default = false,
	Callback = function(Value)
		local Reach = player:FindFirstChild("FartherReach")

		if Value then
			Reach = Instance.new("BoolValue")
			Reach.Name = "FartherReach"
			Reach.Parent = player
			Reach.Value = true
		end
	end
})


-------------------------->> [Line Lag] <<--------------------------

LagSection = Tab.Misc:AddRightGroupbox("Lag")

LineLagAmount = 1000
LineLagToggle = false
LineLagThread = nil

LineAmountSlider = LagSection:AddSlider("LineLagAmountSlider", {
	Text = "Line Amount",
	Default = 1000,
	Min = 0,
	Max = 1000,
	Rounding = 0,
	Compact = false,
	Callback = function(Value)
		LineLagAmount = Value
	end
})

LineLagToggle = LagSection:AddToggle("LineLagToggle", {
	Text = "Line Lag",
	Default = false,
	Callback = function(Value)
		LineLagToggle = Value

		if LineLagThread then
			task.cancel(LineLagThread)
			LineLagThread = nil
		end

		if not Value then
			return
		end

		LineLagThread = task.spawn(function()
			local RATE = 120

			while LineLagToggle do
				local amount = math.floor((LineLagAmount or 0) / RATE)

				for i = 1, amount do
					CreateLine:FireServer(
						workspace.SpawnLocation,
						CFrame.new(0, 9e9, 0)
					)
				end

				task.wait(1 / RATE)
			end
		end)
	end
})

LagSection:AddDivider("Packet Lag")

_G.Packets = 3000
_G.PacketsEnabled = false
_G.AntiDetect = false
PacketLagThread = nil

PacketAmountSlider = LagSection:AddSlider("PacketAmount", {
	Text = "Packet Amount",
	Default = 3000,
	Min = 3000,
	Max = 70000,
	Rounding = 0,
	Compact = false,
})

PacketAmountSlider:OnChanged(function(Value)
	_G.Packets = Value
end)

AntiPacketLagToggle = LagSection:AddToggle("AntiPacketLagToggle", {
	Text = "Anti-Packets",
	Default = false,
})

AntiPacketLagToggle:OnChanged(function(Value)
	_G.AntiDetect = Value
end)

PacketLagToggle = LagSection:AddToggle("PacketLagToggle", {
	Text = "Packets",
	Default = false,
})

PacketLagToggle:OnChanged(function(Value)
	_G.PacketsEnabled = Value

	if PacketLagThread then
		task.cancel(PacketLagThread)
		PacketLagThread = nil
	end

	if not Value then
		return
	end

	PacketLagThread = task.spawn(function()
		while _G.PacketsEnabled do
			task.wait(0.7)

			if not _G.PacketsEnabled then
				break
			end

			pcall(function()
				local packetString = string.rep(
					"MonkeyBoyMonkeyBoyMonkeyBoyMonkeyBoyMonkeyBoyMonkeyBoyMonkeyBoyMonkeyBoy",
					_G.Packets
				)

				if _G.AntiDetect then
					CreateLine:FireServer(packetString)
				else
					ExtendLine:FireServer(packetString)
				end
			end)
		end
	end)
end)

-------------------------->> [Plots] <<--------------------------

PlotsSection = Tab.Misc:AddLeftGroupbox("Plots")

local function BarrierCollisions(Value)
	local PlotsFolder = workspace:WaitForChild("Plots")
	for _, barrier in pairs(PlotsFolder:GetDescendants()) do
		if barrier.Name == "PlotBarrier" then
			barrier.CanCollide = not Value
		end
	end
end

local function FixBarrier(Value)
	local PlotsFolder = workspace:WaitForChild("Plots")
	for _, barrier in pairs(PlotsFolder:GetDescendants()) do
		if barrier.Name == "PlotBarrier" then
			barrier.CanCollide = not Value
		end
	end
end

BarrierCollisionsToggle = PlotsSection:AddToggle("BarrierCollisions", {
	Text = "Barrier Collisions",
	Save = true,
	Default = false,
	Callback = function(Value)
		if Value then
			BarrierCollisions(Value)
		else
			FixBarrier(Value)
		end
	end
})

-------------------------->> [Auto Own Plot] <<--------------------------

PlotCFrames = {
	Purple = CFrame.new(252.431046, -6.72545671, 465.879211),
	Blue = CFrame.new(514.201965, 83.336792, -341.993774),
	Green = CFrame.new(-535.19574, -7.35040379, 93.0739517),
	Yellow = CFrame.new(558.83136, 123.338593, -73.7156754),
	Pink = CFrame.new(-492.85553, -7.35040331, -167.380844),
}

PerferedPlotNames = {"None", "Purple", "Blue", "Green", "Yellow", "Pink"}
PerferedPlotNameValue = "Purple"

AutoOwnPlotToggle = false
AutoOwnPlotBusy = false

local function GetPlotOwners(plot)
	return plot:FindFirstChild("PlotSign")
		and plot.PlotSign:FindFirstChild("ThisPlotsOwners")
end

local function IsPlotOwnedByMe(plot)
	local owners = GetPlotOwners(plot)
	if not owners then return false end

	for _, owner in ipairs(owners:GetDescendants()) do
		if owner:IsA("ObjectValue") and owner.Value == player then
			return true
		elseif owner:IsA("StringValue") and owner.Value == player.Name then
			return true
		end
	end

	return false
end

local function IsPlotOwned(plot)
	local owners = GetPlotOwners(plot)
	if not owners then return false end

	for _, owner in ipairs(owners:GetDescendants()) do
		if owner:IsA("ObjectValue") and owner.Value ~= nil then
			return true
		elseif owner:IsA("StringValue") and owner.Value ~= "" then
			return true
		end
	end

	return false
end

local function GetPlusGrabPart(plot)
	local plotSign = plot:FindFirstChild("PlotSign")
	if not plotSign then return nil end

	for _, sign in ipairs(plotSign:GetDescendants()) do
		if sign.Name == "Sign" then
			local plus = sign:FindFirstChild("Plus")
			local plusGrabPart = plus and plus:FindFirstChild("PlusGrabPart")

			if plusGrabPart then
				return plusGrabPart
			end
		end
	end

	return nil
end

function GetUnownedPlots()
	local plots = workspace:FindFirstChild("Plots")
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not plots or not hrp then
		return nil
	end

	local chosenPlot = nil
	local chosenDist = math.huge
	local wantedCF = PlotCFrames[PerferedPlotNameValue]
	local comparePos = wantedCF and wantedCF.Position or hrp.Position

	for _, plot in ipairs(plots:GetChildren()) do
		if IsPlotOwnedByMe(plot) then
			return plot
		end

		if not IsPlotOwned(plot) then
			local plusGrabPart = GetPlusGrabPart(plot)

			if plusGrabPart then
				local dist = (plot:GetPivot().Position - comparePos).Magnitude

				if dist < chosenDist then
					chosenDist = dist
					chosenPlot = plot
				end
			end
		end
	end

	return chosenPlot
end

PerferedPlotNameDropdown = PlotsSection:AddDropdown("PerferedPlotName", {
	Text = "Perfered Plot",
	Save = true,
	Values = PerferedPlotNames,
	Default = PerferedPlotNameValue,
	Multi = false,
	Callback = function(Value)
		PerferedPlotNameValue = Value
	end
})

AutoOwnPlotToggle = PlotsSection:AddToggle("AutoOwnPlot", {
	Text = "Auto Own",
	Save = true,
	Default = false,
	Callback = function(Value)
		AutoOwnPlotToggle = Value

		if not Value then
			AutoOwnPlotBusy = false
			return
		end

		if AutoOwnPlotBusy then return end
		AutoOwnPlotBusy = true

		task.spawn(function()
			while AutoOwnPlotToggle do
				local plot = GetUnownedPlots()

				if not plot then
					task.wait(0.5)
					continue
				end

				if IsPlotOwnedByMe(plot) then
					break
				end

				if IsPlotOwned(plot) then
					task.wait(0.5)
					continue
				end

				local plusGrabPart = GetPlusGrabPart(plot)

				if not plusGrabPart then
					task.wait(0.2)
					continue
				end

				local char = player.Character or player.CharacterAdded:Wait()
				local hrp = char:WaitForChild("HumanoidRootPart")

				hrp.CFrame = plusGrabPart.CFrame + Vector3.new(0, 3, 0)
				task.wait(0.2)

				while AutoOwnPlotToggle and plot.Parent and not IsPlotOwned(plot) do
					SetOwner:FireServer(plusGrabPart, plusGrabPart.CFrame)
					task.wait(0.02)
				end

				if IsPlotOwnedByMe(plot) then
					break
				end

				task.wait(0.1)
			end

			AutoOwnPlotToggle = false
			AutoOwnPlotBusy = false
		end)
	end
})

-------------------------->> [Auto Spin] <<--------------------------

SlotsSection = Tab.Misc:AddLeftGroupbox("Slots")

AutoSpinToggle = false
AutoSpinBusy = false

AutoSpinToggle = SlotsSection:AddToggle("AutoSpin", {
	Text = "Auto Spin",
	Save = true,
	Default = false,
	Callback = function(Value)
		AutoSpinToggle = Value

		if not Value or AutoSpinBusy then
			return
		end

		AutoSpinBusy = true

		task.spawn(function()
			while AutoSpinToggle do
				local char = player.Character or player.CharacterAdded:Wait()
				local hrp = char:WaitForChild("HumanoidRootPart")

				local readySlots = {}

				for _, slot in ipairs(workspace.Slots:GetChildren()) do
					local words = slot:FindFirstChild("Screen")
						and slot.Screen:FindFirstChild("SlotGui")
						and slot.Screen.SlotGui:FindFirstChild("TimeLeftFrame")
						and slot.Screen.SlotGui.TimeLeftFrame:FindFirstChild("SpinReadyWords")

					local handle = slot:FindFirstChild("SlotHandle")
						and slot.SlotHandle:FindFirstChild("Handle")

					if words and words.Visible and handle then
						table.insert(readySlots, {
							Slot = slot,
							Handle = handle,
							Dist = (handle.Position - hrp.Position).Magnitude,
						})
					end
				end

				table.sort(readySlots, function(a, b)
					return a.Dist < b.Dist
				end)

				for _, info in ipairs(readySlots) do
					if not AutoSpinToggle then
						break
					end

					local handle = info.Handle
					local oldCF = hrp.CFrame
					local teleported = false
					local owned = false

					if info.Dist > 20 then
						hrp.CFrame = handle.CFrame + Vector3.new(0, 3, 0)
						teleported = true
						task.wait(0.2)
					end

					for attempt = 1, 2 do
						for i = 1, 8 do
							if not AutoSpinToggle or not handle.Parent then
								break
							end

							SetOwner:FireServer(handle, handle.CFrame)
							task.wait(0.02)
						end

						local partOwner = handle:FindFirstChild("PartOwner")

						if partOwner and partOwner.Value == player.Name then
							owned = true
							break
						end
					end

					if teleported and hrp.Parent then
						hrp.CFrame = oldCF
					end

					if owned then
						break
					end

					task.wait(0.05)
				end

				task.wait(0.1)
			end

			AutoSpinBusy = false
		end)
	end
})

-------------------------->> [Z TP] <<--------------------------

MiscKeybinds = Tab.Keybind:AddLeftGroupbox("Misc")

TeleportToggle = false
ztp = false

TeleportKey = Enum.KeyCode.Z

function GetTeleportPos()
	local camera = workspace.CurrentCamera
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not camera or not hrp then return nil end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char}
	rayParams.IgnoreWater = true

	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local result = workspace:Raycast(ray.Origin, ray.Direction * 5000, rayParams)

	if result then
		return result.Position + Vector3.new(0, 3, 0)
	end

	return ray.Origin + ray.Direction * 80
end

function TeleportToAim()
	if not TeleportToggle or ztp then return end
	ztp = true

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local human = char:FindFirstChildOfClass("Humanoid")

	if not hrp or not human or human.Health <= 0 then
		ztp = false
		return
	end

	local pos = GetTeleportPos()

	if not pos then
		ztp = false
		return
	end

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(pos)

	task.wait()

	if hrp and hrp.Parent then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end

	ztp = false
end

if TeleportInputConn then
	TeleportInputConn:Disconnect()
	TeleportInputConn = nil
end

TeleportInputConn = UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if not TeleportToggle then return end

	if input.KeyCode == TeleportKey then
		TeleportToAim()
	end
end)

tpKeybindToggle = MiscKeybinds:AddToggle("tpKeybindToggle", {
	Text = "Teleport",
	Default = true,
	Save = true,
	Callback = function(Value)
		TeleportToggle = Value
	end
})
