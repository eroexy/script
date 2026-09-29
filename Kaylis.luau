-------------------------->> [Check Running Script] <<--------------------------
lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
tm = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
tm:SetLibrary(lib)
tm:SetFolder("Kaylis/FlingThingsAndPeople")
tm:SetDefaultTheme({
    FontColor = Color3.fromRGB(255, 255, 255),
	AccentColor = Color3.fromRGB(255, 220, 50),
	FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json"),
	BackgroundImage = ""
})
win = lib:CreateWindow({
    Title = "Kaylis",
    Footer = "~~ I LOVE KAY ~~",
    AutoShow = true,
    Font = Enum.Font.Ubuntu,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Icon = 82795327169782,
    NotifySide = "Right",
    GlobalSearch = true,
    Size = UDim2.fromOffset(725, 650),
    CornerRadius = 16,
})
win:SetSidebarWidth(40)
win:SetBackgroundImage("")
lib.ForceCheckbox = true

-------------------------->> [Services] <<--------------------------
local gs = {
    Players = game.Players,
    TWS = game.TweenService,
    Rep = game.ReplicatedStorage,
    Rs = game.RunService,
    Uis = game.UserInputService,
    l = game.Lighting,
    Tps = game:GetService("TeleportService"),
    Deb = game.Debris,
    Tcs = game:GetService("TextChatService"),
}
-------------------------->> [Event] <<--------------------------
local Event = {
    sno = gs.Rep.GrabEvents.SetNetworkOwner,
    cgl = gs.Rep.GrabEvents.CreateGrabLine,
    egl = gs.Rep.GrabEvents.ExtendGrabLine,
    dgl = gs.Rep.GrabEvents.DestroyGrabLine,
    ege = gs.Rep.GrabEvents.EndGrabEarly,

    SpawnToy = gs.Rep.MenuToys.SpawnToyRemoteFunction,
    DestroyToy = gs.Rep.MenuToys.DestroyToy,

    Struggle = gs.Rep.CharacterEvents.Struggle,
    Ragdoll = gs.Rep.CharacterEvents.RagdollRemote,
    Stick = gs.Rep.PlayerEvents.StickyPartEvent,
}
-------------------------->> [Vars] <<--------------------------
local v1 = {
    player = gs.Players.LocalPlayer,
    camera = workspace.Camera,
    inv = workspace:FindFirstChild(gs.Players.LocalPlayer.Name .. "SpawnedInToys"),
    CanSpawn = gs.Players.LocalPlayer.CanSpawnToy,
    PlotPlayers = workspace.PlotItems.PlayersInPlots,
    KeyPoints = gs.Players.LocalPlayer.BeamColor.ColorSequenceHolder.Color.Keypoints,
    Held = gs.Players.LocalPlayer.IsHeld,
    HeldTimer = gs.Players.LocalPlayer.MaxHeldTimer,
    PlayerGUI = gs.Players.LocalPlayer.PlayerGui,

    MaxGrabDist = 30,
    MaxBlobGrabDist = 40,

    FallenHeight = 0/0,
    NoclipConn = nil,
    OldCollisions = {},

    ThirdPersonVis = nil,

    InfJump = nil,
    JPConn = nil,
    WSConn = nil,

    ServerKicks = 0,
    LastGrabber = nil,

    WhitelistCount = 0,
    Whitelisted = {},
    Notified = {},
    AutoWhitelist = true,

    Connections = {},
}

local v2 = {
    GrabScript = v1.player.Character.GrabbingScript,
    OnFireScript = v1.player.Character.OnFireAnimationScript,
    ChatScript = v1.player.Character.ChatTyping,

    Limb = {
        ["Head"] = true,
        ["Left Arm"] = true,
        ["Right Arm"] = true,
        ["Left Leg"] = true,
        ["Right Leg"] = true,
        ["Torso"] = true,
        ["HumanoidRootPart"] = true,
    },

    WeldLimb = {
        ["Head"] = true,
        ["Left Arm"] = true,
        ["Right Arm"] = true,
        ["Left Leg"] = true,
        ["Right Leg"] = true,
        ["Torso"] = true,
    },

    GucciMatch = {
        ["Tractor"] = "TractorGreen",
        ["Blobman"] = "CreatureBlobman",
    },

    MapPoint = {
        Island = workspace.Map.FactoryIsland,
        Hole = workspace.Map.Hole,
    },

    Location = {
        ["Goon Cave"] = CFrame.new(193, -7, -563),
        ["Small Cave"] = CFrame.new(-84, 15, -310),
        ["Big Cave"] = CFrame.new(-32, 34, 573),
        ["Island Cave"] = CFrame.new(158, 308, 330),
        ["Chinese Roof"] = CFrame.new(592, 153, -96)
    },

    GameFolder = {
        ["Balloons"] = true, ["Cave"] = true, ["Cubes"] = true, ["Drawers"] = true,
        ["Farm"] = true, ["Food"] = true, ["Furniture"] = true, ["Glass Boxes"] = true,
        ["Ladders"] = true, ["Large Animals"] = true, ["Lincoln Planks"] = true, ["Music"] = true,
        ["NOT New"] = true, ["Other"] = true, ["Pallets"] = true, ["Robloxians"] = true,
        ["Rollers"] = true, ["🍗"] = true,
    },

    Blacklist = {
        [workspace.Map] = true,
        [workspace.Slots] = true,
        [workspace.Plots] = true,
        ["Bubble"] = true
    },

    Seatables = {
        ["TractorGreen"] = true,
        ["TractorOrange"] = true,
        ["TractorRed"] = true,
        ["CreatureBlobman"] = true,
    },

    Plot = {
        ["Green House"] = workspace.Plots.Plot1,
        ["Pink House"] = workspace.Plots.Plot2,
        ["Spooky House"] = workspace.Plots.Plot3,
        ["Blue House"] = workspace.Plots.Plot4,
        ["Chinese House"] = workspace.Plots.Plot5,
    },

    BlackListedMusic = {
        "boombox", "musickeyboard", "midimaker",
        "jukebox", "jukeboxorange", "jukeboxblue"
    },

    Item = {
        ["Poop Sparkle"] = "PoopPileSparkle",
        Soda = "FoodSodaCan",
        Cake = "FoodCakePink",
        Hamburger = "FoodHamburger",
        Banana = "FoodBanana",
        Microphone = "InstrumentVoiceMicrophone"
    },

    Movement = {
        PosLockConn = nil,
    },

    Line = {
        LineLag = false,
        LineLagThread = nil,
        LineLagStrength = 11,
        PacketAmount = 3,
        PacketDelay = 0.55,
        PacketLagThread = nil,
        PacketLag = false,
        CrazyLine = false,
        LineExtend = false,
        GrabPartConn = nil,
        ExtendLineConn = nil,
        LineExtendV = 3,
        LineDistv = 1,
        InvisLineConn = nil,
    },

    Grab = {
        SelectedGrabs = {},
        GrabNoclipConn = nil,
        Collidable = {},
        TeleportLocation = "Chinese Roof",
        TeleportMethod = "Players",
        GrabVoidMethod = "Both",
        ToggleStrength = false,
        Strength = 400,
        GpStrengthConn = nil,
        StrengthInputConn = nil,
    },

    Aura = {
        PlayerAuraRunning = {},
        PlayerAuraThreads = {},
        PlayerAuraConn = nil,
        PlayerAuraMethods = {},
        PlayerAura = {},
        AuraTeleportLocation = "Chinese Roof",

        ToyAuraRunning = {},
        ToyAuraThreads = {},
        ToyAuraConn = nil,
        ToyAuraMethods = {},
        ToyAura = false,

        ShowPlayerAuraConn = nil,
    },

    Defense = {
        AntiGrabConn = nil,
        AntiGrabAttacker = nil,
        Attacker = nil,
        CounterAttackConsequence = nil,
        CounterLocation = "Chinese Roof",

        AntiGrabGucci = false,
        GucciType = "Blobman",
        GucciCompleted = false,
        CurrentGucci = nil,
        GucciJumpConn = nil,
        GucciSeatWatch = nil,

        AntiBlobman = false,

        ExplodeWatchConn = nil,
        AntiExplodeBusy = false,
        AntiExplode = false,

        AntiBananaBusy = false,
        AntiBanana = false,
        AntiBananaConn = nil,
        HadGucci = false,

        AntiNetChange = false,
        AntiInput = false,
        AntiInputToy = nil,
        CurrentAntiInputToy = nil,

        AntiDesyncConns = {},

        AntiSticky = false,
        AntiStickyConn = nil,
        AntiStickyRunning = {},
        AntiStickyThreads = {},

        AntiPaint = false,
        AntiPaintBuckets = {},

        AntiBurnConn = nil,

        SavedPoisonCF = {},
        PoisonClones = {},

        AntiKick = nil,
        AntiKickThread = nil,
        CurrentAntiKick = nil,
        AntiKickHL = nil,
        AntiKickHLTrans = 0.4,
        AntiKickHLFillColor = Color3.fromRGB(255, 255, 255),
        AntiKickHLOlColor = Color3.fromRGB(255, 255, 255),

        EnableAntiKick = false,
        AutoEnableAKConn = nil,
        AutoBreakPCLD = false,
        PCLDWaiting = false,
        PCLDProcessing = false,
        PCLDDeathConn = nil,
        CharAddedConn = nil,
        
        AutoResetConn = nil,
        AntiLagSens = 5,
        LineLagWatchConn = nil,
        AntiLagEna = false,
        LineLaggers = {},
        LineLagLastLine = {},

        AntiVoidConn = nil,
    },

    ThirdParty = {
        Protected = {},
        Grabbed = {},
        AntiGrab = false,
        AntiGrabThread = nil,
        
        AntiKick = false,
        Shurikens = {},
        AntiKickThread = nil,

        AntiExplode = false,
        AntiExplodeThread = nil,
        Exploded = {},
    },

    Target = {
        OldTargets = {},
        Targets = {},
        BlobmanTargets = {},
        GoodTargets = {},
        GoodBlobTargets = {},

        TargetMethod = {},
        KickServerMethod = "Heaven",
        KickServerShape = "Circle",
        PlayerShouldLag = false,
        Lag = false,

        BlobmanMethod = nil,
        TimeOut = 1.5,

        ControlledWS = 16,
        ControlledJP = 24,
        FollowMe = false,
        ControlledTeleportLocation = nil,
    },

    Object = {
        EffectTargets = {},
        EffectType = nil,
        ExplodeTargets =  {},
        ExplodeType = nil,

    },

    Visual = {
		PCLD = false,
		PCLDAdded = nil,
		sbTable = {},
		sbSurfaceColor = Color3.fromRGB(124, 42, 195),
		sbColor = Color3.fromRGB(213, 206, 4),

        AntiKickWarn = nil,
        AntiKickWarnFC = Color3.fromRGB(255, 0, 25),
        AntiKickWarnOC = Color3.fromRGB(215, 0, 25),
        AntiKickWarnTrans = 0.4,

        PlayerToyAddedConn = nil,
        PlayerObjectFC = Color3.fromRGB(255, 255, 255),
        PlayerObjectOC = Color3.fromRGB(255, 255, 255),
        PlayerObjectTrans = 0.4,

        CurrentFriendFolder = {},
        FriendAdded = nil,
        FriendObjectFC = Color3.fromRGB(40, 170, 255),
        FriendObjectOC = Color3.fromRGB(120, 210, 255),
        FriendObjectTrans = 0.4,


        CurrentStrangerFolder = {},
        StrangerAdded = nil,
        StrangerObjectFC = Color3.fromRGB(255, 70, 70),
        StrangerObjectOC = Color3.fromRGB(255, 160, 160),
        StrangerObjectTrans = 0.4,

        ToggleMapColors = false,
        GrassColor = Color3.fromRGB(124, 156, 107),
        LushColor = Color3.fromRGB(61, 100, 54),
        RockColor = Color3.fromRGB(163, 161, 165),
        DirtColor = Color3.fromRGB(175, 147, 131),
        WasteColor = Color3.fromRGB(84, 63, 84),
        SnowColor = Color3.fromRGB(248, 248, 248),
        SandColor = Color3.fromRGB(240, 230, 198),

        WaterColor = Color3.fromRGB(36, 74, 105),
        WaterReflect = 0.45,
        WaterTrans = 0.25,
        WaveSize = 0.35,
        WaveSpeed = 10,

        ToggleSkybox = false,
        SkyboxUp = "8995814929",
        SkyboxDn = "8995686153",
        SkyboxLf = "8995816670",
        SkyboxRt = "8995816670",
        SkyboxBk = "8995816670",
        SkyboxFt = "8995816670",

        ToggleWeather = false,
        Time = 14,
        Brightness = 2,
        Ambient = Color3.fromRGB(120, 120, 120),
        Style = Enum.LightingStyle.Soft,
        Tech = Enum.Technology.Voxel,
        
        ToggleShaders = false,
        blur = nil,
        bloom = nil,
        ColorCorrection = nil,
        Dof = nil,
        ray = nil,
        atmos = nil,
        BlurSize = 2,
        BloomIntens = 0.35,
        BloomSize = 12,
        BloomThresh = 0.55,
        ccBrightness = 0.03,
        ccContrast = 0.08,
        ccSaturation = 0.3,
        ccTint = Color3.fromRGB(251, 203, 255),
        dofFar = 0.15,
        dofFocus = 0.5,
        dofInFocus = 55,
        dofNearIntens = 0.15,
        rayIntens = 0.18,
        raySpread = 1,
        atmosDens = 0.08,
        SunSize = 20,
    },

    Misc = {
        FurtherReachConn = nil,
        MultiColorConn = nil,
        MultiColor = false,
        FasterEscapeTime = 3,

        OldLine = {
            [1] = v1.KeyPoints[1].Value,
            [2] = v1.KeyPoints[2].Value,
            [3] = v1.KeyPoints[3].Value,
            [4] = v1.KeyPoints[4].Value,
            [5] = v1.KeyPoints[5].Value,
            [6] = v1.KeyPoints[6].Value,
            [7] = v1.KeyPoints[7].Value,
            [8] = v1.KeyPoints[8].Value,
            [9] = v1.KeyPoints[9].Value,
            Ball = v1.player.BeamColor.BallColorHolder.Value,
        },

        Line = {
            [1] = v1.KeyPoints[1].Value,
            [2] = v1.KeyPoints[2].Value,
            [3] = v1.KeyPoints[3].Value,
            [4] = v1.KeyPoints[4].Value,
            [5] = v1.KeyPoints[5].Value,
            [6] = v1.KeyPoints[6].Value,
            [7] = v1.KeyPoints[7].Value,
            [8] = v1.KeyPoints[8].Value,
            [9] = v1.KeyPoints[9].Value,
            Ball = v1.player.BeamColor.BallColorHolder.Value,
        },

        AmbienceVolumes = {},
        MusicVolumes = {},
        ExplosionVolumes = {},
        ScreamVolumes = {},
        InvWatcher = {},
        LineVolumes = {},
        MuteMusic = false,
        ExplosionWatch = nil,
        GrabLineConn = nil,
        ScreamConn = nil,
        PlotWatcher = nil,

        AutoSpin = false,
        AutiSpinBusy = false,
        PlotTime = false,
        PlotTimeBusy = false,


        SpamSounds = false,
        Message = nil,
        SendDelay = 0.25,
    },
}

local v3 = {
    ActivePackets = false,
    PacketWatchConn = nil,
    ActiveFolders = {},
    ActiveCloneConns = {},
    CloneActive = false,
    Clone = nil,
    CloneMoveConn = nil,
}
-------------------------->> [Functions] <<--------------------------
local Function = {
    Tween = function(obj, property, dur)
        local tw = gs.TWS:Create(obj, TweenInfo.new(dur or 0.5, Enum.EasingStyle.Linear), property)
        tw:Play()
    end,

    Notify = function(Desc, T)
        lib:Notify({Title = "Kaylis", Description = Desc, Time = T,})
        local Sound = Instance.new("Sound")
        Sound.Name = "Notif"
        Sound.SoundId = "rbxassetid://131390520971848"
        Sound.Parent = game.CoreGui
        Sound:Play()
        Sound.Ended:Once(function()
            Sound:Destroy()
        end)
    end,

    Whitelisted = function(plr)
        return v1.Whitelisted[plr] == true
    end,

    LockChar = function(char)
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 3)
        if not hrp then return end
        if hrp:FindFirstChild("Left Leg") then return end
        for _, limb in ipairs(char:GetChildren()) do
            if v2.WeldLimb[limb.Name] then
                local Motor = Instance.new("Motor6D")
                Motor.Name = limb.Name
                Motor.Part0 = hrp
                Motor.Part1 = limb
                Motor.Parent = hrp
                if limb.Name == "Head" then
                    Motor.C1 = CFrame.new(0, -1.5, 0)
                elseif limb.Name == "Left Arm" then
                    Motor.C1 = CFrame.new(1.5, 0, 0)
                elseif limb.Name == "Right Arm" then
                    Motor.C1 = CFrame.new(-1.5, 0, 0)
                elseif limb.Name == "Right Leg" then
                    Motor.C1 = CFrame.new(-0.5, 2, 0)
                elseif limb.Name == "Left Leg" then
                    Motor.C1 = CFrame.new(0.5, 2, 0)
                end
            end
        end
    end,

    UnlockChar = function(char)
        for _, weld in ipairs(char:GetDescendants()) do
            if weld:IsA("Motor6D") and v2.WeldLimb[weld.Name] then
                weld:Destroy()
            end
        end
    end,

    BackPack = function(plr)
        plr = plr or player
        local plotItems = workspace:FindFirstChild("PlotItems")
        local spawnedInToys = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
        local plotBackPack
        if plotItems then
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in ipairs(plots:GetChildren()) do
                    local plotSign = plot:FindFirstChild("PlotSign")
                    local owners = plotSign and plotSign:FindFirstChild("ThisPlotsOwners")
                    if owners then
                        for _, owner in ipairs(owners:GetDescendants()) do
                            if owner:IsA("ObjectValue") and owner.Value == plr then
                                plotBackPack = plotItems:FindFirstChild(plot.Name)
                                break
                            end
                        end
                    end
                    if plotBackPack then
                        break
                    end
                end
            end
        end
        return plotBackPack, spawnedInToys
    end,

    ConnectConn = function(conn)
        table.insert(v1.Connections, conn)
        return conn
    end,

    ResetScriptDefualt = function()
        for _, Toggle in pairs(Library.Toggles) do
            if Toggle.SetValue then
                Toggle:SetValue(false)
            end
        end
        for _, Option in pairs(Library.Options) do
            if Option.Type == "Slider" and Option.SetValue then
                Option:SetValue(Option.Default or 0)
            end
        end
        for _, Option in pairs(Library.Options) do
            if Option.Type == "Dropdown" and Option.Default and Option.SetValue then
                Option:SetValue(Option.Default)
            end
        end
        for _, conn in ipairs(v1.Connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        table.clear(v1.Connections)
    end,

    SpawnSno = function(toy, part, name, invis)
        local OldToys = {}
        for _, t in ipairs(v1.inv:GetChildren()) do
            OldToys[t] = true
        end

        local hrp = v1.player.Character.HumanoidRootPart

        task.spawn(function()
            pcall(function()
                Event.SpawnToy:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 12, 17), Vector3.new(0, 60, 0))
            end)
        end)

        local SpawnedToy

        repeat
            for _, t in ipairs(v1.inv:GetChildren()) do
                if t.Name == toy and not OldToys[t] then
                    SpawnedToy = t
                    break
                end
            end

            task.wait()
        until SpawnedToy

        SpawnedToy.Name = name
        local GP = SpawnedToy:FindFirstChild(part, true)

        if GP then
            repeat
                Event.sno:FireServer(GP, GP.CFrame)
                task.wait(0.02)
            until isnetworkowner(GP) or not SpawnedToy.Parent
            task.wait(0.05)
            GP.AssemblyLinearVelocity = Vector3.new(0, 9e9, 0)
        end

        task.wait(0.03)

        if invis then
            for _, p in ipairs(SpawnedToy:GetChildren()) do
                if p:IsA("BasePart") then
                    p.Transparency = 1
                    p.CanCollide = false
                end
            end
        end

        return SpawnedToy
    end,

    SpawnToy = function(toy, cframe)
        local OldToys = {}
        for _, t in ipairs(v1.inv:GetChildren()) do
            OldToys[t] = true
        end

        task.spawn(function()
            pcall(function()
                Event.SpawnToy:InvokeServer(toy, cframe, Vector3.new(0, 60, 0))
            end)
        end)

        local SpawnedToy

        repeat
            for _, t in ipairs(v1.inv:GetChildren()) do
                if t.Name == toy and not OldToys[t] then
                    SpawnedToy = t
                    break
                end
            end

            task.wait()
        until SpawnedToy

        return SpawnedToy
    end,

    FloatMe = function(hrp)
        if not hrp then return end
        if hrp:FindFirstChild("FloatGyro") then return end

        local gyro = Instance.new("BodyGyro")
        gyro.Name = "FloatGyro"
        gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        gyro.P = 10000
        gyro.D = 1000
        gyro.CFrame = hrp.CFrame
        gyro.Parent = hrp

        local bv = Instance.new("BodyVelocity")
        bv.Name = "FloatVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
    end,

    UnfloatMe = function(hrp)
        if not hrp then return end
        local gyro = hrp:FindFirstChild("FloatGyro")
        local bv = hrp:FindFirstChild("FloatVelocity")
        if gyro then gyro:Destroy() end
        if bv then bv:Destroy() end
    end,

    Float = function(hrp, pos)
        if not hrp then return end
        if hrp:FindFirstChild("Float") then return end
        local bodyPosition = Instance.new("BodyPosition", hrp)
        bodyPosition.Name = "Float"
        bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyPosition.Position = pos
        bodyPosition.P = 10000
        bodyPosition.D = 1000

        local BG = Instance.new("BodyGyro", hrp)
        BG.Name = "Gyro"
        BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BG.P = 10000
        BG.D = 2000
    end,

    Unfloat = function(hrp)
        if not hrp then return end
        local bodyPosition = hrp:FindFirstChild("Float")
        local Gyro = hrp:FindFirstChild("Gyro")
        if bodyPosition or Gyro then
            bodyPosition:Destroy()
            Gyro:Destroy()
        end
    end,

    Launch = function(part, vec)
        if not part then return end
        local bv = Instance.new("BodyVelocity", part)
        bv.Name = "FloatVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = vec
        gs.Deb:AddItem(bv, 0.15)
    end,

    IsRagdolled = function(char)
        return char.Head.BallSocketConstraint.Enabled
    end,

    StartNoclip = function()
        if v1.NoclipConn then
            v1.NoclipConn:Disconnect()
            v1.NoclipConn = nil
            for part, collision in pairs(v1.OldCollisions or {}) do
                if part.Parent then
                    part.CanCollide = collision
                end
            end
            table.clear(v1.OldCollisions)
            return
        end
        v1.OldCollisions = {}
        v1.NoclipConn = gs.Rs.RenderStepped:Connect(function()
            local char = v1.player.Character
            if not char then return end
            for _, x in ipairs(char:GetDescendants()) do
                if x:IsA("BasePart") then
                    if v1.OldCollisions[x] == nil then
                        v1.OldCollisions[x] = x.CanCollide
                    end

                    x.CanCollide = false
                end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            local car = seat and seat.Parent
            if car then
                for _, x in ipairs(car:GetDescendants()) do
                    if x:IsA("BasePart") then
                        if v1.OldCollisions[x] == nil then
                            v1.OldCollisions[x] = x.CanCollide
                        end
                        x.CanCollide = false
                    end
                end
            end
        end)
    end,

    StopNoclip = function()
        if v1.NoclipConn then
            v1.NoclipConn:Disconnect()
            v1.NoclipConn = nil
        end
        for part, collision in pairs(v1.OldCollisions or {}) do
            if part.Parent then
                part.CanCollide = collision
            end
        end
        table.clear(v1.OldCollisions or {})
    end,

    SnoPart = function(part)
        local char = v1.player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not part or not part:IsA("BasePart") then return end

        local hrpClone = hrp:Clone()
        hrpClone.Name = "Part"
        local Dist = (hrp.Position - part.Position).Magnitude
        local ExtendDist = math.clamp(Dist, 0.5, v1.MaxGrabDist)

        hrpClone.CFrame = CFrame.lookAt(hrpClone.Position, part.Position)

        Event.egl:FireServer(ExtendDist)
        Event.sno:FireServer(part, hrpClone.CFrame)
        hrpClone:Destroy()
    end,

    DoesOwn = function(model)
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                if isnetworkowner(part) then
                    return true
                end
            end
        end

        return false
    end,

    HasGucci = function(plr)
        local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
        local seat = hum.SeatPart
        if seat and not seat.Occupant then return true end
        return false
    end,

    GetLookedAtPlayer = function()
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {v1.player.Character}
		local result = workspace:Raycast(v1.camera.CFrame.Position, v1.camera.CFrame.LookVector * 1000, params)
		if result then
			local hit = result.Instance
			for _, plr in ipairs(gs.Players:GetPlayers()) do
				if plr ~= v1.player
					and plr.Character
					and hit:IsDescendantOf(plr.Character) then
					return plr
				end
			end
		end

        return nil
	end,

    FindGrabPart = function(toy)
        for _, c in ipairs(toy:GetChildren()) do
            if c:IsA("BasePart") and c.CanQuery then
                return c
            end
        end
        return false
    end,

    GiveReach = function()
        local notifier = game.ReplicatedStorage.GamepassEvents:FindFirstChild("FurtherReachBoughtNotifier")
        if notifier and getconnections then
            for _,connection in ipairs(getconnections(notifier.OnClientEvent)) do
                pcall(function()
                    connection.Function()
                end)
            end
        end
    end,
    GiveMultiColor = function()
        local notifier2 = game.ReplicatedStorage.GamepassEvents:FindFirstChild("MulticolorLineBoughtNotifier")
        if notifier2 and getconnections then
            for _,connection in ipairs(getconnections(notifier2.OnClientEvent)) do
                pcall(function()
                    connection.Function()
                end)
            end
        end
    end,
    IsTargetGood = function(plr)
        if not plr or not plr.Character then return false end
        local tchar = plr.Character
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        local thum = tchar:FindFirstChildOfClass("Humanoid")
        local char = v1.player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if tchar.Parent and tchar.Parent.Name == "PlayersInPlots" then return false end
        if not thum or thum.Health <= 0 then return false end
        if not thrp or not hrp then return false end
        if (thrp.Position - hrp.Position).Magnitude > 1500 then return false end
        return true
    end,

    StartClone = function(tag)
        if not tag then return end
        if not v3.ActiveCloneConns[tag] then
            v3.ActiveCloneConns[tag] = true
        end
        if v3.CloneActive then return end

        local char = v1.player.Character
        if not char then return end

        v3.CloneActive = true
        char.Archivable = true

        local clone = char:Clone()
        clone.Name = "Character"
        clone.Parent = workspace
        v3.Clone = clone

        local realHum = char:FindFirstChildOfClass("Humanoid")
        local hum = clone:FindFirstChildOfClass("Humanoid")
        

        for _, cam in ipairs(clone:GetChildren()) do
            if cam:IsA("BasePart") and cam.Name == "CamPart" or cam.Name == "TruePosition" then
                cam:Destroy()
            end
        end

        for _, p in ipairs(clone:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
                p.CanQuery = false
                p.Anchored = false
            elseif p:IsA("Script") or p:IsA("LocalScript") then
                p:Destroy()
            end
        end

        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            v1.camera.CameraSubject = hum
        end

        local realAnimator = realHum and realHum:FindFirstChildOfClass("Animator")
        local cloneAnimator = hum and hum:FindFirstChildOfClass("Animator")

        if not cloneAnimator and hum then
            cloneAnimator = Instance.new("Animator")
            cloneAnimator.Parent = hum
        end

        local animationTracks = {}

        v3.CloneMoveConn = gs.Rs.RenderStepped:Connect(function()
            if not clone.Parent or not char.Parent then
                return
            end

            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Transparency = 1
                    end
                end
            end

            if hum and realHum then
                hum:Move(realHum.MoveDirection, false)
                hum.Jump = realHum.Jump
                hum.WalkSpeed = realHum.WalkSpeed
                hum.JumpPower = realHum.JumpPower
                hum.HipHeight = realHum.HipHeight
            end

            local IgnoreAnimations = {
                ["rbxassetid://7047322890"] = true,
                ["rbxassetid://987654321"] = true,
            }

            local cloneFalling = hum:GetState() == Enum.HumanoidStateType.Freefall
            if realTracks then
                for _, realTrack in ipairs(realTracks) do
                    local animation = realTrack.Animation
                    if not animation then continue end

                    local id = animation.AnimationId

                    if IgnoreAnimations[id] then
                        continue
                    end

                    if id == "rbxassetid://7047322890" and not cloneFalling then
                        continue
                    end

                    local cloneTrack = animationTracks[id]

                    if not cloneTrack then
                        local newAnimation = Instance.new("Animation")
                        newAnimation.AnimationId = id

                        cloneTrack = cloneAnimator:LoadAnimation(newAnimation)
                        animationTracks[id] = cloneTrack
                    end

                    if not cloneTrack.IsPlaying then
                        cloneTrack:Play(0, realTrack.WeightCurrent, realTrack.Speed)
                    end

                    cloneTrack:AdjustSpeed(realTrack.Speed)
                    cloneTrack:AdjustWeight(realTrack.WeightCurrent, 0)

                    pcall(function()
                        cloneTrack.TimePosition = realTrack.TimePosition
                    end)
                end
            end
        end)
    end,

    StopClone = function(tag)
        if v3.ActiveCloneConns[tag] then
            v3.ActiveCloneConns[tag] = nil
        else
            return
        end

        if next(v3.ActiveCloneConns) then
            return
        end

        if not v3.CloneActive then return end

        v3.CloneActive = false

        if v3.CloneMoveConn then
            v3.CloneMoveConn:Disconnect()
            v3.CloneMoveConn = nil
        end

        local char = v1.player.Character
        local realHum = char and char:FindFirstChildOfClass("Humanoid")

        if char and v3.Clone then
            local clone = v3.Clone
            local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
            local realRoot = char:FindFirstChild("HumanoidRootPart")

            if cloneRoot and realRoot then
                realRoot.CFrame = cloneRoot.CFrame
            end

            clone:Destroy()
            v3.Clone = nil
        end

        if realHum then
            v1.camera.CameraSubject = realHum
        end
    end
}

