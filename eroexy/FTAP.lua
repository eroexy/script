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
      Enabled = false,
      FolderName = true,
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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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

    -- Create table for this model if it doesn't exist
    if not modelCollides[model] then
        modelCollides[model] = {}
    end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if not value then
                -- Save original state only once
                if modelCollides[model][part] == nil then
                    modelCollides[model][part] = part.CanCollide
                end
                part.CanCollide = false
            else
                -- Restore original state
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

-- === TOGGLE ===
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
-- BRING PLAYERS SYSTEM
local Section = Tab:CreateSection("Bring")
--//////////////////////////////////////////////////////////////////////////////
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local DestroyGrabLine = GrabEvents:FindFirstChild("DestroyGrabLine")

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

local function bringOne(targetPlayer, originalCF)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    local char = targetPlayer.Character
    if not char then return end

    local tRoot = findRoot(char)
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChild("Humanoid")
    if not tRoot or not head or not hum or hum.Health <= 0 then return end

    local near = tRoot.CFrame * CFrame.new(0, -3, -2)
    local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local myRoot = findRoot(myChar)
    if myRoot then pcall(function() myRoot.CFrame = near end) end

    tryClaimOwner(tRoot, 14, 0.02)

    if DestroyGrabLine then pcall(function() DestroyGrabLine:FireServer(tRoot) end) end
    pcall(function()
        tRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
        tRoot.CFrame = originalCF
    end)
end

-- Dropdown UI
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

-- Bring Selected
Tab:CreateButton({
    Name = "Bring Selected",
    Callback = function()
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local myRoot = findRoot(myChar)
        if not myRoot then return end
        local originalCF = myRoot.CFrame

        for _, plr in ipairs(selectedPlayers) do
            pcall(function() bringOne(plr, originalCF) end)
        end

        -- Return to original
        pcall(function()
            local myChar2 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local myRoot2 = findRoot(myChar2)
            if myRoot2 then myRoot2.CFrame = originalCF end
        end)
    end,
})

-- Bring All
Tab:CreateButton({
    Name = "Bring All",
    Callback = function()
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local myRoot = findRoot(myChar)
        if not myRoot then return end
        local originalCF = myRoot.CFrame

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                pcall(function() bringOne(plr, originalCF) end)
            end
        end

        pcall(function()
            local myChar2 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local myRoot2 = findRoot(myChar2)
            if myRoot2 then myRoot2.CFrame = originalCF end
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