Function.CanTeleport = function()
    if v1.player.Held.Value then return false end
    if Function.IsRagdolled(v1.player.Character) then return false end
    return true
end

Function.GetParts = function(plr)
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    return char, hrp, hum
end
-------------------------->> [Tabs] <<--------------------------
local Tab = {
    Home = win:AddTab("Home", "house"),
    Player = win:AddTab("Player", "user"),
    Grab = win:AddTab("Combat", "hand"),
    Defense = win:AddTab("Defense", "shield"),
    Target = win:AddTab("Targets", "crosshair"),
    Objects = win:AddTab("Objects", "shapes"),
    Visual = win:AddTab("Visual", "eye"),
    Misc = win:AddTab("Misc", "clipboard"),
}

local GP = {
    Player = Tab.Home:AddGroupbox({ Side = "Left", Name = "Local Player",}),
    Statistic = Tab.Home:AddGroupbox({ Side = "Right", Name = "Statistics",}),
    Script = Tab.Home:AddGroupbox({ Side = "Right", Name = "Script",}),
    
    Animations = Tab.Player:AddGroupbox({ Side = "Left", Name = "Animations",}),
    Movement = Tab.Player:AddGroupbox({ Side = "Right", Name = "Movement",}),

    Grabs = Tab.Grab:AddTabbox({Side = "Left", Name = "Grab"}),
    PlayerAura = Tab.Grab:AddTabbox({Side = "Left", Name = "Player Aura"}),
    ToyAura = Tab.Grab:AddTabbox({Side = "Left", Name = "Toy Aura"}),

    Line = Tab.Grab:AddTabbox({Side = "Right", Name = "Line"}),
    Lag = Tab.Grab:AddTabbox({Side = "Right", Name = "Lag"}),

    Defense = Tab.Defense:AddTabbox({Side = "Left", Name = "Defense"}),
    ThirdParty = Tab.Defense:AddGroupbox({Side = "Right", Name = "ThirdParty"}),
    Counter = Tab.Defense:AddGroupbox({Side = "Right", Name = "Counter Attack"}),
    Misc = Tab.Defense:AddGroupbox({Side = "Right", Name = "Misc"}),

    PCLD = Tab.Visual:AddGroupbox({Side = "Left", Name = "PCLD"}),
    Warning = Tab.Visual:AddGroupbox({Side = "Left", Name = "Warning"}),
    Camera = Tab.Visual:AddGroupbox({ Side = "Left", Name = "Camera"}),
    Vmap = Tab.Visual:AddGroupbox({ Side = "Left", Name = "Map"}),
    Players = Tab.Visual:AddGroupbox({Side = "Right", Name = "Players"}),
    Objects = Tab.Visual:AddGroupbox({Side = "Right", Name = "Objects"}),
    SkyWeather = Tab.Visual:AddTabbox({Side = "Right", Name = "Sky/Weather"}),

    Gamepass = Tab.Misc:AddTabbox({Side = "Left", Name = "Gamepasses"}),
    Audio = Tab.Misc:AddTabbox({Side = "Left", Name = "Audio"}),
    Auto = Tab.Misc:AddTabbox({Side = "Right", Name = "Auto"}),
    Annoying = Tab.Misc:AddTabbox({Side = "Right", Name = "Annoying"}),

    Target = Tab.Target:AddTabbox({Side = "Left", Name = "Targets"}),
    BlobmanTarget = Tab.Target:AddTabbox({Side = "Right", Name = "BlobmanTargets"}),

    Effect = Tab.Objects:AddTabbox({Side = "Right", Name = "Effects"}),
    Bomb = Tab.Objects:AddTabbox({Side = "Right", Name = "Bomb"}),
}
-------------------------->> [Home] <<--------------------------
GP.Player:AddDivider("Welcome!")
GP.Player:AddImage("LocalPlayerImage", {Image = gs.Players:GetUserThumbnailAsync(v1.player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size352x352),})
GP.Player:AddLabel('Welcome <font color="rgb(244, 255, 148)">' .. v1.player.Name .. '</font> I hope you enjoy using the script!', true)
GP.Player:AddDivider("User info")
GP.Player:AddLabel("Username: " .. v1.player.Name)
GP.Player:AddLabel("UserID: " .. v1.player.UserId)
GP.Player:AddLabel("Account age: " .. v1.player.AccountAge .. " Days")
GP.Statistic:AddLabel("Server kicks: " .. v1.ServerKicks)
PlayerAmountText = GP.Statistic:AddLabel("Current players: " .. #gs.Players:GetPlayers())
GP.Statistic:AddLabel("Game name: Fling Things and People")
LastGrabbedText = GP.Statistic:AddLabel("Last grabbed by: ")
GP.Script:AddButton({
    Text = "Rejoin",
    Func = function()
        gs.Tps:TeleportToPlaceInstance(game.PlaceId, game.JobId, v1.player)
    end
})
GP.Script:AddButton({
    Text = "Rejoin (Private Server)",
    Func = function()
        v1.player:Kick("Rejoining")
        gs.Tps:Teleport(game.PlaceId, v1.player)
    end
})
GP.Script:AddButton({
    Text = "Unload Script",
    Func = function()
        UnloadConfirm = win:AddDialog("UnloadConfirm", {
            Title = "Are you sure?",
            Description = "This will close the script and unload everything.",
            AutoDismiss = true,
            OutsideClickDismiss = true,
            FooterButtons = {
                Cancel = {
                    Title = "Cancel",
                    Variant = "Primary",
                    Order = 1,
                    Callback = function()
                        return
                    end
                },
                Unload = {
                    Title = "Unload",
                    Variant = "Destructive",
                    WaitTime = 0,
                    Order = 2,
                    Callback = function(self)
                        Function.ResetScriptDefualt()
                        lib:Unload()
                    end
                }
            }
        })
    end
})
GP.Script:AddDivider("Whitelist")
WhitelistDropdown = GP.Script:AddDropdown("WhitelistPlayers", {
    Values = {},
    Default = nil,
    Multi = true,
    Text = "Whitelist Players",
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Callback = function(v)
        v1.Whitelisted = v
        for plr, _ in pairs(v2.Target.OldTargets) do
            if type(plr) == "number" then
                v2.Target.OldTargets[plr].Whitelisted = false
            end
        end
        for plr, selected in pairs(v) do
            if selected then
                v2.Target.OldTargets[plr.UserId] = v2.Target.OldTargets[plr.UserId] or {}
                v2.Target.OldTargets[plr.UserId].Whitelisted = true
            end
        end
    end
})
AutoWhitelist = GP.Script:AddToggle("AutoWhitelist", {
    Text = "Auto Whitelist Friends",
    Default = true,
    Callback = function(v)
        v1.AutoWhitelist = v
        if v then
            task.spawn(function()
                while v1.AutoWhitelist do
                    local selected = {}
                    for plr, state in pairs(WhitelistDropdown.Value or {}) do
                        if state then
                            selected[plr] = true
                        end
                    end
                    for _, plr in ipairs(gs.Players:GetPlayers()) do
                        if plr ~= v1.player and plr:IsFriendsWith(v1.player.UserId) then
                            selected[plr] = true
                            if not v1.Notified[plr] then
                                v1.Notified[plr] = true
                                v1.Whitelisted[plr] = true
                                Function.Notify(plr.DisplayName .. " | " .. plr.Name .. " Whitelisted")
                            end
                        end
                    end
                    WhitelistDropdown:SetValue(selected)
                    task.wait(0.05)
                end
            end)
        else
            for plr in pairs(v1.Notified) do
                v1.Whitelisted[plr] = nil
            end
            local selected = {}
            for plr, state in pairs(WhitelistDropdown.Value or {}) do
                if state and not v1.Notified[plr] then
                    selected[plr] = true
                end
            end
            table.clear(v1.Notified)
            WhitelistDropdown:SetValue(selected)
        end
    end
})
-------------------------->> [Player] <<--------------------------
GP.Animations:AddDivider("Disable Animations")
ChatAnimation = GP.Animations:AddToggle("ChatAnimation", {
    Text = "Disable Chat Anim",
    Default = false,
    Callback = function(v)
        if v then
            v2.ChatScript.Disabled = true
        else
            v2.ChatScript.Enabled = true
        end
    end
})
GP.Animations:AddToggle("FireAnimation", {
    Text = "Disable Fire Anim",
    Default = false,
    Callback = function(v)
        if v then
            v2.OnFireScript.Disabled = true
        else
            v2.OnFireScript.Enabled = true
        end
    end
})
-------------------------->> [Movement] <<--------------------------
WS = GP.Movement:AddSlider("WalkSpeed", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        if v1.WSConn then v1.WSConn:Disconnect() end
        if v == 16 then return end

        v1.WSConn = gs.Rs.Stepped:Connect(function()
            local hrp = v1.player.Character:FindFirstChild("HumanoidRootPart")
            local hum = v1.player.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

            local gui = v1.player.PlayerGui
            local stand = gui:FindFirstChild("ControlsGui")
                and gui.ControlsGui:FindFirstChild("PCFrame")
                and gui.ControlsGui.PCFrame:FindFirstChild("Stand")

            local speed = stand and stand.Visible and 5 or v
            local vel = hrp.AssemblyLinearVelocity
            local move = hum.MoveDirection * speed

            hrp.AssemblyLinearVelocity = Vector3.new(move.X, vel.Y, move.Z)
        end)
    end
})
InfJump = GP.Movement:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
    Callback = function(v)
        if v then
            v1.InfJump = gs.Uis.JumpRequest:Connect(function()
                local hum = v1.player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if v1.InfJump then
                v1.InfJump:Disconnect()
                v1.InfJump = nil
            end
        end
    end
})
JP = GP.Movement:AddSlider("JumpPower", {
    Text = "JumpPower",
    Default = 24,
    Min = 24,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v1.player.Character.Humanoid.JumpPower = v
        if v1.JPConn then v1.JPConn:Disconnect(); v1.JPConn = nil end
        v1.JPConn = v1.player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid").JumpPower = v
        end)
    end
})
GP.Movement:AddButton({
    Text = "Reset Movement",
    Func = function()
        JP:SetValue(24)
        WS:SetValue(16)
        InfJump:SetValue(false)
        Function.Notify("Reset movement!", 3)
    end
})
GP.Movement:AddToggle("PosLock", {
    Text = "Position Lock",
    Default = false,
    Callback = function(v)
        if v then
            local hrp = v1.player.Character and v1.player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local target = hrp.Position

            if v2.Movement.PosLockConn then
                v2.Movement.PosLockConn:Disconnect()
            end

            Function.StartClone("PosLock")

            v2.Movement.PosLockConn = gs.Rs.PreRender:Connect(function()
                local hrp = v1.player.Character and v1.player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(target)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        else
            if v2.Movement.PosLockConn then
                v2.Movement.PosLockConn:Disconnect()
                v2.Movement.PosLockConn = nil
            end

            Function.StopClone("PosLock")
        end
    end
})
-------------------------->> [Grabs] <<--------------------------
local GrabBoxTabs = {
    Grabs = GP.Grabs:AddTab("Grabs", "hand"),
    GrabSettings = GP.Grabs:AddTab("Settings", "settings"),

    PlayerAura = GP.PlayerAura:AddTab("Player Aura", "apple"),
    PlayerAuraSettings = GP.PlayerAura:AddTab("Settings", "settings"),

    ToyAura = GP.ToyAura:AddTab("Toy Aura", "shapes"),
    ToyAuraSettings = GP.ToyAura:AddTab("Settings", "settings"),

    Line = GP.Line:AddTab("Line", "pen"),

    Lag = GP.Lag:AddTab("Line", "pen"),
    Packet = GP.Lag:AddTab("Packet", "package"),
    Lobotomy = GP.Lag:AddTab("Lobotomy", "turtle"),
}
GrabBoxTabs.Grabs:AddDropdown("GrabMethods", {
    Text = "Grab Methods",
    Values = {"Noclip", "Teleport", "Massless", "Ragdoll", "Death", "Void"},
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Grab.SelectedGrabs = v
    end
})
ApplyGrabs = GrabBoxTabs.Grabs:AddToggle("ApplyGrabs", {
    Text = "Apply Grabs",
    Default = false,
    Callback = function(v)
        if v then
            v2.Grab.GrabPartConn = workspace.ChildAdded:Connect(function(gp)
                task.spawn(function()
                    if gp:IsA("Model") and gp.Name == "GrabParts" then
                        local GrabPart = gp:FindFirstChild("GrabPart")
                        local DragPart = gp:FindFirstChild("DragPart")
                        local GrabbedPart = GrabPart:FindFirstChild("WeldConstraint").Part1
                        local Blacklisted = v2.Blacklist[GrabbedPart.Name]

                        for Object in pairs(v2.Blacklist) do
                            if typeof(Object) == "Instance" and GrabbedPart:IsDescendantOf(Object) then
                                Blacklisted = true
                                break
                            end
                        end

                        if not Blacklisted then
                            if v2.Grab.SelectedGrabs["Ragdoll"] then
                                if v2.Limb[GrabbedPart.Name] then
                                    local RagPallet = v1.inv:FindFirstChild("RagPallet")
                                    local hrp = v1.player.Character.HumanoidRootPart
                                    local THead = GrabbedPart.Parent.Head
                                    if not RagPallet then
                                        RagPallet = Function.SpawnSno("PalletLightBrown", "SoundPart", "RagPallet", true)
                                        RagPallet:PivotTo(hrp.CFrame * CFrame.new(0, 1e18, 0))
                                    end
                                    if THead then
                                        RagPallet:PivotTo(THead.CFrame)
                                        task.wait(0.03)
                                        RagPallet:PivotTo(hrp.CFrame * CFrame.new(0, 1e18, 0))
                                    end
                                end
                            end

                            if v2.Grab.SelectedGrabs["Teleport"] then
                                if v2.Grab.TeleportMethod == "Players" and v2.Limb[GrabbedPart.Name] then
                                    GrabbedPart.CFrame = v2.Location[v2.Grab.TeleportLocation]
                                elseif v2.Grab.TeleportMethod == "Objects" and not v2.Limb[GrabbedPart.Name] then
                                    GrabbedPart.CFrame = v2.Location[v2.Grab.TeleportLocation]
                                elseif v2.Grab.TeleportMethod == "Both" then
                                    GrabbedPart.CFrame = v2.Location[v2.Grab.TeleportLocation]
                                end
                            end

                            if v2.Grab.SelectedGrabs["Massless"] then
                                DragPart.AlignPosition.MaxForce = math.huge
                                DragPart.AlignPosition.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
                                DragPart.AlignPosition.Responsiveness = 200
                                DragPart.AlignOrientation.MaxTorque = math.huge
                                DragPart.AlignOrientation.Responsiveness = 200
                            end

                            if v2.Grab.SelectedGrabs["Noclip"] then
                                local Parent = GrabbedPart.Parent

                                for _, p in ipairs(Parent:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        v2.Grab.Collidable[p] = p.CanCollide
                                    end
                                end

                                v2.Grab.GrabNoclipConn = gs.Rs.RenderStepped:Connect(function()
                                    if not GrabPart or not GrabPart.Parent then

                                        for part, originalCanCollide in pairs(v2.Grab.Collidable) do
                                            if part and part.Parent then
                                                part.CanCollide = originalCanCollide
                                            end
                                        end

                                        table.clear(v2.Grab.Collidable)

                                        if v2.Grab.GrabNoclipConn then
                                            v2.Grab.GrabNoclipConn:Disconnect()
                                            v2.Grab.GrabNoclipConn = nil
                                        end

                                        return
                                    end

                                    for part in pairs(v2.Grab.Collidable) do
                                        if part and part.Parent then
                                            part.CanCollide = false
                                        end
                                    end
                                end)
                            end

                            if v2.Grab.SelectedGrabs["Void"] then
                                if v2.Grab.GrabVoidMethod == "Players" and v2.Limb[GrabbedPart.Name] then
                                    workspace.FallenPartsDestroyHeight = -500000
                                    GrabbedPart.CFrame = CFrame.new(0, -49995, 0)
                                    task.wait(0.3)
                                    workspace.FallenPartsDestroyHeight = v1.FallenHeight
                                elseif v2.Grab.GrabVoidMethod == "Objects" and not v2.Limb[GrabbedPart.Name] then
                                    workspace.FallenPartsDestroyHeight = -500000
                                    GrabbedPart.CFrame = CFrame.new(0, -49995, 0)
                                    task.wait(0.3)
                                    workspace.FallenPartsDestroyHeight = v1.FallenHeight
                                elseif v2.Grab.GrabVoidMethod == "Both" then
                                    workspace.FallenPartsDestroyHeight = -500000
                                    GrabbedPart.CFrame = CFrame.new(0, -49995, 0)
                                    task.wait(0.3)
                                    workspace.FallenPartsDestroyHeight = v1.FallenHeight
                                end
                            end

                            if v2.Grab.SelectedGrabs["Death"] and v2.Limb[GrabbedPart.Name] then
                                local thum = GrabbedPart.Parent:FindFirstChildOfClass("Humanoid")
                                thum.BreakJointsOnDeath = false
                                thum:ChangeState(Enum.HumanoidStateType.Dead)
                            end
                        end
                    end
                end)
            end)
        else
            if v2.Grab.GrabPartConn then
                v2.Grab.GrabPartConn:Disconnect()
                v2.Grab.GrabPartConn = nil
            end
        end
    end
})
GrabBoxTabs.PlayerAura:AddDropdown("PlayerAuraMethods", {
    Text = "Aura Methods",
    Values = {"Noclip", "Teleport", "Ragdoll", "Void", "Heaven", "Kill", "Push", "Fling"},
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Aura.PlayerAuraMethods = v
    end
})
GrabBoxTabs.PlayerAura:AddToggle("ShowPlayerAura", {
    Text = "Show Aura Radius",
    Default = false,
    Callback = function(v)
        if v then
            local AuraPart = Instance.new("Part", workspace)
            AuraPart.Name = "AuraRadius"
            AuraPart.Shape = Enum.PartType.Ball
            AuraPart.Size = Vector3.new(v1.MaxGrabDist * 2, v1.MaxGrabDist * 2, v1.MaxGrabDist * 2)

            AuraPart.Material = Enum.Material.ForceField
            AuraPart.Color = Color3.fromRGB(255, 0, 0)
            AuraPart.Transparency = 0.35

            AuraPart.Anchored = true
            AuraPart.CanCollide = false
            AuraPart.CanTouch = false
            AuraPart.CanQuery = false
            AuraPart.CastShadow = false

            v2.Aura.ShowPlayerAuraConn = gs.Rs.RenderStepped:Connect(function()
                local hrp = v1.player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    AuraPart.Position = hrp.Position
                end
            end)
        else
            if v2.Aura.ShowPlayerAuraConn then
                v2.Aura.ShowPlayerAuraConn:Disconnect()
                v2.Aura.ShowPlayerAuraConn = nil
            end
            local dp = workspace:FindFirstChild("AuraRadius")
            if dp then dp:Destroy() end
        end
    end
})
PlayerAura = GrabBoxTabs.PlayerAura:AddToggle("PlayerAura", {
    Text = "Apply Auras",
    Default = false,
    Callback = function(v)
        v2.Aura.PlayerAura = v
        if v then
            v2.Aura.PlayerAuraConn = gs.Rs.Heartbeat:Connect(function()
                local char = v1.player.Character or v1.player.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart", true)
                for _, t in ipairs(gs.Players:GetPlayers()) do
                    if t == v1.player then continue end
                    if v2.Aura.PlayerAuraRunning[t] then continue end
                    local tchar = t.Character
                    if not tchar then continue end
                    local thrp = tchar:FindFirstChild("HumanoidRootPart", true)
                    local thum = tchar:FindFirstChild("Humanoid", true)
                    local thead = tchar:FindFirstChild("Head", true)
                    if not thrp then continue end
                    if not hrp then continue end
                    local dist = (thrp.Position - hrp.Position).Magnitude
                    if dist <= v1.MaxGrabDist then
                        v2.Aura.PlayerAuraRunning[t] = true
                        v2.Aura.PlayerAuraThreads[t] = task.spawn(function()
                            if not isnetworkowner(thrp) then
                                repeat
                                    Function.SnoPart(thrp)
                                    dist = (thrp.Position - hrp.Position).Magnitude
                                    task.wait(0.03)
                                until isnetworkowner(thrp) or dist >= v1.MaxGrabDist or thum.Health == 0 or v1.PlotPlayers:IsDescendantOf(tchar) or not v2.Aura.PlayerAura
                            end

                            if not thrp or not tchar or thum.Health == 0 then
                                    v2.Aura.PlayerAuraRunning[t] = nil
                                    v2.Aura.PlayerAuraThreads[t] = nil
                                return
                            end

                            if v2.Aura.PlayerAuraMethods["Void"] then
                                workspace.FallenPartsDestroyHeight = -500000
                                thrp.CFrame = CFrame.new(0, -49998, 0)
                                task.wait(0.3)
                                workspace.FallenPartsDestroyHeight = v1.FallenHeight
                            end

                            if v2.Aura.PlayerAuraMethods["Teleport"] then
                                thrp.CFrame = v2.Location[v2.Aura.AuraTeleportLocation]
                            end

                            if v2.Aura.PlayerAuraMethods["Noclip"] then
                                for _, p in ipairs(tchar:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        p.CanCollide = false
                                    end
                                end
                            end

                            if v2.Aura.PlayerAuraMethods["Ragdoll"] then
                                local RagPallet = v1.inv:FindFirstChild("RagPallet")
                                if not RagPallet then
                                    RagPallet = Function.SpawnSno("PalletLightBrown", "SoundPart", "RagPallet", true)
                                    RagPallet:PivotTo(hrp.CFrame * CFrame.new(0, 1e18, 0))
                                end
                                if Function.IsRagdolled(tchar) then return end
                                if thead then
                                    repeat
                                        RagPallet:PivotTo(thead.CFrame)
                                        task.wait()
                                        RagPallet:PivotTo(hrp.CFrame * CFrame.new(0, 1e18, 0))
                                    until Function.IsRagdolled(tchar) or not RagPallet or not tchar
                                end
                            end

                            if v2.Aura.PlayerAuraMethods["Heaven"] then
                                thrp.AssemblyLinearVelocity = Vector3.new(0, 9e2, 0)
                            end

                            if v2.Aura.PlayerAuraMethods["Kill"] then
                                thum.BreakJointsOnDeath = false
                                Event.dgl:FireServer(thrp)
                                task.wait(); task.wait(0.03)
                                thum:ChangeState(Enum.HumanoidStateType.Dead)
                                thrp.AssemblyLinearVelocity = Vector3.new(0, 9e9, 0)
                            end

                            if v2.Aura.PlayerAuraMethods["Fling"] then
                                local direction = (thrp.Position - hrp.Position)
                                if direction.Magnitude > 0 then
                                    direction = direction.Unit
                                    thrp.AssemblyLinearVelocity = direction * 1500 + Vector3.new(0, 150, 0)
                                end
                            end

                            if v2.Aura.PlayerAuraMethods["Push"] then
                                local direction = (thrp.Position - hrp.Position)
                                if direction.Magnitude > 0 then
                                    direction = direction.Unit
                                    thrp.AssemblyLinearVelocity = direction * 150 + Vector3.new(0, 10, 0)
                                end
                            end

                            v2.Aura.PlayerAuraRunning[t] = nil
                            v2.Aura.PlayerAuraThreads[t] = nil
                        end)
                    end
                end
            end)
        else
            if v2.Aura.PlayerAuraConn then
                v2.Aura.PlayerAuraConn:Disconnect()
                v2.Aura.PlayerAuraConn = nil
            end

            table.clear(v2.Aura.PlayerAuraThreads)
            table.clear(v2.Aura.PlayerAuraRunning)
        end
    end
})
GrabBoxTabs.ToyAura:AddDropdown("ToyAuraMethods", {
    Text = "Aura Methods",
    Values = {"Noclip", "Void", "Push", "Fling"},
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Aura.ToyAuraMethods = v
    end
})
ToyAura = GrabBoxTabs.ToyAura:AddToggle("ToyAura", {
    Text = "Apply Auras",
    Default = false,
    Callback = function(v)
        v2.Aura.ToyAura = v
        if v then
            v2.Aura.ToyAuraConn = gs.Rs.Heartbeat:Connect(function()
                local char = v1.player.Character or v1.player.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart", true)
                if not hrp then return end
                for folder in pairs(v3.ActiveFolders) do
                    for _, toy in ipairs(folder:GetChildren()) do
                        if not toy:IsA("Model") then continue end
                        if v2.Aura.ToyAuraRunning[toy] then continue end
                        local GrabPart = Function.FindGrabPart(toy)
                        if not GrabPart then continue end
                        local dist = (GrabPart.Position - hrp.Position).Magnitude
                        if dist > v1.MaxGrabDist then continue end
                        v2.Aura.ToyAuraRunning[toy] = true
                        v2.Aura.ToyAuraThreads[toy] = task.spawn(function()
                            if not Function.DoesOwn(toy) then
                                repeat
                                    Function.SnoPart(GrabPart)
                                    dist = (GrabPart.Position - hrp.Position).Magnitude
                                    task.wait(0.03)
                                until Function.DoesOwn(toy)
                                    or dist >= v1.MaxGrabDist
                                    or not GrabPart
                                    or not GrabPart.Parent
                                    or not v2.Aura.ToyAura
                            end

                            if not GrabPart or not GrabPart.Parent then
                                v2.Aura.ToyAuraRunning[toy] = nil
                                v2.Aura.ToyAuraThreads[toy] = nil
                                return
                            end

                            if Function.DoesOwn(toy) and v2.Aura.ToyAuraMethods["Noclip"] then
                                for _, p in ipairs(toy:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        p.CanCollide = false
                                    end
                                end
                                Event.dgl:FireServer(GrabPart)
                            end

                            if Function.DoesOwn(toy) and v2.Aura.ToyAuraMethods["Void"] then
                                workspace.FallenPartsDestroyHeight = -500000
                                GrabPart.CFrame = CFrame.new(0, -49995, 0)
                                task.wait(0.3)
                                workspace.FallenPartsDestroyHeight = v1.FallenHeight
                                Event.dgl:FireServer(GrabPart)
                            end

                            if Function.DoesOwn(toy) and v2.Aura.ToyAuraMethods["Fling"] then
                                local direction = (GrabPart.Position - hrp.Position)
                                if direction.Magnitude > 0 then
                                    direction = direction.Unit
                                    GrabPart.AssemblyLinearVelocity = direction * 1500 + Vector3.new(0, 150, 0)
                                    Event.dgl:FireServer(GrabPart)
                                end
                            end

                            if Function.DoesOwn(toy) and v2.Aura.ToyAuraMethods["Push"] then
                                local direction = (GrabPart.Position - hrp.Position)
                                if direction.Magnitude > 0 then
                                    direction = direction.Unit
                                    GrabPart.AssemblyLinearVelocity = direction * 150 + Vector3.new(0, 10, 0)
                                    Event.dgl:FireServer(GrabPart)
                                end
                            end

                            v2.Aura.ToyAuraRunning[toy] = nil
                            v2.Aura.ToyAuraThreads[toy] = nil
                        end)
                    end
                end
            end)
        else
            if v2.Aura.ToyAuraConn then
                v2.Aura.ToyAuraConn:Disconnect()
                v2.Aura.ToyAuraConn = nil
            end

            table.clear(v2.Aura.ToyAuraThreads)
            table.clear(v2.Aura.ToyAuraRunning)
        end
    end
})
GrabBoxTabs.GrabSettings:AddDivider("Void")
GrabBoxTabs.GrabSettings:AddDropdown("GrabVoidMethods", {
    Text = "Void Methods",
    Values = {"Players", "Objects", "Both"},
    Default = "Players",
    Multi = false,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Grab.GrabVoidMethod = v
    end
})
GrabBoxTabs.GrabSettings:AddDivider("Teleport")
GrabBoxTabs.GrabSettings:AddDropdown("GrabTeleportMethods", {
    Text = "Teleport Methods",
    Values = {"Players", "Objects", "Both"},
    Default = "Players",
    Multi = false,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Grab.TeleportMethod = v
    end
})
GrabBoxTabs.GrabSettings:AddDropdown("GrabTeleportLocations", {
    Text = "Teleport Locations",
    Values = {"Chinese Roof", "Small Cave", "Big Cave", "Island Cave", "Goon Cave"},
    Default = "Chinese Roof",
    Multi = false,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Grab.TeleportLocation = v
    end
})
GrabBoxTabs.PlayerAuraSettings:AddDivider("Teleport")
GrabBoxTabs.PlayerAuraSettings:AddDropdown("AuraTeleportLocations", {
    Text = "Teleport Locations",
    Values = {"Chinese Roof", "Small Cave", "Big Cave", "Island Cave", "Goon Cave"},
    Default = "Chinese Roof",
    Multi = false,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Aura.AuraTeleportLocation = v
    end
})
GrabBoxTabs.Line:AddDivider("Strength")
StrengthSlider = GrabBoxTabs.Line:AddSlider("StrengthSlider", {
    Text = "Strength",
    Default = 400,
    Min = 400,
    Max = 10000,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Grab.Strength = v
    end
})
ToggleStrength = GrabBoxTabs.Line:AddToggle("ToggleStrength", {
	Text = "Toggle Strength",
	Default = false,
	Callback = function(v)
		v2.Grab.ToggleStrength = v

		if v then
			v2.Grab.GpStrengthConn = workspace.ChildAdded:Connect(function(GParts)
				if not v2.Grab.ToggleStrength then return end
				if GParts.Name ~= "GrabParts" then return end
				local grabPart = GParts:WaitForChild("GrabPart", 1)
				if not grabPart then return end
				local weld = grabPart:WaitForChild("WeldConstraint", 1)
				if not weld or not weld.Part1 or not weld.Part1:IsA("BasePart") then return end
				local grabbed = weld.Part1
				local velocity = Instance.new("BodyVelocity")
				velocity.Name = "kaykaykay"
				velocity.MaxForce = Vector3.zero
				velocity.Velocity = Vector3.zero
				velocity.Parent = grabbed
				local parentConn
				parentConn = GParts:GetPropertyChangedSignal("Parent"):Connect(function()
					if GParts.Parent ~= nil then return end
					if gs.Uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
						and v2.Grab.ToggleStrength then
						if velocity and velocity.Parent then
							velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							velocity.Velocity =
								v1.camera.CFrame.LookVector * v2.Grab.Strength
							gs.Deb:AddItem(velocity, 0.35)
						end
					elseif velocity and velocity.Parent then
						velocity:Destroy()
					end
					if parentConn then
						parentConn:Disconnect()
						parentConn = nil
					end
				end)
			end)
		else
			if v2.Grab.GpStrengthConn then
				v2.Grab.GpStrengthConn:Disconnect()
				v2.Grab.GpStrengthConn = nil
			end
		end
	end
})
GrabBoxTabs.Line:AddDivider("Line Extend")
GrabBoxTabs.Line:AddSlider("LineExtendSlider", {
    Text = "Line extend amount",
    Default = 3,
    Min = 3,
    Max = 25,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Line.LineExtendV = v
    end
})
FurtherExtend = GrabBoxTabs.Line:AddToggle("FurtherExtend", {
    Text = "Further Extend",
    Default = false,
    Callback = function(v)
        v2.Line.LineExtend = v
        if v then
            if v2.Grab.GrabPartConn then
                v2.Grab.GrabPartConn:Disconnect()
            end

            if v2.Line.ExtendLineConn then
                v2.Line.ExtendLineConn:Disconnect()
            end

            v2.Line.ExtendLineConn  = gs.Uis.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseWheel then
                    local maxDistance = v2.Line.LineExtendV * 15
                    if input.Position.Z > 0 then
                        v2.Line.LineDistv = math.min(v2.Line.LineDistv + v2.Line.LineExtendV, maxDistance)
                    else
                        v2.Line.LineDistv = math.max(11, v2.Line.LineDistv - v2.Line.LineExtendV)
                    end
                end
            end)

            v2.Grab.GrabPartConn = workspace.ChildAdded:Connect(function(gp)
                if gp:IsA("Model") and gp.Name == "GrabParts" then
                    local DragPart = gp:WaitForChild("DragPart", 5)

                    if not DragPart then
                        return
                    end

                    local Clone = DragPart:Clone()
                    Clone.Name = "DragPart1"
                    Clone.Parent = gp

                    local AlignPosition = Clone:FindFirstChild("AlignPosition")
                    local DragAttach = Clone:FindFirstChild("DragAttach")

                    if AlignPosition and DragAttach then
                        AlignPosition.Attachment1 = DragAttach
                    end

                    local AlignOrientation = Clone:FindFirstChild("AlignOrientation")
                    if AlignOrientation then
                        AlignOrientation.Enabled = false
                    end

                    local OriginalAlign = DragPart:FindFirstChild("AlignPosition")
                    if OriginalAlign then
                        OriginalAlign.Enabled = false
                    end

                    v2.Line.LineDistv = math.max(
                        11,
                        (Clone.Position - v1.camera.CFrame.Position).Magnitude
                    )

                    task.spawn(function()
                        while Clone.Parent and gp.Parent do
                            local maxDistance = v2.Line.LineExtendV * 15
                            v2.Line.LineDistv = math.clamp(v2.Line.LineDistv, 11, maxDistance)
                            Clone.Position = v1.camera.CFrame.Position + v1.camera.CFrame.LookVector * v2.Line.LineDistv
                            task.wait()
                        end
                    end)
                end
            end)
        else
            if v2.Grab.GrabPartConn then
                v2.Grab.GrabPartConn:Disconnect()
                v2.Grab.GrabPartConn = nil
            end

            if v2.Line.ExtendLineConn  then
                v2.Line.ExtendLineConn:Disconnect()
                v2.Line.ExtendLineConn  = nil
            end

            v2.Line.LineDistv = 11
        end
    end
})
GrabBoxTabs.Line:AddDivider("Misc")
InvisLine = GrabBoxTabs.Line:AddToggle("InvisLine", {
    Text = "Invisible Line",
    Default = false,
    Callback = function(v)
        if v then
            v2.Line.InvisLineConn = workspace.ChildAdded:Connect(function(gp)
                if gp.Name == "GrabParts" then
                    Event.dgl:FireServer(gp)
                end
            end)
        else
            if v2.Line.InvisLineConn then
                v2.Line.InvisLineConn:Disconnect()
                v2.Line.InvisLineConn = nil
            end
        end
    end
})
GrabBoxTabs.Lag:AddDivider("Lag")
LineLagStrength = GrabBoxTabs.Lag:AddSlider("LineLagStrength", {
    Text = "Strength",
    Default = 11,
    Min = 1,
    Max = 11,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Line.LineLagStrength = v
    end
})
LineLag = GrabBoxTabs.Lag:AddToggle("LineLag", {
    Text = "Line Lag",
    Default = false,
    Callback = function(v)
        v2.Line.LineLag = v
        if v2.Line.LineLagThread then
            task.cancel(v2.Line.LineLagThread)
            v2.Line.LineLagThread = nil
        end
        if not v2.Line.LineLag then return end
        v2.Line.LineLagThread = task.spawn(function()
            while v2.Line.LineLag do
                local spawnLocation = Workspace:FindFirstChild("SpawnLocation") 
                    or Workspace:FindFirstChild("Spawn") 
                    or (player.Character and player.Character:FindFirstChild("HumanoidRootPart"))

                if spawnLocation then
                    local randomX = math.random(-9e9, 9e9)
                    local randomZ = math.random(-9e9, 9e9)
                    Event.cgl:FireServer(spawnLocation, CFrame.new(randomX, 0, randomZ))
                end
                task.wait((11 - v2.Line.LineLagStrength) / 11)
            end
        end)
    end
})
GrabBoxTabs.Lag:AddDivider("Misc")
CrazyLine = GrabBoxTabs.Lag:AddToggle("CrazyLine", {
    Text = "Crazy Line",
    Default = false,
    Callback = function(v)
        v2.Line.CrazyLine = v
        if not v2.Line.CrazyLine then Event.dgl:FireServer() end
        task.spawn(function()
            while v2.Line.CrazyLine do
                for _, plr in ipairs(gs.Players:GetPlayers()) do
                    if plr ~= player then
                        local torso = plr.Character and plr.Character:FindFirstChild("Torso")
                        if torso then
                            Event.cgl:FireServer(torso, CFrame.new(0.12640380859375, -0.9606337547302246, -0.5000009536743164, 0.9985212683677673, 0, -0.05436277016997337, -6.4805472099749295e-9, 1, -1.1903301100346653e-7, 0.05436277016997337, 5.960464477539063e-8, 0.9985212683677673))
                            gs.Rs.Heartbeat:Wait()
                        end
                    end
                end
            end
        end)
    end
})
GrabBoxTabs.Packet:AddDivider("Settings")
GrabBoxTabs.Packet:AddSlider("PacketAmount", {
    Text = "Packet amount: ",
    Default = 3,
    Min = 0.1,
    Max = 18,
    Rounding = 2,
    Suffix = " MBs",
    Compact = true,
    Callback = function(Value)
        v2.Line.PacketAmount = Value
    end
})
GrabBoxTabs.Packet:AddSlider("PacketDelay", {
    Text = "Delay: ",
    Default = 0.45,
    Min = 0.15,
    Max = 2,
    Rounding = 2,
    Suffix = " Seconds",
    Compact = true,
    Callback = function(v)
        v2.Line.PacketDelay = v
    end
})
GrabBoxTabs.Packet:AddDivider("Packets")
GrabBoxTabs.Packet:AddButton({
    Text = "Send One Packet",
    Func = function()
        pcall(function()
            local bytes = math.floor(v2.Line.PacketAmount * 1024 * 1024)
            local Pstring = string.rep("K", bytes)
            Event.egl:FireServer(Pstring)
        end)
    end
})
PacketLag = GrabBoxTabs.Packet:AddToggle("PacketLag", {
    Text = "Send Packets",
    Default = false,
    Callback = function(v)
        v2.Line.PacketLag = v
        if v2.Line.PacketLagThread then
            task.cancel(v2.Line.PacketLagThread)
            v2.Line.PacketLagThread = nil
        end
        if not v2.Line.PacketLag then return end
        v2.Line.PacketLagThread = task.spawn(function()
            while v2.Line.PacketLag do
                task.wait(v2.Line.PacketDelay)
                if not v2.Line.PacketLag then break end
                pcall(function()
                    local bytes = math.floor(v2.Line.PacketAmount * 1024 * 1024)
                    local Pstring = string.rep("K", bytes)
                    Event.egl:FireServer(Pstring)
                end)
            end
        end)
    end
})
GrabBoxTabs.Packet:AddDivider("Misc")

-------------------------->> [Defense] <<--------------------------
local DefenseBoxTabs = {
    Defense = GP.Defense:AddTab("Defense", "shield"),
    Config = GP.Defense:AddTab("Config", "settings"),
}
DefenseBoxTabs.Defense:AddDivider("Protection")
AntiGrab = DefenseBoxTabs.Defense:AddToggle("AntiGrab", {
    Text = "Anti-Grab",
    Default = false,
	Callback = function(v)
        if v then
            v2.Defense.AntiGrabConn = gs.Rs.Heartbeat:Connect(function()
                local char = v1.player.Character
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if not head then return end
                if head:FindFirstChild("PartOwner") then
                    Function.LockChar(char)
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.Anchored = true
                    Event.Struggle:FireServer()
                    Event.Ragdoll:FireServer(hrp, 0)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hum.PlatformStand = true
                    head:FindFirstChild("PartOwner"):Destroy()
                end
                if v1.player.IsHeld.Value and hrp then
                    Function.StartClone("AntiGrab")
                    hrp.Anchored = true
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero
                else
                    if hrp then
                        hrp.Anchored = false
                        hum.PlatformStand = false
                        Function.StopClone("AntiGrab")
                        Function.UnlockChar(char)
                    end
                end
            end)
        else
            if v2.Defense.AntiGrabConn then
                v2.Defense.AntiGrabConn:Disconnect()
                v2.Defense.AntiGrabConn = nil
            end
            Function.StopClone("AntiGrab")
		end
	end
})
function TurnOffGucci()
    for i = 1, 30 do
        local hum = v1.player.Character
            and v1.player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Sit = true
            task.wait()
            hum.Sit = false
        end
    end
end
AntiGrabGucci = DefenseBoxTabs.Defense:AddToggle("AntiGrabGucci", {
    Text = "Anti-Grab Gucci",
    Default = false,
	Callback = function(v)
        v2.Defense.AntiGrabGucci = v
        if v then
            while v2.Defense.AntiGrabGucci do
                if v2.Defense.AntiBananaBusy or v1.player.IsHeld.Value then task.wait(); continue end
                local char = v1.player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    local GucciToy = v1.inv:FindFirstChild("Gucci")
                    if not GucciToy then
                        v2.Defense.GucciCompleted = false
                        v2.Defense.HadGucci = false
                    end
                    if not v2.Defense.GucciCompleted and v1.CanSpawn.Value then
                        while not GucciToy do
                            if v2.Defense.GucciType == "Tractor" or "Blobman" then
                                local OldToys = {}
                                for _, t in ipairs(v1.inv:GetChildren()) do
                                    OldToys[t] = true
                                end
                
                                task.spawn(function()
                                    pcall(function()
                                        Event.SpawnToy:InvokeServer(v2.GucciMatch[v2.Defense.GucciType], 
                                        hrp.CFrame * CFrame.new(0, 2e+38, 0), 
                                        Vector3.zero)
                                    end)
                                end)

                                repeat
                                    for _, t in ipairs(v1.inv:GetChildren()) do
                                        if not OldToys[t] and t.Name == v2.GucciMatch[v2.Defense.GucciType] then
                                            GucciToy = t
                                            break
                                        end
                                    end
                                    task.wait()
                                until GucciToy or not v2.Defense.AntiGrabGucci
                            end

                            if GucciToy.Parent and GucciToy.Parent == v1.inv then GucciToy.Name = "Gucci" end
                            v2.Defense.CurrentGucci = GucciToy

                            task.wait()
                        end

                        if GucciToy then
                            v2.Defense.GucciCompleted = false
                            local seat = GucciToy:WaitForChild("VehicleSeat", 2)
                            Function.StartClone("AntiGrabGucci")
                            gs.Rs.RenderStepped:Wait()
                            seat:Sit(hum)
                            if v2.Defense.AntiBananaBusy or v1.player.IsHeld.Value then
                                if v2.Defense.CurrentGucci then
                                    gs.Rs.RenderStepped:Wait()
                                    Function.StopClone("AntiGrabGucci")
                                    Event.DestroyToy:FireServer(v2.Defense.CurrentGucci)
                                end
                            end
                            if seat and not seat.Occupant then
                                repeat
                                    if not hum or not hum.Parent or hum.Health <= 0 or not seat or not seat.Parent then
                                        break
                                    end
                                    pcall(function()
                                        seat:Sit(hum)
                                        Event.Ragdoll:FireServer(hrp, 0)
                                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                    end)
                                    task.wait()
                                until hum.SeatPart ~= seat and seat.Occupant == hum
                            else
                                local thum = seat.Occupant
                                if not thum or thum == hum then return end
                                Function.Notify("Display: "..thum.Parent.DisplayName .." | Username: ".. thum.Parent.Name .." | interrupted your gucci", 5)
                                Event.DestroyToy:FireServer(v2.Defense.CurrentGucci)
                            end
                            v2.Defense.GucciCompleted = true
                            v2.Defense.HadGucci = true
                            task.spawn(function()
                                hum:ChangeState(Enum.HumanoidStateType.Running)
                                gs.Rs.RenderStepped:Wait()
                                Function.StopClone("AntiGrabGucci")
                                if v2.Defense.GucciType == "Blobman" then
                                    v2.GrabScript.Disabled = true
                                    if char:WaitForChild("LocalCreatureControl", 2) then
                                        char:FindFirstChild("LocalCreatureControl"):Destroy()
                                    end
                                    if workspace:FindFirstChild("GrabParts") then
                                        workspace:FindFirstChild("GrabParts"):Destroy()
                                    end
                                    v2.GrabScript.Enabled = true
                                    if v2.Defense.GucciSeatWatch then
                                        v2.Defense.GucciSeatWatch:Disconnect()
                                        v2.Defense.GucciSeatWatch = nil
                                    end
                                    if v2.Defense.GucciJumpConn then
                                        v2.Defense.GucciJumpConn:Disconnect()
                                        v2.Defense.GucciJumpConn = nil
                                    end
                                    v2.GrabScript.Enabled = true
                                    v2.Defense.GucciJumpConn = gs.Uis.JumpRequest:Connect(function()
                                        if hum:GetState() ~= Enum.HumanoidStateType.Jumping
                                        and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                                        end
                                    end)
                                end
                                v2.Defense.GucciSeatWatch = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
                                    local thum = seat.Occupant
                                    if not thum or thum == hum then return end
                                    Function.Notify("Display: "..thum.Parent.DisplayName .." | Username: ".. thum.Parent.Name .." | sat on your Gucci", 5)
                                    v2.Defense.GucciSeatWatch:Disconnect()
                                    v2.Defense.GucciSeatWatch = nil
                                    TurnOffGucci()
                                    if v2.Defense.CurrentGucci then
                                        Event.DestroyToy:FireServer(v2.Defense.CurrentGucci)
                                    end
                                end)
                            end)
                            local GucciDeathWatch
                            GucciDeathWatch = hum.Died:Connect(function()
                                v2.Defense.GucciCompleted = false
                                v2.Defense.HadGucci = false
                                if GucciDeathWatch then
                                    GucciDeathWatch:Disconnect()
                                    GucciDeathWatch = nil
                                end
                                if v2.Defense.GucciSeatWatch then
                                    v2.Defense.GucciSeatWatch:Disconnect()
                                    v2.Defense.GucciSeatWatch = nil
                                end
                                if v2.Defense.GucciJumpConn then
                                    v2.Defense.GucciJumpConn:Disconnect()
                                    v2.Defense.GucciJumpConn = nil
                                end
                            end)
                        end
                    end
                end

                task.wait(0.05)
            end
        else
            if v2.Defense.GucciSeatWatch then
                v2.Defense.GucciSeatWatch:Disconnect()
                v2.Defense.GucciSeatWatch = nil
            end
            if v2.Defense.GucciCompleted then
                TurnOffGucci()
                v2.Defense.HadGucci = false
                v2.Defense.GucciCompleted = false
            end
		end
	end
})
AntiBlobman = DefenseBoxTabs.Defense:AddToggle("AntiBlobman", {
    Text = "Anti-Blobman",
    Default = false,
	Callback = function(v)
		v2.Defense.AntiBlobman = v
		if v then
			task.spawn(function()
				while v2.Defense.AntiBlobman do
					local char = v1.player.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if char and hrp then
						local tp = char:FindFirstChild("TruePosition") or Instance.new("Part")
						tp.Name = "TruePosition"
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
														Event.Struggle:FireServer()
													end
												end)
											end
										end
									end
								end
								
								for _, plr in pairs(gs.Players:GetPlayers()) do
									local toys = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
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
														Event.Struggle:FireServer()
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
		else
			local char = v1.player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local tp = char and char:FindFirstChild("TruePosition")
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
AntiExplosion = DefenseBoxTabs.Defense:AddToggle("AntiExplosion", {
    Text = "Anti-Explosion",
    Default = false,
	Callback = function(v)
		v2.Defense.AntiExplode = v
		if v then
            v2.Defense.ExplodeWatchConn = workspace.ChildAdded:Connect(function(model)
                if not v2.Defense.AntiExplode or v2.Defense.AntiExplodeBusy then return end
                if not model:IsA("BasePart") then return end

                local char = v1.player.Character
                local human = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local head = char and char:FindFirstChild("Head")

                if not char or not human or not hrp or not head then return end
                if (model.Position - hrp.Position).Magnitude > 15 then return end

                v2.Defense.AntiExplodeBusy = true

                hrp.Anchored = true
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero

                if not v2.Defense.AntiGrabGucci then
                    Function.StartClone("AntiExplode")
                    local t = 0

                    repeat
                        head = char:FindFirstChild("Head")
                        local ball = head and head:FindFirstChildWhichIsA("BallSocketConstraint", true)

                        if ball and ball.Enabled then
                            break
                        end

                        t += task.wait()
                    until not v2.Defense.AntiExplode or t > 1.5
                end

                hrp.Anchored = false
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                v2.Defense.AntiExplodeBusy = false
                Function.StopClone("AntiExplode")
            end)
        else
            if v2.Defense.ExplodeWatchConn then
                v2.Defense.ExplodeWatchConn:Disconnect()
                v2.Defense.ExplodeWatchConn = nil
            end
            v2.Defense.AntiExplodeBusy = false
        end
	end
})
AntiBanana = DefenseBoxTabs.Defense:AddToggle("AntiBanana", {
    Text = "Anti-Banana",
    Default = false,
	Callback = function(v)
		task.spawn(function()
			v2.Defense.AntiBanana = v
			local char = v1.player.Character
			local human = char and char:FindFirstChild("Humanoid")
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if v2.Defense.AntiGrabGucci and v then
                AntiGrabGucci:SetValue(false)
                task.wait(0.03)
                AntiGrabGucci:SetValue(true)
            end
			if v and not v2.Defense.AntiBananaBusy then
				repeat
					v2.Defense.AntiBananaBusy = true
					if char and human and hrp and (char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")) then
						Function.StartClone("AntiBanana")
						local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                        local time = 0.2 * math.max(ping, 25) / 25
                        Event.Ragdoll:FireServer(hrp, time)
						task.wait(0.2)
						for _, name in ipairs({"Right Leg", "Left Leg"}) do
							local leg = char:FindFirstChild(name)
							if leg then
								leg.CFrame = CFrame.new(leg.Position.X, -100000, leg.Position.Z)
							end
						end
						task.wait(0.15)
						hrp.Anchored = true
						hrp.AssemblyLinearVelocity = Vector3.zero
						hrp.AssemblyAngularVelocity = Vector3.zero
						task.wait(0.05)
						task.wait(); task.wait()
                        Function.StopClone("AntiBanana")
						Event.sno:FireServer(hrp, hrp.CFrame)
                        hrp.Anchored = false
					end
					task.wait(0.08)
					local Legs = char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")
					v2.Defense.AntiBananaBusy = false
				until not Legs or not char or not v2.Defense.AntiBanana

                if not v2.Defense.AntiBananaConn then
                    v2.Defense.AntiBananaConn = gs.Rs.Heartbeat:Connect(function()
                        local char = v1.player.Character
                        local human = char and char:FindFirstChild("Humanoid")
                        if not char or not human then return end
                        local Legs = char:FindFirstChild("Left Leg") or char:FindFirstChild("Right Leg")
                        if Legs then
                            human.HipHeight = 0
                            if Legs then
                                v2.Defense.AntiBananaConn:Disconnect()
                                v2.Defense.AntiBananaConn = nil
                            end
                            return
                        end
                        
                        local stand = v1.player.PlayerGui:FindFirstChild("ControlsGui")
                            and v1.player.PlayerGui.ControlsGui:FindFirstChild("PCFrame")
                            and v1.player.PlayerGui.ControlsGui.PCFrame:FindFirstChild("Stand")
                        
                        local newHeight = stand and stand.Visible == false and 2 or 0
                        human.HipHeight = newHeight
                    end)
                    repeat
                        task.wait()
                    until not Function.IsRagdolled(char)
                    task.wait(0.05)
                    if v2.Defense.HadGucci then
                        AntiGrabGucci:SetValue(true)
                    end
                end
            else
                v2.Defense.AntiBanana = false
                v2.Defense.AntiBananaBusy = false
			end
		end)
	end
})
v1.player.CharacterAdded:Connect(function(char)
    if v2.Defense.AntiBanana then
        char:WaitForChild("HumanoidRootPart", 5)
        AntiBanana:SetValue(false)
        task.wait()
        AntiBanana:SetValue(true)
    end
end)
local AntiInput
AntiInput = DefenseBoxTabs.Defense:AddToggle("AntiInput", {
    Text = "Anti-Input",
    Default = false,
	Callback = function(v)
		v2.Defense.AntiInput = v
        if v then
            if not v2.Defense.AntiInputToy then Function.Notify("No item selected!", 3); AntiInput:SetValue(false); return end
            while v2.Defense.AntiInput do
                local char = v1.player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local AntiInputToy = v1.inv:FindFirstChild("AntiInput")
                while not AntiInputToy and v2.Defense.AntiInput do
                    if not AntiInputToy and v1.CanSpawn.Value then
                        local OldToys = {}
                        for _, t in ipairs(v1.inv:GetChildren()) do
                            OldToys[t] = true
                        end
                        task.spawn(function()
                            pcall(function()
                                Event.SpawnToy:InvokeServer(v2.Defense.AntiInputToy, hrp.CFrame * CFrame.new(0, 9e9, 17), Vector3.zero)
                            end)
                        end)
                        gs.Rs.RenderStepped:Wait()
                        repeat
                            for _, t in ipairs(v1.inv:GetChildren()) do
                                if not OldToys[t] and t.Name == v2.Defense.AntiInputToy then
                                    AntiInputToy = t
                                    break
                                end
                            end
                            gs.Rs.RenderStepped:Wait()
                        until AntiInputToy or not v2.Defense.AntiInput
                        v2.Defense.CurrentAntiInputToy = AntiInputToy
                        gs.Rs.RenderStepped:Wait()
                    end
                end

                if AntiInputToy then
                    AntiInputToy.Name = "AntiInput"

                    local hp = AntiInputToy and AntiInputToy:WaitForChild("HoldPart")
                    local hold = hp:WaitForChild("HoldItemRemoteFunction", 3)
                    local drop = hp:WaitForChild("DropItemRemoteFunction", 3)

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

                    while AntiInputToy and AntiInputToy.Parent and v2.Defense.AntiInput do
                        task.spawn(function() 
                            if not heldByOther(AntiInputToy, char) and not heldByMe(AntiInputToy, char) then
                                pcall(function()
                                    hold:InvokeServer(AntiInputToy, char)
                                end)
                            end
                            if heldByOther(AntiInputToy, char) and v2.Defense.CurrentAntiInputToy then
                                Event.DestroyToy:FireServer(v2.Defense.CurrentAntiInputToy)
                            end
                            if heldByMe(AntiInputToy, char) then
                                task.spawn(function() 
                                    pcall(function() 
                                        drop:InvokeServer(AntiInputToy, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.zero) 
                                    end)
                                end)
                            end
                        end)
                        gs.Rs.RenderStepped:Wait()
                    end
                end

                task.wait(0.03)
            end
        else
            if v2.Defense.CurrentAntiInputToy then
                Event.DestroyToy:FireServer(v2.Defense.CurrentAntiInputToy)
            else
                for _, t in ipairs(v1.inv:GetChildren()) do
                    if t.Name == v2.Defense.AntiInputToy then
                        Event.DestroyToy:FireServer(t)
                    end
                end
            end
        end
	end
})
DefenseBoxTabs.Defense:AddDivider("Effects")
AntiBurn = DefenseBoxTabs.Defense:AddToggle("AntiBurn", {
    Text = "Anti-Burn",
    Default = false,
    Callback = function(v)
        local AntiFirePart = game.Workspace.Map.FactoryIsland.PoisonContainer.ExtinguishPart
        local AfpHome = AntiFirePart.CFrame
        local AfpOldSize = AntiFirePart.Size
        if v then
            v2.Defense.AntiBurnConn = gs.Rs.Heartbeat:Connect(function()
                local char = v1.player.Character or v1.player.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local firePart = hrp:FindFirstChild("FirePlayerPart")
                if not firePart then
                    AntiFirePart.CFrame = AfpHome
                    AntiFirePart.Size = AfpOldSize
                    return
                end
                local canBurn = firePart:FindFirstChild("CanBurn")
                if not canBurn then
                    AntiFirePart.CFrame = AfpHome
                    AntiFirePart.Size = AfpOldSize
                    return
                end
                if canBurn.Value then
                    AntiFirePart.Size = Vector3.new(0.1, 0.1, 0.1)
                    AntiFirePart.CFrame = hrp.CFrame
                else
                    AntiFirePart.CFrame = AfpHome
                    AntiFirePart.Size = AfpOldSize
                end
            end)
        else
            AntiFirePart.CFrame = AfpHome
            AntiFirePart.Size = AfpOldSize
            if v2.Defense.AntiBurnConn then
                v2.Defense.AntiBurnConn:Disconnect()
                v2.Defense.AntiBurnConn = nil
            end
        end
    end
})
AntiPoison = DefenseBoxTabs.Defense:AddToggle("AntiPoison", {
    Text = "Anti-Poison",
    Default = false,
	Callback = function(v)
		if v then
			for _, hole in pairs(v2.MapPoint.Hole:GetChildren()) do
				if hole.Name == "PoisonBigHole" or hole.Name == "PoisonSmallHole" then
					for _, part in pairs(hole:GetDescendants()) do
						if (part.Name == "PoisonHurtPart" or part.Name == "PaintPlayerPart") then
							if not v2.Defense.SavedPoisonCF[part] then
								v2.Defense.SavedPoisonCF[part] = part.CFrame
								local fake = part:Clone()
								fake.Parent = v2.MapPoint.Island
								table.insert(v2.Defense.PoisonClones, fake)
								part.CFrame = part.CFrame + Vector3.new(0, 1e9, 1e9)
							end
						end
					end
				end
			end
			for _, PoisonHolder in pairs(v2.MapPoint.Island:GetChildren()) do
				if PoisonHolder.Name == "PoisonContainer" then
					for _, part in pairs(PoisonHolder:GetDescendants()) do
						if (part.Name == "PoisonHurtPart" or part.Name == "PaintPlayerPart") then
							if not v2.Defense.SavedPoisonCF[part] then
								v2.Defense.SavedPoisonCF[part] = part.CFrame
								local fake = part:Clone()
								fake.Parent = v2.MapPoint.Island
								table.insert(v2.Defense.PoisonClones, fake)
								part.CFrame = part.CFrame + Vector3.new(0, 1e9, 1e9)
							end
						end
					end
				end
			end
		else
			for part, cf in pairs(v2.Defense.SavedPoisonCF) do
				if part and part.Parent then
					part.CFrame = cf
				end
			end
			for _, clone in ipairs(v2.Defense.PoisonClones) do
				if clone and clone.Parent then
					clone:Destroy()
				end
			end
			table.clear(v2.Defense.SavedPoisonCF)
			table.clear(v2.Defense.PoisonClones)
		end
	end
})
AntiSticky = DefenseBoxTabs.Defense:AddToggle("AntiSticky", {
    Text = "Anti-Sticky",
    Default = false,
    Callback = function(v)
        if v then
            v2.Defense.AntiStickyConn = gs.Rs.Heartbeat:Connect(function()
                local char = v1.player.Character or v1.player.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart", true)
                if not hrp then return end
                for _, plr in ipairs(gs.Players:GetPlayers()) do
                    local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    if not ToyFolder then continue end
                    for _, toy in ipairs(ToyFolder:GetChildren()) do
                        if not toy:IsA("Model") then continue end
                        if v2.Defense.AntiStickyRunning[toy] then continue end
                        if toy:FindFirstChild("StickyPart") then
                            if toy.Name == "AntiKick" then continue end
                            local GrabPart = toy:FindFirstChild("SoundPart", true)
                            if not GrabPart then continue end
                            local dist = (GrabPart.Position - hrp.Position).Magnitude
                            if dist > v1.MaxGrabDist then continue end
                            local Sticky = toy:FindFirstChild("StickyPart")
                            if not Sticky and Sticky.StickyWeld.Part1 then continue end
                            if Sticky.StickyWeld.Part1 and Sticky.StickyWeld.Part1:IsDescendantOf(char) then
                                v2.Defense.AntiStickyRunning[toy] = true
                                v2.Defense.AntiStickyThreads[toy] = task.spawn(function()
                                    if not Function.DoesOwn(toy) then
                                        repeat
                                            Function.SnoPart(GrabPart)
                                            dist = (GrabPart.Position - hrp.Position).Magnitude
                                            task.wait(0.03)
                                        until Function.DoesOwn(toy)
                                            or dist >= v1.MaxGrabDist
                                            or not GrabPart
                                            or not GrabPart.Parent
                                            or not v2.Defense.AntiSticky
                                    end
                                    Event.dgl:FireServer(GrabPart)
                                    if not GrabPart or not GrabPart.Parent then
                                        v2.Defense.AntiStickyRunning[toy] = nil
                                        v2.Defense.AntiStickyThreads[toy] = nil
                                        return
                                    end
                                    v2.Defense.AntiStickyRunning[toy] = nil
                                    v2.Defense.AntiStickyThreads[toy] = nil
                                end)
                            end
                        end
                    end
                end
            end)
        else
            if v2.Defense.AntiStickyConn then
                v2.Defense.AntiStickyConn:Disconnect()
                v2.Defense.AntiStickyConn = nil
            end

            table.clear(v2.Defense.AntiStickyThreads)
            table.clear(v2.Defense.AntiStickyRunning)
        end
    end
})
AntiPaint = DefenseBoxTabs.Defense:AddToggle("AntiPaint", {
    Text = "Anti-Paint",
    Default = false,
    Callback = function(v)
        v2.Defense.AntiPaint = v
        if v then
            while v2.Defense.AntiPaint do
                local char = v1.player.Character or v1.player.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart", true)
                if not hrp then continue end
                for _, plr in ipairs(gs.Players:GetPlayers()) do
                    local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    if not ToyFolder then continue end
                    for _, toy in ipairs(ToyFolder:GetChildren()) do
                        if toy:IsA("Model") and toy.Name == "BucketPaint" then
                            for _, p in ipairs(toy:GetChildren()) do
                                if p:IsA("BasePart") and p.Name == "PaintPlayerPart" then
                                    v2.Defense.AntiPaintBuckets[p] = toy
                                    p.Parent = nil
                                end
                            end
                        end
                    end
                end
                task.wait(0.25)
            end
        else
            for _, plr in ipairs(gs.Players:GetPlayers()) do
                local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                if not ToyFolder then continue end
                for _, toy in ipairs(ToyFolder:GetChildren()) do
                    if toy:IsA("Model") and toy.Name == "BucketPaint" then
                        for p, Parent in pairs(v2.Defense.AntiPaintBuckets) do
                            if p and Parent == toy then
                                p.Parent = toy
                                v2.Defense.AntiPaintBuckets[p] = nil
                            end
                        end
                    end
                end
            end
        end
    end
})
DefenseBoxTabs.Defense:AddDivider("Anti-Kick")
BreakPCLDToggle = DefenseBoxTabs.Defense:AddToggle("BreakPCLDToggle", {
	Text = "Break PCLD",
	Default = false,
	Callback = function(v)
		if not v and v2.Defense.PCLDWaiting then
            Function.Notify("Removing PCLD", 2.8)
            task.spawn(function()
                local char = v1.player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid", true)
                if not hum or hum.Health <= 0 then
                    char = v1.player.CharacterAdded:Wait()
                    hum = char:WaitForChild("Humanoid")
                end
                hum:ChangeState(Enum.HumanoidStateType.Dead)
            end)
        end
		v2.Defense.AutoBreakPCLD = v
		if not v then
			v2.Defense.PCLDWaiting = false
			v2.Defense.PCLDProcessing = false
			if v2.Defense.PCLDDeathConn then
				v2.Defense.PCLDDeathConn:Disconnect()
				v2.Defense.PCLDDeathConn = nil
			end
			return
		end
		v2.Defense.PCLDProcessing = true
		v2.Defense.PCLDWaiting = false
		local hum = v1.player.Character and v1.player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Dead)
		end
		v2.Defense.CharAddedConn = v1.player.CharacterAdded:Connect(function(char)
			local hum = char:WaitForChild("Humanoid", 1)
			if not v2.Defense.AutoBreakPCLD then
				v2.Defense.PCLDProcessing = false
				v2.Defense.CharAddedConn:Disconnect()
				return
			end
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Dead)
			end
			v2.Defense.PCLDProcessing = false
			v2.Defense.PCLDWaiting = true
			Function.Notify("Done!", 2.8)
			v2.Defense.CharAddedConn:Disconnect()
		end)

		Function.Notify("Breaking PCLD", 2.8)
	end
})
AutoReset = DefenseBoxTabs.Defense:AddToggle("AutoReset", {
    Text = "Auto-Reset",
    Default = true,
    Callback = function(v)
        if v then
            v2.Defense.AutoResetConn = gs.Rep.GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(message)
                if message == "Flying" then
                    Function.Notify("Reset you due to kick warning.", 4)
                    local human = v1.player.Character:FindFirstChildOfClass("Humanoid")
                    if human then task.wait(); human:ChangeState(Enum.HumanoidStateType.Dead) end
                end
            end)
        else
            if v2.Defense.AutoResetConn then
                v2.Defense.AutoResetConn:Disconnect()
                v2.Defense.AutoResetConn = nil
            end
        end
    end
})
AntiKick = DefenseBoxTabs.Defense:AddToggle("AntiKick", {
    Text = "Anti-Kick",
    Default = false,
    Callback = function(v)
        v2.Defense.AntiKick = v
        if v2.Defense.AntiKickThread then
            task.cancel(v2.Defense.AntiKickThread)
            v2.Defense.AntiKickThread = nil
        end
        local function clearKunai()
            if v2.Defense.CurrentAntiKick then
                pcall(function()
                    Event.DestroyToy:FireServer(v2.Defense.CurrentAntiKick)
                end)
            else
                for _, k in pairs(v1.inv:GetChildren()) do
                    if k.Name == "AntiKick" or k.Name == "NinjaShuriken" then
                        pcall(function()
                            Event.DestroyToy:FireServer(k)
                        end)
                    end
                end
            end
        end
        if not v then clearKunai(); return end
        v2.Defense.AntiKickThread = task.spawn(function()
            while v2.Defense.AntiKick do
                task.wait(0.05)
                local char = v1.player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or hum.Health <= 0 or not hrp then continue end
                local kunai = v1.inv and (v1.inv:FindFirstChild("AntiKick"))
                if not kunai and v1.CanSpawn.Value then
                    local OldToys = {}
                    for _, t in ipairs(v1.inv:GetChildren()) do
                        OldToys[t] = true
                    end
                    task.spawn(function()
                        pcall(function()
                            Event.SpawnToy:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 24, 20), Vector3.zero)
                        end)
                    end)
                    task.wait()
                    repeat
                        for _, t in ipairs(v1.inv:GetChildren()) do
                            if not OldToys[t] and t.Name == "NinjaShuriken" then
                                kunai = t
                                break
                            end
                        end
                        task.wait(0.03)
                    until kunai or not v2.Defense.AntiKick
                    v2.Defense.CurrentAntiKick = kunai
                    if not kunai and game.Workspace.PlotItems.PlayersInPlots:FindFirstChild(v1.player.Name) then
                        for _, plot in pairs(game.Workspace.Plots:GetChildren()) do
                            local owners = plot:FindFirstChild("PlotSign")
                                and plot.PlotSign:FindFirstChild("ThisPlotsOwners")
                            if owners then
                                for _, owner in pairs(owners:GetChildren()) do
                                    if owner.Value == v1.player.Name then
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
                        char = v1.player.Character
                        hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if kunai and kunai:FindFirstChild("StickyPart") and hrp then
                            local sound = kunai:FindFirstChild("SoundPart", true)
                            local owner = sound and sound:FindFirstChild("PartOwner")

                            if sound and (not owner or owner.Value ~= v1.player.Name) then
                                pcall(function()
                                    Function.SnoPart(sound)
                                end)
                            end
                            local firePart = hrp:FindFirstChild("FirePlayerPart") or hrp:WaitForChild("FirePlayerPart", 5)
                            if firePart then
                                Event.Stick:FireServer(kunai.StickyPart, firePart, CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)))
                            end
                            if not kunai:FindFirstChild("Kaylis_HL") then
                                local hl = Instance.new("Highlight")
                                hl.Name = "Kaylis_HL"
                                hl.FillColor = v2.Defense.AntiKickHLFillColor
                                hl.OutlineColor = v2.Defense.AntiKickHLOlColor
                                hl.FillTransparency = v2.Defense.AntiKickHLTrans
                                hl.Parent = kunai
                                v2.Defense.AntiKickHL = hl
                            end
                            for _, obj in pairs(kunai:GetChildren()) do
                                if obj:IsA("BasePart") then
                                    obj.CanTouch = false
                                    obj.CanCollide = false
                                    obj.CanQuery = false
                                end
                            end
                        end
                        task.wait(0.05)
                    until not v2.Defense.AntiKick
                        or not kunai
                        or not kunai:FindFirstChild("StickyPart")
                        or not hrp
                        or (hrp.Position - kunai.StickyPart.Position).Magnitude >= 30
                    if kunai and kunai:FindFirstChild("StickyPart") and hrp
                        and (hrp.Position - kunai.StickyPart.Position).Magnitude >= 30 then
                        v2.Defense.CurrentAntiKick = nil
                        v2.Defense.AntiKickHL = nil
                        clearKunai()
                    end
                end
            end
            clearKunai()
        end)
    end
})
EnableAntiKick = DefenseBoxTabs.Defense:AddToggle("EnableAntiKick", {
    Text = "Auto-Enable",
    Default = false,
    Callback = function(v)
        v2.Defense.EnableAntiKick = v
        if v then
            v2.Defense.AutoEnableAKConn = gs.Rep.GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(message)
                if message == "Flying" then
                    Function.Notify("Enabled Anti-Kick due to kick warning.", 4)
                    task.wait()
                    AntiKick:SetValue(true)
                end
            end)
        else
            if v2.Defense.AutoEnableAKConn then
                v2.Defense.AutoEnableAKConn:Disconnect()
                v2.Defense.AutoEnableAKConn = nil
            end
        end
    end
})
DefenseBoxTabs.Defense:AddDivider("Anti-Lag")
AntiLag = DefenseBoxTabs.Defense:AddToggle("AntiLag", {
    Text = "Anti-Lag",
    Default = false,
    Callback = function(v)
        v2.Defense.AntiLagEna = v
        local ls = v1.player:FindFirstChild("PlayerScripts"):FindFirstChild("CharacterAndBeamMove")
        if ls then ls.Disabled = v end
        if not v then
            for _, plr in ipairs(gs.Players:GetPlayers()) do
                if plr ~= v1.player and plr.Character then
                    local gp = plr.Character:FindFirstChild("GrabParts")
                    if gp then gp:Destroy() end
                end
            end
        end
    end
})
AutoAntiLag = DefenseBoxTabs.Defense:AddToggle("AutoAntiLag", {
    Text = "Auto Anti-Lag",
    Default = true,
    Callback = function(v)
        if v then
            local Frames = 0
            local LastTime = os.clock()
            v2.Defense.AntiLagWatchConn = gs.Rs.RenderStepped:Connect(function()
                Frames += 1
                if os.clock() - LastTime >= 0.03 then
                    local FPS = Frames / (os.clock() - LastTime)
                    if FPS < v2.Defense.AntiLagSens and not v2.Defense.AntiLagEna then 
                        AntiLag:SetValue(true) 
                        Function.Notify("Low FPS Detected Anti-Lag Enabled", 3)
                    end
                    Frames = 0
                    LastTime = os.clock()
                end
            end)
        else
            if v2.Defense.AntiLagWatchConn then
                v2.Defense.AntiLagWatchConn:Disconnect()
                v2.Defense.AntiLagWatchConn = nil
            end
        end
    end
})
v2.Defense.LineLagWatchConn = Function.ConnectConn(Event.cgl.OnClientEvent:Connect(function(plr, part, cf)
    if plr == v1.player then return end
    if not plr or not plr:IsA("Player") then return end
    if not part or not part:IsA("BasePart") then return end
    local _, thrp = Function.GetParts(plr)
    if not thrp then return end
    local position = typeof(cf) == "CFrame" and cf.Position or part.Position
    local dist = (position - thrp.Position).Magnitude
    if dist > 500000 then
        v2.Defense.LineLagLastLine[plr] = tick()
        if not v2.Defense.LineLaggers[plr] then
            Function.Notify(plr.DisplayName .. " | " .. plr.Name .. " Started Line Lag", 5)
            v2.Defense.LineLaggers[plr] = true
        end
    end
end))
v2.Defense.LineLagWatchLoop = task.spawn(function()
    while true do
        task.wait(0.25)
        local now = tick()
        for plr in pairs(v2.Defense.LineLaggers) do
            local lastFire = v2.Defense.LineLagLastLine[plr]
            if lastFire and now - lastFire >= 0.25 then
                Function.Notify(plr.DisplayName .. " | " .. plr.Name .. " Stopped Line Lag", 5)
                v2.Defense.LineLaggers[plr] = nil
                v2.Defense.LineLagLastLine[plr] = nil
            end
        end
    end
end)
DefenseBoxTabs.Defense:AddDivider("Void")
AntiVoid = DefenseBoxTabs.Defense:AddToggle("AntiVoid", {
    Text = "Anti-Void",
    Default = false,
	Callback = function(v)
		if v then
			v2.Defense.AntiVoidConn = gs.Rs.Heartbeat:Connect(function()
                local char = v1.player.Character or v1.player.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart", true)
                if hrp.Position.Y < -40 then
                    hrp.CFrame = CFrame.new(0, 0, 0)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end)
		else
            if v2.Defense.AntiVoidConn then
                v2.Defense.AntiVoidConn:Disconnect()
                v2.Defense.AntiVoidConn = nil
            end
		end
	end
})
-------------------------->> [Third Party] <<--------------------------
GP.ThirdParty:AddDivider("Select Players")
ThirdPartyDropdown = GP.ThirdParty:AddDropdown("ThirdParty", {
    Text = "Select Player",
    Values = {},
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Callback = function(v)
        v2.ThirdParty.Protected = v
        for plr in pairs(v) do
            v2.Target.OldTargets[plr.UserId] = v2.Target.OldTargets[plr.UserId] or {}
            v2.Target.OldTargets[plr.UserId].ThirdParty = true
        end
    end
})
-------------------------->> [Third Party Anti-Grab] <<--------------------------
GP.ThirdParty:AddDivider()
GP.ThirdParty:AddToggle("ThirdPartyAntiGrab", {
    Text = "Anti-Grab",
    Default = false,
    Callback = function(v)
        v2.ThirdParty.AntiGrab = v
        if v2.ThirdParty.AntiGrabThread then
            task.cancel(v2.ThirdParty.AntiGrabThread)
            v2.ThirdParty.AntiGrabThread = nil
        end

        table.clear(v2.ThirdParty.Grabbed)

        if not v then
            return
        end

        v2.ThirdParty.AntiGrabThread = task.spawn(function()
            while v2.ThirdParty.AntiGrab do
                local char = v1.player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if not hum or not hrp or hum.Health <= 0 then
                    task.wait()
                    continue
                end

                local grabbedAny = false

                for plr in pairs(v2.ThirdParty.Protected) do
                    local pchar = plr.Character
                    local phum = pchar and pchar:FindFirstChildOfClass("Humanoid")
                    local phrp = pchar and pchar:FindFirstChild("HumanoidRootPart")
                    local phead = pchar and pchar:FindFirstChild("Head")

                    if not phum or phum.Health <= 0 or not phrp or not phead then
                        task.wait()
                        continue
                    end

                    local PartOwner = phead:FindFirstChild("PartOwner")

                    if PartOwner and PartOwner.Value ~= v1.player.Name
                        and not v2.ThirdParty.Grabbed[plr] then

                        v2.ThirdParty.Grabbed[plr] = {
                            TheirHome = phrp.CFrame
                        }
                        Function.StartClone("ThirdPartyAntiGrab")
                        Function.FloatMe(hrp)
                        Function.StartNoclip()
                        grabbedAny = true
                    end
                end

                for plr, data in pairs(v2.ThirdParty.Grabbed) do
                    local pchar = plr.Character
                    local phum = pchar and pchar:FindFirstChildOfClass("Humanoid")
                    local phrp = pchar and pchar:FindFirstChild("HumanoidRootPart")

                    if not phum or phum.Health <= 0 or not phrp then
                        Function.StopClone("ThirdPartyAntiGrab")
                        v2.ThirdParty.Grabbed[plr] = nil
                        continue
                    end

                    if (hrp.Position - phrp.Position).Magnitude > v1.MaxGrabDist then
                        hrp.CFrame = phrp.CFrame + Vector3.new(0, -8, 5)
                    end

                    local start = tick()

                    repeat
                        if hum.Health <= 0 or phum.Health <= 0 then
                            break
                        end

                        Function.SnoPart(phrp)
                        task.wait(0.003)
                    until isnetworkowner(phrp) or tick() - start > v2.Target.TimeOut

                    Event.dgl:FireServer(phrp)

                    task.spawn(function()
                        while isnetworkowner(phrp) do
                            phrp.AssemblyLinearVelocity = Vector3.zero
                            phrp.AssemblyAngularVelocity = Vector3.zero
                            phrp.CFrame = data.TheirHome
                            task.wait(0.005)
                        end
                    end)

                    v2.ThirdParty.Grabbed[plr] = nil
                end

                if grabbedAny then
                    Function.UnfloatMe(hrp)
                    Function.StopNoclip()
                    Function.StopClone("ThirdPartyAntiGrab")
                end

                task.wait(0.05)
            end

            table.clear(v2.ThirdParty.Grabbed)
        end)
    end
})
function clearKunai(plr)
    local kunai = v2.ThirdParty.Shurikens[plr]
    if kunai then
        Event.DestroyToy:FireServer(kunai)
        v2.ThirdParty.Shurikens[plr] = nil
    end
end

function clearAllKunai()
    for plr in pairs(v2.ThirdParty.Shurikens) do
        clearKunai(plr)
    end
end

GP.ThirdParty:AddToggle("ThirdPartyAntiKick", {
    Text = "Anti-Kick",
    Default = false,
    Callback = function(v)
        v2.ThirdParty.AntiKick = v

        if v2.ThirdParty.AntiKickThread then
            task.cancel(v2.ThirdParty.AntiKickThread)
            v2.ThirdParty.AntiKickThread = nil
        end

        if not v then
            clearAllKunai()
            return
        end

        v2.ThirdParty.AntiKickThread = task.spawn(function()
            while v2.ThirdParty.AntiKick do
                for plr in pairs(v2.ThirdParty.Protected) do
                    local char = v1.player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    local pchar = plr.Character
                    local phum = pchar and pchar:FindFirstChildOfClass("Humanoid")
                    local phrp = pchar and pchar:FindFirstChild("HumanoidRootPart")

                    if not phum or phum.Health <= 0 or not phrp
                        or pchar.Parent == workspace.PlotItems.PlayersInPlots then
                        clearKunai(plr)
                        continue
                    end

                    local kunai = v2.ThirdParty.Shurikens[plr]
                        or v1.inv:FindFirstChild(plr.Name .. "_AntiKick")

                    if kunai then
                        v2.ThirdParty.Shurikens[plr] = kunai
                    end

                    if not kunai and v1.CanSpawn.Value and hrp then
                        local oldToys = {}

                        for _, t in ipairs(v1.inv:GetChildren()) do
                            oldToys[t] = true
                        end

                        task.spawn(function()
                            pcall(function()
                                Event.SpawnToy:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 24, 20), Vector3.zero)
                            end)
                        end)

                        repeat
                            for _, t in ipairs(v1.inv:GetChildren()) do
                                if not oldToys[t] and t.Name == "NinjaShuriken" then
                                    kunai = t
                                    break
                                end
                            end

                            task.wait(0.015)
                        until kunai or not v2.ThirdParty.AntiKick

                        if kunai then
                            v2.ThirdParty.Shurikens[plr] = kunai
                        end
                    end

                    if kunai then
                        kunai.Name = plr.Name .. "_AntiKick"

                        local sticky = kunai:FindFirstChild("StickyPart", true)

                        if not kunai.Parent then
                            v2.ThirdParty.Shurikens[plr] = nil
                            continue
                        end

                        local sound = kunai:FindFirstChild("SoundPart", true)
                        local owner = sound and sound:FindFirstChild("PartOwner")

                        if sound and (not owner or owner.Value ~= v1.player.Name) then
                            pcall(function()
                                Function.SnoPart(sound)
                            end)
                        end

                        local firePart = phrp:FindFirstChild("FirePlayerPart")


                        if firePart then
                            Event.Stick:FireServer(sticky, firePart, CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)))
                        end

                        if not kunai:FindFirstChild("Kaylis_HL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "Kaylis_HL"
                            hl.FillColor = v2.Defense.AntiKickHLFillColor
                            hl.OutlineColor = v2.Defense.AntiKickHLOlColor
                            hl.FillTransparency = v2.Defense.AntiKickHLTrans
                            hl.Parent = kunai
                        end

                        for _, obj in ipairs(kunai:GetChildren()) do
                            if obj:IsA("BasePart") then
                                obj.CanTouch = false
                                obj.CanCollide = false
                                obj.CanQuery = false
                            end
                        end

                        if hrp and sticky and (hrp.Position - sticky.Position).Magnitude >= 30 and not sticky.StickyWeld.Part1 then
                            clearKunai(plr)
                            v2.ThirdParty.Shurikens[plr] = nil
                            continue
                        end
                    end
                end

                task.wait(0.05)
            end

            clearAllKunai()
        end)
    end
})
GP.ThirdParty:AddToggle("ThirdPartyAntiExplode", {
    Text = "Anti-Explode",
    Default = false,
    Callback = function(v)
        v2.ThirdParty.AntiExplode = v
        if v2.ThirdParty.AntiExplodeThread then
            task.cancel(v2.ThirdParty.AntiExplodeThread)
            v2.ThirdParty.AntiExplodeThread = nil
        end

        table.clear(v2.ThirdParty.Exploded)

        if not v then
            return
        end

        v2.ThirdParty.AntiExplodeThread = task.spawn(function()
            while v2.ThirdParty.AntiExplode do
                local char = v1.player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if not hum or not hrp or hum.Health <= 0 then
                    task.wait()
                    continue
                end

                local ExplodedAny = false

                for plr in pairs(v2.ThirdParty.Protected) do
                    local pchar = plr.Character
                    local phum = pchar and pchar:FindFirstChildOfClass("Humanoid")
                    local phrp = pchar and pchar:FindFirstChild("HumanoidRootPart")
                    local phead = pchar and pchar:FindFirstChild("Head")

                    if not phum or phum.Health <= 0 or not phrp or not phead then
                        task.wait()
                        continue
                    end

                    local Part = workspace:FindFirstChild("Part")
                    local dist = Part and Part:IsA("BasePart") and (Part.Position - phrp.Position).Magnitude

                    if Function.IsRagdolled(pchar) and dist and dist < 20 and not v2.ThirdParty.Exploded[plr] then
                        v2.ThirdParty.Exploded[plr] = {
                            TheirHome = phrp.CFrame
                        }

                        Part:Destroy()

                        Function.StartClone("ThirdPartyAntiExplode")
                        Function.FloatMe(hrp)
                        Function.StartNoclip()
                        ExplodedAny = true
                    end
                end

                for plr, data in pairs(v2.ThirdParty.Exploded) do
                    local pchar = plr.Character
                    local phum = pchar and pchar:FindFirstChildOfClass("Humanoid")
                    local phrp = pchar and pchar:FindFirstChild("HumanoidRootPart")

                    if not phum or phum.Health <= 0 or not phrp then
                        v2.ThirdParty.Exploded[plr] = nil
                        Function.StopClone("ThirdPartyAntiExplode")
                        continue
                    end

                    if (hrp.Position - phrp.Position).Magnitude > v1.MaxGrabDist then
                        hrp.CFrame = phrp.CFrame + Vector3.new(0, -8, 5)
                    end

                    local start = tick()

                    repeat
                        if hum.Health <= 0 or phum.Health <= 0 then
                            break
                        end

                        Function.SnoPart(phrp)
                        task.wait(0.003)
                    until isnetworkowner(phrp) or tick() - start > v2.Target.TimeOut

                    Event.dgl:FireServer(phrp)

                    task.spawn(function()
                        while isnetworkowner(phrp) do
                            phrp.AssemblyLinearVelocity = Vector3.zero
                            phrp.AssemblyAngularVelocity = Vector3.zero
                            phrp.CFrame = data.TheirHome
                            task.wait(0.005)
                        end
                    end)

                    v2.ThirdParty.Exploded[plr] = nil
                end

                if ExplodedAny then
                    Function.UnfloatMe(hrp)
                    Function.StopNoclip()
                    Function.StopClone("ThirdPartyAntiExplode")
                end

                task.wait(0.05)
            end

            table.clear(v2.ThirdParty.Exploded)
        end)
    end
})
-------------------------->> [Counter Attack] <<--------------------------
GP.Counter:AddDropdown("CounterAttackConsequences", {
    Text = "Consequences",
    Values = {"Void", "Push", "Fling", "Teleport", "Noclip", "Heaven"},
    Default = nil,
    Multi = false,
    AllowNull = false,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Defense.CounterAttackConsequence = v
        if v2.Defense.CounterAttackConsequence == "Teleport" then
            CounterLocation:SetVisible(true)
        else
            CounterLocation:SetVisible(false)
        end
    end
})
CounterLocation = GP.Counter:AddDropdown("CounterLocation", {
    Text = "Teleport Locations",
    Values = {"Chinese Roof", "Small Cave", "Big Cave", "Island Cave", "Goon Cave"},
    Default = "Chinese Roof",
    Multi = false,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Defense.CounterLocation = v
    end
})
CounterLocation:SetVisible(false)
CounterAttack = GP.Counter:AddToggle("CounterAttack", {
    Text = "Counter-Attack",
    Default = false,
    Callback = function(v)
        if v then
            v2.Defense.AntiGrabAttacker = gs.Rs.RenderStepped:Connect(function()
                local char = v1.player.Character
                local head = char:FindFirstChild("Head")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if not head then return end
                if not hrp then return end
                if head:FindFirstChild("PartOwner") then
                    local CurrentAttacker = head:FindFirstChild("PartOwner").Value
                    if not CurrentAttacker then return end
                    v2.Defense.Attacker = CurrentAttacker
                    local AttackerName = tostring(CurrentAttacker)
                    local Attacker = AttackerName and gs.Players:FindFirstChild(AttackerName)
                    local tchar = Attacker and Attacker.Character
                    local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
                    local thum = tchar and tchar:FindFirstChild("Humanoid")
                    head:FindFirstChild("PartOwner"):Destroy()
                    task.spawn(function()
                        if thrp then
                            if not v2.Defense.CounterAttackConsequence then return end
                            local dist = (thrp.Position - hrp.Position).Magnitude
                            if dist > v1.MaxGrabDist then return end
                            if not isnetworkowner(thrp) then
                                repeat
                                    Function.SnoPart(thrp)
                                    dist = (thrp.Position - hrp.Position).Magnitude
                                    task.wait(0.03)
                                until isnetworkowner(thrp) or dist > v1.MaxGrabDist or thum.Health == 0
                            end
                            if isnetworkowner(thrp) then
                                if v2.Defense.CounterAttackConsequence == "Void" then
                                    workspace.FallenPartsDestroyHeight = -50000
                                    thrp.CFrame = CFrame.new(0, -49999, 0)
                                    task.wait(0.3)
                                    workspace.FallenPartsDestroyHeight = v1.FallenHeight
                                end

                                if v2.Defense.CounterAttackConsequence == "Teleport" then
                                    thrp.CFrame = v2.Location[v2.Defense.CounterLocation]
                                end

                                if v2.Defense.CounterAttackConsequence == "Noclip" then
                                    for _, p in ipairs(tchar:GetChildren()) do
                                        if p:IsA("BasePart") then
                                            p.CanCollide = false
                                        end
                                    end
                                end

                                if v2.Defense.CounterAttackConsequence == "Heaven" then
                                    thrp.AssemblyLinearVelocity = Vector3.new(0, 9e2, 0)
                                end

                                if v2.Defense.CounterAttackConsequence == "Fling" then
                                    local direction = (thrp.Position - hrp.Position)
                                    if direction.Magnitude > 0 then
                                        direction = direction.Unit
                                        thrp.AssemblyLinearVelocity = direction * 1500 + Vector3.new(0, 150, 0)
                                    end
                                end

                                if v2.Defense.CounterAttackConsequence == "Push" then
                                    local direction = (thrp.Position - hrp.Position)
                                    if direction.Magnitude > 0 then
                                        direction = direction.Unit
                                        thrp.AssemblyLinearVelocity = direction * 150 + Vector3.new(0, 10, 0)
                                    end
                                end
                            end
                        end
                    end)
                    hum.Sit = false
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hum.PlatformStand = true
                    Function.LockChar(v1.player.Character)
                    Event.Struggle:FireServer(v1.player)
                    if not Function.IsRagdolled(char) then
                        Event.Ragdoll:FireServer(hrp, 0)
                    end
                end
                if v1.player.IsHeld.Value then
                    hrp.Anchored = true
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero
                else
                    hrp.Anchored = false
                    hum.PlatformStand = false
                    hum.Sit = false
                    Function.UnlockChar(v1.player.Character)
                end
            end)
        else
            if v2.Defense.AntiGrabAttacker then
                v2.Defense.AntiGrabAttacker:Disconnect()
                v2.Defense.AntiGrabAttacker = nil
            end
        end
    end
})
-------------------------->> [Config] <<--------------------------
DefenseBoxTabs.Config:AddDivider("Anti-Grab Gucci")
DefenseBoxTabs.Config:AddDropdown("GucciType", {
    Text = "Select Type",
    Values = {"Blobman", "Tractor"},
    Default = "Blobman",
    Multi = false,
    Callback = function(v)
        v2.Defense.GucciType = v
        if v2.Defense.CurrentGucci then
            Event.DestroyToy:FireServer(v2.Defense.CurrentGucci)
            TurnOffGucci()
        end
    end
})
DefenseBoxTabs.Config:AddDivider("Anti-Network/Input")
DefenseBoxTabs.Config:AddDropdown("AntiInputItem", {
    Text = "Select Toy",
    Values = {"Poop Sparkle", "Soda", "Cake", "Hamburger", "Banana", "Microphone"},
    Default = nil,
    Multi = false,
    Callback = function(v)
        v2.Defense.AntiInputToy = v2.Item[v]
    end
})
AntiNetChange = DefenseBoxTabs.Config:AddButton({
    Text = "Anti-Network",
    Tooltip = "This is will change Anti-Input to Anti-Network.",
    Func = function()
        Function.Notify("This change has already been made sorry!", 2)
        if v2.Defense.AntiNetChange then return end
        egeConfirm = win:AddDialog("egeConfirm", {
            Title = "Are you sure?",
            Description = "This change will be permanent until you rejoin.",
            AutoDismiss = true,
            OutsideClickDismiss = true,
            FooterButtons = {
                Cancel = {
                    Title = "Cancel",
                    Variant = "Primary",
                    Order = 1,
                    Callback = function()
                        return
                    end
                },
                Confirm = {
                    Title = "Confirm",
                    Variant = "Destructive",
                    WaitTime = 0,
                    Order = 2,
                    Callback = function(self)
                        local egeClone = Event.ege:Clone(); Event.ege:Destroy(); egeClone.Parent = gs.Rep.GrabEvents
                        if AntiInput then AntiInput:SetText("Anti-Network") end
                        v2.Defense.AntiNetChange = true
                    end
                }
            }
        })
    end
})
DefenseBoxTabs.Config:AddDivider("Anti-Kick")
AntiKickColorHolder = DefenseBoxTabs.Config:AddLabel("Color Settings ~~~~>")
AntiKickColorHolder:AddColorPicker("AntiKickHLFillColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Fill Color",
    Resizable = true,
    Callback = function(v)
        local hl = v2.Defense.AntiKickHL
        v2.Defense.AntiKickHLFillColor = v
        if hl then
            Function.Tween(hl, {FillColor = v}, 1)
        end
    end
})
AntiKickColorHolder:AddColorPicker("AntiKickHLOlColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Outline Color",
    Resizable = true,
    Callback = function(v)
        local hl = v2.Defense.AntiKickHL
        v2.Defense.AntiKickHLOlColor = v
        if hl then
            Function.Tween(hl, {OutlineColor = v}, 1)
        end
    end
})
DefenseBoxTabs.Config:AddSlider("AntiKickHLTrans", {
    Text = "Anti-Kick Transparency",
    Default = 0.4,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        local hl = v2.Defense.AntiKickHL
        if hl then
            Function.Tween(hl, {FillTransparency = v}, 1)
        else
            v2.Defense.AntiKickHLTrans = v
        end
    end
})
DefenseBoxTabs.Config:AddDivider("Anti-Lag")
DefenseBoxTabs.Config:AddSlider("AntiLagSens", {
    Text = "FPS Sensitivity",
    Default = 5,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Defense.AntiLagSens = v
    end
})
-------------------------->> [Defense Misc] <<--------------------------
DisableVoid = GP.Misc:AddToggle("DisableVoid", {
    Text = "Disable Void",
    Default = true,
	Callback = function(v)
		if v then
			workspace.FallenPartsDestroyHeight = 0/0
            v1.FallenHeight = 0/0
		else
            v1.FallenHeight = -50
			workspace.FallenPartsDestroyHeight = v1.FallenHeight
		end
	end
})
WaterWalk = GP.Misc:AddToggle("WaterWalk", {
    Text = "Water Walk",
    Default = false,
	Callback = function(v)
		if v then
			for _, x in ipairs(workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel:GetChildren()) do
                x.CanCollide = v
            end
        else
            for _, x in ipairs(workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel:GetChildren()) do
                x.CanCollide = v
            end
		end
	end
})
RemoveInvis = GP.Misc:AddToggle("RemoveInvis", {
	Text = "Anti-Invis",
	Default = false,
	Callback = function(v)
		if not v then
			for _, c in v2.Defense.AntiDesyncConns do c:Disconnect() end
			table.clear(v2.Defense.AntiDesyncConns)
			return
		end

		for _, plr in Players:GetPlayers() do
			if plr ~= v1.player then
				task.spawn(function()
					local char = plr.Character or plr.CharacterAdded:Wait()
					local hrp = char:WaitForChild("HumanoidRootPart", 5)
					local hum = char:WaitForChild("Humanoid", 5)

					if hrp and hum then
						local function fix()
							if hrp.Massless and not hum.Sit then
								hrp.Massless = false
							end
						end

						fix()
						table.insert(v2.Defense.AntiDesyncConns, hrp:GetPropertyChangedSignal("Massless"):Connect(fix))
						table.insert(v2.Defense.AntiDesyncConns, hum:GetPropertyChangedSignal("Sit"):Connect(fix))
					end
				end)

				table.insert(v2.Defense.AntiDesyncConns, plr.CharacterAdded:Connect(function(char)
					local hrp = char:WaitForChild("HumanoidRootPart", 5)
					local hum = char:WaitForChild("Humanoid", 5)

					if hrp and hum then
						local function fix()
							if hrp.Massless and not hum.Sit then
								hrp.Massless = false
							end
						end
						table.insert(v2.Defense.AntiDesyncConns, hrp:GetPropertyChangedSignal("Massless"):Connect(fix))
						table.insert(v2.Defense.AntiDesyncConns, hum:GetPropertyChangedSignal("Sit"):Connect(fix))
					end
				end))
			end
		end
	end
})
-------------------------->> [Target] <<--------------------------
local ObjectBoxTabs = {
    Target = GP.Target:AddTab("Target", "crosshair"),
    TargetSettings = GP.Target:AddTab("Settings", "settings"),
    BlobmanTarget = GP.BlobmanTarget:AddTab("Blobman", "venetian-mask"),
    BlobmanSettings = GP.BlobmanTarget:AddTab("Settings", "settings"),
}
-------------------------->> [Get Targets] <<--------------------------
ObjectBoxTabs.Target:AddDivider("Select Targets")
TargetDropdown = ObjectBoxTabs.Target:AddDropdown("PlayerTargets", {
    Text = "Select Target",
    Values = {},
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Callback = function(v)
        v2.Target.Targets = v
        for plr in pairs(v) do
            v2.Target.OldTargets[plr.UserId] = v2.Target.OldTargets[plr.UserId] or {}
            v2.Target.OldTargets[plr.UserId].PlayerTargets = true
        end
    end
})
ObjectBoxTabs.BlobmanTarget:AddDivider("Select Targets")
BlobmanTargetDropdown = ObjectBoxTabs.BlobmanTarget:AddDropdown("BlobmanTargets", {
    Text = "Select Target",
    Values = {},
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Callback = function(v)
        v2.Target.BlobmanTargets = v
        for plr in pairs(v) do
            v2.Target.OldTargets[plr.UserId] = v2.Target.OldTargets[plr.UserId] or {}
            v2.Target.OldTargets[plr.UserId].BlobmanTargets = true
        end
    end
})
-------------------------->> [Select Methods] <<--------------------------
ObjectBoxTabs.Target:AddDivider()
ObjectBoxTabs.Target:AddDropdown("TargetMethod", {
    Text = "Select Method",
    Values = {"Kick", "Kill", "Void", "Bring", "Delete Seatables", "Remove Gucci",},
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Target.TargetMethod = v
    end
})
ObjectBoxTabs.BlobmanTarget:AddDivider()
ObjectBoxTabs.BlobmanTarget:AddDropdown("BlobmanMethod", {
    Text = "Select Method",
    Values = {"Kick", "Kill", "Freeze", "Float", "Bring", "Control"},
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Target.BlobmanMethod = v
    end
})
-------------------------->> [Run Target Methods] <<--------------------------
function ApplyMethodSelected(Method, sno)
    table.clear(v2.Target.GoodTargets)

    for plr, selected in pairs(v2.Target.Targets) do
        if selected and (not sno or Function.IsTargetGood(plr)) then
            table.insert(v2.Target.GoodTargets, plr)
        end
    end

    local char, hrp, hum = Function.GetParts(v1.player)

    if not char or not hum or not hrp then
        return
    end

    local Home = hrp.CFrame

    Function.StartClone("ApplyMethodOnce")
    Function.StartNoclip()
    Function.FloatMe(hrp)

    for _, plr in ipairs(v2.Target.GoodTargets) do
        local tchar, thrp, thum = Function.GetParts(plr)

        if not tchar or not thrp or not thum then
            continue
        end

        local start = tick()

        if sno and not isnetworkowner(thrp) then
            repeat
                if hum.Health <= 0 or not Function.IsTargetGood(plr) then
                    break
                end

                if (hrp.Position - thrp.Position).Magnitude > v1.MaxGrabDist and Function.CanTeleport() then
                    hrp.CFrame = thrp.CFrame + Vector3.new(0, -8, 5)
                end

                Function.SnoPart(thrp)
                task.wait(0.003)
            until isnetworkowner(thrp) or tick() - start > v2.Target.TimeOut
        end

        if Method == "Kill" then
            Event.dgl:FireServer(thrp)
            thum.BreakJointsOnDeath = false
            thum:ChangeState(Enum.HumanoidStateType.Dead)
            Function.Launch(thrp, Vector3.new(0, 9e9, 9e9))

        elseif Method == "Bring" then
            thrp.CFrame = Home + Home.LookVector * 5
            Event.dgl:FireServer(thrp)

        elseif Method == "Void" then
            workspace.FallenPartsDestroyHeight = -50000
            thrp.CFrame = CFrame.new(0, -49999, 0)
            Event.dgl:FireServer(thrp)
            task.wait(0.3)
            workspace.FallenPartsDestroyHeight = v1.FallenHeight

        elseif Method == "Remove Gucci" then
            task.spawn(function()
                if Function.HasGucci(plr) then
                    local seat = thum.SeatPart
                    local Tgucci = seat.Parent
                    if Tgucci then
                        seat:Sit(hum)
                        hum.Sit = false
                    end
                end
            end)

        elseif Method == "Delete Seatables" then
            local tbackpack, tinv = Function.BackPack(plr)
            for _, backpack in ipairs({tinv, tbackpack}) do
                if backpack then
                    for _, toy in ipairs(backpack:GetChildren()) do
                        if toy:IsA("Model") and v2.Seatables[toy.Name] then
                            local GrabPart
                            for _, p in ipairs(toy:GetChildren()) do
                                if p:IsA("BasePart") and p.CanQuery then
                                    GrabPart = p
                                    break
                                end
                            end
                            if not GrabPart then continue end
                            local toyStart = tick()
                            if not isnetworkowner(GrabPart) then
                                repeat
                                    if hum.Health <= 0 then
                                        break
                                    end
                                    if (hrp.Position - GrabPart.Position).Magnitude > v1.MaxGrabDist then
                                        hrp.CFrame = GrabPart.CFrame + Vector3.new(0, -8, 5)
                                    end
                                    Function.SnoPart(GrabPart)
                                    task.wait(0.003)
                                until Function.DoesOwn(toy) or tick() - toyStart > v2.Target.TimeOut
                            end
                            task.spawn(function()
                                workspace.FallenPartsDestroyHeight = -50000
                                GrabPart.CFrame = CFrame.new(0, -49995, 0)
                                Event.dgl:FireServer(GrabPart)
                            end)
                        end
                    end
                end
            end
            if tbackpack then
                for _, toy in ipairs(tbackpack:GetChildren()) do
                    if toy:IsA("Model") and v2.Seatables[toy.Name] then
                        task.spawn(function()
                            local seat = toy:FindFirstChild("VehicleSeat")
                            if not seat then return end
                            seat:Sit(hum)
                            workspace.FallenPartsDestroyHeight = -50000
                            hrp.CFrame = CFrame.new(0, -49995, 0)
                            hum.Sit = false
                        end)
                    end
                end
            end
        end
    end
    Function.StopNoclip()
    Function.UnfloatMe(hrp)
    Function.StopClone("ApplyMethodOnce")
end

function ApplyMethodServer(Method)
    table.clear(v2.Target.GoodTargets)

    for _, plr in ipairs(gs.Players:GetPlayers()) do
        if plr ~= v1.player and Function.IsTargetGood(plr) and not Function.Whitelisted(plr) then
            table.insert(v2.Target.GoodTargets, plr)
        end
    end

    local char = v1.player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hum or not hrp then
        return
    end

    local Home = hrp.CFrame

    Function.StartNoclip()
    Function.StartClone("ApplyServerMethodOnce")
    Function.FloatMe(hrp)
    if Method == "Kick" and v2.Target.KickServerMethod == "Shape" then
        local ShapePlayers = {}
        for _, plr in ipairs(v2.Target.GoodTargets) do
            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            Function.FloatMe(thrp)
            
            if thrp then
                if not isnetworkowner(thrp) then
                    local start = tick()
                    repeat
                        if hum.Health <= 0 or not Function.IsTargetGood(plr) then
                            break
                        end
                        if (hrp.Position - thrp.Position).Magnitude > v1.MaxGrabDist and Function.CanTeleport then
                            hrp.CFrame = thrp.CFrame + Vector3.new(0, -8, 5)
                        end

                        Function.SnoPart(thrp)
                        task.wait(0.003)
                    until isnetworkowner(thrp) or tick() - start > v2.Target.TimeOut
                end
                if isnetworkowner(thrp) then
                    table.insert(ShapePlayers, thrp)
                end
            end
        end

        local Count = #ShapePlayers
        local Center = Home.Position

        if Count > 0 then
            if v2.Target.KickServerShape == "Circle" then
                for i, thrp in ipairs(ShapePlayers) do
                    local Angle = (i - 1) / Count * math.pi * 2
                    local Position = Center + Vector3.new(
                        math.cos(Angle) * 15,
                        10,
                        math.sin(Angle) * 15
                    )
                    thrp.CFrame = CFrame.lookAt(Position, Center)
                end
            end

            task.wait()

            for _, thrp in ipairs(ShapePlayers) do
                Event.dgl:FireServer(thrp)
                task.spawn(function()
                    task.wait(2)
                    Function.UnfloatMe(thrp)
                end)
            end
        end
    else
        for _, plr in ipairs(v2.Target.GoodTargets) do
            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar and tchar:FindFirstChild("Humanoid")

            if not thrp or not thum then
                continue
            end

            local start = tick()

            repeat
                if hum.Health <= 0 or not Function.IsTargetGood(plr) then
                    break
                end

                if (hrp.Position - thrp.Position).Magnitude > v1.MaxGrabDist then
                    hrp.CFrame = thrp.CFrame + Vector3.new(0, -15, 5)
                end

                Function.SnoPart(thrp)
                task.wait(0.003)
            until isnetworkowner(thrp) or tick() - start > v2.Target.TimeOut

            if Method == "Kill" then
                Event.dgl:FireServer(thrp)
                thum.BreakJointsOnDeath = false
                thum:ChangeState(Enum.HumanoidStateType.Dead)
                Function.Launch(thrp, Vector3.new(0, 9e9, 9e9))
            elseif Method == "Bring" then
                thrp.CFrame = Home + Home.LookVector * 5
                Event.dgl:FireServer(thrp)
            elseif Method == "Void" then
                workspace.FallenPartsDestroyHeight = -50000
                thrp.CFrame = CFrame.new(0, -49999, 0)
                Event.dgl:FireServer(thrp)
                task.wait()
                workspace.FallenPartsDestroyHeight = v1.FallenHeight
            elseif Method == "Kick" and v2.Target.KickServerMethod == "Heaven" then
                Event.dgl:FireServer(thrp)
                Function.Launch(thrp, Vector3.new(0, 9e9, 9e9))
            end
        end
    end

    Function.StopNoclip()
    Function.UnfloatMe(hrp)
    Function.StopClone("ApplyServerMethodOnce")
    workspace.FallenPartsDestroyHeight = v1.FallenHeight
end

ObjectBoxTabs.Target:AddDivider()
ObjectBoxTabs.Target:AddButton({
    Text = "Apply Methods Once",
    Func = function()
        if v2.Target.TargetMethod["Kill"] then
            ApplyMethodSelected("Kill", true)
        elseif v2.Target.TargetMethod["Void"] then
            ApplyMethodSelected("Void", true)
        elseif v2.Target.TargetMethod["Bring"] then
            ApplyMethodSelected("Bring", true)
        elseif v2.Target.TargetMethod["Delete Seatables"] then
            ApplyMethodSelected("Delete Seatables", false)
        elseif v2.Target.TargetMethod["Remove Gucci"] then
            ApplyMethodSelected("Remove Gucci", false)
        end
    end
})
ObjectBoxTabs.Target:AddButton({
    Text = "Apply Methods Once Server",
    Func = function()
        if v2.Target.TargetMethod["Kill"] then
            ApplyMethodServer("Kill")
        elseif v2.Target.TargetMethod["Void"] then
            ApplyMethodServer("Void")
        elseif v2.Target.TargetMethod["Bring"] then
            ApplyMethodServer("Bring")
        elseif v2.Target.TargetMethod["Kick"] then
            ApplyMethodServer("Kick")
            if v2.Target.PlayerShouldLag then
                v2.Target.Lag = true
                LineLag:SetValue(true)
                local WatchForKick
                WatchForKick = workspace.ChildAdded:Connect(function(c)
                    if c:IsA("Model") and c.Name == "BlackHoleKick" then
                        LineLag:SetValue(false)
                        WatchForKick:Disconnect()
                        WatchForKick = nil
                    end
                end)
            end
        end
    end
})

-------------------------->> [Run Blob Methods] <<--------------------------
function GetBlob()
    local char = v1.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    local old = {}
    for _, x in ipairs(v1.inv:GetChildren()) do
        if x.Name == "CreatureBlobman" then
            old[x] = true
        end
    end

    task.spawn(function()
        pcall(function()
            Event.SpawnToy:InvokeServer("CreatureBlobman", hrp.CFrame, Vector3.new(0, 60, 0))
        end)
    end)

    local blob, seat

    repeat
        for _, x in ipairs(v1.inv:GetChildren()) do
            if x.Name == "CreatureBlobman" and not old[x] then
                seat = x:FindFirstChild("VehicleSeat")
                if seat then
                    blob = x
                    break
                end
            end
        end
        task.wait(0.025)
    until seat or not char

    if not seat then return end

    local conn
    conn = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        local occ = seat.Occupant
        if occ and occ ~= hum then
            Event.DestroyToy:FireServer(blob)
            conn:Disconnect()
        end
    end)

    repeat
        seat:Sit(hum)
        task.wait(0.03)

        local occ = seat.Occupant
        if occ and occ ~= hum then
            local root = occ.Parent and occ.Parent:FindFirstChild("HumanoidRootPart")

            while occ.Parent and occ.Sit and seat.Parent do
                hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                if root then
                    SetOwner:FireServer(root, root.CFrame)
                end
                task.wait(0.03)
            end

            task.wait(0.35)
        end
    until hum.SeatPart == seat and seat.Occupant == hum and hum.Sit
        or not seat.Parent
        or not hrp.Parent

    if conn then
        conn:Disconnect()
    end
end

function HasBlob()
	local hum = v1.player.Character and v1.player.Character:FindFirstChildOfClass("Humanoid")
	local seat = hum and hum.SeatPart
	local blob = seat and seat:FindFirstAncestorWhichIsA("Model")
	if blob and blob.Name == "CreatureBlobman" then
		return blob
	end
	return nil
end

function BlobParts(blob, hand)
	local side = hand == "Right" and "Right" or "Left"
	local det = blob:FindFirstChild(side .. "Detector")
	local weld = det and det:FindFirstChild(side .. "Weld")
	local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
	return det, weld, scriptObj
end

function BlobDrop(blob, targetHRP, hand)
	local _, weld, scriptObj = BlobParts(blob, hand)
	local drop = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
	if weld and drop and targetHRP then
		drop:FireServer(weld, targetHRP)
		return true
	end
	return false
end

function BlobGrab(blob, targetHRP, hand)
	local _, weld, scriptObj = BlobParts(blob, hand)
	local grab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
	if weld and grab and targetHRP then
		grab:FireServer(nil, targetHRP, weld)
		return true
	end
	return false
end

function BlobGrabRelease(blob, targetHRP, hand)
	local _, weld, scriptObj = BlobParts(blob, hand)
	local grab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
	local release = scriptObj and scriptObj:FindFirstChild("CreatureRelease")
	if weld and grab and release and targetHRP then
		grab:FireServer(nil, targetHRP, weld)
		release:FireServer(weld, targetHRP)
		return true
	end
	return false
end

local function RunBlobMethod(Method, Type, Multi, Server)
    table.clear(v2.Target.GoodBlobTargets)
    if Server then
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            if plr ~= v1.player and Function.IsTargetGood(plr) and not Function.Whitelisted(plr) then
                table.insert(v2.Target.GoodBlobTargets, plr)
            end
        end
    else
        for plr, selected in pairs(v2.Target.BlobmanTargets) do
            if selected and Function.IsTargetGood(plr) then
                table.insert(v2.Target.GoodBlobTargets, plr)
            end
        end
    end

	local char = v1.player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hum or not hrp then
		return
	end

	local blob = HasBlob()

	if not blob then
		GetBlob()
	end

	repeat
		task.wait(0.1)
		blob = HasBlob()
	until blob or hum.Health <= 0

	if not blob or hum.Health <= 0 then
		return
	end

    local Home = hrp.CFrame

    if Type == "Release" and Multi then
	    for _, plr in ipairs(v2.Target.GoodBlobTargets) do
            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar and tchar:FindFirstChild("Humanoid")

            if not thrp or not thum then
                continue
            end

            local start = tick()
            Function.StartNoclip()
            Function.FloatMe(hrp)

            if not isnetworkowner(thrp) then
                repeat
                    if hum.Health <= 0 or not HasBlob() then
                        break
                    end

                    if not Function.IsTargetGood(plr) then
                        break
                    end

                    local dist = (hrp.Position - thrp.Position).Magnitude

                    if dist > v1.MaxBlobGrabDist then
                        hrp.CFrame = thrp.CFrame + Vector3.new(0, -15, 5)
                    end

                    BlobGrabRelease(blob, thrp, "Left")

                    task.wait(0.003)
                until isnetworkowner(thrp) or tick() - start > v2.Target.TimeOut
            end

            if Method == "Kill" then
                task.spawn(function()
                    if isnetworkowner(thrp) then
                        thum.BreakJointsOnDeath = false
                        Function.LockChar(tchar)
                        thum:ChangeState(Enum.HumanoidStateType.Dead)
                    end
                end)
            elseif Method == "Freeze" then
                task.spawn(function()
                    Function.Float(thrp, thrp.CFrame.Position)
                    repeat
                        task.wait(0.05)
                    until not isnetworkowner(thrp)
                    Function.Unfloat(thrp)
                end)
            elseif Method == "Float" then
                task.spawn(function()
                    Function.Float(thrp, thrp.CFrame.Position + Vector3.new(0, 40, 0))
                    repeat
                        task.wait(0.05)
                    until not isnetworkowner(thrp)
                    Function.Unfloat(thrp)
                end)
            elseif Method == "Bring" then
                task.spawn(function()
                    thrp.CFrame = Home + Home.LookVector * 5
                end)
            elseif Method == "Control" then
                task.spawn(function()
                    while thum.Health > 0 and isnetworkowner(thrp) do
                        if not v2.Target.FollowMe then
                            thum.WalkSpeed = v2.Target.ControlledWS
                            thum.JumpPower = v2.Target.ControlledJP
                        end

                        local dist = (hrp.Position - thrp.Position).Magnitude

                        if v2.Target.FollowMe and hrp and dist > 10 then
                            thum.WalkSpeed = 16
                            thum.JumpPower = 24
                            thum:MoveTo(hrp.CFrame.Position)
                        end

                        task.wait(0.15)
                    end
                end)
            end
            Function.StopNoclip()
            Function.UnfloatMe(hrp)
            hrp.CFrame = Home
        end
    elseif Type == "Sno" and not Multi then
        local TargetCount = 0
        local LeftTarget
        local RightTarget

        for _, plr in ipairs(v2.Target.GoodBlobTargets) do
            if TargetCount >= 2 then
                break
            end

            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar and tchar:FindFirstChild("Humanoid")

            if not thrp or not thum then
                continue
            end

            TargetCount += 1

            if TargetCount == 1 then
                LeftTarget = plr
            elseif TargetCount == 2 then
                RightTarget = plr
            end

            local start = tick()
            Function.StartNoclip()
            Function.FloatMe(hrp)

            repeat
                if hum.Health <= 0 or not HasBlob() then
                    break
                end

                if not Function.IsTargetGood(plr) then
                    break
                end

                local dist = (hrp.Position - thrp.Position).Magnitude

                if dist > v1.MaxBlobGrabDist then
                    hrp.CFrame = thrp.CFrame + Vector3.new(0, -15, 5)
                end

                Function.SnoPart(thrp)

                task.wait(0.003)
            until isnetworkowner(thrp) or tick() - start > v2.Target.TimeOut

            if Method == "Kick" and not Multi then
                task.spawn(function()
                    if LeftTarget then
                        if thrp then
                            if RightTarget then
                                thrp.CFrame = Home + Home.RightVector * -7 + Vector3.new(0, 40, 0)
                                Function.FloatMe(thrp)
                            else
                                thrp.CFrame = Home + Vector3.new(0, 40, 0)
                                Function.FloatMe(thrp)
                            end
                        end
                    end
                    if RightTarget then
                        if thrp then
                            thrp.CFrame = Home + Home.RightVector * 7 + Vector3.new(0, 40, 0)
                            Function.FloatMe(thrp)
                        end
                    end
                    Function.StopNoclip()
                    Function.UnfloatMe(hrp)
                    hrp.CFrame = Home
                    Event.dgl:FireServer(thrp)
                    task.wait(0.25)
                    if LeftTarget and blob then
                        BlobGrab(blob, thrp, "Left")
                        Function.UnfloatMe(thrp)
                    end
                    if RightTarget and blob then
                        BlobGrab(blob, thrp, "Right")
                        Function.UnfloatMe(thrp)
                    end
                end)
            end
        end
	end
end

function RunServerBlob(method)
    table.clear(v2.Target.GoodBlobTargets)
    for _, plr in ipairs(gs.Players:GetPlayers()) do
        if plr ~= v1.player and Function.IsTargetGood(plr) and not Function.Whitelisted(plr) then
            table.insert(v2.Target.GoodBlobTargets, plr)
        end
    end

	local char = v1.player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if not hum or not hrp then
		return
	end

	local blob = HasBlob()

	if not blob then
		GetBlob()
	end

	repeat
		task.wait(0.1)
		blob = HasBlob()
	until blob or hum.Health <= 0

	if not blob or hum.Health <= 0 then
		return
	end

    local Home = hrp.CFrame

    Function.StartNoclip()
    Function.FloatMe(hrp)

    for _, plr in ipairs(v2.Target.GoodBlobTargets) do
        local tchar = plr.Character
        local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
        local thum = tchar and tchar:FindFirstChild("Humanoid")

        if not thrp or not thum then
            continue
        end

        local start = tick()

        if not isnetworkowner(thrp) then
            repeat
                if hum.Health <= 0 or not HasBlob() then
                    break
                end

                if not Function.IsTargetGood(plr) then
                    break
                end

                if (hrp.Position - thrp.Position).Magnitude > v1.MaxBlobGrabDist then
                    hrp.CFrame = thrp.CFrame + Vector3.new(0, -15, 5)
                end

                BlobGrabRelease(blob, thrp, "Left")
                task.wait(0.003)
            until isnetworkowner(thrp) or tick() - start > v2.Target.TimeOut
        end
    end

    if method == "Kick" then
        local Center = Home.Position + Vector3.new(0, 30, 0)
        local Radius = 20
        local PlayerList = {}
        
        for _, plr in ipairs(v2.Target.GoodBlobTargets) do
            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")

            if thrp and isnetworkowner(thrp) then
                table.insert(PlayerList, thrp)
            end
        end

        local Count = #PlayerList

        for i, thrp in ipairs(PlayerList) do
            local Angle = (i - 1) / Count * math.pi * 2
            local X = math.cos(Angle) * Radius
            local Z = math.sin(Angle) * Radius

            thrp.CFrame = CFrame.new(Center + Vector3.new(X, 0, Z))

            thrp.AssemblyLinearVelocity = Vector3.zero
            thrp.AssemblyAngularVelocity = Vector3.zero
        end

        hrp.CFrame = Home
        Function.StopNoclip()
        Function.UnfloatMe(hrp)

        for _, thrp in ipairs(PlayerList) do
            Event.sno:FireServer(thrp, thrp.CFrame)
            task.wait(0.05)
            Event.dgl:FireServer(thrp)
        end

        task.wait(0.05)

        for _, thrp in ipairs(PlayerList) do
            if thrp.Parent and isnetworkowner(thrp) then
                BlobGrab(blob, thrp, "Left")
            end
        end
    end
end
ObjectBoxTabs.BlobmanTarget:AddDivider()
ObjectBoxTabs.BlobmanTarget:AddButton({
    Text = "Run Method Once",
    Func = function()
        if v2.Target.BlobmanMethod == "Kill" then
            RunBlobMethod("Kill", "Release", true, false)
        elseif v2.Target.BlobmanMethod == "Freeze" then
            RunBlobMethod("Freeze", "Release", true, false)
        elseif v2.Target.BlobmanMethod == "Kick" then 
            RunBlobMethod("Kick", "Sno", false, false)
        elseif v2.Target.BlobmanMethod == "Float" then 
            RunBlobMethod("Float", "Release", true, false)
        elseif v2.Target.BlobmanMethod == "Bring" then 
            RunBlobMethod("Bring", "Release", true, false)
        elseif v2.Target.BlobmanMethod == "Control" then 
            RunBlobMethod("Control", "Release", true, false)
        end
    end
})
ObjectBoxTabs.BlobmanTarget:AddButton({
    Text = "Run Method Once Server",
    Func = function()
        if v2.Target.BlobmanMethod == "Kill" then
            RunBlobMethod("Kill", "Release", true, true)
        elseif v2.Target.BlobmanMethod == "Freeze" then
            RunBlobMethod("Freeze", "Release", true, true)
        elseif v2.Target.BlobmanMethod == "Kick" then 
            RunServerBlob("Kick")
        elseif v2.Target.BlobmanMethod == "Float" then 
            RunBlobMethod("Float", "Release", true, true)
        elseif v2.Target.BlobmanMethod == "Bring" then 
            RunBlobMethod("Bring", "Release", true, true)
        elseif v2.Target.BlobmanMethod == "Control" then 
            RunBlobMethod("Control", "Release", true, true)
        end
    end
})
-------------------------->> [Blobman Settings] <<--------------------------
ObjectBoxTabs.TargetSettings:AddDivider("Server Kick")
ObjectBoxTabs.TargetSettings:AddDropdown("KickServerMethod", {
    Text = "Server Kick Method",
    Values = {"Heaven", "Shape"},
    Default = "Heaven",
    Multi = false,
    AllowNull = false,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Target.KickServerMethod = v
        KickServerShape:SetVisible(v == "Shape")
    end
})
KickServerShape = ObjectBoxTabs.TargetSettings:AddDropdown("KickServerMethod", {
    Text = "Shape",
    Values = {"Circle"},
    Default = "Circle",
    Multi = false,
    AllowNull = false,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Target.KickServerShape = v
    end
})
KickServerShape:SetVisible(false)
ObjectBoxTabs.TargetSettings:AddToggle("ShouldLineLag", {
	Text = "Should Line Lag",
	Default = false,
	Callback = function(v)
        v2.Target.PlayerShouldLag = v
	end
})
ObjectBoxTabs.BlobmanSettings:AddDivider("Control Server")
ObjectBoxTabs.BlobmanSettings:AddSlider("ControlledWS", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Target.ControlledWS = v
    end
})
ObjectBoxTabs.BlobmanSettings:AddSlider("ControlledJP", {
    Text = "JumpPower",
    Default = 24,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Target.ControlledJP = v
    end
})
ObjectBoxTabs.BlobmanSettings:AddToggle("FollowMe", {
	Text = "Follow Me",
	Default = false,
	Callback = function(v)
        v2.Target.FollowMe = v
	end
})
ObjectBoxTabs.BlobmanSettings:AddDropdown("ControlledTeleportLocation", {
    Text = "Location",
    Values = {"Chinese Roof", "Small Cave", "Big Cave", "Island Cave", "Goon Cave"},
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    Callback = function(v)
        v2.Target.ControlledTeleportLocation = v
    end
})
ObjectBoxTabs.BlobmanSettings:AddButton({
    Text = "Teleport",
    Func = function()
        for _, plr in ipairs(v2.Target.GoodBlobTargets) do
            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            if thrp and isnetworkowner(thrp) then
                thrp.CFrame = v2.Location[v2.Target.ControlledTeleportLocation]
            end
        end
    end
})
ObjectBoxTabs.BlobmanSettings:AddButton({
    Text = "Jump",
    Func = function()
        for _, plr in ipairs(v2.Target.GoodBlobTargets) do
            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar and tchar:FindFirstChild("Humanoid")
            if thrp and isnetworkowner(thrp) then
                thum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
})
ObjectBoxTabs.BlobmanSettings:AddButton({
    Text = "Kill",
    Func = function()
        for _, plr in ipairs(v2.Target.GoodBlobTargets) do
            local tchar = plr.Character
            local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
            local thum = tchar and tchar:FindFirstChild("Humanoid")
            if thrp and isnetworkowner(thrp) then
                thum:ChangeState(Enum.HumanoidStateType.Dead)
            end
        end
    end
})
-------------------------->> [Objects] <<--------------------------
local ObjectBoxTabs = {
    Effect = GP.Effect:AddTab("Effects", "sparkles"),
    Explode = GP.Bomb:AddTab("Explode", "bomb"),
}
-------------------------->> [Get Targets] <<--------------------------
ObjectBoxTabs.Effect:AddDropdown("MyDropdown", {
    Values = {},
    Default = nil,
    Multi = true,
    Text = "Select Target",
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Callback = function(v)
        v2.Object.EffectTargets = v
        for plr, selected in pairs(v2.Object.EffectTargets) do
            if selected then
                print(plr.Name)
            end
        end
    end
})
ObjectBoxTabs.Explode:AddDropdown("MyDropdown", {
    Values = {},
    Default = nil,
    Multi = true,
    Text = "Select Target",
    AllowNull = true,
    Searchable = true,
    MaxVisibleDropdownItems = 6,
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    Callback = function(v)
        v2.Object.ExplodeTargets = v
    end
})
-------------------------->> [Banana Target] <<--------------------------

-------------------------->> [Visual] <<--------------------------
local VisualBoxTabs = {
    Skybox = GP.SkyWeather:AddTab("Skybox", "grid-2x2"),
    Weather = GP.SkyWeather:AddTab("Weather", "cloudy"),
    Shaders = GP.SkyWeather:AddTab("Shaders", "sun-moon"),
}
-------------------------->> [PCLD] <<--------------------------
PCLD = GP.PCLD:AddToggle("PCLD", {
	Text = "PCLD",
	Default = false,
	Callback = function(v)
		v2.Visual.PCLD = v
		if v then
			for _, p in ipairs(workspace:GetChildren()) do
				if p:IsA("BasePart") and p.Name == "PlayerCharacterLocationDetector" then
					local sb = Instance.new("SelectionBox")
					sb.Color3 = v2.Visual.sbColor
					sb.SurfaceColor3 = v2.Visual.sbSurfaceColor
					sb.LineThickness = 0.05
					sb.SurfaceTransparency = 0.45
					sb.Adornee = p
					sb.Parent = p
					table.insert(v2.Visual.sbTable, sb)
				end
			end
			v2.Visual.PCLDAdded = workspace.ChildAdded:Connect(function(c)
				if c:IsA("BasePart") and c.Name == "PlayerCharacterLocationDetector" then
					local sb = Instance.new("SelectionBox")
					sb.Color3 = v2.Visual.sbColor
					sb.SurfaceColor3 = v2.Visual.sbSurfaceColor
					sb.LineThickness = 0.05
					sb.SurfaceTransparency = 0.45
					sb.Adornee = c
					sb.Parent = c
					table.insert(v2.Visual.sbTable, sb)
				end
			end)
		else
			for _, sb in ipairs(v2.Visual.sbTable) do
                sb:Destroy()
			end
			table.clear(v2.Visual.sbTable)
			if v2.Visual.PCLDAdded then
				v2.Visual.PCLDAdded:Disconnect()
				v2.Visual.PCLDAdded = nil
			end
		end
	end
})
PCLD:AddColorPicker("sbSurfaceColor", {
	Default = v2.Visual.sbSurfaceColor,
	Title = "Surface Color",
	Resizable = true,
	Callback = function(v)
		v2.Visual.sbSurfaceColor = v
		if v2.Visual.PCLD then
			for _, sb in ipairs(v2.Visual.sbTable) do
				Function.Tween(sb, {SurfaceColor3 = v}, 1)
				v2.Visual.sbSurfaceColor = v
			end
		end
	end
})
PCLD:AddColorPicker("sbColor", {
	Default = v2.Visual.sbColor,
	Title = "Outline Color",
	Resizable = true,
	Callback = function(v)
		v2.Visual.sbColor = v
		if v2.Visual.PCLD then
			for _, sb in ipairs(v2.Visual.sbTable) do
				Function.Tween(sb,  {Color3 = v}, 1)
				v2.Visual.sbColor = v
			end
		end
	end
})
-------------------------->> [Warning] <<--------------------------
GP.Warning:AddDivider("Anti-Kick")
AntiKickWarning = GP.Warning:AddToggle("AntiKickWarn", {
    Text = "Anti-Kick Warn",
    Default = false,
    Callback = function(v)
        if v then
            v2.Visual.AntiKickWarn = gs.Rs.Heartbeat:Connect(function()
                for _, plr in ipairs(gs.Players:GetPlayers()) do
                    local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                    for _, toy in ipairs(ToyFolder:GetChildren()) do
                        if not toy:IsA("Model") then continue end
                        local Sticky = toy:FindFirstChild("StickyPart")
                        local Weld = Sticky and Sticky:FindFirstChild("StickyWeld")
                        local AttachedPart = Weld and Weld.Part1
                        local hl = toy:FindFirstChild("Kaylis_Warn")
                        if hl and not AttachedPart then hl:Destroy() end
                        if not AttachedPart then continue end
                        if AttachedPart.Name ~= "FirePlayerPart" then continue end
                        local tchar = AttachedPart:FindFirstAncestorOfClass("Model")
                        local tplr = tchar and gs.Players:GetPlayerFromCharacter(tchar)
                        if not tplr or tplr == v1.player then continue end
                        if not hl then
                            hl = Instance.new("Highlight", toy)
                            hl.Name = "Kaylis_Warn"
                            hl.FillColor = v2.Visual.AntiKickWarnFC
                            hl.FillTransparency = v2.Visual.AntiKickWarnTrans
                            hl.OutlineColor = v2.Visual.AntiKickWarnOC
                            Function.Notify("Display: "..tplr.DisplayName .." | Username: ".. tplr.Name .." | has Anti-Kick")
                        end
                    end
                end
            end)
        else
            if v2.Visual.AntiKickWarn then
                v2.Visual.AntiKickWarn:Disconnect()
                v2.Visual.AntiKickWarn = nil
            end
            for _, plr in ipairs(gs.Players:GetPlayers()) do
                local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                for _, toy in ipairs(ToyFolder:GetChildren()) do
                    local hl = toy:FindFirstChild("Kaylis_Warn")
                    if hl then
                        hl:Destroy()
                    end
                end
            end
        end
    end
})
AntiKickWarning:AddColorPicker("AntiKickWarnFC", {
    Default = Color3.fromRGB(255, 0, 25),
    Title = "Fill Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.AntiKickWarnFC = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Warn")
                if hl then
                    Function.Tween(hl, {FillColor = v}, 1)
                end
            end
        end
    end
})
AntiKickWarning:AddColorPicker("AntiKickWarnOC", {
    Default = Color3.fromRGB(215, 0, 25),
    Title = "Outline Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.AntiKickWarnOC = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Warn")
                if hl then
                    Function.Tween(hl, {OutlineColor = v}, 1)
                end
            end
        end
    end
})
GP.Warning:AddSlider("AntiKickWarnTrans", {
    Text = "Anti-Kick Transparency",
    Default = 0.4,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Visual.AntiKickWarnTrans = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Warn")
                if hl then
                    Function.Tween(hl, {FillTransparency = v}, 1)
                end
            end
        end
    end
})
-------------------------->> [Camera] <<--------------------------
FOV = GP.Camera:AddSlider("FOVSlider", {
    Text = "FOV",
    Default = 70,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        Function.Tween(v1.camera, {FieldOfView = v}, 0.35)
    end
})
ThirdPerson = GP.Camera:AddToggle("ThirdPerson", {
	Text = "Third Person",
	Default = false,
	Callback = function(v)
		if v then
			v1.player.CameraMaxZoomDistance = 1000
			v1.player.CameraMode = Enum.CameraMode.Classic
			v1.ThirdPersonVis = gs.Rs.RenderStepped:Connect(function()
				local char = v1.player.Character
				local head = char and char:FindFirstChild("Head")
				if not head then return end
				local Dist = (v1.camera.CFrame.Position - head.Position).Magnitude
				local rotate = v1.player.PlayerGui.ControlsGui.PCFrame.StopRotating.Visible
				local Invis = Dist < 1.5 or rotate
				for _, obj in ipairs(char:GetDescendants()) do
					if obj:IsA("BasePart")
						and obj.Name ~= "HumanoidRootPart"
						and obj.Name ~= "FirePlayerPart"
						and obj.Name ~= "RagdollTouchedHitbox"
						and obj.Name ~= "KeyboardPart"
						and obj.Name ~= "CamPart"
						and not (obj.Name == "Handle" and obj.Parent and obj.Parent.Name == "TypingKeyboardMyWorld") then
						obj.Transparency = Invis and 1 or 0
						obj.LocalTransparencyModifier = Invis and 1 or 0
					end
				end
				if v3.CloneActive then
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            obj.LocalTransparencyModifier = 1
                        elseif obj:IsA("Decal") or obj:IsA("Texture") then
                            obj.Transparency = 1
                        end
                    end
                end
			end)
		else
			if v1.ThirdPersonVis then
				v1.ThirdPersonVis:Disconnect()
				v1.ThirdPersonVis = nil
			end
			v1.player.CameraMode = Enum.CameraMode.LockFirstPerson
		end
	end
})
CameraNoclip = GP.Camera:AddToggle("CameraNoclip", {
	Text = "Camera No-Clip",
	Default = false,
	Callback = function(v)
		if v then
			v1.player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
		else
			v1.player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        end
	end
})
GP.Camera:AddButton({
    Text = "Reset Camera",
    Func = function()
        FOV:SetValue(70)
        ThirdPerson:SetValue(false)
        Function.Notify("Reset camera settings!", 3)
    end
})
-------------------------->> [Map] <<--------------------------
GP.Vmap:AddDivider("Map")
ToggleMapColors = GP.Vmap:AddToggle("ToggleMapColor", {
    Text = "Toggle Map Colors",
    Default = false,
    Callback = function(v)
        v2.Visual.ToggleMapColors = v
        if v then
            for _, p in ipairs(workspace.Map:GetDescendants()) do
                if p:IsA("BasePart") then
                    if p.Name == "Grass" then Function.Tween(p, {Color = v2.Visual.GrassColor}, 1) end
                    if p.Name == "LushGrass" then Function.Tween(p, {Color = v2.Visual.LushColor}, 1) end
                    if p.Name == "Rock" then Function.Tween(p, {Color = v2.Visual.RockColor}, 1) end
                    if p.Name == "Dirt" then Function.Tween(p, {Color = v2.Visual.DirtColor}, 1) end
                    if p.Name == "WasteGrass" then Function.Tween(p, {Color = v2.Visual.WasteColor}, 1) end
                    if p.Name == "Snow" then Function.Tween(p, {Color = v2.Visual.SnowColor}, 1) end
                    if p.Name == "Sand" then Function.Tween(p, {Color = v2.Visual.SandColor}, 1) end
                end
            end
        else
            for _, p in ipairs(workspace.Map:GetDescendants()) do
                if p:IsA("BasePart") then
                    if p.Name == "Grass" then Function.Tween(p, {Color = Color3.fromRGB(124, 156, 107)}, 1) end
                    if p.Name == "LushGrass" then Function.Tween(p, {Color = Color3.fromRGB(61, 100, 54)}, 1) end
                    if p.Name == "Rock" then Function.Tween(p, {Color = Color3.fromRGB(163, 161, 165)}, 1) end
                    if p.Name == "Dirt" then Function.Tween(p, {Color = Color3.fromRGB(175, 147, 131)}, 1) end
                    if p.Name == "WasteGrass" then Function.Tween(p, {Color = Color3.fromRGB(84, 63, 84)}, 1) end
                    if p.Name == "Snow" then Function.Tween(p, {Color = Color3.fromRGB(248, 248, 248)}, 1) end
                    if p.Name == "Snow" then Function.Tween(p, {Color = Color3.fromRGB(240, 230, 198)}, 1) end
                end
            end
        end
    end
})
ToggleMapColors:AddColorPicker("GrassColor", {
    Default = v2.Visual.GrassColor,
    Title = "Grass Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.GrassColor = v
        if not v2.Visual.ToggleMapColors then return end
        for _, p in ipairs(workspace.Map:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Grass" then 
                    Function.Tween(p, {Color = v}, 1)
                end
            end
        end
    end
})
ToggleMapColors:AddColorPicker("LushGrassColor", {
    Default = v2.Visual.LushColor,
    Title = "Lush Grass Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.LushColor = v
        if not v2.Visual.ToggleMapColors then return end
        for _, p in ipairs(workspace.Map:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "LushGrass" then 
                    Function.Tween(p, {Color = v}, 1)
                end
            end
        end
    end
})
ToggleMapColors:AddColorPicker("RockColor", {
    Default = v2.Visual.RockColor,
    Title = "Rock Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.RockColor = v
        if not v2.Visual.ToggleMapColors then return end
        for _, p in ipairs(workspace.Map:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Rock" then 
                    Function.Tween(p, {Color = v}, 1)
                end
            end
        end
    end
})
ToggleMapColors:AddColorPicker("DirtColor", {
    Default = v2.Visual.DirtColor,
    Title = "Dirt Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.DirtColor = v
        if not v2.Visual.ToggleMapColors then return end
        for _, p in ipairs(workspace.Map:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Dirt" then 
                    Function.Tween(p, {Color = v}, 1)
                end
            end
        end
    end
})
ToggleMapColors:AddColorPicker("WasteGrassColor", {
    Default = v2.Visual.WasteColor,
    Title = "Waste Grass Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.WasteColor = v
        if not v2.Visual.ToggleMapColors then return end
        for _, p in ipairs(workspace.Map:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "WasteGrass" then 
                    Function.Tween(p, {Color = v}, 1)
                end
            end
        end
    end
})
ToggleMapColors:AddColorPicker("SnowColor", {
    Default = v2.Visual.SnowColor,
    Title = "Snow Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.SnowColor = v
        if not v2.Visual.ToggleMapColors then return end
        for _, p in ipairs(workspace.Map:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Snow" then 
                    Function.Tween(p, {Color = v}, 1)
                end
            end
        end
    end
})
ToggleMapColors:AddColorPicker("SandColor", {
    Default = v2.Visual.SandColor,
    Title = "Sand Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.SandColor = v
        if not v2.Visual.ToggleMapColors then return end
        for _, p in ipairs(workspace.Map:GetDescendants()) do
            if p:IsA("BasePart") then
                if p.Name == "Sand" then 
                    Function.Tween(p, {Color = v}, 1)
                end
            end
        end
    end
})
GP.Vmap:AddDivider("Water")
RealisticWater = GP.Vmap:AddToggle("RealisticWater", {
    Text = "Realistic Water",
    Default = false,
    Callback = function(v)
        if v then
            for _, p in ipairs(workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel:GetDescendants()) do
                if p:IsA("BasePart") then
                    workspace.Terrain:FillBlock(p.CFrame, p.Size, Enum.Material.Water)
                    p.Transparency = 1
                    workspace.Terrain.WaterColor = v2.Visual.WaterColor
                    workspace.Terrain.WaterReflectance = v2.Visual.WaterReflect
                    workspace.Terrain.WaterTransparency = v2.Visual.WaterTrans
                    workspace.Terrain.WaterWaveSize = v2.Visual.WaveSize
                    workspace.Terrain.WaterWaveSpeed = v2.Visual.WaveSpeed
                end
            end
        else
            for _, p in ipairs(workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel:GetDescendants()) do
                if p:IsA("BasePart") then
                    workspace.Terrain:FillBlock(p.CFrame, p.Size + Vector3.new(4, 4, 4), Enum.Material.Air)
                    p.Transparency = 0
                end
            end
        end
    end
})
RealisticWater:AddColorPicker("WaterColor", {
    Default = v2.Visual.WaterColor,
    Title = "Water Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.WaterColor = v
        Function.Tween(workspace.Terrain, {WaterColor = v}, 1)
    end
})
GP.Vmap:AddSlider("WaterReflectance", {
    Text = "Water Reflectance",
    Default = v2.Visual.WaterReflect,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Visual.WaterReflect = v
        Function.Tween(workspace.Terrain, {WaterReflectance = v}, 1)
    end
})
GP.Vmap:AddSlider("WaterTransparency", {
    Text = "Water Transparency",
    Default = v2.Visual.WaterTrans,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Visual.WaterTrans = v
        Function.Tween(workspace.Terrain, {WaterTransparency = v}, 1)
    end
})
GP.Vmap:AddSlider("WaterWaveSize", {
    Text = "Wave Size",
    Default = v2.Visual.WaveSize,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Visual.WaveSize = v
        Function.Tween(workspace.Terrain, {WaterWaveSize = v}, 1)
    end
})
GP.Vmap:AddSlider("WaterWaveSpeed", {
    Text = "Wave Speed",
    Default = v2.Visual.WaveSpeed,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Visual.WaveSpeed = v
        Function.Tween(workspace.Terrain, {WaterWaveSpeed = v}, 1)
    end
})
-------------------------->> [Objects] <<--------------------------
GP.Objects:AddDivider("Local Player")
PlayerHLToys = GP.Objects:AddToggle("PlayerHLToys", {
    Text = "Highlight Your Toys",
    Default = false,
    Callback = function(v)
        if v then
            for _, toy in ipairs(v1.inv:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Self") or toy:FindFirstChildWhichIsA("Highlight")
                if not hl then
                    hl = Instance.new("Highlight", toy)
                    hl.Name = "Kaylis_Self"
                    hl.FillColor = v2.Visual.PlayerObjectFC
                    hl.FillTransparency = 1
                    hl.OutlineColor = v2.Visual.PlayerObjectOC
                    Function.Tween(hl, {FillTransparency = v2.Visual.PlayerObjectTrans}, 1)
                end
            end
            v2.Visual.PlayerToyAddedConn = v1.inv.ChildAdded:Connect(function(c)
                local hl = c:FindFirstChild("Kaylis_Self") or c:FindFirstChildWhichIsA("Highlight")
                if not hl then
                    hl = Instance.new("Highlight", c)
                    hl.Name = "Kaylis_Self"
                    hl.FillColor = v2.Visual.PlayerObjectFC
                    hl.FillTransparency = 1
                    hl.OutlineColor = v2.Visual.PlayerObjectOC
                    Function.Tween(hl, {FillTransparency = v2.Visual.PlayerObjectTrans}, 1)
                end
            end)
        else
            if v2.Visual.PlayerToyAddedConn then
                v2.Visual.PlayerToyAddedConn:Disconnect()
                v2.Visual.PlayerToyAddedConn = nil
            end
            for _, toy in ipairs(v1.inv:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Self")
                if hl then
                    hl:Destroy()
                end
            end
        end
    end
})
PlayerHLToys:AddColorPicker("PlayerObjectFC", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Fill Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.PlayerObjectFC = v
        for _, toy in ipairs(v1.inv:GetChildren()) do
            if not toy:IsA("Model") then continue end
            local hl = toy:FindFirstChild("Kaylis_Self")
            if hl then
                Function.Tween(hl, {FillColor = v}, 1)
            end
        end
    end
})
PlayerHLToys:AddColorPicker("PlayerObjectOC", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Outline Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.PlayerObjectOC = v
        for _, toy in ipairs(v1.inv:GetChildren()) do
            if not toy:IsA("Model") then continue end
            local hl = toy:FindFirstChild("Kaylis_Self")
            if hl then
                Function.Tween(hl, {OutlineColor = v}, 1)
            end
        end
    end
})
GP.Objects:AddSlider("PlayerObjectTrans", {
    Text = "Object Transparency",
    Default = 0.4,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Visual.PlayerObjectTrans = v
        for _, toy in ipairs(v1.inv:GetChildren()) do
            if not toy:IsA("Model") then continue end
            local hl = toy:FindFirstChild("Kaylis_Self")
            if hl then
                Function.Tween(hl, {FillTransparency = v}, 1)
            end
        end
    end
})
GP.Objects:AddDivider("Friends")
FriendHLToys = GP.Objects:AddToggle("FriendHLToys", {
    Text = "Highlight Friends Toys",
    Default = false,
    Callback = function(v)
        v2.Visual.FriendToys = v
        if v then
            for _, plr in ipairs(gs.Players:GetPlayers()) do
                if plr == v1.player or not plr:IsFriendsWith(v1.player.UserId) then continue end
                local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                for _, toy in ipairs(ToyFolder:GetChildren()) do
                    if not toy:IsA("Model") then continue end
                    local hl = toy:FindFirstChild("Kaylis_Friend") or toy:FindFirstChildWhichIsA("Highlight")
                    if not hl then
                        hl = Instance.new("Highlight", toy)
                        hl.Name = "Kaylis_Friend"
                        hl.FillColor = v2.Visual.FriendObjectFC
                        hl.FillTransparency = 1
                        hl.OutlineColor = v2.Visual.FriendObjectOC
                        Function.Tween(hl, {FillTransparency = v2.Visual.FriendObjectTrans}, 1)
                    end
                end
                table.insert(v2.Visual.CurrentFriendFolder, ToyFolder.ChildAdded:Connect(function(t)
                    if not t:IsA("Model") then return end
                    local hl = t:FindFirstChild("Kaylis_Friend") or t:FindFirstChildWhichIsA("Highlight")
                    if not hl then
                        hl = Instance.new("Highlight", t)
                        hl.Name = "Kaylis_Friend"
                        hl.FillColor = v2.Visual.FriendObjectFC
                        hl.FillTransparency = 1
                        hl.OutlineColor = v2.Visual.FriendObjectOC
                        Function.Tween(hl, {FillTransparency = v2.Visual.FriendObjectTrans}, 1)
                    end
                end))
            end
            v2.Visual.FriendAdded = gs.Players.PlayerAdded:Connect(function(plr)
                if plr == v1.player or not plr:IsFriendsWith(v1.player.UserId) then return end
                local ToyFolder = workspace:WaitForChild(plr.Name.."SpawnedInToys", 5)
                table.insert(v2.Visual.CurrentFriendFolder,
                    ToyFolder.ChildAdded:Connect(function(t)
                        if not t:IsA("Model") then return end
                        local hl = t:FindFirstChild("Kaylis_Friend") or t:FindFirstChildWhichIsA("Highlight")
                        if not hl then
                            hl = Instance.new("Highlight", t)
                            hl.Name = "Kaylis_Friend"
                            hl.FillColor = v2.Visual.FriendObjectFC
                            hl.FillTransparency = 1
                            hl.OutlineColor = v2.Visual.FriendObjectOC
                            Function.Tween(hl, {FillTransparency = v2.Visual.FriendObjectTrans}, 1)
                        end
                    end)
                )
            end)
        else
            for _, conn in ipairs(v2.Visual.CurrentFriendFolder) do
                conn:Disconnect()
            end
            table.clear(v2.Visual.CurrentFriendFolder)
            if v2.Visual.FriendAdded then
                v2.Visual.FriendAdded:Disconnect()
                v2.Visual.FriendAdded = nil
            end
            for _, plr in ipairs(gs.Players:GetPlayers()) do
                if plr == v1.player or not plr:IsFriendsWith(v1.player.UserId) then continue end
                local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                for _, toy in ipairs(ToyFolder:GetChildren()) do
                    if not toy:IsA("Model") then continue end
                    local hl = toy:FindFirstChild("Kaylis_Friend")
                    if hl then
                        hl:Destroy()
                    end
                end
            end
        end
    end
})
FriendHLToys:AddColorPicker("FriendObjectFC", {
    Default = Color3.fromRGB(40, 170, 255),
    Title = "Fill Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.FriendObjectFC = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            if plr == v1.player or not plr:IsFriendsWith(v1.player.UserId) then continue end
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Friend")
                if hl then
                    Function.Tween(hl, {FillColor = v}, 1)
                end
            end
        end
    end
})
FriendHLToys:AddColorPicker("FriendObjectOC", {
    Default = Color3.fromRGB(120, 210, 255),
    Title = "Outline Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.FriendObjectOC = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            if plr == v1.player or not plr:IsFriendsWith(v1.player.UserId) then continue end
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Friend")
                if hl then
                    Function.Tween(hl, {OutlineColor = v}, 1)
                end
            end
        end
    end
})
GP.Objects:AddSlider("FriendObjectTrans", {
    Text = "Friend Object Transparency",
    Default = 0.4,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Visual.FriendObjectTrans = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            if plr == v1.player or not plr:IsFriendsWith(v1.player.UserId) then continue end
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Friend")
                if hl then
                    Function.Tween(hl, {FillTransparency = v}, 1)
                end
            end
        end
    end
})
GP.Objects:AddDivider("Strangers")
StrangerHLToys = GP.Objects:AddToggle("StrangerHLToys", {
    Text = "Highlight Strangers Toys",
    Default = false,
    Callback = function(v)
        v2.Visual.StrangerToys = v
        if v then
            for _, plr in ipairs(gs.Players:GetPlayers()) do
                if plr == v1.player or plr:IsFriendsWith(v1.player.UserId) then continue end
                local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                for _, toy in ipairs(ToyFolder:GetChildren()) do
                    if not toy:IsA("Model") then continue end
                    local hl = toy:FindFirstChild("Kaylis_Stranger") or toy:FindFirstChildWhichIsA("Highlight")
                    if not hl then
                        hl = Instance.new("Highlight", toy)
                        hl.Name = "Kaylis_Stranger"
                        hl.FillColor = v2.Visual.StrangerObjectFC
                        hl.FillTransparency = 1
                        hl.OutlineColor = v2.Visual.StrangerObjectOC
                        Function.Tween(hl, {FillTransparency = v2.Visual.StrangerObjectTrans}, 1)
                    end
                end
                table.insert(v2.Visual.CurrentStrangerFolder, ToyFolder.ChildAdded:Connect(function(t)
                    if not t:IsA("Model") then return end
                    local hl = t:FindFirstChild("Kaylis_Stranger") or t:FindFirstChildWhichIsA("Highlight")
                    if not hl then
                        hl = Instance.new("Highlight", t)
                        hl.Name = "Kaylis_Stranger"
                        hl.FillColor = v2.Visual.StrangerObjectFC
                        hl.FillTransparency = 1
                        hl.OutlineColor = v2.Visual.StrangerObjectOC
                        Function.Tween(hl, {FillTransparency = v2.Visual.StrangerObjectTrans}, 1)
                    end
                end))
            end
            v2.Visual.StrangerAdded = gs.Players.PlayerAdded:Connect(function(plr)
                if plr == v1.player or plr:IsFriendsWith(v1.player.UserId) then return end
                local ToyFolder = workspace:WaitForChild(plr.Name.."SpawnedInToys", 5)
                table.insert(v2.Visual.CurrentStrangerFolder,
                    ToyFolder.ChildAdded:Connect(function(t)
                        if not t:IsA("Model") then return end
                        local hl = t:FindFirstChild("Kaylis_Stranger") or t:FindFirstChildWhichIsA("Highlight")
                        if not hl then
                            hl = Instance.new("Highlight", t)
                            hl.Name = "Kaylis_Stranger"
                            hl.FillColor = v2.Visual.StrangerObjectFC
                            hl.FillTransparency = 1
                            hl.OutlineColor = v2.Visual.StrangerObjectOC
                            Function.Tween(hl, {
                                FillTransparency = v2.Visual.StrangerObjectTrans
                            }, 1)
                        end
                    end)
                )
            end)
        else
            for _, conn in ipairs(v2.Visual.CurrentStrangerFolder) do
                conn:Disconnect()
            end
            table.clear(v2.Visual.CurrentStrangerFolder)
            if v2.Visual.StrangerAdded then
                v2.Visual.StrangerAdded:Disconnect()
                v2.Visual.StrangerAdded = nil
            end
            for _, plr in ipairs(gs.Players:GetPlayers()) do
                if plr == v1.player or plr:IsFriendsWith(v1.player.UserId) then continue end
                local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                for _, toy in ipairs(ToyFolder:GetChildren()) do
                    if not toy:IsA("Model") then continue end
                    local hl = toy:FindFirstChild("Kaylis_Stranger")
                    if hl then
                        hl:Destroy()
                    end
                end
            end
        end
    end
})
StrangerHLToys:AddColorPicker("StrangerObjectFC", {
    Default =  Color3.fromRGB(255, 70, 70),
    Title = "Fill Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.StrangerObjectFC = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            if plr == v1.player or plr:IsFriendsWith(v1.player.UserId) then continue end
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Stranger")
                if hl then
                    Function.Tween(hl, {FillColor = v}, 1)
                end
            end
        end
    end
})
StrangerHLToys:AddColorPicker("StrangerObjectOC", {
    Default = Color3.fromRGB(255, 160, 160),
    Title = "Outline Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.StrangerObjectOC = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            if plr == v1.player or plr:IsFriendsWith(v1.player.UserId) then continue end
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Stranger")
                if hl then
                    Function.Tween(hl, {OutlineColor = v}, 1)
                end
            end
        end
    end
})
GP.Objects:AddSlider("StrangerObjectTrans", {
    Text = "Stranger Object Transparency",
    Default = 0.4,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Visual.StrangerObjectTrans = v
        for _, plr in ipairs(gs.Players:GetPlayers()) do
            if plr == v1.player or plr:IsFriendsWith(v1.player.UserId) then continue end
            local ToyFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
            for _, toy in ipairs(ToyFolder:GetChildren()) do
                if not toy:IsA("Model") then continue end
                local hl = toy:FindFirstChild("Kaylis_Stranger")
                if hl then
                    Function.Tween(hl, {FillTransparency = v}, 1)
                end
            end
        end
    end
})
-------------------------->> [Skybox] <<--------------------------
ToggleSkybox = VisualBoxTabs.Skybox:AddToggle("ToggleSkybox", {
    Text = "Toggle Skybox",
    Default = false,
    Callback = function(v)
        v2.Visual.ToggleSkybox = v
        if v then
            gs.l.Sky.SkyboxUp = "rbxassetid://"..v2.Visual.SkyboxUp
            gs.l.Sky.SkyboxDn = "rbxassetid://"..v2.Visual.SkyboxDn
            gs.l.Sky.SkyboxLf = "rbxassetid://"..v2.Visual.SkyboxLf
            gs.l.Sky.SkyboxRt = "rbxassetid://"..v2.Visual.SkyboxRt
            gs.l.Sky.SkyboxFt = "rbxassetid://"..v2.Visual.SkyboxFt
            gs.l.Sky.SkyboxBk = "rbxassetid://"..v2.Visual.SkyboxBk
            BoxTop:SetVisible(true); BoxBottom:SetVisible(true); BoxLeft:SetVisible(true)
            BoxRight:SetVisible(true); BoxFront:SetVisible(true); BoxBack:SetVisible(true)
        else
            gs.l.Sky.SkyboxUp = "rbxassetid://8995814929"
            gs.l.Sky.SkyboxDn = "rbxassetid://8995686153"
            gs.l.Sky.SkyboxLf = "rbxassetid://8995816670"
            gs.l.Sky.SkyboxRt = "rbxassetid://8995816670"
            gs.l.Sky.SkyboxFt = "rbxassetid://8995816670"
            gs.l.Sky.SkyboxBk = "rbxassetid://8995816670"
            BoxTop:SetVisible(false); BoxBottom:SetVisible(false); BoxLeft:SetVisible(false)
            BoxRight:SetVisible(false); BoxFront:SetVisible(false); BoxBack:SetVisible(false)
        end
    end
})
BoxTop = VisualBoxTabs.Skybox:AddInput("skyboxUp", {
    Text = "Skybox Top",
	Default = nil,
	Numeric = false,
	Finished = true,
	ClearTextOnFocus = true,
    Visible = false,
	Placeholder = "rbxassetid://69696969",
	Callback = function(v)
        v2.Visual.SkyboxUp = v
        if not v2.Visual.ToggleSkybox then return end
        gs.l.Sky.SkyboxUp = "rbxassetid://"..v
	end,
})
BoxBottom = VisualBoxTabs.Skybox:AddInput("skyboxDn", {
    Text = "Skybox Bottom",
	Default = nil,
	Numeric = false,
	Finished = true,
	ClearTextOnFocus = true,
    Visible = false,
	Placeholder = "rbxassetid://69696969",
	Callback = function(v)
        v2.Visual.SkyboxDn = v
        if not v2.Visual.ToggleSkybox then return end
        gs.l.Sky.SkyboxDn = "rbxassetid://"..v
	end,
})
BoxLeft = VisualBoxTabs.Skybox:AddInput("SkyboxLf", {
    Text = "Skybox Left",
	Default = nil,
	Numeric = false,
	Finished = true,
	ClearTextOnFocus = true,
    Visible = false,
	Placeholder = "rbxassetid://69696969",
	Callback = function(v)
        v2.Visual.SkyboxLf = v
        if not v2.Visual.ToggleSkybox then return end
        gs.l.Sky.SkyboxLf = "rbxassetid://"..v
	end,
})
BoxRight = VisualBoxTabs.Skybox:AddInput("SkyboxRt", {
    Text = "Skybox Right",
	Default = nil,
	Numeric = false,
	Finished = true,
	ClearTextOnFocus = true,
    Visible = false,
	Placeholder = "rbxassetid://69696969",
	Callback = function(v)
        v2.Visual.SkyboxRt = v
        if not v2.Visual.ToggleSkybox then return end
        gs.l.Sky.SkyboxRt = "rbxassetid://"..v
	end,
})
BoxFront = VisualBoxTabs.Skybox:AddInput("SkyboxFt", {
    Text = "Skybox Front",
	Default = nil,
	Numeric = false,
	Finished = true,
	ClearTextOnFocus = true,
    Visible = false,
	Placeholder = "rbxassetid://69696969",
	Callback = function(v)
        v2.Visual.SkyboxFt = v
        if not v2.Visual.ToggleSkybox then return end
        gs.l.Sky.SkyboxFt = "rbxassetid://"..v
	end,
})
BoxBack = VisualBoxTabs.Skybox:AddInput("SkyboxBk", {
    Text = "Skybox Back",
	Default = nil,
	Numeric = false,
	Finished = true,
	ClearTextOnFocus = true,
    Visible = false,
	Placeholder = "rbxassetid://69696969",
	Callback = function(v)
        v2.Visual.SkyboxBk = v
        if not v2.Visual.ToggleSkybox then return end
        gs.l.Sky.SkyboxBk = "rbxassetid://"..v
	end,
})
-------------------------->> [Weather] <<--------------------------
ToggleWeather = VisualBoxTabs.Weather:AddToggle("ToggleWeather", {
    Text = "Toggle Weather",
    Default = false,
    Callback = function(v)
        v2.Visual.ToggleWeather = v
        if v then
            gs.l.ClockTime = v2.Visual.Time
            gs.l.Brightness = v2.Visual.Brightness
            gs.l.Ambient = v2.Visual.Ambient
            gs.l.LightingStyle = v2.Visual.Style
        else
            gs.l.ClockTime = 14
            gs.l.Brightness = 2
            gs.l.Ambient = Color3.fromRGB(120, 120, 120)
            gs.l.LightingStyle = Enum.LightingStyle.Soft
        end
    end
})
VisualBoxTabs.Weather:AddToggle("RealisticLighting", {
    Text = "Realistic Lighting",
    Default = false,
    Callback = function(v)
        if v then
            v2.Visual.Style = Enum.LightingStyle.Realistic
            v2.Visual.Tech = Enum.Technology.Future
            if not v2.Visual.ToggleWeather then return end
            gs.l.LightingStyle = Enum.LightingStyle.Realistic
            gs.l.Technology = Enum.Technology.Future
        else
            v2.Visual.Style = Enum.LightingStyle.Soft
            v2.Visual.Tech = Enum.Technology.Voxel
            gs.l.LightingStyle = Enum.LightingStyle.Soft
            gs.l.Technology = Enum.Technology.Voxel
        end
    end
})
ToggleWeather:AddColorPicker("LightingAmbient", {
    Default = Color3.fromRGB(120, 120, 120),
    Title = "Ambient",
    Resizable = true,
    Callback = function(v)
        v2.Visual.Ambient = v
        if not v2.Visual.ToggleWeather then return end
        Function.Tween(gs.l, {Ambient = v}, 1)
    end
})
VisualBoxTabs.Weather:AddSlider("TimeOfDay", {
    Text = "Clock Time",
    Default = 14,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        v2.Visual.Time = v
        if not v2.Visual.ToggleWeather then return end
        Function.Tween(gs.l, {ClockTime = v}, 1)
    end
})
VisualBoxTabs.Weather:AddSlider("LightingBrightness", {
    Text = "Brightness",
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        v2.Visual.Brightness = v
        if not v2.Visual.ToggleWeather then return end
        Function.Tween(gs.l, {Brightness = v}, 1)
    end
})
-------------------------->> [Shaders] <<--------------------------
ToggelShaders = VisualBoxTabs.Shaders:AddToggle("ToggleShaders", {
    Text = "Toggle Shaders",
    Default = false,
    Callback = function(v)
        if v then
            SunSize:SetVisible(true); Blur:SetVisible(true); Bloom:SetVisible(true)
            ColorCorrection:SetVisible(true); DepthOfField:SetVisible(true); SunRays:SetVisible(true)
            Atmosphere:SetVisible(true)
        else
            SunSize:SetVisible(false); Blur:SetVisible(false); Bloom:SetVisible(false)
            ColorCorrection:SetVisible(false); DepthOfField:SetVisible(false); SunRays:SetVisible(false)
            Atmosphere:SetVisible(false)

            SunSize:SetValue(false); Blur:SetValue(false); Bloom:SetValue(false)
            ColorCorrection:SetValue(false); DepthOfField:SetValue(false); SunRays:SetValue(false)
            Atmosphere:SetValue(false)
        end
    end
})
SunSize = VisualBoxTabs.Shaders:AddToggle("SunSize", {
    Text = "Sun Size",
    Default = false,
    Visible = false,
    Callback = function(v)
        if v then
            SunSizeSlider:SetVisible(true)
            Function.Tween(gs.l.Sky, {SunAngularSize = 20}, 1)
        else
            SunSizeSlider:SetVisible(false)
            Function.Tween(gs.l.Sky, {SunAngularSize = 30}, 1)
        end
    end
})
SunSizeSlider = VisualBoxTabs.Shaders:AddSlider("SunSizeSlider", {
    Text = "Size",
    Default = v2.Visual.SunSize,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.SunSize = v
        Function.Tween(gs.l.Sky, {SunAngularSize = v}, 1)
    end
})
Blur = VisualBoxTabs.Shaders:AddToggle("Blur", {
    Text = "Blur",
    Default = false,
    Visible = false,
    Callback = function(v)
        if v then
            v2.Visual.blur = Instance.new("BlurEffect", gs.l)
            v2.Visual.blur.Size = v2.Visual.BlurSize
            BlurSizeSlider:SetVisible(true)
        else
            if v2.Visual.blur then
                v2.Visual.blur:Destroy()
            end
            BlurSizeSlider:SetVisible(false)
        end
    end
})
BlurSizeSlider = VisualBoxTabs.Shaders:AddSlider("BlurSizeSlider", {
    Text = "Size",
    Default = v2.Visual.BlurSize,
    Min = 0,
    Max = 30,
    Rounding = 1,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.BlurSize = v
        Function.Tween(v2.Visual.blur, {Size = v}, 1)
    end
})
Bloom = VisualBoxTabs.Shaders:AddToggle("Bloom", {
    Text = "Bloom",
    Default = false,
    Visible = false,
    Callback = function(v)
        if v then
            v2.Visual.bloom = Instance.new("BloomEffect", gs.l)
            v2.Visual.bloom.Intensity = v2.Visual.BloomIntens
            v2.Visual.bloom.Size = v2.Visual.BloomSize
            v2.Visual.bloom.Threshold = v2.Visual.BloomThresh
            BloomIntensitySlider:SetVisible(true)
            BloomSizeSlider:SetVisible(true)
            BloomThreshSlider:SetVisible(true)
        else
            if v2.Visual.bloom then
                v2.Visual.bloom:Destroy()
            end
            BloomIntensitySlider:SetVisible(false)
            BloomSizeSlider:SetVisible(false)
            BloomThreshSlider:SetVisible(false)
        end
    end
})
BloomIntensitySlider = VisualBoxTabs.Shaders:AddSlider("BloomIntensitySlider", {
    Text = "Intensity",
    Default = v2.Visual.BloomIntens,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.BloomIntens = v
        Function.Tween(v2.Visual.bloom, {Intensity = v}, 1)
    end
})
BloomSizeSlider = VisualBoxTabs.Shaders:AddSlider("BloomSizeSlider", {
    Text = "Size",
    Default = v2.Visual.BloomSize,
    Min = 0,
    Max = 30,
    Rounding = 1,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.BloomSize = v
        Function.Tween(v2.Visual.bloom, {Size = v}, 1)
    end
})
BloomThreshSlider = VisualBoxTabs.Shaders:AddSlider("BloomThreshSlider", {
    Text = "Threshold",
    Default = v2.Visual.BloomThresh,
    Min = 0,
    Max = 3,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.BloomThresh = v
        Function.Tween(v2.Visual.bloom, {Threshold = v}, 1)
    end
})
ColorCorrection = VisualBoxTabs.Shaders:AddToggle("ColorCorrection", {
    Text = "Color Correction",
    Default = false,
    Visible = false,
    Callback = function(v)
        if v then
            v2.Visual.ColorCorrection = Instance.new("ColorCorrectionEffect", gs.l)
            v2.Visual.ColorCorrection.Brightness = v2.Visual.ccBrightness
            v2.Visual.ColorCorrection.Contrast = v2.Visual.ccContrast
            v2.Visual.ColorCorrection.Saturation = v2.Visual.ccSaturation
            v2.Visual.ColorCorrection.TintColor = v2.Visual.ccTint
            ccBrightnessSlider:SetVisible(true)
            ccContrastSlider:SetVisible(true)
            ccSaturationSlider:SetVisible(true)
        else
            if v2.Visual.ColorCorrection then
                v2.Visual.ColorCorrection:Destroy()
            end
            ccBrightnessSlider:SetVisible(false)
            ccContrastSlider:SetVisible(false)
            ccSaturationSlider:SetVisible(false)
        end
    end
})
ccBrightnessSlider = VisualBoxTabs.Shaders:AddSlider("ccBrightnessSlider", {
    Text = "Brightness",
    Default = v2.Visual.ccBrightness,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.ccBrightness = v
        Function.Tween(v2.Visual.ColorCorrection, {Brightness = v}, 1)
    end
})
ccContrastSlider = VisualBoxTabs.Shaders:AddSlider("ccContrastSlider", {
    Text = "Contrast",
    Default = v2.Visual.ccContrast,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.ccContrast = v
        Function.Tween(v2.Visual.ColorCorrection, {Contrast = v}, 1)
    end
})
ccSaturationSlider = VisualBoxTabs.Shaders:AddSlider("ccSaturationSlider", {
    Text = "Saturation",
    Default = v2.Visual.ccSaturation,
    Min = 0,
    Max = 2,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.ccSaturation = v
        Function.Tween(v2.Visual.ColorCorrection, {Saturation = v}, 1)
    end
})
ColorCorrection:AddColorPicker("ccTintColor", {
    Default = v2.Visual.ccTint,
    Title = "Tint Color",
    Resizable = true,
    Callback = function(v)
        v2.Visual.ccTint = v
        if not ColorCorrection then return end
        if v2.Visual.ColorCorrection then
            Function.Tween(v2.Visual.ColorCorrection, {TintColor = v}, 1)
        end
    end
})
DepthOfField = VisualBoxTabs.Shaders:AddToggle("DepthOfField", {
    Text = "Depth Of Field",
    Default = false,
    Visible = false,
    Callback = function(v)
        if v then
            v2.Visual.Dof = Instance.new("DepthOfFieldEffect", gs.l)
            v2.Visual.Dof.FarIntensity = v2.Visual.dofFar
            v2.Visual.Dof.FocusDistance = v2.Visual.dofFocus
            v2.Visual.Dof.InFocusRadius = v2.Visual.dofInFocus
            v2.Visual.Dof.NearIntensity = v2.Visual.dofNearIntens
            DofFocusDistanceSlider:SetVisible(true)
            DofFarIntensitySlider:SetVisible(true)
            DofFocusDistanceSlider:SetVisible(true)
            DofInFocusRadiusSlider:SetVisible(true)
        else
            if v2.Visual.Dof then
                v2.Visual.Dof:Destroy()
            end
            DofFocusDistanceSlider:SetVisible(false)
            DofFarIntensitySlider:SetVisible(false)
            DofFocusDistanceSlider:SetVisible(false)
            DofInFocusRadiusSlider:SetVisible(false)
        end
    end
})
DofFarIntensitySlider = VisualBoxTabs.Shaders:AddSlider("DofFarIntensitySlider", {
    Text = "Far Intensity",
    Default = v2.Visual.dofFar,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.dofFar = v
        Function.Tween(v2.Visual.Dof, {FarIntensity = v}, 1)
    end
})
DofFocusDistanceSlider = VisualBoxTabs.Shaders:AddSlider("DofFocusDistanceSlider", {
    Text = "Focus Distance",
    Default = v2.Visual.dofFocus,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.dofFocus = v
        Function.Tween(v2.Visual.Dof, {FocusDistance = v}, 1)
    end
})
DofInFocusRadiusSlider = VisualBoxTabs.Shaders:AddSlider("DofInFocusRadiusSlider", {
    Text = "In Focus Radius",
    Default = v2.Visual.dofInFocus,
    Min = 0,
    Max = 150,
    Rounding = 1,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.dofInFocus = v
        Function.Tween(v2.Visual.Dof, {InFocusRadius = v}, 1)
    end
})
DofNearIntensitySlider = VisualBoxTabs.Shaders:AddSlider("DofNearIntensitySlider", {
    Text = "Near Intensity",
    Default = v2.Visual.dofNearIntens,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.dofNearIntens = v
        Function.Tween(v2.Visual.Dof, {NearIntensity = v}, 1)
    end
})
SunRays = VisualBoxTabs.Shaders:AddToggle("SunRays", {
    Text = "SunRays",
    Default = false,
    Visible = false,
    Callback = function(v)
        if v then
            v2.Visual.ray = Instance.new("SunRaysEffect", gs.l)
            v2.Visual.ray.Intensity = v2.Visual.rayIntens
            v2.Visual.ray.Spread = v2.Visual.raySpread
            RaySpreadSlider:SetVisible(true)
            RayIntensitySlider:SetVisible(true)
        else
            if v2.Visual.ray then
                v2.Visual.ray:Destroy()
            end
            RaySpreadSlider:SetVisible(false)
            RayIntensitySlider:SetVisible(false)
        end
    end
})
RayIntensitySlider = VisualBoxTabs.Shaders:AddSlider("RayIntensitySlider", {
    Text = "Intensity",
    Default = v2.Visual.rayIntens,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.rayIntens = v
        Function.Tween(v2.Visual.ray, {Intensity = v}, 1)
    end
})
RaySpreadSlider = VisualBoxTabs.Shaders:AddSlider("RaySpreadSlider", {
    Text = "Spread",
    Default = v2.Visual.raySpread,
    Min = 0,
    Max = 2,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.raySpread = v
        Function.Tween(v2.Visual.ray, {Spread = v}, 1)
    end
})
Atmosphere = VisualBoxTabs.Shaders:AddToggle("Atmosphere", {
    Text = "Atmosphere",
    Default = false,
    Visible = false,
    Callback = function(v)
        if v then
            v2.Visual.atmos = Instance.new("Atmosphere", gs.l)
            v2.Visual.atmos.Density = v2.Visual.atmosDens
            atmosDensSlider:SetVisible(true)
        else
            if v2.Visual.atmos then
                v2.Visual.atmos:Destroy()
            end
            atmosDensSlider:SetVisible(false)
        end
    end
})
atmosDensSlider = VisualBoxTabs.Shaders:AddSlider("atmosDensSlider", {
    Text = "Density",
    Default = v2.Visual.atmosDens,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Visible = false,
    Callback = function(v)
        v2.Visual.atmosDens = v
        Function.Tween(v2.Visual.atmos, {Density = v}, 1)
    end
})
-------------------------->> [Misc] <<--------------------------
local MiscBoxTabs = {
    Gamepasses = GP.Gamepass:AddTab("Gamepasses", "dollar-sign"),
    GPConfig = GP.Gamepass:AddTab("Config", "settings"),
    Audio = GP.Audio:AddTab("Audio", "speaker"),
    Auto = GP.Auto:AddTab("Auto", "bot"),
    ChatSpam = GP.Annoying:AddTab("Chat", "message-square"),
}
-------------------------->> [Gamepasses] <<--------------------------
FurtherReach = MiscBoxTabs.Gamepasses:AddToggle("FurtherReach", {
    Text = "Further Reach",
    Default = false,
    Callback = function(v)
        if v then
            Function.GiveReach()
            v2.Misc.FurtherReachConn = v1.player.CharacterAdded:Connect(function(char)
                local GrabScript = char:WaitForChild("GrabbingScript", 5)
                if GrabScript then
                    Function.GiveReach()
                end
            end)
        else
            if v2.Misc.FurtherReachConn then
                v2.Misc.FurtherReachConn:Disconnect()
                v2.Misc.FurtherReachConn = nil
            end
            if v1.player.Character and v1.player.Character.GrabbingScript then
                v1.player.Character.GrabbingScript.Disabled = true
                task.wait()
                v1.player.Character.GrabbingScript.Enabled = true
            end
        end
    end
})
FasterEscape = MiscBoxTabs.Gamepasses:AddToggle("FasterEscape", {
    Text = "Faster Escape",
    Default = false,
    Callback = function(v)
        if v then
            local EscapeFrame = v1.PlayerGUI.ControlsGui.PCFrame.Escape
            local EscapeTimerFrame = v1.PlayerGUI.ControlsGui.PCFrame.EscapeTimer
            local EscapeTimerClone = EscapeTimerFrame:Clone()
            EscapeTimerFrame.Parent = nil
            local EscapeTimer = EscapeTimerClone:FindFirstChild("TimeToEscape")
        else
            
        end
    end
})
MultiColor = MiscBoxTabs.Gamepasses:AddToggle("MultiColor", {
    Text = "Multi-Color Line",
    Default = false,
    Callback = function(v)
        v2.Misc.MultiColor = v
        if v then
            Function.GiveMultiColor()
            v2.Misc.MultiColorConn = v1.player.CharacterAdded:Connect(function(char)
                local GrabScript = char:WaitForChild("GrabbingScript", 5)
                if GrabScript then
                    Function.GiveMultiColor()
                end
            end)
            v1.player.BeamColor.ColorSequenceHolder.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(v1.KeyPoints[1].Time, v2.Misc.Line[1]),
                ColorSequenceKeypoint.new(v1.KeyPoints[2].Time, v2.Misc.Line[2]),
                ColorSequenceKeypoint.new(v1.KeyPoints[3].Time, v2.Misc.Line[3]),
                ColorSequenceKeypoint.new(v1.KeyPoints[4].Time, v2.Misc.Line[4]),
                ColorSequenceKeypoint.new(v1.KeyPoints[5].Time, v2.Misc.Line[5]),
                ColorSequenceKeypoint.new(v1.KeyPoints[6].Time, v2.Misc.Line[6]),
                ColorSequenceKeypoint.new(v1.KeyPoints[7].Time, v2.Misc.Line[7]),
                ColorSequenceKeypoint.new(v1.KeyPoints[8].Time, v2.Misc.Line[8]),
                ColorSequenceKeypoint.new(v1.KeyPoints[9].Time, v2.Misc.Line[9]),
            })
        else
            if v2.Misc.MultiColorConn then
                v2.Misc.MultiColorConn:Disconnect()
                v2.Misc.MultiColorConn = nil
            end
            if v1.player.Character and v1.player.Character.GrabbingScript then
                v1.player.Character.GrabbingScript.Disabled = true
                task.wait()
                v1.player.Character.GrabbingScript.Enabled = true
                if workspace:FindFirstChild("GrabParts") then
                    workspace:FindFirstChild("GrabParts"):Destroy()
                end
            end
            v1.player.BeamColor.ColorSequenceHolder.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(v1.KeyPoints[1].Time, v2.Misc.OldLine[1]),
                ColorSequenceKeypoint.new(v1.KeyPoints[2].Time, v2.Misc.OldLine[2]),
                ColorSequenceKeypoint.new(v1.KeyPoints[3].Time, v2.Misc.OldLine[3]),
                ColorSequenceKeypoint.new(v1.KeyPoints[4].Time, v2.Misc.OldLine[4]),
                ColorSequenceKeypoint.new(v1.KeyPoints[5].Time, v2.Misc.OldLine[5]),
                ColorSequenceKeypoint.new(v1.KeyPoints[6].Time, v2.Misc.OldLine[6]),
                ColorSequenceKeypoint.new(v1.KeyPoints[7].Time, v2.Misc.OldLine[7]),
                ColorSequenceKeypoint.new(v1.KeyPoints[8].Time, v2.Misc.OldLine[8]),
                ColorSequenceKeypoint.new(v1.KeyPoints[9].Time, v2.Misc.OldLine[9]),
            })
            v1.player.BeamColor.BallColorHolder.Value = v2.Misc.OldLine.Ball
        end
    end
})
-------------------------->> [Config] <<--------------------------
MiscBoxTabs.GPConfig:AddDivider("Faster Escape")
FasterEscapeTime = MiscBoxTabs.GPConfig:AddSlider("FasterEscapeTime", {
    Text = "Seconds",
    Default = v2.Misc.FasterEscapeTime,
    Min = 3,
    Max = 11,
    Rounding = 0,
    Compact = true,
    Callback = function(v)
        v2.Misc.FasterEscapeTime = v
    end
})
MiscBoxTabs.GPConfig:AddDivider("Multi-Color")
BallColor = MiscBoxTabs.GPConfig:AddLabel("Ball Color")
BallColor:AddColorPicker("CS9Color", {
    Default = v2.Misc.Line.Ball,
    Title = "Color",
    Resizable = true,
    Callback = function(v)
        v2.Misc.Line.Ball = v
        if not v2.Misc.MultiColor then return end
        v2.Misc.Line.Ball = v
        v1.player.BeamColor.BallColorHolder.Value = v
    end
})
for i = 1, 9 do
    local CS = MiscBoxTabs.GPConfig:AddLabel("Color Sequence " .. i)
    CS:AddColorPicker("CS" .. i .. "Color", {
        Default = v2.Misc.Line[i],
        Title = "Color",
        Resizable = true,
        Callback = function(v)
            v2.Misc.Line[i] = v
            if not v2.Misc.MultiColor then return end
           v1.player.BeamColor.ColorSequenceHolder.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(v1.KeyPoints[1].Time, v2.Misc.Line[1]),
                ColorSequenceKeypoint.new(v1.KeyPoints[2].Time, v2.Misc.Line[2]),
                ColorSequenceKeypoint.new(v1.KeyPoints[3].Time, v2.Misc.Line[3]),
                ColorSequenceKeypoint.new(v1.KeyPoints[4].Time, v2.Misc.Line[4]),
                ColorSequenceKeypoint.new(v1.KeyPoints[5].Time, v2.Misc.Line[5]),
                ColorSequenceKeypoint.new(v1.KeyPoints[6].Time, v2.Misc.Line[6]),
                ColorSequenceKeypoint.new(v1.KeyPoints[7].Time, v2.Misc.Line[7]),
                ColorSequenceKeypoint.new(v1.KeyPoints[8].Time, v2.Misc.Line[8]),
                ColorSequenceKeypoint.new(v1.KeyPoints[9].Time, v2.Misc.Line[9]),
            })
        end
    })
end
-------------------------->> [Audio] <<--------------------------
MiscBoxTabs.Audio:AddToggle("MuteAmbience", {
	Text = "Mute Ambience",
	Default = false,
	Callback = function(v)
		local MapNoises = workspace.Map.MapNoises
		if v then
			table.clear(v2.Misc.AmbienceVolumes)
			for _, s in ipairs(MapNoises:GetDescendants()) do
				if s:IsA("Sound") then
					v2.Misc.AmbienceVolumes[s] = s.Volume
					s.Volume = 0
				end
			end
		else
			for s, volume in pairs(v2.Misc.AmbienceVolumes) do
				if s and s.Parent then
					s.Volume = volume
				end
			end
			table.clear(v2.Misc.AmbienceVolumes)
		end
	end
})
MiscBoxTabs.Audio:AddToggle("MuteMusic", {
	Text = "Mute music", Default = false,
	Callback = function(v)
		v2.Misc.MuteMusic = v
		if v then
			table.clear(v2.Misc.MusicVolumes)
			local function CheckMusic(obj)
				if not v2.Misc.MuteMusic or not obj:IsA("Sound") then return end
				local current = obj
				while current do
					local name = current.Name:lower()
					for _, music in ipairs(v2.BlackListedMusic) do
						if name:find(music:lower()) then
							if v2.Misc.MusicVolumes[obj] == nil then
								v2.Misc.MusicVolumes[obj] = obj.Volume
							end
							obj.Volume = 0
							obj:GetPropertyChangedSignal("Playing"):Connect(function()
								if v2.Misc.MuteMusic and obj.Parent and obj.Playing then
									obj.Volume = 0
								end
							end)
							return
						end
					end
					current = current.Parent
				end
			end
			local function Scan(folder)
				if not folder then return end
				for _, obj in ipairs(folder:GetDescendants()) do CheckMusic(obj) end
				folder.DescendantAdded:Connect(CheckMusic)
			end
			for inv in pairs(v3.ActiveFolders) do Scan(inv) end
			Scan(workspace.PlotItems)
		else
			for sound, volume in pairs(v2.Misc.MusicVolumes) do
				if sound and sound.Parent then sound.Volume = volume end
			end
			table.clear(v2.Misc.MusicVolumes)
		end
	end
})
MiscBoxTabs.Audio:AddToggle("MuteExplosions", {
	Text = "Mute Explosions",
	Default = false,
	Callback = function(v)
		if v2.Misc.ExplosionWatch then
			v2.Misc.ExplosionWatch:Disconnect()
			v2.Misc.ExplosionWatch = nil
		end
		if v then
			table.clear(v2.Misc.ExplosionVolumes)
			local function MuteSounds(obj)
				if obj:IsA("Sound") then
					if not v2.Misc.ExplosionVolumes[obj] then
						v2.Misc.ExplosionVolumes[obj] = obj.Volume
					end
					obj.Volume = 0
				end
			end
			for _, obj in ipairs(workspace:GetChildren()) do
				if obj:IsA("Part") then
					for _, s in ipairs(obj:GetDescendants()) do
						MuteSounds(s)
					end
					obj.DescendantAdded:Connect(MuteSounds)
				end
			end
			v2.Misc.ExplosionWatch = workspace.ChildAdded:Connect(function(obj)
				if obj:IsA("Part") then
					for _, s in ipairs(obj:GetDescendants()) do
						MuteSounds(s)
					end
					obj.DescendantAdded:Connect(MuteSounds)
				end
			end)
		else
			for sound, volume in pairs(v2.Misc.ExplosionVolumes) do
				if sound and sound.Parent then
					sound.Volume = volume
				end
			end
			table.clear(v2.Misc.ExplosionVolumes)
		end
	end
})
MiscBoxTabs.Audio:AddToggle("MuteScream", {
    Text = "Mute Screams",
    Default = false,
    Callback = function(v)
        v2.Misc.MuteScreams = v
        if v then
            table.clear(v2.Misc.ScreamVolumes)
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") and s.Name == "Scream" then
                    v2.Misc.ScreamVolumes[s] = s.Volume
                    s.Volume = 0
                end
            end
            v2.Misc.ScreamConn = workspace.DescendantAdded:Connect(function(s)
                if s:IsA("Sound") and s.Name == "Scream" then
                    v2.Misc.ScreamVolumes[s] = s.Volume
                    s.Volume = 0
                end
            end)
        else
            for s, volume in pairs(v2.Misc.ScreamVolumes) do
                if s and s.Parent then
                    s.Volume = volume
                end
            end
            if v2.Misc.ScreamConn then
                v2.Misc.ScreamConn:Disconnect()
                v2.Misc.ScreamConn = nil
            end
            table.clear(v2.Misc.ScreamVolumes)
        end
    end
})
MiscBoxTabs.Audio:AddToggle("MuteLines", {
    Text = "Mute Line",
    Default = false,
    Callback = function(v)
        if v2.Misc.GrabLineConn then
            v2.Misc.GrabLineConn:Disconnect()
            v2.Misc.GrabLineConn = nil
        end
        if v then
            table.clear(v2.Misc.LineVolumes)
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") and s:FindFirstAncestor("GrabParts") then
                    v2.Misc.LineVolumes[s] = s.Volume
                    s.Volume = 0
                end
            end
            v2.Misc.GrabLineConn = workspace.DescendantAdded:Connect(function(s)
                if s:IsA("Sound") and s:FindFirstAncestor("GrabParts") then
                    v2.Misc.LineVolumes[s] = s.Volume
                    s.Volume = 0
                end
            end)
        else
            for s, volume in pairs(v2.Misc.LineVolumes) do
                if s and s.Parent then
                    s.Volume = volume
                end
            end
            table.clear(v2.Misc.LineVolumes)
        end
    end
})
-------------------------->> [Auto] <<--------------------------
AutoSpin = MiscBoxTabs.Auto:AddToggle("AutoSpin", {
    Text = "Auto-Spin",
    Default = false,
    Callback = function(v)
        v2.Misc.AutoSpin = v
        if not v then return end
        task.spawn(function()
            while v2.Misc.AutoSpin do
                local char = v1.player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    task.wait()
                    continue
                end
                local time
                local closest
                for _, slot in ipairs(workspace.Slots:GetChildren()) do
                    if slot.Screen.SlotGui.TimeLeftFrame.SpinReadyWords.Visible then
                        time = slot.Screen.SlotGui.TimeLeftFrame.SpinReadyWords
                        break
                    end
                end
                for _, handle in ipairs(workspace.Slots:GetDescendants()) do
                    if handle:IsA("BasePart") and handle.Name == "Handle" then
                        if not closest or (hrp.Position - handle.Position).Magnitude < (hrp.Position - closest.Position).Magnitude then
                            closest = handle
                        end
                    end
                end
                if time and closest and not v2.Misc.AutiSpinBusy then
                    v2.Misc.AutiSpinBusy = true

                    local home = hrp.CFrame
                    local PartOwner

                    local dist = (hrp.Position - closest.Position).Magnitude
                    if dist > 20 then
                        hrp.CFrame = closest.CFrame + Vector3.new(0, -8, 0)
                        task.wait(0.2)
                    end

                    repeat
                        PartOwner = closest:FindFirstChild("PartOwner")

                        dist = (hrp.Position - closest.Position).Magnitude

                        if dist > 20 then
                            hrp.CFrame = closest.CFrame + Vector3.new(0, -8, 0)
                        end

                        Event.sno:FireServer(closest, closest.CFrame)

                        task.wait(0.03)
                    until (PartOwner and PartOwner.Value == v1.player.Name)
                        or not v2.Misc.AutoSpin
                        or not closest.Parent

                    hrp.CFrame = home
                    while time.Visible do task.wait(0.05) end
                    v2.Misc.AutiSpinBusy = false
                end
                task.wait(0.05)
            end
        end)
    end
})
-------------------------->> [Auto Plot] <<--------------------------
PlotTime = MiscBoxTabs.Auto:AddToggle("PlotTime", {
    Text = "AFK Plot Time",
    Default = false,
    Callback = function(v)
        v2.Misc.PlotTime = v
        if not v then return end
        task.spawn(function()
            while v2.Misc.PlotTime do
                local plot
                local char = v1.player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                for _, p in ipairs(workspace.Plots:GetChildren()) do
                    for _, frame in ipairs(p:GetDescendants()) do
                        if frame:IsA("Frame") and frame.Name == "Frame" and frame.Parent.Parent.Name == "Screen" then
                            local name = frame:FindFirstChild("PlayerDisplayName")
                            local role = frame:FindFirstChild("PlayerRole")

                            if name and role and name.Text == v1.player.DisplayName and role.Text == "Owner" then
                                plot = p
                                break
                            end
                        end
                    end

                    if plot then
                        break
                    end
                end

                if plot then
                    local time

                    for _, folder in ipairs(plot:GetDescendants()) do
                        if folder.Name == "ThisPlotsOwners" then
                            local plr = folder:FindFirstChild("Value")

                            if plr and plr.Value == v1.player.DisplayName then
                                time = plr:FindFirstChild("TimeRemainingNum")
                                break
                            end
                        end
                    end
                    local Home = hrp.CFrame
                    if time and time.Value <= 3 and not v2.Misc.PlotTimeBusy then
                        v2.Misc.PlotTimeBusy = true
                        local TP = plot and plot.House:FindFirstChildWhichIsA("BasePart")
                        hrp.CFrame = TP.CFrame
                        repeat
                            task.wait(0.03)
                        until time and time.Value >= 90
                        hrp.CFrame = Home
                        v2.Misc.PlotTimeBusy = false
                    end
                end

                task.wait(0.05)
            end
        end)
    end
})
-------------------------->> [Chat Sounds] <<--------------------------
ChatSendDelay = MiscBoxTabs.ChatSpam:AddSlider("ChatSendDelay", {
    Text = "Send Delay",
    Default = 0.25,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(v)
        v2.Misc.SendDelay = v
    end
})
MiscBoxTabs.ChatSpam:AddDropdown("SpamMessage", {
    Text = "Message",
    Values = {"Mommy", "Daddy", "UwU", "Oi", "Yum", "Sing", "Talk", "Ahh", "Ooo", "Haha", "Grr"},
    Default = nil,
    Multi = false,
    Callback = function(v)
        v2.Misc.Message = v
    end
})
local SpamChatSounds
SpamChatSounds = MiscBoxTabs.ChatSpam:AddToggle("SpamChatSounds", {
    Text = "Spam Chat Sounds",
    Default = false,
    Callback = function(v)
        v2.Misc.SpamSounds = v
        if v and not v2.Misc.Message then
            v2.Misc.SpamSounds = false
            SpamChatSounds:SetValue(false)
            Function.Notify("No sound is selected", 3)
            return
        end
        if v then
            task.spawn(function()
                while v2.Misc.SpamSounds do
                    if v2.Misc.Message then
                        task.spawn(function()
                            gs.Tcs.TextChannels.RBXGeneral:SendAsync("/e " .. v2.Misc.Message)
                        end)
                    end
                    task.wait(v2.Misc.SendDelay)
                end
            end)
        end
    end
})
-------------------------->> [Watch For Packets] <<--------------------------
v3.PacketWatchConn = Function.ConnectConn(Event.egl.OnClientEvent:Connect(function(plr, args)
	if v3.ActivePackets then return end
	if not plr or not plr.Name then return end

	if typeof(args) == "string" and #args > 300 then
		v3.ActivePackets = true

		local mb = math.round((#args / 1048576) * 1000) / 1000
		if plr.Name ~= v1.player.Name then
			Function.Notify(plr.DisplayName .. " | " .. plr.Name .. "\nSent packet size: " .. tostring(mb) .. " MB", 2.5)
		else
			Function.Notify("You sent packet size: " .. tostring(mb) .. " MB", 2.5)
		end
		task.delay(2.5, function()
			v3.ActivePackets = false
		end)
	end
end))
-------------------------->> [Get All Active Folders] <<--------------------------
for FolderName in pairs(v2.GameFolder) do
    local gamefolder = workspace:FindFirstChild(FolderName)
    if gamefolder then
        v3.ActiveFolders[gamefolder] = true
    end
end
for _, plr in ipairs(gs.Players:GetPlayers()) do
    local plrFolder = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
    if plrFolder then
        v3.ActiveFolders[plrFolder] = true
    end
end
-------------------------->> [Disable Void] <<--------------------------
workspace.FallenPartsDestroyHeight = 0/0
-------------------------->> [Set Toggles] <<--------------------------
AutoReset:SetValue(true)
AutoAntiLag:SetValue(true)
AutoWhitelist:SetValue(true)
-------------------------->> [Set Default Ocean] <<--------------------------
workspace.Terrain.WaterColor = Color3.fromRGB(108, 183, 244)
workspace.Terrain.WaterReflectance = 0.25
workspace.Terrain.WaterTransparency = 0.5
workspace.Terrain.WaterWaveSize = 0.35
workspace.Terrain.WaterWaveSpeed = 10
-------------------------->> [Last Grabbed By] <<--------------------------
Function.ConnectConn(gs.Rs.Heartbeat:Connect(function()
    local Char = v1.player.Character
    local Head = Char and Char:FindFirstChild("Head")
    if not Head then return end
    local PartOwner = Head:FindFirstChild("PartOwner")
    local CurrentGrabber = PartOwner and PartOwner.Value
    if not CurrentGrabber or CurrentGrabber == v1.LastGrabber then return end
    v1.LastGrabber = CurrentGrabber
    LastGrabbedText:SetText("Last grabbed by: " .. tostring(CurrentGrabber))
    Function.Notify("Grabbed by: " .. tostring(CurrentGrabber), 2)
end))
function ApplyHearts(hrp)
    local att = Instance.new("Attachment")
    att.Name = "HeartAura"
    att.Parent = hrp
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "PinkHearts"
    emitter.Texture = "rbxassetid://12323570774"
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 182, 220)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 105, 180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 250)),
    })
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.3, 1.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Lifetime = NumberRange.new(1.5, 2.5)
    emitter.Rate = 15
    emitter.Speed = NumberRange.new(2, 5)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Rotation = NumberRange.new(-30, 30)
    emitter.RotSpeed = NumberRange.new(-60, 60)
    emitter.LightEmission = 1
    emitter.LightInfluence = 0
    emitter.Parent = att
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 105, 180)
    light.Brightness = 2
    light.Range = 10
    light.Parent = hrp
end
-------------------------->> [On Player Joins and Leaves] <<--------------------------
Function.ConnectConn(gs.Players.PlayerAdded:Connect(function(plr)
    PlayerAmountText:SetText("Concurrent players: " .. #gs.Players:GetPlayers())

    -- add it to active stuff so we dont gotta do too much later on
    local plrFolder = workspace:WaitForChild(plr.Name.."SpawnedInToys", 5)
    if plrFolder then
        v3.ActiveFolders[plrFolder] = true
    end

    local data = v2.Target.OldTargets[plr.UserId]
    if not data then return end

    if data.PlayerTargets then
        Function.Notify("Target: "..plr.DisplayName .. " | " .. plr.Name .. " has rejoined", 5)
        local selected = TargetDropdown.Value or {}
        selected[plr] = true
        TargetDropdown:SetValue(selected)
    end

    if data.BlobmanTargets then
        Function.Notify("Target: "..plr.DisplayName .. " | " .. plr.Name .. " has rejoined", 5)
        local selected = BlobmanTargetDropdown.Value or {}
        selected[plr] = true
        BlobmanTargetDropdown:SetValue(selected)
    end

    if data.Whitelisted then
        Function.Notify("Whitelisted: "..plr.DisplayName .. " | " .. plr.Name, 5)
        local selected = WhitelistDropdown.Value or {}
        selected[plr] = true
        WhitelistDropdown:SetValue(selected)
    end

    if plr.Name == "KAYSLAKS" or plr.Name == "X3DxFS" then
        local function Hearts(char)
            local hrp = char:WaitForChild("HumanoidRootPart", 3)
            if hrp then
                ApplyHearts(hrp)
            end
        end
        plr.CharacterAdded:Connect(Hearts)
        if plr.Character then
            Hearts(plr.Character)
        end
    end
end))
Function.ConnectConn(gs.Players.PlayerRemoving:Connect(function(plr)
    PlayerAmountText:SetText("Concurrent players: " .. #gs.Players:GetPlayers())

    -- if they leave then we remove the folder from table so we arent still watching a non existent folder
    local plrFolder = workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
    if plrFolder then
        v3.ActiveFolders[plrFolder] = nil
    end

    local data = v2.Target.OldTargets[plr.UserId]
    if not data then return end

    if data.PlayerTargets then
        Function.Notify("Target: "..plr.DisplayName .. " | " .. plr.Name .. " left the game", 5)
    elseif data.BlobmanTargets then
        Function.Notify("Target: "..plr.DisplayName .. " | " .. plr.Name .. " left the game", 5)
    elseif data.Whitelisted then
        Function.Notify("Whitelisted: "..plr.DisplayName .. " | " .. plr.Name .. " left the game", 5)
    end
end))
