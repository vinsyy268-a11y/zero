-- V35: ultra-smooth UI motion / no overshoot / synchronized transitions
local function _w(t) t = t or 0.03 if task and type(task.wait) == "function" then task.wait(t) elseif type(wait) == "function" then wait(t) end end do local n = 0 while n < 200 do local ok, loaded = pcall(function() return game:IsLoaded() end) if ok and loaded then break end n = n + 1; _w(0.05) end end


-- ============================================================
-- REMOVE CAMERA SHAKE LOGIC (merged from Remove_Camera_Shake_Logic.lua)
-- ============================================================
-- Logic only: no GUI.
-- Compatible API:
--   RemoveCameraShake.SetEnabled(true/false)
--   RemoveCameraShake.IsEnabled()
--   RemoveCameraShake.ShouldSkipCameraAim()
--   RemoveCameraShake.AimCameraAt(targetPosition)
--
-- The original logic uses the desyncNoCam flag to prevent camera-aim
-- code from overwriting CurrentCamera.CFrame. The main file currently
-- does not contain a direct TP-Bat CurrentCamera.CFrame aim write, so
-- this module is exposed for any compatible camera-aim call in the hub.

do
    local _RCS_Existing = rawget(_G, "RemoveCameraShake")
    local RemoveCameraShake = (type(_RCS_Existing) == "table") and _RCS_Existing or {}

    if RemoveCameraShake.Enabled == nil then
        RemoveCameraShake.Enabled = false
    end

    function RemoveCameraShake.SetEnabled(enabled)
        RemoveCameraShake.Enabled = (enabled == true)

        -- Compatibility with the original extracted logic/flag name.
        pcall(function()
            _G.desyncNoCam = RemoveCameraShake.Enabled
        end)

        return RemoveCameraShake.Enabled
    end

    function RemoveCameraShake.IsEnabled()
        return RemoveCameraShake.Enabled == true
    end

    function RemoveCameraShake.ShouldSkipCameraAim()
        return RemoveCameraShake.Enabled == true
    end

    function RemoveCameraShake.AimCameraAt(targetPosition)
        if RemoveCameraShake.ShouldSkipCameraAim() then
            return false
        end

        local camera = workspace.CurrentCamera
        if not camera or typeof(targetPosition) ~= "Vector3" then
            return false
        end

        local ok = pcall(function()
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
        end)

        return ok
    end

    -- Compatibility aliases used by the extracted logic.
    _G.RemoveCameraShake = RemoveCameraShake
    _G._AdaptRemoveCameraShake = RemoveCameraShake
end


-- ============================================================
-- TOGGLE PING NOTIFICATION SYSTEM
-- ============================================================
do
    local _TPN_TweenService = game:GetService("TweenService")
    local _TPN_Players = game:GetService("Players")
    local _TPN_LP = _TPN_Players.LocalPlayer

    local function _tpnSafeParent(gui)
        pcall(function()
            if type(gethui) == "function" then
                local ok, p = pcall(gethui)
                if ok and p then gui.Parent = p return end
            end
            if type(protectgui) == "function" then
                gui.Parent = game:GetService("CoreGui")
                pcall(function() protectgui(gui) end)
                return
            end
            gui.Parent = game:GetService("CoreGui")
        end)
        if not gui.Parent then
            pcall(function() gui.Parent = _TPN_LP:WaitForChild("PlayerGui") end)
        end
    end

    local _tpnGui = Instance.new("ScreenGui")
    _tpnGui.Name = "VyxroTogglePingNotif"
    _tpnGui.ResetOnSpawn = false
    _tpnGui.IgnoreGuiInset = true
    _tpnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _tpnGui.DisplayOrder = 1500
    _tpnSafeParent(_tpnGui)

    local _tpnStack = Instance.new("Frame")
    _tpnStack.Name = "PingStack"
    _tpnStack.AnchorPoint = Vector2.new(0.5, 0)
    _tpnStack.Position = UDim2.new(0.5, 0, 0, 60)
    _tpnStack.Size = UDim2.new(0, 240, 0, 300)
    _tpnStack.BackgroundTransparency = 1
    _tpnStack.ClipsDescendants = true
    _tpnStack.Parent = _tpnGui

    local _tpnLayout = Instance.new("UIListLayout", _tpnStack)
    _tpnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    _tpnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    _tpnLayout.Padding = UDim.new(0, 6)

    local _tpnOrder = 0

    _G.VyxroToggleNotifEnabled = true

    local function ShowTogglePing(label, isOn)
        if _G.VyxroToggleNotifEnabled == false then return end
        pcall(function()
            _tpnOrder = _tpnOrder + 1
            local myOrder = _tpnOrder

            local card = Instance.new("Frame")
            card.Name = "PingCard"
            card.LayoutOrder = myOrder
            card.Size = UDim2.new(0, 258, 0, 60)
            card.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
            card.BackgroundTransparency = 0.02
            card.BorderSizePixel = 0
            card.ClipsDescendants = true
            card.AnchorPoint = Vector2.new(0.5, 0)
            card.Parent = _tpnStack
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

            local stroke = Instance.new("UIStroke", card)
            stroke.Thickness = 1.2
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.78

            local inner = Instance.new("Frame")
            inner.Name = "Inner"
            inner.Position = UDim2.new(0, 1, 0, 1)
            inner.Size = UDim2.new(1, -2, 1, -2)
            inner.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
            inner.BackgroundTransparency = 0.12
            inner.BorderSizePixel = 0
            inner.ZIndex = card.ZIndex + 1
            inner.Parent = card
            Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 15)

            local pad = Instance.new("UIPadding", inner)
            pad.PaddingLeft = UDim.new(0, 10)
            pad.PaddingRight = UDim.new(0, 10)

            local icon = Instance.new("Frame")
            icon.Name = "StateIcon"
            icon.Size = UDim2.new(0, 24, 0, 24)
            icon.BackgroundColor3 = isOn and Color3.fromRGB(255,255,255) or Color3.fromRGB(28,28,30)
            icon.BorderSizePixel = 0
            icon.ZIndex = inner.ZIndex + 1
            icon.Parent = inner
            Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
            local iconStroke = Instance.new("UIStroke", icon)
            iconStroke.Color = Color3.fromRGB(255,255,255)
            iconStroke.Thickness = 1
            iconStroke.Transparency = isOn and 0.0 or 0.35

            local iconText = Instance.new("TextLabel")
            iconText.BackgroundTransparency = 1
            iconText.Size = UDim2.new(1,0,1,0)
            iconText.Font = Enum.Font.GothamBlack
            iconText.TextSize = 15
            iconText.TextColor3 = isOn and Color3.fromRGB(8,8,10) or Color3.fromRGB(255,255,255)
            iconText.Text = isOn and "✓" or "×"
            iconText.ZIndex = icon.ZIndex + 1
            iconText.Parent = icon

            local textCol = Instance.new("Frame")
            textCol.Name = "TextCol"
            textCol.BackgroundTransparency = 1
            textCol.Position = UDim2.new(0, 45, 0, 0)
            textCol.Size = UDim2.new(1, -112, 1, 0)
            textCol.ZIndex = inner.ZIndex + 1
            textCol.Parent = inner

            local title = Instance.new("TextLabel")
            title.BackgroundTransparency = 1
            title.Position = UDim2.new(0,0,0,7)
            title.Size = UDim2.new(1,0,0,18)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 11
            title.TextColor3 = Color3.fromRGB(245,245,247)
            title.TextTruncate = Enum.TextTruncate.AtEnd
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Text = tostring(label)
            title.ZIndex = textCol.ZIndex + 1
            title.Parent = textCol

            local sub = Instance.new("TextLabel")
            sub.BackgroundTransparency = 1
            sub.Position = UDim2.new(0,0,0,27)
            sub.Size = UDim2.new(1,0,0,14)
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 9
            sub.TextColor3 = Color3.fromRGB(160,160,165)
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.Text = isOn and "STATUS  •  ENABLED" or "STATUS  •  DISABLED"
            sub.ZIndex = textCol.ZIndex + 1
            sub.Parent = textCol

            local badge = Instance.new("Frame")
            badge.Name = "StatusBadge"
            badge.AnchorPoint = Vector2.new(1, 0.5)
            badge.Position = UDim2.new(1, -10, 0.5, 0)
            badge.Size = UDim2.new(0, 52, 0, 28)
            badge.BackgroundColor3 = isOn and Color3.fromRGB(255,255,255) or Color3.fromRGB(24,24,27)
            badge.BorderSizePixel = 0
            badge.ZIndex = inner.ZIndex + 1
            badge.Parent = inner
            Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 9)
            local badgeStroke = Instance.new("UIStroke", badge)
            badgeStroke.Color = Color3.fromRGB(255,255,255)
            badgeStroke.Thickness = 1
            badgeStroke.Transparency = isOn and 0.0 or 0.55

            local badgeTxt = Instance.new("TextLabel")
            badgeTxt.BackgroundTransparency = 1
            badgeTxt.Size = UDim2.new(1,0,1,0)
            badgeTxt.Font = Enum.Font.GothamBlack
            badgeTxt.TextSize = 10
            badgeTxt.TextColor3 = isOn and Color3.fromRGB(8,8,10) or Color3.fromRGB(240,240,242)
            badgeTxt.Text = isOn and "ON" or "OFF"
            badgeTxt.ZIndex = badge.ZIndex + 1
            badgeTxt.Parent = badge

            local lineTrack = Instance.new("Frame")
            lineTrack.Name = "LifetimeTrack"
            lineTrack.Position = UDim2.new(0, 12, 1, -4)
            lineTrack.Size = UDim2.new(1, -24, 0, 2)
            lineTrack.BackgroundColor3 = Color3.fromRGB(45,45,48)
            lineTrack.BorderSizePixel = 0
            lineTrack.ZIndex = inner.ZIndex + 1
            lineTrack.Parent = inner
            Instance.new("UICorner", lineTrack).CornerRadius = UDim.new(1,0)
            local lineFill = Instance.new("Frame")
            lineFill.Size = UDim2.new(1,0,1,0)
            lineFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
            lineFill.BorderSizePixel = 0
            lineFill.ZIndex = lineTrack.ZIndex + 1
            lineFill.Parent = lineTrack
            Instance.new("UICorner", lineFill).CornerRadius = UDim.new(1,0)

            pcall(function() if _G.__VxyroGlossAttach then _G.__VxyroGlossAttach(inner, {z=1, radius=15, thickness=1.15, bloomThickness=4.3}) end end)

            card.Position = UDim2.new(0.5, 0, 0, -25)
            card.BackgroundTransparency = 1
            stroke.Transparency = 1
            inner.BackgroundTransparency = 1
            _TPN_TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 0.02
            }):Play()
            _TPN_TweenService:Create(stroke, TweenInfo.new(0.22), {Transparency = 0.78}):Play()
            _TPN_TweenService:Create(inner, TweenInfo.new(0.22), {BackgroundTransparency = 0.12}):Play()
            _TPN_TweenService:Create(lineFill, TweenInfo.new(1.8, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)}):Play()

            task.delay(1.82, function()
                if not card.Parent then return end
                _TPN_TweenService:Create(card, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5,0,0,-22), BackgroundTransparency = 1
                }):Play()
                _TPN_TweenService:Create(stroke, TweenInfo.new(0.20), {Transparency = 1}):Play()
                _TPN_TweenService:Create(inner, TweenInfo.new(0.20), {BackgroundTransparency = 1}):Play()
                _TPN_TweenService:Create(title, TweenInfo.new(0.20), {TextTransparency = 1}):Play()
                _TPN_TweenService:Create(sub, TweenInfo.new(0.20), {TextTransparency = 1}):Play()
                _TPN_TweenService:Create(badgeTxt, TweenInfo.new(0.20), {TextTransparency = 1}):Play()
                _TPN_TweenService:Create(iconText, TweenInfo.new(0.20), {TextTransparency = 1}):Play()
                _TPN_TweenService:Create(icon, TweenInfo.new(0.20), {BackgroundTransparency = 1}):Play()
                game:GetService("Debris"):AddItem(card, 0.26)
            end)
        end)
    end
    _G.ShowTogglePing = ShowTogglePing
    _G.VyxroShowTogglePing = ShowTogglePing
end
-- ============================================================
_w(0.1); print("[Vyxro Duel] Starting..."); local Players = game:GetService("Players"); local RunService = game:GetService("RunService"); local UIS = game:GetService("UserInputService"); local TS = game:GetService("TweenService"); local Lighting = game:GetService("Lighting"); local HS = game:GetService("HttpService"); local LP = Players.LocalPlayer if not LP then local ok, plr = pcall(function() return Players:WaitForChild("LocalPlayer", 15) end) if ok then LP = plr end end if not LP then warn("[Vyxro Duel] LocalPlayer not found - abort") return end local _genv = _G pcall(function()
if type(getgenv) == "function" then local g = getgenv() if type(g) == "table" then _genv = g end end end)
-- One active execution owns persistence. Older executions are prevented from
-- writing their stale/default state over the newest config after re-execute.
_genv.__VxyroDuelRunId = (tonumber(_genv.__VxyroDuelRunId) or 0) + 1
local __VXYRO_RUN_ID = _genv.__VxyroDuelRunId
local function __VXYRO_IS_CURRENT_RUN()
    return _genv.__VxyroDuelRunId == __VXYRO_RUN_ID
end
-- Clean up imported feature workers from the previous execution before creating new ones.
-- This prevents two Skin Tool / Custom Sound engines from fighting over the same Tool.
pcall(function()
    local oldReset = _genv.VxyroImportedFeaturesReset
    if type(oldReset) == "function" then oldReset() end
end)
local function destroyOldGuis() local names = {"VyxroDuel", "VyxroDuelMobileButtons", "VyxroDuelIntro", "VyxroE01Notification", "AmbitiousHubMusicPlayer", "AmbitiousHubFontPicker", "VxyroAvaPreset", "VyxroAvaPreset"}; local parents = {} pcall(function() table.insert(parents, game:GetService("CoreGui")) end) pcall(function() if LP then table.insert(parents, LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 2)) end end) pcall(function() if type(gethui) == "function" then table.insert(parents, gethui()) end end) for _, parent in ipairs(parents) do if parent then
for _, name in ipairs(names) do pcall(function() local o = parent:FindFirstChild(name) while o do o:Destroy(); o = parent:FindFirstChild(name) end end) end end end _G.VersincMobileButtonRefs = {} end if _genv.__VyxroDuelLoaded then pcall(destroyOldGuis); _genv.__VyxroDuelLoaded = false warn("[Vyxro Duel] Old instance cleaned - reloading...") end pcall(destroyOldGuis); _G.__AntiTPBatEnabled = false
-- ============================================================
-- VXYRO LOW-END PERFORMANCE PROFILE
-- Rendering/polling optimizations only; gameplay feature logic is kept intact.
-- ============================================================
 local AntiTPBat = { runtime = nil } do local okInit, errInit = pcall(function() local Players = game:GetService("Players")
local RunService = game:GetService("RunService"); local UserInputService = game:GetService("UserInputService"); local TweenService = game:GetService("TweenService"); local CoreGui = game:GetService("CoreGui"); local NetworkClient = game:GetService("NetworkClient"); local Workspace = game:GetService("Workspace"); local LocalPlayer = Players.LocalPlayer; local environment = if getgenv then getgenv() else _G; local RUNTIME_KEY = "__HOOK_ANTI_ANTI_RECONSTRUCTION"; local previousRuntime = environment[RUNTIME_KEY]
if type(previousRuntime) == "table" and type(previousRuntime.destroy) == "function" then pcall(previousRuntime.destroy) end local runtime = { alive = true, enabled = false, awaitingKey = false, boundKey = Enum.KeyCode.Delete, character = nil, rootPart = nil, fakeRoot = nil, repRootOwner = nil, stepConnection = nil, connections = {}, settingsRestore = {}, captureGeneration = 0, } environment[RUNTIME_KEY] = runtime local function connect(signal, callback) local connection = signal:Connect(callback); table.insert(runtime.connections, connection) return connection end
local function disconnect(connection) if connection then pcall(function() connection:Disconnect() end) end end local function createInstance(className, properties, parent) local object = Instance.new(className) for property, value in pairs(properties or {}) do object[property] = value end if parent then object.Parent = parent end return object end local function addCorner(parent, radius) return createInstance("UICorner", { CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius), }, parent) end local function addStroke(parent, color, transparency, thickness)
return createInstance("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = color, Transparency = transparency, Thickness = thickness, }, parent) end local function playTween(object, duration, goals) local animation = TweenService:Create( object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goals ) animation:Play() return animation end local function isBasePart(instance) if not instance then return false end local ok, result = pcall(function() return instance:IsA("BasePart") end) return ok and result == true end
local function getCurrentRoot(character) character = character or LocalPlayer.Character if not character then return nil end local ok, root = pcall(function() return character:FindFirstChild("HumanoidRootPart") end) if ok and isBasePart(root) then return root end return nil end local function findGlobalFunction(...) for index = 1, select("#", ...) do local name = select(index, ...); local value = rawget(environment, name) if type(value) == "function" then return value end end return nil end local function setHidden(instance, property, value) if not instance then return false end
local setter = findGlobalFunction( "sethiddenproperty", "set_hidden_property", "sethiddenprop", "set_hidden_prop" ) if setter then local ok = pcall(setter, instance, property, value) if ok then return true end end return pcall(function() instance[property] = value end) end local function getHidden(instance, property) if not instance then return false, nil end local getter = findGlobalFunction( "gethiddenproperty", "get_hidden_property", "gethiddenprop", "get_hidden_prop" ) if getter then local ok, value = pcall(getter, instance, property) if ok then return true, value end end
local ok, value = pcall(function() return instance[property] end) return ok, value end local function rememberSetting(instance, property) local ok, value = pcall(function() return instance[property] end) if ok then table.insert(runtime.settingsRestore, { instance = instance, property = property, value = value, }) end end local function applyPublicSetting(instance, property, value) if not instance then return false end rememberSetting(instance, property) return pcall(function() instance[property] = value end) end local function configurePhysics()
setHidden(LocalPlayer, "MaximumSimulationRadius", math.huge); setHidden(LocalPlayer, "SimulationRadius", math.huge) pcall(function() local networkSettings = settings().Network applyPublicSetting( networkSettings, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled ) end) pcall(function() local physicsSettings = settings().Physics applyPublicSetting( physicsSettings, "PhysicsEnvironmentalThrottle", Enum.EnviromentalPhysicsThrottle.Disabled ) applyPublicSetting(physicsSettings, "AllowSleep", false) end) pcall(function() NetworkClient:SetOutgoingKBPSLimit(math.huge) end) end
configurePhysics(); local FAKE_ROOT_NAME = "DavidDesyncRoot" local FAKE_ROOT_Y = -2500; local FAKE_ROOT_VELOCITY = Vector3.new(0, -1000, 0) local function fakeRootIsUsable() local fake = runtime.fakeRoot if not isBasePart(fake) then return false end local ok, parent = pcall(function() return fake.Parent end) return ok and parent ~= nil end local function destroyFakeRoot() local fake = runtime.fakeRoot; runtime.fakeRoot = nil if fake then pcall(function() fake:Destroy() end) end end local function restoreReplicationRoot() local owner = runtime.repRootOwner or runtime.rootPart
if isBasePart(owner) then setHidden(owner, "PhysicsRepRootPart", owner) end runtime.repRootOwner = nil end local function createFakeRoot(rootPart) destroyFakeRoot() local fake = createInstance("Part", { Name = FAKE_ROOT_NAME, Size = Vector3.new(2, 2, 1), Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false, Transparency = 1, CFrame = CFrame.new(0, FAKE_ROOT_Y, 0), AssemblyLinearVelocity = FAKE_ROOT_VELOCITY, }, Workspace) local ok, position = pcall(function() return rootPart.Position end) if ok then fake.CFrame = CFrame.new(position.X, FAKE_ROOT_Y, position.Z) end
runtime.fakeRoot = fake return fake end local function assignFakeReplicationRoot(rootPart, fake) if not isBasePart(rootPart) or not isBasePart(fake) then return false end setHidden(rootPart, "PhysicsRepRootPart", rootPart); runtime.repRootOwner = rootPart return setHidden(rootPart, "PhysicsRepRootPart", fake) end local function stepDesync() if not runtime.alive or not runtime.enabled then return end local root = runtime.rootPart if not isBasePart(root) then root = getCurrentRoot(runtime.character); runtime.rootPart = root end if not root then return end if not fakeRootIsUsable() then
local fake = createFakeRoot(root); assignFakeReplicationRoot(root, fake) return end local fake = runtime.fakeRoot local ok, rootPosition, fakePosition = pcall(function() return root.Position, fake.Position end) if ok and ( math.abs(rootPosition.X - fakePosition.X) > 0.01 or math.abs(rootPosition.Z - fakePosition.Z) > 0.01 or math.abs(fakePosition.Y - FAKE_ROOT_Y) > 0.01 ) then pcall(function() fake.CFrame = CFrame.new(rootPosition.X, FAKE_ROOT_Y, rootPosition.Z) end) end pcall(function() fake.Anchored = true fake.AssemblyLinearVelocity = FAKE_ROOT_VELOCITY end)
local gotValue, current = getHidden(root, "PhysicsRepRootPart") if not gotValue or current ~= fake then setHidden(root, "PhysicsRepRootPart", fake) end end local function stopStepConnection() disconnect(runtime.stepConnection); runtime.stepConnection = nil end local function startStepConnection() stopStepConnection(); runtime.stepConnection = RunService.Stepped:Connect(stepDesync) end local function bindCharacter(character) local oldRoot = runtime.rootPart; runtime.character = character; runtime.rootPart = getCurrentRoot(character) if runtime.enabled then
if isBasePart(oldRoot) and oldRoot ~= runtime.rootPart then setHidden(oldRoot, "PhysicsRepRootPart", oldRoot) end destroyFakeRoot(); local root = runtime.rootPart if not root and character then local ok, waitedRoot = pcall(function() return character:WaitForChild("HumanoidRootPart", 8) end) if ok and isBasePart(waitedRoot) then root = waitedRoot; runtime.rootPart = root end end if root then local fake = createFakeRoot(root); assignFakeReplicationRoot(root, fake); startStepConnection() end end end bindCharacter(LocalPlayer.Character) connect(LocalPlayer.CharacterAdded, function(character)
task.defer(bindCharacter, character) end) local COLORS = { main = Color3.fromRGB(5, 10, 20), row = Color3.fromRGB(8, 18, 32), track = Color3.fromRGB(10, 24, 42), button = Color3.fromRGB(7, 14, 26), text = Color3.fromRGB(225, 232, 242), muted = Color3.fromRGB(125, 145, 170), accent = Color3.fromRGB(27, 96, 178), rowStroke = Color3.fromRGB(24, 78, 132), } local uiParent = CoreGui local oldGui = uiParent:FindFirstChild("HookAntiAntiUI") if oldGui then oldGui:Destroy() end local screenGui = createInstance("ScreenGui", { Name = "HookAntiAntiUI", DisplayOrder = 999, ResetOnSpawn = false,
IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, }, nil) local parented = pcall(function() screenGui.Parent = uiParent end) if not parented then local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui") uiParent = playerGui; local stale = uiParent:FindFirstChild("HookAntiAntiUI") if stale then stale:Destroy() end screenGui.Parent = uiParent end runtime.gui = screenGui local main = createInstance("Frame", { Name = "Main", Active = true, ClipsDescendants = true, BackgroundTransparency = 0.08, BackgroundColor3 = COLORS.main,
BorderSizePixel = 0, Position = UDim2.new(0.5, -155, 0.5, -90), Size = UDim2.new(0, 310, 0, 175), }, screenGui) addCorner(main, 16) local mainStroke = addStroke(main, Color3.new(1, 1, 1), 0, 1.8) local outlineGradient = createInstance("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0.00, Color3.fromRGB(75, 0, 125)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(165, 35, 240)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235, 95, 255)), ColorSequenceKeypoint.new(0.50, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(235, 95, 255)),
ColorSequenceKeypoint.new(0.80, Color3.fromRGB(165, 35, 240)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(75, 0, 125)), }), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0.00, 0.75), NumberSequenceKeypoint.new(0.25, 0.40), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(0.75, 0.40), NumberSequenceKeypoint.new(1.00, 0.75), }), Rotation = 0, }, mainStroke) local mainScale = createInstance("UIScale", { Scale = 1, }, main) local backdrop = createInstance("ImageLabel", { Name = "Backdrop", ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.22,
AnchorPoint = Vector2.new(1, 0), Image = "rbxasset://e108b292ebba4c47d7bac2a9aef23afa/hooklagger_bg.png", BackgroundTransparency = 1, Position = UDim2.new(1, 10, 0, -5), ZIndex = 1, Size = UDim2.new(0, 210, 1, 10), }, main) addCorner(backdrop, 16) local header = createInstance("Frame", { Name = "Header", BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 6), ZIndex = 10, Size = UDim2.new(1, -24, 0, 40), }, main) addCorner(header, 6) local logo = createInstance("ImageLabel", { Name = "Logo", BackgroundTransparency = 1,
Image = "rbxasset://e108b292ebba4c47d7bac2a9aef23afa/hookduels_logo.png", Position = UDim2.new(0, 2, 0, 6), ZIndex = 11, Size = UDim2.new(0, 28, 0, 28), }, header) addCorner(logo, 6) local title = createInstance("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = "ANTI TP BAT", TextColor3 = COLORS.text, Font = Enum.Font.GothamBlack, Position = UDim2.new(0, 38, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11, TextSize = 14, Size = UDim2.new(1, -40, 1, 0), }, header) local content = createInstance("Frame", { Name = "Content", BackgroundTransparency = 1,
Position = UDim2.new(0, 18, 0, 48), ZIndex = 5, Size = UDim2.new(1, -28, 1, -54), }, main) createInstance("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, }, content) local function makeRow(name, layoutOrder) local row = createInstance("Frame", { Name = name, BackgroundColor3 = COLORS.row, BackgroundTransparency = 0.25, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 46), LayoutOrder = layoutOrder, ZIndex = 5, }, content) addCorner(row, 10) createInstance("UIGradient", { Color = ColorSequence.new( Color3.new(1, 1, 1), Color3.fromRGB(205, 210, 230) ),
Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0.00, 0.55), NumberSequenceKeypoint.new(0.50, 0.85), NumberSequenceKeypoint.new(1.00, 0.70), }), Rotation = 90, }, row) addStroke(row, COLORS.rowStroke, 0.60, 1) return row end local toggleRow = makeRow("AntiAntiRow", 1) local toggleLabel = createInstance("TextLabel", { Name = "Label", BackgroundTransparency = 1, Text = "Enable Anti TP Bat", TextColor3 = COLORS.text, Font = Enum.Font.GothamBold, Position = UDim2.new(0, 14, 0, 6), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, TextSize = 13, Size = UDim2.new(1, -74, 0, 18),
}, toggleRow) local statusLabel = createInstance("TextLabel", { Name = "Status", BackgroundTransparency = 1, Text = "OFF", TextColor3 = COLORS.muted, Font = Enum.Font.GothamBold, Position = UDim2.new(0, 14, 0, 24), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, TextSize = 9, Size = UDim2.new(1, -74, 0, 14), }, toggleRow) local toggleTrack = createInstance("Frame", { Name = "Toggle", AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = COLORS.track, BorderSizePixel = 0, Position = UDim2.new(1, -12, 0.5, 0), ZIndex = 7, Size = UDim2.new(0, 44, 0, 22), }, toggleRow)
addCorner(toggleTrack, 11) addStroke(toggleTrack, COLORS.rowStroke, 0.50, 1.2) local toggleKnob = createInstance("Frame", { Name = "Knob", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0, 3), ZIndex = 8, }, toggleTrack) addCorner(toggleKnob, UDim.new(1, 0)) local toggleHit = createInstance("TextButton", { Name = "ToggleHit", BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 9, Size = UDim2.new(1, 0, 1, 0), }, toggleRow) local keybindRow = makeRow("KeybindRow", 2)
local keybindLabel = createInstance("TextLabel", { Name = "Label", BackgroundTransparency = 1, Text = "Keybind", TextColor3 = COLORS.text, Font = Enum.Font.GothamBold, Position = UDim2.new(0, 14, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, TextSize = 13, Size = UDim2.new(1, -84, 1, 0), }, keybindRow) local keybindButton = createInstance("TextButton", { Name = "KeybindBtn", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = COLORS.button, BackgroundTransparency = 0.30, BorderSizePixel = 0, Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.new(0, 76, 0, 26), Text = "Delete", TextColor3 = COLORS.accent, Font = Enum.Font.GothamBlack, TextSize = 11, ZIndex = 7, }, keybindRow) addCorner(keybindButton, 7) addStroke(keybindButton, COLORS.rowStroke, 0.50, 1) local function ripple(row) if _VXYRO_LOW_END then return end if not runtime.alive or not row or not row.Parent then return end
local mousePosition = UserInputService:GetMouseLocation(); local absolutePosition = row.AbsolutePosition; local absoluteSize = row.AbsoluteSize; local x = mousePosition.X - absolutePosition.X; local y = mousePosition.Y - absolutePosition.Y; local diameter = math.max(absoluteSize.X, absoluteSize.Y) * 1.35 local image = createInstance("ImageLabel", { Name = "Ripple", BackgroundTransparency = 1, Image = "rbxassetid://266543268", ImageColor3 = COLORS.accent, ImageTransparency = 0.40, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, 0, 0, 0), ZIndex = 30,
}, row) local animation = playTween(image, 0.45, { Size = UDim2.new(0, diameter, 0, diameter), ImageTransparency = 1, }) animation.Completed:Connect(function() if image then image:Destroy() end end) end local function applyEnabledVisual(value, instant) statusLabel.Text = value and "ACTIVE" or "OFF"; statusLabel.TextColor3 = value and COLORS.accent or COLORS.muted; local trackColor = value and Color3.fromRGB(122, 30, 134) or COLORS.track; local knobPosition = value and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3) if instant then toggleTrack.BackgroundColor3 = trackColor
toggleKnob.Position = knobPosition else playTween(toggleTrack, 0.18, { BackgroundColor3 = trackColor }); playTween(toggleKnob, 0.18, { Position = knobPosition }) end end local function setEnabled(value) if not runtime.alive then return false end value = value == true if runtime.enabled == value then applyEnabledVisual(value, false) return value end runtime.enabled = value; applyEnabledVisual(value, false) if value then local root = getCurrentRoot(runtime.character); runtime.rootPart = root if not root then runtime.enabled = false; applyEnabledVisual(false, false) return false end
local fake = createFakeRoot(root); assignFakeReplicationRoot(root, fake); startStepConnection() else stopStepConnection(); restoreReplicationRoot(); destroyFakeRoot() end return runtime.enabled end local function toggleEnabled() return setEnabled(not runtime.enabled) end connect(toggleHit.MouseButton1Click, function() ripple(toggleRow) local _r = toggleEnabled() pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Anti TP Bat", _r == true) end end) end) connect(keybindButton.MouseButton1Click, function() if not runtime.alive or runtime.awaitingKey then return end ripple(keybindRow); runtime.awaitingKey = true runtime.captureGeneration += 1 local generation = runtime.captureGeneration
task.spawn(function() for _, text in ipairs({".", "..", "..."}) do if not runtime.alive or not runtime.awaitingKey or generation ~= runtime.captureGeneration then return end keybindButton.Text = text; task.wait(0.15) end end) end) connect(UserInputService.InputBegan, function(input, gameProcessed) if not runtime.alive then return end if runtime.awaitingKey then if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then if input.KeyCode ~= Enum.KeyCode.Escape then runtime.boundKey = input.KeyCode end runtime.awaitingKey = false
runtime.captureGeneration += 1 keybindButton.Text = runtime.boundKey.Name end return end if not gameProcessed and input.KeyCode == runtime.boundKey then ripple(toggleRow); local _r = toggleEnabled() pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Anti TP Bat", _r == true) end end) end end) local dragging = false local dragInput = nil; local dragStart = nil; local startPosition = nil connect(main.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragInput = input; dragStart = input.Position; startPosition = main.Position local changedConnection
changedConnection = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; dragInput = nil; disconnect(changedConnection) end end) end end) connect(main.InputChanged, function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end) connect(UserInputService.InputChanged, function(input) if not dragging or input ~= dragInput or not dragStart or not startPosition then return end local delta = input.Position - dragStart main.Position = UDim2.new(
startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y ) end) local outlineAccum = 0
connect(RunService.RenderStepped, function(deltaTime)
    if _VXYRO_LOW_END then return end
    if not runtime.alive or not outlineGradient.Parent then return end
    outlineAccum += deltaTime
    if outlineAccum < 0.08 then return end
    outlineAccum = 0
    outlineGradient.Rotation = (outlineGradient.Rotation + 11) % 360
end) local function destroy() if not runtime.alive then return end runtime.alive = false; runtime.enabled = false; runtime.awaitingKey = false runtime.captureGeneration += 1 stopStepConnection(); restoreReplicationRoot(); destroyFakeRoot()
for _, connection in ipairs(runtime.connections) do disconnect(connection) end table.clear(runtime.connections) for index = #runtime.settingsRestore, 1, -1 do local entry = runtime.settingsRestore[index] pcall(function() entry.instance[entry.property] = entry.value end) end table.clear(runtime.settingsRestore) if runtime.gui then pcall(function() runtime.gui:Destroy() end) end if environment[RUNTIME_KEY] == runtime then environment[RUNTIME_KEY] = nil end end
runtime.setEnabled = setEnabled; runtime.toggle = toggleEnabled; runtime.step = stepDesync; runtime.bindCharacter = bindCharacter; runtime.setHidden = setHidden; runtime.getHidden = getHidden; runtime.destroy = destroy runtime.getBoundKey = function() return runtime.boundKey end runtime.setBoundKey = function(keyCode) if keyCode and keyCode ~= Enum.KeyCode.Unknown then runtime.boundKey = keyCode; keybindButton.Text = keyCode.Name return true end return false end applyEnabledVisual(false, true) end) if not okInit then warn("[Vyxro Duel] Anti TP Bat init failed: " .. tostring(errInit)) end
pcall(function() local g = (type(getgenv) == "function" and getgenv()) or _G AntiTPBat.runtime = g["__HOOK_ANTI_ANTI_RECONSTRUCTION"] if AntiTPBat.runtime and AntiTPBat.runtime.gui then AntiTPBat.runtime.gui.Enabled = false end end) end function AntiTPBat.isOn() return _G.__AntiTPBatEnabled == true end function AntiTPBat.set(state) state = state == true; local rt = AntiTPBat.runtime if not rt or type(rt.setEnabled) ~= "function" then _G.__AntiTPBatEnabled = false return false end local ok, res = pcall(rt.setEnabled, state); _G.__AntiTPBatEnabled = (ok and res == true) or false
return _G.__AntiTPBatEnabled end function AntiTPBat.toggle() return AntiTPBat.set(not AntiTPBat.isOn()) end local getconnections = getconnections or get_signal_cons or getconnects or (syn and syn.get_signal_cons) or nil; local _IS_MOBILE = false pcall(function() _IS_MOBILE = UIS.TouchEnabled == true and UIS.KeyboardEnabled ~= true end) pcall(function() if UIS.TouchEnabled and not UIS.MouseEnabled then _IS_MOBILE = true end end)
-- Low-end profile: reduce cosmetic work/polling on touch-first devices without changing feature logic.
local _VXYRO_LOW_END = _IS_MOBILE == true
pcall(function()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize
    if vp and (vp.X < 900 or vp.Y < 600) then _VXYRO_LOW_END = true end
end)
local function _perfEveryN(nMobile, nDesktop) local n = _IS_MOBILE and nMobile or nDesktop if n <= 1 then return true end local bucket = math.floor(os.clock() * 60)
return (bucket % n) == 0 end local function _perfDue(key, mobileSec, desktopSec) return _perfEveryN(math.max(1, math.floor((mobileSec or 0.1) * 60)), math.max(1, math.floor((desktopSec or 0.05) * 60))) end local S = { NS = 60, CS = 30, LAGGER_SPEED = 15, LAGGER_CARRY_SPEED = 24.5, speedMode = false, antiRagdollEnabled = false, antiRagdollMode = 1, aimbotMode = 1, antiBatBypassEnabled = false, laggerToggled = false, laggerPhase = 0, autoCarrySpeedEnabled = false, setAutoCarrySpeedVisual = nil, _autoCarryFromSteal = false, _autoCarryWaitingPickup = false,
_autoCarryGraceUntil = 0, _autoCarryPickupUntil = 0, _autoCarryReturnMode = nil, _stealAttrWasActive = false, medusaCounterEnabled = false, medusaResetEnabled = false, batCounterEnabled = false, unwalkEnabled = false, medusaDebounce = false, medusaLastUsed = 0, dropActive = false, autoLeftEnabled = false, autoRightEnabled = false, autoLeftSetVisual = nil, autoRightSetVisual = nil, speedLabel = nil, autoBatEnabled = false, autoSwingEnabled = true, autoBatSetVisual = nil, autoBatEquippedThisRun = false, _autoBatTarget = nil, _autoBatLastScan = 0, resetAutoBatMotion = nil,
AUTO_BAT_SPEED = 58, AUTO_BAT_VERT_SPEED = 52, AUTO_BAT_DIST = -2.8, AUTO_BAT_HEIGHT = 4.75, AUTO_BAT_V_OFF = 1, AUTO_BAT_TURN_SPEED = 285, AUTO_BAT_MAX_TURN_RATE = 28, setBatCounterVisual = nil, startBatCounter = nil, stopBatCounter = nil, enableAutoBat = nil, disableAutoBat = nil, antiLagEnabled = false, removeAccessoriesEnabled = false, antiDieEnabled = false, antiFlingShieldEnabled = false, antiLagDescConn = nil, stretchRezEnabled = false, stretchRezConn = nil, setStretchRezVisual = nil, unwalkSavedAnimate = nil,
_anyKeyListening = false, autoTPEnabled = false, autoTPHeight = 20, autoTPConn = nil, setAutoTPVisual = nil, autoSaveEnabled = true, _lastSaveOk = false, _lastSaveAt = 0, cursedResetRemote = nil, CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42", AntiRagdollConns = {}, noPlayerCollisionEnabled = false, safeModeEnabled = false, autoResetOnMedEnabled = false, showTracerEnabled = false, ragdollCountdownEnabled = false, toggleNotifEnabled = true, guiLocked = false, hideMobileButtons = false, lockMobileButtons = false, allLockButtons = false, moveButtons = false, progressBarScale = 100, infJumpMode = "hold",
-- Imported visual/customization states
avatarChanger = {}, avaPresetEnabled = false, avaPresetName = "PURPLE", customToolsEnabled = false, customToolSkinBat = "DiamondSword", customToolSkinMedusa = "GoldenDesertEagle", customSoundsEnabled = false,
vividGraphicsEnabled = false, vividSettings = { saturation = 0.6, bloomIntensity = 0.8, bloomSize = 24, sunIntensity = 0.2, dofFocus = 25 }, motionBlurEnabled = false,
mirrorTPDownEnabled = false, _bodyLockPausedByCombat = false, _bodyLockWanted = false, _bodyLockPausedByBrainrot = false, mobileButtonScale = 0.80, uiScaleValue = 100, keyboardOverlayEnabled = false, } local VS, UI, F = {}, {}, {} local NS, CS = S.NS, S.CS; local CONFIG_FILE, CONFIG_FILE_LEGACY = "VyxroDuelConfig.json", "cursedPC.json"
local FEATURE_CONFIG_FILE = "VxyroDuel_Features.json"
local _readfile = readfile or (syn and syn.readfile) or (getgenv and getgenv().readfile) or nil
local _rawIsFile = isfile or (syn and syn.isfile) or (getgenv and getgenv().isfile) or nil
local _isfile = function(path)
    if _rawIsFile then
        local ok, result = pcall(_rawIsFile, path)
        if ok and result == true then return true end
    end
    -- Some executors expose readfile/writefile but not isfile.  Fall back to
    -- an actual read so saved config can still be discovered on next execute.
    if _readfile then
        local ok, data = pcall(_readfile, path)
        return ok and type(data) == "string" and data ~= ""
    end
    return false
end
local _writefile = writefile or (syn and syn.writefile) or (getgenv and getgenv().writefile) or nil; local antiRagdollConn = nil; local antiRagdollModeActive = nil; local ragdollConnections = {}; local cachedCharData = {}; local isBoosting = false; local BOOST_SPEED = 400 local AR_DEFAULT_SPEED = 16 local function arGetNormalSpeed() return AR_DEFAULT_SPEED end local function arV2ResetCharacter(char) local hum = char and char:FindFirstChildOfClass("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart") if not hum or not root or hum.Health <= 0 then return end pcall(function()
hum:ChangeState(Enum.HumanoidStateType.GettingUp); hum:ChangeState(Enum.HumanoidStateType.Running) root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero hum.PlatformStand = false; hum.Sit = false; hum.AutoRotate = true hum.JumpPower = hum.JumpPower > 0 and hum.JumpPower or 50 hum.WalkSpeed = hum.WalkSpeed > 0 and hum.WalkSpeed or AR_DEFAULT_SPEED for _, obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") then obj.Enabled = true
elseif obj:IsA("Constraint") or obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") then obj.Enabled = true elseif obj:IsA("BasePart") then obj.CanCollide = true; obj.AssemblyLinearVelocity = Vector3.zero; obj.AssemblyAngularVelocity = Vector3.zero end end if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end local playerModule = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule"); local controlModule = playerModule and playerModule:FindFirstChild("ControlModule") if controlModule then
local loaded, module = pcall(require, controlModule) if loaded and module and module.Enable then pcall(function() module:Enable() end) end end end) end local function arCacheCharacterData() local char = LP.Character if not char then return false end local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart") if not hum or not root then return false end cachedCharData = { character = char, humanoid = hum, root = root }; S._ragdollCache = cachedCharData return true end local function arDisconnectAll()
for _, conn in ipairs(ragdollConnections) do pcall(function() conn:Disconnect() end) end ragdollConnections = {} end local AR_STATES = { [Enum.HumanoidStateType.Physics] = true, [Enum.HumanoidStateType.Ragdoll] = true, [Enum.HumanoidStateType.FallingDown] = true } local function arIsRagdolled() if not cachedCharData.humanoid then return false end if AR_STATES[cachedCharData.humanoid:GetState()] then return true end local endTime = LP:GetAttribute("RagdollEndTime") return (endTime and (endTime - workspace:GetServerTimeNow()) > 0) or false end local function arForceExitRagdoll()
if not cachedCharData.humanoid or not cachedCharData.root then return end pcall(function() LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end) for _, d in ipairs(cachedCharData.character:GetDescendants()) do if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and tostring(d.Name):find("RagdollAttachment")) then pcall(function() d:Destroy() end) end end if not isBoosting then isBoosting = true pcall(function() cachedCharData.humanoid.WalkSpeed = BOOST_SPEED end) end pcall(function()
if cachedCharData.humanoid.Health > 0 then cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.Running) end cachedCharData.root.Anchored = false end) end local function arHeartbeatLoop() while antiRagdollModeActive == "v1" do task.wait() local currentlyRagdolled = arIsRagdolled() if currentlyRagdolled then arForceExitRagdoll() elseif isBoosting and not currentlyRagdolled then isBoosting = false if cachedCharData.humanoid then pcall(function() cachedCharData.humanoid.WalkSpeed = AR_DEFAULT_SPEED end) end end end end function F.startAntiRagdoll()
local requestedMode = (S.antiRagdollMode == 2) and "v2" or "v1" if antiRagdollModeActive == requestedMode and (#S.AntiRagdollConns > 0 or antiRagdollConn) then return end F.stopAntiRagdoll() if not arCacheCharacterData() then return end antiRagdollModeActive = requestedMode if requestedMode == "v2" then antiRagdollConn = RunService.Heartbeat:Connect(function() if antiRagdollModeActive ~= "v2" or not S.antiRagdollEnabled then return end local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid") if not hum then return end local state = hum:GetState()
if AR_STATES[state] or state == Enum.HumanoidStateType.Dead or hum.PlatformStand == true or hum.Sit == true then arV2ResetCharacter(char) end end) table.insert(S.AntiRagdollConns, antiRagdollConn) return end local camConn = RunService.RenderStepped:Connect(function() local cam = workspace.CurrentCamera if cam and cachedCharData.humanoid then cam.CameraSubject = cachedCharData.humanoid end end) table.insert(ragdollConnections, camConn); table.insert(S.AntiRagdollConns, camConn) local respawnConn = LP.CharacterAdded:Connect(function()
isBoosting = false; task.wait(0.5); arCacheCharacterData() end) table.insert(ragdollConnections, respawnConn); table.insert(S.AntiRagdollConns, respawnConn); task.spawn(arHeartbeatLoop) end function F.stopAntiRagdoll() antiRagdollModeActive = nil if antiRagdollConn then pcall(function() antiRagdollConn:Disconnect() end); antiRagdollConn = nil end if isBoosting and cachedCharData.humanoid then pcall(function() cachedCharData.humanoid.WalkSpeed = AR_DEFAULT_SPEED end) end isBoosting = false; arDisconnectAll() for _, conn in pairs(S.AntiRagdollConns) do pcall(function() conn:Disconnect() end) end
S.AntiRagdollConns = {}; cachedCharData = {}; S._ragdollCache = {} end local _adDeathConns = {}; local _adHeartConn = nil; local _adCharConn = nil; local _afsLoop = nil local _antiDie = { loop = nil, healthConn = nil, diedConn = nil, humanoid = nil, lastHealTime = 0, invincibleUntil = 0, config = { healthThreshold = 50, invincibilityFrames = 0.75, ragdollProtection = true, autoRevive = true }, } local function _adDisconnectHumanoid() if _antiDie.healthConn then pcall(function() _antiDie.healthConn:Disconnect() end); _antiDie.healthConn = nil end
if _antiDie.diedConn then pcall(function() _antiDie.diedConn:Disconnect() end); _antiDie.diedConn = nil end _antiDie.humanoid = nil end local function _adDisconnectAll() for _, c in ipairs(_adDeathConns) do pcall(function() c:Disconnect() end) end _adDeathConns = {} if _adHeartConn then pcall(function() _adHeartConn:Disconnect() end); _adHeartConn = nil end _adDisconnectHumanoid() end local function _adSuperHeal(hum) if not hum or not hum.Parent then return end local maxHealth = hum.MaxHealth or 100 if maxHealth <= 0 or maxHealth == math.huge then maxHealth = 100 end pcall(function()
hum.Health = maxHealth if hum.MaxHealth < maxHealth then hum.MaxHealth = maxHealth end end) _antiDie.invincibleUntil = tick() + (_antiDie.config.invincibilityFrames or 0.75) _antiDie.lastHealTime = tick() pcall(function() local char = hum.Parent if not char then return end for _, child in ipairs(char:GetChildren()) do if child:IsA("NumberValue") then local name = child.Name:lower() if name:find("health") or name:find("hp") or name:find("life") then child.Value = maxHealth end end if child:IsA("BoolValue") and child.Name:lower():find("dead") then child.Value = false end end end) end
local function _adPreventDamage(root, hum) if not hum then return end if hum.Health < (hum.MaxHealth or 100) then _adSuperHeal(hum) end if tick() < (_antiDie.invincibleUntil or 0) then if hum.Health < (hum.MaxHealth or 100) then pcall(function() hum.Health = hum.MaxHealth or 100 end) end end if _antiDie.config.ragdollProtection then local state = hum:GetState() if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Dead then pcall(function()
hum:ChangeState(Enum.HumanoidStateType.GettingUp) hum:ChangeState(Enum.HumanoidStateType.Running) end) _adSuperHeal(hum) if root then pcall(function() root.AssemblyAngularVelocity = Vector3.zero root.AssemblyLinearVelocity = Vector3.new( root.AssemblyLinearVelocity.X, math.max(root.AssemblyLinearVelocity.Y, -10), root.AssemblyLinearVelocity.Z ) end) end end end if hum.Health <= 0 then _adSuperHeal(hum) pcall(function() hum.PlatformStand = false hum.Sit = false hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end end function F.applyAntiReset()
pcall(function() game:GetService("StarterGui"):SetCore("ResetButtonCallback", false) end) end function F.restoreReset() pcall(function() game:GetService("StarterGui"):SetCore("ResetButtonCallback", true) end) end local function protectCharClean(char) if not S.antiDieEnabled then return end char = char or LP.Character if not char then return end local hum = char:FindFirstChildOfClass("Humanoid") if not hum then local ok, waited = pcall(function() return char:WaitForChild("Humanoid", 3) end) if ok and waited and waited:IsA("Humanoid") then hum = waited end end
if not hum or not S.antiDieEnabled then return end _adDisconnectHumanoid() _antiDie.humanoid = hum pcall(function() hum.BreakJointsOnDeath = false hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end) _adSuperHeal(hum) _antiDie.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function() if not S.antiDieEnabled or not hum.Parent then return end if hum.Health <= 0 or hum.Health < (_antiDie.config.healthThreshold or 50) then _adSuperHeal(hum) end end) table.insert(_adDeathConns, _antiDie.healthConn) _antiDie.diedConn = hum.Died:Connect(function()
if not S.antiDieEnabled or not char.Parent then return end task.wait() if not S.antiDieEnabled or not char.Parent then return end pcall(function() local newHum = Instance.new("Humanoid") newHum.Name = "ReplacedHumanoid" newHum.BreakJointsOnDeath = false newHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) local maxH = (hum.MaxHealth and hum.MaxHealth > 0 and hum.MaxHealth ~= math.huge) and hum.MaxHealth or 100 newHum.MaxHealth = maxH newHum.Health = maxH newHum.Parent = char if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = newHum end
if hum.Parent then hum:Destroy() end end) if S.antiDieEnabled then protectCharClean(char) end end) table.insert(_adDeathConns, _antiDie.diedConn) end function F.startAntiDie() S.antiDieEnabled = true _adDisconnectAll() if _antiDie.loop then pcall(function() _antiDie.loop:Disconnect() end); _antiDie.loop = nil end if _adCharConn then pcall(function() _adCharConn:Disconnect() end); _adCharConn = nil end _antiDie.loop = RunService.Heartbeat:Connect(function() if not S.antiDieEnabled then return end local char = LP.Character if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid") local root = char:FindFirstChild("HumanoidRootPart") if not hum then return end _adPreventDamage(root, hum) end) _adHeartConn = _antiDie.loop _adCharConn = LP.CharacterAdded:Connect(function(c) if not S.antiDieEnabled then return end task.defer(function() protectCharClean(c) end) task.spawn(function() for _ = 1, 12 do if not S.antiDieEnabled then return end F.applyAntiReset() task.wait(0.25) end end) end) task.defer(function() protectCharClean(LP.Character) end) F.applyAntiReset() task.spawn(function() for _ = 1, 12 do
if not S.antiDieEnabled then return end F.applyAntiReset() task.wait(0.25) end end) end function F.stopAntiDie() S.antiDieEnabled = false if _antiDie.loop then pcall(function() _antiDie.loop:Disconnect() end); _antiDie.loop = nil end if _adCharConn then pcall(function() _adCharConn:Disconnect() end); _adCharConn = nil end local hum = _antiDie.humanoid _adDisconnectAll() if hum and hum.Parent then pcall(function() hum.BreakJointsOnDeath = true hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end) end local char = LP.Character; local chum = char and char:FindFirstChildOfClass("Humanoid")
if chum then pcall(function() chum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) if chum.MaxHealth == math.huge then chum.MaxHealth = 100 end chum.Health = math.min(chum.Health, chum.MaxHealth) if chum.Health <= 0 then chum.Health = chum.MaxHealth end end) end F.restoreReset() end local ANTI_FLING_MAX_LIN = 160 local ANTI_FLING_MAX_ANG = 45 local ANTI_FLING_AIMBOT_LIN = 220 local ANTI_FLING_AIMBOT_ANG = 60 local function _antiFlingApply(root, char, maxLin, maxAng) if not root or not root.Parent then return end pcall(function() local v = root.AssemblyLinearVelocity
local horiz = Vector3.new(v.X, 0, v.Z) local hMag = horiz.Magnitude if hMag > maxLin then local scale = maxLin / hMag root.AssemblyLinearVelocity = Vector3.new(v.X * scale, v.Y, v.Z * scale) elseif v.Magnitude > maxLin * 1.35 then root.AssemblyLinearVelocity = v.Unit * maxLin end local av = root.AssemblyAngularVelocity if av.Magnitude > maxAng then root.AssemblyAngularVelocity = Vector3.zero end if char then for _, p in ipairs(char:GetChildren()) do if p:IsA("BasePart") and p ~= root then local pv = p.AssemblyLinearVelocity local ph = Vector3.new(pv.X, 0, pv.Z)
if ph.Magnitude > maxLin * 1.2 then local scale = (maxLin * 1.05) / ph.Magnitude p.AssemblyLinearVelocity = Vector3.new(pv.X * scale, pv.Y, pv.Z * scale) end if p.AssemblyAngularVelocity.Magnitude > maxAng then p.AssemblyAngularVelocity = Vector3.zero end end end end end) end function F.startAntiFlingShield() S.antiFlingShieldEnabled = true if _afsLoop then pcall(function() _afsLoop:Disconnect() end); _afsLoop = nil end _afsLoop = RunService.Heartbeat:Connect(function() if not S.antiFlingShieldEnabled then return end local char = LP.Character if not char then return end
local root = char:FindFirstChild("HumanoidRootPart") if not root then return end local aimOn = (S.autoBatEnabled == true) or (tpBatEnabled == true) or (S.antiBatBypassEnabled == true) local maxLin = aimOn and ANTI_FLING_AIMBOT_LIN or ANTI_FLING_MAX_LIN local maxAng = aimOn and ANTI_FLING_AIMBOT_ANG or ANTI_FLING_MAX_ANG _antiFlingApply(root, char, maxLin, maxAng) end) end function F.stopAntiFlingShield() S.antiFlingShieldEnabled = false if _afsLoop then pcall(function() _afsLoop:Disconnect() end); _afsLoop = nil end end
local removeAccConn = nil; local removeAccChildConn = nil; local removeAccActive = false
local function isLocalAvaPresetCharacter(char)
    return char ~= nil and LP ~= nil and char == LP.Character and S.avaPresetEnabled == true
end
local function isHatOrHairAccessory(accessory)
    if not accessory or not accessory:IsA("Accessory") then return false end
    local parentChar = nil
    pcall(function()
        parentChar = LP.Character
        if parentChar and accessory:IsDescendantOf(parentChar) and S.avaPresetEnabled == true then
            return false
        end
    end)
    local tagged = false
    pcall(function()
        tagged = accessory:GetAttribute("_VyxroAvatarChanger") == true or accessory:GetAttribute("_VxyroAvaPreset") == true
    end)
    if tagged then return false end
    local accessoryType = nil
    pcall(function() accessoryType = accessory.AccessoryType end)
    if accessoryType == Enum.AccessoryType.Hat or accessoryType == Enum.AccessoryType.Hair then return true end
    for _, item in ipairs(accessory:GetDescendants()) do
        if item:IsA("Attachment") and (item.Name == "HatAttachment" or item.Name == "HairAttachment") then return true end
    end
    local lowerName = tostring(accessory.Name):lower()
    return lowerName:find("hair", 1, true) ~= nil or lowerName:find("hat", 1, true) ~= nil
end
local function removeCharAccessories(char)
    if not char or isLocalAvaPresetCharacter(char) then return end
    for _, child in ipairs(char:GetChildren()) do
        pcall(function()
            if child:IsA("Accessory") and isHatOrHairAccessory(child) then child:Destroy() end
        end)
    end
end
function F.startRemoveAccessories()
    removeAccActive = true; S.removeAccessoriesEnabled = true
    local function bindCharacter(char)
        if removeAccChildConn then removeAccChildConn:Disconnect(); removeAccChildConn = nil end
        -- Ava Preset owns the local character's wearables while active.
        -- Never let Remove Accessories touch that character during a preset apply/switch.
        if isLocalAvaPresetCharacter(char) then return end
        removeCharAccessories(char)
        if char then
            removeAccChildConn = char.ChildAdded:Connect(function(child)
                if not removeAccActive or not child:IsA("Accessory") then return end
                if isLocalAvaPresetCharacter(char) then return end
                task.defer(function()
                    if not removeAccActive or isLocalAvaPresetCharacter(char) then return end
                    if child.Parent == char then removeCharAccessories(char) end
                end)
            end)
        end
    end
    bindCharacter(LP.Character)
    if removeAccConn then removeAccConn:Disconnect() end
    removeAccConn = LP.CharacterAdded:Connect(function(char)
        task.wait(0.15)
        bindCharacter(char)
    end)
end
function F.stopRemoveAccessories() removeAccActive = false; S.removeAccessoriesEnabled = false
if removeAccConn then removeAccConn:Disconnect(); removeAccConn = nil end if removeAccChildConn then removeAccChildConn:Disconnect(); removeAccChildConn = nil end end local moveProxy = nil function F.ensureProxy() local c = LP.Character if not c then return nil end local root = c:FindFirstChild("HumanoidRootPart") if not root then return nil end if moveProxy and moveProxy.Parent == c then return moveProxy end if moveProxy then moveProxy:Destroy() end
moveProxy = Instance.new("Part"); moveProxy.Name = "VyxroDuel_MoveProxy"; moveProxy.Size = Vector3.new(1, 1, 1); moveProxy.Transparency = 1; moveProxy.CanCollide = false; moveProxy.Massless = true; moveProxy.Parent = c; local weld = Instance.new("WeldConstraint"); weld.Part0 = root; weld.Part1 = moveProxy; weld.Parent = moveProxy return moveProxy end function F.destroyProxy() if moveProxy then moveProxy:Destroy(); moveProxy = nil end end local infJumpEnabled = false; local holdInfJumpConn = nil; local infJumpInputConns = {}; local INF_JUMP_POWER = 55 local function applyJumpVel(root, y)
if not root or not root.Parent then return end pcall(function() local cv = root.AssemblyLinearVelocity root.AssemblyLinearVelocity = Vector3.new(cv.X, y, cv.Z) end) end local function manualJumpBoost(boost) if not infJumpEnabled then return end if (S.infJumpMode or "hold") ~= "manual" then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") if root then applyJumpVel(root, boost or INF_JUMP_POWER) end end local function startHoldInfJump() if holdInfJumpConn then return end holdInfJumpConn = RunService.Heartbeat:Connect(function()
if not infJumpEnabled then return end if (S.infJumpMode or "hold") ~= "hold" then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid") if not root or not hum then return end local isJumpHeld = false pcall(function() isJumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.ButtonA) or (hum.Jump == true) end) local cv = root.AssemblyLinearVelocity if isJumpHeld and cv.Y < 35 then applyJumpVel(root, INF_JUMP_POWER) end cv = root.AssemblyLinearVelocity
if cv.Y < -120 then applyJumpVel(root, -120) end end) end local function stopHoldInfJump() if holdInfJumpConn then pcall(function() holdInfJumpConn:Disconnect() end) holdInfJumpConn = nil end end function F.startInfJump() for _, c in ipairs(infJumpInputConns) do pcall(function() c:Disconnect() end) end infJumpInputConns = {}; stopHoldInfJump() table.insert(infJumpInputConns, UIS.JumpRequest:Connect(function() if not infJumpEnabled then return end if (S.infJumpMode or "hold") == "manual" then manualJumpBoost(50) end end))
table.insert(infJumpInputConns, UIS.InputBegan:Connect(function(input, gp) if gp or UIS:GetFocusedTextBox() then return end if not infJumpEnabled then return end if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then if (S.infJumpMode or "hold") == "manual" then manualJumpBoost(50) end end end)) if (S.infJumpMode or "hold") == "hold" then startHoldInfJump() end end function F.stopInfJump() stopHoldInfJump() for _, c in ipairs(infJumpInputConns) do pcall(function() c:Disconnect() end) end infJumpInputConns = {} end function F.setInfJumpMode(mode)
mode = (mode == "manual") and "manual" or "hold"; S.infJumpMode = mode if infJumpEnabled then F.startInfJump() else stopHoldInfJump() end end local mirrorTPPreviousY = {}; local mirrorTPLastTeleport = 0; local mirrorTPConn = nil local function mirrorTPAimbotActive() return (aimbotEnabled == true) or (tpBatEnabled == true) or (S.autoBatEnabled == true) or (_G.MirrorNormalAimbotOn == true) or (_G.MirrorAntiBypassAimbotOn == true) or (_G.MirrorAntiDesyncAimbotOn == true) end local MIRROR_TP_DROP_THRESHOLD = 3; local MIRROR_TP_DOWN_Y = -7.00 local function mirrorTPTeleportDown()
local character = LP.Character; local root = character and character:FindFirstChild("HumanoidRootPart"); local humanoid = character and character:FindFirstChildOfClass("Humanoid") if not root or not humanoid or humanoid.Health <= 0 then return end local now = tick() if now - (mirrorTPLastTeleport or 0) < 0.08 then return end mirrorTPLastTeleport = now; local _, yaw = root.CFrame:ToEulerAnglesYXZ(); root.CFrame = CFrame.new(root.Position.X, MIRROR_TP_DOWN_Y, root.Position.Z) * CFrame.Angles(0, yaw, 0); root.Velocity = Vector3.zero
pcall(function() root.AssemblyLinearVelocity = Vector3.zero end) end function F.startMirrorTPDown() if mirrorTPConn then return end S.mirrorTPDownEnabled = true _G.MirrorSetTPDown = function(enabled) S.mirrorTPDownEnabled = enabled == true if not S.mirrorTPDownEnabled then mirrorTPPreviousY = {} end end mirrorTPConn = RunService.Heartbeat:Connect(function() if not S.mirrorTPDownEnabled then return end if not mirrorTPAimbotActive() then if next(mirrorTPPreviousY) then mirrorTPPreviousY = {} end return end for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then
local tr = plr.Character:FindFirstChild("HumanoidRootPart") if tr then local currentY = tr.Position.Y; local previousY = mirrorTPPreviousY[plr.UserId] if previousY and (previousY - currentY) >= MIRROR_TP_DROP_THRESHOLD then pcall(mirrorTPTeleportDown); mirrorTPPreviousY = {} return end mirrorTPPreviousY[plr.UserId] = currentY end end end end) end function F.stopMirrorTPDown() S.mirrorTPDownEnabled = false if mirrorTPConn then pcall(function() mirrorTPConn:Disconnect() end) mirrorTPConn = nil end mirrorTPPreviousY = {} end
do
    local floatConnection = nil
    local floatCharacterConnection = nil
    local floatTargetY = nil
    local function floatRoot()
        local char = LP.Character
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end
    local function floatStopInternal()
        if floatConnection then pcall(function() floatConnection:Disconnect() end) end
        floatConnection = nil
        floatTargetY = nil
    end
    local previousFloat = rawget(_G, "__VyxroFloatController")
    if type(previousFloat) == "table" and type(previousFloat.stop) == "function" then pcall(previousFloat.stop) end
    function F.startFloat()
        if floatConnection then return true end
        local root = floatRoot()
        if not root then return false end
        local height = math.clamp(tonumber(S.floatHeight) or 18, 4, 80)
        local speed = math.clamp(tonumber(S.floatSpeed) or 10, 2, 30)
        S.floatHeight, S.floatSpeed = height, speed
        floatTargetY = root.Position.Y + height
        floatConnection = RunService.Heartbeat:Connect(function()
            if S.floatEnabled ~= true then return end
            local rp = floatRoot()
            if not rp then return end
            local target = floatTargetY
            if not target then target = rp.Position.Y + height; floatTargetY = target end
            if math.abs(rp.Position.Y - target) > 45 then floatTargetY = rp.Position.Y + height; target = floatTargetY end
            local dy = rp.Position.Y - target
            local yVel = 0
            if dy < -0.35 then yVel = speed elseif dy > 0.35 then yVel = -math.min(5, speed) end
            pcall(function() local cv = rp.AssemblyLinearVelocity; rp.AssemblyLinearVelocity = Vector3.new(cv.X, yVel, cv.Z) end)
        end)
        return true
    end
    function F.stopFloat() floatStopInternal(); return true end
    function F.setFloat(on)
        on = on == true; S.floatEnabled = on
        if on then F.startFloat() else F.stopFloat() end
        pcall(function() if _G._VersincRefreshMobileButtons then _G._VersincRefreshMobileButtons() end end)
        pcall(function() if F.saveConfig then F.saveConfig(true) end end)
        pcall(function() if _G.__VxyroSpaceRefreshUI then _G.__VxyroSpaceRefreshUI() end end)
        return on
    end
    function F.toggleFloat() return F.setFloat(S.floatEnabled ~= true) end
    function F.getFloatSpeed() return tonumber(S.floatSpeed) or 10 end
    function F.setFloatModeSpeed(v) S.floatSpeed = math.clamp(tonumber(v) or 10, 2, 30); return S.floatSpeed end
    function F.cycleFloatMode() return "normal" end
    floatCharacterConnection = LP.CharacterAdded:Connect(function(char)
        if not S.floatEnabled then return end
        task.spawn(function()
            local root = char:WaitForChild("HumanoidRootPart", 10)
            if not root or S.floatEnabled ~= true then return end
            task.wait(0.15); floatStopInternal(); F.startFloat()
        end)
    end)
    _G.__VyxroFloatController = { stop = function() S.floatEnabled=false; floatStopInternal(); if floatCharacterConnection then pcall(function() floatCharacterConnection:Disconnect() end) end; floatCharacterConnection=nil end }
end
function F.setMirrorTPDown(on) if on then F.startMirrorTPDown() else F.stopMirrorTPDown() end if VS.setMirrorTPVisual then VS.setMirrorTPVisual(on == true) end end -- ============================================================
-- AIMBOT RUNTIME CLEANUP / MODE STATE
-- V1 = VXYRO logic from this file
-- V2 = VASPER standalone logic supplied separately
-- ============================================================
do
    local previous = rawget(_genv, "__VyxroDuelAimbotRuntime")
    if type(previous) == "table" and type(previous.stop) == "function" then
        pcall(previous.stop)
    end

    -- Also stop a separately executed Vasper standalone instance so
    -- switching/re-executing cannot leave a second RenderStepped loop running.
    pcall(function()
        local previousVasper = rawget(_genv, "VasperAimbot")
        if type(previousVasper) == "table" and type(previousVasper.Stop) == "function" then
            previousVasper.Stop()
        end
    end)
end

local aimbotEnabled = false; local tpBatEnabled = false; local tpBatMode = 1; local TP_BAT_KEY = Enum.KeyCode.V; local TP_BAT_CONTROLLER = Enum.KeyCode.ButtonY; local setTPBatVisual, tpBatUIState, tpBatModeLbl = nil, nil, nil
local setAimbotState, setTPBatState, getTPBatMode, findBatTool, getClosestAliveRoot local TP_BAT_MODES local startAimbot, stopAimbot, startVxyroAimbot, startVasperAimbot, startTPBat, stopTPBat local function __initAimbotTPBat() aimbotEnabled = false; local aimbotConn = nil; tpBatEnabled = false; local aimbotSwingCooldown = false; local AIMBOT_SPEED = 63; local AIMBOT_VERT_SPEED = 52; local AIMBOT_DISTANCE = -2.8; local AIMBOT_HEIGHT = 4.75; local AIMBOT_V_OFFSET = 1; local AIMBOT_MAX_TURN_RATE = 28; local AIMBOT_SWING_DIST = 5; local AIMBOT_SWING_CD = 0.3; local _aimbotLastSwing = 0 findBatTool = function()
local char = LP.Character if not char then return nil end for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("slap")) then return t end end local bp = LP:FindFirstChild("Backpack") or LP:FindFirstChildOfClass("Backpack") if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("slap")) then return t end end end return nil end local function swingBatTool() if aimbotSwingCooldown then return end aimbotSwingCooldown = true pcall(function() local bat = findBatTool()
local char = LP.Character if not bat or not char then return end local hum = char:FindFirstChildOfClass("Humanoid") if bat.Parent ~= char and hum then pcall(function() hum:EquipTool(bat) end) end local remote = bat:FindFirstChildOfClass("RemoteEvent") if remote then pcall(function() remote:FireServer() end) else pcall(function() bat:Activate() end) end end) task.delay(0.09, function() aimbotSwingCooldown = false end) end local _closestCache, _closestCacheAt = nil, 0 getClosestAliveRoot = function() local now = os.clock(); local ttl = _IS_MOBILE and 0.07 or 0.025
if _closestCache and (now - _closestCacheAt) < ttl then if _closestCache.Parent then return _closestCache end end local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not root then return nil end local closest, minDist = nil, math.huge for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then local tRoot = plr.Character:FindFirstChild("HumanoidRootPart"); local hum = plr.Character:FindFirstChildOfClass("Humanoid") if tRoot and hum and hum.Health > 0 then local d = (tRoot.Position - root.Position).Magnitude if d < minDist then
minDist = d; closest = tRoot end end end end _closestCache, _closestCacheAt = closest, now return closest end

-- ============================================================
-- BAT AIMBOT (dari linx.vs / LINX HUB)
-- ============================================================
local _linxAimbotSpeed = 58
local _linxLaggerAimbotSpeed = 40
local _linxAutoSwingEnabled = true
local _linxAimbotTarget = nil

local function _linxGetAimbotSpeed()
    if S.laggerToggled or S.laggerCarryActive then
        return tonumber(_linxLaggerAimbotSpeed) or 40
    end
    return tonumber(_linxAimbotSpeed) or 58
end

-- ============================================================
-- AIMBOT V1 - VXYRO
-- Original Vyxro/LINX aimbot logic from this file.
-- ============================================================
startVxyroAimbot = function()
    if aimbotConn then
        pcall(function() aimbotConn:Disconnect() end)
        aimbotConn = nil
    end
    if tpBatEnabled then return end

    local char0 = LP.Character
    local hum0 = char0 and char0:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate = false end

    aimbotEnabled = true
    _linxAimbotTarget = nil

    aimbotConn = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled or tpBatEnabled or (S.aimbotMode or 1) ~= 1 then return end

        local char = LP.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then return end

        if hum.AutoRotate then
            hum.AutoRotate = false
        end

        local bat = findBatTool and findBatTool() or nil
        if bat and bat.Parent ~= char then
            pcall(function() hum:EquipTool(bat) end)
        end

        local target = getClosestAliveRoot and getClosestAliveRoot() or nil
        if not target or not target.Parent then
            _linxAimbotTarget = nil
            root.AssemblyAngularVelocity = Vector3.zero
            if _linxAutoSwingEnabled and bat then
                pcall(function() bat:Activate() end)
            end
            return
        end
        _linxAimbotTarget = target

        local targetVel = target.AssemblyLinearVelocity
        pcall(function()
            if (not targetVel or targetVel.Magnitude < 0.01) and target.Velocity then
                targetVel = target.Velocity
            end
        end)
        if typeof(targetVel) ~= "Vector3" then
            targetVel = Vector3.zero
        end

        local myPos = root.Position
        local targetPos = target.Position

        local predictPos = targetPos + targetVel * 0.14 + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flat = Vector3.new(direction.X, 0, direction.Z)
        local flatDir = (flat.Magnitude > 0.01) and flat.Unit or Vector3.zero

        local chaseSpeed = _linxGetAimbotSpeed()
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8

        if hum.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, 13)
        end
        yVel = math.clamp(yVel, -70, 110)

        local desiredVel = Vector3.new(
            flatDir.X * chaseSpeed,
            yVel,
            flatDir.Z * chaseSpeed
        )

        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        pcall(function() root.Velocity = root.AssemblyLinearVelocity end)

        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime

        if (predictedPos - myPos).Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(
                Vector3.new(rx * 42, ry * 42, rz * 42)
            )
        else
            root.AssemblyAngularVelocity = Vector3.zero
        end

        if _linxAutoSwingEnabled and bat then
            pcall(function() bat:Activate() end)
        end
    end)
end

-- ============================================================
-- AIMBOT V2 - VASPER
-- Exact standalone Vasper logic supplied by the user, integrated
-- behind the V2 selector without its original GUI/other features.
-- ============================================================
local vasperAimbotEnabled = false
local vasperAimbotConn = nil
local vasperAimbotTarget = nil

local function vasperFindBat()
    local char = LP.Character
    if not char then
        return nil
    end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("bat") or name:find("slap") then
                return tool
            end
        end
    end

    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("bat") or name:find("slap") then
                    return tool
                end
            end
        end
    end

    return nil
end

local function vasperGetClosestTarget()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local closest = nil
    local minDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")

            if targetRoot and hum and hum.Health > 0 then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = targetRoot
                end
            end
        end
    end

    return closest
end

local function stopVasperAimbot()
    vasperAimbotEnabled = false
    vasperAimbotTarget = nil

    if vasperAimbotConn then
        pcall(function() vasperAimbotConn:Disconnect() end)
        vasperAimbotConn = nil
    end

    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.AutoRotate = true
    end
end

local function startVasperAimbot()
    if vasperAimbotConn then
        pcall(function() vasperAimbotConn:Disconnect() end)
        vasperAimbotConn = nil
    end
    if tpBatEnabled then return end

    vasperAimbotEnabled = true
    aimbotEnabled = true

    local character = LP.Character
    local humanoid0 = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid0 then
        humanoid0.AutoRotate = false
    end

    vasperAimbotConn = RunService.RenderStepped:Connect(function()
        if not vasperAimbotEnabled or tpBatEnabled or (S.aimbotMode or 1) ~= 2 then
            return
        end

        local char = LP.Character
        if not char then
            return
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then
            return
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            return
        end

        -- Automatically equip the first Bat/Slap tool that exists.
        if not char:FindFirstChildOfClass("Tool") then
            local bat = vasperFindBat()
            if bat then
                pcall(function()
                    hum:EquipTool(bat)
                end)
            end
        end

        local target = vasperGetClosestTarget()
        if not target then
            vasperAimbotTarget = nil
            return
        end

        vasperAimbotTarget = target

        local targetVel = target.AssemblyLinearVelocity
        local myPos = root.Position
        local targetPos = target.Position

        -- Original Vasper target prediction.
        local predictPos = targetPos + targetVel * 0.14
        predictPos = predictPos + target.CFrame.LookVector * 0.3

        local direction = predictPos - myPos
        local flat = Vector3.new(direction.X, 0, direction.Z)
        if flat.Magnitude <= 0.001 then
            return
        end

        local flatDir = flat.Unit
        local chaseSpeed = 58
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8

        if hum.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, 13)
        end

        yVel = math.clamp(yVel, -70, 110)

        local desiredVel = Vector3.new(
            flatDir.X * chaseSpeed,
            yVel,
            flatDir.Z * chaseSpeed
        )

        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)

        -- Original Vasper rotational prediction / tracking.
        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos

        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()

            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)

            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(
                Vector3.new(rx * 42, ry * 42, rz * 42)
            )
        end
    end)
end

-- One public start/stop pair. Every caller (GUI, mobile button,
-- config restore, TP-Bat handoff) now uses the selected mode.
startAimbot = function()
    -- Always tear down both implementations first so a mode change
    -- can never leave two RenderStepped connections active.
    pcall(stopAimbot)
    if (S.aimbotMode or 1) == 2 then
        startVasperAimbot()
    else
        startVxyroAimbot()
    end
end

stopAimbot = function()
    aimbotEnabled = false
    vasperAimbotEnabled = false
    _linxAimbotTarget = nil

    if aimbotConn then
        pcall(function() aimbotConn:Disconnect() end)
        aimbotConn = nil
    end

    stopVasperAimbot()

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = true
    end
end

setAimbotState = function(on)
    on = on == true

    if on then
        if F.safeModeTryStart and not F.safeModeTryStart() then
            return false
        end

        -- EXCLUSIVE COMBAT MODE:
        -- BAT AIMBOT cannot run together with Auto Left / Auto Right.
        -- Stop both their logic loops before starting the aimbot.
        if S.autoLeftEnabled then
            S.autoLeftEnabled = false
            pcall(function() if F.stopAutoLeft then F.stopAutoLeft() end end)
            pcall(function() if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end end)
        end
        if S.autoRightEnabled then
            S.autoRightEnabled = false
            pcall(function() if F.stopAutoRight then F.stopAutoRight() end end)
            pcall(function() if S.autoRightSetVisual then S.autoRightSetVisual(false) end end)
        end

        if tpBatEnabled then
            pcall(function() if stopTPBat then stopTPBat() end end)
            tpBatEnabled = false
            if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, false) end
        end
        if S.autoBatEnabled and S.disableAutoBat then
            pcall(S.disableAutoBat)
            if S.autoBatSetVisual then pcall(S.autoBatSetVisual, false) end
        end

        _G.__VxyroCombatMode = "aimbot"
        pcall(stopAimbot)
        local ok, err = pcall(startAimbot)
        if not ok then
            warn("[Vyxro Duel] Aimbot start failed: " .. tostring(err))
            pcall(stopAimbot)
            aimbotEnabled = false
            vasperAimbotEnabled = false
        end
    else
        pcall(stopAimbot)
        if _G.__VxyroCombatMode == "aimbot" then _G.__VxyroCombatMode = "none" end
    end

    local _aimbotResult = aimbotEnabled == true or vasperAimbotEnabled == true
    pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Bat Aimbot", _aimbotResult) end end)
    return _aimbotResult
end

-- Expose a tiny runtime handle so a re-executed Vyxro instance can
-- cleanly stop this instance before creating a new one.
_genv.__VyxroDuelAimbotRuntime = { stop = stopAimbot }


-- ============================================================
-- TP BAT V1 - SPACE TP BAT
-- Replaced the old Vxyro / Macho / V3 selector logic with the
-- V1 behavior from Space Tp Bat.txt. No V2/V3 selector remains.
-- ============================================================
do
    local previousSpaceTpBat = rawget(_genv, "__VxyroSpaceTpBatRuntime")
    if type(previousSpaceTpBat) == "table" and type(previousSpaceTpBat.stop) == "function" then
        pcall(previousSpaceTpBat.stop)
    end

    local SPACE_TPBAT_CONFIG = {
        range = 250,
        tpOffset = Vector3.new(0, 0, 0),
        loopDelay = 0.08,
        smartRotation = true,
        resetVelocity = true,
        predictMovement = true,
        predictionFactor = 0.15,
        healthCheck = true,
        teamCheck = false,
        behindTarget = false,
        behindDistance = 4,
        antiFling = true,
        sideOffset = 2.5,
    }

    local spaceTpBatHrp = nil
    local spaceTpBatHumanoid = nil
    local spaceTpBatThread = nil
    local spaceTpBatHitCooldown = false

    local function spaceTpBatUpdateCharacter()
        local char = LP.Character
        if not char then
            spaceTpBatHrp = nil
            spaceTpBatHumanoid = nil
            return
        end
        spaceTpBatHrp = char:FindFirstChild("HumanoidRootPart")
        spaceTpBatHumanoid = char:FindFirstChildOfClass("Humanoid")
    end

    local function spaceTpBatGetBat()
        local character = LP.Character
        if not character then return nil end
        local tool = character:FindFirstChild("Bat")
        if tool and tool:IsA("Tool") then return tool end
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("bat") or n:find("slap") then return child end
            end
        end
        local backpack = LP:FindFirstChild("Backpack") or LP:FindFirstChildOfClass("Backpack")
        if backpack then
            tool = backpack:FindFirstChild("Bat")
            if tool and tool:IsA("Tool") then
                pcall(function()
                    local hum = character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:EquipTool(tool) end
                end)
                return tool
            end
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    local n = child.Name:lower()
                    if n:find("bat") or n:find("slap") then
                        pcall(function() child.Parent = character end)
                        return child
                    end
                end
            end
        end
        return nil
    end

    local function spaceTpBatTryHit()
        if spaceTpBatHitCooldown then return end
        spaceTpBatHitCooldown = true
        pcall(function()
            local bat = spaceTpBatGetBat()
            if bat then
                pcall(function() bat:Activate() end)
                local remoteEvent = bat:FindFirstChildWhichIsA("RemoteEvent")
                if remoteEvent then pcall(function() remoteEvent:FireServer() end) end
            end
        end)
        task.delay(0.08, function()
            spaceTpBatHitCooldown = false
        end)
    end

    local function spaceTpBatIsValidEnemy(player)
        if player == LP or not player.Character then return false end
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end
        if SPACE_TPBAT_CONFIG.healthCheck and humanoid.Health <= 0 then return false end
        if SPACE_TPBAT_CONFIG.teamCheck and player.Team == LP.Team and player.Team ~= nil then return false end
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        return true, root, humanoid
    end

    local function spaceTpBatPredict(rootPart)
        if not SPACE_TPBAT_CONFIG.predictMovement then return rootPart.Position end
        return rootPart.Position + (rootPart.AssemblyLinearVelocity * SPACE_TPBAT_CONFIG.predictionFactor)
    end

    local function spaceTpBatFindNearest()
        local myRoot = spaceTpBatHrp or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
        if not myRoot then return nil end
        local nearest = nil
        local shortest = SPACE_TPBAT_CONFIG.range
        for _, player in ipairs(Players:GetPlayers()) do
            local valid, root = spaceTpBatIsValidEnemy(player)
            if valid then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = root
                end
            end
        end
        return nearest
    end

    local function spaceTpBatTeleport(targetRoot)
        if not targetRoot then return end
        local myRoot = spaceTpBatHrp or (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"))
        local myHum = spaceTpBatHumanoid or (LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"))
        if not myRoot then return end

        local targetPos = spaceTpBatPredict(targetRoot)
        local finalPos
        if SPACE_TPBAT_CONFIG.behindTarget then
            local delta = targetPos - myRoot.Position
            local direction = delta.Magnitude > 0.001 and delta.Unit or Vector3.new(0,0,1)
            finalPos = targetPos - direction * SPACE_TPBAT_CONFIG.behindDistance + Vector3.new(0,2,0)
        elseif SPACE_TPBAT_CONFIG.sideOffset > 0 then
            local dir = myRoot.Position - targetPos
            dir = Vector3.new(dir.X, 0, dir.Z)
            if dir.Magnitude < 0.1 then dir = Vector3.new(1,0,0) else dir = dir.Unit end
            finalPos = targetPos + dir * SPACE_TPBAT_CONFIG.sideOffset
        else
            finalPos = targetPos + SPACE_TPBAT_CONFIG.tpOffset
        end

        if SPACE_TPBAT_CONFIG.smartRotation then
            myRoot.CFrame = CFrame.new(finalPos, targetPos)
        else
            myRoot.CFrame = CFrame.new(finalPos)
        end

        if SPACE_TPBAT_CONFIG.resetVelocity then
            pcall(function()
                myRoot.Velocity = Vector3.zero
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.RotVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        if SPACE_TPBAT_CONFIG.antiFling and myHum then
            pcall(function()
                myHum.PlatformStand = false
                myHum.Sit = false
            end)
        end
    end

    local spaceTpBatCharacterConn = nil
    spaceTpBatUpdateCharacter()
    spaceTpBatCharacterConn = LP.CharacterAdded:Connect(function(char)
        spaceTpBatHrp = nil
        spaceTpBatHumanoid = nil
        task.defer(function()
            if char == LP.Character then
                pcall(function() char:WaitForChild("HumanoidRootPart", 5) end)
                pcall(function() char:WaitForChild("Humanoid", 5) end)
                spaceTpBatUpdateCharacter()
            end
        end)
    end)

    getTPBatMode = function()
        return { name = "V1 SPACE TP BAT" }
    end

    local function spaceTpBatAutoBatEnabled()
        -- Keep the behavior compatible with the hub's existing Auto Bat toggle.
        return S.autoBatEnabled ~= false
    end

    startTPBat = function()
        if tpBatEnabled then return end
        tpBatEnabled = true
        tpBatMode = 1
        spaceTpBatUpdateCharacter()
        if spaceTpBatThread then pcall(function() task.cancel(spaceTpBatThread) end) end
        spaceTpBatThread = task.spawn(function()
            while tpBatEnabled do
                spaceTpBatUpdateCharacter()
                local target = spaceTpBatFindNearest()
                if target then
                    spaceTpBatTeleport(target)
                    if spaceTpBatAutoBatEnabled() then
                        spaceTpBatTryHit()
                    end
                end
                task.wait(SPACE_TPBAT_CONFIG.loopDelay)
            end
        end)
        if tpBatUIState then pcall(tpBatUIState, true) end
        if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, true) end
    end

    stopTPBat = function()
        tpBatEnabled = false
        if spaceTpBatThread then
            pcall(function() task.cancel(spaceTpBatThread) end)
            spaceTpBatThread = nil
        end
        spaceTpBatHitCooldown = false
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                root.AssemblyAngularVelocity = Vector3.zero
                root.AssemblyLinearVelocity = Vector3.zero
            end)
        end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.AutoRotate = true end) end
        if tpBatUIState then pcall(tpBatUIState, false) end
        if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, false) end
        spaceTpBatUpdateCharacter()
    end

    setTPBatState = function(on)
        on = on == true
        if on then
            -- EXCLUSIVE 4-WAY COMBAT MODE:
            -- TP BAT cannot run together with BAT AIMBOT, Auto Left or Auto Right.
            pcall(function()
                if aimbotEnabled or vasperAimbotEnabled then
                    if stopAimbot then stopAimbot() end
                    aimbotEnabled = false
                    vasperAimbotEnabled = false
                    if VS and VS.setAimbotVisual then VS.setAimbotVisual(false) end
                end
            end)

            if S.autoLeftEnabled then
                S.autoLeftEnabled = false
                pcall(function() if F.stopAutoLeft then F.stopAutoLeft() end end)
                pcall(function() if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end end)
            end
            if S.autoRightEnabled then
                S.autoRightEnabled = false
                pcall(function() if F.stopAutoRight then F.stopAutoRight() end end)
                pcall(function() if S.autoRightSetVisual then S.autoRightSetVisual(false) end end)
            end

            -- Stop the separate Auto Bat runtime as well; it is another targeting controller.
            if S.autoBatEnabled and S.disableAutoBat then
                pcall(S.disableAutoBat)
                if S.autoBatSetVisual then pcall(S.autoBatSetVisual, false) end
            end
            startTPBat()
            _G.__VxyroCombatMode = "tpBat"
        else
            stopTPBat()
            if _G.__VxyroCombatMode == "tpBat" then _G.__VxyroCombatMode = "none" end
        end
        local result = tpBatEnabled == true
        if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, result) end
        pcall(function()
            if _G.ShowTogglePing then _G.ShowTogglePing("TP Bat", result) end
        end)
        pcall(function() if _G.VersincRefreshMobileStates then _G.VersincRefreshMobileStates() end end)
        return result
    end

    -- Runtime cleanup for safe re-execution. Without this, an old TP BAT worker
    -- could keep teleporting the character after the hub is executed again.
    _genv.__VxyroSpaceTpBatRuntime = {
        stop = function()
            tpBatEnabled = false
            if spaceTpBatThread then
                pcall(function() task.cancel(spaceTpBatThread) end)
                spaceTpBatThread = nil
            end
            if spaceTpBatCharacterConn then
                pcall(function() spaceTpBatCharacterConn:Disconnect() end)
                spaceTpBatCharacterConn = nil
            end
            spaceTpBatHitCooldown = false
        end,
    }

    -- Compatibility hooks used elsewhere in the hub, but there is no mode selector.
    UI = UI or {}
    UI.refreshTPBatMode = function() tpBatMode = 1 end
    UI.selectTPBatMode = function(mode) return tonumber(mode) == 1 end
end
local antiBatBypassLockEnabled = false; local AceAntiBypassAimbot = { conn = nil, swingCooldown = false, prevAutoRotate = nil }; local AceAntiBypassAimbotSpeed = 58; local AceAntiBypassLaggerAimbotSpeed = 40 local function GetAntiBypassAimbotSpeed() if S.laggerToggled then return tonumber(AceAntiBypassLaggerAimbotSpeed) or 40 end return tonumber(AceAntiBypassAimbotSpeed) or 58 end local function AntiBypassGetClosest()
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not root then return nil, math.huge end local closest, minDist = nil, math.huge for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then local tRoot = plr.Character:FindFirstChild("HumanoidRootPart"); local hum = plr.Character:FindFirstChildOfClass("Humanoid") if tRoot and hum and hum.Health > 0 then local dist = (tRoot.Position - root.Position).Magnitude if dist < minDist then minDist = dist; closest = tRoot end end end end return closest, minDist end local function AntiBypassFindBat()
if findBatTool then return findBatTool() end local char = LP.Character if not char then return nil end for _, tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") then local n = tool.Name:lower() if n:find("bat") or n:find("slap") then return tool end end end local bp = LP:FindFirstChild("Backpack") if bp then for _, tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") then local n = tool.Name:lower() if n:find("bat") or n:find("slap") then return tool end end end end return nil end local function AntiBypassTrySwing() if AceAntiBypassAimbot.swingCooldown then return end
if S.autoSwingEnabled == false then return end AceAntiBypassAimbot.swingCooldown = true pcall(function() local char = LP.Character if not char then return end local bat = AntiBypassFindBat() if not bat then return end local hum = char:FindFirstChildOfClass("Humanoid") if bat.Parent ~= char and hum then pcall(function() hum:EquipTool(bat) end) end pcall(function() bat:Activate() end) local ev = bat:FindFirstChildWhichIsA("RemoteEvent") if ev then pcall(function() ev:FireServer() end) end end) task.delay(0.03, function() AceAntiBypassAimbot.swingCooldown = false end) end
function F.startAimbotBypassAntiBat() pcall(function() if tpBatEnabled and stopTPBat then stopTPBat() end end) pcall(function() if aimbotEnabled and stopAimbot then stopAimbot() end end) pcall(function() if S.autoBatEnabled and S.disableAutoBat then S.disableAutoBat() end end) if AceAntiBypassAimbot.conn then pcall(function() AceAntiBypassAimbot.conn:Disconnect() end) AceAntiBypassAimbot.conn = nil end antiBatBypassLockEnabled = true; S.antiBatBypassEnabled = true; local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if hum0 then
AceAntiBypassAimbot.prevAutoRotate = hum0.AutoRotate; hum0.AutoRotate = false end pcall(function() F.destroyProxy() end) local bypassTick = 0; local _bpTarget, _bpDist, _bpLastScan = nil, math.huge, 0 AceAntiBypassAimbot.conn = RunService.Heartbeat:Connect(function() if not antiBatBypassLockEnabled then return end bypassTick = bypassTick + 1 if bypassTick % (_IS_MOBILE and 3 or 8) == 0 then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end if bypassTick % 5 == 0 then local bat = AntiBypassFindBat() if bat and bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end end local now = os.clock() if (now - _bpLastScan) >= (_IS_MOBILE and 0.08 or 0.03) then _bpLastScan = now; _bpTarget, _bpDist = AntiBypassGetClosest() end local target, targetDist = _bpTarget, _bpDist if not target then return end local myPos = root.Position; local targetPos = target.Position; local direction = targetPos - myPos; local flatDir = Vector3.new(direction.X, 0, direction.Z) if flatDir.Magnitude > 0 then
flatDir = flatDir.Unit else flatDir = Vector3.zero end local chaseSpeed = GetAntiBypassAimbotSpeed(); local desiredHeight = targetPos.Y + 3.7; local yVel = (desiredHeight - myPos.Y) * 19.5 if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end yVel = math.clamp(yVel, -70, 110); local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed); root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8); local toTarget = targetPos - myPos if toTarget.Magnitude > 0.1 then
local goalCF = CFrame.lookAt(myPos, targetPos); local diffCF = root.CFrame:Inverse() * goalCF; local rx, ry, rz = diffCF:ToEulerAnglesXYZ(); rx = math.clamp(rx, -2.5, 2.5); ry = math.clamp(ry, -2.5, 2.5); rz = math.clamp(rz, -2.5, 2.5); root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42)) end if targetDist <= 8 then AntiBypassTrySwing() end end) if VS and VS.setAntiBatBypassVisual then pcall(function() VS.setAntiBatBypassVisual(true) end) end end function F.stopAimbotBypassAntiBat()
antiBatBypassLockEnabled = false; S.antiBatBypassEnabled = false if AceAntiBypassAimbot.conn then pcall(function() AceAntiBypassAimbot.conn:Disconnect() end) AceAntiBypassAimbot.conn = nil end AceAntiBypassAimbot.swingCooldown = false; local c = LP.Character; local root = c and c:FindFirstChild("HumanoidRootPart") if root then pcall(function() root.AssemblyAngularVelocity = Vector3.zero end) end local hum = c and c:FindFirstChildOfClass("Humanoid") if hum then local prev = AceAntiBypassAimbot.prevAutoRotate; hum.AutoRotate = (prev == nil) and true or prev end
AceAntiBypassAimbot.prevAutoRotate = nil if VS and VS.setAntiBatBypassVisual then pcall(function() VS.setAntiBatBypassVisual(false) end) end end end local cursedInstaReset local K7 = { fovEnabled = false, fovValue = 80, lineESPEnabled = false, speedESPEnabled = false, animPackEnabled = false, animPackName = "Tryhard", animPackIndex = 1, headlessEnabled = false, korbloxEnabled = false, bodyLockEnabled = false, bodyLockRadius = 60, medusaResetEnabled = false, currentSkyTheme = "Off", skyThemeIndex = 1, } K7.headIndicator = nil K7.headSpeedConn = nil function K7.updateHeadIndicatorTheme()
local indicator = K7.headIndicator if not indicator then return end local accent = S.themeColor or Color3.fromRGB(100, 200, 255) if indicator.discord then indicator.discord.TextColor3 = accent end if indicator.speed then indicator.speed.TextColor3 = accent end if indicator.divider then indicator.divider.BackgroundColor3 = accent end end function K7.setupHeadIndicator(char) char = char or LP.Character; local head = char and (char:FindFirstChild("Head") or char:WaitForChild("Head", 5)) if not head then return end local old = head:FindFirstChild("LinxHeadIndicator")
if old then old:Destroy() end
local bb = Instance.new("BillboardGui"); bb.Name = "LinxHeadIndicator"; bb.Size = UDim2.new(0, 250, 0, 90); bb.StudsOffset = Vector3.new(0, 3.5, 0); bb.AlwaysOnTop = true; bb.MaxDistance = 600; bb.Adornee = head; bb.Parent = head; local accent = S.themeColor or Color3.fromRGB(100, 200, 255); local discordLbl = Instance.new("TextLabel"); discordLbl.Name = "Discord"; discordLbl.Size = UDim2.new(1, 0, 0.30, 0); discordLbl.Position = UDim2.new(0, 0, 0.30, 0); discordLbl.BackgroundTransparency = 1; discordLbl.Text = "https://discord.gg/2edSTrt8A"; discordLbl.TextColor3 = accent; discordLbl.Font = Enum.Font.GothamBold; discordLbl.TextScaled = true; discordLbl.TextStrokeTransparency = 0; discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); discordLbl.Parent = bb; local divider = Instance.new("Frame"); divider.Name = "Divider"; divider.Size = UDim2.new(0.72, 0, 0, 2); divider.Position = UDim2.new(0.14, 0, 0.635, 0); divider.BackgroundColor3 = accent; divider.BackgroundTransparency = 0.15; divider.BorderSizePixel = 0; divider.ZIndex = 2; divider.Parent = bb; local dividerCorner = Instance.new("UICorner"); dividerCorner.CornerRadius = UDim.new(1, 0); dividerCorner.Parent = divider; local speedLbl = Instance.new("TextLabel"); speedLbl.Name = "Speed"; speedLbl.Size = UDim2.new(1, 0, 0.30, 0); speedLbl.Position = UDim2.new(0, 0, 0.66, 0); speedLbl.BackgroundTransparency = 1; speedLbl.Text = "0.0"; speedLbl.TextColor3 = accent; speedLbl.Font = Enum.Font.GothamBold; speedLbl.TextScaled = true; speedLbl.TextStrokeTransparency = 0; speedLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); speedLbl.Parent = bb; K7.headIndicator = { bb = bb, discord = discordLbl, speed = speedLbl, divider = divider }; K7.updateHeadIndicatorTheme()
end function K7.startHeadSpeedUpdates() if K7.headSpeedConn then K7.headSpeedConn:Disconnect() end K7.headSpeedConn = RunService.Heartbeat:Connect(function() local indicator = K7.headIndicator if not indicator or not indicator.bb or not indicator.bb.Parent then return end local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local displaySpeed = 0 if S and (S.autoLeftEnabled or S.autoRightEnabled) then local ok, value = pcall(function() return (F and F.getAutoPathSpeed and F.getAutoPathSpeed()) or nil end) if ok and type(value) == "number" then
displaySpeed = value elseif F and F.getActiveMoveSpeed then local ok2, v2 = pcall(F.getActiveMoveSpeed) if ok2 and type(v2) == "number" then displaySpeed = v2 end end elseif F and F.getActiveMoveSpeed then local ok, value = pcall(F.getActiveMoveSpeed) if ok and type(value) == "number" then displaySpeed = value end elseif hrp then local velocity = hrp.AssemblyLinearVelocity; displaySpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude end indicator.speed.Text = string.format("%.1f", displaySpeed) end) end local function bindHeadIndicator(char) task.spawn(function() task.wait(0.25)
K7.setupHeadIndicator(char); K7.startHeadSpeedUpdates() end) end bindHeadIndicator(LP.Character); LP.CharacterAdded:Connect(bindHeadIndicator) do local skyThemeTag = "CursedSkyTheme"; local currentSkyTheme = "Off"; local SkyOrder = {"Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"} local SkyPresets = { ["Off"]={kind="off"},
["Night"]={clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140},sky={stars=4000,moon=18,sun=0,moonTex=true},atm={dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2}}, ["Aurora"]={clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150},atm={dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3},clouds={cover=0.7,dens=0.7,color={255,240,250}}},
["Sunset"]={clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110},sky={stars=0,sun=25,moon=0},atm={dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5},clouds={cover=0.55,dens=0.55,color={255,200,140}}}, ["Galaxy"]={clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110},sky={stars=10000,moon=30,sun=0},atm={dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5}},
["Cyber"]={clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180},sky={stars=2000,moon=12},atm={dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2},clouds={cover=0.4,dens=0.6,color={100,200,255}}}, ["Sakura"]={clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170},sky={sun=8},atm={dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5},clouds={cover=0.6,dens=0.4,color={255,250,252}}},
["Pink Night"]={clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120},sky={stars=5000,moon=22,sun=0,moonTex=true},atm={dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4}}, ["Blood Moon"]={clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50},sky={stars=1500,moon=28,sun=0,moonTex=true},atm={dens=0.6,color={220,30,30},decay={120,10,10},glare=1.4,haze=2}}, ["Emerald Dawn"]={clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150},sky={sun=18},atm={dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2}},
["Volcanic"]={clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50},sky={stars=200,sun=12},atm={dens=0.75,color={255,60,0},decay={180,20,0},glare=3,haze=3.5}}, ["Arctic"]={clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245},sky={sun=10},atm={dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8}}, ["Midnight Ocean"]={clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140},sky={stars=6000,moon=24,sun=0,moonTex=true},atm={dens=0.5,color={20,60,140},decay={10,30,90},glare=0.6,haze=1.5}},
["Vaporwave"]={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4}}, ["Toxic"]={clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90},atm={dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6}}, ["Solar Eclipse"]={clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70},sky={stars=3500,sun=22},atm={dens=0.5,color={255,140,40},decay={30,20,40},glare=2.8,haze=1.8}},
["Hellscape"]={clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40},sky={stars=100,sun=30},atm={dens=0.85,color={255,30,0},decay={120,0,0},glare=3.5,haze=4}}, ["Heaven"]={clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220},sky={sun=16},atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5}}, ["Storm"]={clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120},sky={sun=6},atm={dens=0.65,color={80,90,120},decay={40,50,80},glare=0.5,haze=3}},
["Sunrise"]={clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140},sky={sun=22},atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2}}, ["Deep Space"]={clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60},sky={stars=15000,moon=0,sun=0},atm={dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3}}, ["Lavender Dream"]={clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230},sky={stars=800,moon=16},atm={dens=0.4,color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8}},
["Inferno"]={clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50},sky={sun=26},atm={dens=0.6,color={255,90,20},decay={200,40,0},glare=3,haze=3.2}}, ["Mint Sky"]={clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220},sky={sun=10},atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6}}, } local function skyRGB(t) return Color3.fromRGB(t[1],t[2],t[3]) end local function applySkyTheme(mode) currentSkyTheme = mode or "Off"; K7.currentSkyTheme = currentSkyTheme for _,child in ipairs(Lighting:GetChildren()) do
if child:GetAttribute(skyThemeTag) then pcall(function() child:Destroy() end) end end local terrain = workspace:FindFirstChildOfClass("Terrain") if terrain then for _,child in ipairs(terrain:GetChildren()) do if child:GetAttribute(skyThemeTag) then pcall(function() child:Destroy() end) end end end local preset = SkyPresets[mode] if not preset or preset.kind == "off" then Lighting.ClockTime = 14; Lighting.Brightness = 2; Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127); Lighting.Ambient = Color3.fromRGB(127,127,127); Lighting.FogEnd = 100000; Lighting.GlobalShadows = true return end
Lighting.FogStart = 0; Lighting.FogEnd = 100000; Lighting.GlobalShadows = true; Lighting.ClockTime = preset.clock or 14; Lighting.Brightness = preset.brightness or 2 if preset.outAmb then Lighting.OutdoorAmbient = skyRGB(preset.outAmb) end if preset.ambient then Lighting.Ambient = skyRGB(preset.ambient) end if preset.sky then local skyInst = Instance.new("Sky"); skyInst:SetAttribute(skyThemeTag, true) if preset.sky.stars then skyInst.StarCount = preset.sky.stars end if preset.sky.moon then skyInst.MoonAngularSize = preset.sky.moon end
if preset.sky.sun then skyInst.SunAngularSize = preset.sky.sun end if preset.sky.moonTex then skyInst.MoonTextureId = "rbxasset://sky/moon.jpg" end skyInst.Parent = Lighting end if preset.atm then local atm = Instance.new("Atmosphere"); atm:SetAttribute(skyThemeTag, true); atm.Density = preset.atm.dens or 0.3; atm.Color = skyRGB(preset.atm.color); atm.Decay = skyRGB(preset.atm.decay); atm.Glare = preset.atm.glare or 1; atm.Haze = preset.atm.haze or 1; atm.Parent = Lighting end if preset.clouds and terrain then
local clouds = Instance.new("Clouds"); clouds:SetAttribute(skyThemeTag, true); clouds.Cover = preset.clouds.cover or 0.5; clouds.Density = preset.clouds.dens or 0.5; clouds.Color = skyRGB(preset.clouds.color); clouds.Parent = terrain end end local skyThemeIndex = 1 local function cycleSkyTheme(dir) skyThemeIndex = skyThemeIndex + (dir or 1) if skyThemeIndex < 1 then skyThemeIndex = #SkyOrder end if skyThemeIndex > #SkyOrder then skyThemeIndex = 1 end applySkyTheme(SkyOrder[skyThemeIndex]); K7.skyThemeIndex = skyThemeIndex return SkyOrder[skyThemeIndex] end
_G._VezyFOV = _G._VezyFOV or 70; local fovEnabled = false; local fovValue = 70; local fovConn = nil; local stretchRezEnabled = false; local stretchRezConn, stretchFovConn = nil, nil; local stretchFOV = 120; _G.State = _G.State or {}; State = _G.State; State.stretchedResEnabled = false; State.stretchFOV = 120 local function applyStretchFOV(val) local cam = workspace.CurrentCamera if cam then pcall(function() cam.FieldOfView = val end) end end local function enableStretchRez() S.stretchRezEnabled = true; State.stretchedResEnabled = true; local cam = workspace.CurrentCamera
if not cam then return end if S.stretchRezConn then S.stretchRezConn:Disconnect() end if stretchFovConn then stretchFovConn:Disconnect() end stretchFovConn = RunService.Heartbeat:Connect(function() if not S.stretchRezEnabled then return end if not _perfEveryN(4, 2) then return end applyStretchFOV(State.stretchFOV or stretchFOV) end) S.stretchRezConn = RunService.Heartbeat:Connect(function() if not S.stretchRezEnabled then if S.stretchRezConn then S.stretchRezConn:Disconnect(); S.stretchRezConn = nil end return end if _IS_MOBILE and not _perfEveryN(2, 1) then return end if cam then
cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.7, 0, 0, 0, 1) end end) end local function disableStretchRez() S.stretchRezEnabled = false; State.stretchedResEnabled = false if S.stretchRezConn then S.stretchRezConn:Disconnect(); S.stretchRezConn = nil end if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn = nil end pcall(function() if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = _G._VezyFOV or 70 end end) end local function applyFOV() pcall(function() RunService:UnbindFromRenderStep("CursedFOV") end)
if fovConn then fovConn:Disconnect(); fovConn = nil end if not K7.fovEnabled then local target = _G._VezyFOV or 70 if workspace.CurrentCamera and not State.stretchedResEnabled then workspace.CurrentCamera.FieldOfView = target end return end local cam = workspace.CurrentCamera; local target = K7.fovValue or _G._VezyFOV or 70; _G._VezyFOV = target if cam and not State.stretchedResEnabled then cam.FieldOfView = target end pcall(function() RunService:BindToRenderStep("CursedFOV", Enum.RenderPriority.Camera.Value + 1, function() if not K7.fovEnabled then return end
if State.stretchedResEnabled then return end local c = workspace.CurrentCamera if c then c.FieldOfView = K7.fovValue or _G._VezyFOV or 70 end end) end) fovConn = RunService.Heartbeat:Connect(function() if not _perfEveryN(3, 1) then return end if not K7.fovEnabled then return end if State.stretchedResEnabled then return end local c = workspace.CurrentCamera if c then c.FieldOfView = K7.fovValue or _G._VezyFOV or 70 end end) end do local _VezyFOVPropConn = nil local function _attachFOVLock(cam) if not cam then return end
if _VezyFOVPropConn then pcall(function() _VezyFOVPropConn:Disconnect() end) end pcall(function() if not State.stretchedResEnabled then cam.FieldOfView = _G._VezyFOV or 70 end end) _VezyFOVPropConn = cam:GetPropertyChangedSignal("FieldOfView"):Connect(function() local target = _G._VezyFOV or 70 if not State.stretchedResEnabled and cam.FieldOfView ~= target then pcall(function() cam.FieldOfView = target end) end end) end pcall(function() if workspace.CurrentCamera then _attachFOVLock(workspace.CurrentCamera) end workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() task.wait()
pcall(function() _attachFOVLock(workspace.CurrentCamera) end) end) if LP then LP.CharacterAdded:Connect(function() task.wait(0.3) pcall(function() _attachFOVLock(workspace.CurrentCamera) end) end) end end) end local headlessEnabled, korbloxEnabled = false, false; local HEADLESS_MESH_ID = "rbxassetid://1095708" local function applyHeadless(char, enabled) if not char then return end local head = char:FindFirstChild("Head") if not head then return end if enabled then head.Transparency = 1; head.CanCollide = false; local face = head:FindFirstChild("face") if face then face:Destroy() end
for _, c in ipairs(head:GetChildren()) do if c:IsA("SpecialMesh") and c.Name == "HeadlessMesh" then c:Destroy() end end local mesh = Instance.new("SpecialMesh"); mesh.MeshType = Enum.MeshType.FileMesh; mesh.MeshId = HEADLESS_MESH_ID; mesh.Scale = Vector3.new(0.001, 0.001, 0.001); mesh.Name = "HeadlessMesh"; mesh.Parent = head else head.Transparency = 0; head.CanCollide = true for _, c in ipairs(head:GetChildren()) do if c:IsA("SpecialMesh") and c.Name == "HeadlessMesh" then c:Destroy() end end end end local KORBLOX_ASSETS = { ["Left Leg"] = { id = "rbxassetid://139607673",
targetBodyPart = "LeftUpperLeg", partsToHide = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg"}, scale = Vector3.new(1, 1, 1), offset = CFrame.new(), }, ["Right Leg"] = { id = "rbxassetid://139607718", targetBodyPart = "RightUpperLeg", partsToHide = {"RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg"}, scale = Vector3.new(1, 1, 1), offset = CFrame.new(), }, } local korbloxSide = 1 local function clearKorbloxAttachments(char) if not char then return end for _, name in ipairs({"Korblox_LeftLeg", "Korblox_RightLeg", "Korblox_Left Leg", "Korblox_Right Leg"}) do
local old = char:FindFirstChild(name) if old then pcall(function() old:Destroy() end) end end for _, child in ipairs(char:GetChildren()) do if child.Name:find("^Korblox_") then pcall(function() child:Destroy() end) end end for _, partName in ipairs({ "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg", }) do local limb = char:FindFirstChild(partName) if limb and limb:IsA("BasePart") then limb.Transparency = 0 end end end local function attachKorbloxMesh(char, itemName, config) if not char then return false, "No character" end
local targetPart = char:FindFirstChild(config.targetBodyPart) if not targetPart then if itemName == "Left Leg" then targetPart = char:FindFirstChild("Left Leg") elseif itemName == "Right Leg" then targetPart = char:FindFirstChild("Right Leg") end end if not targetPart then return false, "Target part missing" end local safeName = "Korblox_" .. itemName:gsub("%s+", ""); local oldAsset = char:FindFirstChild(safeName) if oldAsset then pcall(function() oldAsset:Destroy() end) end for _, partName in ipairs(config.partsToHide) do local limb = char:FindFirstChild(partName)
if limb and limb:IsA("BasePart") then limb.Transparency = 1 end end local success, objects = pcall(function() return game:GetObjects(config.id) end) if not success or not objects or #objects == 0 then return false, "Asset fetch failed" end local assetModel = objects[1]; assetModel.Name = safeName; local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true) if not mainMesh then return false, "No MeshPart in asset" end pcall(function() mainMesh.Size = mainMesh.Size * (config.scale or Vector3.new(1,1,1))
mainMesh.CanCollide = false; mainMesh.Anchored = false; mainMesh.CFrame = targetPart.CFrame * (config.offset or CFrame.new()) end) local weld = Instance.new("WeldConstraint") weld.Part0 = targetPart; weld.Part1 = mainMesh; weld.Parent = mainMesh; assetModel.Parent = char return true end local function applyKorblox(char, enabled) if not char then return end clearKorbloxAttachments(char) if not enabled then return end local sides = {}; local side = korbloxSide or 1 if side == 2 then sides = {"Left Leg"} elseif side == 3 then sides = {"Left Leg", "Right Leg"} else sides = {"Right Leg"} end
for _, itemName in ipairs(sides) do local config = KORBLOX_ASSETS[itemName] if config then local ok, err = attachKorbloxMesh(char, itemName, config) if not ok then warn("[Vyxro Duel] Korblox equip failed (" .. itemName .. "): " .. tostring(err)) end end end end local bodyLockEnabled = false; local bodyLockRadius = 60; local bodyLockConn = nil local function getNearestBodyLockTarget() local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not root then return nil end local nearest, shortest = nil, math.huge for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP and plr.Character then local tr = plr.Character:FindFirstChild("HumanoidRootPart"); local hum = plr.Character:FindFirstChildOfClass("Humanoid") if tr and hum and hum.Health > 0 then local d = (tr.Position - root.Position).Magnitude if d <= (K7.bodyLockRadius or bodyLockRadius or 60) and d < shortest then shortest = d; nearest = plr end end end end return nearest end local function isNearBrainrot(root, radius) if not root then return false end radius = radius or 5 local ok, parts = pcall(function() return workspace:GetPartBoundsInRadius(root.Position, radius) end)
if not ok or not parts then return false end for _, p in ipairs(parts) do if p and p:IsA("BasePart") then local model = p:FindFirstAncestorOfClass("Model") if model and model ~= LP.Character then if not Players:GetPlayerFromCharacter(model) then local n = string.lower(model.Name) if n:find("brainrot", 1, true) or n:find("animal", 1, true) or n:find("steal", 1, true) then return true end local par = model.Parent if par then local pn = string.lower(par.Name) if pn:find("brainrot", 1, true) or pn:find("animals", 1, true) then return true end end end end end end return false end
local function startBodyLock() if bodyLockConn then K7.bodyLockEnabled = true; bodyLockEnabled = true; S._bodyLockWanted = true return end K7.bodyLockEnabled = true; bodyLockEnabled = true; S._bodyLockWanted = true; S._bodyLockPausedByBrainrot = false; local _blCachedTarget = nil; local _blLastScan = 0; local _blLastBrain = 0; local _blNearBrain = false bodyLockConn = RunService.Heartbeat:Connect(function() if not K7.bodyLockEnabled then return end if aimbotEnabled or tpBatEnabled or antiBatBypassLockEnabled then return end
local char = LP.Character; local myRoot = char and char:FindFirstChild("HumanoidRootPart"); local humanoid = char and char:FindFirstChildOfClass("Humanoid") if not myRoot or not humanoid or humanoid.Health <= 0 then return end local now = os.clock(); local brainInterval = _IS_MOBILE and 0.18 or 0.08 if (now - _blLastBrain) >= brainInterval then _blLastBrain = now; local holding, near = false, false pcall(function() holding = F.isCarryingBrainrot and F.isCarryingBrainrot(char) == true end) pcall(function() near = isNearBrainrot and isNearBrainrot(myRoot, 5) == true end)
_blNearBrain = holding or near end if _blNearBrain then S._bodyLockPausedByBrainrot = true; humanoid.AutoRotate = true return end local scanInterval = _IS_MOBILE and 0.12 or 0.05 if (now - _blLastScan) >= scanInterval then _blLastScan = now; _blCachedTarget = getNearestBodyLockTarget() end local target = _blCachedTarget if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then local targetPos = target.Character.HumanoidRootPart.Position; local myPos = myRoot.Position; local offset = Vector3.new(targetPos.X, myPos.Y, targetPos.Z) - myPos
if offset.Magnitude > 0.1 then humanoid.AutoRotate = false; local lookDir = offset.Unit local currentDir = myRoot.CFrame.LookVector local cross = currentDir:Cross(lookDir); local currentVel = myRoot.AssemblyAngularVelocity; myRoot.AssemblyAngularVelocity = Vector3.new(currentVel.X, cross.Y * 40, currentVel.Z) end else humanoid.AutoRotate = true end end) end local function stopBodyLock(fromUser) K7.bodyLockEnabled = false; bodyLockEnabled = false if bodyLockConn then bodyLockConn:Disconnect(); bodyLockConn = nil end local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.AutoRotate = true end if fromUser == true then S._bodyLockWanted = false; S._bodyLockPausedByBrainrot = false end end if not S._bodyLockBrainrotWatcher then S._bodyLockBrainrotWatcher = true RunService.Heartbeat:Connect(function() if not S._bodyLockWanted then return end if S._bodyLockPausedByCombat then return end if aimbotEnabled or tpBatEnabled then return end local char = LP.Character if not char then return end local root = char:FindFirstChild("HumanoidRootPart") if not root then return end local holding, near = false, false
pcall(function() holding = F.isCarryingBrainrot and F.isCarryingBrainrot(char) == true end) pcall(function() near = isNearBrainrot and isNearBrainrot(root, 5) == true end) if holding or near then S._bodyLockPausedByBrainrot = true return end if S._bodyLockPausedByBrainrot or not bodyLockConn then S._bodyLockPausedByBrainrot = false if not bodyLockConn then pcall(startBodyLock) else K7.bodyLockEnabled = true; bodyLockEnabled = true end if VS and VS.setBodyLockVisual then pcall(function() VS.setBodyLockVisual(true) end) end end end) end
local medusaResetEnabled = false; local medusaResetConns = {}; local medusaResetDebounce = false local function onPartAnchoredForReset(part) return part:GetPropertyChangedSignal("Anchored"):Connect(function() if part.Anchored and part.Transparency == 1 and part.Name ~= "HumanoidRootPart" then if medusaResetDebounce or not K7.medusaResetEnabled then return end medusaResetDebounce = true task.spawn(function() if cursedInstaReset then cursedInstaReset() end task.wait(1.5); medusaResetDebounce = false end) end end) end local function startMedusaReset()
for _, c in pairs(medusaResetConns) do pcall(function() c:Disconnect() end) end medusaResetConns = {}; local char = LP.Character if not char then return end for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(medusaResetConns, onPartAnchoredForReset(part)) end end table.insert(medusaResetConns, char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(medusaResetConns, onPartAnchoredForReset(part)) end end)) end local function stopMedusaReset() for _, c in pairs(medusaResetConns) do pcall(function() c:Disconnect() end) end
medusaResetConns = {}; medusaResetDebounce = false end local lineESPEnabled = false; local speedESPEnabled = false; local PlayerESP = { enabled = false, conns = {}, playerData = {} }; local TracerESP = { drawings = {}, conn = nil, gui = nil } local function startPlayerESP() if PlayerESP.enabled then return end PlayerESP.enabled = true local function cleanup(plr) local d = PlayerESP.playerData[plr] if not d then return end pcall(function() if d.highlight then d.highlight:Destroy() end end) pcall(function() if d.billboard then d.billboard:Destroy() end end)
for _, c in ipairs(d.conns or {}) do pcall(function() c:Disconnect() end) end PlayerESP.playerData[plr] = nil end local function setupPlayer(plr, char) if not PlayerESP.enabled or plr == LP then return end cleanup(plr); char = char or plr.Character if not char then return end local hrp = char:FindFirstChild("HumanoidRootPart"); local head = char:FindFirstChild("Head") or hrp if not hrp then return end
local hl = Instance.new("Highlight"); hl.Name = "SevenUpPlayerESP"; hl.Adornee = char; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; local acc = (S and S.themeColor) or (COLORS and COLORS.accent) or Color3.fromRGB(230, 230, 235); hl.FillColor = acc; hl.FillTransparency = 0.72; hl.OutlineColor = acc; hl.OutlineTransparency = 0.08; hl.Parent = char; local bb = Instance.new("BillboardGui"); bb.Name = "SevenUpPlayerESP_BB"; bb.Adornee = head; bb.Size = UDim2.new(0, 120, 0, 28); bb.StudsOffset = Vector3.new(0, 2.8, 0); bb.AlwaysOnTop = true; bb.MaxDistance = 600; local lbl = Instance.new("TextLabel", bb); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Text = plr.DisplayName or plr.Name; lbl.TextColor3 = (S and S.themeColor) or (COLORS and COLORS.accent) or Color3.fromRGB(230, 230, 235); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.TextStrokeTransparency = 0.3
pcall(function() bb.Parent = game:GetService("CoreGui") end) if not bb.Parent then pcall(function() bb.Parent = LP:FindFirstChild("PlayerGui") end) end local lastEspUp = 0 local conn = RunService.Heartbeat:Connect(function() if not PlayerESP.enabled or not hrp.Parent then return end local now = os.clock(); local interval = _IS_MOBILE and 0.22 or 0.08 if (now - lastEspUp) < interval then return end lastEspUp = now; local v = hrp.AssemblyLinearVelocity; local spd = Vector3.new(v.X, 0, v.Z).Magnitude; lbl.Text = string.format("%s\n%.0f sps", plr.DisplayName or plr.Name, spd) end)
PlayerESP.playerData[plr] = { highlight = hl, billboard = bb, conns = { conn } } end for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP then table.insert(PlayerESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(setupPlayer, plr, c) end)) if plr.Character then task.defer(setupPlayer, plr, plr.Character) end end end table.insert(PlayerESP.conns, Players.PlayerAdded:Connect(function(plr) table.insert(PlayerESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(setupPlayer, plr, c) end)) end)) table.insert(PlayerESP.conns, Players.PlayerRemoving:Connect(cleanup)) end
local function stopPlayerESP() PlayerESP.enabled = false for _, c in ipairs(PlayerESP.conns or {}) do pcall(function() c:Disconnect() end) end PlayerESP.conns = {} for plr, d in pairs(PlayerESP.playerData) do pcall(function() if d.highlight then d.highlight:Destroy() end end) pcall(function() if d.billboard then d.billboard:Destroy() end end) for _, c in ipairs(d.conns or {}) do pcall(function() c:Disconnect() end) end end PlayerESP.playerData = {} end local function ensureTracerGui() if TracerESP.gui and TracerESP.gui.Parent then return TracerESP.gui end
local g = Instance.new("ScreenGui"); g.Name = "VyxroDuelTracerESP"; g.IgnoreGuiInset = true; g.DisplayOrder = 50; g.ResetOnSpawn = false pcall(function() g.Parent = game:GetService("CoreGui") end) if not g.Parent then pcall(function() g.Parent = LP:FindFirstChild("PlayerGui") end) end TracerESP.gui = g return g end local function tracerCleanup(plr) local d = TracerESP.drawings[plr] if d then pcall(function() if d.line then d.line:Destroy() end end) TracerESP.drawings[plr] = nil end end local function startTracerESP() if TracerESP.conn then pcall(function() TracerESP.conn:Disconnect() end)
TracerESP.conn = nil end for plr in pairs(TracerESP.drawings) do tracerCleanup(plr) end ensureTracerGui(); S.showTracerEnabled = true TracerESP.conn = RunService.Heartbeat:Connect(function() if not S.showTracerEnabled and not (K7 and K7.lineESPEnabled) then for plr in pairs(TracerESP.drawings) do tracerCleanup(plr) end return end if not _perfEveryN(3, 1) then return end if not TracerESP.gui or not TracerESP.gui.Parent then return end local myChar = LP.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart") if not myRoot then return end local cam = workspace.CurrentCamera
if not cam then return end local seen = {} for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then local tr = plr.Character:FindFirstChild("HumanoidRootPart") if tr then seen[plr] = true; local sp, son = cam:WorldToViewportPoint(myRoot.Position); local ep, eon = cam:WorldToViewportPoint(tr.Position) if son and eon then local line = TracerESP.drawings[plr] and TracerESP.drawings[plr].line if not line then
line = Instance.new("Frame"); line.Name = "Tracer_" .. plr.Name; line.AnchorPoint = Vector2.new(0.5, 0.5); line.BorderSizePixel = 0; line.BackgroundColor3 = (S and S.themeColor) or (COLORS and COLORS.accent) or Color3.fromRGB(230, 230, 235); line.BackgroundTransparency = 0.15; line.Parent = TracerESP.gui; TracerESP.drawings[plr] = { line = line } end
local dx, dy = ep.X - sp.X, ep.Y - sp.Y; local len = math.sqrt(dx * dx + dy * dy); line.Size = UDim2.fromOffset(math.max(1, len), 2); line.Position = UDim2.fromOffset((sp.X + ep.X) / 2, (sp.Y + ep.Y) / 2); line.Rotation = math.deg(math.atan2(dy, dx)); line.Visible = true else tracerCleanup(plr) end end end end for plr in pairs(TracerESP.drawings) do if not seen[plr] then tracerCleanup(plr) end end end) end local function stopTracerESP() S.showTracerEnabled = false if TracerESP.conn then TracerESP.conn:Disconnect(); TracerESP.conn = nil end
for plr in pairs(TracerESP.drawings) do tracerCleanup(plr) end if TracerESP.gui then pcall(function() TracerESP.gui:Destroy() end); TracerESP.gui = nil end end local function refreshESP() stopPlayerESP(); stopTracerESP() if not K7 then return end if K7.lineESPEnabled or K7.speedESPEnabled then startPlayerESP(); startTracerESP() end end if K7 then K7.refreshESP = refreshESP end local animPackEnabled = false; local animPackName = "Tryhard"; local savedAnimateClone = nil; local applyingAnim = false local ANIM_PACKS = { ["Tryhard"] = {
Animation1 = 133806214992291, Animation2 = 94970088341563, WalkAnim = 707897309, RunAnim = 707861613, JumpAnim = 116936326516985, FallAnim = 116936326516985, ClimbAnim = 116936326516985, Swim = 116936326516985, SwimIdle = 116936326516985, }, ["Crazy"] = { Animation1 = 133806214992291, Animation2 = 94970088341563, WalkAnim = 134824450619865, RunAnim = 134824450619865, JumpAnim = 121454505477205, FallAnim = 94788218468396, ClimbAnim = 121454505477205, Swim = 121454505477205, SwimIdle = 121454505477205, }, ["Adidas Sports"] = {
Animation1 = 18537376492, Animation2 = 18537371272, WalkAnim = 18537392113, RunAnim = 18537384940, JumpAnim = 18537380791, FallAnim = 18537367238, ClimbAnim = 18537363391, Swim = 18537389531, SwimIdle = 18537387180, }, ["Adidas Community"] = { Animation1 = 122257458498464, Animation2 = 102357151005774, WalkAnim = 122150855457006, RunAnim = 82598234841035, JumpAnim = 75290611992385, FallAnim = 98600215928904, ClimbAnim = 88763136693023, Swim = 133308483266208, SwimIdle = 109346520324160, }, ["Adidas Aura"] = {
Animation1 = 110211186840347, Animation2 = 114191137265065, WalkAnim = 83842218823011, RunAnim = 118320322718866, JumpAnim = 109996626521204, FallAnim = 95603166884636, ClimbAnim = 97824616490448, Swim = 134530128383903, SwimIdle = 94922130551805, }, ["Wicked Popular"] = { Animation1 = 118832222982049, Animation2 = 76049494037641, WalkAnim = 92072849924640, RunAnim = 72301599441680, JumpAnim = 104325245285198, FallAnim = 121152442762481, ClimbAnim = 131326830509784, Swim = 99384245425157, SwimIdle = 113199415118199, }, ["Elder"] = {
Animation1 = 10921101664, Animation2 = 10921102574, WalkAnim = 10921111375, RunAnim = 10921104374, JumpAnim = 10921107367, FallAnim = 10921105765, ClimbAnim = 10921100400, Swim = 10921108971, SwimIdle = 10921110137, }, ["Zombie"] = { Animation1 = 10921344533, Animation2 = 10921345376, WalkAnim = 10921355261, RunAnim = 616163682, JumpAnim = 10921351278, FallAnim = 10921350320, ClimbAnim = 10921343576, Swim = 10921352344, SwimIdle = 10921353442, }, ["Mage"] = {
Animation1 = 10921144709, Animation2 = 10921145797, WalkAnim = 10921152678, RunAnim = 10921148209, JumpAnim = 10921149743, FallAnim = 10921148939, ClimbAnim = 10921143404, Swim = 10921150788, SwimIdle = 10921151661, }, ["Catwalk Glam"] = { Animation1 = 133806214992291, Animation2 = 94970088341563, WalkAnim = 109168724482748, RunAnim = 81024476153754, JumpAnim = 116936326516985, FallAnim = 92294537340807, ClimbAnim = 119377220967554, Swim = 134591743181628, SwimIdle = 98854111361360, }, ["Astronaut"] = {
Animation1 = 10921034824, Animation2 = 10921036806, WalkAnim = 10921046031, RunAnim = 10921039308, JumpAnim = 10921042494, FallAnim = 10921040576, ClimbAnim = 10921032124, Swim = 10921044000, SwimIdle = 10921045006, }, ["Werewolf"] = { Animation1 = 10921330408, Animation2 = 10921333667, WalkAnim = 10921342074, RunAnim = 10921336997, JumpAnim = 10921337907, FallAnim = 10921337907, ClimbAnim = 10921329322, Swim = 10921340419, SwimIdle = 10921341319, }, ["Superhero"] = {
Animation1 = 10921288909, Animation2 = 10921290167, WalkAnim = 10921298616, RunAnim = 10921291831, JumpAnim = 10921294559, FallAnim = 10921293373, ClimbAnim = 10921286911, Swim = 10921295495, SwimIdle = 10921297391, }, ["Toy"] = { Animation1 = 10921301576, Animation2 = 10921301576, WalkAnim = 10921312010, RunAnim = 10921306285, JumpAnim = 10921308158, FallAnim = 10921307241, ClimbAnim = 10921300839, Swim = 10921309319, SwimIdle = 10921310341, }, ["No Boundaries"] = {
Animation1 = 18747067405, Animation2 = 18747063918, WalkAnim = 18747074203, RunAnim = 18747070484, JumpAnim = 18747069148, FallAnim = 18747062535, ClimbAnim = 18747060903, Swim = 18747073181, SwimIdle = 18747071682, }, ["NFL"] = { Animation1 = 92080889861410, Animation2 = 74451233229259, WalkAnim = 110358958299415, RunAnim = 117333533048078, JumpAnim = 119846112151352, FallAnim = 129773241321032, ClimbAnim = 134630013742019, Swim = 132697394189921, SwimIdle = 79090109939093, }, ["Vampire"] = {
Animation1 = 10921315373, Animation2 = 10921315373, WalkAnim = 10921326949, RunAnim = 10921320299, JumpAnim = 10921322186, FallAnim = 10921321317, ClimbAnim = 10921314188, Swim = 10921324408, SwimIdle = 10921325443, }, ["Ninja"] = { Animation1 = 656117400, Animation2 = 656118341, WalkAnim = 656121766, RunAnim = 656118852, JumpAnim = 656117878, FallAnim = 656115606, ClimbAnim = 656114359, Swim = 656119721, SwimIdle = 656121397, }, ["Robot"] = {
Animation1 = 616088211, Animation2 = 616089559, WalkAnim = 616095330, RunAnim = 616091570, JumpAnim = 616090535, FallAnim = 616087089, ClimbAnim = 616086039, Swim = 616092998, SwimIdle = 616094091, }, ["Levitation"] = { Animation1 = 616006778, Animation2 = 616008087, WalkAnim = 616013216, RunAnim = 616010382, JumpAnim = 616008936, FallAnim = 616005863, ClimbAnim = 616003713, Swim = 616011509, SwimIdle = 616012453, }, ["Stylish"] = {
Animation1 = 616136790, Animation2 = 616138447, WalkAnim = 616146177, RunAnim = 616140816, JumpAnim = 616139451, FallAnim = 616134815, ClimbAnim = 616133594, Swim = 616143378, SwimIdle = 616144772, }, ["Bubbly"] = { Animation1 = 910004836, Animation2 = 910009958, WalkAnim = 910034870, RunAnim = 910025107, JumpAnim = 910016857, FallAnim = 910001910, ClimbAnim = 909997997, Swim = 910028158, SwimIdle = 910030921, }, ["Cartoon"] = {
Animation1 = 742637544, Animation2 = 742638445, WalkAnim = 742640026, RunAnim = 742638842, JumpAnim = 742637942, FallAnim = 742637151, ClimbAnim = 742636889, Swim = 742639220, SwimIdle = 742639812, }, ["Wicked Dancing"] = { Animation1 = 92849173543269, Animation2 = 132238900951109, WalkAnim = 73718308412641, RunAnim = 135515454877967, JumpAnim = 78508480717326, FallAnim = 78147885297412, ClimbAnim = 129447497744818, Swim = 110657013921774, SwimIdle = 129183123083281, }, ["Normal"] = {
Animation1 = 507766388, Animation2 = 507766666, WalkAnim = 507777826, RunAnim = 507767714, JumpAnim = 507765000, FallAnim = 507767968, ClimbAnim = 507765644, Swim = 507784897, SwimIdle = 507784897, }, } local ANIM_PACK_LIST = {"Tryhard","Crazy","Adidas Sports","Adidas Community","Adidas Aura","Wicked Popular","Elder","Zombie","Mage","Catwalk Glam","Astronaut","Werewolf","Superhero","Toy","No Boundaries","NFL","Vampire","Ninja","Robot","Levitation","Stylish","Bubbly","Cartoon","Wicked Dancing","Normal"} local animPackIndex = 1 local function setAnimId(obj, id)
if not obj or not id then return end local idStr = type(id) == "number" and ("rbxassetid://" .. tostring(id)) or tostring(id) if not idStr:find("rbxassetid://") and tonumber(idStr) then idStr = "rbxassetid://" .. idStr end pcall(function() if obj:IsA("Animation") then obj.AnimationId = idStr elseif obj:IsA("StringValue") then obj.Value = idStr end end) end local function applyAnimPack(name) if not K7.animPackEnabled then return end if applyingAnim then return end name = name or K7.animPackName if not name or name == "" then applyingAnim = false; return end
K7.animPackName = name; applyingAnim = true; local pack = ANIM_PACKS[name] if not pack then applyingAnim = false; return end local char = LP.Character if not char then applyingAnim = false; return end local animate = char:FindFirstChild("Animate") if not animate then applyingAnim = false; return end if not savedAnimateClone then pcall(function() savedAnimateClone = animate:Clone() end) end local hum = char:FindFirstChildOfClass("Humanoid") if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end end local function ensure(folder, animName)
if not folder then return nil end local a = folder:FindFirstChild(animName) if not a then a = Instance.new("Animation"); a.Name = animName; a.Parent = folder end return a end local function setFolderAnim(folderName, animName, id) if not id then return end local folder = animate:FindFirstChild(folderName) if not folder then folder = Instance.new("Folder"); folder.Name = folderName; folder.Parent = animate end setAnimId(ensure(folder, animName), id) for _, ch in ipairs(folder:GetChildren()) do if ch:IsA("Animation") or ch:IsA("StringValue") then setAnimId(ch, id) end end end
setFolderAnim("walk", "WalkAnim", pack.WalkAnim); setFolderAnim("run", "RunAnim", pack.RunAnim); setFolderAnim("jump", "JumpAnim", pack.JumpAnim); setFolderAnim("fall", "FallAnim", pack.FallAnim); setFolderAnim("climb", "ClimbAnim", pack.ClimbAnim); setFolderAnim("swim", "Swim", pack.Swim); setFolderAnim("swimidle", "SwimIdle", pack.SwimIdle); local idle = animate:FindFirstChild("idle") if not idle then idle = Instance.new("Folder"); idle.Name = "idle"; idle.Parent = animate end if idle then
setAnimId(ensure(idle, "Animation1"), pack.Animation1); setAnimId(ensure(idle, "Animation2"), pack.Animation2 or pack.Animation1) for _, ch in ipairs(idle:GetChildren()) do if ch:IsA("Animation") or ch:IsA("StringValue") then if ch.Name:find("1") then setAnimId(ch, pack.Animation1) elseif ch.Name:find("2") then setAnimId(ch, pack.Animation2 or pack.Animation1) end end end end animate.Disabled = true; task.wait(0.05); animate.Disabled = false; animPackName = name; K7.animPackName = name; applyingAnim = false; print("[Vyxro Duel] Anim pack applied:", name) end local function resetAnimPack()
local char = LP.Character if not char then return end local animate = char:FindFirstChild("Animate") if animate then animate:Destroy() end if savedAnimateClone then local n = savedAnimateClone:Clone(); n.Parent = char; n.Disabled = true; task.wait(0.05); n.Disabled = false end end K7.applySkyTheme = applySkyTheme; K7.cycleSkyTheme = cycleSkyTheme; K7.applyFOV = applyFOV; K7.enableStretchRez = enableStretchRez; K7.disableStretchRez = disableStretchRez; K7.applyHeadless = applyHeadless; K7.applyKorblox = applyKorblox; K7.korbloxSide = korbloxSide
K7.setKorbloxSide = function(n) korbloxSide = n; K7.korbloxSide = n end K7.startBodyLock = startBodyLock; K7.stopBodyLock = stopBodyLock; K7.startMedusaReset = startMedusaReset; K7.stopMedusaReset = stopMedusaReset; K7.refreshESP = refreshESP; K7.applyAnimPack = applyAnimPack; K7.resetAnimPack = resetAnimPack; K7.ANIM_PACK_LIST = ANIM_PACK_LIST if K7.currentSkyTheme == nil then K7.currentSkyTheme = currentSkyTheme end if K7.skyThemeIndex == nil then K7.skyThemeIndex = skyThemeIndex end if K7.fovValue == nil then K7.fovValue = fovValue end
-- ===== [Vyxro Duel] Accessory Pack (3 skins personalizadas) =====
do
local ACCESSORY_PACK_LIST = {"Off"}
local BLEED_PACKS = {
    -- === Custom Outfits ===
}
local ORIG = { shirt = nil, pants = nil, accessories = {} }

local function saveOriginalOutfit(char)
    if not char then return end
    local shirt = char:FindFirstChildWhichIsA("Shirt")
    local pants = char:FindFirstChildWhichIsA("Pants")
    ORIG.shirt = shirt and shirt.ShirtTemplate or nil
    ORIG.pants = pants and pants.PantsTemplate or nil
end

local function clearAllOutfit(char)
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then pcall(function() obj:Destroy() end) end
    end
end

local function restoreOriginalOutfit(char)
    if not char then return end
    clearAllOutfit(char)
    if ORIG.shirt then local s = Instance.new("Shirt"); s.ShirtTemplate = ORIG.shirt; s.Parent = char end
    if ORIG.pants then local p = Instance.new("Pants"); p.PantsTemplate = ORIG.pants; p.Parent = char end
    ORIG.shirt = nil; ORIG.pants = nil
end

local function saveOriginalAccessories(char)
    ORIG.accessories = {}
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") then
            pcall(function() table.insert(ORIG.accessories, child:Clone()) end)
        end
    end
end

local function clearAllAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        pcall(function()
            if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then child:Destroy()
            elseif child.Name:find("Korblox_") or child.Name:find("Headless_") then child:Destroy() end
        end)
    end
    for _, partName in ipairs({"Head", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then part.Transparency = 0 end
    end
end

local function restoreOriginalAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        pcall(function()
            if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then child:Destroy() end
        end)
    end
    for _, clone in ipairs(ORIG.accessories) do
        pcall(function()
            local newAcc = clone:Clone()
            newAcc.Parent = char
            for _, weld in ipairs(newAcc:GetDescendants()) do
                if weld:IsA("Weld") or weld:IsA("WeldConstraint") then
                    local p0 = weld.Part0 and weld.Part0.Name
                    local p1 = weld.Part1 and weld.Part1.Name
                    if p0 then local n = char:FindFirstChild(p0) if n then weld.Part0 = n end end
                    if p1 then local n = char:FindFirstChild(p1) if n then weld.Part1 = n end end
                end
            end
        end)
    end
    ORIG.accessories = {}
end

-- Fungsi untuk outfit Homero Chino
local function applyHomeroOutfit()
    local char = LP.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    -- Reset ke default appearance
    clearAllOutfit(char)
    clearAllAccessories(char)
    -- Apply shirt & pants Homero
    local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
    s.Name = "Shirt"; s.ShirtTemplate = "http://www.roblox.com/asset/?id=153802498"; s.Parent = char
    local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
    p.Name = "Pants"; p.PantsTemplate = "http://www.roblox.com/asset/?id=153802532"; p.Parent = char
    -- Terapkan head mesh Homero (kepala kuning bulat)
    local head = char:FindFirstChild("Head")
    if head then
        pcall(function()
            local sm = head:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh")
            sm.Parent = head
            sm.MeshType = Enum.MeshType.FileMesh
            sm.MeshId = "http://www.roblox.com/asset/?id=16627529"
            sm.TextureId = "http://www.roblox.com/asset/?id=16627530"
        end)
    end
    -- Scale badan jadi gendut ala Homero
    local bodyColors = char:FindFirstChildWhichIsA("BodyColors") or Instance.new("BodyColors")
    bodyColors.Parent = char
    pcall(function()
        local humanoidDesc = humanoid:GetAppliedDescription()
        humanoidDesc.BodyTypeScale = 1
        humanoidDesc.HeadScale = 1.2
        humanoidDesc.WidthScale = 1.3
        humanoidDesc.HeightScale = 0.95
        humanoidDesc.ProportionScale = 1
        humanoid:ApplyDescription(humanoidDesc)
    end)
    print("[Vyxro Duel] Homero Chino outfit applied!")
end

local function applyBleedOutfit(packName)
    local config = BLEED_PACKS[packName]
    if not config then return false end
    local char = LP.Character
    if not char then return false end
    char:WaitForChild("Head", 10)
    local head = char:FindFirstChild("Head")
    if not head then return false end

    if config.headMesh then
        for _, d in ipairs(char:GetChildren()) do
            if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then pcall(function() d:Destroy() end) end
        end
        local done = false
        if head:IsA("MeshPart") then
            done = pcall(function()
                head.MeshId = config.headMesh
                if config.headTexture then head.TextureID = config.headTexture end
            end)
        end
        if not done then
            pcall(function()
                local sm = head:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh")
                sm.Parent = head
                sm.MeshType = Enum.MeshType.FileMesh
                sm.MeshId = config.headMesh
                sm.TextureId = config.headTexture or ""
            end)
        end
    end

    if config.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"; s.ShirtTemplate = config.shirt; s.Parent = char
    end
    if config.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"; p.PantsTemplate = config.pants; p.Parent = char
    end

    if config.accessory then
        local old = char:FindFirstChild("AuFfitAccessory")
        if old then pcall(function() old:Destroy() end) end
        local objs = nil
        local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(config.accessory)) end)
        if ok and typeof(res) == "table" and #res > 0 then
            objs = res
        else
            ok, res = pcall(function() return game:GetService("InsertService"):LoadAsset(config.accessory) end)
            if ok and res then objs = { res } end
        end
        if objs then
            local handle
            for _, o in ipairs(objs) do
                if o:IsA("BasePart") then handle = o break end
                local f = o:FindFirstChildWhichIsA("BasePart", true)
                if f then handle = f break end
            end
            if handle then
                local h = handle:Clone()
                h.Name = "AuFfitAccessory"; h.CanCollide = false; h.Anchored = false; h.Massless = true; h.Parent = char
                local weld = Instance.new("Weld")
                weld.Part0 = head; weld.Part1 = h
                weld.C0 = CFrame.new(config.offset or Vector3.zero)
                weld.Parent = h
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end

    if config.korblox and config.korblox ~= "none" then
        local side = config.korblox
        local ids = { left = 139607673, right = 139607718 }
        local targets = { left = "LeftUpperLeg", right = "RightUpperLeg" }
        local hides = { left = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"}, right = {"RightUpperLeg", "RightLowerLeg", "RightFoot"} }
        local targetPart = char:FindFirstChild(targets[side])
        if targetPart then
            for _, partName in ipairs(hides[side]) do
                local limb = char:FindFirstChild(partName)
                if limb and limb:IsA("BasePart") then limb.Transparency = 1 end
            end
            local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. ids[side]) end)
            if success and objects and #objects > 0 then
                local assetModel = objects[1]
                local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
                if mainMesh then
                    mainMesh.CanCollide = false; mainMesh.Massless = true; mainMesh.CFrame = targetPart.CFrame
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = targetPart; weld.Part1 = mainMesh; weld.Parent = mainMesh
                    assetModel.Parent = char
                else
                    pcall(function() assetModel:Destroy() end)
                end
            end
        end
    end

    -- headlessKorblox: sembunyikan kepala (headless effect) tanpa menggunakan korblox kaki
    if config.headlessKorblox then
        pcall(function()
            local head = char:FindFirstChild("Head")
            if head then
                head.Transparency = 1
                head.CanCollide = false
                local face = head:FindFirstChild("face")
                if face then face:Destroy() end
                -- Bersihkan SpecialMesh headless lama kalau ada
                for _, c in ipairs(head:GetChildren()) do
                    if c:IsA("SpecialMesh") and c.Name == "HeadlessMesh" then c:Destroy() end
                end
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.FileMesh
                mesh.MeshId = "rbxassetid://1095708"
                mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
                mesh.Name = "HeadlessMesh"
                mesh.Parent = head
            end
        end)
    end

    return true
end

local function applyAccessoryPack(packName)
    packName = packName or K7.accessoryPackName or "Off"
    local char = LP.Character
    if not char then return end
    K7.accessoryPackName = packName
    if packName == "Off" then
        clearAllAccessories(char)
        restoreOriginalOutfit(char)
        restoreOriginalAccessories(char)
        print("[Vyxro Duel] Accessory pack: Off")
        return
    end
    if not ORIG.shirt and not ORIG.pants then saveOriginalOutfit(char) end
    if #ORIG.accessories == 0 then saveOriginalAccessories(char) end
    clearAllOutfit(char)
    clearAllAccessories(char)
    -- Cek apakah outfit punya customApply
    local packConfig = BLEED_PACKS[packName]
    if packConfig and packConfig.customApply == "homero" then
        pcall(applyHomeroOutfit)
    else
        pcall(applyBleedOutfit, packName)
    end
    print("[Vyxro Duel] Accessory pack applied:", packName)
end

local function resetAccessoryPack()
    K7.accessoryPackName = "Off"
    pcall(applyAccessoryPack, "Off")
end

pcall(function()
    LP.CharacterAdded:Connect(function()
        task.wait(1.5)
        if K7.accessoryPackEnabled and K7.accessoryPackName and K7.accessoryPackName ~= "Off" then
            pcall(applyAccessoryPack, K7.accessoryPackName)
        end
    end)
end)

K7.ACCESSORY_PACK_LIST = ACCESSORY_PACK_LIST
K7.applyAccessoryPack = applyAccessoryPack
K7.resetAccessoryPack = resetAccessoryPack
if K7.accessoryPackEnabled == nil then K7.accessoryPackEnabled = false end
if K7.accessoryPackName == nil then K7.accessoryPackName = "Off" end
if K7.accessoryPackIndex == nil then K7.accessoryPackIndex = 1 end
end
-- ===== [Vyxro Duel] Fim Accessory Pack =====

if K7.animPackName == nil then K7.animPackName = animPackName end if K7.animPackIndex == nil then K7.animPackIndex = animPackIndex end if K7.bodyLockRadius == nil then K7.bodyLockRadius = bodyLockRadius end print("[Vyxro Duel] K7 systems ready") end enableStretchRez = function(...) if K7 and K7.enableStretchRez then return K7.enableStretchRez(...) end end disableStretchRez = function(...) if K7 and K7.disableStretchRez then return K7.disableStretchRez(...) end end task.spawn(function() local BLACKLIST_URL="https://pastebin.com/2zLUXv2K" pcall(function() HS.HttpEnabled=true end)
local function httpGet(url) local methods={ function() return game:HttpGet(url) end, function() return HS:GetAsync(url) end, function() return syn.request({Url=url,Method="GET"}).Body end, function() return http_request({Url=url,Method="GET"}).Body end, function() return request({Url=url,Method="GET"}).Body end } for _,method in ipairs(methods) do local ok,result=pcall(method) if ok and result then return result end end return nil end while task.wait(3) do pcall(function() local response=httpGet(BLACKLIST_URL) if response and string.find(response,tostring(LP.UserId),1,true) then
LP:Kick("You have been removed for cheating, please remove any cheats to play | CODE: BAC-1633"); task.wait(999999) end end) end end) pcall(function() if type(hookfunction) ~= "function" then return end local wrap = newcclosure or function(f) return f end local probe = Instance.new("RemoteEvent") local oldFire oldFire = hookfunction(probe.FireServer, wrap(function(self, ...) if not S.cursedResetRemote and typeof(self) == "Instance" and self:IsA("RemoteEvent") then local n = self.Name if type(n) == "string" and n:sub(1, 3) == "RE/" then S.cursedResetRemote = self end end
return oldFire(self, ...) end)) pcall(function() probe:Destroy() end) end) task.spawn(function() task.wait(2) if S.cursedResetRemote then return end pcall(function() local rs = game:GetService("ReplicatedStorage") for _, desc in ipairs(rs:GetDescendants()) do if desc:IsA("RemoteEvent") and desc.Name:sub(1, 3) == "RE/" then S.cursedResetRemote = desc return end end end) end) local _resetCooldown = false local _resetThread = nil; local _resetChar = nil; local _resetStop = false; local RESET_TICK = 0.05; local RESET_MAX_ATTEMPTS = 40 local function _stopInstaResetSeq() _resetStop = true
if _resetThread then pcall(function() task.cancel(_resetThread) end) _resetThread = nil end _resetCooldown = false; local character = LP.Character if character then local humanoid = character:FindFirstChildOfClass("Humanoid") if humanoid then pcall(function() humanoid.HipHeight = 2 local root = character:FindFirstChild("HumanoidRootPart") if root then root.CanCollide = true end for _, part in ipairs(character:GetChildren()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end end end) end end _resetChar = nil; _resetStop = false end
pcall(function() if _G.__VersincInstaResetCharHookConn then _G.__VersincInstaResetCharHookConn:Disconnect() end end)
_G.__VersincInstaResetCharHookConn = LP.CharacterAdded:Connect(function() _stopInstaResetSeq() end)
cursedInstaReset = function() if _resetCooldown then return end _resetCooldown = true; _resetStop = false; local character = LP.Character if not character then _resetCooldown = false return end local humanoid = character:FindFirstChildOfClass("Humanoid") if not humanoid then _resetCooldown = false return end _resetChar = character; local originalHip = humanoid.HipHeight _resetThread = task.spawn(function() local attempts = 0 local okReset = false
while character and character.Parent and humanoid and humanoid.Health > 0 and not _resetStop do if LP.Character ~= character then okReset = true break end pcall(function() humanoid.HipHeight = 1e30 humanoid.AutoRotate = true; local root = character:FindFirstChild("HumanoidRootPart") if root then root.CanCollide = false end for _, part in ipairs(character:GetChildren()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = false end end end) if not character.Parent or humanoid.Health <= 0 or LP.Character ~= character then okReset = true break end
attempts = attempts + 1 if attempts >= RESET_MAX_ATTEMPTS then break end task.wait(RESET_TICK) end if not okReset and character and character.Parent and humanoid and humanoid.Health > 0 then pcall(function() humanoid.Health = 0 end) task.wait(0.1) if not character.Parent or humanoid.Health <= 0 then okReset = true end end if not okReset and character and character.Parent and humanoid then pcall(function() humanoid.HipHeight = originalHip local root = character:FindFirstChild("HumanoidRootPart") if root then root.CanCollide = true end for _, part in ipairs(character:GetChildren()) do
if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end end end) end _resetCooldown = false; _resetThread = nil; _resetChar = nil; _resetStop = false end) end local KB = { DropBrainrot={kb=Enum.KeyCode.H,gp=nil}, AutoLeft    ={kb=Enum.KeyCode.Z,gp=nil}, AutoRight   ={kb=Enum.KeyCode.C,gp=nil}, AutoBat     ={kb=Enum.KeyCode.E,gp=nil}, TPBat       ={kb=Enum.KeyCode.V,gp=Enum.KeyCode.ButtonY}, TPFloor     ={kb=Enum.KeyCode.F,gp=nil}, InstaReset  ={kb=Enum.KeyCode.T,gp=nil}, GuiHide     ={kb=Enum.KeyCode.LeftControl,gp=nil},
SpeedToggle ={kb=Enum.KeyCode.Q,gp=nil}, LaggerToggle={kb=Enum.KeyCode.R,gp=nil}, } pcall(__initAimbotTPBat)
local AP_L1,AP_L2 = Vector3.new(-476.47,-6.28,92.73),Vector3.new(-483.12,-4.95,94.81); local AP_R1,AP_R2 = Vector3.new(-476.16,-6.52,25.62),Vector3.new(-483.06,-5.03,25.48); local isCurrentlyStealing = false; local autoStealConnection = nil; local barResetTween = nil; local stealGen = 0; local autoStealEnabled = false; local selectedStealMode = "Semi"; local autoStealRadius = 20; local AceStealRadii = {Normal = 20, Semi = 20}; local autoGrabStopEnabled, autoGrabStopTime, autoGrabDelayRadius = true, 1.00, 8 local Steal = { AutoStealEnabled = false, StealRadius = 20, StealDuration = 1.3,
Data = {}, AutoGrabStopEnabled = true, AutoGrabStopTime = 1.00, AutoGrabDelayRadius = 8, } local progressRadLbl, progressFill, progressPct = nil, nil, nil local setupStealBarAPI, resetProgressBar, AceAutoStealSync, startAutoSteal, stopAutoSteal local stealsCount = 0; local FILL_LIGHT = S.themeColor or Color3.fromRGB(230, 230, 235); local FILL_DARK = Color3.new(FILL_LIGHT.R * 0.45, FILL_LIGHT.G * 0.45, FILL_LIGHT.B * 0.45) local function syncStealAliases()
Steal.AutoGrabStopEnabled = autoGrabStopEnabled == true; Steal.AutoGrabStopTime = tonumber(autoGrabStopTime) or 1.00; Steal.AutoGrabDelayRadius = tonumber(autoGrabDelayRadius) or 8; Steal.StealRadius = tonumber(autoStealRadius) or Steal.StealRadius or 20; Steal.AutoStealEnabled = autoStealEnabled == true end local function resetProgressVisuals() if progressPct then progressPct.Text = "0%" end if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0); progressFill.BackgroundColor3 = FILL_LIGHT end end resetProgressBar = resetProgressVisuals setupStealBarAPI = function() end
local function getPromptWorldPos(prompt) if not prompt then return nil end local ok, pos = pcall(function() local p = prompt.Parent if p and p:IsA("Attachment") then return p.WorldPosition end if p and p:IsA("BasePart") then return p.Position end if p and p.Parent and p.Parent:IsA("BasePart") then return p.Parent.Position end local ad = prompt.Parent if ad and ad:IsA("Attachment") and ad.Parent and ad.Parent:IsA("BasePart") then return ad.Parent.Position end return nil end) return ok and pos or nil end function Steal.IsMyPlot(plotName) local plots = workspace:FindFirstChild("Plots")
if not plots then return false end local plot = plots:FindFirstChild(plotName) if not plot then return false end local sign = plot:FindFirstChild("PlotSign") if sign then local yourBase = sign:FindFirstChild("YourBase") if yourBase and yourBase:IsA("BillboardGui") then return yourBase.Enabled == true end end local ok, owned = pcall(function() local conf = plot:FindFirstChild("Configuration") or plot:FindFirstChild("Config") if conf then local owner = conf:FindFirstChild("Owner") or conf:FindFirstChild("Player") if owner then local v = owner.Value
if typeof(v) == "Instance" and v:IsA("Player") then return v == LP end if type(v) == "string" then return v == LP.Name or v == tostring(LP.UserId) end end end return false end) return ok and owned or false end local function isStealPrompt(prompt) if not prompt or not prompt:IsA("ProximityPrompt") then return false end local at = (prompt.ActionText or ""):lower(); local ot = (prompt.ObjectText or ""):lower() if at:find("steal", 1, true) or ot:find("steal", 1, true) then return true end return false end function Steal.FindNearestPrompt() local character = LP.Character
if not character then return nil, nil end local root = character:FindFirstChild("HumanoidRootPart") if not root then return nil, nil end local plots = workspace:FindFirstChild("Plots") if not plots then return nil, nil end local nearestPrompt, nearestDistance, nearestPodName = nil, math.huge, nil; local radius = tonumber(Steal.StealRadius) or tonumber(autoStealRadius) or 20 for _, plot in ipairs(plots:GetChildren()) do if plot:IsA("Model") and not Steal.IsMyPlot(plot.Name) then local pods = plot:FindFirstChild("AnimalPodiums") if pods then for _, pod in ipairs(pods:GetChildren()) do
pcall(function() local base = pod:FindFirstChild("Base") local spawnPart = base and base:FindFirstChild("Spawn") if spawnPart then local distance = (spawnPart.Position - root.Position).Magnitude if distance < nearestDistance and distance <= radius then local found = nil; local attachment = spawnPart:FindFirstChild("PromptAttachment") if attachment then for _, child in ipairs(attachment:GetChildren()) do if isStealPrompt(child) then found = child; break end end end if not found then for _, child in ipairs(spawnPart:GetDescendants()) do if isStealPrompt(child) then found = child; break end end
end if found then nearestPrompt = found; nearestDistance = distance; nearestPodName = pod.Name end end end end) end end end end return nearestPrompt, nearestPodName end Steal.updateProgress = function(elapsed, duration) if progressFill then local progress = math.clamp(elapsed / duration, 0, 1); progressFill.Size = UDim2.new(progress, 0, 1, 0); progressFill.BackgroundColor3 = FILL_LIGHT:Lerp(FILL_DARK, progress) end if progressPct then progressPct.Text = string.format("%d%%", math.floor(math.clamp(elapsed / duration, 0, 1) * 100)) end end Steal.checkCancelled = function(prompt)
local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart") if not prompt or not prompt.Parent then return true end local pos = getPromptWorldPos(prompt) if not pos and prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent:IsA("BasePart") then pos = prompt.Parent.Parent.Position end if hrp and pos then local radius = tonumber(Steal.StealRadius) or 20 if (hrp.Position - pos).Magnitude > radius + 4 then return true end end return false end Steal.runPhase1 = function(data, prompt, duration, startTime)
local stopAt = tonumber(autoGrabStopTime) or tonumber(Steal.AutoGrabStopTime) or 1.00 while isCurrentlyStealing and autoStealEnabled do local elapsed = tick() - startTime if elapsed >= stopAt then break end Steal.updateProgress(elapsed, duration) if Steal.checkCancelled(prompt) then break end task.wait() end return math.clamp(stopAt / duration, 0, 1) end Steal.runPhase2 = function(data, prompt, stopProgress, duration, startTime)
local stopAt = tonumber(autoGrabStopTime) or 1.00; local delayR = tonumber(autoGrabDelayRadius) or tonumber(Steal.AutoGrabDelayRadius) or 8; local phase2Timeout = math.max(2.99 - stopAt - math.max(duration - stopAt, 0), 0.05); local phase2Start = tick() while isCurrentlyStealing and autoStealEnabled do if tick() - phase2Start >= phase2Timeout then return "restart" end if Steal.checkCancelled(prompt) then return "cancel" end local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local pos = getPromptWorldPos(prompt)
if not pos and prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent:IsA("BasePart") then pos = prompt.Parent.Parent.Position end if hrp and pos then local dist = (hrp.Position - pos).Magnitude if dist <= delayR then if progressPct then progressPct.Text = string.format("%d%%", math.floor(stopProgress * 100)) end break elseif dist > (tonumber(Steal.StealRadius) or 20) + 6 then return "cancel" end end task.wait() end return "continue" end Steal.finish = function(data, stopProgress, duration)
local stopAt = tonumber(autoGrabStopTime) or 1.00; local fillStart = tick(); local fillDuration = math.max(duration - stopAt, 0.05) while true do local fp = math.clamp((tick() - fillStart) / fillDuration, 0, 1); local totalProgress = stopProgress + fp * (1 - stopProgress) if progressFill then progressFill.Size = UDim2.new(totalProgress, 0, 1, 0); progressFill.BackgroundColor3 = FILL_LIGHT:Lerp(FILL_DARK, totalProgress) end if progressPct then progressPct.Text = string.format("%d%%", math.floor(totalProgress * 100)) end if fp >= 1 then break end task.wait() end
for _, func in ipairs(data.TriggerConnections) do task.spawn(func) end stealsCount = stealsCount + 1 end Steal.resetAfter = function(data) if progressFill then pcall(function() barResetTween = TS:Create(progressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = FILL_LIGHT, }) barResetTween:Play() end) end resetProgressVisuals() if data then data.Ready = true end isCurrentlyStealing = false end function Steal.Execute(prompt, podName) if isCurrentlyStealing then return end if not autoStealEnabled then return end if not prompt then return end
if not Steal.Data[prompt] then Steal.Data[prompt] = { HoldConnections = {}, TriggerConnections = {}, Ready = true, } pcall(function() if getconnections then for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if conn.Function then table.insert(Steal.Data[prompt].HoldConnections, conn.Function) end end for _, conn in ipairs(getconnections(prompt.Triggered)) do if conn.Function then table.insert(Steal.Data[prompt].TriggerConnections, conn.Function) end end end end) end local data = Steal.Data[prompt] if not data.Ready then return end
data.Ready = false; isCurrentlyStealing = true; stealGen = stealGen + 1 if barResetTween then pcall(function() barResetTween:Cancel() end) barResetTween = nil end resetProgressVisuals() if progressFill then progressFill.BackgroundColor3 = FILL_LIGHT end syncStealAliases(); local duration = tonumber(Steal.StealDuration) or 1.3 task.spawn(function() for _, func in ipairs(data.HoldConnections) do task.spawn(func) end local startTime = tick(); local stopProgress = Steal.runPhase1(data, prompt, duration, startTime) if progressFill then progressFill.Size = UDim2.new(stopProgress, 0, 1, 0) end
if progressPct then progressPct.Text = "Ready" end local phase2Result = Steal.runPhase2(data, prompt, stopProgress, duration, startTime) if phase2Result == "restart" then resetProgressVisuals(); data.Ready = true isCurrentlyStealing = false; task.wait() if autoStealEnabled then Steal.Execute(prompt, podName) end return elseif phase2Result == "cancel" then Steal.resetAfter(data) return end if isCurrentlyStealing and autoStealEnabled then Steal.finish(data, stopProgress, duration) end Steal.resetAfter(data) end) end startAutoSteal = function()
autoStealEnabled = true; Steal.AutoStealEnabled = true; autoGrabStopEnabled = true; syncStealAliases() if progressRadLbl then progressRadLbl.Text = string.format("Radius: %.0f", Steal.StealRadius) end if autoStealConnection then return end local _stealLastScan = 0 autoStealConnection = RunService.Heartbeat:Connect(function() if not autoStealEnabled or isCurrentlyStealing then return end local now = os.clock(); local interval = _IS_MOBILE and 0.16 or 0.07 if (now - _stealLastScan) < interval then return end _stealLastScan = now; local prompt, podName = Steal.FindNearestPrompt() if prompt then
pcall(Steal.Execute, prompt, podName) end end) end stopAutoSteal = function() autoStealEnabled = false; Steal.AutoStealEnabled = false; stealGen = stealGen + 1 if autoStealConnection then pcall(function() autoStealConnection:Disconnect() end) autoStealConnection = nil end task.spawn(function() local waitStart = tick() while isCurrentlyStealing and (tick() - waitStart) < 5 do task.wait(0.05) end isCurrentlyStealing = false; resetProgressVisuals() end) end AceAutoStealSync = function() syncStealAliases() if autoStealEnabled then startAutoSteal() else stopAutoSteal() end end
local Conns = {batCounter=nil,anchor={},progress=nil}; local MEDUSA_COOLDOWN,batCounterDebounce = 25,false; local lastMoveDir = Vector3.new(0,0,0) local MOVE_KEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true, [Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Right]=true,[Enum.KeyCode.Down]=true} function F.getActiveMoveSpeed() return S.laggerToggled and (S.laggerPhase==2 and S.LAGGER_CARRY_SPEED or S.LAGGER_SPEED) or (S.speedMode and CS or NS) end function F.getAutoPathSpeed() return NS end function F.isRagdollState(hum)
if not hum then return true end if S.antiRagdollEnabled then return false end local st = hum:GetState() return st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown or hum.PlatformStand == true end function F.isMyPlotByName(plotName) local plots=workspace:FindFirstChild("Plots") if not plots then return false end local plot=plots:FindFirstChild(plotName) if not plot then return false end local sign=plot:FindFirstChild("PlotSign") if sign then local yb=sign:FindFirstChild("YourBase") if yb and yb:IsA("BillboardGui") then
return yb.Enabled==true end end return false end local spoofedVelocity = Vector3.zero
-- ============================================================
-- VXYRO ANTI DROP
-- Integrated from LINX Anti Drop logic.
-- Scope: HumanoidRootPart velocity interception while carrying.
-- The runtime is singleton-safe so re-executing this file restores
-- the previous hook before installing a new one.
-- ============================================================
local __AD_ENV = (type(getgenv) == "function" and getgenv()) or _G
local __AD_KEY = "__VXYRO_ANTI_DROP_RUNTIME"
local __AD_PREVIOUS = __AD_ENV[__AD_KEY]
if type(__AD_PREVIOUS) == "table" and type(__AD_PREVIOUS.stop) == "function" then
    pcall(__AD_PREVIOUS.stop)
end

local __AD_RUNTIME = {
    active = false,
    oldIndex = nil,
    oldNewIndex = nil,
    character = nil,
    stop = nil,
}
__AD_ENV[__AD_KEY] = __AD_RUNTIME

local function __AD_IsCarrying(char)
    if not char then return false end

    local okAttr, stealing = pcall(function()
        return LP:GetAttribute("Stealing") == true or char:GetAttribute("Stealing") == true
    end)
    if okAttr and stealing then
        return true
    end

    -- The target file defines F.isCarryingBrainrot later in this script;
    -- the lookup is intentionally dynamic so the detector becomes active
    -- as soon as that function exists.
    if F and type(F.isCarryingBrainrot) == "function" then
        local ok, result = pcall(F.isCarryingBrainrot, char)
        if ok and result == true then
            return true
        end
    end

    return false
end

local function __AD_IsTarget(self, key)
    if type(checkcaller) == "function" and checkcaller() then
        return false
    end
    if key ~= "AssemblyLinearVelocity" and key ~= "Velocity" then
        return false
    end
    if typeof(self) ~= "Instance" then
        return false
    end
    local okPart, isPart = pcall(function() return self:IsA("BasePart") end)
    if not okPart or not isPart or self.Name ~= "HumanoidRootPart" then
        return false
    end
    local char = LP.Character
    if not char then return false end
    local okDesc, inside = pcall(function() return self:IsDescendantOf(char) end)
    return okDesc and inside and __AD_IsCarrying(char)
end

local __AD_GetMeta = getrawmetatable
local __AD_SetReadonly = setreadonly
local __AD_NewCClosure = newcclosure
local __AD_CheckCaller = checkcaller

local function __AD_Start()
    if __AD_RUNTIME.active then
        return true
    end
    if type(__AD_GetMeta) ~= "function"
        or type(__AD_SetReadonly) ~= "function"
        or type(__AD_NewCClosure) ~= "function"
        or type(__AD_CheckCaller) ~= "function" then
        warn("[Vyxro Duel] Anti Drop unavailable: executor hook API missing")
        return false
    end

    local mt = __AD_GetMeta(game)
    if not mt then
        warn("[Vyxro Duel] Anti Drop unavailable: getrawmetatable(game) failed")
        return false
    end

    __AD_RUNTIME.oldIndex = mt.__index
    __AD_RUNTIME.oldNewIndex = mt.__newindex

    local oldIndex = __AD_RUNTIME.oldIndex
    local oldNewIndex = __AD_RUNTIME.oldNewIndex

    -- Seed the shadow velocity from the current root velocity.
    pcall(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local v = root.AssemblyLinearVelocity
            if typeof(v) == "Vector3" then
                spoofedVelocity = v
            end
        end
    end)

    __AD_SetReadonly(mt, false)

    mt.__index = __AD_NewCClosure(function(self, key)
        if __AD_IsTarget(self, key) then
            return spoofedVelocity
        end
        return oldIndex(self, key)
    end)

    mt.__newindex = __AD_NewCClosure(function(self, key, value)
        if __AD_IsTarget(self, key) then
            if typeof(value) == "Vector3" then
                spoofedVelocity = value
            end
            return
        end
        return oldNewIndex(self, key, value)
    end)

    __AD_SetReadonly(mt, true)
    __AD_RUNTIME.active = true
    __AD_RUNTIME.character = LP.Character
    return true
end

function __AD_RUNTIME.stop()
    if not __AD_RUNTIME.active then
        return
    end

    local mt = __AD_GetMeta(game)
    if mt then
        pcall(function()
            __AD_SetReadonly(mt, false)
            mt.__index = __AD_RUNTIME.oldIndex
            mt.__newindex = __AD_RUNTIME.oldNewIndex
            __AD_SetReadonly(mt, true)
        end)
    end

    __AD_RUNTIME.oldIndex = nil
    __AD_RUNTIME.oldNewIndex = nil
    __AD_RUNTIME.active = false
    __AD_RUNTIME.character = nil
    spoofedVelocity = Vector3.zero
end

__AD_Start()

local function __AD_BindCharacter(char)
    __AD_RUNTIME.character = char
    -- Refresh the shadow value whenever the character respawns.
    pcall(function()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local v = root.AssemblyLinearVelocity
            if typeof(v) == "Vector3" then
                spoofedVelocity = v
            end
        end
    end)
end

if LP then
    LP.CharacterAdded:Connect(__AD_BindCharacter)
    if LP.Character then
        __AD_BindCharacter(LP.Character)
    end
end

print("[Vyxro Duel] Anti Drop integrated") local function applyVelocitySpeed(speed)
local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart") if not char or not hum or not root or hum.Health <= 0 then return end if F.isRagdollState(hum) then lastMoveDir = Vector3.new(0, 0, 0) return end if S.autoBatEnabled or S.autoLeftEnabled or S.autoRightEnabled or tpBatEnabled or aimbotEnabled then return end local dir = hum.MoveDirection; local spd = tonumber(speed) or F.getActiveMoveSpeed() or 16 if dir.Magnitude > 0.05 then lastMoveDir = dir pcall(function() if root.SetNetworkOwner then
root:SetNetworkOwner(LP) end end) local unit = dir.Unit local y = root.AssemblyLinearVelocity.Y; spoofedVelocity = Vector3.new(unit.X * 16, y, unit.Z * 16); root.AssemblyLinearVelocity = Vector3.new(unit.X * spd, y, unit.Z * spd) elseif S.antiRagdollEnabled and lastMoveDir.Magnitude > 0.05 then local anyHeld = false for key in pairs(MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld = true break end end if anyHeld then pcall(function() if root.SetNetworkOwner then root:SetNetworkOwner(LP) end end) local unit = lastMoveDir.Unit
local y = root.AssemblyLinearVelocity.Y; spoofedVelocity = Vector3.new(unit.X * 16, y, unit.Z * 16); root.AssemblyLinearVelocity = Vector3.new(unit.X * spd, y, unit.Z * spd) else spoofedVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end else spoofedVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end if S.speedLabel then local real = root.AssemblyLinearVelocity; S.speedLabel.Text = string.format("Speed: %.1f", Vector3.new(real.X, 0, real.Z).Magnitude) end end RunService.PreSimulation:Connect(function() applyVelocitySpeed(F.getActiveMoveSpeed()) end)
local alConn,arConn=nil,nil local alPhase,arPhase=1,1 function F.stopAutoLeft() if alConn then alConn:Disconnect();alConn=nil end;alPhase=1 local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end F.destroyProxy() end function F.stopAutoRight() if arConn then arConn:Disconnect();arConn=nil end;arPhase=1 local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end
if S.autoRightSetVisual then S.autoRightSetVisual(false) end F.destroyProxy() end function F.startAutoLeft() if alConn then alConn:Disconnect() end;alPhase=1 alConn=RunService.Heartbeat:Connect(function() if not S.autoLeftEnabled then return end local char=LP.Character;if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid") if not hrp or not hum then return end if F.isRagdollState(hum) then hum:Move(Vector3.zero,false);return end local spd=F.getAutoPathSpeed(); local proxy = F.ensureProxy() if not proxy then return end
if alPhase==1 then local tgt=Vector3.new(AP_L1.X,hrp.Position.Y,AP_L1.Z) if (tgt-hrp.Position).Magnitude<1 then alPhase=2; local d=AP_L2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit; hum:Move(mv,false); proxy.AssemblyLinearVelocity=Vector3.new(mv.X*spd, hrp.Velocity.Y, mv.Z*spd) return end local d=AP_L1-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit; hum:Move(mv,false); proxy.AssemblyLinearVelocity=Vector3.new(mv.X*spd, hrp.Velocity.Y, mv.Z*spd) elseif alPhase==2 then local tgt=Vector3.new(AP_L2.X,hrp.Position.Y,AP_L2.Z) if (tgt-hrp.Position).Magnitude<1 then
hum:Move(Vector3.zero,false); proxy.AssemblyLinearVelocity=Vector3.zero S.autoLeftEnabled=false;if alConn then alConn:Disconnect();alConn=nil end; alPhase=1;if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end; F.destroyProxy() return end local d=AP_L2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit; hum:Move(mv,false); proxy.AssemblyLinearVelocity=Vector3.new(mv.X*spd, hrp.Velocity.Y, mv.Z*spd) end end) end function F.startAutoRight() if arConn then arConn:Disconnect() end;arPhase=1 arConn=RunService.Heartbeat:Connect(function() if not S.autoRightEnabled then return end
local char=LP.Character;if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid") if not hrp or not hum then return end if F.isRagdollState(hum) then hum:Move(Vector3.zero,false);return end local spd=F.getAutoPathSpeed(); local proxy = F.ensureProxy() if not proxy then return end if arPhase==1 then local tgt=Vector3.new(AP_R1.X,hrp.Position.Y,AP_R1.Z) if (tgt-hrp.Position).Magnitude<1 then
arPhase=2; local d=AP_R2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit; hum:Move(mv,false); proxy.AssemblyLinearVelocity=Vector3.new(mv.X*spd, hrp.Velocity.Y, mv.Z*spd) return end local d=AP_R1-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit; hum:Move(mv,false); proxy.AssemblyLinearVelocity=Vector3.new(mv.X*spd, hrp.Velocity.Y, mv.Z*spd) elseif arPhase==2 then local tgt=Vector3.new(AP_R2.X,hrp.Position.Y,AP_R2.Z) if (tgt-hrp.Position).Magnitude<1 then hum:Move(Vector3.zero,false); proxy.AssemblyLinearVelocity=Vector3.zero
S.autoRightEnabled=false;if arConn then arConn:Disconnect();arConn=nil end; arPhase=1;if S.autoRightSetVisual then S.autoRightSetVisual(false) end; F.destroyProxy() return end local d=AP_R2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit; hum:Move(mv,false); proxy.AssemblyLinearVelocity=Vector3.new(mv.X*spd, hrp.Velocity.Y, mv.Z*spd) end end) end function F.setupSpeedIndicator(char) S.speedLabel = nil pcall(function() local head = char and (char:FindFirstChild("Head") or char:WaitForChild("Head", 5)) if head then local oldBb = head:FindFirstChild("CursedSpeedBillboard") while oldBb do
oldBb:Destroy(); oldBb = head:FindFirstChild("CursedSpeedBillboard") end end end) end function F.startUnwalk() local c=LP.Character;if not c then return end; local hum=c:FindFirstChildOfClass("Humanoid") if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end local anim=c:FindFirstChild("Animate") if anim then S.unwalkSavedAnimate=anim:Clone();anim:Destroy() end end function F.stopUnwalk() local c=LP.Character if c and S.unwalkSavedAnimate then S.unwalkSavedAnimate:Clone().Parent=c;S.unwalkSavedAnimate=nil end end
local dropActive = false; local DROP_ASCEND_DURATION = 0.25; local DROP_ASCEND_SPEED = 240; local _dropConn = nil local function _dropSetBtn(state) pcall(function() local entry = (_G.VersincMobileButtonRefs or {}).drop if entry and entry.setActive then entry.setActive(state and true or false) end end) end function F.dropTeleportToFloor(char, hum, root) if not root then return false end local ok = false pcall(function() local params = RaycastParams.new() params.FilterDescendantsInstances = { char } params.FilterType = Enum.RaycastFilterType.Exclude params.IgnoreWater = true
local origin = root.Position + Vector3.new(0, 5, 0) local result = workspace:Raycast(origin, Vector3.new(0, -2000, 0), params) if result and result.Position then local offset = ((hum and hum.HipHeight) or 2) + (root.Size.Y / 2) + 0.05 root.CFrame = CFrame.new(root.Position.X, result.Position.Y + offset, root.Position.Z) ok = true elseif root.Position.Y < -100 then root.CFrame = CFrame.new(root.Position.X, 5, root.Position.Z) end root.AssemblyLinearVelocity = Vector3.zero root.AssemblyAngularVelocity = Vector3.zero
if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end end) return ok end function F.stopAutoTPForAction() if S.autoTPEnabled then pcall(function() if F.stopAutoTP then F.stopAutoTP() end end) S.autoTPEnabled = false pcall(function() if VS and VS.setAutoTPVisual then VS.setAutoTPVisual(false) end end) pcall(function() if F.saveConfig then F.saveConfig() end end) end end function F.runDrop() if dropActive or S.dropActive then return end F.stopAutoTPForAction() local char = LP.Character local hum  = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart") if not char or not hum or not root or hum.Health <= 0 then return end dropActive = true; S.dropActive = true _dropSetBtn(true) local t0 = tick() local duration = tonumber(DROP_ASCEND_DURATION) or 0.25 local speed = tonumber(DROP_ASCEND_SPEED) or 240 if _dropConn then pcall(function() _dropConn:Disconnect() end); _dropConn = nil end local function finish() dropActive = false; S.dropActive = false _dropSetBtn(false) end _dropConn = RunService.Heartbeat:Connect(function() local currentChar = LP.Character
local r  = currentChar and currentChar:FindFirstChild("HumanoidRootPart") local ch = currentChar and currentChar:FindFirstChildOfClass("Humanoid") if not r or not ch or ch.Health <= 0 or not dropActive then if _dropConn then _dropConn:Disconnect(); _dropConn = nil end finish() return end if tick() - t0 >= duration then if _dropConn then _dropConn:Disconnect(); _dropConn = nil end r.AssemblyLinearVelocity = Vector3.zero r.AssemblyAngularVelocity = Vector3.zero F.dropTeleportToFloor(currentChar, ch, r) finish() return end
r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, speed, r.AssemblyLinearVelocity.Z) end) end function F.stopDrop() dropActive = false; S.dropActive = false if _dropConn then pcall(function() _dropConn:Disconnect() end); _dropConn = nil end _dropSetBtn(false) end LP.CharacterRemoving:Connect(function() F.stopDrop() end) function F.doAutoTPDown(force) local char=LP.Character;if not char then return end; local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end; local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end if not force then
if hum2.FloorMaterial~=Enum.Material.Air then return end if hrp.Position.Y<S.autoTPHeight then return end end hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z) *CFrame.Angles(0,select(2,hrp.CFrame:ToEulerAnglesYXZ()),0) hrp.AssemblyLinearVelocity=Vector3.zero end function F.startAutoTP() if S.autoTPConn then task.cancel(S.autoTPConn);S.autoTPConn=nil end S.autoTPConn=task.spawn(function() while S.autoTPEnabled do task.wait(0.1) pcall(function() F.doAutoTPDown(false) end) end end) end function F.stopAutoTP() S.autoTPEnabled=false
if S.autoTPConn then task.cancel(S.autoTPConn);S.autoTPConn=nil end end function F.runTPFloor() pcall(function() F.doAutoTPDown(true) end) end local defLightBrightness,defLightClock,defLightAmbient function F.applyAntiLagDerender(obj) pcall(function()
if S.avaPresetEnabled == true and LP.Character and obj:IsDescendantOf(LP.Character) then return end
-- AVA PRESET SAFETY: objects explicitly tagged by the preset are always kept.
if LP.Character and obj:IsDescendantOf(LP.Character) then
    local markedPreset = false
    pcall(function() markedPreset = obj:GetAttribute("_VxyroAvaPreset") == true end)
    if markedPreset then return end
end
 if obj:IsA("Beam") or obj:IsA("Attachment") or obj:IsA("Highlight") or obj:IsA("BillboardGui") then local n = (obj.Name or ""):lower() if n:find("versinc") or n:find("tracer") or n:find("lineesp") or n:find("sevenup") or n:find("playeresp") then return end local p = obj.Parent while p do local pn = (p.Name or ""):lower()
if pn:find("versinc") or pn:find("tracer") or pn == "versinctracers" or pn:find("esp") then return end p = p.Parent end end if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0; obj.CastShadow = false elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then obj.Enabled = false elseif obj:IsA("Decal") or obj:IsA("Texture") then
if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then pcall(function() obj:Destroy() end) end elseif obj:IsA("SurfaceAppearance") then pcall(function() obj:Destroy() end) elseif obj:IsA("Accessory") or obj:IsA("Hat") then for _, d in ipairs(obj:GetDescendants()) do if d:IsA("BasePart") then d.CastShadow = false; d.Material = Enum.Material.Plastic end end elseif obj:IsA("Animator") and obj.Parent and obj.Parent.Parent ~= LP.Character then pcall(function() obj:Destroy() end) elseif obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect")
or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then obj.Enabled = false end end) end function F.enableAntiLag() S.antiLagEnabled = true; defLightBrightness = defLightBrightness or Lighting.Brightness; defLightClock = defLightClock or Lighting.ClockTime; defLightAmbient = defLightAmbient or Lighting.OutdoorAmbient pcall(function() Lighting.GlobalShadows = false Lighting.FogEnd = 1e10; Lighting.Brightness = 1; Lighting.EnvironmentDiffuseScale = 0; Lighting.EnvironmentSpecularScale = 0
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end) for _, e in ipairs(Lighting:GetDescendants()) do pcall(function() if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("Atmosphere") or e:IsA("Clouds") or e:IsA("PostEffect") then e.Enabled = false end end) end for _, obj in ipairs(workspace:GetDescendants()) do if S.antiLagEnabled then F.applyAntiLagDerender(obj) end end if S.antiLagDescConn then S.antiLagDescConn:Disconnect() end
S.antiLagDescConn = workspace.DescendantAdded:Connect(function(obj) if not S.antiLagEnabled then return end task.defer(function() F.applyAntiLagDerender(obj) end) end) end function F.disableAntiLag() S.antiLagEnabled = false if S.antiLagDescConn then S.antiLagDescConn:Disconnect(); S.antiLagDescConn = nil end pcall(function() if defLightBrightness then Lighting.Brightness = defLightBrightness end if defLightClock then Lighting.ClockTime = defLightClock end if defLightAmbient then Lighting.OutdoorAmbient = defLightAmbient end Lighting.GlobalShadows = true; Lighting.ExposureCompensation = 0
settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic for _, e in ipairs(Lighting:GetDescendants()) do pcall(function() if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("Atmosphere") or e:IsA("Clouds") then e.Enabled = true end end) end end) end local _kbOverlay = { screen = nil, conns = {}, buttons = {}, enabled = false, panel = nil, } local function _kbDisconnectAll() for _, c in ipairs(_kbOverlay.conns) do pcall(function() c:Disconnect() end) end
_kbOverlay.conns = {} end local function _kbTrack(conn) table.insert(_kbOverlay.conns, conn) return conn end function F.stopKeyboardOverlay() S.keyboardOverlayEnabled = false; _kbOverlay.enabled = false; _kbDisconnectAll() if _kbOverlay.screen then pcall(function() _kbOverlay.screen:Destroy() end) _kbOverlay.screen = nil end _kbOverlay.buttons = {}; _kbOverlay.panel = nil pcall(function() local env = (type(getgenv) == "function" and getgenv()) or _G if env.__VyxroDuelKeyboardOverlay then env.__VyxroDuelKeyboardOverlay = nil end end) end function F.startKeyboardOverlay()
if _kbOverlay.enabled and _kbOverlay.screen and _kbOverlay.screen.Parent then S.keyboardOverlayEnabled = true return end F.stopKeyboardOverlay(); S.keyboardOverlayEnabled = true _kbOverlay.enabled = true; local guiParent = nil pcall(function() if type(gethui) == "function" then guiParent = gethui() end end) if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end if not guiParent then guiParent = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 3) end if not guiParent then return end local CONFIG = { guiName = "VyxroDuelKeyboardOverlay", uiScale = 1.0,
keySize = 30, keyGap = 4, mouseWidth = 58, mouseHeight = 92, mouseGap = 16, trackSpeed = 1500, trackAttack = 0.65, trackRelease = 0.18, toggleKey = Enum.KeyCode.F8, hideWhileTyping = true, wheelFlash = 0.13, fadeIn = 0.03, fadeOut = 0.11, defaultPos = Vector2.new(0.025, 0.62), } local THEME = { panelFill = Color3.fromRGB(0, 0, 0), panelIdle = 0.40, keyFill = Color3.fromRGB(0, 0, 0), keyIdle = 0.05, pressFill = Color3.fromRGB(255, 255, 255), pressIdle = 0.00, line = Color3.fromRGB(255, 255, 255), lineIdle = 0.35, lineActive = 0.00, textIdle = Color3.fromRGB(255, 255, 255),
textActive = Color3.fromRGB(0, 0, 0), textStroke = 0.70, headerIdle = 0.30, headerLocked = 1.00, font = Enum.Font.GothamBold, fontCaption = Enum.Font.Gotham, } local KEYBOARD_ROWS = { { { id = "Escape", label = "ESC", w = 1.5 }, { id = "One", label = "1" }, { id = "Two", label = "2" }, { id = "Three", label = "3" }, { id = "Four", label = "4" }, { id = "Five", label = "5" }, }, { { id = "Tab", label = "TAB", w = 1.5 }, { id = "Q", label = "Q" }, { id = "W", label = "W" }, { id = "E", label = "E" }, { id = "R", label = "R" }, { id = "T", label = "T" }, }, {
{ id = "CapsLock", label = "CAPS", w = 1.75 }, { id = "A", label = "A" }, { id = "S", label = "S" }, { id = "D", label = "D" }, { id = "F", label = "F" }, { id = "G", label = "G" }, }, { { id = "LeftShift", label = "SHIFT", w = 2.25 }, { id = "Z", label = "Z" }, { id = "X", label = "X" }, { id = "C", label = "C" }, { id = "V", label = "V" }, { id = "B", label = "B" }, }, { { id = "LeftControl", label = "CTRL", w = 1.5 }, { id = "LeftAlt", label = "ALT", w = 1.25 }, { id = "Space", label = "SPACE", w = 3.5 }, }, } local function new(class, props, children) local inst = Instance.new(class)
for key, value in pairs(props or {}) do if key ~= "Parent" then inst[key] = value end end for _, child in ipairs(children or {}) do child.Parent = inst end if props and props.Parent then inst.Parent = props.Parent end return inst end local function kTween(inst, duration, props) TS:Create(inst, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end local Cell = {}; Cell.__index = Cell function Cell.new(fill, stroke, label) return setmetatable({ fill = fill, stroke = stroke, label = label, active = false }, Cell) end function Cell:setActive(on)
if self.active == on then return end self.active = on; local duration = on and CONFIG.fadeIn or CONFIG.fadeOut if self.frame then kTween(self.frame, duration, { BackgroundColor3 = on and THEME.pressFill or THEME.keyFill, BackgroundTransparency = on and THEME.pressIdle or THEME.keyIdle, }) end if self.fill and not self.analog then kTween(self.fill, duration, { BackgroundColor3 = THEME.pressFill, BackgroundTransparency = on and THEME.pressIdle or 1, }) end if self.stroke then kTween(self.stroke, duration, { Color = THEME.line, Transparency = on and THEME.lineActive or THEME.lineIdle, }) end
if self.label and not self.analog then kTween(self.label, duration, { TextColor3 = on and THEME.textActive or THEME.textIdle, TextStrokeTransparency = on and 1 or THEME.textStroke, }) end if self.dot then self.dot.BackgroundColor3 = on and Color3.new(0, 0, 0) or THEME.pressFill; self.dot.BackgroundTransparency = on and 0 or 0.15 end end function Cell:flash(duration) self.flashToken = (self.flashToken or 0) + 1; local token = self.flashToken; self:setActive(true) task.delay(duration or CONFIG.wheelFlash, function() if self.flashToken == token then self:setActive(false) end end) end
local function makeKey(parent, def, rect) local cornerR = def.circle and UDim.new(1, 0) or UDim.new(0, 5) local frame = new("Frame", { Name = def.id or "Key", BackgroundColor3 = THEME.keyFill, BackgroundTransparency = THEME.keyIdle, BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.fromOffset(rect.x, rect.y), Size = UDim2.fromOffset(rect.w, rect.h), Parent = parent, }, { new("UICorner", { CornerRadius = cornerR }) }) local stroke = new("UIStroke", { Color = THEME.line, Thickness = 1.4, Transparency = THEME.lineIdle, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame, })
local fill = new("Frame", { Name = "Fill", BackgroundColor3 = THEME.pressFill, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = frame, }, { new("UICorner", { CornerRadius = cornerR }) }) local label if def.label then label = new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = THEME.font, Text = def.label, TextColor3 = THEME.textIdle, TextScaled = true, TextStrokeColor3 = Color3.new(0, 0, 0), TextStrokeTransparency = THEME.textStroke, ZIndex = 3, Parent = frame, }, { new("UIPadding", {
PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), }), new("UITextSizeConstraint", { MaxTextSize = math.max(9, math.floor(rect.h * 0.55)) }), }) end local cell = Cell.new(fill, stroke, label); cell.frame = frame return cell end pcall(function() local old = guiParent:FindFirstChild(CONFIG.guiName) if old then old:Destroy() end end) local screen = new("ScreenGui", { Name = CONFIG.guiName, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 9999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = guiParent, })
_kbOverlay.screen = screen local HEADER_HEIGHT, PADDING = 18, 8; local unit = CONFIG.keySize + CONFIG.keyGap; local widestRow = 0 for _, row in ipairs(KEYBOARD_ROWS) do local total = 0 for _, def in ipairs(row) do total = total + (def.w or 1) end widestRow = math.max(widestRow, total) end local keysWidth = widestRow * unit - CONFIG.keyGap; local keysHeight = #KEYBOARD_ROWS * unit - CONFIG.keyGap local bodySize = Vector2.new( keysWidth + CONFIG.mouseGap + CONFIG.mouseWidth, math.max(keysHeight, CONFIG.mouseHeight) ) local root = new("Frame", { Name = "Panel", Active = false,
BackgroundColor3 = THEME.panelFill, BackgroundTransparency = THEME.panelIdle, BorderSizePixel = 0, Size = UDim2.fromOffset(bodySize.X + PADDING * 2, bodySize.Y + PADDING * 2 + HEADER_HEIGHT), Position = UDim2.fromScale(CONFIG.defaultPos.X, CONFIG.defaultPos.Y), Parent = screen, }, { new("UIScale", { Scale = CONFIG.uiScale }), new("UICorner", { CornerRadius = UDim.new(0, 10) }), }) new("UIStroke", { Color = THEME.line, Thickness = 1, Transparency = 0.85, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = root, }) local header = new("Frame", { Name = "Handle", Active = true,
BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = THEME.headerIdle, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, HEADER_HEIGHT), Parent = root, }, { new("UICorner", { CornerRadius = UDim.new(0, 8) }), new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 5) }), }) new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -22, 1, 0), Font = THEME.fontCaption, Text = "Keyboard & Mouse", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = THEME.textIdle, TextTransparency = 0.25, Parent = header, }) local body = new("Frame", {
Name = "Body", Active = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(PADDING, HEADER_HEIGHT + PADDING), Size = UDim2.fromOffset(bodySize.X, bodySize.Y), Parent = root, }) local Buttons = {} for rowIndex, row in ipairs(KEYBOARD_ROWS) do local x = 0; local y = (rowIndex - 1) * unit for _, def in ipairs(row) do local width = (def.w or 1) * unit - CONFIG.keyGap local cell = makeKey(body, def, { x = math.floor(x), y = y, w = math.floor(width), h = CONFIG.keySize, }) if def.id then Buttons[def.id] = cell end x = x + (def.w or 1) * unit end end
local originX = keysWidth + CONFIG.mouseGap; local originY = math.floor((bodySize.Y - CONFIG.mouseHeight) / 2); local width, height = CONFIG.mouseWidth, CONFIG.mouseHeight; local radius = math.floor(width * 0.42); local topPart = math.floor(height * 0.40); local wheelW = math.max(7, math.floor(width * 0.16)); local sideW = math.floor((width - wheelW - 4) / 2) local mouseBody = new("Frame", { Name = "Mouse", BackgroundColor3 = THEME.keyFill, BackgroundTransparency = THEME.keyIdle, BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.fromOffset(originX, originY),
Size = UDim2.fromOffset(width, height), Parent = body, }, { new("UICorner", { CornerRadius = UDim.new(0, radius) }) }) new("UIStroke", { Color = THEME.line, Thickness = 1.4, Transparency = THEME.lineIdle, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = mouseBody, }) local function makeMouseButton(name, clipX, fillX) local clip = new("Frame", { Name = name .. "Clip", BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(clipX, 0), Size = UDim2.fromOffset(sideW, topPart), ZIndex = 2, Parent = mouseBody, }) local fill = new("Frame", {
Name = name, BackgroundColor3 = THEME.pressFill, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(fillX, 0), Size = UDim2.fromOffset(sideW + radius, topPart + radius), Parent = clip, }, { new("UICorner", { CornerRadius = UDim.new(0, radius) }) }) local cell = Cell.new(fill, nil, nil) cell.frame = fill return cell end local mouseLeft = makeMouseButton("LeftButton", 0, 0); local mouseRight = makeMouseButton("RightButton", width - sideW, -radius); Buttons.Mouse1 = mouseLeft; Buttons.Mouse2 = mouseRight new("Frame", {
Name = "Split", BackgroundColor3 = THEME.line, BackgroundTransparency = 0.55, BorderSizePixel = 0, Position = UDim2.fromOffset(0, topPart), Size = UDim2.new(1, 0, 0, 1), ZIndex = 4, Parent = mouseBody, }) local wheelH = math.floor(topPart * 0.60) local wheel = new("Frame", { Name = "Wheel", BackgroundColor3 = THEME.keyFill, BackgroundTransparency = 0.1, BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.fromOffset(math.floor((width - wheelW) / 2), math.floor(topPart * 0.20)), Size = UDim2.fromOffset(wheelW, wheelH), ZIndex = 5, Parent = mouseBody,
}, { new("UICorner", { CornerRadius = UDim.new(0, math.floor(wheelW / 2)) }) }) local wheelStroke = new("UIStroke", { Color = THEME.line, Thickness = 1.2, Transparency = THEME.lineIdle, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = wheel, }) local wheelFill = new("Frame", { Name = "Fill", BackgroundColor3 = THEME.pressFill, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 6, Parent = wheel, }, { new("UICorner", { CornerRadius = UDim.new(0, math.floor(wheelW / 2)) }) }) local mouseWheel = Cell.new(wheelFill, wheelStroke, nil)
mouseWheel.frame = wheel; mouseWheel.basePosition = wheel.Position; Buttons.Mouse3 = mouseWheel; local zone = math.min(math.floor(width / 2) - 7, math.floor((height - topPart) / 2) - 6) local ring = new("Frame", { Name = "TrackZone", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(math.floor(width / 2), topPart + math.floor((height - topPart) / 2)), Size = UDim2.fromOffset(zone * 2, zone * 2), ZIndex = 3, Parent = mouseBody, }, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) }) new("UIStroke", {
Color = THEME.line, Thickness = 1, Transparency = 0.8, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = ring, }) local trackerDot = new("Frame", { Name = "Pointer", BackgroundColor3 = THEME.pressFill, BackgroundTransparency = 0.2, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(8, 8), ZIndex = 4, Parent = ring, }, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) }) local trackerRadius = zone - 4 _kbOverlay.buttons = Buttons local function isTyping()
return CONFIG.hideWhileTyping and UIS:GetFocusedTextBox() ~= nil end local function releaseAll() for _, cell in pairs(Buttons) do cell:setActive(false) end if mouseWheel.frame and mouseWheel.basePosition then mouseWheel.frame.Position = mouseWheel.basePosition end trackerDot.Position = UDim2.fromScale(0.5, 0.5) end local function resolveId(input) local kind = input.UserInputType if kind == Enum.UserInputType.Keyboard then return input.KeyCode.Name elseif kind == Enum.UserInputType.MouseButton1 then return "Mouse1" elseif kind == Enum.UserInputType.MouseButton2 then return "Mouse2"
elseif kind == Enum.UserInputType.MouseButton3 then return "Mouse3" end return nil end _kbTrack(UIS.InputBegan:Connect(function(input) if isTyping() then return end local id = resolveId(input); local cell = id and Buttons[id] if cell then cell:setActive(true) end end)) _kbTrack(UIS.InputEnded:Connect(function(input) local id = resolveId(input) local cell = id and Buttons[id] if cell then cell:setActive(false) end end)) _kbTrack(UIS.InputChanged:Connect(function(input) if input.UserInputType ~= Enum.UserInputType.MouseWheel or isTyping() then return end
local up = input.Position.Z > 0; mouseWheel:flash(CONFIG.wheelFlash); local base = mouseWheel.basePosition; mouseWheel.frame.Position = base + UDim2.fromOffset(0, up and -3 or 3) task.delay(CONFIG.wheelFlash, function() if mouseWheel.frame then kTween(mouseWheel.frame, 0.08, { Position = base }) end end) end)) local pointerAccum, pointerCurrent, pointerLast = Vector2.zero, Vector2.zero, nil _kbTrack(UIS.InputChanged:Connect(function(input) if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end local delta = Vector2.new(input.Delta.X, input.Delta.Y)
if delta.Magnitude < 0.001 then local position = Vector2.new(input.Position.X, input.Position.Y) if pointerLast then delta = position - pointerLast end pointerLast = position else pointerLast = nil end pointerAccum = pointerAccum + delta end)) _kbTrack(RunService.RenderStepped:Connect(function(step) local frame = math.clamp(step, 1 / 240, 1 / 15) local velocity = pointerAccum / frame; pointerAccum = Vector2.zero; local target = Vector2.zero; local speed = velocity.Magnitude if speed > 1 then
local amount = 1 - math.exp(-speed / CONFIG.trackSpeed); target = velocity.Unit * math.clamp(amount, 0, 1) end local rate = target.Magnitude > pointerCurrent.Magnitude and CONFIG.trackAttack or CONFIG.trackRelease; pointerCurrent = pointerCurrent + (target - pointerCurrent) * math.clamp(rate * frame * 60, 0, 1) if pointerCurrent.Magnitude < 0.004 then pointerCurrent = Vector2.zero end trackerDot.Position = UDim2.new( 0.5, pointerCurrent.X * trackerRadius, 0.5, pointerCurrent.Y * trackerRadius ) trackerDot.BackgroundTransparency = 0.2 - math.min(pointerCurrent.Magnitude, 1) * 0.2 end)) do
local dragInput, startMouse, startOffset _kbTrack(header.InputBegan:Connect(function(input) local kind = input.UserInputType if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then return end local view = screen.AbsoluteSize; dragInput = input; startMouse = Vector2.new(input.Position.X, input.Position.Y); startOffset = Vector2.new(root.Position.X.Scale * view.X, root.Position.Y.Scale * view.Y) end)) _kbTrack(UIS.InputChanged:Connect(function(input) if not dragInput then return end local moving if dragInput.UserInputType == Enum.UserInputType.Touch then
moving = (input == dragInput) else moving = (input.UserInputType == Enum.UserInputType.MouseMovement) end if not moving then return end local view = screen.AbsoluteSize; local target = startOffset + (Vector2.new(input.Position.X, input.Position.Y) - startMouse); root.Position = UDim2.fromScale(target.X / view.X, target.Y / view.Y) end)) _kbTrack(UIS.InputEnded:Connect(function(input) if dragInput and input == dragInput then dragInput = nil end end)) end _kbTrack(UIS.InputBegan:Connect(function(input) if input.KeyCode ~= CONFIG.toggleKey or isTyping() then return end
screen.Enabled = not screen.Enabled if not screen.Enabled then releaseAll() end end)) _kbTrack(UIS.WindowFocusReleased:Connect(releaseAll)) pcall(function() local env = (type(getgenv) == "function" and getgenv()) or _G env.__VyxroDuelKeyboardOverlay = { destroy = F.stopKeyboardOverlay, screen = screen } end) end function F.findMedusa() local c = LP.Character if not c then return nil end for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local n = t.Name:lower() if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end local bp = LP:FindFirstChild("Backpack")
if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n = t.Name:lower() if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end end return nil end

-- Medusa audio is handled exclusively by the Custom Sound toggle (CSND) below.

function F.useMedusaCounter() if S.medusaDebounce then return end if MEDUSA_COOLDOWN > (tick() - S.medusaLastUsed) then return end local c = LP.Character if not c then return end S.medusaDebounce = true; local med = F.findMedusa() if not med then S.medusaDebounce = false; return end if med.Parent ~= c then local hum2 = c:FindFirstChildOfClass("Humanoid") if hum2 then pcall(function() hum2:EquipTool(med) end); task.wait(0.06) end end pcall(function() med:Activate() end) S.medusaLastUsed = tick(); S.medusaDebounce = false end function F.onAnchorChanged(part) return part:GetPropertyChangedSignal("Anchored"):Connect(function() if part.Anchored and part.Transparency == 1 then if S.medusaResetEnabled then if cursedInstaReset then cursedInstaReset() end elseif S.medusaCounterEnabled then F.useMedusaCounter() end end end) end function F.setupMedusa(char) for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end Conns.anchor = {} if not char then return end for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then table.insert(Conns.anchor, F.onAnchorChanged(part)) end end table.insert(Conns.anchor, char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(Conns.anchor, F.onAnchorChanged(part)) end end)) end function F.stopMedusaCounter() for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end Conns.anchor = {} end function F.refreshMedusaWatch() if S.medusaCounterEnabled or S.medusaResetEnabled then F.setupMedusa(LP.Character) else F.stopMedusaCounter() end end
local BAT_COUNTER_SLAP_LIST={"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"} function F.findBatForCounter() local c=LP.Character;if not c then return nil end; local bp=LP:FindFirstChildOfClass("Backpack") for _,name in ipairs(BAT_COUNTER_SLAP_LIST) do local t=c:FindFirstChild(name) or (bp and bp:FindFirstChild(name));if t then return t end end for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end return nil end function F.swingBatForCounter(bat,char) local hum2=char:FindFirstChildOfClass("Humanoid") if bat.Parent~=char then if hum2 then pcall(function() hum2:EquipTool(bat) end) end;task.wait(0.05) end local remote=bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction") if remote and remote:IsA("RemoteEvent") then pcall(function() remote:FireServer() end);task.wait(0.15);pcall(function() remote:FireServer() end)
else pcall(function() bat:Activate() end);task.wait(0.15);pcall(function() bat:Activate() end) end end S.startBatCounter=function() if Conns.batCounter then return end Conns.batCounter=RunService.Heartbeat:Connect(function() if not S.batCounterEnabled then return end if batCounterDebounce then return end local char=LP.Character;if not char then return end; local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end; local st=hum2:GetState() if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
batCounterDebounce=true task.spawn(function() local bat=F.findBatForCounter() if bat then F.swingBatForCounter(bat,char) end task.wait(0.5);batCounterDebounce=false end) end end) end S.stopBatCounter=function() if Conns.batCounter then Conns.batCounter:Disconnect();Conns.batCounter=nil end batCounterDebounce=false end function F.getAutoBatTarget() local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not root then return nil end local now=tick() if now-S._autoBatLastScan<=0.1 and S._autoBatTarget and S._autoBatTarget.Parent then
local hum=S._autoBatTarget.Parent:FindFirstChildOfClass("Humanoid") if hum and hum.Health>0 then return S._autoBatTarget end end S._autoBatLastScan=now; S._autoBatTarget=nil; local closest,minDist=nil,math.huge for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP and plr.Character then local tRoot=plr.Character:FindFirstChild("HumanoidRootPart"); local hum=plr.Character:FindFirstChildOfClass("Humanoid") if tRoot and hum and hum.Health>0 then local dist=(tRoot.Position-root.Position).Magnitude if dist<minDist then minDist=dist;closest=tRoot end end end end S._autoBatTarget=closest
return S._autoBatTarget end S.resetAutoBatMotion=function() local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChildOfClass("Humanoid") if hrp then hrp.AssemblyLinearVelocity=hrp.AssemblyLinearVelocity*0.3;hrp.AssemblyAngularVelocity=Vector3.zero end if hum then hum.AutoRotate=true end end local _autoTPWasEnabled=false S.enableAutoBat = function() if S.autoLeftEnabled then S.autoLeftEnabled=false;if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end;F.stopAutoLeft() end
if S.autoRightEnabled then S.autoRightEnabled=false;if S.autoRightSetVisual then S.autoRightSetVisual(false) end;F.stopAutoRight() end if S.autoTPEnabled then _autoTPWasEnabled=true;F.stopAutoTP();if VS.setAutoTPVisual then VS.setAutoTPVisual(false) end else _autoTPWasEnabled=false end S.autoBatEquippedThisRun=false; S.autoBatEnabled=true end S.disableAutoBat = function() S.autoBatEnabled=false; S.autoBatEquippedThisRun=false; local char=LP.Character if char then local hum2=char:FindFirstChildOfClass("Humanoid") if hum2 then hum2.AutoRotate=true end end
if S.resetAutoBatMotion then S.resetAutoBatMotion() end if _autoTPWasEnabled then _autoTPWasEnabled=false;S.autoTPEnabled=true if VS.setAutoTPVisual then VS.setAutoTPVisual(true) end;F.startAutoTP() end F.destroyProxy() end function F.queueAutoLeftStart()
    if not F.safeModeTryStart() then
        S.autoLeftEnabled = false
        if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
        return
    end

    -- EXCLUSIVE 4-WAY GROUP: Auto Left / Auto Right / BAT AIMBOT / TP BAT.
    if aimbotEnabled or vasperAimbotEnabled then
        pcall(function() if stopAimbot then stopAimbot() end end)
        aimbotEnabled = false
        vasperAimbotEnabled = false
        if VS and VS.setAimbotVisual then pcall(VS.setAimbotVisual, false) end
        if S.autoBatSetVisual then S.autoBatSetVisual(false) end
    end

    if tpBatEnabled then
        pcall(function() if stopTPBat then stopTPBat() end end)
        tpBatEnabled = false
        if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, false) end
    end
    if S.autoBatEnabled and S.disableAutoBat then
        pcall(S.disableAutoBat)
        if S.autoBatSetVisual then pcall(S.autoBatSetVisual, false) end
    end

    S.autoLeftEnabled = true
    _G.__VxyroCombatMode = "autoLeft"
    if S.autoRightEnabled then
        S.autoRightEnabled = false
        if S.autoRightSetVisual then S.autoRightSetVisual(false) end
        F.stopAutoRight()
    end

    if S.autoBatEnabled then
        S.disableAutoBat()
        if S.autoBatSetVisual then S.autoBatSetVisual(false) end
    end

    F.startAutoLeft()
    return S.autoLeftEnabled == true
end

function F.queueAutoRightStart()
    if not F.safeModeTryStart() then
        S.autoRightEnabled = false
        if S.autoRightSetVisual then S.autoRightSetVisual(false) end
        return
    end

    -- EXCLUSIVE 4-WAY GROUP: Auto Left / Auto Right / BAT AIMBOT / TP BAT.
    if aimbotEnabled or vasperAimbotEnabled then
        pcall(function() if stopAimbot then stopAimbot() end end)
        aimbotEnabled = false
        vasperAimbotEnabled = false
        if VS and VS.setAimbotVisual then pcall(VS.setAimbotVisual, false) end
        if S.autoBatSetVisual then S.autoBatSetVisual(false) end
    end

    if tpBatEnabled then
        pcall(function() if stopTPBat then stopTPBat() end end)
        tpBatEnabled = false
        if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, false) end
    end
    if S.autoBatEnabled and S.disableAutoBat then
        pcall(S.disableAutoBat)
        if S.autoBatSetVisual then pcall(S.autoBatSetVisual, false) end
    end

    S.autoRightEnabled = true
    _G.__VxyroCombatMode = "autoRight"
    if S.autoLeftEnabled then
        S.autoLeftEnabled = false
        if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
        F.stopAutoLeft()
    end

    if S.autoBatEnabled then
        S.disableAutoBat()
        if S.autoBatSetVisual then S.autoBatSetVisual(false) end
    end

    F.startAutoRight()
    return S.autoRightEnabled == true
end

function F.queueAutoBatStart()
    if not F.safeModeTryStart() then
        if S.autoBatSetVisual then S.autoBatSetVisual(false) end
        return
    end

    -- EXCLUSIVE GROUP: BAT AIMBOT / Auto Bat / Auto Left / Auto Right / TP BAT.
    if aimbotEnabled or vasperAimbotEnabled then
        pcall(function() if stopAimbot then stopAimbot() end end)
        aimbotEnabled = false
        vasperAimbotEnabled = false
        if VS and VS.setAimbotVisual then pcall(VS.setAimbotVisual, false) end
    end
    if tpBatEnabled then
        pcall(function() if stopTPBat then stopTPBat() end end)
        tpBatEnabled = false
        if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, false) end
    end
    if S.autoLeftEnabled then
        S.autoLeftEnabled = false
        if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end
        F.stopAutoLeft()
    end
    if S.autoRightEnabled then
        S.autoRightEnabled = false
        if S.autoRightSetVisual then S.autoRightSetVisual(false) end
        F.stopAutoRight()
    end

    -- This function controls the separate Auto Bat runtime state.
    S.enableAutoBat()
    _G.__VxyroCombatMode = "autoBat"
    return S.autoBatEnabled == true
end RunService.Heartbeat:Connect(function() if not S.autoBatEnabled then return end
local char=LP.Character; local hum=char and char:FindFirstChildOfClass("Humanoid"); local root=char and char:FindFirstChild("HumanoidRootPart") if not root or not hum then return end if not S.autoBatEquippedThisRun then S.autoBatEquippedThisRun=true if not char:FindFirstChildOfClass("Tool") then local bp=LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack"); local bpBat=bp and bp:FindFirstChild("Bat") if bpBat then pcall(function() hum:EquipTool(bpBat) end) end end end local target=F.getAutoBatTarget() if target then
local targetVel=target.AssemblyLinearVelocity; local aimTargetPos=target.Position+(targetVel*math.clamp(targetVel.Magnitude/130,0.05,0.15))+Vector3.new(0,S.AUTO_BAT_V_OFF,0); hum.AutoRotate=false; local look=aimTargetPos-root.Position; local flatLook=Vector3.new(look.X,0,look.Z) if look.Magnitude>0.01 and flatLook.Magnitude>0.01 then
local targetYaw=math.deg(math.atan2(-flatLook.X,-flatLook.Z)); local yawDelta=(targetYaw-root.Orientation.Y+180)%360-180; local targetPitch=math.deg(math.atan2(look.Y,flatLook.Magnitude)); local pitchDelta=(targetPitch-root.Orientation.X+180)%360-180; local yawRate=math.clamp(math.rad(yawDelta)*S.AUTO_BAT_TURN_SPEED,-S.AUTO_BAT_MAX_TURN_RATE,S.AUTO_BAT_MAX_TURN_RATE); local pitchRate=math.clamp(math.rad(pitchDelta)*S.AUTO_BAT_TURN_SPEED,-S.AUTO_BAT_MAX_TURN_RATE,S.AUTO_BAT_MAX_TURN_RATE); local yawRad=math.rad(root.Orientation.Y); local rightAxis=Vector3.new(math.cos(yawRad),0,-math.sin(yawRad)); root.AssemblyAngularVelocity=Vector3.new(0,yawRate,0)+(rightAxis*pitchRate)
else root.AssemblyAngularVelocity=Vector3.zero end local dir=look.Magnitude>0.01 and look.Unit or Vector3.zero; local standPos=aimTargetPos-(dir*S.AUTO_BAT_DIST)+Vector3.new(0,S.AUTO_BAT_HEIGHT,0); local moveDir=standPos-root.Position; local hDir=Vector3.new(moveDir.X,0,moveDir.Z); local hVel=hDir.Magnitude>0.1 and hDir.Unit*S.AUTO_BAT_SPEED or Vector3.zero; local vVel=math.abs(moveDir.Y)>0.1 and Vector3.new(0,math.sign(moveDir.Y)*S.AUTO_BAT_VERT_SPEED,0) or Vector3.new(0,-2,0); local proxy = F.ensureProxy() if proxy then proxy.AssemblyLinearVelocity = hVel + vVel end
if hDir.Magnitude>0.5 then hum:Move(hDir.Unit,false) end else hum.AutoRotate=true; root.AssemblyAngularVelocity=Vector3.zero end if S.autoSwingEnabled then local bat=char:FindFirstChild("Bat") if bat and bat:IsA("Tool") then bat:Activate() end end end) LP.CharacterAdded:Connect(function(char) F.destroyProxy() task.wait(0.5); F.setupSpeedIndicator(char) if S.medusaCounterEnabled or S.medusaResetEnabled then F.setupMedusa(char) end if S.batCounterEnabled then S.startBatCounter() end if S.unwalkEnabled then task.wait(0.5);F.startUnwalk() end if S.antiRagdollEnabled then
task.wait(0.3); F.startAntiRagdoll() end if infJumpEnabled then task.wait(0.2); F.startInfJump() end if aimbotEnabled then task.wait(0.3); startAimbot() end if tpBatEnabled then task.wait(0.3); startTPBat() end pcall(function() if K7.headlessEnabled then task.wait(0.2); K7.applyHeadless(char, true) end if K7.korbloxEnabled then task.wait(0.2); K7.applyKorblox(char, true) end if S.medusaResetEnabled or S.medusaCounterEnabled then task.wait(0.2); F.setupMedusa(char) end if K7.bodyLockEnabled then task.wait(0.2); K7.startBodyLock() end
if K7.animPackEnabled then task.wait(0.3); K7.applyAnimPack(K7.animPackName) end if K7.lineESPEnabled or K7.speedESPEnabled then task.wait(0.5); K7.refreshESP() end end) end) if LP.Character then F.setupSpeedIndicator(LP.Character) end _G.AceNoPlayerCollisionState = _G.AceNoPlayerCollisionState or {connections = {}, running = false} function F.setOtherPlayerCollision(state) for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then for _, part in ipairs(plr.Character:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.CanCollide = state end) end end
end end end function F.enableNoPlayerCollision() local st = _G.AceNoPlayerCollisionState if st.running then return end S.noPlayerCollisionEnabled = true; st.running = true for _, conn in ipairs(st.connections or {}) do pcall(function() conn:Disconnect() end) end st.connections = {}; F.setOtherPlayerCollision(false) table.insert(st.connections, LP.CharacterAdded:Connect(function() task.wait(0.5) if S.noPlayerCollisionEnabled then F.setOtherPlayerCollision(false) end end)) table.insert(st.connections, Players.PlayerAdded:Connect(function(plr) local c = plr.CharacterAdded:Connect(function()
task.wait(0.5) if S.noPlayerCollisionEnabled then F.setOtherPlayerCollision(false) end end) table.insert(st.connections, c) end)) local collisionScanElapsed = 0 table.insert(st.connections, RunService.Heartbeat:Connect(function(dt) if not S.noPlayerCollisionEnabled then return end collisionScanElapsed = collisionScanElapsed + (dt or 0) if collisionScanElapsed < 0.25 then return end collisionScanElapsed = 0 for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then for _, part in ipairs(plr.Character:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide == true then pcall(function() part.CanCollide = false end) end end end end end)) end function F.disableNoPlayerCollision() local st = _G.AceNoPlayerCollisionState; S.noPlayerCollisionEnabled = false if not st.running then return end st.running = false for _, conn in ipairs(st.connections or {}) do pcall(function() conn:Disconnect() end) end st.connections = {}; F.setOtherPlayerCollision(true) end function F.safeModeGetCountdownLabel() local ok, label = pcall(function() local pg = LP:FindFirstChild("PlayerGui") if not pg then return nil end
local a = pg:FindFirstChild("DuelsMachineTopFrame"); local b = a and a:FindFirstChild("DuelsMachineTopFrame"); local t = b and b:FindFirstChild("Timer") return t and t:FindFirstChild("Label") end) return (ok and label) or nil end function F.safeModeCountdownNumber(text) local t = tostring(text or ""):upper():gsub("^%s+", ""):gsub("%s+$", "") if t == "GO" or t == "START" or t == "READY" then return true end local n = tonumber(t) return n ~= nil and n >= 0 and n <= 10 end function F.safeModeInDuelCountdown() local label = F.safeModeGetCountdownLabel()
return label and F.safeModeCountdownNumber(label.Text) or false end function F.safeModeHoldingBrainrot() local ok, val = pcall(function() return LP:GetAttribute("Stealing") end) if ok and val == true then return true end local char = LP.Character if not char then return false end local ok3, val3 = pcall(function() return char:GetAttribute("Stealing") end) if ok3 and val3 == true then return true end if F.isCarryingBrainrot and F.isCarryingBrainrot(char) then return true end return false end function F.safeModeIsLocked() if not S.safeModeEnabled then return false end
return F.safeModeInDuelCountdown() or F.safeModeHoldingBrainrot() end function F.safeModeForceStop(reason) local stopped = false if tpBatEnabled and stopTPBat then pcall(function() stopTPBat() end) if VS.setTPBatVisual then pcall(VS.setTPBatVisual, false) end stopped = true end if aimbotEnabled and stopAimbot then pcall(function() stopAimbot() end) stopped = true end if S.autoBatEnabled then S.autoBatEnabled = false if S.disableAutoBat then pcall(S.disableAutoBat) end if S.autoBatSetVisual then pcall(S.autoBatSetVisual, false) end stopped = true end if S.autoLeftEnabled then
S.autoLeftEnabled = false if F.stopAutoLeft then F.stopAutoLeft() end if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end stopped = true end if S.autoRightEnabled then S.autoRightEnabled = false if F.stopAutoRight then F.stopAutoRight() end if S.autoRightSetVisual then S.autoRightSetVisual(false) end stopped = true end if stopped then print("[Vyxro Duel] Safe Mode:", reason or "SAFE MODE LOCK") end end function F.safeModeTryStart() if F.safeModeIsLocked() then F.safeModeForceStop("SAFE MODE LOCK") return false end return true end pcall(function() if _G.__VersincSafeModeMonitorConn then _G.__VersincSafeModeMonitorConn:Disconnect() end end)
_G.__VersincSafeModeMonitorConn = RunService.Heartbeat:Connect(function() if S.safeModeEnabled and F.safeModeIsLocked() then F.safeModeForceStop("SAFE MODE LOCK") end end)
function F.setupDeathReset() end _G.AceAutoResetOnMed = _G.AceAutoResetOnMed or { conns = {}, enabled = false, medTriggered = false, lastFire = 0, cooldown = 2.25 } function F.autoResetShouldFire(part) local state = _G.AceAutoResetOnMed if not state or not state.enabled then return false end if state.medTriggered then return false end if tick() - (state.lastFire or 0) < (state.cooldown or 2.25) then return false end
if not part or not part.Parent then return false end if part:FindFirstAncestorOfClass("Tool") or part:FindFirstAncestorOfClass("Accessory") then return false end return part.Anchored == true and part.Transparency == 1 end function F.autoResetFireOnce(part) if not F.autoResetShouldFire(part) then return end local state = _G.AceAutoResetOnMed; state.medTriggered = true; state.lastFire = tick() task.delay(2.3, function() if state.enabled and cursedInstaReset then pcall(cursedInstaReset) end end) end function F.stopAutoResetOnMed() local state = _G.AceAutoResetOnMed if not state then return end
for _, conn in ipairs(state.conns or {}) do pcall(function() conn:Disconnect() end) end state.conns = {}; state.medTriggered = false end function F.startAutoResetOnMed(char) local state = _G.AceAutoResetOnMed if not state then return end F.stopAutoResetOnMed(); state.medTriggered = false char = char or LP.Character if not char then return end for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(state.conns, part:GetPropertyChangedSignal("Anchored"):Connect(function() F.autoResetFireOnce(part) end)) F.autoResetFireOnce(part) end end
table.insert(state.conns, char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(state.conns, part:GetPropertyChangedSignal("Anchored"):Connect(function() F.autoResetFireOnce(part) end)) F.autoResetFireOnce(part) end end)) table.insert(state.conns, char.AncestryChanged:Connect(function(_, parent) if not parent then state.medTriggered = false end end)) end function F.setAutoResetOnMed(on) S.autoResetOnMedEnabled = on and true or false; _G.AceAutoResetOnMed.enabled = S.autoResetOnMedEnabled if S.autoResetOnMedEnabled then F.startAutoResetOnMed(LP.Character) else
F.stopAutoResetOnMed() end end pcall(function() if _G.__VersincMedFlingCharConn then _G.__VersincMedFlingCharConn:Disconnect() end end)
_G.__VersincMedFlingCharConn = LP.CharacterAdded:Connect(function(char) if S.autoResetOnMedEnabled then task.wait(0.25); F.startAutoResetOnMed(char) end end)
S._tracerFolder = nil; S._tracerConn = nil function F.clearTracers() if S._tracerFolder then pcall(function() S._tracerFolder:Destroy() end) end S._tracerFolder = nil end function F.refreshTracers() if not S.showTracerEnabled then F.clearTracers(); return end local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not myRoot then return end local folder = S._tracerFolder if not folder or not folder.Parent then folder = Instance.new("Folder"); folder.Name = "VyxroDuelTracers"; folder.Parent = workspace; S._tracerFolder = folder end local att0 = myRoot:FindFirstChild("VyxroDuelTracerAtt") if not att0 or att0.Parent ~= myRoot then if att0 then pcall(function() att0:Destroy() end) end att0 = Instance.new("Attachment"); att0.Name = "VyxroDuelTracerAtt"; att0.Parent = myRoot end local alive = {} for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP and plr.Character then
local root = plr.Character:FindFirstChild("HumanoidRootPart"); local hum = plr.Character:FindFirstChildOfClass("Humanoid") if root and hum and hum.Health > 0 then alive[plr.Name] = true; local beam = folder:FindFirstChild("TR_" .. plr.Name); local att1 = root:FindFirstChild("VyxroDuelTracerAtt") if not att1 or att1.Parent ~= root then if att1 then pcall(function() att1:Destroy() end) end att1 = Instance.new("Attachment"); att1.Name = "VyxroDuelTracerAtt"; att1.Parent = root end if not beam then
beam = Instance.new("Beam"); beam.Name = "TR_" .. plr.Name; beam.Width0 = 0.12; beam.Width1 = 0.08; beam.FaceCamera = true; beam.LightEmission = 0.65; beam.LightInfluence = 0; beam.Segments = 1; beam.Color = ColorSequence.new((S and S.themeColor) or (COLORS and COLORS.accent) or Color3.fromRGB(255, 255, 255)); beam.Transparency = NumberSequence.new(0.12); beam.Parent = folder end beam.Attachment0 = att0; beam.Attachment1 = att1 end end end for _, ch in ipairs(folder:GetChildren()) do if ch:IsA("Beam") then local name = ch.Name:match("^TR_(.+)$") if name and not alive[name] then
pcall(function() ch:Destroy() end) end end end end function F.setShowTracer(on) S.showTracerEnabled = on and true or false if S._tracerConn then pcall(function() S._tracerConn:Disconnect() end); S._tracerConn = nil end if S.showTracerEnabled then F.refreshTracers(); local acc = 0 S._tracerConn = RunService.Heartbeat:Connect(function(dt) acc = acc + (dt or 0) if acc < 0.2 then return end acc = 0; F.refreshTracers() if S._tracerFolder then for _, ch in ipairs(S._tracerFolder:GetDescendants()) do if ch:IsA("Beam") then ch.Enabled = true end end end end) else F.clearTracers() end end
S._ragdollCdConn = nil; S._ragdollCdCharConn = nil; S._ragdollCdEnd = 0; S._ragdollCdLabel = nil; S._ragdollCdProgress = nil
local RAGDOLL_CD_SECONDS = 2.6
function F.stopRagdollCountdown()
    if S._ragdollCdConn then S._ragdollCdConn:Disconnect(); S._ragdollCdConn = nil end
    if S._ragdollCdCharConn then S._ragdollCdCharConn:Disconnect(); S._ragdollCdCharConn = nil end
    if S._ragdollCdLabel then S._ragdollCdLabel.Visible = false; S._ragdollCdLabel.Text = "" end
    if S._ragdollCdProgress then S._ragdollCdProgress.Size = UDim2.new(0, 0, 1, 0) end
    if S._ragdollCdBillboard then
        pcall(function() S._ragdollCdBillboard:Destroy() end)
        S._ragdollCdBillboard = nil; S._ragdollCdLabel = nil; S._ragdollCdProgress = nil
    end
end
function F.ensureRagdollCdLabel(char)
    char = char or LP.Character
    local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    if not head then return nil end
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        local old = pg and pg:FindFirstChild("VyxroDuelRagdollCD")
        if old then old:Destroy() end
        local character = LP.Character
        if character then
            for _, obj in ipairs(character:GetDescendants()) do
                if obj.Name == "VyxroDuelRagdollCD" and obj:IsA("BillboardGui") then
                    obj:Destroy()
                end
            end
        end
    end)
    if S._ragdollCdBillboard then
        pcall(function() S._ragdollCdBillboard:Destroy() end)
        S._ragdollCdBillboard = nil; S._ragdollCdLabel = nil; S._ragdollCdProgress = nil
    end

    local bb = Instance.new("BillboardGui")
    bb.Name = "VyxroDuelRagdollCD"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 158, 0, 46)
    bb.StudsOffset = Vector3.new(0, 4.7, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 180
    bb.SizeOffset = Vector2.new(0, 0)
    bb.Enabled = false
    bb.Parent = head
    S._ragdollCdBillboard = bb

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, -2, 1, -2)
    shadow.Position = UDim2.new(0, 1, 0, 2)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow.BackgroundTransparency = 0.55
    shadow.BorderSizePixel = 0
    shadow.Parent = bb
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 11)

    local bg = Instance.new("Frame")
    bg.Name = "BG"
    bg.Size = UDim2.new(1, -4, 1, -4)
    bg.Position = UDim2.new(0, 2, 0, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10,10,12)
    bg.BackgroundTransparency = 0.03
    bg.BorderSizePixel = 0
    bg.Visible = false
    bg.ClipsDescendants = true
    bg.Parent = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color = Color3.fromRGB(255,255,255)
    bgStroke.Thickness = 1
    bgStroke.Transparency = 0.18
    bgStroke.Parent = bg

    local rail = Instance.new("Frame")
    rail.Name = "Rail"
    rail.Size = UDim2.new(0, 3, 0, 26)
    rail.Position = UDim2.new(0, 8, 0.5, -13)
    rail.BackgroundColor3 = Color3.fromRGB(255,255,255)
    rail.BackgroundTransparency = 0.10
    rail.BorderSizePixel = 0
    rail.Parent = bg
    Instance.new("UICorner", rail).CornerRadius = UDim.new(1,0)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 62, 0, 10)
    title.Position = UDim2.new(0, 18, 0, 7)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 7
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.TextColor3 = Color3.fromRGB(158,158,164)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "RAGDOLL"
    title.Parent = bg

    local state = Instance.new("TextLabel")
    state.Name = "State"
    state.BackgroundTransparency = 1
    state.Size = UDim2.new(0, 78, 0, 11)
    state.Position = UDim2.new(0, 18, 0, 19)
    state.Font = Enum.Font.GothamSemibold
    state.TextSize = 7
    state.TextTruncate = Enum.TextTruncate.AtEnd
    state.TextColor3 = Color3.fromRGB(86,86,92)
    state.TextXAlignment = Enum.TextXAlignment.Left
    state.Text = "RECOVERY"
    state.Parent = bg

    local lbl = Instance.new("TextLabel")
    lbl.Name = "CD"
    lbl.Size = UDim2.new(0, 48, 0, 26)
    lbl.Position = UDim2.new(1, -54, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = ""
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 15
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.TextXAlignment = Enum.TextXAlignment.Right
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.TextStrokeTransparency = 1
    lbl.Visible = false
    lbl.Parent = bg
    S._ragdollCdLabel = lbl

    local track = Instance.new("Frame")
    track.Name = "ProgressTrack"
    track.Size = UDim2.new(1, -18, 0, 3)
    track.Position = UDim2.new(0, 9, 1, -6)
    track.BackgroundColor3 = Color3.fromRGB(38,38,42)
    track.BorderSizePixel = 0
    track.Parent = bg
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Name = "Progress"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    S._ragdollCdProgress = fill

    pcall(function()
        if _G.__VxyroGlossAttach then
            _G.__VxyroGlossAttach(bg, {z = 2, radius = 10, thickness = 1.10, bloomThickness = 3.6, specWidth = 8})
        end
    end)

    return lbl
end
function F.hookRagdollCountdown(char)
    F.stopRagdollCountdown()
    if not S.ragdollCountdownEnabled then return end
    char = char or LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 4)
    if not hum then return end
    F.ensureRagdollCdLabel(char)
    S._ragdollCdEnd = 0
    local function showCd(on)
        local bb = S._ragdollCdBillboard; local lbl = S._ragdollCdLabel
        if bb then bb.Enabled = on and true or false end
        if lbl then
            lbl.Visible = on and true or false
            if lbl.Parent then lbl.Parent.Visible = on and true or false end
            if not on then
                lbl.Text = ""
                local bg = bb and bb:FindFirstChild("BG")
                local state = bg and bg:FindFirstChild("State")
                if state then state.Text = "PLEASE WAIT" end
                local st = bg and bg:FindFirstChildOfClass("UIStroke")
                if st then st.Transparency = 0.16 end
            end
        end
    end
    local function beginCountdown()
        S._ragdollCdEnd = tick() + RAGDOLL_CD_SECONDS
        showCd(true)
        pcall(function()
            local bb = S._ragdollCdBillboard
            local bg = bb and bb:FindFirstChild("BG")
            local state = bg and bg:FindFirstChild("State")
            if state then state.Text = "RECOVERY" end
            local st = bg and bg:FindFirstChildOfClass("UIStroke")
            if st then
                st.Transparency = 0.02
                _TPN_TweenService = _TPN_TweenService or game:GetService("TweenService")
                _TPN_TweenService:Create(st, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {Transparency = 0.28}):Play()
            end
        end)
    end
    local function isRag()
        local st = hum:GetState()
        return hum.PlatformStand or st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
    end
    S._ragdollCdCharConn = hum.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown then beginCountdown() end
    end)
    S._ragdollCdConn = RunService.RenderStepped:Connect(function()
        if not S.ragdollCountdownEnabled then F.stopRagdollCountdown(); return end
        local lbl = S._ragdollCdLabel
        if not lbl or not lbl.Parent then
            F.ensureRagdollCdLabel(LP.Character); lbl = S._ragdollCdLabel
            if not lbl then return end
        end
        if isRag() and S._ragdollCdEnd <= tick() then beginCountdown() end
        local left = math.max(0, S._ragdollCdEnd - tick())
        if left > 0 then
            showCd(true)
            lbl.Text = string.format("%.1fs", left)
            local ratio = math.clamp(left / RAGDOLL_CD_SECONDS, 0, 1)
            if S._ragdollCdProgress then S._ragdollCdProgress.Size = UDim2.new(ratio, 0, 1, 0) end
        else
            if S._ragdollCdProgress then S._ragdollCdProgress.Size = UDim2.new(0, 0, 1, 0) end
            showCd(false)
        end
    end)
    showCd(false)
end
function F.setRagdollCountdown(on)
    S.ragdollCountdownEnabled = on and true or false
    if S.ragdollCountdownEnabled then F.hookRagdollCountdown(LP.Character) else F.stopRagdollCountdown() end
end
pcall(function() if _G.__VersincRagdollCdCharConn then _G.__VersincRagdollCdCharConn:Disconnect() end end)
_G.__VersincRagdollCdCharConn = LP.CharacterAdded:Connect(function(char)
    if S.ragdollCountdownEnabled then task.wait(0.3); F.hookRagdollCountdown(char) end
end)
_G.VersincMobileButtonRefs = _G.VersincMobileButtonRefs or {}; _G.VersincMobileButtonPositions = _G.VersincMobileButtonPositions or {} function F.saveMobileButtonPositions() _G.VersincMobileButtonPositions = _G.VersincMobileButtonPositions or {} for k, entry in pairs(_G.VersincMobileButtonRefs or {}) do local h = entry and entry.holder if h and h.Parent then local p = h.Position _G.VersincMobileButtonPositions[k] = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset, } end end pcall(function() if F.saveConfig then F.saveConfig(true) end end) end
function F.applyMobileButtonsHidden() local function setEn(g) if g then g.Enabled = not (S.hideMobileButtons == true) end end pcall(function() if gethui then setEn(gethui():FindFirstChild("VyxroDuelMobileButtons")) end end) pcall(function() setEn(game:GetService("CoreGui"):FindFirstChild("VyxroDuelMobileButtons")) end) local pg = LP:FindFirstChild("PlayerGui") if pg then setEn(pg:FindFirstChild("VyxroDuelMobileButtons")) end end function F.applyMobileButtonSize() S.mobileButtonScale = math.clamp(tonumber(S.mobileButtonScale) or 0.80, 0.30, 1.35) for _, entry in pairs(_G.VersincMobileButtonRefs) do
local holder = entry and entry.holder if holder then local sc = holder:FindFirstChild("MobileButtonScale") or Instance.new("UIScale"); sc.Name = "MobileButtonScale"; sc.Scale = S.mobileButtonScale; sc.Parent = holder end end end function F.resetMobileButtons() S.mobileButtonScale = 0.80; S.hideMobileButtons = false; _G.VersincMobileButtonPositions = {}; F.buildMobileButtons(); F.applyMobileButtonSize(); F.applyMobileButtonsHidden() pcall(function() if F.saveConfig then F.saveConfig() end end) end function F.buildMobileButtons() if _G.__VersincBuildingMobile then return end
_G.__VersincBuildingMobile = true if type(_G.__VersincMobileInputConns) == "table" then for _, c in ipairs(_G.__VersincMobileInputConns) do pcall(function() c:Disconnect() end) end end _G.__VersincMobileInputConns = {}; local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 8) if not pg then _G.__VersincBuildingMobile = false; return end pcall(function() local function wipe(parent) if not parent then return end for _, ch in ipairs(parent:GetChildren()) do if ch.Name == "VyxroDuelMobileButtons" then pcall(function() ch:Destroy() end) end end end wipe(pg)
pcall(function() wipe(game:GetService("CoreGui")) end) pcall(function() if type(gethui) == "function" then wipe(gethui()) end end) end) _G.VersincMobileButtonRefs = {} _G.VersincMobileButtonPositions = _G.VersincMobileButtonPositions or {}; local isMobile = false pcall(function() if UIS.TouchEnabled then isMobile = true end end) local cam = workspace.CurrentCamera local vp = cam and cam.ViewportSize or Vector2.new(1280, 720) if vp.X < 900 or vp.Y < 600 then isMobile = true end pcall(function() if UIS.MouseEnabled and UIS.KeyboardEnabled and not UIS.TouchEnabled then isMobile = false end end)
S._isMobileLayout = isMobile local mobileGui = Instance.new("ScreenGui"); mobileGui.Name = "VyxroDuelMobileButtons"; mobileGui.ResetOnSpawn = false; mobileGui.IgnoreGuiInset = true; mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; mobileGui.DisplayOrder = 9999; mobileGui.Enabled = true; local parented = false pcall(function() if gethui then mobileGui.Parent = gethui(); parented = mobileGui.Parent ~= nil end end) if not parented then pcall(function() mobileGui.Parent = game:GetService("CoreGui"); parented = mobileGui.Parent ~= nil end) end if not parented then mobileGui.Parent = pg end
if S.hideMobileButtons ~= true then mobileGui.Enabled = true else mobileGui.Enabled = false end local mobileButtons = _G.VersincMobileButtonRefs local function udimFromSaved(key, default) local store = _G.VersincMobileButtonPositions or {}; local s = store[key] if type(s) ~= "table" then return default end local xs = tonumber(s.xs); local ys = tonumber(s.ys) if xs == nil or ys == nil then return default end local xo = tonumber(s.xo) or 0; local yo = tonumber(s.yo) or 0 return UDim2.new(xs, xo, ys, yo) end local function savePos(key, holder) if not holder then return end
local p = holder.Position; _G.VersincMobileButtonPositions = _G.VersincMobileButtonPositions or {} _G.VersincMobileButtonPositions[key] = { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset, } for k, entry in pairs(_G.VersincMobileButtonRefs or {}) do local h = entry and entry.holder if h and h.Parent then local hp = h.Position _G.VersincMobileButtonPositions[k] = { xs = hp.X.Scale, xo = hp.X.Offset, ys = hp.Y.Scale, yo = hp.Y.Offset, } end end end local function persistMobilePositions() pcall(function() if F.saveConfig then F.saveConfig(true) end end) end
local function getTheme() return S.themeColor or Color3.fromRGB(100, 200, 255) end local FP_INACTIVE_BG   = Color3.fromRGB(0, 0, 0); local FP_INACTIVE_TEXT = Color3.fromRGB(255, 255, 255); local FP_STROKE        = Color3.fromRGB(0, 0, 0); local FP_ACTIVE_BG     = Color3.fromRGB(0, 0, 0); local FP_ACTIVE_TEXT   = Color3.fromRGB(255, 255, 255) local function setActive(btn, state) if not btn or not btn.Parent then return end local pressed = btn:GetAttribute("Pressed") == true; state = (state == true) or pressed; local visual = state and "on" or "off"
if btn:GetAttribute("VisualState") == visual and not pressed then return end btn:SetAttribute("VisualState", visual); local lbl = btn:FindFirstChild("MBLabel"); local st = btn:FindFirstChildOfClass("UIStroke"); local theme = getTheme() if state then btn.BackgroundColor3 = theme; btn.BackgroundTransparency = 0; btn.TextColor3 = FP_ACTIVE_TEXT if lbl then lbl.TextColor3 = FP_ACTIVE_TEXT end if st then st.Color = theme; st.Transparency = 0 end else btn.BackgroundColor3 = FP_INACTIVE_BG; btn.BackgroundTransparency = 0; btn.TextColor3 = FP_INACTIVE_TEXT
if lbl then lbl.TextColor3 = FP_INACTIVE_TEXT end if st then st.Color = theme; st.Transparency = 0.4 end end end _G._VersincApplyMobileTheme = function(col) S.themeColor = col for _, entry in pairs(mobileButtons) do local btn = entry and entry.btn if btn and btn.Parent then local st = btn:GetAttribute("VisualState"); btn:SetAttribute("VisualState", nil); setActive(btn, st == "on") end end end local function refreshAllMobileStates() for key, entry in pairs(mobileButtons) do local btn = entry and entry.btn if btn then local keep = false if key == "autoLeft" then keep = S.autoLeftEnabled == true
elseif key == "autoRight" then keep = S.autoRightEnabled == true elseif key == "aimbot" then keep = tpBatEnabled == true elseif key == "autoBat" then keep = aimbotEnabled == true elseif key == "carry" then keep = S.speedMode == true and not S.laggerToggled elseif key == "lagger" then keep = S.laggerToggled == true and S.laggerPhase == 1 elseif key == "laggerCarry" then keep = S.laggerToggled == true and S.laggerPhase == 2 elseif key == "antitp" then keep = (_G.__AntiTPBatEnabled == true) elseif key == "float" then keep = S.floatEnabled == true end setActive(btn, keep) end end end
_G._VersincRefreshMobileButtons = refreshAllMobileStates local function pulse(btn) if not btn then return end btn:SetAttribute("Pressed", true); setActive(btn, true) task.delay(0.15, function() if btn and btn.Parent then btn:SetAttribute("Pressed", false); refreshAllMobileStates() end end) end local btnW, btnH = 60, 60 local function makeButton(key, label, pos, onPress)
local holder = Instance.new("Frame"); holder.Name = "MBH_" .. key; holder.Size = UDim2.new(0, btnW, 0, btnH); holder.Position = udimFromSaved(key, pos); holder.BackgroundTransparency = 1; holder.ZIndex = 1000; holder.Active = true; holder.Parent = mobileGui; local btn = Instance.new("TextButton"); btn.Name = "MB_" .. key; btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundColor3 = FP_INACTIVE_BG; btn.BackgroundTransparency = 0; btn.BorderSizePixel = 0; btn.Text = ""; btn.TextColor3 = FP_INACTIVE_TEXT; btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.TextWrapped = true; btn.AutoButtonColor = false; pcall(function() btn.Selectable = false; btn.SelectionImageObject = nil end); btn.ZIndex = 1002; btn.Active = true; btn.Selectable = false; pcall(function() btn.SelectionImageObject = nil end); btn.ClipsDescendants = true; btn:SetAttribute("ThemeMobile", true); btn.Parent = holder; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18); local stroke = Instance.new("UIStroke", btn); stroke.Color = FP_STROKE; stroke.Thickness = 1.2; stroke.Transparency = 0.4; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; local strokeGrad = Instance.new("UIGradient"); strokeGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(0.22, Color3.fromRGB(220, 220, 220)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(0.78, Color3.fromRGB(220, 220, 220)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)), }); strokeGrad.Rotation = 0; strokeGrad.Parent = stroke; local _btnGradRot = 0; local _btnGradConn = game:GetService("RunService").RenderStepped:Connect(function(dt) if not stroke.Parent then _btnGradConn:Disconnect() return end _btnGradRot = (_btnGradRot + (dt or 0.016) * 52) % 360; strokeGrad.Rotation = _btnGradRot end); local blabel = Instance.new("TextLabel", btn); pcall(function() if _G.__VxyroGlossAttach then _G.__VxyroGlossAttach(btn, {z=1002, radius=18, thickness=1.35, bloomThickness=5.0}) end end); blabel.Name = "MBLabel"; blabel.Size = UDim2.new(1, 0, 1, 0); blabel.BackgroundTransparency = 1; blabel.Text = label; blabel.TextColor3 = FP_INACTIVE_TEXT; blabel.Font = Enum.Font.GothamBold; blabel.TextSize = 10; blabel.TextWrapped = true; blabel.ZIndex = 1003; local pressing, dragging = false, false; local pressPos, holderStart = nil, nil; local fired = false
local function fireAction() if fired then return end fired = true pcall(function() if onPress then onPress(btn) end end) task.defer(refreshAllMobileStates) task.delay(0.25, function() fired = false end) end local clickStrokeTween, clickScaleTween, releaseScaleTween
local function getClickScale()
    local sc = btn:FindFirstChild("BDClickScale")
    if not sc then
        sc = Instance.new("UIScale")
        sc.Name = "BDClickScale"
        sc.Scale = 1
        sc.Parent = btn
    end
    return sc
end
local function stopClickTween(tw)
    pcall(function() if tw then tw:Cancel() end end)
end
local function beginPress(input)
    pressing = true; dragging = false; fired = false; pressPos = input.Position; holderStart = holder.Position
    btn:SetAttribute("Pressed", true); setActive(btn, true)

    pcall(function()
        stopClickTween(clickStrokeTween)
        stopClickTween(releaseScaleTween)
        local accent = getTheme()
        local strokeFx = btn:FindFirstChild("BtnStroke") or btn:FindFirstChildOfClass("UIStroke")
        if strokeFx then
            clickStrokeTween = TS:Create(strokeFx, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 3.2, Transparency = 0.0,
            })
            clickStrokeTween:Play()
        end

        local oldRipple = btn:FindFirstChild("BtnRipple")
        if oldRipple then oldRipple:Destroy() end

        local ripple = Instance.new("Frame")
        ripple.Name = "BtnRipple"
        ripple.BackgroundColor3 = accent
        ripple.BackgroundTransparency = 0.45
        ripple.BorderSizePixel = 0
        ripple.ZIndex = btn.ZIndex + 1
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.ClipsDescendants = true
        ripple.Parent = btn
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(1, 0)
        rc.Parent = ripple

        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.2
        local rippleTween = TS:Create(ripple, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, sz, 0, sz), BackgroundTransparency = 1,
        })
        rippleTween:Play()
        task.delay(0.40, function()
            if ripple and ripple.Parent then ripple:Destroy() end
        end)
    end)

    pcall(function()
        stopClickTween(clickScaleTween)
        local sc = getClickScale()
        clickScaleTween = TS:Create(sc, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Scale = 0.91,
        })
        clickScaleTween:Play()
    end)
end
local function endPress()
    if not pressing then return end
    if not dragging then fireAction() end
    if dragging then savePos(key, holder); persistMobilePositions() end

    pcall(function()
        stopClickTween(clickStrokeTween)
        local isOn = btn:GetAttribute("VisualState") == "on"
        local strokeFx = btn:FindFirstChild("BtnStroke") or btn:FindFirstChildOfClass("UIStroke")
        if strokeFx then
            clickStrokeTween = TS:Create(strokeFx, TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Thickness = isOn and 2 or 1.4, Transparency = 0.15,
            })
            clickStrokeTween:Play()
        end
    end)

    pcall(function()
        stopClickTween(clickScaleTween)
        stopClickTween(releaseScaleTween)
        local sc = btn:FindFirstChild("BDClickScale")
        if sc then
            releaseScaleTween = TS:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Scale = 1.015,
            })
            releaseScaleTween:Play()
            task.delay(0.28, function()
                if sc and sc.Parent then
                    stopClickTween(releaseScaleTween)
                    releaseScaleTween = TS:Create(sc, TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        Scale = 1.0,
                    })
                    releaseScaleTween:Play()
                end
            end)
        end
    end)

    pressing = false; dragging = false; btn:SetAttribute("Pressed", false)
    task.delay(0.05, refreshAllMobileStates)
end
btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then beginPress(input) end end) local function track(conn) if conn then _G.__VersincMobileInputConns = _G.__VersincMobileInputConns or {}; table.insert(_G.__VersincMobileInputConns, conn) end return conn end track(UIS.InputEnded:Connect(function(input) if not pressing then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then endPress() end end)) local groupStart = nil track(UIS.InputChanged:Connect(function(input) if not pressing then groupStart = nil; return end if S.moveButtons ~= true and S.allLockButtons ~= true then return end if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end if not pressPos then return end local delta = input.Position - pressPos; local thresh = isMobile and 18 or 8
if not dragging and (math.abs(delta.X) > thresh or math.abs(delta.Y) > thresh) then dragging = true if S.allLockButtons == true then groupStart = {} for k, entry in pairs(_G.VersincMobileButtonRefs or {}) do local h = entry and entry.holder if h and h.Parent then groupStart[k] = h.Position end end end end if dragging then if S.allLockButtons == true and groupStart then for k, startPos in pairs(groupStart) do local entry = (_G.VersincMobileButtonRefs or {})[k] local h = entry and entry.holder if h and h.Parent then h.Position = UDim2.new( startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y ) end end elseif holderStart then holder.Position = UDim2.new( holderStart.X.Scale, holderStart.X.Offset + delta.X, holderStart.Y.Scale, holderStart.Y.Offset + delta.Y ) end end end)) btn.Activated:Connect(function() if dragging then return end if pressing then endPress() else fireAction() end end) mobileButtons[key] = {holder = holder, btn = btn, setActive = function(state) setActive(btn, state) end} setActive(btn, false) return btn end local defaults do
local GAP_X, GAP_Y = 8, 14; local MARGIN_R = isMobile and 12 or 18; local totalW = btnW * 3 + GAP_X * 2 local col = { -(totalW + MARGIN_R), -(totalW + MARGIN_R) + (btnW + GAP_X), -(totalW + MARGIN_R) + 2 * (btnW + GAP_X), } local ROWS = 4 local function slot(c, r) return UDim2.new(1, col[c], 0.5, -((ROWS * (btnH + GAP_Y)) / 2) + (r - 1) * (btnH + GAP_Y)) end defaults = { antitp      = slot(1, 1), drop        = slot(2, 1), autoLeft    = slot(3, 1), aimbot      = slot(1, 2), autoBat     = slot(2, 2), autoRight   = slot(3, 2), tp          = slot(2, 3), carry       = slot(3, 3),
laggerCarry = slot(2, 4), lagger      = slot(3, 4), float       = slot(1, 4), } end makeButton("antitp", "ANTI\nTP BAT", defaults.antitp, function() if AntiTPBat and AntiTPBat.toggle then local _r = AntiTPBat.toggle() pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Anti TP Bat", _r == true) end end) end end) makeButton("drop", "DROP\nBR", defaults.drop, function(btn) if F.runDrop then F.runDrop() end pulse(btn) end) makeButton("autoLeft", "AUTO\nLEFT", defaults.autoLeft, function() if S.autoLeftEnabled then S.autoLeftEnabled = false if F.stopAutoLeft then F.stopAutoLeft() end if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Auto Left", false) end end) else if F.queueAutoLeftStart then F.queueAutoLeftStart() end pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Auto Left", S.autoLeftEnabled == true) end end)
if S.autoLeftSetVisual then S.autoLeftSetVisual(S.autoLeftEnabled == true) end end end) makeButton("autoBat", "BAT\nAIMBOT", defaults.autoBat, function() if F.safeModeTryStart and not F.safeModeTryStart() then return end if setAimbotState then setAimbotState(not aimbotEnabled) end end) makeButton("aimbot", "TP\nBAT", defaults.aimbot, function() if F.safeModeTryStart and not F.safeModeTryStart() then return end
if setTPBatState then setTPBatState(not tpBatEnabled) end if VS.setTPBatVisual then VS.setTPBatVisual(tpBatEnabled) end pcall(function() if _G.VersincRefreshMobileStates then _G.VersincRefreshMobileStates() end end) end) makeButton("autoRight", "AUTO\nRIGHT", defaults.autoRight, function() if S.autoRightEnabled then S.autoRightEnabled = false if F.stopAutoRight then F.stopAutoRight() end if S.autoRightSetVisual then S.autoRightSetVisual(false) end pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Auto Right", false) end end) else if F.queueAutoRightStart then F.queueAutoRightStart() end if S.autoRightSetVisual then S.autoRightSetVisual(S.autoRightEnabled == true) end pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Auto Right", S.autoRightEnabled == true) end end) end end) makeButton("tp", "TP\nDOWN", defaults.tp, function(btn) if F.runTPFloor then F.runTPFloor() end
pulse(btn) end) makeButton("carry", "CARRY\nSPD", defaults.carry, function() if F.toggleCarryMode then F.toggleCarryMode() end if F.refreshSpeedModeLabel then F.refreshSpeedModeLabel() end pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Carry Speed", S.speedMode == true) end end) end) makeButton("lagger", "LAGGER\nMODE", defaults.lagger, function() if S.laggerToggled and S.laggerPhase == 1 then S.laggerToggled = false; S.laggerPhase = 0 else S.speedMode = false; S.laggerToggled = true; S.laggerPhase = 1 end if F.refreshSpeedModeLabel then F.refreshSpeedModeLabel() end pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Lagger Mode", S.laggerToggled == true) end end) end) makeButton("laggerCarry", "LAGGER\nCARRY", defaults.laggerCarry, function()
if S.laggerToggled and S.laggerPhase == 2 then S.laggerToggled = false; S.laggerPhase = 0 else S.speedMode = false; S.laggerToggled = true; S.laggerPhase = 2 end if F.refreshSpeedModeLabel then F.refreshSpeedModeLabel() end end) makeButton("float", "FLOAT", defaults.float, function(btn) F.toggleFloat(); pulse(btn); pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Float", S.floatEnabled == true) end end) end) F.applyMobileButtonSize(); F.applyMobileButtonsHidden() task.defer(function() refreshAllMobileStates() if S.themeColor and _G._VersincApplyMobileTheme then pcall(function() _G._VersincApplyMobileTheme(S.themeColor) end) end end)
-- [FIX] Sync visual state dos botoes (Auto Left / Auto Right e afins) quando a funcao para sozinha
local function _fpStateSig() return tostring(S.floatEnabled == true) .. tostring(aimbotEnabled == true) .. tostring(vasperAimbotEnabled == true) .. tostring(S.autoLeftEnabled == true) .. tostring(S.autoRightEnabled == true) .. tostring(S.autoBatEnabled == true) .. tostring(tpBatEnabled == true) .. tostring(_G.__AntiTPBatEnabled == true) .. tostring(S.speedMode == true) .. tostring(S.laggerToggled == true) .. tostring(S.laggerPhase) end
if _G.__VersincVisualSyncLoop then _G.__VersincVisualSyncLoop = false end
_G.__VersincVisualSyncLoop = true
_G.__VersincRefreshMobileStates = refreshAllMobileStates
task.spawn(function()
  local last = nil
  while _G.__VersincVisualSyncLoop do
    local ok, sig = pcall(_fpStateSig)
    if ok and sig ~= last then
      last = sig
      pcall(refreshAllMobileStates)
      pcall(function()
        if S.autoLeftSetVisual then S.autoLeftSetVisual(S.autoLeftEnabled == true) end
        if S.autoRightSetVisual then S.autoRightSetVisual(S.autoRightEnabled == true) end
        if S.autoBatSetVisual then S.autoBatSetVisual(S.autoBatEnabled == true) end
        if VS and VS.setAimbotVisual then VS.setAimbotVisual(aimbotEnabled == true) end
        if VS and VS.setTPBatVisual then pcall(VS.setTPBatVisual, tpBatEnabled == true) end
      end)
    end
    task.wait(0.1)
  end
end)
_G.__VersincBuildingMobile = false end -- [FEATURESAVE] Dedicated persistence for imported features.
local FEATURE_DEFAULTS = {
    customToolsEnabled = false,
    customSoundsEnabled = false,
    customToolSkinBat = "DiamondSword",
    customToolSkinMedusa = "GoldenDesertEagle",
    vividGraphicsEnabled = false,
    vividSettings = { saturation = 0.6, bloomIntensity = 0.8, bloomSize = 24, sunIntensity = 0.2, dofFocus = 25 },
    motionBlurEnabled = false,
}
local function featureSnapshot()
    local v = type(S.vividSettings) == "table" and S.vividSettings or FEATURE_DEFAULTS.vividSettings
    return {
        version = 2,
        customToolsEnabled = S.customToolsEnabled == true,
        customSoundsEnabled = S.customSoundsEnabled == true,
        customToolSkinBat = tostring(S.customToolSkinBat or FEATURE_DEFAULTS.customToolSkinBat),
        customToolSkinMedusa = tostring(S.customToolSkinMedusa or FEATURE_DEFAULTS.customToolSkinMedusa),
        vividGraphicsEnabled = S.vividGraphicsEnabled == true,
        vividSettings = {
            saturation = math.clamp(tonumber(v.saturation) or 0.6, 0, 2),
            bloomIntensity = math.clamp(tonumber(v.bloomIntensity) or 0.8, 0, 3),
            bloomSize = math.clamp(tonumber(v.bloomSize) or 24, 1, 56),
            sunIntensity = math.clamp(tonumber(v.sunIntensity) or 0.2, 0, 1),
            dofFocus = math.clamp(tonumber(v.dofFocus) or 25, 1, 100),
        },
        motionBlurEnabled = S.motionBlurEnabled == true,
    }
end
function F.saveFeatureConfig()
    if not __VXYRO_IS_CURRENT_RUN() then return false end
    if not _writefile then return false end
    local snapshot = featureSnapshot()
    local encoded
    local okEncode = pcall(function() encoded = HS:JSONEncode(snapshot) end)
    if not okEncode or type(encoded) ~= "string" or encoded == "" then return false end
    local okWrite = pcall(function() _writefile(FEATURE_CONFIG_FILE, encoded) end)
    if not okWrite then return false end
    if _readfile then
        local okRead, raw = pcall(_readfile, FEATURE_CONFIG_FILE)
        if not okRead or type(raw) ~= "string" or raw == "" then return false end
        local okDecode, decoded = pcall(function() return HS:JSONDecode(raw) end)
        if not okDecode or type(decoded) ~= "table" then return false end
        if decoded.customToolsEnabled ~= snapshot.customToolsEnabled
            or decoded.customSoundsEnabled ~= snapshot.customSoundsEnabled
            or decoded.customToolSkinBat ~= snapshot.customToolSkinBat
            or decoded.customToolSkinMedusa ~= snapshot.customToolSkinMedusa
            or decoded.vividGraphicsEnabled ~= snapshot.vividGraphicsEnabled
            or decoded.motionBlurEnabled ~= snapshot.motionBlurEnabled then
            return false
        end
    end
    return true
end
function F.loadFeatureConfig()
    if type(_savedCfg) == "table" and type(_savedCfg.features) == "table" then
        local fcfg = _savedCfg.features
        S.customToolsEnabled = fcfg.customToolsEnabled == true
        S.customSoundsEnabled = fcfg.customSoundsEnabled == true
        S.customToolSkinBat = tostring(fcfg.customToolSkinBat or FEATURE_DEFAULTS.customToolSkinBat)
        S.customToolSkinMedusa = tostring(fcfg.customToolSkinMedusa or FEATURE_DEFAULTS.customToolSkinMedusa)
        S.vividGraphicsEnabled = fcfg.vividGraphicsEnabled == true
        local v = type(fcfg.vividSettings) == "table" and fcfg.vividSettings or FEATURE_DEFAULTS.vividSettings
        S.vividSettings = {
            saturation = math.clamp(tonumber(v.saturation) or 0.6, 0, 2),
            bloomIntensity = math.clamp(tonumber(v.bloomIntensity) or 0.8, 0, 3),
            bloomSize = math.clamp(tonumber(v.bloomSize) or 24, 1, 56),
            sunIntensity = math.clamp(tonumber(v.sunIntensity) or 0.2, 0, 1),
            dofFocus = math.clamp(tonumber(v.dofFocus) or 25, 1, 100),
        }
        S.motionBlurEnabled = fcfg.motionBlurEnabled == true
        return true
    end
    if not _readfile then return false end
    local raw; local okRead = pcall(function() raw = _readfile(FEATURE_CONFIG_FILE) end)
    if not okRead or type(raw) ~= "string" or raw == "" then return false end
    local ok, cfg = pcall(function() return HS:JSONDecode(raw) end)
    if not ok or type(cfg) ~= "table" then return false end
    local fcfg = type(cfg.features) == "table" and cfg.features or cfg
    S.customToolsEnabled = fcfg.customToolsEnabled == true
    S.customSoundsEnabled = fcfg.customSoundsEnabled == true
    S.customToolSkinBat = tostring(fcfg.customToolSkinBat or FEATURE_DEFAULTS.customToolSkinBat)
    S.customToolSkinMedusa = tostring(fcfg.customToolSkinMedusa or FEATURE_DEFAULTS.customToolSkinMedusa)
    S.vividGraphicsEnabled = fcfg.vividGraphicsEnabled == true
    local v = type(fcfg.vividSettings) == "table" and fcfg.vividSettings or FEATURE_DEFAULTS.vividSettings
    S.vividSettings = {
        saturation = math.clamp(tonumber(v.saturation) or 0.6, 0, 2),
        bloomIntensity = math.clamp(tonumber(v.bloomIntensity) or 0.8, 0, 3),
        bloomSize = math.clamp(tonumber(v.bloomSize) or 24, 1, 56),
        sunIntensity = math.clamp(tonumber(v.sunIntensity) or 0.2, 0, 1),
        dofFocus = math.clamp(tonumber(v.dofFocus) or 25, 1, 100),
    }
    S.motionBlurEnabled = fcfg.motionBlurEnabled == true
    _savedCfg = _savedCfg or {}
    _savedCfg.features = fcfg
    return true
end
function F.saveFeatureConfigAndMain()
    if not __VXYRO_IS_CURRENT_RUN() then return false end
    return F.saveConfig(true)
end

function F.saveConfig(force)
    if not __VXYRO_IS_CURRENT_RUN() then return false end
    if not _writefile then S._lastSaveOk = false if UI and UI.saveStatusLbl then UI.saveStatusLbl.Text = "Save: no writefile"; UI.saveStatusLbl.TextColor3 = Color3.fromRGB(255, 120, 120) end return false end local ok, err = pcall(function() local function ks(e) if type(e) ~= "table" then return {kb=nil,gp=nil} end return {kb = e.kb and e.kb.Name or nil, gp = e.gp and e.gp.Name or nil} end local function numFromBox(box, fallback) if box and box.Text then local n = tonumber(box.Text) if n then return n end end return fallback end
if UI then local v v = numFromBox(UI.radInput, nil) if v and v > 0 then autoStealRadius = v; Steal.StealRadius = v end v = numFromBox(UI.stealDurInput, nil) if v and v >= 0.1 then Steal.StealDuration = v end v = numFromBox(UI.stopTimeInput, nil) if v and v > 0 then autoGrabStopTime = v; Steal.AutoGrabStopTime = v end v = numFromBox(UI.delayRadInput, nil) if v and v > 0 then autoGrabDelayRadius = v; Steal.AutoGrabDelayRadius = v end v = numFromBox(UI.normalBox, nil) if v and v > 0 then NS = v end v = numFromBox(UI.carryBox, nil) if v and v > 0 then CS = v end v = numFromBox(UI.laggerBox, nil)
if v and v > 0 then S.LAGGER_SPEED = v end v = numFromBox(UI.laggerCarryBox, nil) if v and v > 0 then S.LAGGER_CARRY_SPEED = v end v = numFromBox(UI.autoTPHeightBox, nil) if v then S.autoTPHeight = v end end
local stealRad = tonumber(autoStealRadius) or (Steal and Steal.StealRadius) or 20; local stealDur = (Steal and tonumber(Steal.StealDuration)) or 1.3; local stopT = tonumber(autoGrabStopTime) or (Steal and tonumber(Steal.AutoGrabStopTime)) or 1.00; local delayR = tonumber(autoGrabDelayRadius) or (Steal and tonumber(Steal.AutoGrabDelayRadius)) or 8; autoGrabStopTime = stopT; autoGrabDelayRadius = delayR if Steal then
Steal.StealRadius = stealRad; Steal.StealDuration = stealDur; Steal.AutoGrabStopTime = stopT; Steal.AutoGrabDelayRadius = delayR; Steal.AutoGrabStopEnabled = autoGrabStopEnabled == true end -- [FEATURESAVE] S is the shared authoritative runtime state.
if type(S.vividSettings) ~= "table" then
    S.vividSettings = { saturation=0.6, bloomIntensity=0.8, bloomSize=24, sunIntensity=0.2, dofFocus=25 }
end
local cfg = { normalSpeed = NS, carrySpeed = CS, dropBrainrotKey = ks(KB.DropBrainrot), autoLeftKey = ks(KB.AutoLeft), autoRightKey = ks(KB.AutoRight), autoBatKey = ks(KB.AutoBat), tpBatKey = ks(KB.TPBat), laggerToggleKey = ks(KB.LaggerToggle), tpFloorKey = ks(KB.TPFloor), instaResetKey = ks(KB.InstaReset), guiHideKey = ks(KB.GuiHide), speedToggleKey = ks(KB.SpeedToggle),
grabRadius = stealRad, stealDuration = stealDur, selectedStealMode = selectedStealMode, aceStealRadii = AceStealRadii and { Normal = AceStealRadii.Normal, Semi = AceStealRadii.Semi } or nil, autoGrabStopEnabled = autoGrabStopEnabled == true, autoGrabStopTime = stopT, autoGrabDelayRadius = delayR, antiRagdollMode = S.antiRagdollMode or 1, aimbotMode = S.aimbotMode or 1, antiRagdoll = S.antiRagdollEnabled, antiDieEnabled = S.antiDieEnabled, antiFlingShieldEnabled = S.antiFlingShieldEnabled, removeAccessories = S.removeAccessoriesEnabled, autoStealEnabled = autoStealEnabled,
medusaCounter = S.medusaCounterEnabled, medusaReset = S.medusaResetEnabled, batCounter = S.batCounterEnabled, infJump = infJumpEnabled, aimbot = aimbotEnabled, tpBat = tpBatEnabled, antiBatBypass = S.antiBatBypassEnabled == true or antiBatBypassLockEnabled == true, aimbotSpeed = AIMBOT_SPEED or 63, autoLeft = S.autoLeftEnabled == true, autoRight = S.autoRightEnabled == true, tpBatMode = 1, combatMode = (function()
    local m = _G.__VxyroCombatMode
    if m == "aimbot" and not (aimbotEnabled == true or vasperAimbotEnabled == true) then m = nil end
    if m == "tpBat" and not (tpBatEnabled == true) then m = nil end
    if m == "autoLeft" and not (S.autoLeftEnabled == true) then m = nil end
    if m == "autoRight" and not (S.autoRightEnabled == true) then m = nil end
    if m == "autoBat" and not (S.autoBatEnabled == true) then m = nil end
    if not m then
        if tpBatEnabled then m = "tpBat"
        elseif S.autoRightEnabled then m = "autoRight"
        elseif S.autoLeftEnabled then m = "autoLeft"
        elseif aimbotEnabled or vasperAimbotEnabled then m = "aimbot"
        elseif S.autoBatEnabled then m = "autoBat"
        else m = "none" end
    end
    return m
end)(), tpBatLegacyKey = (TP_BAT_KEY and TP_BAT_KEY.Name) or "V", carryMode = S.speedMode, laggerMode = S.laggerToggled, laggerCarryMode = S.laggerPhase == 2, autoCarrySpeedEnabled = S.autoCarrySpeedEnabled,
noPlayerCollisionEnabled = S.noPlayerCollisionEnabled, safeModeEnabled = S.safeModeEnabled, autoResetOnMedEnabled = S.autoResetOnMedEnabled, laggerSpeed = S.LAGGER_SPEED, laggerCarrySpeed = S.LAGGER_CARRY_SPEED, autoBat = S.autoBatEnabled, autoSwing = S.autoSwingEnabled, unwalkEnabled = S.unwalkEnabled, antiLag = S.antiLagEnabled, keyboardOverlay = S.keyboardOverlayEnabled == true, stretchRez = S.stretchRezEnabled, autoTPEnabled = S.autoTPEnabled, autoTPHeight = S.autoTPHeight, nukeOptimizer = (_G._NukeOn == true), skyTheme = K7 and K7.currentSkyTheme or nil, fovEnabled = K7 and K7.fovEnabled or false,
fovValue = (K7 and K7.fovValue) or (_G._VezyFOV) or 70, headless = K7 and K7.headlessEnabled or false, korbloxSide = korbloxSide or (K7 and K7.korbloxSide) or 1, korblox = K7 and K7.korbloxEnabled or false, bodyLock = K7 and K7.bodyLockEnabled or false, bodyLockRadius = K7 and K7.bodyLockRadius or 60, lineESP = K7 and K7.lineESPEnabled or false, speedESP = K7 and K7.speedESPEnabled or false, animPackEnabled = K7 and K7.animPackEnabled or false, animPack = K7 and K7.animPackName or nil, animPackIndex = K7 and K7.animPackIndex or 1,
guiScale = (_G._VersincGetGuiScale and _G._VersincGetGuiScale()) or 1, themeName = S.currentThemeName or currentThemeName or "WHITE", bgId = S.currentBgId or "", bgIntensity = S.bgIntensity or 0.58, backgroundPhotoEnabled = S.backgroundPhotoEnabled ~= false, spaceBgIndex = math.clamp(math.floor(tonumber(S.spaceBgIndex) or 1), 1, 6), floatEnabled = S.floatEnabled == true, floatHeight = math.clamp(tonumber(S.floatHeight) or 18, 4, 80), floatSpeed = math.clamp(tonumber(S.floatSpeed) or 10, 2, 30), autoSaveEnabled = S.autoSaveEnabled, showTracerEnabled = S.showTracerEnabled, ragdollCountdownEnabled = S.ragdollCountdownEnabled, toggleNotifEnabled = (S.toggleNotifEnabled ~= false), guiLocked = S.guiLocked, hubPos = S.hubPos, miniPos = S.miniPos, hideMobileButtons = S.hideMobileButtons, lockMobileButtons = S.lockMobileButtons == true, allLockButtons = S.allLockButtons == true, moveButtons = S.moveButtons == true,
progressBarScale = S.progressBarScale or 100, stealBarPos = S.stealBarPos, keyboardOverlay = S.keyboardOverlayEnabled == true, mobileButtonScale = S.mobileButtonScale, infJumpMode = S.infJumpMode or "hold", mirrorTPDown = S.mirrorTPDownEnabled == true, mobileButtonPositions = _G.VersincMobileButtonPositions,
avatarChanger = S.avatarChanger, avaPresetEnabled = S.avaPresetEnabled == true, avaPresetName = S.avaPresetName or "PURPLE", customToolsEnabled = S.customToolsEnabled == true, customSoundsEnabled = S.customSoundsEnabled == true, customToolSkinBat = S.customToolSkinBat or "DiamondSword", customToolSkinMedusa = S.customToolSkinMedusa or "GoldenDesertEagle", customFontSelected = _G.VxyroCustomFontSelected or _G.AmbitiousFontChoice or "Default", customFontEnabled = _G.VxyroCustomFontEnabled == true, vividGraphicsEnabled = S.vividGraphicsEnabled == true, vividSettings = { saturation = tonumber(S.vividSettings and S.vividSettings.saturation) or 0.6, bloomIntensity = tonumber(S.vividSettings and S.vividSettings.bloomIntensity) or 0.8, bloomSize = tonumber(S.vividSettings and S.vividSettings.bloomSize) or 24, sunIntensity = tonumber(S.vividSettings and S.vividSettings.sunIntensity) or 0.2, dofFocus = tonumber(S.vividSettings and S.vividSettings.dofFocus) or 25 }, motionBlurEnabled = S.motionBlurEnabled == true,
features = { customToolsEnabled = S.customToolsEnabled == true, customSoundsEnabled = S.customSoundsEnabled == true, customToolSkinBat = S.customToolSkinBat or "DiamondSword", customToolSkinMedusa = S.customToolSkinMedusa or "GoldenDesertEagle", vividGraphicsEnabled = S.vividGraphicsEnabled == true, vividSettings = { saturation = tonumber(S.vividSettings and S.vividSettings.saturation) or 0.6, bloomIntensity = tonumber(S.vividSettings and S.vividSettings.bloomIntensity) or 0.8, bloomSize = tonumber(S.vividSettings and S.vividSettings.bloomSize) or 24, sunIntensity = tonumber(S.vividSettings and S.vividSettings.sunIntensity) or 0.2, dofFocus = tonumber(S.vividSettings and S.vividSettings.dofFocus) or 25 }, motionBlurEnabled = S.motionBlurEnabled == true },
} local encoded = HS:JSONEncode(cfg) _writefile(CONFIG_FILE, encoded)
local verifyOK = true
if _readfile then
    local rok, rraw = pcall(_readfile, CONFIG_FILE)
    verifyOK = rok and type(rraw) == "string" and rraw ~= ""
    if verifyOK then
        local dok, dcfg = pcall(function() return HS:JSONDecode(rraw) end)
        verifyOK = dok and type(dcfg) == "table"
        if verifyOK then
            local f = type(dcfg.features) == "table" and dcfg.features or dcfg
            local snap = featureSnapshot()
            verifyOK = (f.customToolsEnabled == snap.customToolsEnabled)
                and (f.customSoundsEnabled == snap.customSoundsEnabled)
                and (f.customToolSkinBat == snap.customToolSkinBat)
                and (f.customToolSkinMedusa == snap.customToolSkinMedusa)
                and (f.vividGraphicsEnabled == snap.vividGraphicsEnabled)
                and (f.motionBlurEnabled == snap.motionBlurEnabled)
        end
    end
end
if not verifyOK then error("config write verification failed") end
pcall(function() _writefile(CONFIG_FILE_LEGACY, encoded) end)
local featureSnapshotNow = featureSnapshot()
local featureEncoded = HS:JSONEncode(featureSnapshotNow)
local featureWriteOK = pcall(function() _writefile(FEATURE_CONFIG_FILE, featureEncoded) end)
if featureWriteOK and _readfile then
    local fok, fraw = pcall(_readfile, FEATURE_CONFIG_FILE)
    if not fok or type(fraw) ~= "string" or fraw == "" then featureWriteOK = false end
end
if not featureWriteOK then error("feature config write verification failed") end
end) S._lastSaveOk = ok and true or false S._lastSaveAt = tick() if UI and UI.saveStatusLbl then if ok then
UI.saveStatusLbl.Text = "Saved OK"; UI.saveStatusLbl.TextColor3 = Color3.fromRGB(100, 220, 160) else UI.saveStatusLbl.Text = "Save failed"; UI.saveStatusLbl.TextColor3 = Color3.fromRGB(255, 120, 120); warn("[Vyxro Duel] F.saveConfig error:", err) end end return ok end task.spawn(function() while true do task.wait(5) if S.autoSaveEnabled ~= false then pcall(function() F.saveConfig(true) end) end end end) local CONFIG_EXPORT_FILE = "VyxroDuel_Export.json"
local CONFIG_IMPORT_FILE = "VyxroDuel_Import.json"; local _setclipboard = setclipboard or toclipboard or (syn and syn.write_clipboard); local _getclipboard = getclipboard or (syn and syn.read_clipboard) function F.saveMobileButtonsOnly() if not _writefile then return false end local ok = pcall(function() local raw = nil if _isfile(CONFIG_FILE) then pcall(function() raw = _readfile(CONFIG_FILE) end) end local cfg = {} if raw and raw ~= "" then pcall(function() cfg = HS:JSONDecode(raw) or {} end) end if type(cfg) ~= "table" then cfg = {} end
cfg.mobileButtonPositions = _G.VersincMobileButtonPositions or cfg.mobileButtonPositions; cfg.mobileButtonScale = S.mobileButtonScale; cfg.hideMobileButtons = S.hideMobileButtons == true; cfg.lockMobileButtons = S.lockMobileButtons == true; cfg.allLockButtons = S.allLockButtons == true; cfg.moveButtons = S.moveButtons == true; cfg.progressBarScale = S.progressBarScale or 100; _writefile(CONFIG_FILE, HS:JSONEncode(cfg)) end) return ok == true end function F.exportConfig() local okSnap = pcall(function() if F.saveConfig then F.saveConfig(true) end end) local raw = nil
if _isfile(CONFIG_FILE) then pcall(function() raw = _readfile(CONFIG_FILE) end) end if not raw or raw == "" then return false, "no_config" end pcall(function() _writefile(CONFIG_EXPORT_FILE, raw) end) local copied = false if _setclipboard then copied = pcall(_setclipboard, raw) end return true, copied and "copied_and_exported" or "exported_to_file" end function F.importConfig(pastedText) local raw = tostring(pastedText or ""):match("^%s*(.-)%s*$") or "" if raw == "" and _getclipboard then local clipOk, clip = pcall(_getclipboard)
if clipOk and type(clip) == "string" then raw = clip:match("^%s*(.-)%s*$") or "" end end if raw == "" and _isfile(CONFIG_IMPORT_FILE) then pcall(function() raw = tostring(_readfile(CONFIG_IMPORT_FILE) or ""):match("^%s*(.-)%s*$") or "" end) end if raw == "" then return false, "empty" end local valid, decoded = pcall(function() return HS:JSONDecode(raw) end) if not valid or type(decoded) ~= "table" then return false, "invalid_json" end local encodedOk, normalized = pcall(function() return HS:JSONEncode(decoded) end) if not encodedOk then return false, "encode_failed" end
pcall(function() _writefile(CONFIG_FILE, normalized) end) _savedCfg = decoded pcall(function() if F.loadConfigKeys then F.loadConfigKeys() end if F.loadConfigState then F.loadConfigState() end end) return true, "imported" end function F.resetAllConfig() pcall(function() if _G.VxyroImportedFeaturesReset then _G.VxyroImportedFeaturesReset() end end) S.customToolsEnabled=false; S.customSoundsEnabled=false; S.customToolSkinBat="DiamondSword"; S.customToolSkinMedusa="GoldenDesertEagle"; _G.VxyroCustomFontSelected="Default"; _G.VxyroCustomFontEnabled=false; if _G.AmbitiousFonts and _G.AmbitiousFonts.set then pcall(function() _G.AmbitiousFonts.set("Default", true) end) end; if _G._VxyroImportedMusicClose then pcall(_G._VxyroImportedMusicClose) end; S.vividGraphicsEnabled=false; S.motionBlurEnabled=false; S.vividSettings={saturation=0.6,bloomIntensity=0.8,bloomSize=24,sunIntensity=0.2,dofFocus=25}; S.avatarChanger={} pcall(function() if _G._nukeStop then _G._nukeStop() end end) _G.__VxyroNukeOptimizerConfigWanted = false pcall(function() if VS and VS.setNukeOptimizerVisual then VS.setNukeOptimizerVisual(false) end end) pcall(function() if S.antiRagdollEnabled then S.antiRagdollEnabled=false; F.stopAntiRagdoll() end end) pcall(function() if infJumpEnabled then infJumpEnabled=false; F.stopInfJump() end end) pcall(function() if tpBatEnabled and setTPBatState then setTPBatState(false) end end)
pcall(function() if aimbotEnabled and setAimbotState then setAimbotState(false) end end) pcall(function() if S.autoBatEnabled and S.disableAutoBat then S.autoBatEnabled=false; S.disableAutoBat() end end) pcall(function() if S.laggerToggled then S.laggerToggled=false; S.laggerPhase=0 end end) pcall(function() if S.speedMode then S.speedMode=false end end) pcall(function() if S.autoTPEnabled and F.stopAutoTP then F.stopAutoTP() end end) pcall(function() if S.unwalkEnabled and F.stopUnwalk then S.unwalkEnabled=false; F.stopUnwalk() end end)
pcall(function() if S.antiLagEnabled and F.disableAntiLag then F.disableAntiLag() end end) pcall(function() if F.stopKeyboardOverlay then F.stopKeyboardOverlay() end end) pcall(function() if S.stretchRezEnabled and disableStretchRez then disableStretchRez() end end) pcall(function() if S.showTracerEnabled and F.setShowTracer then F.setShowTracer(false) end end) pcall(function() if S.ragdollCountdownEnabled and F.setRagdollCountdown then F.setRagdollCountdown(false) end end) pcall(function() if S.noPlayerCollisionEnabled and F.disableNoPlayerCollision then F.disableNoPlayerCollision() end end)
pcall(function() if autoStealEnabled and stopAutoSteal then stopAutoSteal() end end) pcall(function() if S.batCounterEnabled and S.stopBatCounter then S.batCounterEnabled=false; S.stopBatCounter() end end) pcall(function() if S.medusaCounterEnabled or S.medusaResetEnabled then S.medusaCounterEnabled=false; S.medusaResetEnabled=false end end) pcall(function() if S.autoResetOnMedEnabled and F.setAutoResetOnMed then F.setAutoResetOnMed(false) end end)
NS, CS = 60, 30; S.NS, S.CS = 60, 30; S.floatEnabled = false; S.floatHeight = 18; S.floatSpeed = 10; S.spaceBgIndex = 1; pcall(function() if F.stopFloat then F.stopFloat() end end); S.LAGGER_SPEED, S.LAGGER_CARRY_SPEED = 15, 24.5; S.autoTPHeight = 20; S.autoCarrySpeedEnabled = false; S.safeModeEnabled = false; S.autoSwingEnabled = true; S.guiLocked = false; S.lockMobileButtons = false; S.moveButtons = false; S.progressBarScale = 100; S.hideMobileButtons = false; S.mobileButtonScale = 0.80; S.uiScaleValue = 100; S.autoSaveEnabled = true; S.toggleNotifEnabled = true; _G.VyxroToggleNotifEnabled = true; S.backgroundPhotoEnabled = true; S.currentThemeName = "ZERO"; S.themeColor = Color3.fromRGB(26,92,160); S.spaceBgIndex = tonumber(S.spaceBgIndex) or 1; S.floatEnabled = false; S.floatHeight = tonumber(S.floatHeight) or 18; S.floatSpeed = tonumber(S.floatSpeed) or 10; S.autoLeftEnabled = false; S.autoRightEnabled = false; S.dropActive = false; S.noPlayerCollisionEnabled = false; S.showTracerEnabled = false; S.ragdollCountdownEnabled = false; S.autoResetOnMedEnabled = false; S.medusaCounterEnabled = false; S.medusaResetEnabled = false; S.batCounterEnabled = false; S.unwalkEnabled = false; S.antiLagEnabled = false; S.stretchRezEnabled = false; S.antiRagdollEnabled = false; S.autoTPEnabled = false; S.autoBatEnabled = false; S.speedMode = false; S.laggerToggled = false; S.laggerPhase = 0; KB.DropBrainrot = {kb=Enum.KeyCode.H, gp=nil}; KB.AutoLeft = {kb=Enum.KeyCode.Z, gp=nil}; KB.AutoRight = {kb=Enum.KeyCode.C, gp=nil}; KB.AutoBat = {kb=Enum.KeyCode.E, gp=nil}; KB.TPBat = {kb=Enum.KeyCode.V, gp=Enum.KeyCode.ButtonY}; KB.TPFloor = {kb=Enum.KeyCode.F, gp=nil}; KB.InstaReset = {kb=Enum.KeyCode.T, gp=nil}; KB.GuiHide = {kb=Enum.KeyCode.LeftControl, gp=nil}; KB.SpeedToggle = {kb=Enum.KeyCode.Q, gp=nil}; KB.LaggerToggle = {kb=Enum.KeyCode.R, gp=nil}; TP_BAT_KEY = Enum.KeyCode.V; TP_BAT_CONTROLLER = Enum.KeyCode.ButtonY; tpBatMode = 1
pcall(function() selectedStealMode = "Normal" AceStealRadii = AceStealRadii or {Normal=55, Semi=20}; AceStealRadii.Normal = 55; AceStealRadii.Semi = 20; autoStealRadius = 55 if Steal then Steal.StealRadius = 55; Steal.StealDuration = 1.3 end autoGrabStopEnabled = false end) pcall(function() if K7 then K7.lineESPEnabled = false; K7.speedESPEnabled = false; K7.fovEnabled = false; K7.bodyLockEnabled = false; K7.bodyLockRadius = 60; K7.headlessEnabled = false; K7.korbloxEnabled = false; K7.animPackEnabled = false if K7.refreshESP then K7.refreshESP() end end end)
_G.VersincMobileButtonPositions = {} pcall(function() if F.resetMobileButtons then F.resetMobileButtons() end end) pcall(function() if F.applyMobileButtonsHidden then F.applyMobileButtonsHidden() end end) pcall(function() if _G._VersincApplyGuiScale then _G._VersincApplyGuiScale(1, true) end end) pcall(function() local df = delfile or (syn and syn.delfile) if df then if _isfile(CONFIG_FILE) then df(CONFIG_FILE) end if _isfile(CONFIG_FILE_LEGACY) then df(CONFIG_FILE_LEGACY) end if _isfile(FEATURE_CONFIG_FILE) then df(FEATURE_CONFIG_FILE) end elseif _writefile then _writefile(CONFIG_FILE, "{}"); _writefile(CONFIG_FILE_LEGACY, "{}"); _writefile(FEATURE_CONFIG_FILE, "{}") end end) _savedCfg = nil
pcall(function() if VS and VS.setBackgroundPhotoVisual then VS.setBackgroundPhotoVisual(true) end if _G._VersincSetBackgroundPhotoEnabled then _G._VersincSetBackgroundPhotoEnabled(true, true) end end) pcall(function() if UI.normalBox then UI.normalBox.Text = "60" end if UI.carryBox then UI.carryBox.Text = "30" end if UI.laggerBox then UI.laggerBox.Text = "15" end if UI.laggerCarryBox then UI.laggerCarryBox.Text = "24.5" end if UI.autoTPHeightBox then UI.autoTPHeightBox.Text = "20" end if UI.radInput then UI.radInput.Text = "55" end if UI.stealModeLbl then UI.stealModeLbl.Text = "Normal" end if UI.mobileSizeLbl then UI.mobileSizeLbl.Text = "0.80" end if F.refreshSpeedModeLabel then F.refreshSpeedModeLabel() end end) local visualOff = {
"setBackgroundPhotoVisual","setAntiRagVisual","setInfJumpVisual","setTPBatVisual","setAutoTPVisual","setUnwalkVisual", "setAntiLagVisual","setStretchRezVisual","setShowTracerVisual","setRagdollCdVisual", "setNoPlayerCollisionVisual","setSafeModeVisual","setMedusaVisual","setMedusaResetVisual", "setAutoResetOnMedVisual","setBatCounterVisual", "setAutoSwingVisual","setLockGuiVisual","setHideMobileVisual","setLineESPVisual", "setSpeedESPVisual","setBodyLockVisual","setHeadlessVisual","setKorbloxVisual","setAnimPackVisual", "setFOVVisual", } for _, name in ipairs(visualOff) do
pcall(function() if VS[name] then VS[name](false) end end) end pcall(function() if S.setAutoCarrySpeedVisual then S.setAutoCarrySpeedVisual(false) end end) pcall(function() if S.autoBatSetVisual then S.autoBatSetVisual(false) end end) pcall(function() if S.autoLeftSetVisual then S.autoLeftSetVisual(false) end end) pcall(function() if S.autoRightSetVisual then S.autoRightSetVisual(false) end end) pcall(function() if VS.setToggleNotifVisual then VS.setToggleNotifVisual(true) end end) pcall(function() if UI.saveStatusLbl then UI.saveStatusLbl.Text = "Config reset" end end) local ok = F.saveConfig(true) if UI and UI.saveStatusLbl then
UI.saveStatusLbl.Text = ok and "Config reset OK" or "Reset done (save fail)"; UI.saveStatusLbl.TextColor3 = ok and Color3.fromRGB(100, 220, 160) or Color3.fromRGB(255, 200, 100) end print("[Vyxro Duel] All configs reset to defaults") return ok end VS = VS or {}; UI = UI or {} function F.refreshSpeedModeLabel() if modeValLbl then modeValLbl.Text=S.laggerToggled and (S.laggerPhase==2 and "Lagger Carry" or "Lagger Normal") or (S.speedMode and "Carry" or "Normal") end end function F.getSpeedModeName() if S.laggerToggled then return (S.laggerPhase == 2) and "Lagger Carry" or "Lagger"
elseif S.speedMode then return "Carry" end return "Normal" end function F.setSpeedModeName(mode) if mode == "Lagger Carry" then S.laggerToggled = true; S.speedMode = false; S.laggerPhase = 2 elseif mode == "Lagger" then S.laggerToggled = true; S.speedMode = false; S.laggerPhase = 1 elseif mode == "Carry" then S.laggerToggled = false; S.speedMode = true; S.laggerPhase = 0 else S.laggerToggled = false; S.speedMode = false; S.laggerPhase = 0 end F.refreshSpeedModeLabel() end function F.isCarryName(name) local n = tostring(name or ""):lower()
return n:find("brainrot") or n:find("animal") or n:find("carry") or n:find("grab") or n:find("steal") or n:find("hold") end function F.isIgnoredCarryTool(name) local n = tostring(name or ""):lower() return n:find("bat") or n:find("slap") or n:find("medusa") or n:find("head") or n:find("stone") end function F.isCarryingBrainrot(char) if not char then return false end for _, name in ipairs({"Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab"}) do local v = char:FindFirstChild(name, true) if v then if v:IsA("BoolValue") and v.Value then return true end
if v:IsA("ObjectValue") and v.Value then return true end if v:IsA("StringValue") and v.Value ~= "" then return true end end end for _, child in ipairs(char:GetChildren()) do if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then if child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then return true end if F.isCarryName(child.Name) then return true end elseif child:IsA("Tool") and not F.isIgnoredCarryTool(child.Name) then return true end end return false end function F.enableCarrySpeedForSteal()
S._autoCarryWaitingPickup = false; S._autoCarryPickupUntil = 0 if not S._autoCarryFromSteal then S._autoCarryReturnMode = F.getSpeedModeName() end S._autoCarryFromSteal = true; S._autoCarryGraceUntil = tick() + 0.75 local wasLagger = (S._autoCarryReturnMode == "Lagger" or S._autoCarryReturnMode == "Lagger Carry" or F.getSpeedModeName() == "Lagger" or F.getSpeedModeName() == "Lagger Carry") if wasLagger then F.setSpeedModeName("Lagger Carry") else F.setSpeedModeName("Carry") end pcall(function() if F.saveConfig then F.saveConfig() end end) end function F.disableAutoCarrySpeed()
if not S._autoCarryFromSteal and not S._autoCarryWaitingPickup then return end local wasAutoApplied = S._autoCarryFromSteal == true; local returnMode = S._autoCarryReturnMode; S._autoCarryFromSteal = false; S._autoCarryWaitingPickup = false; S._autoCarryGraceUntil = 0; S._autoCarryPickupUntil = 0; S._autoCarryReturnMode = nil if not wasAutoApplied then return end if returnMode == "Lagger" or returnMode == "Lagger Carry" then F.setSpeedModeName("Lagger") elseif returnMode == "Carry" then F.setSpeedModeName("Carry") else F.setSpeedModeName("Normal") end
pcall(function() if F.saveConfig then F.saveConfig() end end) end function F.startAutoCarryPickupWatch(seconds) if S.autoCarrySpeedEnabled ~= true then return end S._autoCarryWaitingPickup = true; S._autoCarryPickupUntil = tick() + (seconds or 1.25) end RunService.RenderStepped:Connect(function() if S.autoCarrySpeedEnabled ~= true then if S._autoCarryFromSteal or S._autoCarryWaitingPickup then F.disableAutoCarrySpeed() end return end local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local root = char and char:FindFirstChild("HumanoidRootPart")
if not char or not hum or not root then F.disableAutoCarrySpeed(); S._stealAttrWasActive = false return end local st = hum:GetState(); local gotHit = st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown local stealingAttr = false pcall(function() stealingAttr = (LP:GetAttribute("Stealing") == true) end) local carryingBrainrot = F.isCarryingBrainrot(char) if stealingAttr and not S._stealAttrWasActive then S._stealAttrWasActive = true; F.enableCarrySpeedForSteal() elseif not stealingAttr then S._stealAttrWasActive = false end
if S._autoCarryWaitingPickup then if gotHit or tick() > (S._autoCarryPickupUntil or 0) then S._autoCarryWaitingPickup = false; S._autoCarryPickupUntil = 0 elseif carryingBrainrot then F.enableCarrySpeedForSteal() end end if carryingBrainrot and not S._autoCarryFromSteal then F.enableCarrySpeedForSteal() end if S._autoCarryFromSteal then local graceDone = tick() > (S._autoCarryGraceUntil or 0) if gotHit or (graceDone and not carryingBrainrot and not stealingAttr) then F.disableAutoCarrySpeed() end end end) function F.toggleCarryMode() if S.laggerToggled then
S.laggerToggled=false; S.laggerPhase=0; S.speedMode=true else S.speedMode=not S.speedMode end F.refreshSpeedModeLabel() end function F.toggleLaggerMode() if not S.laggerToggled then S.speedMode=false; S.laggerToggled=true; S.laggerPhase=2 elseif S.laggerPhase==2 then S.laggerPhase=1 else S.laggerPhase=2 end F.refreshSpeedModeLabel() end function F.buildGui() local COLORS = { bg = Color3.fromRGB(2, 6, 14), row = Color3.fromRGB(5, 12, 24), row2 = Color3.fromRGB(8, 18, 34), stroke = Color3.fromRGB(30, 74, 122), strokeSoft = Color3.fromRGB(16, 41, 70), white = Color3.fromRGB(232, 240, 250),
textDim = Color3.fromRGB(132, 154, 182), toggleBg = Color3.fromRGB(6, 16, 30), knob = Color3.fromRGB(226, 238, 250), accent = Color3.fromRGB(27, 96, 178), accentStrong = Color3.fromRGB(50, 132, 224), on = Color3.fromRGB(27, 96, 178), off = Color3.fromRGB(7, 19, 35), } local THEME_PRESETS = { { name = "ZERO", color = Color3.fromRGB(27, 96, 178) },
{ name = "GREEN",  color = Color3.fromRGB(27, 96, 178) }, { name = "RED",    color = Color3.fromRGB(27, 96, 178) }, { name = "CYAN",   color = Color3.fromRGB(27, 96, 178) }, } local BG_EMBED = {
["Neon"] = [[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]],
["Wave"] = [[/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAA8LDA0MCg8NDA0REA8SFyYZFxUVFy8iJBwmODE7OjcxNjU9RVhLPUFUQjU2TWlOVFteY2RjPEpsdGxgc1hhY1//2wBDARARERcUFy0ZGS1fPzY/X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX1//wAARCAGkAaQDASIAAhEBAxEB/8QAHAABA@secret:AWS_ACCESS_KEY_IDAQFAgMGBwEI/8QARxAAAgEDAwIDBQcCAwcEAQIHAQIDAAQRBRIhMUETUWEGFCJxgSMyQpGhscEV0VJi8CQzQ3KC4fEHFlOSYzVEVHODk6Ky4v/EABUBAQEAAAAAAAAAAAAAAAAAAAAB/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8A87pSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApSlApWSqWIVeSeAB3q/i9jNflt1mSxOG6KzqrfkTQc9SuhT2K9oWP/AOnkfORR/Nab72V1uwjMk9hIUHJaMhwPnigpKUIxSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUpSgUqZpum3ep3S21nCZJG6+SjzJ7CvTdG9htMsole+QXlxj4i/wBwfIf3oPM9P0m/1OUR2NrJMc8lR8I+Z6Cu40n/ANOwAJNXucn/AOKA/ux/gV30UUcMYjijWNF6KowB9KzoKS39k9Bt1AXTYnI7yZc/rUpdB0deml2f/wDZX+1WVKCJFpthAwaGyto2HQpEoI/SpVfaxY4Uk9AM0H3oKjtfWqkhriMEHB571AGo3HimTbvt1cq4WJsgYyMHuc4H1qJGIxt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]],
["Bloom"] = [[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]],
["Topo"] = [[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]],
["Blood"] = [[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]],
["Gaze"] = [[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]],
} local BG_RESOLVED = { None = "" } local function b64decode(data) local decoders = { function() return crypt.base64decode(data) end, function() return crypt.base64.decode(data) end, function() return base64_decode(data) end, function() return syn.crypt.base64.decode(data) end, function() local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; data = data:gsub('[^'..b..'=]','') return (data:gsub('.', function(x) if x=='=' then return '' end local r,f='', (b:find(x)-1) for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end return r
end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x) if #x~=8 then return '' end local c=0 for i=1,8 do c=c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end return string.char(c) end)) end, } for _, fn in ipairs(decoders) do local ok, res = pcall(fn) if ok and type(res)=='string' and #res > 0 then return res end end return nil end local function ensureBgAssets() local gca = getcustomasset or getsynasset or nil; local wf = writefile or (syn and syn.writefile) or nil if not gca or not wf then return end for name, b64 in pairs(BG_EMBED) do local fileName = "VyxroDuelBG_" .. name .. ".jpg"
local okWrite = pcall(function() local bin = b64decode(b64) if not bin then return end wf(fileName, bin) end) if okWrite then local okPath, path = pcall(gca, fileName) if okPath and type(path)=='string' then BG_RESOLVED[name] = path end end end end pcall(ensureBgAssets) local function resolveBgId(key)
if not key or key == "" or key == "None" then return "" end if type(key)=="string" and (key:find("rbxasset", 1, true) or key:find("rbxthumb", 1, true) or key:find("http", 1, true)) then return key end return BG_RESOLVED[key] or "" end local currentThemeName = "ZERO"; S.currentThemeName = currentThemeName; S.themeColor = Color3.fromRGB(27, 96, 178); local currentBgId = ""; S.currentBgId = ""; S.bgIntensity = S.bgIntensity or 0.58; if S.backgroundPhotoEnabled == nil then S.backgroundPhotoEnabled = true end local bgAsset, bgVeil; local sidebarImgRef; local sidebarScrimRef; local themeAccentStrokes = {}; local themeAccentFrames = {} local function applyBackground(imageId, skipSave)
    currentBgId = imageId or ""
    S.currentBgId = currentBgId
    local resolved = resolveBgId(currentBgId)
    local photoEnabled = S.backgroundPhotoEnabled ~= false

    if bgAsset then
        if photoEnabled and resolved ~= "" then
            bgAsset.Image = resolved
            bgAsset.ImageTransparency = 1 - (S.bgIntensity or 0.58)
            bgAsset.ImageColor3 = Color3.new(1, 1, 1)
            bgAsset.Visible = true
            if bgVeil then bgVeil.BackgroundTransparency = 0.32 end
        else
            bgAsset.Image = ""
            bgAsset.ImageTransparency = 1
            bgAsset.Visible = false
            if bgVeil then bgVeil.BackgroundTransparency = 0.58 end
        end
        bgAsset.ZIndex = 0
    end

    if sidebarImgRef then
        local showSidebar = photoEnabled and resolved ~= ""
        sidebarImgRef.Image = showSidebar and resolved or ""
        sidebarImgRef.ImageTransparency = showSidebar and (1 - (S.bgIntensity or 0.58)) or 1
        sidebarImgRef.Visible = showSidebar
        sidebarImgRef.ImageColor3 = Color3.new(1, 1, 1)
    end
    if sidebarScrimRef then
        sidebarScrimRef.Visible = true
    end
    pcall(function() if _G.__VxyroSpaceBGSync then _G.__VxyroSpaceBGSync(resolved, photoEnabled) end end)

    if not skipSave then
        pcall(function() if F and F.saveConfig then F.saveConfig() end end)
    end
end

local function setBackgroundPhotoEnabled(enabled, skipSave)
    S.backgroundPhotoEnabled = enabled == true
    if bgAsset then
        local resolved = resolveBgId(S.currentBgId or "")
        local show = S.backgroundPhotoEnabled and resolved ~= ""
        bgAsset.Visible = show
        if show then
            bgAsset.Image = resolved
            bgAsset.ImageTransparency = 1 - (S.bgIntensity or 0.58)
        else
            bgAsset.Image = ""
            bgAsset.ImageTransparency = 1
        end
        if bgVeil then
            bgVeil.BackgroundTransparency = show and 0.32 or 0.58
        end
    end
    pcall(function() if _G.__VxyroSpaceBGSync then _G.__VxyroSpaceBGSync(resolveBgId(S.currentBgId or ""), S.backgroundPhotoEnabled) end end)
    if sidebarImgRef then
        local resolved = resolveBgId(S.currentBgId or "")
        local showSidebar = S.backgroundPhotoEnabled and resolved ~= ""
        sidebarImgRef.Image = showSidebar and resolved or ""
        sidebarImgRef.ImageTransparency = showSidebar and (1 - (S.bgIntensity or 0.58)) or 1
        sidebarImgRef.Visible = showSidebar
        sidebarImgRef.ImageColor3 = Color3.new(1, 1, 1)
    end
    if not skipSave then
        pcall(function() if F and F.saveConfig then F.saveConfig() end end)
    end
    return S.backgroundPhotoEnabled
end

_G._VersincApplyBackground = function(imageId, skipSave) applyBackground(imageId, skipSave) end
_G._VersincSetBackgroundPhotoEnabled = function(enabled, skipSave) return setBackgroundPhotoEnabled(enabled, skipSave) end
 local function applyThemeColor(col, name)
  local ZERO_BLUE = Color3.fromRGB(27, 96, 178)
  col = ZERO_BLUE currentThemeName = "ZERO"; S.currentThemeName = "ZERO"; S.themeColor = col pcall(function() if K7 and K7.updateHeadIndicatorTheme then K7.updateHeadIndicatorTheme() end end) COLORS.stroke = col COLORS.accent = col; COLORS.on = col; COLORS.accentStrong = col; COLORS.strokeSoft = Color3.new(col.R * 0.45 + 0.12, col.G * 0.45 + 0.12, col.B * 0.45 + 0.12) for _, s in ipairs(themeAccentStrokes) do
if s and s.Parent then pcall(function() s.Color = col end) end end
if main then
    for _, d in ipairs(main:GetDescendants()) do
        if d:IsA("UIStroke") and (d:GetAttribute("ThemeAccent") or d:GetAttribute("ThemeAccentStrong")) then
            d.Color = col
        elseif d:IsA("TextButton") and d:GetAttribute("ThemeActive") then
            if d:GetAttribute("ThemeIsActive") == true then
                d.BackgroundColor3 = col
                d.TextColor3 = Color3.fromRGB(0, 0, 0)
            end
        elseif d:IsA("UIGradient") and d.Name == "ToggleGradient" then
            local deep = col:Lerp(Color3.new(0, 0, 0), 0.68)
            local void = col:Lerp(Color3.new(0, 0, 0), 0.90)
            d.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, void),
                ColorSequenceKeypoint.new(0.20, deep),
                ColorSequenceKeypoint.new(0.48, col),
                ColorSequenceKeypoint.new(0.50, col),
                ColorSequenceKeypoint.new(0.52, col),
                ColorSequenceKeypoint.new(0.80, deep),
                ColorSequenceKeypoint.new(1.00, void),
            })
        elseif d:IsA("Frame") and d:GetAttribute("ThemeAccentFill") then
            d.BackgroundColor3 = col
        elseif d:IsA("TextLabel") and d:GetAttribute("ThemeAccentText") then
            d.TextColor3 = col
        end
    end
end if S._mainTryhardBorder and S._mainTryhardBorder.Parent then pcall(function() S._mainTryhardBorder.Color = col end) end if main then for _, d in ipairs(main:GetDescendants()) do if d:IsA("UIStroke") then if d:GetAttribute("ThemeAccent") or d:GetAttribute("ThemeStroke") then d.Color = col end elseif d:IsA("TextButton") then local isHubBtn = d:GetAttribute("ThemeButton") or d.Name == "KeybindButton" or d.Name:find("Btn") or d.Name:find("Button") or d.Name == "PickerPrev" or d.Name == "PickerNext" or d.Name == "PickerValue"
if isHubBtn and d.BackgroundTransparency < 1 then d.BackgroundColor3 = col; d.BackgroundTransparency = math.max(d.BackgroundTransparency, 0.5); local st = d:FindFirstChildOfClass("UIStroke") if st then st.Color = col end end elseif d:IsA("TextBox") then if d.BackgroundTransparency < 1 then local st = d:FindFirstChildOfClass("UIStroke") if st then st.Color = col end end elseif d:IsA("Frame") then if d:GetAttribute("ThemePillOn") then d.BackgroundColor3 = col; d.BackgroundTransparency = 0.22 end end end end pcall(function() if _G.__VxyroSpaceApplyTheme then _G.__VxyroSpaceApplyTheme(col, name or currentThemeName) end end) pcall(function() if _G.__VxyroProtectKeybindRefresh then _G.__VxyroProtectKeybindRefresh(col) end end) pcall(function() if _G._VersincApplyMobileTheme then _G._VersincApplyMobileTheme(col) end
end) pcall(function() if _G._VxyroImportedMusicApplyAccent then _G._VxyroImportedMusicApplyAccent(col) end end) pcall(function() if _G._VxyroSkinApplyAccent then _G._VxyroSkinApplyAccent(col) end end) pcall(function() if _G._VxyroStealBarApplyAccent then _G._VxyroStealBarApplyAccent(col) end end) pcall(function() if PlayerESP and PlayerESP.playerData then for _, d in pairs(PlayerESP.playerData) do if d.highlight then d.highlight.FillColor = col; d.highlight.OutlineColor = col end if d.billboard then local lbl = d.billboard:FindFirstChildWhichIsA("TextLabel") if lbl then lbl.TextColor3 = col end end end end if TracerESP and TracerESP.drawings then for _, d in pairs(TracerESP.drawings) do if d.line then d.line.BackgroundColor3 = col end end end local legacy = workspace:FindFirstChild("VyxroDuelTracers") if legacy then for _, ch in ipairs(legacy:GetDescendants()) do
if ch:IsA("Beam") then ch.Color = ColorSequence.new(col) end end end end) end _G._VersincApplyTheme = function(themeName) for _, preset in ipairs(THEME_PRESETS) do if preset.name == themeName then applyThemeColor(preset.color, preset.name) return end end end local function corner(parent, radius) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = parent return c end local function stroke(parent, color, thickness, transparency)
local s = Instance.new("UIStroke"); s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Color = color or COLORS.stroke; s.Thickness = thickness or 1; s.Transparency = transparency or 0.55; s.Parent = parent if color == nil or color == COLORS.stroke or color == COLORS.accent then s:SetAttribute("ThemeAccent", true); table.insert(themeAccentStrokes, s) end return s end 
-- ============================================================
-- VXYRO GLOSS / SHINE VISUAL LAYER (UI ONLY)
-- Premium reflective finish: soft sweep + sharp specular streak + theme edge bloom.
-- One shared loop keeps the effect light even with many buttons.
-- ============================================================
do
    local __previousGlossRuntime = rawget(_G, "__VxyroGlossRuntime")
    if type(__previousGlossRuntime) == "table" and type(__previousGlossRuntime.stop) == "function" then
        pcall(__previousGlossRuntime.stop)
    end

    local __VXYRO_GLOSS_ALIVE = true
    local __VXYRO_GLOSS = setmetatable({}, {__mode = "k"})
    local __VXYRO_GLOSS_ACTIVE = {}
    local __VXYRO_GLOSS_LAST = 0
    local __VXYRO_GLOSS_PHASE = 0

    local function __vxyroGlossColor(col)
        if typeof(col) == "Color3" then return col end
        if typeof(S) == "table" and typeof(S.themeColor) == "Color3" then return S.themeColor end
        if typeof(COLORS) == "table" and typeof(COLORS.accent) == "Color3" then return COLORS.accent end
        return Color3.fromRGB(100, 200, 255)
    end

    local function __vxyroGlossAttach(target, opts)
        if typeof(target) ~= "Instance" or not target:IsA("GuiObject") then return false end
        opts = opts or {}
        local old = __VXYRO_GLOSS[target]
        if old and old.root and old.root.Parent then return true end

        local theme = __vxyroGlossColor()
        pcall(function() target.ClipsDescendants = true end)
        local radius = tonumber(opts.radius) or 12
        local z = tonumber(opts.z) or math.max(1, (tonumber(target.ZIndex) or 1) + 1)

        local root = Instance.new("Frame")
        root.Name = "VxyroGlossFX"
        root.Size = UDim2.new(1.22, 0, 1.34, 0)
        root.Position = UDim2.new(-0.94, 0, -0.17, 0)
        root.BackgroundColor3 = Color3.fromRGB(255,255,255)
        root.BackgroundTransparency = 0.70
        root.BorderSizePixel = 0
        root.Active = false
        root.Selectable = false
        root.ZIndex = z
        root.Parent = target
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, radius)
        rc.Parent = root

        local soft = Instance.new("UIGradient")
        soft.Name = "GlossSoft"
        soft.Rotation = tonumber(opts.rotation) or 18
        soft.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.00, 1.00),
            NumberSequenceKeypoint.new(0.34, 0.98),
            NumberSequenceKeypoint.new(0.44, 0.72),
            NumberSequenceKeypoint.new(0.50, 0.20),
            NumberSequenceKeypoint.new(0.56, 0.72),
            NumberSequenceKeypoint.new(0.66, 0.98),
            NumberSequenceKeypoint.new(1.00, 1.00),
        })
        soft.Parent = root

        local spec = Instance.new("Frame")
        spec.Name = "SpecularStreak"
        spec.AnchorPoint = Vector2.new(0.5, 0.5)
        spec.Size = UDim2.new(0, math.max(9, math.floor((tonumber(opts.specWidth) or 10))), 1.45, 0)
        spec.Position = UDim2.new(0.5, 0, 0.5, 0)
        spec.Rotation = tonumber(opts.rotation) or 18
        spec.BackgroundColor3 = Color3.fromRGB(255,255,255)
        spec.BackgroundTransparency = 0.72
        spec.BorderSizePixel = 0
        spec.ZIndex = z + 1
        spec.Parent = root
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = spec
        local sg = Instance.new("UIGradient")
        sg.Name = "SpecularGradient"
        sg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.00, 1.00),
            NumberSequenceKeypoint.new(0.46, 1.00),
            NumberSequenceKeypoint.new(0.50, 0.05),
            NumberSequenceKeypoint.new(0.54, 1.00),
            NumberSequenceKeypoint.new(1.00, 1.00),
        })
        sg.Parent = spec

        local edge = Instance.new("UIStroke")
        edge.Name = "GlossEdge"
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        edge.Color = theme
        edge.Thickness = tonumber(opts.thickness) or 1.35
        edge.Transparency = tonumber(opts.transparency) or 0.24
        edge.Parent = target

        local bloom = Instance.new("UIStroke")
        bloom.Name = "GlossBloom"
        bloom.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bloom.Color = theme
        bloom.Thickness = tonumber(opts.bloomThickness) or 5.2
        bloom.Transparency = 0.86
        bloom.Parent = target

        local state = {
            root = root,
            soft = soft,
            spec = spec,
            edge = edge,
            bloom = bloom,
            baseTransparency = tonumber(opts.transparency) or 0.24,
            baseThickness = tonumber(opts.thickness) or 1.35,
            bloomBase = tonumber(opts.bloomThickness) or 5.2,
            specAlpha = 0.72,
        }
        __VXYRO_GLOSS[target] = state
        table.insert(__VXYRO_GLOSS_ACTIVE, target)
        return true
    end

    local function __vxyroGlossRefresh(col)
        local theme = __vxyroGlossColor(col)
        for i = #__VXYRO_GLOSS_ACTIVE, 1, -1 do
            local target = __VXYRO_GLOSS_ACTIVE[i]
            local state = __VXYRO_GLOSS[target]
            if not target or not target.Parent or not state or not state.root or not state.root.Parent then
                table.remove(__VXYRO_GLOSS_ACTIVE, i)
            else
                pcall(function()
                    state.edge.Color = theme
                    state.bloom.Color = theme
                end)
            end
        end
    end

    _G.__VxyroGlossAttach = __vxyroGlossAttach
    _G.__VxyroRefreshGlossTheme = __vxyroGlossRefresh
    local __VXYRO_GLOSS_RENDER_CONN = nil

    _G.__VxyroGlossRuntime = {
        stop = function()
            __VXYRO_GLOSS_ALIVE = false
            if __VXYRO_GLOSS_RENDER_CONN then
                pcall(function() __VXYRO_GLOSS_RENDER_CONN:Disconnect() end)
                __VXYRO_GLOSS_RENDER_CONN = nil
            end
            table.clear(__VXYRO_GLOSS_ACTIVE)
        end,
    }

    __VXYRO_GLOSS_RENDER_CONN = RunService.RenderStepped:Connect(function(dt)
        if not __VXYRO_GLOSS_ALIVE then return end
        local now = os.clock()
        local step = math.clamp(tonumber(dt) or 0.016, 0, 0.05)
        __VXYRO_GLOSS_PHASE = (__VXYRO_GLOSS_PHASE + step * 0.43) % 1
        local sweep = -1.75 + (__VXYRO_GLOSS_PHASE * 3.50)
        local pulse = (math.sin(now * 2.2) + 1) * 0.5
        for i = #__VXYRO_GLOSS_ACTIVE, 1, -1 do
            local target = __VXYRO_GLOSS_ACTIVE[i]
            local state = __VXYRO_GLOSS[target]
            if not target or not target.Parent or not state or not state.root or not state.root.Parent then
                table.remove(__VXYRO_GLOSS_ACTIVE, i)
            else
                pcall(function()
                    state.soft.Offset = Vector2.new(sweep, 0)
                    state.spec.Position = UDim2.new(__VXYRO_GLOSS_PHASE * 1.85 - 0.42, 0, 0.5, 0)
                    state.spec.BackgroundTransparency = 0.76 - pulse * 0.08
                    state.edge.Transparency = math.clamp(state.baseTransparency + pulse * 0.08, 0.12, 0.55)
                    state.edge.Thickness = state.baseThickness + pulse * 0.35
                    state.bloom.Transparency = math.clamp(0.90 - pulse * 0.11, 0.74, 0.94)
                    state.bloom.Thickness = state.bloomBase + pulse * 1.10
                end)
            end
        end
    end)
end

do
    local __oldVxyroApplyTheme = _G._VersincApplyTheme
    if type(__oldVxyroApplyTheme) == "function" and not _G.__VxyroGlossThemeWrapped then
        _G.__VxyroGlossThemeWrapped = true
        _G._VersincApplyTheme = function(themeName)
            local result = __oldVxyroApplyTheme(themeName)
            pcall(function()
                if _G.__VxyroRefreshGlossTheme then _G.__VxyroRefreshGlossTheme(S.themeColor) end
            end)
            return result
        end
    end
end

local function destroyGuiCopies(name)
    local parents = {}
    pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
    pcall(function() table.insert(parents, LP:FindFirstChild("PlayerGui")) end)
    pcall(function() if type(gethui) == "function" then table.insert(parents, gethui()) end end)
    local seen = {}
    for _, parent in ipairs(parents) do
        if parent and not seen[parent] then
            seen[parent] = true
            pcall(function()
                local obj = parent:FindFirstChild(name)
                while obj do
                    obj:Destroy()
                    obj = parent:FindFirstChild(name)
                end
            end)
        end
    end
end

-- ============================================================
-- VXYRO E01 NOTIFICATION UI (NO-INTERFERENCE)
-- Visual-only: does not touch character physics, CFrame, velocity,
-- remotes, tools, or movement state.
-- ============================================================
do
    local E01_GUI_NAME = "VyxroE01Notification"
    local E01_DURATION = 3.00
    local E01_ENTRY_TIME = 0.35
    local E01_EXIT_TIME = 0.30
    local E01_COOLDOWN = 0.55

    local previous = _genv.__VyxroE01VisualRun
    if type(previous) == "table" and type(previous.stop) == "function" then
        pcall(previous.stop)
    end

    local run = {
        alive = true,
        connections = {},
        generation = 0,
        active = false,
        lastCarry = false,
        lastShow = 0,
        gui = nil,
    }
    _genv.__VyxroE01VisualRun = run

    local function disconnectAll()
        for i = #run.connections, 1, -1 do
            local c = run.connections[i]
            pcall(function() c:Disconnect() end)
            run.connections[i] = nil
        end
    end

    local function getPlayerGui()
        if not LP then return nil end
        local ok, pg = pcall(function()
            return LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 3)
        end)
        return ok and pg or nil
    end

    local function destroyGui()
        if run.gui then
            pcall(function() run.gui:Destroy() end)
            run.gui = nil
        end
        -- Remove only this script's named E01 GUI from PlayerGui.
        local pg = getPlayerGui()
        if pg then
            pcall(function()
                local old = pg:FindFirstChild(E01_GUI_NAME)
                while old do
                    old:Destroy()
                    old = pg:FindFirstChild(E01_GUI_NAME)
                end
            end)
        end
    end

    local function getAccent()
        local accent
        pcall(function()
            accent = rawget(_G, "EmpireThemeAccent")
        end)
        if typeof(accent) == "Color3" then return accent end
        pcall(function()
            accent = rawget(_G, "UI_ACCENT")
        end)
        if typeof(accent) == "Color3" then return accent end
        pcall(function()
            accent = rawget(_G, "CHERRY_ACCENT")
        end)
        if typeof(accent) == "Color3" then return accent end
        return Color3.fromRGB(255, 20, 147)
    end

    local function showE01(force)
        if not run.alive then return false end
        local now = os.clock()
        if not force and now - run.lastShow < E01_COOLDOWN then return false end
        if run.active and not force then return false end
        run.lastShow = now
        run.generation += 1
        local generation = run.generation
        run.active = true

        local pg = getPlayerGui()
        if not pg then
            run.active = false
            return false
        end

        destroyGui()

        local gui = Instance.new("ScreenGui")
        gui.Name = E01_GUI_NAME
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 230
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.Parent = pg
        run.gui = gui

        local frame = Instance.new("Frame")
        frame.Name = "E01Capsule"
        frame.Size = UDim2.new(0, 300, 0, 38)
        frame.Position = UDim2.new(0.5, -150, 0, -58)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.04
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 10
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Name = "TimerBorder"
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = getAccent()
        stroke.Thickness = 1.5
        stroke.Transparency = 0
        stroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "StateText"
        label.Size = UDim2.new(1, -24, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0.2
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Text = "DONT STEAL"
        label.ZIndex = 20
        label.Parent = frame
        pcall(function() if _G.__VxyroGlossAttach then _G.__VxyroGlossAttach(frame, {z=11, radius=19, thickness=1.45, bloomThickness=5.2}) end end)

        local top = UDim2.new(0.5, -150, 0, 18)
        local hidden = UDim2.new(0.5, -150, 0, -58)

        pcall(function()
            TS:Create(frame,
                TweenInfo.new(E01_ENTRY_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { Position = top, BackgroundTransparency = 0 }
            ):Play()
        end)

        -- UI-only timer driven by TweenService instead of RenderStepped.
        pcall(function()
            TS:Create(stroke,
                TweenInfo.new(E01_DURATION, Enum.EasingStyle.Linear),
                { Transparency = 0.18 }
            ):Play()
        end)

        task.delay(E01_DURATION, function()
            if not run.alive or generation ~= run.generation or not frame.Parent then return end
            label.Text = "STEAL"

            task.delay(0.18, function()
                if not run.alive or generation ~= run.generation or not frame.Parent then return end
                local outTween
                pcall(function()
                    outTween = TS:Create(frame,
                        TweenInfo.new(E01_EXIT_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                        { Position = hidden, BackgroundTransparency = 1 }
                    )
                    outTween:Play()
                end)
                if outTween then
                    pcall(function() outTween.Completed:Wait() end)
                end
                if run.alive and generation == run.generation then
                    if gui.Parent then pcall(function() gui:Destroy() end) end
                    if run.gui == gui then run.gui = nil end
                    run.active = false
                end
            end)
        end)

        return true
    end

    local function isCarryLikeName(name)
        local n = tostring(name or ""):lower()
        return n:find("brainrot", 1, true) or n:find("brain", 1, true) or
               n:find("animal", 1, true) or n:find("carry", 1, true) or
               n:find("grab", 1, true) or n:find("stolen", 1, true) or
               n:find("held", 1, true) or n:find("holding", 1, true) or
               n:find("steal", 1, true)
    end

    local function isCarryingNow()
        local char = LP and LP.Character
        if not char then return false end

        for _, attrName in ipairs({"Carrying", "IsCarrying", "Stealing", "IsStealing", "HasBrainrot", "HasBrainRot"}) do
            local ok, value = pcall(function() return char:GetAttribute(attrName) end)
            if ok and value == true then return true end
        end
        for _, attrName in ipairs({"Carrying", "IsCarrying", "Stealing", "IsStealing", "HasBrainrot", "HasBrainRot"}) do
            local ok, value = pcall(function() return LP:GetAttribute(attrName) end)
            if ok and value == true then return true end
        end

        for _, child in ipairs(char:GetChildren()) do
            if isCarryLikeName(child.Name) then return true end
            if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
                return true
            end
        end
        return false
    end

    local function checkCarry()
        if not run.alive then return end
        local carrying = isCarryingNow()
        if carrying and not run.lastCarry then
            showE01(false)
        end
        run.lastCarry = carrying
    end

    local function bindCharacter(char)
        if not run.alive or not char then return end
        run.lastCarry = false

        table.insert(run.connections, char.ChildAdded:Connect(function()
            if run.alive then task.defer(checkCarry) end
        end))
        table.insert(run.connections, char.ChildRemoved:Connect(function()
            if run.alive then task.defer(checkCarry) end
        end))

        for _, attrName in ipairs({"Carrying", "IsCarrying", "Stealing", "IsStealing", "HasBrainrot", "HasBrainRot"}) do
            table.insert(run.connections, char:GetAttributeChangedSignal(attrName):Connect(checkCarry))
        end
        task.defer(checkCarry)
    end

    table.insert(run.connections, LP.CharacterAdded:Connect(function(char)
        bindCharacter(char)
    end))

    for _, attrName in ipairs({"Carrying", "IsCarrying", "Stealing", "IsStealing", "HasBrainrot", "HasBrainRot"}) do
        table.insert(run.connections, LP:GetAttributeChangedSignal(attrName):Connect(checkCarry))
    end

    -- Lightweight fallback poll; it does not write or read character physics.
    task.spawn(function()
        while run.alive do
            _w(0.35)
            if run.alive then checkCarry() end
        end
    end)

    if LP.Character then bindCharacter(LP.Character) end

    _G.E01Notification = {
        show = function() return showE01(true) end,
        hide = function()
            run.generation += 1
            run.active = false
            destroyGui()
        end,
        Duration = E01_DURATION,
    }

    function run.stop()
        if not run.alive then return end
        run.alive = false
        run.generation += 1
        run.active = false
        disconnectAll()
        destroyGui()
        if _genv.__VyxroE01VisualRun == run then
            _genv.__VyxroE01VisualRun = nil
        end
    end

    -- Deliberately no auto-show on script execution: notification appears
    -- only when the carry/steal state transitions to active.
end

destroyGuiCopies("VyxroDuel")

local gui = Instance.new("ScreenGui")
gui.Name = "VyxroDuel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10001
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if type(syn) == "table" and type(syn.protect_gui) == "function" then
        syn.protect_gui(gui)
    elseif type(protect_gui) == "function" then
        protect_gui(gui)
    elseif type(protectgui) == "function" then
        protectgui(gui)
    end
end)

local parented = false
pcall(function()
    if type(gethui) == "function" then
        gui.Parent = gethui()
        parented = gui.Parent ~= nil
    end
end)
if not parented then
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 8)
        if pg then
            gui.Parent = pg
            parented = gui.Parent ~= nil
        end
    end)
end
if not parented then
    pcall(function()
        gui.Parent = game:GetService("CoreGui")
        parented = gui.Parent ~= nil
    end)
end
if not parented then
    warn("[Vyxro Duel] ScreenGui parent failed")
    return
end

-- Shared root used by the imported Music Player / Custom Font popups.
pcall(function() _G.VxyroMainGui = gui end)

local main = Instance.new("Frame", gui)
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Size = UDim2.new(0, 480, 0, 520)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.ZIndex = 1
corner(main, 22)

local miniScaleObj
local uiScaleObj = Instance.new("UIScale", main)
uiScaleObj.Name = "MenuScale"
local guiScale = math.clamp((tonumber(S.uiScaleValue) or 100) / 100, 0.60, 1.35)
uiScaleObj.Scale = guiScale
local mainUIScale = uiScaleObj
if miniScaleObj then
    miniScaleObj.Scale = guiScale
end

local mainStroke = stroke(main, Color3.fromRGB(255, 255, 255), 1.2, 0.55)
mainStroke.Name = "MenuBorder"
mainStroke:SetAttribute("ThemeAccent", true)
local mainGlow = stroke(main, S.themeColor or Color3.fromRGB(100, 200, 255), 4, 0.86)
mainGlow.Name = "MenuGlow"
mainGlow:SetAttribute("ThemeAccent", true)
TS:Create(mainGlow, TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.94}):Play()
local mainBloom = stroke(main, S.themeColor or Color3.fromRGB(100, 200, 255), 7, 0.965)
mainBloom.Name = "MenuBloom"
mainBloom:SetAttribute("ThemeAccent", true)
TS:Create(mainBloom, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.985}):Play()
local ambientSweep = Instance.new("Frame", main)
ambientSweep.Name = "AmbientSweep"
ambientSweep.Size = UDim2.new(0.34, 0, 1, 0)
ambientSweep.Position = UDim2.new(-0.36, 0, 0, 0)
ambientSweep.BackgroundColor3 = S.themeColor or Color3.fromRGB(100, 200, 255)
ambientSweep.BackgroundTransparency = 0.93
ambientSweep.BorderSizePixel = 0
ambientSweep.Rotation = 10
ambientSweep.ZIndex = 2
ambientSweep:SetAttribute("ThemeAccentFill", true)
corner(ambientSweep, 22)
local ambientSweepGrad = Instance.new("UIGradient", ambientSweep)
ambientSweepGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.35),
    NumberSequenceKeypoint.new(1, 1),
})
TS:Create(ambientSweep, TweenInfo.new(3.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false), {Position = UDim2.new(1.05, 0, 0, 0)}):Play()
local topHighlight = Instance.new("Frame", main)
topHighlight.Name = "TopHighlight"
topHighlight.Size = UDim2.new(1, -42, 0, 2)
topHighlight.Position = UDim2.new(0, 21, 0, 3)
topHighlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topHighlight.BackgroundTransparency = 0.72
topHighlight.BorderSizePixel = 0
topHighlight.ZIndex = 9
corner(topHighlight, 2)
local topHighlightGradient = Instance.new("UIGradient", topHighlight)
topHighlightGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.1),
    NumberSequenceKeypoint.new(1, 1)
})


local panelBg = Instance.new("Frame", main)
panelBg.Name = "PanelBg"
panelBg.Size = UDim2.new(1, 0, 1, 0)
panelBg.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
panelBg.BackgroundTransparency = 0.04
panelBg.BorderSizePixel = 0
panelBg.ZIndex = 1
corner(panelBg, 22)
local panelGradient = Instance.new("UIGradient", panelBg)
panelGradient.Rotation = 135
panelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 18, 52)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(12, 10, 22)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(8, 16, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 8, 42))
})

-- Premium VXYRO visual layer: subtle ambient glows + animated glass sheen.
local ambientA = Instance.new("Frame", main)
ambientA.Name = "VXYROAmbientA"
ambientA.Size = UDim2.new(0, 250, 0, 250)
ambientA.Position = UDim2.new(0, -88, 0, -72)
ambientA.BackgroundColor3 = S.themeColor or Color3.fromRGB(100, 200, 255)
ambientA.BackgroundTransparency = 0.72
ambientA.BorderSizePixel = 0
ambientA.ZIndex = 1
corner(ambientA, 125)
ambientA:SetAttribute("ThemeAccentFill", true)
local ambientAGrad = Instance.new("UIGradient", ambientA)
ambientAGrad.Rotation = 35
ambientAGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 0.92),
    NumberSequenceKeypoint.new(0.50, 0.08),
    NumberSequenceKeypoint.new(1.00, 0.92),
})
local ambientAStroke = stroke(ambientA, S.themeColor or Color3.fromRGB(100, 200, 255), 10, 0.94)
ambientAStroke:SetAttribute("ThemeAccent", true)

local ambientB = Instance.new("Frame", main)
ambientB.Name = "VXYROAmbientB"
ambientB.Size = UDim2.new(0, 230, 0, 230)
ambientB.Position = UDim2.new(1, -140, 1, -135)
ambientB.BackgroundColor3 = S.themeColor or Color3.fromRGB(60, 160, 255)
ambientB.BackgroundTransparency = 0.74
ambientB.BorderSizePixel = 0
ambientB.ZIndex = 1
corner(ambientB, 115)
ambientB:SetAttribute("ThemeAccentFill", true)
local ambientBGrad = Instance.new("UIGradient", ambientB)
ambientBGrad.Rotation = -35
ambientBGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 0.94),
    NumberSequenceKeypoint.new(0.50, 0.12),
    NumberSequenceKeypoint.new(1.00, 0.94),
})
local ambientBStroke = stroke(ambientB, S.themeColor or Color3.fromRGB(60, 160, 255), 9, 0.95)
ambientBStroke:SetAttribute("ThemeAccent", true)

local glassShine = Instance.new("Frame", main)
glassShine.Name = "VXYROGlassShine"
glassShine.Size = UDim2.new(0, 46, 1, 80)
glassShine.Position = UDim2.new(0, -70, 0, -40)
glassShine.Rotation = 16
glassShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glassShine.BackgroundTransparency = 0.90
glassShine.BorderSizePixel = 0
glassShine.ZIndex = 1
local shineGrad = Instance.new("UIGradient", glassShine)
shineGrad.Rotation = 90
shineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.00, 1),
    NumberSequenceKeypoint.new(0.50, 0.15),
    NumberSequenceKeypoint.new(1.00, 1),
})

TS:Create(panelGradient, TweenInfo.new(6.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Offset = Vector2.new(0.16, 0)
}):Play()
TS:Create(ambientA, TweenInfo.new(5.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Position = UDim2.new(0, -48, 0, -42),
    BackgroundTransparency = 0.62
}):Play()
TS:Create(ambientAStroke, TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Transparency = 0.88,
    Thickness = 13
}):Play()
TS:Create(ambientB, TweenInfo.new(6.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Position = UDim2.new(1, -174, 1, -165),
    BackgroundTransparency = 0.64
}):Play()
TS:Create(ambientBStroke, TweenInfo.new(3.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Transparency = 0.89,
    Thickness = 12
}):Play()
local shineSweep = TS:Create(glassShine, TweenInfo.new(3.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, -1, false), {
    Position = UDim2.new(1, 45, 0, -40)
})
shineSweep:Play()


bgAsset = Instance.new("ImageLabel", main)
bgAsset.Name = "BackgroundAsset"
bgAsset.Size = UDim2.new(1, 0, 1, 0)
bgAsset.BackgroundTransparency = 1
bgAsset.Image = ""
bgAsset.ImageTransparency = 1
bgAsset.ScaleType = Enum.ScaleType.Crop
bgAsset.ZIndex = 1
corner(bgAsset, 22)

bgVeil = Instance.new("Frame", main)
bgVeil.Name = "BackgroundVeil"
bgVeil.Size = UDim2.new(1, 0, 1, 0)
bgVeil.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgVeil.BackgroundTransparency = 0.72
bgVeil.BorderSizePixel = 0
bgVeil.ZIndex = 1
corner(bgVeil, 22)

local function _packPos(p)
    return { xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset }
end

local function _unpackPos(v)
    if type(v) ~= "table" then return nil end
    return UDim2.new(tonumber(v.xs) or 0, tonumber(v.xo) or 0, tonumber(v.ys) or 0, tonumber(v.yo) or 0)
end

local function _applyHubPosition()
    if type(S.hubPos) == "table" then
        pcall(function()
            local p = _unpackPos(S.hubPos)
            if p then main.Position = p end
        end)
    end
end

_G._VersincSetHubPos = function(hub, mini)
    local p = _unpackPos(hub)
    if p and main then main.Position = p end
    local q = _unpackPos(mini)
    if q and _G.__VersincMiniBtn then _G.__VersincMiniBtn.Position = q end
end

do
    local dragging, dragStart, startPos, dragInput = false, nil, nil, nil

    main.InputBegan:Connect(function(input)
        if S.guiLocked == true then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragging then
                        dragging = false
                        S.hubPos = _packPos(main.Position)
                        pcall(function() F.saveConfig(true) end)
                    end
                end
            end)
        end
    end)

    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if S.guiLocked == true then dragging = false; return end
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local SIDEBAR_W = 195
local CONTENT_OVERLAP = 8

local sidebar = Instance.new("Frame", main)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 3
sidebar.ClipsDescendants = true
corner(sidebar, 22)

local sidebarCanvas = Instance.new("Frame", sidebar)
sidebarCanvas.Name = "SidebarCanvas"
sidebarCanvas.Size = UDim2.new(1, 60, 1, 0)
sidebarCanvas.Position = UDim2.new(0, 0, 0, 0)
sidebarCanvas.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sidebarCanvas.BackgroundTransparency = 0
sidebarCanvas.BorderSizePixel = 0
sidebarCanvas.ZIndex = 1
corner(sidebarCanvas, 22)

local sidebarImg = Instance.new("ImageLabel", sidebarCanvas)
sidebarImgRef = sidebarImg
sidebarImg.Name = "SidebarArt"
sidebarImg.Size = UDim2.new(1, 0, 1, 0)
sidebarImg.Position = UDim2.new(0, 0, 0, 0)
sidebarImg.BackgroundTransparency = 1
sidebarImg.Image = ""
sidebarImg.ScaleType = Enum.ScaleType.Crop
sidebarImg.ImageTransparency = 1
sidebarImg.ImageColor3 = Color3.new(1, 1, 1)
sidebarImg.Visible = false
sidebarImg.ZIndex = 2

local sidebarScrim = Instance.new("Frame", sidebarCanvas)
sidebarScrimRef = sidebarScrim
sidebarScrim.Name = "SidebarScrim"
sidebarScrim.Size = UDim2.new(1, 0, 1, 0)
sidebarScrim.Position = UDim2.new(0, 0, 0, 0)
sidebarScrim.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
sidebarScrim.BackgroundTransparency = 0.92
sidebarScrim.BorderSizePixel = 0
sidebarScrim.ZIndex = 3

local brandBg = Instance.new("Frame", sidebar)
brandBg.Size = UDim2.new(0, 120, 0, 30)
brandBg.Position = UDim2.new(0, 8, 0, 8)
brandBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
brandBg.BackgroundTransparency = 0
brandBg.BorderSizePixel = 0
brandBg.ZIndex = 4
corner(brandBg, 6)
stroke(brandBg, Color3.fromRGB(255, 255, 255), 0.8, 0.3)

local brandFrame = Instance.new("Frame", sidebar)
brandFrame.Size = UDim2.new(0, 120, 0, 30)
brandFrame.Position = UDim2.new(0, 12, 0, 10)
brandFrame.BackgroundTransparency = 1
brandFrame.ZIndex = 5

local grayCircle = Instance.new("Frame", brandFrame)
grayCircle.Size = UDim2.new(0, 10, 0, 10)
grayCircle.Position = UDim2.new(0, 0, 0, 8)
grayCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
grayCircle.BorderSizePixel = 0
grayCircle.ZIndex = 6
corner(grayCircle, 10)
local brandPulse = Instance.new("UIStroke", grayCircle)
brandPulse.Color = COLORS.accentStrong
brandPulse.Thickness = 2
brandPulse.Transparency = 0.35
brandPulse:SetAttribute("ThemeAccent", true)
TS:Create(brandPulse, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.80, Thickness = 1}):Play()

local brandTitle = Instance.new("TextLabel", brandFrame)
brandTitle.Size = UDim2.new(1, 0, 0, 30)
brandTitle.Position = UDim2.new(0, 16, 0, 0)
brandTitle.BackgroundTransparency = 1
brandTitle.Text = "ZERO HUB"
brandTitle.TextColor3 = Color3.fromRGB(192, 198, 210)
brandTitle.Font = Enum.Font.GothamBold
brandTitle.TextSize = 14
brandTitle.TextXAlignment = Enum.TextXAlignment.Left
brandTitle.TextYAlignment = Enum.TextYAlignment.Center
brandTitle.ZIndex = 6
local brandGradient = Instance.new("UIGradient", brandTitle)
brandGradient.Rotation = 0
brandGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(210, 210, 215)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.70, Color3.fromRGB(235, 235, 240)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 158)),
})
TS:Create(brandGradient, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Offset = Vector2.new(0.28, 0)
}):Play()

local tabContainer = Instance.new("Frame", sidebar)
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(0, 140, 0, 350)
tabContainer.AnchorPoint = Vector2.new(1, 0.5)
tabContainer.Position = UDim2.new(0.95, 0, 0.50, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 4
tabContainer.ClipsDescendants = false

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 8)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 14)
closeBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
closeBtn.BackgroundTransparency = 0.05
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 17
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 10
corner(closeBtn, 7)
local closeStroke = stroke(closeBtn, Color3.fromRGB(255, 255, 255), 1, 0.45)
closeStroke:SetAttribute("ThemeAccent", true)

local miniBtn = Instance.new("TextButton", gui)
miniBtn.Name = "LINXMini"
miniBtn.Size = UDim2.new(0, 126, 0, 34)
miniBtn.Position = UDim2.new(1, -144, 0, 26)
miniBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
miniBtn.BorderSizePixel = 0
miniBtn.Text = "ZERO HUB"
miniBtn.TextColor3 = Color3.fromRGB(192, 198, 210) -- Open GUI text: pure white
miniBtn.TextStrokeTransparency = 0.55
miniBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
miniBtn.Font = Enum.Font.GothamBlack
miniBtn.TextSize = 11
miniBtn.ZIndex = 20
miniBtn.Visible = false
corner(miniBtn, 8)
miniScaleObj = Instance.new("UIScale", miniBtn)
miniScaleObj.Name = "MiniButtonScale"
miniScaleObj.Scale = guiScale
local miniStroke = stroke(miniBtn, Color3.fromRGB(255, 255, 255), 1.2, 0.4)
miniStroke:SetAttribute("ThemeAccent", true)
local miniHoverScale = Instance.new("UIScale", miniBtn)
miniHoverScale.Name = "MiniHoverScale"
miniHoverScale.Scale = 1
miniBtn.MouseEnter:Connect(function()
    TS:Create(miniBtn, TweenInfo.new(0.14), {BackgroundTransparency = 0.0}):Play()
    TS:Create(miniStroke, TweenInfo.new(0.14), {Transparency = 0.08}):Play()
    TS:Create(miniHoverScale, TweenInfo.new(0.14), {Scale = 1.04}):Play()
end)
miniBtn.MouseLeave:Connect(function()
    TS:Create(miniBtn, TweenInfo.new(0.14), {BackgroundTransparency = 0.08}):Play()
    TS:Create(miniStroke, TweenInfo.new(0.14), {Transparency = 0.4}):Play()
    TS:Create(miniHoverScale, TweenInfo.new(0.14), {Scale = 1}):Play()
end)
local closeScale = Instance.new("UIScale", closeBtn)
closeBtn.MouseEnter:Connect(function()
    TS:Create(closeBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.0}):Play()
    TS:Create(closeStroke, TweenInfo.new(0.12), {Transparency = 0.05}):Play()
    TS:Create(closeScale, TweenInfo.new(0.12), {Scale = 1.08}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TS:Create(closeBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.05}):Play()
    TS:Create(closeStroke, TweenInfo.new(0.12), {Transparency = 0.45}):Play()
    TS:Create(closeScale, TweenInfo.new(0.12), {Scale = 1}):Play()
end)
_G.__VersincMiniBtn = miniBtn
_G.__VersincMiniButtonScale = miniScaleObj

if type(S.miniPos) == "table" then
    pcall(function()
        local p = _unpackPos(S.miniPos)
        if p then miniBtn.Position = p end
    end)
end

do
    local miniDragging, dragStart, startPos = false, nil, nil
    miniBtn.InputBegan:Connect(function(input)
        if S.guiLocked == true then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            miniDragging = true
            dragStart = input.Position
            startPos = miniBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End and miniDragging then
                    miniDragging = false
                    S.miniPos = _packPos(miniBtn.Position)
                    pcall(function() F.saveConfig(true) end)
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if S.guiLocked == true then miniDragging = false; return end
            local delta = input.Position - dragStart
            miniBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local contentArea = Instance.new("Frame", main)
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -(SIDEBAR_W - CONTENT_OVERLAP), 1, 0)
contentArea.Position = UDim2.new(0, SIDEBAR_W - CONTENT_OVERLAP, 0, 0)
contentArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.ZIndex = 2
corner(contentArea, 26)
local contentBorder = stroke(contentArea, Color3.fromRGB(70, 70, 70), 1, 0.18)
contentBorder:SetAttribute("ThemeAccent", true)

local pageHolder = Instance.new("Frame", contentArea)
pageHolder.Size = UDim2.new(1, -10, 1, -18)
pageHolder.Position = UDim2.new(0, 5, 0, 9)
pageHolder.BackgroundTransparency = 1
pageHolder.BorderSizePixel = 0
pageHolder.ZIndex = 3

local function buildEmptyPage(name)
    local p = Instance.new("ScrollingFrame", pageHolder)
    p.Name = name
    p.Size = UDim2.new(1, -2, 1, 0)
    p.Position = UDim2.new(0, 0, 0, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ClipsDescendants = true
    p.ScrollBarThickness = 0
    p.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    p.ScrollBarImageTransparency = 0.5
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.ZIndex = 4
    local list = Instance.new("UIListLayout", p)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 7)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 16)
    pad.PaddingLeft = UDim.new(0, 3)
    pad.PaddingRight = UDim.new(0, 7)
    return p
end

local mainPage = buildEmptyPage("Main")
local customizationPage = buildEmptyPage("Customization")
local configPage = buildEmptyPage("Config")
local otherPage = buildEmptyPage("Other")

mainPage.Visible = true
customizationPage.Visible = false
configPage.Visible = false
otherPage.Visible = false

-- Keep the existing control logic intact while moving it into the new 4-page menu.
local pageMOVE = mainPage
local pageTOOLS = mainPage
local pageVIEW = customizationPage
local pageSYS = configPage

-- ============================================================
-- SPACE-STYLE VXYRO SHELL
-- Existing Vxyro pages/logic are retained and simply mounted
-- inside a compact Space-style shell.
-- ============================================================
do
    local SPACE_BG_IDS = {
        "rbxassetid://76835310118322", "rbxassetid://114138477258742", "rbxassetid://128490869357075",
        "rbxassetid://114608427279807", "rbxassetid://115887697595024", "rbxassetid://75252890789907",
    }
    local SPACE_THEMES = {}
    local spaceThemeBtns, spaceBgBtns, spaceTabBtns, spacePages = {}, {}, {}, {}
    local spaceActiveTab = "Combat"

    pcall(function() sidebar.Visible=false end); pcall(function() contentArea.Visible=false end); pcall(function() pageHolder.Visible=false end); pcall(function() closeBtn.Visible=false end)
    local spaceW = (UIS.TouchEnabled and not UIS.KeyboardEnabled) and 310 or 430
    local spaceH = (UIS.TouchEnabled and not UIS.KeyboardEnabled) and 430 or 510
    main.Size = UDim2.new(0,spaceW,0,spaceH); main.BackgroundColor3=Color3.fromRGB(11,11,13); main.BackgroundTransparency=0.02; main.ClipsDescendants=true

    local root=Instance.new("Frame",main); root.Name="SpaceShell"; root.Size=UDim2.fromScale(1,1); root.BackgroundTransparency=1; root.ZIndex=20; root.ClipsDescendants=true; corner(root,18)
    local bg=Instance.new("ImageLabel",root); bg.Name="Background"; bg.Size=UDim2.fromScale(1,1); bg.BackgroundColor3=Color3.fromRGB(10,10,12); bg.BorderSizePixel=0; bg.Image=SPACE_BG_IDS[math.clamp(math.floor(tonumber(S.spaceBgIndex) or 1),1,#SPACE_BG_IDS)]; bg.ImageTransparency=1-(S.bgIntensity or .58); bg.ScaleType=Enum.ScaleType.Crop; bg.ZIndex=20; corner(bg,18)
    local veil=Instance.new("Frame",root); veil.Size=UDim2.fromScale(1,1); veil.BackgroundColor3=Color3.fromRGB(5,5,7); veil.BackgroundTransparency=.58; veil.BorderSizePixel=0; veil.ZIndex=21; corner(veil,18)
    local glowFrame=Instance.new("Frame",root); glowFrame.Size=UDim2.new(1,-8,1,-8); glowFrame.Position=UDim2.new(0,4,0,4); glowFrame.BackgroundTransparency=1; glowFrame.ZIndex=22; glowFrame.ClipsDescendants=false; corner(glowFrame,16)
    local glow=Instance.new("UIStroke",glowFrame); glow.Name="ThemeGlow"; glow.Color=S.themeColor or COLORS.accent; glow.Thickness=1.8; glow.Transparency=.30; glow:SetAttribute("ThemeAccent",true)
    local glowGrad=Instance.new("UIGradient",glow); glowGrad.Name="RotatingThemeGlow"; glowGrad.Rotation=0
    local function glowSequence(col)
        local light=col:Lerp(Color3.new(1,1,1),0.20)
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(0.28, light), ColorSequenceKeypoint.new(0.50, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(0.72, light), ColorSequenceKeypoint.new(1.00, Color3.new(0,0,0)),
        })
    end
    glowGrad.Color=glowSequence(S.themeColor or COLORS.accent)
    glowGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0.00,0.88), NumberSequenceKeypoint.new(0.35,0.34),
        NumberSequenceKeypoint.new(0.50,0.04), NumberSequenceKeypoint.new(0.65,0.34), NumberSequenceKeypoint.new(1.00,0.88),
    })
    local glowBloom=Instance.new("UIStroke",glowFrame); glowBloom.Name="ThemeGlowBloom"; glowBloom.Color=S.themeColor or COLORS.accent; glowBloom.Thickness=4.5; glowBloom.Transparency=.78; glowBloom:SetAttribute("ThemeAccent",true)
    local bloomGrad=Instance.new("UIGradient",glowBloom); bloomGrad.Name="RotatingThemeBloom"; bloomGrad.Rotation=0; bloomGrad.Color=glowGrad.Color
    bloomGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0.00,0.97), NumberSequenceKeypoint.new(0.42,0.72),
        NumberSequenceKeypoint.new(0.50,0.38), NumberSequenceKeypoint.new(0.58,0.72), NumberSequenceKeypoint.new(1.00,0.97),
    })
    TS:Create(glow,TweenInfo.new(1.35,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=.58,Thickness=1.25}):Play()
    local oldSpaceGlowConn=rawget(_genv,"__VxyroSpaceGlowConn")
    if oldSpaceGlowConn then pcall(function() oldSpaceGlowConn:Disconnect() end) end
    local spaceGlowConn
    spaceGlowConn=RunService.RenderStepped:Connect(function(dt)
        if not glowFrame.Parent then pcall(function() spaceGlowConn:Disconnect() end); if rawget(_genv,"__VxyroSpaceGlowConn")==spaceGlowConn then _genv.__VxyroSpaceGlowConn=nil end; return end
        glowGrad.Rotation=(glowGrad.Rotation+(tonumber(dt) or 0.016)*95)%360
        bloomGrad.Rotation=glowGrad.Rotation
    end)
    _genv.__VxyroSpaceGlowConn=spaceGlowConn
    -- HookDuels-style GUI effect bridge: decorative only.
    _genv.__VxyroHookGuiParts = {
        root = root,
        background = bg,
        glowFrame = glowFrame,
        glowStroke = glow,
        widthRef = function() return main.Size.X.Offset end,
        heightRef = function() return main.Size.Y.Offset end,
        homePosition = UDim2.fromScale(0, 0),
    }
    local function refreshSpaceGlowColor(col)
        col=col or S.themeColor or COLORS.accent
        glow.Color=col; glowBloom.Color=col
        local seq=glowSequence(col)
        glowGrad.Color=seq; bloomGrad.Color=seq
    end

    local header=Instance.new("Frame",root); header.Size=UDim2.new(1,-16,0,58); header.Position=UDim2.new(0,8,0,8); header.BackgroundColor3=Color3.fromRGB(10,10,12); header.BackgroundTransparency=.18; header.BorderSizePixel=0; header.ZIndex=30; corner(header,14)
    local hst=stroke(header,S.themeColor or COLORS.accent,1,.55); hst:SetAttribute("ThemeAccent",true)
    local dot=Instance.new("Frame",header); dot.Size=UDim2.new(0,9,0,9); dot.Position=UDim2.new(0,12,.5,-4); dot.BackgroundColor3=S.themeColor or COLORS.accent; dot.BorderSizePixel=0; dot.ZIndex=32; corner(dot,9); dot:SetAttribute("ThemeAccentFill",true)
    local title=Instance.new("TextLabel",header); title.Size=UDim2.new(.56,-24,0,24); title.Position=UDim2.new(0,28,0,6); title.BackgroundTransparency=1; title.Text="ZERO HUB"; title.TextColor3=Color3.fromRGB(250,250,252); title.Font=Enum.Font.GothamBold; title.TextSize=17; title.TextXAlignment=Enum.TextXAlignment.Left; title.ZIndex=32; title.TextTruncate=Enum.TextTruncate.AtEnd
    local sub=Instance.new("TextLabel",header); sub.Size=UDim2.new(.58,-24,0,16); sub.Position=UDim2.new(0,28,0,31); sub.BackgroundTransparency=1; sub.Text="DUEL • SPACE UI"; sub.TextColor3=Color3.fromRGB(180,180,188); sub.Font=Enum.Font.GothamMedium; sub.TextSize=9; sub.TextXAlignment=Enum.TextXAlignment.Left; sub.ZIndex=32; sub.TextTruncate=Enum.TextTruncate.AtEnd
    local closeSpace=Instance.new("TextButton",header); closeSpace.Size=UDim2.new(0,36,0,36); closeSpace.Position=UDim2.new(1,-44,.5,-18); closeSpace.BackgroundColor3=Color3.fromRGB(0,0,0); closeSpace.BackgroundTransparency=.08; closeSpace.BorderSizePixel=0; closeSpace.Text="×"; closeSpace.TextColor3=Color3.fromRGB(245,245,245); closeSpace.Font=Enum.Font.GothamBold; closeSpace.TextSize=22; closeSpace.AutoButtonColor=false; closeSpace.ZIndex=32; corner(closeSpace,12)
    local cst=stroke(closeSpace,S.themeColor or COLORS.accent,1,.35); cst:SetAttribute("ThemeAccent",true)

    local tabs=Instance.new("Frame",root); tabs.Size=UDim2.new(1,-16,0,40); tabs.Position=UDim2.new(0,8,0,72); tabs.BackgroundColor3=Color3.fromRGB(8,8,10); tabs.BackgroundTransparency=.18; tabs.BorderSizePixel=0; tabs.ZIndex=30; corner(tabs,12); stroke(tabs,Color3.fromRGB(90,90,95),.8,.65)
    local tl=Instance.new("UIListLayout",tabs); tl.FillDirection=Enum.FillDirection.Horizontal; tl.Padding=UDim.new(0,3); tl.HorizontalAlignment=Enum.HorizontalAlignment.Center; tl.VerticalAlignment=Enum.VerticalAlignment.Center
    local tp=Instance.new("UIPadding",tabs); tp.PaddingLeft=UDim.new(0,5); tp.PaddingRight=UDim.new(0,5)
    local content=Instance.new("Frame",root); content.Size=UDim2.new(1,-16,1,-122); content.Position=UDim2.new(0,8,0,116); content.BackgroundColor3=Color3.fromRGB(7,7,9); content.BackgroundTransparency=.68; content.BorderSizePixel=0; content.ZIndex=29; corner(content,14); stroke(content,Color3.fromRGB(90,90,95),.8,.7)

    local function mount(n,p)
        if not p then return end; p.Parent=content; p.Size=UDim2.fromScale(1,1); p.Position=UDim2.fromScale(0,0); p.BackgroundTransparency=1; p.ZIndex=31; for _,d in ipairs(p:GetDescendants()) do if d:IsA("GuiObject") then d.ZIndex=(tonumber(d.ZIndex) or 1)+35 end end; spacePages[n]=p; pcall(function() p.ScrollBarImageTransparency=.75 end)
    end
    mount("Combat",mainPage); mount("Protect",otherPage); mount("Visual",customizationPage); mount("Settings",configPage)

    local function addTab(n,label,order)
        local b=Instance.new("TextButton",tabs); b.Name="Tab_"..n; b.LayoutOrder=order; b.Size=UDim2.new(.245,-3,1,-8); b.BackgroundColor3=Color3.fromRGB(15,15,17); b.BackgroundTransparency=.15; b.BorderSizePixel=0; b.Text=label; b.TextColor3=Color3.fromRGB(210,210,215); b.Font=Enum.Font.GothamBold; b.TextSize=(spaceW<350) and 9 or 10; b.AutoButtonColor=false; b.ZIndex=32; corner(b,9); local st=stroke(b,Color3.fromRGB(70,70,75),.8,.7); spaceTabBtns[n]={btn=b,stroke=st}
        b.Activated:Connect(function()
            spaceActiveTab=n
            for pn,p in pairs(spacePages) do p.Visible=(pn==n) end
            for tn,it in pairs(spaceTabBtns) do local on=(tn==n); it.btn.BackgroundColor3=on and (S.themeColor or COLORS.accent) or Color3.fromRGB(15,15,17); it.btn.TextColor3=on and Color3.fromRGB(0,0,0) or Color3.fromRGB(210,210,215); it.stroke.Color=on and (S.themeColor or COLORS.accent) or Color3.fromRGB(70,70,75); it.stroke.Transparency=on and .1 or .7 end
        end)
    end
    addTab("Combat","COMBAT",1); addTab("Protect","PROTECT",2); addTab("Visual","VISUAL",3); addTab("Settings","SETTINGS",4)

    -- ONE background UI only: picker + ON/OFF + opacity in a single card.
    for _, parent in ipairs({configPage, mainPage, customizationPage, otherPage}) do
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("GuiObject") then
                local n=tostring(obj.Name)
                if n=="BackgroundToggleRow" or n=="BackgroundPhotoToggle" or n=="LegacyUnifiedBackgroundToggleRow" or n=="LegacyBackgroundPhotoToggle" or n=="BgToggleRow" or n=="BgToggle" or n=="BackgroundControlRow" or n=="UnifiedBackgroundControl" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end

    configPage:SetAttribute("UnifiedBackgroundUI", true)
    local appearance=Instance.new("Frame",configPage)
    appearance.Name="SpaceAppearance"
    appearance.Size=UDim2.new(1,0,0,166)
    appearance.LayoutOrder=-1000
    appearance.BackgroundColor3=Color3.fromRGB(10,10,12)
    appearance.BackgroundTransparency=.17
    appearance.BorderSizePixel=0
    appearance.ZIndex=33
    corner(appearance,12)
    local apst=stroke(appearance,S.themeColor or COLORS.accent,1,.55); apst:SetAttribute("ThemeAccent",true)

    local apt=Instance.new("TextLabel",appearance)
    apt.Size=UDim2.new(1,-20,0,18); apt.Position=UDim2.new(0,10,0,7); apt.BackgroundTransparency=1
    apt.Text="ZERO HUB • BACKGROUND"; apt.TextColor3=Color3.fromRGB(245,245,248); apt.Font=Enum.Font.GothamBold; apt.TextSize=10; apt.TextXAlignment=Enum.TextXAlignment.Left; apt.ZIndex=34

    local tr=Instance.new("Frame",appearance)
    tr.Size=UDim2.new(1,-20,0,26); tr.Position=UDim2.new(0,10,0,27); tr.BackgroundTransparency=1; tr.ZIndex=34; tr.Visible=false
    local tlbl=Instance.new("TextLabel",tr)
    tlbl.Size=UDim2.new(0,48,1,0); tlbl.BackgroundTransparency=1; tlbl.Text="THEME"; tlbl.TextColor3=Color3.fromRGB(180,180,188); tlbl.Font=Enum.Font.GothamBold; tlbl.TextSize=9; tlbl.TextXAlignment=Enum.TextXAlignment.Left; tlbl.ZIndex=35
    local tlist=Instance.new("Frame",tr)
    tlist.Size=UDim2.new(1,-54,1,0); tlist.Position=UDim2.new(0,54,0,0); tlist.BackgroundTransparency=1; tlist.ZIndex=35
    local tll=Instance.new("UIListLayout",tlist); tll.FillDirection=Enum.FillDirection.Horizontal; tll.Padding=UDim.new(0,5); tll.VerticalAlignment=Enum.VerticalAlignment.Center
    for _,it in ipairs(SPACE_THEMES) do
        local b=Instance.new("TextButton",tlist); b.Size=UDim2.new(0,22,0,22); b.BackgroundColor3=it.color; b.BorderSizePixel=0; b.Text=""; b.AutoButtonColor=false; b.ZIndex=36; corner(b,11)
        local st=stroke(b,Color3.fromRGB(255,255,255),1,.65); spaceThemeBtns[it.name]={btn=b,stroke=st,color=it.color}
        b.Activated:Connect(function() applyThemeColor(it.color,it.name); pcall(function() if F.saveConfig then F.saveConfig(true) end end) end)
    end

    -- Single BACKGROUND control: one ON/OFF switch with the preset picker and opacity below.
    local bgControl=Instance.new("Frame",appearance)
    bgControl.Name="UnifiedBackgroundControl"
    bgControl.Size=UDim2.new(1,-20,0,112)
    bgControl.Position=UDim2.new(0,10,0,31)
    bgControl.BackgroundTransparency=1
    bgControl.ZIndex=34

    local bgHeader=Instance.new("Frame",bgControl)
    bgHeader.Size=UDim2.new(1,0,0,27); bgHeader.BackgroundTransparency=1; bgHeader.ZIndex=35
    local bgHeaderLabel=Instance.new("TextLabel",bgHeader)
    bgHeaderLabel.Size=UDim2.new(1,-72,1,0); bgHeaderLabel.BackgroundTransparency=1; bgHeaderLabel.Text="BACKGROUND"; bgHeaderLabel.TextColor3=Color3.fromRGB(180,180,188); bgHeaderLabel.Font=Enum.Font.GothamBold; bgHeaderLabel.TextSize=9; bgHeaderLabel.TextXAlignment=Enum.TextXAlignment.Left; bgHeaderLabel.ZIndex=36; bgHeaderLabel.TextTruncate=Enum.TextTruncate.AtEnd
    local bgToggle=Instance.new("TextButton",bgHeader)
    bgToggle.Name="UnifiedBackgroundToggle"; bgToggle.Size=UDim2.new(0,60,0,22); bgToggle.Position=UDim2.new(1,-60,.5,-11); bgToggle.BackgroundColor3=Color3.fromRGB(18,18,20); bgToggle.BorderSizePixel=0; bgToggle.Text="OFF"; bgToggle.TextColor3=Color3.fromRGB(235,235,238); bgToggle.Font=Enum.Font.GothamBold; bgToggle.TextSize=9; bgToggle.AutoButtonColor=false; bgToggle.ZIndex=36; corner(bgToggle,9)
    local bgToggleStroke=stroke(bgToggle,S.themeColor or COLORS.accent,1,.45); bgToggleStroke:SetAttribute("ThemeAccent",true)
    local function refreshBgToggle()
        local on=S.backgroundPhotoEnabled ~= false
        bgToggle.Text=on and "ON" or "OFF"
        bgToggle.BackgroundColor3=on and (S.themeColor or COLORS.accent) or Color3.fromRGB(18,18,20)
        bgToggle.TextColor3=on and Color3.fromRGB(0,0,0) or Color3.fromRGB(235,235,238)
    end
    bgToggle.Activated:Connect(function()
        local on=not (S.backgroundPhotoEnabled ~= false)
        if VS.setBackgroundPhotoVisual then VS.setBackgroundPhotoVisual(on) else setBackgroundPhotoEnabled(on,true) end
        refreshBgToggle(); pcall(function() if F.saveConfig then F.saveConfig(true) end end)
    end)
    local oldBgToggleVisual=VS.setBackgroundPhotoVisual
    VS.setBackgroundPhotoVisual=function(on)
        if oldBgToggleVisual then pcall(oldBgToggleVisual,on) end
        refreshBgToggle()
    end
    task.defer(refreshBgToggle)

    local blist=Instance.new("Frame",bgControl)
    blist.Name="BackgroundPresets"
    blist.Size=UDim2.new(1,0,0,30)
    blist.Position=UDim2.new(0,0,0,29)
    blist.BackgroundTransparency=1
    blist.ZIndex=35
    local bll=Instance.new("UIListLayout",blist)
    bll.FillDirection=Enum.FillDirection.Horizontal
    bll.Padding=UDim.new(0,4)
    bll.HorizontalAlignment=Enum.HorizontalAlignment.Left
    bll.VerticalAlignment=Enum.VerticalAlignment.Center
    for i,id in ipairs(SPACE_BG_IDS) do
        local b=Instance.new("TextButton",blist)
        b.Name="BG_"..i
        b.Size=UDim2.new(0,43,0,24) -- 16:9 selector frame
        b.BackgroundColor3=Color3.fromRGB(16,16,19)
        b.BorderSizePixel=0
        b.Text=""
        b.AutoButtonColor=false
        b.ZIndex=36
        b.ClipsDescendants=true
        corner(b,7)

        local im=Instance.new("ImageLabel",b)
        im.Name="Preview"
        im.AnchorPoint=Vector2.new(.5,.5)
        im.Position=UDim2.fromScale(.5,.5)
        im.Size=UDim2.new(1,-2,1,-2)
        im.BackgroundColor3=Color3.fromRGB(8,8,10)
        im.BackgroundTransparency=0
        im.BorderSizePixel=0
        im.Image=id
        im.ScaleType=Enum.ScaleType.Fit
        im.ImageTransparency=.02
        im.ZIndex=37
        corner(im,6)

        local shade=Instance.new("Frame",b)
        shade.Name="PreviewShade"
        shade.Size=UDim2.fromScale(1,1)
        shade.BackgroundColor3=Color3.fromRGB(0,0,0)
        shade.BackgroundTransparency=.62
        shade.BorderSizePixel=0
        shade.ZIndex=38
        shade.Active=false
        corner(shade,6)

        local ct=Instance.new("TextLabel",b)
        ct.Name="Index"
        ct.AnchorPoint=Vector2.new(1,1)
        ct.Position=UDim2.new(1,-3,1,-2)
        ct.Size=UDim2.new(0,14,0,13)
        ct.BackgroundColor3=Color3.fromRGB(0,0,0)
        ct.BackgroundTransparency=.24
        ct.BorderSizePixel=0
        ct.Text=tostring(i)
        ct.TextColor3=Color3.fromRGB(255,255,255)
        ct.Font=Enum.Font.GothamBold
        ct.TextSize=8
        ct.TextXAlignment=Enum.TextXAlignment.Center
        ct.TextYAlignment=Enum.TextYAlignment.Center
        ct.ZIndex=39
        corner(ct,5)

        local st=stroke(b,Color3.fromRGB(110,110,118),.9,.72)
        st.Name="BackgroundPreviewStroke"
        spaceBgBtns[i]={btn=b,stroke=st,image=im,shade=shade}
        b.Activated:Connect(function()
            S.spaceBgIndex=i
            for j,it in pairs(spaceBgBtns) do
                local selected = j == i
                pcall(function()
                    TS:Create(it.stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Transparency = selected and 0.02 or 0.70,
                        Thickness = selected and 1.8 or 0.8,
                        Color = selected and (S.themeColor or COLORS.accent) or Color3.fromRGB(110,110,118)
                    }):Play()
                    if it.shade then
                        TS:Create(it.shade, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = selected and 0.48 or 0.62}):Play()
                    end
                    if it.image then
                        TS:Create(it.image, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = selected and 0 or 0.04}):Play()
                    end
                end)
            end
            applyBackground(id)
            pcall(function() if F.saveConfig then F.saveConfig(true) end end)
        end)
    end

    local trans=Instance.new("TextLabel",bgControl)
    trans.Name="BackgroundOpacityLabel"
    trans.Size=UDim2.new(1,-62,0,22); trans.Position=UDim2.new(0,2,0,79); trans.BackgroundTransparency=1
    trans.TextColor3=Color3.fromRGB(205,205,212); trans.Font=Enum.Font.GothamBold; trans.TextSize=9; trans.TextXAlignment=Enum.TextXAlignment.Left; trans.TextYAlignment=Enum.TextYAlignment.Center
    trans.ZIndex=35; trans.TextTruncate=Enum.TextTruncate.AtEnd; trans.TextWrapped=false; trans.Text="OPACITY  "..tostring(math.floor((S.bgIntensity or .58)*100)).."%"
    local minus=Instance.new("TextButton",bgControl)
    minus.Name="BackgroundOpacityMinus"; minus.Size=UDim2.new(0,24,0,22); minus.Position=UDim2.new(1,-66,0,79); minus.BackgroundColor3=Color3.fromRGB(18,18,20); minus.BorderSizePixel=0; minus.Text="−"; minus.TextColor3=Color3.fromRGB(235,235,238); minus.Font=Enum.Font.GothamBold; minus.TextSize=14; minus.AutoButtonColor=false; minus.ZIndex=36; corner(minus,7)
    local mst=stroke(minus,S.themeColor or COLORS.accent,1,.55); mst:SetAttribute("ThemeAccent",true)
    local plus=Instance.new("TextButton",bgControl)
    plus.Name="BackgroundOpacityPlus"; plus.Size=UDim2.new(0,24,0,22); plus.Position=UDim2.new(1,-36,0,79); plus.BackgroundColor3=Color3.fromRGB(18,18,20); plus.BorderSizePixel=0; plus.Text="+"; plus.TextColor3=Color3.fromRGB(235,235,238); plus.Font=Enum.Font.GothamBold; plus.TextSize=14; plus.AutoButtonColor=false; plus.ZIndex=36; corner(plus,7)
    local pst=stroke(plus,S.themeColor or COLORS.accent,1,.55); pst:SetAttribute("ThemeAccent",true)

    local function setOpacity(v) S.bgIntensity=math.clamp(tonumber(v) or .58,.12,.95); local id=S.currentBgId; if not id or id=="" then id=SPACE_BG_IDS[math.clamp(math.floor(tonumber(S.spaceBgIndex) or 1),1,#SPACE_BG_IDS)] end; applyBackground(id,true); pcall(function() if F.saveConfig then F.saveConfig(true) end end); pcall(function() if _G.__VxyroSpaceRefreshUI then _G.__VxyroSpaceRefreshUI() end end) end
    minus.Activated:Connect(function() setOpacity((S.bgIntensity or .58)-.08) end); plus.Activated:Connect(function() setOpacity((S.bgIntensity or .58)+.08) end)

    local floatCard=Instance.new("Frame",otherPage); floatCard.Name="SpaceFloatCard"; floatCard.Size=UDim2.new(1,0,0,74); floatCard.LayoutOrder=-1000; floatCard.BackgroundColor3=Color3.fromRGB(10,10,12); floatCard.BackgroundTransparency=.16; floatCard.BorderSizePixel=0; floatCard.ZIndex=33; corner(floatCard,12); local fst=stroke(floatCard,S.themeColor or COLORS.accent,1,.55); fst:SetAttribute("ThemeAccent",true)
    local fl=Instance.new("TextLabel",floatCard); fl.Size=UDim2.new(1,-92,0,18); fl.Position=UDim2.new(0,10,0,9); fl.BackgroundTransparency=1; fl.Text="FLOAT"; fl.TextColor3=Color3.fromRGB(245,245,248); fl.Font=Enum.Font.GothamBold; fl.TextSize=11; fl.TextXAlignment=Enum.TextXAlignment.Left; fl.ZIndex=34
    local fsub=Instance.new("TextLabel",floatCard); fsub.Size=UDim2.new(1,-92,0,22); fsub.Position=UDim2.new(0,10,0,30); fsub.BackgroundTransparency=1; fsub.Text="Space float logic • mobile button"; fsub.TextColor3=Color3.fromRGB(165,165,173); fsub.Font=Enum.Font.GothamMedium; fsub.TextSize=8; fsub.TextXAlignment=Enum.TextXAlignment.Left; fsub.TextTruncate=Enum.TextTruncate.AtEnd; fsub.ZIndex=34
    local fbtn=Instance.new("TextButton",floatCard); fbtn.Size=UDim2.new(0,70,0,32); fbtn.Position=UDim2.new(1,-80,.5,-16); fbtn.BackgroundColor3=Color3.fromRGB(18,18,20); fbtn.BorderSizePixel=0; fbtn.Text="OFF"; fbtn.TextColor3=Color3.fromRGB(235,235,238); fbtn.Font=Enum.Font.GothamBold; fbtn.TextSize=9; fbtn.AutoButtonColor=false; fbtn.ZIndex=35; corner(fbtn,10); local fbs=stroke(fbtn,S.themeColor or COLORS.accent,1,.45); fbs:SetAttribute("ThemeAccent",true)

    _G.__VxyroSpaceApplyTheme=function(col,name)
        col=col or S.themeColor or COLORS.accent; pcall(function() refreshSpaceGlowColor(col); hst.Color=col; cst.Color=col; dot.BackgroundColor3=col; apst.Color=col; fst.Color=col; fbs.Color=col end)
        for n,it in pairs(spaceTabBtns) do local on=n==spaceActiveTab; it.btn.BackgroundColor3=on and col or Color3.fromRGB(15,15,17); it.btn.TextColor3=on and Color3.fromRGB(0,0,0) or Color3.fromRGB(210,210,215); it.stroke.Color=on and col or Color3.fromRGB(70,70,75) end
        for n,it in pairs(spaceThemeBtns) do local on=tostring(name or ""):lower()==n:lower(); it.stroke.Color=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(120,120,125); it.stroke.Transparency=on and .05 or .68; it.stroke.Thickness=on and 1.7 or 1 end
    end
    _G.__VxyroSpaceBGSync=function(resolved,enabled)
        local id=resolved; if not id or id=="" then id=SPACE_BG_IDS[math.clamp(math.floor(tonumber(S.spaceBgIndex) or 1),1,#SPACE_BG_IDS)] end
        pcall(function() bg.Image=id; bg.Visible=(enabled~=false and id~=""); bg.ImageTransparency=bg.Visible and math.clamp(0.06 + (1-(S.bgIntensity or .58))*0.24, 0, 0.88) or 1; veil.BackgroundTransparency=bg.Visible and .66 or .18 end)
    end
    _G.__VxyroSpaceRefreshUI=function()
        pcall(function() _G.__VxyroSpaceApplyTheme(S.themeColor,S.currentThemeName) end)
        local idx=math.clamp(math.floor(tonumber(S.spaceBgIndex) or 1),1,#SPACE_BG_IDS)
        for i,it in pairs(spaceBgBtns) do
            local on=i==idx
            it.stroke.Color=on and (S.themeColor or COLORS.accent) or Color3.fromRGB(110,110,118)
            it.stroke.Transparency=on and .02 or .70
            it.stroke.Thickness=on and 1.8 or .8
            if it.shade then it.shade.BackgroundTransparency=on and .48 or .62 end
            if it.image then it.image.ImageTransparency=on and 0 or .04 end
        end
        trans.Text="OPACITY  "..tostring(math.floor((S.bgIntensity or .58)*100)).."%"; refreshBgToggle();
        local on=S.floatEnabled==true; fbtn.Text=on and "ON" or "OFF"; fbtn.BackgroundColor3=on and (S.themeColor or COLORS.accent) or Color3.fromRGB(18,18,20); fbtn.TextColor3=on and Color3.fromRGB(0,0,0) or Color3.fromRGB(235,235,238)
        pcall(function() _G.__VxyroSpaceBGSync(S.currentBgId,S.backgroundPhotoEnabled~=false) end)
    end
    fbtn.Activated:Connect(function() F.toggleFloat() end); closeSpace.Activated:Connect(function() pcall(function() if type(_G.__VxyroHideGui) == "function" then _G.__VxyroHideGui() end end) end)
    for n,p in pairs(spacePages) do p.Visible=(n==spaceActiveTab) end
    task.defer(function() pcall(function() _G.__VxyroSpaceRefreshUI() end) end)
end

local function addOtherInfo(text, order)
    local holder = Instance.new("Frame", otherPage)
    holder.Size = UDim2.new(1, 0, 0, 40)
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order or 1
    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 5, 0, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    lbl.BackgroundTransparency = 0.18
    lbl.BorderSizePixel = 0
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 5
    corner(lbl, 10)
    stroke(lbl, Color3.fromRGB(90, 90, 90), 1, 0.55)
end

addOtherInfo("Vyxro Duel", 1)
addOtherInfo("Menu layout by VXYRO • 4-page navigation", 2)
addOtherInfo("Save Config restores supported toggle states when the script is executed again.", 3)

local Tabs = Instance.new("Frame", main)
Tabs.Name = "LegacyTabs"
Tabs.Size = UDim2.new(0, 0, 0, 0)
Tabs.Visible = false
Tabs.BackgroundTransparency = 1
Tabs.BorderSizePixel = 0
Tabs.ZIndex = 0
Tabs.Parent = main

local tabButtons = {}
local tabDefs = {
    {name = "Main", page = mainPage, order = 1},
    {name = "Customization", page = customizationPage, order = 2},
    {name = "Config", page = configPage, order = 3},
    {name = "Other", page = otherPage, order = 4},
}

local function setTab(name)
    local accent = S.themeColor or COLORS.accent
    for _, def in ipairs(tabDefs) do
        local on = def.name == name
        def.page.Visible = on
        local btn = tabButtons[def.name]
        if btn then
            btn:SetAttribute("ThemeIsActive", on)
            btn.BackgroundColor3 = on and accent or Color3.fromRGB(18, 18, 18)
            btn.BackgroundTransparency = on and 0.02 or 0.34
            btn.TextColor3 = on and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(245, 245, 245)
            local st = btn:FindFirstChildOfClass("UIStroke")
            if st then
                st.Color = on and accent or Color3.fromRGB(120, 120, 120)
                st.Transparency = on and 0.10 or 0.5
            end
        end
    end
end

for i, def in ipairs(tabDefs) do
    local btn = Instance.new("TextButton", tabContainer)
    btn.Name = def.name
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.BackgroundTransparency = 0.34
    btn.BorderSizePixel = 0
    btn.Text = def.name
    btn.TextColor3 = Color3.fromRGB(192, 198, 210)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.LayoutOrder = i
    btn.ZIndex = 5
    btn:SetAttribute("ThemeActive", true)
    btn:SetAttribute("ThemeIsActive", false)
    corner(btn, 14)
    local tabStroke = stroke(btn, Color3.fromRGB(88, 88, 88), 1, 0.35)
    tabStroke:SetAttribute("ThemeAccent", true)
    btn.MouseEnter:Connect(function()
        if btn:GetAttribute("ThemeIsActive") ~= true then
            TS:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.16}):Play()
        end
        TS:Create(tabStroke, TweenInfo.new(0.12), {Transparency = btn:GetAttribute("ThemeIsActive") and 0.08 or 0.24}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if btn:GetAttribute("ThemeIsActive") ~= true then
            TS:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.34}):Play()
        end
        TS:Create(tabStroke, TweenInfo.new(0.12), {Transparency = btn:GetAttribute("ThemeIsActive") and 0.18 or 0.5}):Play()
    end)
    btn.Activated:Connect(function()
        if S._anyKeyListening then return end
        local sc = btn:FindFirstChild("TabClickScale") or Instance.new("UIScale")
        sc.Name = "TabClickScale"
        sc.Scale = 1
        sc.Parent = btn
        TS:Create(sc, TweenInfo.new(0.06, Enum.EasingStyle.Quad), {Scale = 0.95}):Play()
        TS:Create(btn, TweenInfo.new(0.06), {BackgroundTransparency = 0.06}):Play()
        local ripple = Instance.new("Frame")
        ripple.Name = "TabRipple"
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Size = UDim2.new(0, 8, 0, 8)
        ripple.BackgroundColor3 = S.themeColor or COLORS.accent
        ripple.BackgroundTransparency = 0.45
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 7
        ripple.Parent = btn
        corner(ripple, 99)
        local span = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.0
        TS:Create(ripple, TweenInfo.new(0.32, Enum.EasingStyle.Quart), {Size = UDim2.new(0, span, 0, span), BackgroundTransparency = 1}):Play()
        task.delay(0.34, function() if ripple and ripple.Parent then ripple:Destroy() end end)
        setTab(def.name)
        task.delay(0.07, function()
            if sc and sc.Parent then TS:Create(sc, TweenInfo.new(0.16, Enum.EasingStyle.Quint), {Scale = 1}):Play() end
        end)
        task.delay(0.08, function()
            if btn and btn.Parent and btn:GetAttribute("ThemeIsActive") ~= true then
                TS:Create(btn, TweenInfo.new(0.10), {BackgroundTransparency = 0.34}):Play()
            end
        end)
    end)
    tabButtons[def.name] = btn
end


-- ===== VXYRO ULTRA VISUAL LAYER =====
-- Decorative-only effects: no feature logic is changed.
do
    local function safeTween(obj, info, goals)
        if not obj or not obj.Parent then return end
        pcall(function() TS:Create(obj, info, goals):Play() end)
    end

    -- Soft neon edge rails.
    local rails = {}
    local railSpecs = {
        {name = "TopRail", size = UDim2.new(1, -74, 0, 2), pos = UDim2.new(0, 38, 0, 8)},
        {name = "BottomRail", size = UDim2.new(1, -74, 0, 2), pos = UDim2.new(0, 38, 1, -10)},
        {name = "LeftRail", size = UDim2.new(0, 2, 1, -74), pos = UDim2.new(0, 10, 0, 37)},
        {name = "RightRail", size = UDim2.new(0, 2, 1, -74), pos = UDim2.new(1, -12, 0, 37)},
    }
    for _, spec in ipairs(railSpecs) do
        local rail = Instance.new("Frame", main)
        rail.Name = "VXYRO" .. spec.name
        rail.Size = spec.size
        rail.Position = spec.pos
        rail.BackgroundColor3 = S.themeColor or COLORS.accent
        rail.BackgroundTransparency = 0.72
        rail.BorderSizePixel = 0
        rail.ZIndex = 2
        rail.Active = false
        rail:SetAttribute("ThemeAccentFill", true)
        corner(rail, 2)
        table.insert(rails, rail)
    end

    -- Animated scanline for the glass panel.
    local scanline = Instance.new("Frame", main)
    scanline.Name = "VXYROScanline"
    scanline.Size = UDim2.new(1, -28, 0, 1)
    scanline.Position = UDim2.new(0, 14, 0, -4)
    scanline.BackgroundColor3 = S.themeColor or COLORS.accent
    scanline.BackgroundTransparency = 0.56
    scanline.BorderSizePixel = 0
    scanline.ZIndex = 2
    scanline.Active = false
    scanline:SetAttribute("ThemeAccentFill", true)
    corner(scanline, 2)
    safeTween(scanline,
        TweenInfo.new(4.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false),
        {Position = UDim2.new(0, 14, 1, 3)}
    )

    -- Small floating particles to give the menu a living background.
    local particleFolder = Instance.new("Frame", main)
    particleFolder.Name = "VXYROParticles"
    particleFolder.Size = UDim2.new(1, 0, 1, 0)
    particleFolder.BackgroundTransparency = 1
    particleFolder.BorderSizePixel = 0
    particleFolder.ZIndex = 2
    particleFolder.Active = false

    local rng = Random.new()
    for i = 1, 20 do
        local p = Instance.new("Frame", particleFolder)
        p.Name = "Particle" .. i
        local s = rng:NextInteger(2, 4)
        p.Size = UDim2.new(0, s, 0, s)
        p.Position = UDim2.new(rng:NextNumber(0.02, 0.96), 0, rng:NextNumber(0.05, 0.95), 0)
        p.BackgroundColor3 = (i % 3 == 0) and Color3.fromRGB(255, 255, 255) or (S.themeColor or COLORS.accent)
        p.BackgroundTransparency = rng:NextNumber(0.45, 0.82)
        p.BorderSizePixel = 0
        p.ZIndex = 2
        p.Active = false
        p:SetAttribute("ThemeAccentFill", (i % 3 ~= 0))
        corner(p, 99)

        local targetX = math.clamp(p.Position.X.Scale + rng:NextNumber(-0.035, 0.035), 0.01, 0.98)
        local targetY = math.clamp(p.Position.Y.Scale + rng:NextNumber(-0.10, 0.10), 0.03, 0.97)
        local dur = rng:NextNumber(2.4, 5.6)
        safeTween(p,
            TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {
                Position = UDim2.new(targetX, 0, targetY, 0),
                BackgroundTransparency = rng:NextNumber(0.18, 0.58),
                Size = UDim2.new(0, s + rng:NextInteger(1, 3), 0, s + rng:NextInteger(1, 3)),
            }
        )
    end

    -- Four corner brackets for a tech-frame look.
    local bracketColor = S.themeColor or COLORS.accent
    local function bracket(name, pos, flipX, flipY)
        local holder = Instance.new("Frame", main)
        holder.Name = name
        holder.Size = UDim2.new(0, 26, 0, 26)
        holder.Position = pos
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.ZIndex = 3
        holder.Active = false

        local h = Instance.new("Frame", holder)
        h.Size = UDim2.new(0, 18, 0, 2)
        h.Position = flipX and UDim2.new(1, -18, 0, 0) or UDim2.new(0, 0, 0, 0)
        h.BackgroundColor3 = bracketColor
        h.BackgroundTransparency = 0.35
        h.BorderSizePixel = 0
        h.ZIndex = 3
        h:SetAttribute("ThemeAccentFill", true)
        corner(h, 2)

        local v = Instance.new("Frame", holder)
        v.Size = UDim2.new(0, 2, 0, 18)
        v.Position = flipX and UDim2.new(1, -2, 0, 0) or UDim2.new(0, 0, 0, 0)
        v.BackgroundColor3 = bracketColor
        v.BackgroundTransparency = 0.35
        v.BorderSizePixel = 0
        v.ZIndex = 3
        v:SetAttribute("ThemeAccentFill", true)
        corner(v, 2)

        if flipY then
            h.Position = UDim2.new(h.Position.X.Scale, h.Position.X.Offset, 1, -2)
            v.Position = UDim2.new(v.Position.X.Scale, v.Position.X.Offset, 1, -18)
        end
        safeTween(h, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.08})
        safeTween(v, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0.08})
    end
    bracket("VXYROBracketTL", UDim2.new(0, 18, 0, 18), false, false)
    bracket("VXYROBracketTR", UDim2.new(1, -44, 0, 18), true, false)
    bracket("VXYROBracketBL", UDim2.new(0, 18, 1, -44), false, true)
    bracket("VXYROBracketBR", UDim2.new(1, -44, 1, -44), true, true)

    -- Header status chip.
    local status = Instance.new("Frame", main)
    status.Name = "VXYROStatus"
    status.Size = UDim2.new(0, 92, 0, 24)
    status.Position = UDim2.new(0, SIDEBAR_W + 20, 0, 15)
    status.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    status.BackgroundTransparency = 0.15
    status.BorderSizePixel = 0
    status.ZIndex = 8
    status.Active = false
    corner(status, 12)
    local statusStroke = stroke(status, S.themeColor or COLORS.accent, 1, 0.45)
    statusStroke:SetAttribute("ThemeAccent", true)
    local statusDot = Instance.new("Frame", status)
    statusDot.Size = UDim2.new(0, 7, 0, 7)
    statusDot.Position = UDim2.new(0, 10, 0.5, -3)
    statusDot.BackgroundColor3 = S.themeColor or COLORS.accent
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 9
    statusDot.Active = false
    statusDot:SetAttribute("ThemeAccentFill", true)
    corner(statusDot, 99)
    local dotGlow = stroke(statusDot, S.themeColor or COLORS.accent, 2, 0.48)
    dotGlow:SetAttribute("ThemeAccent", true)
    safeTween(dotGlow, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.82, Thickness = 1})
    local statusLabel = Instance.new("TextLabel", status)
    statusLabel.Size = UDim2.new(1, -26, 1, 0)
    statusLabel.Position = UDim2.new(0, 24, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "ZERO HUB  •  LIVE"
    statusLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 9
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 9

    -- More responsive, dimensional tabs.
    for _, def in ipairs(tabDefs) do
        local btn = tabButtons[def.name]
        if btn then
            local underGlow = Instance.new("Frame", btn)
            underGlow.Name = "VXYROTabGlow"
            underGlow.AnchorPoint = Vector2.new(0.5, 1)
            underGlow.Size = UDim2.new(0.72, 0, 0, 4)
            underGlow.Position = UDim2.new(0.5, 0, 1, 2)
            underGlow.BackgroundColor3 = S.themeColor or COLORS.accent
            underGlow.BackgroundTransparency = 1
            underGlow.BorderSizePixel = 0
            underGlow.ZIndex = 6
            underGlow.Active = false
            underGlow:SetAttribute("ThemeAccentFill", true)
            corner(underGlow, 2)

            local iconBar = Instance.new("Frame", btn)
            iconBar.Name = "VXYROTabIndicator"
            iconBar.Size = UDim2.new(0, 3, 0, 16)
            iconBar.Position = UDim2.new(0, 8, 0.5, -8)
            iconBar.BackgroundColor3 = S.themeColor or COLORS.accent
            iconBar.BackgroundTransparency = 1
            iconBar.BorderSizePixel = 0
            iconBar.ZIndex = 6
            iconBar.Active = false
            iconBar:SetAttribute("ThemeAccentFill", true)
            corner(iconBar, 2)

            btn:GetAttributeChangedSignal("ThemeIsActive"):Connect(function()
                local on = btn:GetAttribute("ThemeIsActive") == true
                local accent = S.themeColor or COLORS.accent
                safeTween(underGlow, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = on and 0.08 or 1,
                    Size = on and UDim2.new(0.78, 0, 0, 4) or UDim2.new(0.72, 0, 0, 4),
                })
                safeTween(iconBar, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    BackgroundTransparency = on and 0.02 or 1,
                })
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = accent
                end
            end)
        end
    end

    -- Slow breathing animation on the main border.
    safeTween(mainStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Transparency = 0.24,
        Thickness = 1.8,
    })
    safeTween(topHighlight, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.44,
    })

    -- Give the close/minimize controls a soft ring pulse.
    for _, control in ipairs({closeBtn, miniBtn}) do
        if control then
            local ring = stroke(control, S.themeColor or COLORS.accent, 2, 0.72)
            ring.Name = "VXYROSoftRing"
            ring:SetAttribute("ThemeAccent", true)
            safeTween(ring, TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                Transparency = 0.88,
                Thickness = 3,
            })
        end
    end
end

local activeTab = "Main"
setTab(activeTab)
applyThemeColor(S.themeColor or COLORS.accent, S.currentThemeName or currentThemeName)
setBackgroundPhotoEnabled(S.backgroundPhotoEnabled ~= false, true)
pcall(function() if _G.__VxyroSpaceRefreshUI then _G.__VxyroSpaceRefreshUI() end end)

-- Keep the Open GUI button text consistently white across all themes.
local function forceOpenGuiButtonWhite()
    if not miniBtn or not miniBtn.Parent then return end
    miniBtn.TextColor3 = Color3.fromRGB(192, 198, 210)
    miniBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    miniBtn.TextStrokeTransparency = 0.35
    -- UIGradient can tint a TextButton's visual content, so keep the Open GUI button gradient-free.
    for _, child in ipairs(miniBtn:GetChildren()) do
        if child:IsA("UIGradient") then
            child:Destroy()
        end
    end
end

forceOpenGuiButtonWhite()

-- HookDuels-style GUI effects: opening/closing + circular click ripple.
local __hookFx = rawget(_genv, "__VxyroHookGuiFx") or {}

local function __hookFxTween(obj, info, props)
    if not obj or not obj.Parent then return nil end
    local ok, tw = pcall(function() return TweenService:Create(obj, info, props) end)
    if ok and tw then
        tw:Play()
        return tw
    end
    return nil
end

local function __hookFxClick(button, accent)
    if not button or not button.Parent then return end
    if button:GetAttribute("__HookFxClickBound") == true then return end
    button:SetAttribute("__HookFxClickBound", true)
    button.ClipsDescendants = true
    button.MouseButton1Click:Connect(function()
        local pos = button.AbsolutePosition
        local m = UIS:GetMouseLocation()
        local px = m.X - pos.X
        local py = m.Y - pos.Y
        if px < 0 or px > button.AbsoluteSize.X or py < 0 or py > button.AbsoluteSize.Y then
            px, py = button.AbsoluteSize.X * 0.5, button.AbsoluteSize.Y * 0.5
        end
        local ripple = Instance.new("Frame")
        ripple.Name = "HookClickRipple"
        ripple.BackgroundColor3 = S.themeColor or accent or COLORS.accent
        ripple.BackgroundTransparency = 0.52
        ripple.Size = UDim2.fromOffset(0,0)
        ripple.AnchorPoint = Vector2.new(.5,.5)
        ripple.Position = UDim2.fromOffset(px,py)
        ripple.BorderSizePixel = 0
        ripple.ZIndex = (tonumber(button.ZIndex) or 1) + 6
        ripple.Active = false
        ripple.Parent = button
        corner(ripple,99)
        local tw = __hookFxTween(ripple,TweenInfo.new(.46,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
            Size = UDim2.fromOffset(240,240),
            BackgroundTransparency = 1,
        })
        if tw then
            tw.Completed:Connect(function() pcall(function() ripple:Destroy() end) end)
        else
            task.delay(.52,function() pcall(function() ripple:Destroy() end) end)
        end
    end)
end

local function __hookFxBindAll(rootGui)
    if not rootGui then return end
    for _,obj in ipairs(rootGui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            __hookFxClick(obj, S.themeColor or COLORS.accent)
        end
    end
end

local function __hookFxOpen()
    local parts = rawget(_genv,"__VxyroHookGuiParts")
    if not parts or not parts.root or not parts.root.Parent then return end
    local r,b,gs = parts.root,parts.background,parts.glowStroke
    local w = math.max(100, math.floor((parts.widthRef and parts.widthRef() or 300)+.5))
    local h = math.max(100, math.floor((parts.heightRef and parts.heightRef() or 420)+.5))
    r.Size = UDim2.fromOffset(w,h)
    r.Position = parts.homePosition or UDim2.fromScale(0,0)
    r.BackgroundTransparency = 1
    -- Preserve the selected background across close/open. On first launch the
    -- image may start transparent; on later opens its current state is kept.
    if b then
        pcall(function()
            local resolved = resolveBgId(S.currentBgId or "")
            b.Image = resolved
            b.Visible = (S.backgroundPhotoEnabled ~= false and resolved ~= "")
        end)
    end
    if gs then gs.Transparency = 1 end
    __hookFxTween(r,TweenInfo.new(.50,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
        Size=UDim2.fromOffset(w,h),
        Position=parts.homePosition or UDim2.fromScale(0,0),
    })
    if b then
        __hookFxTween(b,TweenInfo.new(.62,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
            ImageTransparency=math.clamp(1-(S.bgIntensity or .58),0,1),
        })
    end
    if gs then
        __hookFxTween(gs,TweenInfo.new(.34,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
            Transparency=.25,
        })
    end
end

local function __hookFxClose()
    local parts = rawget(_genv,"__VxyroHookGuiParts")
    if not parts or not parts.root or not parts.root.Parent then return end
    local r,gs = parts.root,parts.glowStroke
    local w = math.max(100, math.floor((parts.widthRef and parts.widthRef() or 300)+.5))
    local h = math.max(100, math.floor((parts.heightRef and parts.heightRef() or 420)+.5))
    -- Keep the selected background image untouched during close. The main GUI is
    -- hidden after this tween, and the image must retain its state for the next open.
    __hookFxTween(r,TweenInfo.new(.30,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
        Size=UDim2.fromOffset(w*.3,h*.4),
        Position=UDim2.new(0,0,0,40),
        BackgroundTransparency=1,
    })
    if gs then __hookFxTween(gs,TweenInfo.new(.24,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=1}) end
end

local function __hookFxRefreshBindings()
    pcall(function() __hookFxBindAll(main) end)
    __hookFxClick(miniBtn, S.themeColor or COLORS.accent)
    __hookFxClick(closeBtn, S.themeColor or COLORS.accent)
end

_G.__VxyroHookGuiFx = {
    refresh = __hookFxRefreshBindings,
    open = __hookFxOpen,
    close = __hookFxClose,
}

__hookFxRefreshBindings()

local function __restoreSpaceBackgroundVisual()
    -- Re-apply the selected photo every time the main GUI is shown. This is
    -- intentionally visual-only: it does not change the background toggle state.
    pcall(function()
        if _G.__VxyroSpaceBGSync then
            local resolved = resolveBgId(S.currentBgId or "")
            local photoEnabled = S.backgroundPhotoEnabled ~= false
            _G.__VxyroSpaceBGSync(resolved, photoEnabled)
        end
    end)
    pcall(function()
        if bgAsset then
            local resolved = resolveBgId(S.currentBgId or "")
            local photoEnabled = S.backgroundPhotoEnabled ~= false and resolved ~= ""
            bgAsset.Image = resolved
            bgAsset.Visible = photoEnabled
            bgAsset.ImageTransparency = photoEnabled and (1 - (S.bgIntensity or .58)) or 1
        end
        if bgVeil then
            bgVeil.BackgroundTransparency = (S.backgroundPhotoEnabled ~= false) and .32 or .58
        end
    end)
end

local function showGui()
    if not main then return end
    forceOpenGuiButtonWhite()
    main.Visible = true
    miniBtn.Visible = false
    mainUIScale.Scale = math.max(0.5, guiScale * 0.90)
    TS:Create(mainUIScale, TweenInfo.new(0.34, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Scale = guiScale
    }):Play()
    -- Restore the photo before the shell animation starts, then sync again after
    -- the tween so the close/open animation can never leave the image transparent.
    pcall(__restoreSpaceBackgroundVisual)
    pcall(__hookFxOpen)
    task.defer(function() task.wait(0.08); pcall(__restoreSpaceBackgroundVisual) end)
    pcall(function()
        if _G.__VxyroHookGuiFx and _G.__VxyroHookGuiFx.refresh then _G.__VxyroHookGuiFx.refresh() end
    end)
    pcall(function()
        if F.applyMobileButtonsHidden then F.applyMobileButtonsHidden() end
    end)
end

local function hideGui()
    if not main then return end
    forceOpenGuiButtonWhite()
    pcall(__hookFxClose)
    TS:Create(mainUIScale, TweenInfo.new(0.26, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        Scale = math.max(0.5, guiScale * 0.94)
    }):Play()
    task.delay(0.28, function()
        if main and main.Parent then
            main.Visible = false
            miniBtn.Visible = true
            local parts=rawget(_genv,"__VxyroHookGuiParts")
            if parts and parts.root and parts.root.Parent then
                parts.root.Size=UDim2.fromScale(1,1)
                parts.root.Position=parts.homePosition or UDim2.fromScale(0,0)
            end
            -- Do not clear or disable the selected image while the GUI is hidden.
            -- It will be shown again by __restoreSpaceBackgroundVisual on reopen.
        end
    end)
end

_G.__VxyroHideGui = hideGui
closeBtn.Activated:Connect(hideGui)
miniBtn.Activated:Connect(showGui)
miniBtn:GetPropertyChangedSignal("TextColor3"):Connect(function()
    if miniBtn.TextColor3 ~= Color3.fromRGB(255, 255, 255) then
        miniBtn.TextColor3 = Color3.fromRGB(192, 198, 210)
    end
end)

local function applyGuiScale(v, skipSave)
    v = math.clamp(tonumber(v) or 1, 0.60, 1.35)
    guiScale = math.floor(v * 100 + 0.5) / 100
    mainUIScale.Scale = guiScale
    if miniScaleObj then
        miniScaleObj.Scale = guiScale
    end
    S.uiScaleValue = math.floor(guiScale * 100 + 0.5)
    if UI.guiScaleLbl then
        UI.guiScaleLbl.Text = string.format("%.0f%%", guiScale * 100)
    end
    if not skipSave then
        pcall(F.saveConfig)
    end
    return guiScale
end

_G._VersincApplyGuiScale = applyGuiScale
_G._VersincGetGuiScale = function() return guiScale end
_G._VersincSyncGui = function()
    pcall(function() applyGuiScale(guiScale, true) end)
    pcall(function() applyBackground(S.currentBgId or "", true) end)
    pcall(function() setBackgroundPhotoEnabled(S.backgroundPhotoEnabled ~= false, true) end)
end

_applyHubPosition()
local lo = 0
local function LO() lo = lo + 1; return lo end

local function section(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 27)
    f.BackgroundTransparency = 1
    f.LayoutOrder = LO()
    local accentLine = Instance.new("Frame", f)
    accentLine.Size = UDim2.new(0, 3, 0, 14)
    accentLine.Position = UDim2.new(0, 4, 0.5, -7)
    accentLine.BackgroundColor3 = COLORS.accentStrong
    accentLine.BackgroundTransparency = 0.04
    accentLine.BorderSizePixel = 0
    accentLine.ZIndex = 5
    accentLine:SetAttribute("ThemeAccentFill", true)
    corner(accentLine, 2)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -18, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text:upper()
    l.TextColor3 = COLORS.accentStrong
    l.Font = Enum.Font.GothamBlack
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 5
    l:SetAttribute("ThemeAccentText", true)
    return f
end

local function mkRow(parent, h)
    local effectiveH = (h == nil or h == 34) and 38 or h
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, effectiveH)
    f.BackgroundColor3 = COLORS.row
    f.BackgroundTransparency = 0.20
    f.BorderSizePixel = 0
    f.LayoutOrder = LO()
    f.ZIndex = 4
    corner(f, 11)
    local rowStroke = stroke(f, COLORS.stroke, 1, 0.76)
    rowStroke.Name = "RowStroke"
    rowStroke:SetAttribute("ThemeAccent", true)

    local hover = Instance.new("Frame", f)
    hover.Name = "HoverAccent"
    hover.Size = UDim2.new(0, 3, 0, 18)
    hover.Position = UDim2.new(0, 4, 0.5, -9)
    hover.BackgroundColor3 = S.themeColor or COLORS.accent
    hover.BackgroundTransparency = 1
    hover.BorderSizePixel = 0
    hover.ZIndex = 5
    hover:SetAttribute("ThemeAccentFill", true)
    corner(hover, 2)

    local rowScale = Instance.new("UIScale", f)
    rowScale.Name = "HoverScale"
    rowScale.Scale = 1

    local inside = false
    f.MouseEnter:Connect(function()
        inside = true
        TS:Create(f, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.07, BackgroundColor3 = COLORS.row2}):Play()
        TS:Create(rowStroke, TweenInfo.new(0.14), {Transparency = 0.42}):Play()
        TS:Create(hover, TweenInfo.new(0.14), {BackgroundTransparency = 0.05}):Play()
        TS:Create(rowScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.008}):Play()
    end)
    f.MouseLeave:Connect(function()
        inside = false
        TS:Create(f, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.20, BackgroundColor3 = COLORS.row}):Play()
        TS:Create(rowStroke, TweenInfo.new(0.14), {Transparency = 0.76}):Play()
        TS:Create(hover, TweenInfo.new(0.14), {BackgroundTransparency = 1}):Play()
        TS:Create(rowScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)
    return f
end

local function mkLabel(row, txt)
    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(0.62, 0, 1, 0)
    l.Position = UDim2.new(0, 16, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = COLORS.white
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.ZIndex = 6
    return l
end

local _SpaceToggleGradients = {}
local _SpaceToggleGradientConn = nil

local function _SpaceToggleColorSet(col)
    col = col or S.themeColor or COLORS.accent or COLORS.on
    local deep = col:Lerp(Color3.new(0, 0, 0), 0.68)
    local void = col:Lerp(Color3.new(0, 0, 0), 0.90)
    return deep, void, col
end

local function _EnsureSpaceToggleGradientLoop()
    if _SpaceToggleGradientConn then return end
    _SpaceToggleGradientConn = RunService.RenderStepped:Connect(function(dt)
        for i = #_SpaceToggleGradients, 1, -1 do
            local item = _SpaceToggleGradients[i]
            local g = item and item.g
            local pill = item and item.pill
            if not g or not g.Parent or not pill or not pill.Parent then
                table.remove(_SpaceToggleGradients, i)
            else
                g.Rotation = (g.Rotation + (item.speed or 120) * dt) % 360
            end
        end
        if #_SpaceToggleGradients == 0 and _SpaceToggleGradientConn then
            _SpaceToggleGradientConn:Disconnect()
            _SpaceToggleGradientConn = nil
        end
    end)
end

local function mkPill(row, offset)
    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 46, 0, 24)
    pill.Position = UDim2.new(1, -(offset or 54), 0.5, -12)
    pill.BackgroundColor3 = COLORS.off
    pill.BorderSizePixel = 0
    pill.ZIndex = 7
    pill:SetAttribute("ThemeTogglePill", true)
    corner(pill, 7)

    local stroke = Instance.new("UIStroke", pill)
    stroke.Name = "ToggleStroke"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1.5
    stroke.Transparency = 0.15
    stroke.Color = S.themeColor or COLORS.accent
    stroke:SetAttribute("ThemeAccent", true)

    local grad = Instance.new("UIGradient", stroke)
    grad.Name = "ToggleGradient"
    local deep, void, accent = _SpaceToggleColorSet(S.themeColor or COLORS.accent)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, void),
        ColorSequenceKeypoint.new(0.20, deep),
        ColorSequenceKeypoint.new(0.48, accent),
        ColorSequenceKeypoint.new(0.50, accent),
        ColorSequenceKeypoint.new(0.52, accent),
        ColorSequenceKeypoint.new(0.80, deep),
        ColorSequenceKeypoint.new(1.00, void),
    })
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 0.88),
        NumberSequenceKeypoint.new(0.25, 0.34),
        NumberSequenceKeypoint.new(0.48, 0.03),
        NumberSequenceKeypoint.new(0.50, 0.00),
        NumberSequenceKeypoint.new(0.52, 0.03),
        NumberSequenceKeypoint.new(0.75, 0.34),
        NumberSequenceKeypoint.new(1.00, 0.88),
    })
    grad.Rotation = 0
    table.insert(_SpaceToggleGradients, {g = grad, pill = pill, speed = 120})
    _EnsureSpaceToggleGradientLoop()

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(115, 115, 125)
    knob.BorderSizePixel = 0
    knob.ZIndex = 8
    knob:SetAttribute("ThemeToggleKnob", true)
    corner(knob, 5)

    local shine = Instance.new("Frame", pill)
    shine.Name = "ToggleShine"
    shine.Size = UDim2.new(1, -8, 0, 2)
    shine.Position = UDim2.new(0, 4, 0, 3)
    shine.BackgroundColor3 = COLORS.white
    shine.BackgroundTransparency = 0.90
    shine.BorderSizePixel = 0
    shine.ZIndex = 7
    shine:SetAttribute("ThemeAccentFill", true)
    corner(shine, 2)

    return pill, knob
end

local function animPill(pill, dot, on)
    local onCol = S.themeColor or COLORS.on or Color3.fromRGB(220, 220, 225)
    pill:SetAttribute("ThemePillOn", on == true)
    local st = pill:FindFirstChild("ToggleStroke")
    local grad = st and st:FindFirstChild("ToggleGradient")
    local deep, void, accent = _SpaceToggleColorSet(onCol)

    TS:Create(pill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = on and onCol or COLORS.off,
        BackgroundTransparency = on and 0 or 0,
    }):Play()
    if st then
        TS:Create(st, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Color = on and onCol or COLORS.strokeSoft,
            Transparency = on and 0.08 or 0.22,
            Thickness = on and 1.5 or 1.25,
        }):Play()
    end
    if grad then
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, void),
            ColorSequenceKeypoint.new(0.20, deep),
            ColorSequenceKeypoint.new(0.48, accent),
            ColorSequenceKeypoint.new(0.50, accent),
            ColorSequenceKeypoint.new(0.52, accent),
            ColorSequenceKeypoint.new(0.80, deep),
            ColorSequenceKeypoint.new(1.00, void),
        })
    end
    TS:Create(dot, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(115, 115, 125),
    }):Play()
    local ds = dot:FindFirstChild("DotStroke")
    if ds then
        TS:Create(ds, TweenInfo.new(0.16), {
            Color = on and onCol or COLORS.strokeSoft,
            Transparency = on and 0.10 or 0.45,
        }):Play()
    end
    local shine = pill:FindFirstChild("ToggleShine")
    if shine then
        TS:Create(shine, TweenInfo.new(0.16), {BackgroundTransparency = on and 0.78 or 0.90}):Play()
    end
end

local function toggleClickFx(pill, dot)
    if not pill or not pill.Parent then return end
    local sc = pill:FindFirstChild("ToggleClickScale")
    if not sc then
        sc = Instance.new("UIScale")
        sc.Name = "ToggleClickScale"
        sc.Scale = 1
        sc.Parent = pill
    end
    TS:Create(sc, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
    task.delay(0.08, function()
        if sc and sc.Parent then
            TS:Create(sc, TweenInfo.new(0.20, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = 1}):Play()
        end
    end)

    pcall(function()
        local pop = Instance.new("Frame", pill)
        pop.Name = "TogglePop"
        pop.AnchorPoint = Vector2.new(0.5, 0.5)
        pop.Position = UDim2.new(1, -12, 0.5, 0)
        pop.Size = UDim2.new(0, 16, 0, 16)
        pop.BackgroundTransparency = 1
        pop.BorderSizePixel = 0
        pop.ZIndex = pill.ZIndex + 4
        corner(pop, 99)
        local ps = Instance.new("UIStroke", pop)
        ps.Thickness = 2
        ps.Color = S.themeColor or COLORS.accent
        ps.Transparency = 0.10
        ps:SetAttribute("ThemeAccent", true)
        local twP = TS:Create(pop, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 36, 0, 36),
        })
        local twS = TS:Create(ps, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Transparency = 1,
            Thickness = 0.5,
        })
        twP:Play()
        twS:Play()
        twP.Completed:Connect(function() pcall(function() pop:Destroy() end) end)
    end)
end

local function mkToggle(parent, txt, initialOrCb, maybeCb)
    local initial = type(initialOrCb) == "boolean" and initialOrCb or false
    local cb = (type(initialOrCb) == "function") and initialOrCb or maybeCb
    local row = mkRow(parent, 40)
    mkLabel(row, txt)
    local pill, dot = mkPill(row, 54)
    local on = initial == true
    local function sv(s)
        on = s == true
        animPill(pill, dot, on)
    end
    sv(initial)
    local clk = Instance.new("TextButton", pill)
    clk.Size = UDim2.new(1, 0, 1, 0)
    clk.BackgroundTransparency = 1
    clk.Text = ""
    clk.AutoButtonColor = false
    clk.ZIndex = 10
    clk.Activated:Connect(function()
        if S._anyKeyListening then return end
        toggleClickFx(pill, dot)
        on = not on
        sv(on)
        if cb then pcall(cb, on) end
    end)
    return sv
end


local function mkBox(parent, default, w, xOff, cb)
    local tb = Instance.new("TextBox", parent)
    tb.Size = UDim2.new(0, w or 58, 0, 26)
    tb.Position = UDim2.new(1, -(xOff or 64), 0.5, -13)
    tb.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    tb.BackgroundTransparency = 0.05
    tb.BorderSizePixel = 0
    tb.Text = tostring(default)
    tb.TextColor3 = COLORS.white
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 12
    tb.ClearTextOnFocus = false
    tb.ZIndex = 6
    corner(tb, 9)
    local bs = stroke(tb, COLORS.stroke, 1, 0.70)
    bs.Name = "InputStroke"
    bs:SetAttribute("ThemeAccent", true)
    tb.MouseEnter:Connect(function() TS:Create(bs, TweenInfo.new(0.12), {Transparency = 0.35}):Play() end)
    tb.MouseLeave:Connect(function() if not tb:IsFocused() then TS:Create(bs, TweenInfo.new(0.12), {Transparency = 0.70}):Play() end end)
    tb.Focused:Connect(function()
        TS:Create(bs, TweenInfo.new(0.12), {Color = COLORS.accent, Transparency = 0.05}):Play()
        TS:Create(tb, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    end)
    tb.FocusLost:Connect(function()
        TS:Create(bs, TweenInfo.new(0.12), {Color = COLORS.strokeSoft, Transparency = 0.70}):Play()
        TS:Create(tb, TweenInfo.new(0.12), {BackgroundTransparency = 0.05}):Play()
        if cb then
            local n = tonumber(tb.Text)
            if n then cb(n) else tb.Text = tostring(default) end
        end
    end)
    return tb
end

local GAMEPAD_KEYS = { [Enum.KeyCode.ButtonA]=true,[Enum.KeyCode.ButtonB]=true,[Enum.KeyCode.ButtonX]=true,[Enum.KeyCode.ButtonY]=true, [Enum.KeyCode.ButtonL1]=true,[Enum.KeyCode.ButtonR1]=true,[Enum.KeyCode.ButtonL2]=true,[Enum.KeyCode.ButtonR2]=true, [Enum.KeyCode.ButtonL3]=true,[Enum.KeyCode.ButtonR3]=true,[Enum.KeyCode.ButtonStart]=true,[Enum.KeyCode.ButtonSelect]=true,
[Enum.KeyCode.DPadUp]=true,[Enum.KeyCode.DPadDown]=true,[Enum.KeyCode.DPadLeft]=true,[Enum.KeyCode.DPadRight]=true }
local function isGamepadInput(inp) return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil end
local function isBindableInput(inp) if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end if inp.UserInputType == Enum.UserInputType.Keyboard then return true end return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true end
local function kbMatch(entry, kc) return kc and (kc == entry.kb or (entry.gp and kc == entry.gp)) end

local function mkKB(parent, kbEntry, cb)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 56, 0, 26)
    btn.Position = UDim2.new(1, -64, 0.5, -13)
    btn.BackgroundColor3 = S.themeColor or COLORS.accent or Color3.fromRGB(18, 18, 20)
    btn.BackgroundTransparency = 0.48
    btn.BorderSizePixel = 0
    btn:SetAttribute("ThemeButton", true)
    btn.Text = (kbEntry.gp and kbEntry.gp.Name) or (kbEntry.kb and kbEntry.kb.Name) or "None"
    btn.TextColor3 = COLORS.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.ZIndex = 6
    corner(btn, 9)
    local kStroke = stroke(btn, S.themeColor or COLORS.stroke, 1, 0.45)
    kStroke:SetAttribute("ThemeAccent", true)
    local li, lc, pv, listenStart = false, nil, btn.Text, 0
    btn.MouseEnter:Connect(function()
        TS:Create(kStroke, TweenInfo.new(0.12), {Transparency = 0.10}):Play()
        TS:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.30}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if not li then TS:Create(kStroke, TweenInfo.new(0.12), {Transparency = 0.45}):Play(); TS:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.48}):Play() end
    end)
    btn.Activated:Connect(function()
        if li then
            li = false; S._anyKeyListening = false
            if lc then lc:Disconnect(); lc = nil end
            btn.Text = pv; btn.TextColor3 = COLORS.white
            return
        end
        pv = btn.Text; li = true; S._anyKeyListening = true; listenStart = tick()
        btn.Text = "TAP KEY"
        btn.TextColor3 = COLORS.accentStrong
        TS:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.15}):Play()
        TS:Create(kStroke, TweenInfo.new(0.12), {Transparency = 0.02}):Play()
        lc = UIS.InputBegan:Connect(function(inp)
            if not li then return end
            if inp.KeyCode == Enum.KeyCode.Escape then
                li = false; S._anyKeyListening = false
                if lc then lc:Disconnect(); lc = nil end
                btn.Text = pv; btn.TextColor3 = COLORS.white
                TS:Create(kStroke, TweenInfo.new(0.12), {Transparency = 0.45}):Play()
                return
            end
            local isGp = isGamepadInput(inp)
            if isGp and tick() - listenStart < 0.15 then return end
            if not isBindableInput(inp) then return end
            btn.Text = inp.KeyCode.Name; pv = btn.Text; btn.TextColor3 = COLORS.white
            li = false; S._anyKeyListening = false
            if lc then lc:Disconnect(); lc = nil end
            TS:Create(kStroke, TweenInfo.new(0.12), {Transparency = 0.35}):Play()
            if cb then cb(inp.KeyCode, isGp) end
        end)
    end)
    return btn
end

lo = 0; section(pageMOVE, "Auto Speed") do S.setAutoCarrySpeedVisual = mkToggle(pageMOVE, "Speed", function(on) S.autoCarrySpeedEnabled = on if not on then pcall(F.disableAutoCarrySpeed) end F.saveConfig() end) end section(pageMOVE, "Speed") do local row = mkRow(pageMOVE, 34); mkLabel(row, "Normal Speed"); UI.normalBox = mkBox(row, NS, 54, 62, function(v) if v > 0 and v <= 500 then NS = v end; F.saveConfig() end) end
do local row = mkRow(pageMOVE, 34); mkLabel(row, "Carry Speed"); UI.carryBox = mkBox(row, CS, 54, 62, function(v) if v > 0 and v <= 500 then CS = v end; F.saveConfig() end) end do local row = mkRow(pageMOVE, 34); mkLabel(row, "Lagger Normal"); UI.laggerBox = mkBox(row, S.LAGGER_SPEED, 54, 62, function(v) if v > 0 and v <= 500 then S.LAGGER_SPEED = v end; F.saveConfig() end) end do local row = mkRow(pageMOVE, 34); mkLabel(row, "Lagger Carry"); UI.laggerCarryBox = mkBox(row, S.LAGGER_CARRY_SPEED, 54, 62, function(v) if v > 0 and v <= 500 then S.LAGGER_CARRY_SPEED = v end; F.saveConfig() end) end
do local row = mkRow(pageMOVE, 34); mkLabel(row, "Mode"); modeValLbl = Instance.new("TextLabel", row); modeValLbl.Size = UDim2.new(0, 100, 1, 0); modeValLbl.Position = UDim2.new(1, -110, 0, 0); modeValLbl.BackgroundTransparency = 1; modeValLbl.Text = "Normal"; modeValLbl.TextColor3 = COLORS.accentStrong; modeValLbl.Font = Enum.Font.GothamBlack; modeValLbl.TextSize = 12; modeValLbl.TextXAlignment = Enum.TextXAlignment.Right; local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(1, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 2
clk.Activated:Connect(function() if S._anyKeyListening then return end F.toggleCarryMode(); F.saveConfig() end) end section(pageMOVE, "Auto Play") do local sv = mkToggle(pageMOVE, "Auto Left", function(on) S.autoLeftEnabled = on if on then F.queueAutoLeftStart() else F.stopAutoLeft() end F.saveConfig() end) S.autoLeftSetVisual = sv end do local sv = mkToggle(pageMOVE, "Auto Right", function(on) S.autoRightEnabled = on if on then F.queueAutoRightStart() else F.stopAutoRight() end F.saveConfig() end) S.autoRightSetVisual = sv end section(pageMOVE, "Teleport") do local row = mkRow(pageMOVE, 34); mkLabel(row, "Drop Brainrot")
local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(0.55, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 2 clk.Activated:Connect(function() F.runDrop() end) end do local row = mkRow(pageMOVE, 34); mkLabel(row, "TP Down") local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(0.55, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 2
clk.Activated:Connect(function() F.runTPFloor() end) end do VS.setAutoTPVisual = mkToggle(pageMOVE, "Auto TP", function(on) S.autoTPEnabled = on if on then F.startAutoTP() else F.stopAutoTP() end F.saveConfig() end) end do local row = mkRow(pageMOVE, 34); mkLabel(row, "Auto TP Height") UI.autoTPHeightBox = mkBox(row, S.autoTPHeight, 54, 62, function(v) if v >= 0 and v <= 500 then S.autoTPHeight = v elseif UI.autoTPHeightBox then UI.autoTPHeightBox.Text = tostring(S.autoTPHeight) end F.saveConfig() end) end lo = 0; section(pageTOOLS, "Bat") do
local abRow = mkRow(pageTOOLS, 34); mkLabel(abRow, "Auto Bat") local abPill, abDot = mkPill(abRow, 54) local abOn = false local function svAutoBat(s) abOn = s; animPill(abPill, abDot, s) end S.autoBatSetVisual = svAutoBat; local abClk = Instance.new("TextButton", abPill); abClk.Size = UDim2.new(1, 0, 1, 0); abClk.BackgroundTransparency = 1; abClk.Text = ""; abClk.ZIndex = 6 abClk.Activated:Connect(function()
if S._anyKeyListening then return end abOn = not abOn; svAutoBat(abOn) if abOn then F.queueAutoBatStart() else S.autoBatEnabled = false; S.disableAutoBat() end F.saveConfig() end) end VS.setMirrorTPVisual = mkToggle(pageTOOLS, "Mirror TP Down", function(on) F.setMirrorTPDown(on) F.saveConfig() end) do
local expandedA = false
local headerH_A, bodyH_A = 34, 44
local wrapA = Instance.new("Frame", pageTOOLS)
wrapA.Name = "AimbotModeWrap"
wrapA.Size = UDim2.new(1, 0, 0, headerH_A)
wrapA.BackgroundTransparency = 1
wrapA.ClipsDescendants = true
wrapA.LayoutOrder = LO()

local headerA = Instance.new("Frame", wrapA)
headerA.Size = UDim2.new(1, 0, 0, headerH_A)
headerA.BackgroundColor3 = COLORS.row
headerA.BorderSizePixel = 0
headerA.Active = true
corner(headerA, 9)
stroke(headerA, COLORS.strokeSoft, 1, 0.55)

local arrowA = Instance.new("TextLabel", headerA)
arrowA.Size = UDim2.new(0, 22, 1, 0)
arrowA.Position = UDim2.new(0, 8, 0, 0)
arrowA.BackgroundTransparency = 1
arrowA.Text = "▶"
arrowA.TextColor3 = COLORS.accentStrong
arrowA.Font = Enum.Font.GothamBold
arrowA.TextSize = 11
arrowA.TextXAlignment = Enum.TextXAlignment.Left

local titleA = Instance.new("TextLabel", headerA)
titleA.Size = UDim2.new(0.36, 0, 1, 0)
titleA.Position = UDim2.new(0, 28, 0, 0)
titleA.BackgroundTransparency = 1
titleA.Text = "Aimbot"
titleA.TextColor3 = COLORS.white
titleA.Font = Enum.Font.GothamBold
titleA.TextSize = 12
titleA.TextXAlignment = Enum.TextXAlignment.Left

local hintA = Instance.new("TextLabel", headerA)
hintA.Size = UDim2.new(0, 82, 0, 18)
hintA.Position = UDim2.new(1, -144, 0.5, -9)
hintA.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
hintA.BorderSizePixel = 0
hintA.TextColor3 = COLORS.accentStrong
hintA.Font = Enum.Font.GothamBold
hintA.TextSize = 9
hintA.TextXAlignment = Enum.TextXAlignment.Center
hintA.ZIndex = 4
corner(hintA, 5)

local pillA, dotA = mkPill(headerA, 52)
local aimbotVisualOn = false
local function setAimbotVisual(state)
    aimbotVisualOn = state == true
    animPill(pillA, dotA, aimbotVisualOn)
end
VS.setAimbotVisual = setAimbotVisual
VS.setAntiBatBypassVisual = function() end

local pillClkA = Instance.new("TextButton", pillA)
pillClkA.Size = UDim2.new(1, 0, 1, 0)
pillClkA.BackgroundTransparency = 1
pillClkA.Text = ""
pillClkA.ZIndex = 6
pillClkA.Activated:Connect(function()
    if S._anyKeyListening then return end
    local active = setAimbotState(not aimbotVisualOn)
    setAimbotVisual(active)
    F.saveConfig()
end)

local expandClkA = Instance.new("TextButton", headerA)
expandClkA.Size = UDim2.new(1, -108, 1, 0)
expandClkA.Position = UDim2.new(0, 0, 0, 0)
expandClkA.BackgroundTransparency = 1
expandClkA.Text = ""
expandClkA.ZIndex = 2

local bodyA = Instance.new("Frame", wrapA)
bodyA.Size = UDim2.new(1, 0, 0, bodyH_A)
bodyA.Position = UDim2.new(0, 0, 0, headerH_A)
bodyA.BackgroundTransparency = 1
bodyA.Visible = false
bodyA.Active = true
bodyA.ZIndex = 45

local modeRowA = Instance.new("Frame", bodyA)
modeRowA.Name = "AimbotModeRow"
modeRowA.Size = UDim2.new(1, 0, 0, 34)
modeRowA.Position = UDim2.new(0, 0, 0, 4)
modeRowA.BackgroundColor3 = COLORS.row2
modeRowA.BorderSizePixel = 0
modeRowA.Active = true
modeRowA.ZIndex = 100
corner(modeRowA, 8)
stroke(modeRowA, COLORS.strokeSoft, 1, 0.6)

local modeLblA = Instance.new("TextLabel", modeRowA)
modeLblA.Size = UDim2.new(0, 48, 1, 0)
modeLblA.Position = UDim2.new(0, 10, 0, 0)
modeLblA.BackgroundTransparency = 1
modeLblA.Text = "Mode"
modeLblA.TextColor3 = COLORS.textDim
modeLblA.Font = Enum.Font.GothamBold
modeLblA.TextSize = 10
modeLblA.TextXAlignment = Enum.TextXAlignment.Left
modeLblA.ZIndex = 105

local AIMBOT_MODE_NAMES = {[1] = "MODE V1", [2] = "MODE V2"}
local aimbotModeButtons = {}
local lastAimbotModeClick = 0

local function refreshAimbotModeUI()
    local current = (S.aimbotMode == 2) and 2 or 1
    S.aimbotMode = current
    hintA.Text = AIMBOT_MODE_NAMES[current]
    for i = 1, 2 do
        local b = aimbotModeButtons[i]
        if b and b.Parent then
            local selected = i == current
            b.BackgroundColor3 = selected and (S.themeColor or COLORS.accent) or Color3.fromRGB(18, 18, 20)
            b.TextColor3 = selected and Color3.fromRGB(0, 0, 0) or COLORS.white
            local st = b:FindFirstChildOfClass("UIStroke")
            if st then
                st.Color = selected and (S.themeColor or COLORS.accent) or COLORS.stroke
                st.Transparency = selected and 0.05 or 0.55
            end
        end
    end
end

local function selectAimbotMode(mode)
    mode = tonumber(mode)
    if mode ~= 1 and mode ~= 2 then return false end
    mode = math.floor(mode)

    local now = os.clock()
    if now - lastAimbotModeClick < 0.22 then
        return false
    end
    lastAimbotModeClick = now

    -- The MODE buttons are standalone selectors: clicking MODE V1/V2
    -- must start the selected logic even when the main Aimbot pill is OFF.
    -- If the selected mode is already running, do not restart its loop.
    local currentMode = (S.aimbotMode == 2) and 2 or 1
    local runtimeOn = (aimbotEnabled == true) or (vasperAimbotEnabled == true)

    if currentMode ~= mode then
        -- Stop the previous implementation before changing the mode.
        pcall(setAimbotState, false)
        setAimbotVisual(false)
    end

    S.aimbotMode = mode
    refreshAimbotModeUI()

    if currentMode ~= mode or not runtimeOn then
        local ok, active = pcall(setAimbotState, true)
        if ok and active == true then
            setAimbotVisual(true)
        else
            setAimbotVisual(false)
            warn("[Vyxro Duel] MODE V" .. tostring(mode) .. " could not be started")
            F.saveConfig()
            return false
        end
    else
        -- Runtime is already active in the selected mode. Keep the UI in sync.
        setAimbotVisual(true)
    end

    F.saveConfig()
    return true
end

for i = 1, 2 do
    local b = Instance.new("TextButton", modeRowA)
    b.Name = "AimbotModeV" .. tostring(i)
    b.Size = UDim2.new(0, 86, 0, 26)
    b.Position = UDim2.new(1, -188 + ((i - 1) * 92), 0.5, -13)
    b.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    b.BorderSizePixel = 0
    b.Text = AIMBOT_MODE_NAMES[i]
    b.TextColor3 = COLORS.white
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 10
    b.AutoButtonColor = false
    b.Active = true
    b.Selectable = true
    b.ZIndex = 10000
    corner(b, 7)
    stroke(b, COLORS.stroke, 1, 0.55)
    aimbotModeButtons[i] = b
    local mode = i
    b.Activated:Connect(function()
        if S._anyKeyListening then return end
        selectAimbotMode(mode)
    end)
end

UI.aimbotModeBtn = hintA
UI.selectAimbotMode = selectAimbotMode
UI.refreshAimbotMode = refreshAimbotModeUI
refreshAimbotModeUI()

local function setAimbotExpanded(on)
    expandedA = on == true
    arrowA.Text = expandedA and "▼" or "▶"
    bodyA.Visible = expandedA
    TS:Create(wrapA, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1, 0, 0, expandedA and (headerH_A + bodyH_A + 2) or headerH_A)
    }):Play()
end
expandClkA.Activated:Connect(function()
    if S._anyKeyListening then return end
    setAimbotExpanded(not expandedA)
end)
end
VS.setAutoSwingVisual = mkToggle(pageTOOLS, "Auto Swing", function(on) S.autoSwingEnabled = on F.saveConfig() end)
-- Nuke Optimizer toggle
do
    local nukeToggle = mkToggle(pageTOOLS, "Nuke Optimizer", function(on)
        if on then
            local ok, err = pcall(function()
                if _G._nukeStart then
                    _G._nukeStart()
                else
                    error("Nuke Optimizer logic is not loaded")
                end
            end)
            if not ok then
                warn("[Vyxro Duel] Nuke Optimizer start failed: " .. tostring(err))
                if _G._nukeStop then pcall(_G._nukeStop) end
                if nukeToggle then pcall(function() nukeToggle(false) end) end
            end
        else
            if _G._nukeStop then pcall(_G._nukeStop) end
        end
        F.saveConfig()
    end)
    VS.setNukeOptimizerVisual = nukeToggle
end
 if VS.setAutoSwingVisual then VS.setAutoSwingVisual(S.autoSwingEnabled) end do
VS.setBatCounterVisual = mkToggle(pageTOOLS, "Bat Counter", function(on) S.batCounterEnabled = on if on then S.startBatCounter() else S.stopBatCounter() end F.saveConfig() end) end do
VS.setTPBatVisual = mkToggle(pageTOOLS, "TP Bat", function(on) setTPBatState(on); F.saveConfig() end) end section(pageTOOLS, "Steal") do
local stealRow = mkRow(pageTOOLS, 34); mkLabel(stealRow, "Auto Steal"); local pill, dot = mkPill(stealRow, 52) pcall(function() if _G.__VxyroGlossAttach then _G.__VxyroGlossAttach(pill, {z=3, radius=12, thickness=1.20, bloomThickness=4.0}) end end) local function applyStealVis(on) TS:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = on and COLORS.accent or COLORS.off}):Play() TS:Create(dot, TweenInfo.new(0.15), { Position = on and UDim2.new(1, -22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = on and COLORS.white or COLORS.textDim }):Play() end VS.setInstaGrab = applyStealVis pill.InputBegan:Connect(function(inp)
if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end if S._anyKeyListening then return end local on = not autoStealEnabled if on then startAutoSteal() else stopAutoSteal() end applyStealVis(on); F.saveConfig() end) end do
local row = mkRow(pageTOOLS, 34); mkLabel(row, "Steal Mode"); local modeLbl = Instance.new("TextButton", row); modeLbl.Size = UDim2.new(0, 90, 0, 24); modeLbl.Position = UDim2.new(1, -100, 0.5, -12); modeLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 20); modeLbl.BorderSizePixel = 0; modeLbl.Text = tostring(selectedStealMode or "Normal"); modeLbl.TextColor3 = COLORS.white; modeLbl.Font = Enum.Font.GothamBold; modeLbl.TextSize = 11; modeLbl.ZIndex = 5; corner(modeLbl, 8); UI.stealModeLbl = modeLbl; local modes = {"Normal", "Semi", "V3"} modeLbl.MouseButton1Click:Connect(function()
local cur = selectedStealMode or "Normal" local idx = 1 for i, m in ipairs(modes) do if m == cur then idx = i break end end idx = (idx % #modes) + 1; selectedStealMode = modes[idx]; modeLbl.Text = selectedStealMode if selectedStealMode == "Normal" then autoGrabStopEnabled = false; Steal.AutoGrabStopEnabled = false elseif selectedStealMode == "Semi" then autoGrabStopEnabled = true; Steal.AutoGrabStopEnabled = true else autoGrabStopEnabled = true; Steal.AutoGrabStopEnabled = true; autoStealRadius = math.max(tonumber(autoStealRadius) or 20, 55); Steal.StealRadius = autoStealRadius
if UI.radInput then UI.radInput.Text = tostring(autoStealRadius) end end if autoStealEnabled then pcall(stopAutoSteal); pcall(startAutoSteal) end F.saveConfig() end) end do local row = mkRow(pageTOOLS, 34); mkLabel(row, "Steal Radius") UI.radInput = mkBox(row, Steal.StealRadius, 54, 62, function(v) v = tonumber(v) if v and v > 0 then autoStealRadius = v; Steal.StealRadius = v; AceStealRadii.Normal = v if progressRadLbl then progressRadLbl.Text = string.format("Radius: %.0f", v) end F.saveConfig() end end) end do local row = mkRow(pageTOOLS, 34); mkLabel(row, "Steal Duration")
UI.stealDurInput = mkBox(row, Steal.StealDuration, 54, 62, function(v) v = tonumber(v) if v and v >= 0.1 then Steal.StealDuration = v; F.saveConfig() end end) end do local row = mkRow(pageTOOLS, 34); mkLabel(row, "Stop Time"); local pill, dot = mkPill(row, 52) local function vis(on) TS:Create(pill, TweenInfo.new(0.15), {BackgroundColor3 = on and COLORS.accent or COLORS.off}):Play() TS:Create(dot, TweenInfo.new(0.15), { Position = on and UDim2.new(1, -22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }):Play() end VS.setAutoGrabStopVisual = vis pill.InputBegan:Connect(function(inp)
if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end Steal.AutoGrabStopEnabled = not Steal.AutoGrabStopEnabled; autoGrabStopEnabled = Steal.AutoGrabStopEnabled; vis(Steal.AutoGrabStopEnabled); F.saveConfig() end) end do local row = mkRow(pageTOOLS, 34); mkLabel(row, "Stop Time (s)") UI.stopTimeInput = mkBox(row, Steal.AutoGrabStopTime, 54, 62, function(v) v = tonumber(v) if v and v > 0 then Steal.AutoGrabStopTime = v; autoGrabStopTime = v; F.saveConfig() end end) end do
local row = mkRow(pageTOOLS, 34); mkLabel(row, "Delay Radius") UI.delayRadInput = mkBox(row, Steal.AutoGrabDelayRadius, 54, 62, function(v) v = tonumber(v) if v and v > 0 then Steal.AutoGrabDelayRadius = v; autoGrabDelayRadius = v; F.saveConfig() end end) end section(pageTOOLS, "Combat") VS.setMedusaVisual = mkToggle(pageTOOLS, "Medusa Counter", function(on) S.medusaCounterEnabled = on F.refreshMedusaWatch(); F.saveConfig() end) do local row = mkRow(pageTOOLS, 34); mkLabel(row, "Instant Reset") local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(0.55, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 2 clk.Activated:Connect(function() if cursedInstaReset then cursedInstaReset() end end) end VS.setInfJumpVisual = mkToggle(pageTOOLS, "Infinite Jump", function(on) infJumpEnabled = on if on then F.startInfJump() else F.stopInfJump() end F.saveConfig() end) do
local row = mkRow(pageTOOLS, 34); mkLabel(row, "Jump Mode"); local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(0, 72, 0, 24); btn.Position = UDim2.new(1, -80, 0.5, -12); btn.BackgroundColor3 = COLORS.row2; btn.BorderSizePixel = 0; btn.Text = ((S.infJumpMode or "hold") == "manual") and "Manual" or "Hold"; btn.TextColor3 = COLORS.white; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.ZIndex = 5 corner(btn, 8); stroke(btn, COLORS.stroke, 1, 0.6); UI.infJumpModeBtn = btn btn.MouseButton1Click:Connect(function()
local nextMode = ((S.infJumpMode or "hold") == "manual") and "hold" or "manual" F.setInfJumpMode(nextMode); btn.Text = (nextMode == "manual") and "Manual" or "Hold" F.saveConfig() end) end VS.setAntiRagVisual = mkToggle(pageTOOLS, "Anti Ragdoll", function(on) S.antiRagdollEnabled = on if on then F.startAntiRagdoll() else F.stopAntiRagdoll() end F.saveConfig() end) do
local row = mkRow(pageTOOLS, 34); mkLabel(row, "Ragdoll Mode"); local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(0, 72, 0, 24); btn.Position = UDim2.new(1, -80, 0.5, -12); btn.BackgroundColor3 = COLORS.row2; btn.BorderSizePixel = 0; btn.Text = (S.antiRagdollMode == 2) and "V2" or "V1"; btn.TextColor3 = COLORS.white; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.ZIndex = 5; corner(btn, 8); stroke(btn, COLORS.stroke, 1, 0.6) btn.MouseButton1Click:Connect(function() S.antiRagdollMode = (S.antiRagdollMode == 2) and 1 or 2
btn.Text = (S.antiRagdollMode == 2) and "V2" or "V1" if S.antiRagdollEnabled then F.stopAntiRagdoll(); F.startAntiRagdoll() end F.saveConfig() end) end do
local expanded = false; local headerRow = mkRow(pageTOOLS, 34); mkLabel(headerRow, "Anti Die System"); local expandBtn = Instance.new("TextButton", headerRow); expandBtn.Size = UDim2.new(0, 72, 0, 24); expandBtn.Position = UDim2.new(1, -80, 0.5, -12); expandBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); expandBtn.BorderSizePixel = 0; expandBtn.Text = "OPEN"; expandBtn.TextColor3 = COLORS.white; expandBtn.Font = Enum.Font.GothamBold; expandBtn.TextSize = 11; expandBtn.ZIndex = 5; corner(expandBtn, 8); stroke(expandBtn, COLORS.stroke, 1, 0.6)
VS.setAntiDieVisual = mkToggle(pageTOOLS, "Anti Die", function(on) if on then F.startAntiDie() else F.stopAntiDie() end end) VS.setAntiFlingVisual = mkToggle(pageTOOLS, "Fling Shield", function(on) if on then F.startAntiFlingShield() else F.stopAntiFlingShield() end end) local antiDieRow, flingRow = nil, nil local children = pageTOOLS:GetChildren() for i = #children, 1, -1 do local ch = children[i] if ch:IsA("Frame") then local lbl = ch:FindFirstChildWhichIsA("TextLabel") if lbl and lbl.Text == "Fling Shield" and not flingRow then flingRow = ch
elseif lbl and lbl.Text == "Anti Die" and not antiDieRow then antiDieRow = ch end end if antiDieRow and flingRow then break end end if antiDieRow then antiDieRow.Visible = false end if flingRow then flingRow.Visible = false end expandBtn.MouseButton1Click:Connect(function() expanded = not expanded expandBtn.Text = expanded and "CLOSE" or "OPEN" if antiDieRow then antiDieRow.Visible = expanded end if flingRow then flingRow.Visible = expanded end end) end VS.setNoPlayerCollisionVisual = mkToggle(pageTOOLS, "No Player Collision", function(on)
if on then F.enableNoPlayerCollision() else F.disableNoPlayerCollision() end F.saveConfig() end) VS.setSafeModeVisual = mkToggle(pageTOOLS, "Safe Mode", function(on) S.safeModeEnabled = on F.saveConfig() end) VS.setMedusaResetVisual = mkToggle(pageTOOLS, "Medusa Reset", function(on) S.medusaResetEnabled = on F.refreshMedusaWatch(); F.saveConfig() end) VS.setAutoResetOnMedVisual = mkToggle(pageTOOLS, "Auto Reset On Med Fling", function(on) F.setAutoResetOnMed(on) F.saveConfig() end) VS.setBodyLockVisual = mkToggle(pageTOOLS, "Body Lock", function(on) if on then
if K7 and K7.startBodyLock then K7.startBodyLock() elseif startBodyLock then startBodyLock() end else if K7 and K7.stopBodyLock then K7.stopBodyLock(true) elseif stopBodyLock then stopBodyLock(true) end end F.saveConfig() end) do local row = mkRow(pageTOOLS, 34); mkLabel(row, "Lock Radius"); local rad = (K7 and K7.bodyLockRadius) or bodyLockRadius or 60 mkBox(row, rad, 54, 62, function(v) if v >= 5 and v <= 300 then if K7 then K7.bodyLockRadius = v end bodyLockRadius = v end F.saveConfig() end) end
if S.toggleNotifEnabled == nil then S.toggleNotifEnabled = true end
VS.setToggleNotifVisual = mkToggle(pageTOOLS, "Toggle Notifications", function(on)
    on = on == true
    if on then
        S.toggleNotifEnabled = true
        _G.VyxroToggleNotifEnabled = true
        pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Notifications", true) end end)
    else
        pcall(function() if _G.ShowTogglePing then _G.ShowTogglePing("Notifications", false) end end) -- tampil sekali sebelum dimatikan
        S.toggleNotifEnabled = false
        _G.VyxroToggleNotifEnabled = false
    end
    F.saveConfig()
end)
task.defer(function() if VS.setToggleNotifVisual then VS.setToggleNotifVisual(S.toggleNotifEnabled ~= false) end end)
lo = 0; section(pageVIEW, "Visual")

-- ================================================================
-- IMPORTED FEATURES: MUSIC PLAYER + CUSTOM FONT
-- Both controls use the existing Vxyro toggle system.
-- Music Player toggle controls the player window; playback itself remains
-- independent when the window is closed, matching the source behavior.
-- Custom Font toggle enables/disables the selected font; PICK opens the
-- complete font picker from the imported logic.
-- ================================================================
VS.setAntiLagVisual = mkToggle(pageVIEW, "FPS Boost (Anti Lag)", function(on) if on then F.enableAntiLag() else F.disableAntiLag() end F.saveConfig() end) VS.setStretchRezVisual = mkToggle(pageVIEW, "Stretch Rez", function(on) if on then enableStretchRez() else disableStretchRez() end F.saveConfig() end) VS.setUnwalkVisual = mkToggle(pageVIEW, "Unwalk", function(on) S.unwalkEnabled = on if on then F.startUnwalk() else F.stopUnwalk() end end) VS.setRemoveAccVisual = mkToggle(pageVIEW, "Remove Accessories", function(on) if on then F.startRemoveAccessories() else F.stopRemoveAccessories() end
end) VS.setKeyboardOverlayVisual = mkToggle(pageVIEW, "Keyboard Overlay", function(on) if on then F.startKeyboardOverlay() else F.stopKeyboardOverlay() end F.saveConfig() end) section(pageVIEW, "ESP") VS.setLineESPVisual = mkToggle(pageVIEW, "Player ESP", function(on) K7.lineESPEnabled = on K7.speedESPEnabled = on; K7.refreshESP(); F.saveConfig() end) VS.setShowTrackerVisual = mkToggle(pageVIEW, "Tracer ESP", function(on) S.showTracerEnabled = on if on then startTracerESP() else stopTracerESP() end pcall(function() if F.setShowTracer then F.setShowTracer(false) end end)
pcall(function() if F.clearTracers then F.clearTracers() end end) S.showTracerEnabled = on; F.saveConfig() end) VS.setShowTracerVisual = VS.setShowTrackerVisual VS.setSpeedESPVisual = function(on) if VS.setLineESPVisual then VS.setLineESPVisual(on) end end VS.setRagdollCdVisual = mkToggle(pageVIEW, "Ragdoll Countdown", function(on) F.setRagdollCountdown(on) F.saveConfig() end) section(pageVIEW, "Sky & Vision") do
local row = mkRow(pageVIEW, 34); mkLabel(row, "Sky Theme"); local skyLbl = Instance.new("TextLabel", row); skyLbl.Size = UDim2.new(0, 90, 0, 24); skyLbl.Position = UDim2.new(1, -100, 0.5, -12); skyLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 20); skyLbl.Text = K7.currentSkyTheme; skyLbl.TextColor3 = COLORS.white; skyLbl.Font = Enum.Font.GothamBold; skyLbl.TextSize = 11; Instance.new("UICorner", skyLbl).CornerRadius = UDim.new(0, 6); local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(1, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 3
clk.Activated:Connect(function() local name = K7.cycleSkyTheme(1) skyLbl.Text = name; F.saveConfig() end) end do local row = mkRow(pageVIEW, 34); mkLabel(row, "FOV") local fovBox = mkBox(row, K7.fovValue or _G._VezyFOV or 70, 54, 62, function(v) if v >= 30 and v <= 180 then K7.fovValue = v; _G._VezyFOV = v if K7.fovEnabled then K7.applyFOV() end local cam = workspace.CurrentCamera if cam and not (State and State.stretchedResEnabled) then pcall(function() cam.FieldOfView = v end) end end F.saveConfig() end) end VS.setFOVVisual = mkToggle(pageVIEW, "Custom FOV", function(on) K7.fovEnabled = on
K7.applyFOV(); F.saveConfig() end) lo = 0 section(pageSYS, "Charter") VS.setHeadlessVisual = mkToggle(pageSYS, "Headless", function(on) K7.headlessEnabled = on K7.applyHeadless(LP.Character, on); F.saveConfig() end) VS.setKorbloxVisual = mkToggle(pageSYS, "Korblox", function(on) K7.korbloxEnabled = on K7.applyKorblox(LP.Character, on); F.saveConfig() end) do
local sideNames = {[1] = "Right", [2] = "Left", [3] = "Both"}; local row = mkRow(pageSYS, 34); mkLabel(row, "Korblox Side"); local btn = Instance.new("TextButton", row); btn.Size = UDim2.new(0, 72, 0, 24); btn.Position = UDim2.new(1, -80, 0.5, -12); btn.BackgroundColor3 = COLORS.row2; btn.BorderSizePixel = 0; btn.Text = sideNames[korbloxSide] or "Right"; btn.TextColor3 = COLORS.white; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.ZIndex = 5; corner(btn, 8); stroke(btn, COLORS.stroke, 1, 0.6) btn.MouseButton1Click:Connect(function() korbloxSide = (korbloxSide % 3) + 1
K7.korbloxSide = korbloxSide; btn.Text = sideNames[korbloxSide] or "Right" if K7.korbloxEnabled then K7.applyKorblox(LP.Character, true) end F.saveConfig() end) end section(pageSYS, "Animation Pack") VS.setAnimPackVisual = mkToggle(pageSYS, "Animation Pack Enabled", function(on) K7.animPackEnabled = on if on then K7.applyAnimPack(K7.animPackName) else K7.resetAnimPack() end F.saveConfig() end) do
local row = mkRow(pageSYS, 34); mkLabel(row, "Select Pack"); local packLbl = Instance.new("TextLabel", row); packLbl.Size = UDim2.new(0, 100, 0, 24); packLbl.Position = UDim2.new(1, -110, 0.5, -12); packLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 20); packLbl.Text = K7.animPackName; UI.animPackLbl = packLbl; packLbl.TextColor3 = COLORS.white; packLbl.Font = Enum.Font.GothamBold; packLbl.TextSize = 10; Instance.new("UICorner", packLbl).CornerRadius = UDim.new(0, 6); local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(1, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 3
clk.Activated:Connect(function() K7.animPackIndex = K7.animPackIndex % #K7.ANIM_PACK_LIST + 1 K7.animPackName = K7.ANIM_PACK_LIST[K7.animPackIndex]; packLbl.Text = K7.animPackName if K7.animPackEnabled then K7.applyAnimPack(K7.animPackName) end F.saveConfig() end) end do
local row = mkRow(pageSYS, 34); mkLabel(row, "Current Pack"); local applyBtn = Instance.new("TextButton", row); applyBtn.Size = UDim2.new(0, 60, 0, 24); applyBtn.Position = UDim2.new(1, -70, 0.5, -12); applyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 44); applyBtn.Text = "APPLY"; applyBtn.TextColor3 = COLORS.white; applyBtn.Font = Enum.Font.GothamBold; applyBtn.TextSize = 11; applyBtn.BorderSizePixel = 0; Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6) applyBtn.Activated:Connect(function() if K7.animPackEnabled then K7.applyAnimPack(K7.animPackName) end F.saveConfig() end)

end section(pageSYS, "Appearance") do
-- Background Photo UI is rendered once inside the Space Appearance card below.
-- Keep this API as the single logic entry-point used by config/other systems.
VS.setBackgroundPhotoVisual = function(on)
    setBackgroundPhotoEnabled(on == true, true)
end
task.defer(function()
    if VS.setBackgroundPhotoVisual then
        VS.setBackgroundPhotoVisual(S.backgroundPhotoEnabled ~= false)
    end
end)
-- Theme selection is handled only by SPACE APPEARANCE > THEME.

    -- Background selector, intensity, and enable switch are centralized in SPACE APPEARANCE.
    pcall(function() if _G.__VxyroSpaceRefreshUI then _G.__VxyroSpaceRefreshUI() end end)
end do
local row = mkRow(pageSYS, 34); mkLabel(row, "GUI Size"); local minusBtn = Instance.new("TextButton", row); minusBtn.Size = UDim2.new(0, 28, 0, 24); minusBtn.Position = UDim2.new(1, -112, 0.5, -12); minusBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); minusBtn.BackgroundTransparency = 0.1; minusBtn.BorderSizePixel = 0; minusBtn.Text = "−"; minusBtn.TextColor3 = COLORS.white; minusBtn.Font = Enum.Font.GothamBold; minusBtn.TextSize = 16; minusBtn.ZIndex = 5; corner(minusBtn, 8); stroke(minusBtn, COLORS.stroke, 1, 0.75); local scaleLbl = Instance.new("TextLabel", row); scaleLbl.Size = UDim2.new(0, 44, 0, 24); scaleLbl.Position = UDim2.new(1, -80, 0.5, -12); scaleLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 20); scaleLbl.BackgroundTransparency = 0.15; scaleLbl.BorderSizePixel = 0; scaleLbl.Text = string.format("%.0f%%", guiScale * 100); scaleLbl.TextColor3 = COLORS.white; scaleLbl.Font = Enum.Font.GothamBold; scaleLbl.TextSize = 11; scaleLbl.ZIndex = 5
corner(scaleLbl, 8); UI.guiScaleLbl = scaleLbl local plusBtn = Instance.new("TextButton", row); plusBtn.Size = UDim2.new(0, 28, 0, 24); plusBtn.Position = UDim2.new(1, -32, 0.5, -12); plusBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); plusBtn.BackgroundTransparency = 0.1; plusBtn.BorderSizePixel = 0; plusBtn.Text = "+"; plusBtn.TextColor3 = COLORS.white; plusBtn.Font = Enum.Font.GothamBold; plusBtn.TextSize = 16; plusBtn.ZIndex = 5; corner(plusBtn, 8); stroke(plusBtn, COLORS.stroke, 1, 0.75) minusBtn.Activated:Connect(function() if S._anyKeyListening then return end
if _G._VersincApplyGuiScale then _G._VersincApplyGuiScale((_G._VersincGetGuiScale and _G._VersincGetGuiScale() or 1) - 0.1) end end) plusBtn.Activated:Connect(function() if S._anyKeyListening then return end if _G._VersincApplyGuiScale then _G._VersincApplyGuiScale((_G._VersincGetGuiScale and _G._VersincGetGuiScale() or 1) + 0.1) end end) end do
local row = mkRow(pageSYS, 34); mkLabel(row, "Progress Bar Size"); local minusBtn = Instance.new("TextButton", row); minusBtn.Size = UDim2.new(0, 28, 0, 24); minusBtn.Position = UDim2.new(1, -112, 0.5, -12); minusBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); minusBtn.BackgroundTransparency = 0.1; minusBtn.BorderSizePixel = 0; minusBtn.Text = "-"; minusBtn.TextColor3 = COLORS.white; minusBtn.Font = Enum.Font.GothamBold; minusBtn.TextSize = 16; minusBtn.ZIndex = 5; corner(minusBtn, 8); stroke(minusBtn, COLORS.stroke, 1, 0.75); local pbLbl = Instance.new("TextLabel", row); pbLbl.Size = UDim2.new(0, 44, 0, 24); pbLbl.Position = UDim2.new(1, -80, 0.5, -12); pbLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 20); pbLbl.BackgroundTransparency = 0.15; pbLbl.BorderSizePixel = 0; pbLbl.Text = tostring(S.progressBarScale or 100) .. "%"; pbLbl.TextColor3 = COLORS.white; pbLbl.Font = Enum.Font.GothamBold; pbLbl.TextSize = 11; pbLbl.ZIndex = 5
corner(pbLbl, 8); _G.__VersincProgressBarSizeLbl = pbLbl local plusBtn = Instance.new("TextButton", row); plusBtn.Size = UDim2.new(0, 28, 0, 24); plusBtn.Position = UDim2.new(1, -32, 0.5, -12); plusBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); plusBtn.BackgroundTransparency = 0.1; plusBtn.BorderSizePixel = 0; plusBtn.Text = "+"; plusBtn.TextColor3 = COLORS.white; plusBtn.Font = Enum.Font.GothamBold; plusBtn.TextSize = 16; plusBtn.ZIndex = 5; corner(plusBtn, 8); stroke(plusBtn, COLORS.stroke, 1, 0.75) local function bump(d) if S._anyKeyListening then return end
local n = math.clamp((tonumber(S.progressBarScale) or 100) + d, 50, 200)
S.progressBarScale = n
_G._VersincApplyProgressBarScale = function(value)
    local v = math.clamp(tonumber(value) or S.progressBarScale or 100, 50, 200)
    S.progressBarScale = v
    local sc = _G.__VersincProgressBarScaleObj
    if sc and sc.Parent then
        sc.Scale = v / 100
    end
    local lbl = _G.__VersincProgressBarSizeLbl
    if lbl and lbl.Parent then
        lbl.Text = tostring(math.floor(v + 0.5)) .. "%"
    end
end
_G._VersincApplyProgressBarScale(n)
pbLbl.Text = tostring(S.progressBarScale) .. "%"; F.saveConfig() end minusBtn.Activated:Connect(function() bump(-10) end) plusBtn.Activated:Connect(function() bump(10) end) end VS.setLockGuiVisual = mkToggle(pageSYS, "Lock GUI", function(on) S.guiLocked = on and true or false F.saveConfig() end) if S.autoSaveEnabled == nil then S.autoSaveEnabled = true end VS.setAutoSaveVisual = mkToggle(pageSYS, "Auto Save", function(on)
S.autoSaveEnabled = on and true or false F.saveConfig(true) end) do local row = mkRow(pageSYS, 28); local st = Instance.new("TextLabel", row); st.Size = UDim2.new(1, -12, 1, 0); st.Position = UDim2.new(0, 10, 0, 0); st.BackgroundTransparency = 1; st.Text = "Save: ready"; st.TextColor3 = COLORS.textDim; st.Font = Enum.Font.GothamMedium; st.TextSize = 11; st.TextXAlignment = Enum.TextXAlignment.Left; st.ZIndex = 5; UI.saveStatusLbl = st end task.defer(function() if VS.setAutoSaveVisual then VS.setAutoSaveVisual(S.autoSaveEnabled) end
if VS.setLockGuiVisual then VS.setLockGuiVisual(S.guiLocked) end end) section(pageSYS, "Mobile") VS.setMoveButtonsVisual = mkToggle(pageSYS, "Move Buttons", function(on) S.moveButtons = on and true or false S.lockMobileButtons = not S.moveButtons; F.saveConfig() end) VS.setLockMobileButtonsVisual = VS.setMoveButtonsVisual VS.setAllLockVisual = mkToggle(pageSYS, "All Lock Buttons", function(on) S.allLockButtons = on and true or false if S.allLockButtons then S.moveButtons = true; S.lockMobileButtons = false if VS.setMoveButtonsVisual then pcall(function() VS.setMoveButtonsVisual(true) end) end
end F.saveConfig() end) S.setAllLockVisual = VS.setAllLockVisual task.defer(function() if VS.setMoveButtonsVisual then VS.setMoveButtonsVisual(S.moveButtons == true) end if VS.setAllLockVisual then VS.setAllLockVisual(S.allLockButtons == true) end end) VS.setHideMobileVisual = mkToggle(pageSYS, "Hide Mobile Buttons", function(on) S.hideMobileButtons = on and true or false F.applyMobileButtonsHidden(); F.saveConfig() end) do
local row = mkRow(pageSYS, 34); mkLabel(row, "Mobile Buttons Size"); local minusBtn = Instance.new("TextButton", row); minusBtn.Size = UDim2.new(0, 28, 0, 24); minusBtn.Position = UDim2.new(1, -112, 0.5, -12); minusBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); minusBtn.BorderSizePixel = 0; minusBtn.Text = "−"; minusBtn.TextColor3 = COLORS.white; minusBtn.Font = Enum.Font.GothamBold; minusBtn.TextSize = 16; minusBtn.ZIndex = 5
corner(minusBtn, 8); local sizeLbl = Instance.new("TextLabel", row); sizeLbl.Size = UDim2.new(0, 44, 0, 24); sizeLbl.Position = UDim2.new(1, -80, 0.5, -12); sizeLbl.BackgroundColor3 = Color3.fromRGB(18, 18, 20); sizeLbl.BorderSizePixel = 0
sizeLbl.Text = string.format("%.2f", S.mobileButtonScale or 0.80); sizeLbl.TextColor3 = COLORS.white; sizeLbl.Font = Enum.Font.GothamBold; sizeLbl.TextSize = 11; sizeLbl.ZIndex = 5; corner(sizeLbl, 8); UI.mobileSizeLbl = sizeLbl; local plusBtn = Instance.new("TextButton", row); plusBtn.Size = UDim2.new(0, 28, 0, 24); plusBtn.Position = UDim2.new(1, -32, 0.5, -12); plusBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); plusBtn.BorderSizePixel = 0; plusBtn.Text = "+"; plusBtn.TextColor3 = COLORS.white; plusBtn.Font = Enum.Font.GothamBold; plusBtn.TextSize = 16; plusBtn.ZIndex = 5; corner(plusBtn, 8)
local function refreshSizeLbl() if UI.mobileSizeLbl then UI.mobileSizeLbl.Text = string.format("%.2f", S.mobileButtonScale or 0.80) end end minusBtn.Activated:Connect(function() S.mobileButtonScale = math.clamp((S.mobileButtonScale or 0.80) - 0.05, 0.30, 1.35) F.applyMobileButtonSize(); refreshSizeLbl(); F.saveConfig() end) plusBtn.Activated:Connect(function() S.mobileButtonScale = math.clamp((S.mobileButtonScale or 0.80) + 0.05, 0.30, 1.35) F.applyMobileButtonSize(); refreshSizeLbl(); F.saveConfig() end) end do
local row = mkRow(pageSYS, 34); mkLabel(row, "Reset Mobile Buttons"); local resetBtn = Instance.new("TextButton", row); resetBtn.Size = UDim2.new(0, 72, 0, 24); resetBtn.Position = UDim2.new(1, -82, 0.5, -12); resetBtn.BackgroundColor3 = Color3.fromRGB(238, 238, 238); resetBtn.BorderSizePixel = 0; resetBtn.Text = "RESET"; resetBtn.TextColor3 = Color3.fromRGB(0, 0, 0); resetBtn.Font = Enum.Font.GothamBold; resetBtn.TextSize = 11; resetBtn.ZIndex = 5; corner(resetBtn, 8) resetBtn.Activated:Connect(function() F.resetMobileButtons()
if UI.mobileSizeLbl then UI.mobileSizeLbl.Text = string.format("%.2f", S.mobileButtonScale or 0.80) end if VS.setHideMobileVisual then VS.setHideMobileVisual(false) end end) end do
local row = mkRow(pageSYS, 34); mkLabel(row, "Save Config"); local saveBtn = Instance.new("TextButton", row); saveBtn.Size = UDim2.new(0, 72, 0, 24); saveBtn.Position = UDim2.new(1, -82, 0.5, -12); saveBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 20); saveBtn.BackgroundTransparency = 0.1; saveBtn.BorderSizePixel = 0; saveBtn.Text = "SAVE"; saveBtn.TextColor3 = COLORS.white; saveBtn.Font = Enum.Font.GothamBold; saveBtn.TextSize = 11; saveBtn.ZIndex = 5; corner(saveBtn, 8); stroke(saveBtn, COLORS.stroke, 1, 0.75) saveBtn.Activated:Connect(function() if S._anyKeyListening then return end
saveBtn.Text = "..."; local mainOk = F.saveConfig(true); local featureOk = false; pcall(function() featureOk = F.saveFeatureConfig() end); local ok = (mainOk == true and featureOk == true); pcall(function() if F.saveMobileButtonsOnly then F.saveMobileButtonsOnly() end end) saveBtn.Text = ok and "SAVED" or "FAIL" if UI.saveStatusLbl then UI.saveStatusLbl.Text = ok and ("Saved " .. os.date("%H:%M:%S")) or "Save failed"; UI.saveStatusLbl.TextColor3 = ok and Color3.fromRGB(100, 220, 160) or Color3.fromRGB(255, 120, 120) end task.delay(1.4, function() if saveBtn and saveBtn.Parent then saveBtn.Text = "SAVE" end end) end) end do
local row = mkRow(pageSYS, 34); mkLabel(row, "Reset All Configs"); local resetCfgBtn = Instance.new("TextButton", row); resetCfgBtn.Size = UDim2.new(0, 72, 0, 24); resetCfgBtn.Position = UDim2.new(1, -82, 0.5, -12); resetCfgBtn.BackgroundColor3 = Color3.fromRGB(238, 80, 80); resetCfgBtn.BackgroundTransparency = 0.05; resetCfgBtn.BorderSizePixel = 0; resetCfgBtn.Text = "RESET"; resetCfgBtn.TextColor3 = Color3.fromRGB(192, 198, 210); resetCfgBtn.Font = Enum.Font.GothamBold; resetCfgBtn.TextSize = 11; resetCfgBtn.ZIndex = 5; corner(resetCfgBtn, 8); stroke(resetCfgBtn, Color3.fromRGB(255, 140, 140), 1, 0.45)
resetCfgBtn.Activated:Connect(function() if S._anyKeyListening then return end resetCfgBtn.Text = "..."; local ok = F.resetAllConfig(); resetCfgBtn.Text = ok and "DONE" or "OK" task.delay(1.5, function() if resetCfgBtn and resetCfgBtn.Parent then resetCfgBtn.Text = "RESET" end end) end) end do
local row = mkRow(pageSYS, 28); local st = Instance.new("TextLabel", row); st.Size = UDim2.new(1, -12, 1, 0); st.Position = UDim2.new(0, 10, 0, 0); st.BackgroundTransparency = 1; st.Text = "Save: ready"; st.TextColor3 = COLORS.textDim; st.Font = Enum.Font.GothamMedium; st.TextSize = 11; st.TextXAlignment = Enum.TextXAlignment.Left; st.ZIndex = 5; UI.saveStatusLbl = st end task.defer(function() if UI.saveStatusLbl then UI.saveStatusLbl.Text = "Save: manual only"; UI.saveStatusLbl.TextColor3 = COLORS.textDim end end) -- All keybind configuration UI is centralized in Protect.
lo = 0
UIS.InputBegan:Connect(function(input, gpe) if S._anyKeyListening then return end if input.UserInputType == Enum.UserInputType.Keyboard then
if gpe or UIS:GetFocusedTextBox() then return end elseif not isGamepadInput(input) then return end if not isBindableInput(input) then return end local kc = input.KeyCode if kbMatch(KB.LaggerToggle, kc) then F.toggleLaggerMode(); F.saveConfig() elseif kbMatch(KB.SpeedToggle, kc) then F.toggleCarryMode(); F.saveConfig() elseif kbMatch(KB.DropBrainrot, kc) then F.runDrop() elseif kbMatch(KB.TPFloor, kc) then F.runTPFloor() elseif kbMatch(KB.InstaReset, kc) then if cursedInstaReset then cursedInstaReset() end elseif kbMatch(KB.AutoLeft, kc) then S.autoLeftEnabled = not S.autoLeftEnabled
if S.autoLeftEnabled then F.queueAutoLeftStart() else F.stopAutoLeft() end if S.autoLeftSetVisual then S.autoLeftSetVisual(S.autoLeftEnabled) end elseif kbMatch(KB.AutoRight, kc) then S.autoRightEnabled = not S.autoRightEnabled if S.autoRightEnabled then F.queueAutoRightStart() else F.stopAutoRight() end if S.autoRightSetVisual then S.autoRightSetVisual(S.autoRightEnabled) end elseif kbMatch(KB.AutoBat, kc) then if not S.autoBatEnabled then F.queueAutoBatStart() if S.autoBatSetVisual then S.autoBatSetVisual(true) end else S.autoBatEnabled = false; S.disableAutoBat()
if S.autoBatSetVisual then S.autoBatSetVisual(false) end end elseif kbMatch(KB.TPBat, kc) then setTPBatState(not tpBatEnabled) elseif kbMatch(KB.GuiHide, kc) then if main.Visible then hideGui() else showGui() end end end) 
do
    -- ================================================================
    -- ============================================================
-- PROTECT PAGE: CENTRALIZED KEYBINDS
-- ============================================================
do
    local card = Instance.new("Frame", otherPage)
    card.Name = "ProtectKeybindsCard"
    card:SetAttribute("CentralizedKeybinds", true)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    card.BackgroundTransparency = 0.12
    card.BorderSizePixel = 0
    card.LayoutOrder = -900
    card.ZIndex = 40
    corner(card, 12)
    local cardStroke = stroke(card, S.themeColor or COLORS.accent, 1, 0.55)
    cardStroke:SetAttribute("ThemeAccent", true)

    local heading = Instance.new("TextLabel", card)
    heading.Size = UDim2.new(1, -20, 0, 18)
    heading.Position = UDim2.new(0, 10, 0, 7)
    heading.BackgroundTransparency = 1
    heading.Text = "KEYBINDS"
    heading.TextColor3 = Color3.fromRGB(245, 245, 248)
    heading.Font = Enum.Font.GothamBold
    heading.TextSize = 11
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.TextTruncate = Enum.TextTruncate.AtEnd
    heading.ZIndex = 41

    local hint = Instance.new("TextLabel", card)
    hint.Size = UDim2.new(1, -20, 0, 13)
    hint.Position = UDim2.new(0, 10, 0, 25)
    hint.BackgroundTransparency = 1
    hint.Text = "All toggle and action keybinds"
    hint.TextColor3 = Color3.fromRGB(165, 165, 173)
    hint.Font = Enum.Font.GothamMedium
    hint.TextSize = 8
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.TextTruncate = Enum.TextTruncate.AtEnd
    hint.ZIndex = 41

    local list = Instance.new("Frame", card)
    list.Name = "KeybindList"
    list.Size = UDim2.new(1, -12, 0, 0)
    list.Position = UDim2.new(0, 6, 0, 44)
    list.BackgroundTransparency = 1
    list.ZIndex = 40
    local ll = Instance.new("UIListLayout", list)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 6)

    local function addKey(labelText, entry, callback)
        local row = mkRow(list, 38)
        row.ZIndex = 40
        for _, d in ipairs(row:GetDescendants()) do
            if d:IsA("GuiObject") then
                d.ZIndex = math.max(40, tonumber(d.ZIndex) or 40)
            end
        end
        mkLabel(row, labelText)
        local keyBtn = mkKB(row, entry, function(k, isGp)
            if isGp then
                entry.gp = k
                entry.kb = nil
            else
                entry.kb = k
                entry.gp = nil
            end
            if callback then pcall(callback, k, isGp) end
            pcall(F.saveConfig)
        end)
        keyBtn.ZIndex = 42
    end

    addKey("Speed Key", KB.SpeedToggle)
    addKey("Lagger Key", KB.LaggerToggle)
    addKey("Auto Left Key", KB.AutoLeft)
    addKey("Auto Right Key", KB.AutoRight)
    addKey("Auto Bat Key", KB.AutoBat)
    addKey("TP Bat Key", KB.TPBat, function(k, isGp)
        if isGp then TP_BAT_CONTROLLER = k else TP_BAT_KEY = k end
    end)
    addKey("Drop Key", KB.DropBrainrot)
    addKey("TP Down Key", KB.TPFloor)
    addKey("Instant Reset Key", KB.InstaReset)
    addKey("Hide UI Key", KB.GuiHide)

    local rows = 10
    local listH = rows * 38 + (rows - 1) * 6
    list.Size = UDim2.new(1, -12, 0, listH)
    card.Size = UDim2.new(1, 0, 0, 52 + listH)

    _G.__VxyroProtectKeybindRefresh = function(col)
        col = col or S.themeColor or COLORS.accent
        pcall(function() cardStroke.Color = col end)
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("UIStroke") and d:GetAttribute("ThemeAccent") then
                d.Color = col
            end
        end
    end
    pcall(function() if _G.__VxyroProtectKeybindRefresh then _G.__VxyroProtectKeybindRefresh(S.themeColor) end end)
end

-- VXYRO IMPORTS REPAIRED
    -- Avatar Changer + Skin Tool (Bat/Medusa) + Custom Sound +
    -- Vivid Graphics + Motion Blur.
    -- ================================================================

    local AV = {
        cats = {
            {name="Hair", type=Enum.AvatarAssetType.HairAccessory},
            {name="Hats", type=Enum.AvatarAssetType.Hat},
            {name="Face", type=Enum.AvatarAssetType.FaceAccessory},
            {name="Neck", type=Enum.AvatarAssetType.NeckAccessory},
            {name="Shoulder", type=Enum.AvatarAssetType.ShoulderAccessory},
            {name="Front", type=Enum.AvatarAssetType.FrontAccessory},
            {name="Back", type=Enum.AvatarAssetType.BackAccessory},
            {name="Waist", type=Enum.AvatarAssetType.WaistAccessory},
            {name="Shirts", type=Enum.AvatarAssetType.Shirt},
            {name="Pants", type=Enum.AvatarAssetType.Pants},
            {name="T-Shirts", type=Enum.AvatarAssetType.TShirt},
            {name="Jackets", type=Enum.AvatarAssetType.JacketAccessory},
            {name="Sweaters", type=Enum.AvatarAssetType.SweaterAccessory},
            {name="Bottoms", type=Enum.AvatarAssetType.ShortsAccessory},
        },
        cache = {},
        gen = 0,
        visual = {},
        picker = nil,
        pickerCat = nil,
        favoriteMax = 5,
    }

    S.avatarChanger = type(S.avatarChanger) == "table" and S.avatarChanger or {}
    for _, cat in ipairs(AV.cats) do
        local e = S.avatarChanger[cat.name]
        if type(e) ~= "table" then
            e = {enabled=false, savedId=nil, savedName=""}
            S.avatarChanger[cat.name] = e
        end
        e.enabled = e.enabled == true
        e.savedId = tonumber(e.savedId)
        e.savedName = tostring(e.savedName or "")
        if type(e.favorites) ~= "table" then e.favorites = {} end
        local favNorm, favSeen = {}, {}
        for _, fav in ipairs(e.favorites) do
            local fid = tonumber(type(fav) == "table" and fav.id or fav)
            local fname = tostring(type(fav) == "table" and fav.name or "Asset")
            if fid and not favSeen[fid] and #favNorm < 5 then
                favSeen[fid] = true
                favNorm[#favNorm + 1] = {id=fid, name=fname}
            end
        end
        e.favorites = favNorm
    end

    local function safeParentGui()
        local ok, res = pcall(function()
            if type(gethui) == "function" then return gethui() end
            if type(get_hidden_gui) == "function" then return get_hidden_gui() end
            return game:GetService("CoreGui")
        end)
        if ok and typeof(res) == "Instance" then return res end
        return LP:WaitForChild("PlayerGui")
    end

    local function avWaitChar(char, timeout)
        if not char then return false end
        local deadline = os.clock() + (tonumber(timeout) or 8)
        while os.clock() < deadline do
            if not char.Parent or LP.Character ~= char then return false end
            if char:FindFirstChild("Head")
               and char:FindFirstChild("HumanoidRootPart")
               and char:FindFirstChildOfClass("Humanoid") then
                return true
            end
            task.wait(0.05)
        end
        return false
    end

    local function normalizeAsset(root)
        if not root then return nil end
        if root:IsA("Accessory") or root:IsA("Shirt") or root:IsA("Pants") or root:IsA("ShirtGraphic") then
            return root
        end
        if root:IsA("Folder") or root:IsA("Model") then
            local direct = root:FindFirstChildOfClass("Accessory")
                or root:FindFirstChildOfClass("Shirt")
                or root:FindFirstChildOfClass("Pants")
                or root:FindFirstChildOfClass("ShirtGraphic")
            if direct then return direct end
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("Accessory") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then
                    return d
                end
            end
        end
        return root
    end

    local function isAccessoryInCategory(obj, catName)
        if not obj or not obj:IsA("Accessory") then return false end
        local tagged = false
        pcall(function() tagged = obj:GetAttribute("_VyxroAvatarChanger") == true end)
        local accessoryType = nil
        pcall(function() accessoryType = obj.AccessoryType end)
        if catName == "Hair" and accessoryType == Enum.AccessoryType.Hair then return true end
        if catName == "Hats" and accessoryType == Enum.AccessoryType.Hat then return true end
        local h = obj:FindFirstChild("Handle")
        if h then
            if catName == "Hair" then
                if h:FindFirstChild("HairAttachment") then return true end
            elseif catName == "Hats" then
                if h:FindFirstChild("HatAttachment") or h:FindFirstChild("FaceFrontAttachment") or h:FindFirstChild("FaceCenterAttachment") then return true end
            end
        end
        if tagged then
            return false
        end
        local lower = obj.Name:lower()
        return lower:find(catName:lower(), 1, true) ~= nil
    end

    local function avRemoveAccessoryCategory(char, catName)
        if not char then return end
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") and isAccessoryInCategory(obj, catName) then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    local function avRemove(cat, name)
        local char = LP.Character
        if not char then return end
        pcall(function()
            local typ = cat.type
            if typ == Enum.AvatarAssetType.Shirt then
                for _,o in ipairs(char:GetChildren()) do
                    if o:IsA("Shirt") and (o.Name == "ACShirt" or o.Name == name) then o:Destroy() end
                end
            elseif typ == Enum.AvatarAssetType.Pants then
                for _,o in ipairs(char:GetChildren()) do
                    if o:IsA("Pants") and (o.Name == "ACPants" or o.Name == name) then o:Destroy() end
                end
            elseif typ == Enum.AvatarAssetType.TShirt then
                for _,o in ipairs(char:GetChildren()) do
                    if o:IsA("ShirtGraphic") and (o.Name == "ACTShirt" or o.Name == name) then o:Destroy() end
                end
            elseif cat.name == "Hair" then
                avRemoveAccessoryCategory(char, "Hair")
            elseif cat.name == "Hats" then
                avRemoveAccessoryCategory(char, "Hats")
            else
                for _,o in ipairs(char:GetChildren()) do
                    if o:IsA("Accessory") and (o.Name == "AC"..tostring(name) or o.Name == tostring(name)) then
                        o:Destroy()
                    end
                end
            end
        end)
    end

    local function avManualAccessoryFallback(char, obj, catName)
        local handle = obj and obj:FindFirstChild("Handle")
        if not handle then return false end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local targetPart = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        if not targetPart then return false end
        obj.Name = "AC" .. tostring(obj.Name)
        obj.Parent = char
        handle.CFrame = targetPart.CFrame
        for _,j in ipairs(handle:GetChildren()) do
            if j:IsA("Weld") or j:IsA("ManualWeld") or j:IsA("WeldConstraint") or j:IsA("AccessoryWeld") then
                pcall(function() j:Destroy() end)
            end
        end
        local w = Instance.new("Weld")
        w.Name = "ACManualWeld"
        w.Part0 = handle
        w.Part1 = targetPart
        w.C0 = CFrame.new(0, 0.5, 0)
        w.Parent = handle
        pcall(function() if hum then hum:AddAccessory(obj) end end)
        return obj.Parent == char
    end

    local function avEquip(cat, id, itemName, generation)
        if not id or generation ~= AV.gen then return false end
        local ok, applied = pcall(function()
            local obj
            local cached = AV.cache[id]
            if cached then
                obj = cached:Clone()
            else
                local got = game:GetObjects("rbxassetid://" .. tostring(id))
                if not got or not got[1] then return false end
                AV.cache[id] = got[1]:Clone()
                obj = AV.cache[id]:Clone()
            end

            if generation ~= AV.gen then return false end
            local char = LP.Character
            if not char or not avWaitChar(char, 8) then return false end
            obj = normalizeAsset(obj)
            if not obj then return false end

            if obj:IsA("Shirt") then
                for _,o in ipairs(char:GetChildren()) do if o:IsA("Shirt") then o:Destroy() end end
                obj.Name = "ACShirt"
                pcall(function() obj:SetAttribute("_VyxroAvatarChanger", true) end)
                obj.Parent = char
                return true
            elseif obj:IsA("Pants") then
                for _,o in ipairs(char:GetChildren()) do if o:IsA("Pants") then o:Destroy() end end
                obj.Name = "ACPants"
                pcall(function() obj:SetAttribute("_VyxroAvatarChanger", true) end)
                obj.Parent = char
                return true
            elseif obj:IsA("ShirtGraphic") then
                for _,o in ipairs(char:GetChildren()) do if o:IsA("ShirtGraphic") then o:Destroy() end end
                obj.Name = "ACTShirt"
                pcall(function() obj:SetAttribute("_VyxroAvatarChanger", true) end)
                obj.Parent = char
                return true
            end

            if not obj:IsA("Accessory") then return false end
            if cat.name == "Hair" then
                avRemoveAccessoryCategory(char, "Hair")
            elseif cat.name == "Hats" then
                avRemoveAccessoryCategory(char, "Hats")
            else
                avRemove(cat, itemName)
            end

            obj.Name = "AC" .. tostring(itemName or obj.Name)
            pcall(function() obj:SetAttribute("_VyxroAvatarChanger", true) end)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local handle = obj:FindFirstChild("Handle")
            if not hum or not handle then return false end

            -- AddAccessory works most reliably when the accessory is unparented first.
            obj.Parent = nil
            local addOK = pcall(function() hum:AddAccessory(obj) end)
            if addOK and obj.Parent == char then
                local hasJoint = handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("WeldConstraint")
                if hasJoint then return true end
                -- Some executor/game combinations parent the accessory but fail to create the joint.
                obj.Parent = nil
            end

            -- Manual attachment fallback for Hair/Hats and other UGC accessories.
            obj.Parent = char
            pcall(function() handle.CanCollide = false; handle.CanTouch = false; handle.CanQuery = false; handle.Massless = true end)
            local accessoryAttachment = handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("HatAttachment") or handle:FindFirstChildOfClass("Attachment")
            local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
            local targetAttachment = nil
            if accessoryAttachment then
                for _,bodyPart in ipairs(char:GetDescendants()) do
                    if bodyPart:IsA("BasePart") then
                        local a2 = bodyPart:FindFirstChild(accessoryAttachment.Name)
                        if a2 and a2:IsA("Attachment") then
                            targetPart = bodyPart
                            targetAttachment = a2
                            break
                        end
                    end
                end
            end
            if not targetPart then return false end
            for _,j in ipairs(handle:GetChildren()) do
                if j:IsA("Weld") or j:IsA("ManualWeld") or j:IsA("WeldConstraint") or j:IsA("AccessoryWeld") then
                    pcall(function() j:Destroy() end)
                end
            end
            if accessoryAttachment and targetAttachment then
                pcall(function()
                    handle.CFrame = targetAttachment.WorldCFrame * accessoryAttachment.CFrame:Inverse()
                end)
            else
                pcall(function() handle.CFrame = targetPart.CFrame * CFrame.new(0, 1.5, 0) end)
            end
            local wc = Instance.new("WeldConstraint")
            wc.Name = "ACManualWeld"
            wc.Part0 = handle
            wc.Part1 = targetPart
            wc.Parent = handle
            return obj.Parent == char
        end)
        return ok and applied == true
    end

    -- Low-stutter avatar apply queue. Only enabled categories are processed,
    -- one at a time, outside the GUI thread. Cached assets are reused so
    -- re-apply/respawn does not repeatedly call GetObjects for the same id.
    AV.applyToken = 0
    AV.applyRunning = false

    local function avApplyAll(generation)
        if S.avaPresetEnabled == true and _G.__VxyroAvaPresetActive == true then return end
        AV.applyToken = AV.applyToken + 1
        local myToken = AV.applyToken
        if AV.applyRunning then return end
        AV.applyRunning = true
        task.spawn(function()
            local ok = pcall(function()
                local char = LP.Character
                if not char or not avWaitChar(char, 4) then return end
                for _, cat in ipairs(AV.cats) do
                    if myToken ~= AV.applyToken or generation ~= AV.gen then break end
                    local e = S.avatarChanger[cat.name]
                    if e and e.enabled and e.savedId then
                        -- One immediate attempt is enough in the common path.
                        -- Only retry Hair/Hats when their first attachment fails.
                        local success = avEquip(cat, e.savedId, e.savedName, generation)
                        if not success and (cat.name == "Hair" or cat.name == "Hats") then
                            for retry = 1, 2 do
                                task.wait(0.16 * retry)
                                if myToken ~= AV.applyToken or generation ~= AV.gen or not e.enabled then break end
                                success = avEquip(cat, e.savedId, e.savedName, generation)
                                if success then break end
                            end
                        end
                        -- Yield a little between categories to prevent a burst
                        -- when several saved accessories are restored together.
                        task.wait(0.06)
                    end
                end
            end)
            AV.applyRunning = false
            -- If another load/respawn request arrived while this queue was
            -- running, schedule exactly one fresh pass instead of stacking
            -- multiple apply workers.
            if myToken ~= AV.applyToken and generation == AV.gen then
                task.defer(function()
                    avApplyAll(AV.gen)
                end)
            end
        end)
    end

    local avRefresh
    local avClosePicker

    avRefresh = function(catName)
        local e = S.avatarChanger[catName]
        local v = AV.visual[catName]
        if v then
            if v.pill and v.dot then animPill(v.pill, v.dot, e and e.enabled == true) end
            if v.name then
                v.name.Text = (e and e.savedName ~= "" and e.savedName) or "None"
            end
        end
    end

    avClosePicker = function()
        if AV.picker and AV.picker.Parent then pcall(function() AV.picker:Destroy() end) end
        AV.picker = nil
        AV.pickerCat = nil
    end

    local function avOpenPicker(cat)
        if AV.picker and AV.picker.Parent and AV.pickerCat == cat.name then
            avClosePicker()
            return
        end
        avClosePicker()
        AV.pickerCat = cat.name
        local aes = game:GetService("AvatarEditorService")
        local parentGui = safeParentGui()
        local sg = Instance.new("ScreenGui")
        sg.Name = "VyxroAvatarPicker"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = 10050
        sg.Parent = parentGui
        AV.picker = sg

        local backdrop = Instance.new("Frame")
        backdrop.Size = UDim2.fromScale(1,1)
        backdrop.BackgroundColor3 = Color3.new(0,0,0)
        backdrop.BackgroundTransparency = 0.45
        backdrop.BorderSizePixel = 0
        backdrop.ZIndex = 1
        backdrop.Parent = sg

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0,370,0,560)
        box.Position = UDim2.new(0.5,-185,0.5,-255)
        box.BackgroundColor3 = Color3.fromRGB(8,8,10)
        box.BorderSizePixel = 0
        box.ZIndex = 2
        box.Parent = sg
        corner(box,16)
        local pickerAccent = S.themeColor or Color3.fromRGB(170,140,220)
        local boxStroke = stroke(box,pickerAccent,1,0.38)

        -- Lightweight layered glow: static, no RenderStepped loop.
        local glowOuter = Instance.new("Frame")
        glowOuter.Name = "PremiumGlowOuter"
        glowOuter.Size = UDim2.new(1,18,1,18)
        glowOuter.Position = UDim2.new(0,-9,0,-9)
        glowOuter.BackgroundColor3 = pickerAccent
        glowOuter.BackgroundTransparency = 0.93
        glowOuter.BorderSizePixel = 0
        glowOuter.ZIndex = 1
        glowOuter.Parent = box
        corner(glowOuter,22)
        local glowMid = Instance.new("Frame")
        glowMid.Name = "PremiumGlowMid"
        glowMid.Size = UDim2.new(1,10,1,10)
        glowMid.Position = UDim2.new(0,-5,0,-5)
        glowMid.BackgroundColor3 = pickerAccent
        glowMid.BackgroundTransparency = 0.955
        glowMid.BorderSizePixel = 0
        glowMid.ZIndex = 1
        glowMid.Parent = box
        corner(glowMid,19)

        local topAura = Instance.new("Frame")
        topAura.Name = "AccentAura"
        topAura.Size = UDim2.new(1,-28,0,2)
        topAura.Position = UDim2.new(0,14,0,42)
        topAura.BackgroundColor3 = pickerAccent
        topAura.BackgroundTransparency = 0.16
        topAura.BorderSizePixel = 0
        topAura.ZIndex = 4
        topAura.Parent = box
        corner(topAura,4)

        local topAuraGlow = Instance.new("Frame")
        topAuraGlow.Name = "AccentAuraGlow"
        topAuraGlow.Size = UDim2.new(1,14,1,8)
        topAuraGlow.Position = UDim2.new(0,-7,0,-3)
        topAuraGlow.BackgroundColor3 = pickerAccent
        topAuraGlow.BackgroundTransparency = 0.92
        topAuraGlow.BorderSizePixel = 0
        topAuraGlow.ZIndex = 3
        topAuraGlow.Parent = topAura
        corner(topAuraGlow,8)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1,-58,0,38)
        title.Position = UDim2.new(0,14,0,6)
        title.BackgroundTransparency = 1
        title.Text = cat.name .. " Changer"
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = pickerAccent:Lerp(Color3.new(1,1,1),0.12)
        title.TextStrokeColor3 = pickerAccent
        title.TextStrokeTransparency = 0.88
        title.Parent = box

        local titleSub = Instance.new("TextLabel")
        titleSub.Name = "Subtitle"
        titleSub.Size = UDim2.new(1,-70,0,16)
        titleSub.Position = UDim2.new(0,16,0,34)
        titleSub.BackgroundTransparency = 1
        titleSub.Text = string.upper(cat.name) .. "  •  PICK / FAVORITE / APPLY"
        titleSub.TextColor3 = pickerAccent:Lerp(Color3.new(1,1,1),0.45)
        titleSub.Font = Enum.Font.GothamSemibold
        titleSub.TextSize = 7
        titleSub.TextXAlignment = Enum.TextXAlignment.Left
        titleSub.Parent = box

        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0,32,0,32)
        close.Position = UDim2.new(1,-40,0,8)
        close.BackgroundColor3 = Color3.fromRGB(24,24,27)
        close.BorderSizePixel = 0
        close.Text = "X"
        close.TextColor3 = Color3.new(1,1,1)
        close.Font = Enum.Font.GothamBold
        close.TextSize = 13
        close.AutoButtonColor = false
        close.Parent = box
        corner(close,9)
        stroke(close,pickerAccent,1,0.28)
        close.MouseEnter:Connect(function()
            TS:Create(close,TweenInfo.new(0.10,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundColor3=pickerAccent,TextColor3=Color3.new(1,1,1)}):Play()
        end)
        close.MouseLeave:Connect(function()
            TS:Create(close,TweenInfo.new(0.12,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundColor3=Color3.fromRGB(24,24,27),TextColor3=Color3.new(1,1,1)}):Play()
        end)
        close.Activated:Connect(avClosePicker)

        local search = Instance.new("TextBox")
        search.Size = UDim2.new(1,-24,0,30)
        search.Position = UDim2.new(0,12,0,52)
        search.BackgroundColor3 = Color3.fromRGB(18,18,20)
        search.BorderSizePixel = 0
        search.PlaceholderText = "Search..."
        search.PlaceholderColor3 = Color3.fromRGB(110,110,110)
        search.Text = ""
        search.TextColor3 = Color3.new(1,1,1)
        search.Font = Enum.Font.GothamSemibold
        search.TextSize = 12
        search.ClearTextOnFocus = false
        search.Parent = box
        corner(search,8)
        local searchStroke = stroke(search,pickerAccent,1,0.52)
        local searchGrad = Instance.new("UIGradient")
        searchGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(24,24,29)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(15,15,19)),
            ColorSequenceKeypoint.new(1, pickerAccent:Lerp(Color3.new(0,0,0),0.88)),
        })
        searchGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(1,0.18),
        })
        searchGrad.Parent = search
        search.Focused:Connect(function()
            TS:Create(searchStroke,TweenInfo.new(0.12,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency=0.08,Thickness=1.4}):Play()
        end)
        search.FocusLost:Connect(function()
            TS:Create(searchStroke,TweenInfo.new(0.14,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency=0.52,Thickness=1}):Play()
        end)

        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(1,-24,0,18)
        status.Position = UDim2.new(0,12,0,84)
        status.BackgroundTransparency = 1
        status.Text = "Loading..."
        status.TextColor3 = Color3.fromRGB(150,150,150)
        status.Font = Enum.Font.GothamSemibold
        status.TextSize = 10
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.Parent = box

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1,-12,1,-188)
        scroll.Position = UDim2.new(0,6,0,178)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = Color3.fromRGB(90,90,90)
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = box

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.new(0,105,0,122)
        grid.CellPadding = UDim2.new(0,7,0,7)
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = scroll

        local page = nil
        local loadingMore = false
        local order = 0
        local activeSearchQuery = ""
        local searchGeneration = 0
        local SEARCH_MAX_AUTO_PAGES = 6

        local function startsWithQuery(name, query)
            name = tostring(name or "")
            query = tostring(query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
            if query == "" then return true end
            return name:sub(1, #query):lower() == query
        end

        -- ============================================================
        -- FAVORITES: MAX 5 PER CATEGORY
        -- ============================================================
        local function avatarState()
            local e = S.avatarChanger[cat.name]
            if not e then
                e = {enabled=false, savedId=nil, savedName="", favorites={}}
                S.avatarChanger[cat.name] = e
            end
            if type(e.favorites) ~= "table" then e.favorites = {} end
            return e
        end

        local function isFavorite(id)
            id = tonumber(id)
            if not id then return false end
            for _, fav in ipairs(avatarState().favorites) do
                if tonumber(fav.id) == id then return true end
            end
            return false
        end

        local function toggleFavorite(id, name)
            id = tonumber(id)
            if not id then return false, "invalid" end
            local e = avatarState()
            for i, fav in ipairs(e.favorites) do
                if tonumber(fav.id) == id then
                    table.remove(e.favorites, i)
                    pcall(F.saveConfig)
                    return true, "removed"
                end
            end
            if #e.favorites >= (AV.favoriteMax or 5) then
                return false, "full"
            end
            e.favorites[#e.favorites + 1] = {id=id, name=tostring(name or "Asset")}
            pcall(F.saveConfig)
            return true, "added"
        end

        -- Premium favorites header + strip. Kept compact so the picker still fits on phone screens.
        local favHeader = Instance.new("Frame")
        favHeader.Name = "FavoritesHeader"
        favHeader.Size = UDim2.new(1,-24,0,20)
        favHeader.Position = UDim2.new(0,12,0,103)
        favHeader.BackgroundTransparency = 1
        favHeader.Parent = box

        local favAccent = S.themeColor or Color3.fromRGB(170,140,220)
        local favTitle = Instance.new("TextLabel")
        favTitle.Size = UDim2.new(0.65,0,1,0)
        favTitle.Position = UDim2.new(0,2,0,0)
        favTitle.BackgroundTransparency = 1
        favTitle.Text = "★  QUICK FAVORITES"
        favTitle.TextColor3 = favAccent:Lerp(Color3.new(1,1,1),0.18)
        favTitle.Font = Enum.Font.GothamBlack
        favTitle.TextSize = 10
        favTitle.TextXAlignment = Enum.TextXAlignment.Left
        favTitle.Parent = favHeader

        local favCount = Instance.new("TextLabel")
        favCount.Size = UDim2.new(0,48,0,18)
        favCount.Position = UDim2.new(1,-48,0,0)
        favCount.BackgroundColor3 = favAccent
        favCount.BackgroundTransparency = 0.10
        favCount.BorderSizePixel = 0
        favCount.Text = "0/5"
        favCount.TextColor3 = Color3.new(1,1,1)
        favCount.Font = Enum.Font.GothamBlack
        favCount.TextSize = 9
        favCount.TextXAlignment = Enum.TextXAlignment.Center
        favCount.Parent = favHeader
        corner(favCount,8)
        stroke(favCount,favAccent,1,0.30)

        local favoriteStrip = Instance.new("ScrollingFrame")
        favoriteStrip.Name = "Favorites"
        favoriteStrip.Size = UDim2.new(1,-24,0,55)
        favoriteStrip.Position = UDim2.new(0,12,0,123)
        favoriteStrip.BackgroundColor3 = Color3.fromRGB(11,11,14)
        favoriteStrip.BackgroundTransparency = 0.04
        favoriteStrip.BorderSizePixel = 0
        favoriteStrip.ScrollBarThickness = 0
        favoriteStrip.ScrollBarImageTransparency = 1
        favoriteStrip.CanvasSize = UDim2.new(0,0,0,55)
        favoriteStrip.AutomaticCanvasSize = Enum.AutomaticSize.None
        favoriteStrip.ScrollingDirection = Enum.ScrollingDirection.Y
        favoriteStrip.ScrollingEnabled = false
        favoriteStrip.CanvasPosition = Vector2.new(0,0)
        favoriteStrip.Parent = box
        corner(favoriteStrip,11)
        local favStripStroke = stroke(favoriteStrip,favAccent,1.1,0.20)

        -- Decorative lines/glow live in a sibling overlay instead of inside
        -- the UIListLayout. Otherwise their full width is treated as a list item
        -- and pushes favorite cards off-screen to the right.
        local favOverlay = Instance.new("Frame")
        favOverlay.Name = "FavoritesDecorOverlay"
        favOverlay.Size = favoriteStrip.Size
        favOverlay.Position = favoriteStrip.Position
        favOverlay.BackgroundTransparency = 1
        favOverlay.BorderSizePixel = 0
        favOverlay.ZIndex = 5
        favOverlay.ClipsDescendants = true
        favOverlay.Parent = box
        corner(favOverlay,11)

        local favTopLine = Instance.new("Frame")
        favTopLine.Name = "FavoritesTopLine"
        favTopLine.Size = UDim2.new(1,-22,0,2)
        favTopLine.Position = UDim2.new(0,11,0,1)
        favTopLine.BackgroundColor3 = favAccent
        favTopLine.BackgroundTransparency = 0.12
        favTopLine.BorderSizePixel = 0
        favTopLine.ZIndex = 6
        favTopLine.Parent = favOverlay
        corner(favTopLine,5)
        local favBottomLine = Instance.new("Frame")
        favBottomLine.Name = "FavoritesBottomLine"
        favBottomLine.Size = UDim2.new(1,-22,0,1)
        favBottomLine.Position = UDim2.new(0,11,1,-2)
        favBottomLine.BackgroundColor3 = favAccent
        favBottomLine.BackgroundTransparency = 0.72
        favBottomLine.BorderSizePixel = 0
        favBottomLine.ZIndex = 6
        favBottomLine.Parent = favOverlay

        local favGlow = Instance.new("Frame")
        favGlow.Name = "AccentGlow"
        favGlow.Size = UDim2.new(1,0,0,2)
        favGlow.Position = UDim2.new(0,0,0,0)
        favGlow.BackgroundColor3 = favAccent
        favGlow.BackgroundTransparency = 0.15
        favGlow.BorderSizePixel = 0
        favGlow.ZIndex = 3
        favGlow.Parent = favOverlay
        corner(favGlow,4)

        local favEmpty = Instance.new("TextLabel")
        favEmpty.Name = "EmptyHint"
        favEmpty.Size = UDim2.new(1,-16,1,-10)
        favEmpty.Position = UDim2.new(0,8,0,5)
        favEmpty.BackgroundTransparency = 1
        favEmpty.Text = "Tap ☆ on an item to pin it here"
        favEmpty.TextColor3 = Color3.fromRGB(120,120,130)
        favEmpty.Font = Enum.Font.GothamSemibold
        favEmpty.TextSize = 9
        favEmpty.TextXAlignment = Enum.TextXAlignment.Center
        favEmpty.TextYAlignment = Enum.TextYAlignment.Center
        favEmpty.LayoutOrder = -999
        favEmpty.ZIndex = 2
        favEmpty.Parent = favoriteStrip

        local favLayout = Instance.new("UIListLayout")
        favLayout.FillDirection = Enum.FillDirection.Horizontal
        favLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        favLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        favLayout.Padding = UDim.new(0,6)
        favLayout.SortOrder = Enum.SortOrder.LayoutOrder
        favLayout.Parent = favoriteStrip
        local favPad = Instance.new("UIPadding")
        favPad.PaddingLeft = UDim.new(0,6)
        favPad.PaddingRight = UDim.new(0,6)
        favPad.Parent = favoriteStrip

        local function refreshFavorites()
            for _, child in ipairs(favoriteStrip:GetChildren()) do
                if child:IsA("TextButton") or (child:IsA("Frame") and child.Name:match("^FavoriteSlot_")) then
                    child:Destroy()
                end
            end
            local e = avatarState()
            local maxFav = AV.favoriteMax or 5
            favCount.Text = string.format("%d/%d", #e.favorites, maxFav)
            favCount.BackgroundColor3 = favAccent
            favCount.TextColor3 = Color3.new(1,1,1)
            favTitle.TextColor3 = favAccent:Lerp(Color3.new(1,1,1),0.18)
            -- The visual-clean pass may have removed these optional stroke/line
            -- instances. Treat them as optional so favorites refresh can never
            -- abort the picker before the catalog loader starts.
            pcall(function() if favStripStroke and favStripStroke.Parent then favStripStroke.Color = favAccent end end)
            pcall(function() if favTopLine and favTopLine.Parent then favTopLine.BackgroundColor3 = favAccent end end)
            pcall(function() if favBottomLine and favBottomLine.Parent then favBottomLine.BackgroundColor3 = favAccent end end)
            pcall(function() if favGlow and favGlow.Parent then favGlow.BackgroundColor3 = favAccent end end)
            pcall(function() if boxStroke and boxStroke.Parent then boxStroke.Color = favAccent end end)
            pcall(function() if glowOuter and glowOuter.Parent then glowOuter.BackgroundColor3 = favAccent end end)
            pcall(function() if glowMid and glowMid.Parent then glowMid.BackgroundColor3 = favAccent end end)
            pcall(function() if topAura and topAura.Parent then topAura.BackgroundColor3 = favAccent end end)
            pcall(function() if topAuraGlow and topAuraGlow.Parent then topAuraGlow.BackgroundColor3 = favAccent end end)
            titleSub.TextColor3 = favAccent:Lerp(Color3.new(1,1,1),0.45)
            favEmpty.Visible = (#e.favorites == 0)
            for index, fav in ipairs(e.favorites) do
                local id = tonumber(fav.id)
                local slot = Instance.new("Frame")
                slot.Name = "FavoriteSlot_"..tostring(index)
                slot.Size = UDim2.new(0,56,0,47)
                slot.BackgroundColor3 = Color3.fromRGB(17,17,21)
                slot.BorderSizePixel = 0
                slot.LayoutOrder = index
                slot.ZIndex = 4
                slot.Parent = favoriteStrip
                corner(slot,10)
                local slotStroke = stroke(slot,favAccent,1.1,0.34)
                local slotGrad = Instance.new("UIGradient")
                slotGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, favAccent:Lerp(Color3.new(1,1,1),0.08)),
                    ColorSequenceKeypoint.new(0.52, Color3.fromRGB(18,18,22)),
                    ColorSequenceKeypoint.new(1, favAccent:Lerp(Color3.new(0,0,0),0.82)),
                })
                slotGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,0.82),
                    NumberSequenceKeypoint.new(0.55,0.90),
                    NumberSequenceKeypoint.new(1,0.78),
                })
                slotGrad.Parent = slot

                local favIndexBadge = Instance.new("TextLabel")
                favIndexBadge.Name = "Index"
                favIndexBadge.Size = UDim2.new(0,18,0,14)
                favIndexBadge.Position = UDim2.new(0,3,1,-17)
                favIndexBadge.BackgroundColor3 = favAccent
                favIndexBadge.BackgroundTransparency = 0.10
                favIndexBadge.BorderSizePixel = 0
                favIndexBadge.Text = "F" .. tostring(index)
                favIndexBadge.TextColor3 = Color3.new(1,1,1)
                favIndexBadge.Font = Enum.Font.GothamBlack
                favIndexBadge.TextSize = 7
                favIndexBadge.ZIndex = 8
                favIndexBadge.Parent = slot
                corner(favIndexBadge,5)

                local bi = Instance.new("ImageLabel")
                bi.Name = "Thumb"
                bi.Size = UDim2.new(1,-10,1,-10)
                bi.Position = UDim2.new(0,5,0,5)
                bi.BackgroundColor3 = Color3.fromRGB(25,25,29)
                bi.BackgroundTransparency = 0.05
                bi.BorderSizePixel = 0
                bi.Image = "rbxthumb://type=Asset&id="..tostring(id).."&w=150&h=150"
                bi.ScaleType = Enum.ScaleType.Fit
                bi.ZIndex = 5
                bi.Parent = slot
                corner(bi,8)

                local slotNo = Instance.new("TextLabel")
                slotNo.Size = UDim2.new(0,21,0,15)
                slotNo.Position = UDim2.new(0,3,0,3)
                slotNo.BackgroundColor3 = Color3.fromRGB(0,0,0)
                slotNo.BackgroundTransparency = 0.18
                slotNo.BorderSizePixel = 0
                slotNo.Text = string.format("%02d", index)
                slotNo.TextColor3 = Color3.fromRGB(235,235,240)
                slotNo.Font = Enum.Font.GothamBlack
                slotNo.TextSize = 8
                slotNo.ZIndex = 7
                slotNo.Parent = slot
                corner(slotNo,6)

                local star = Instance.new("TextLabel")
                star.Size = UDim2.new(0,18,0,18)
                star.Position = UDim2.new(1,-21,0,2)
                star.BackgroundColor3 = Color3.fromRGB(0,0,0)
                star.BackgroundTransparency = 0.10
                star.BorderSizePixel = 0
                star.Text = "★"
                star.TextColor3 = favAccent:Lerp(Color3.new(1,1,1),0.20)
                star.Font = Enum.Font.GothamBlack
                star.TextSize = 10
                star.ZIndex = 7
                star.Parent = slot
                corner(star,9)

                local hit = Instance.new("TextButton")
                hit.Size = UDim2.fromScale(1,1)
                hit.BackgroundTransparency = 1
                hit.BorderSizePixel = 0
                hit.Text = ""
                hit.AutoButtonColor = false
                hit.ZIndex = 8
                hit.Parent = slot

                hit.MouseEnter:Connect(function()
                    if slot.Parent then
                        TS:Create(slot,TweenInfo.new(0.10,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundColor3=favAccent:Lerp(Color3.new(1,1,1),0.08)}):Play()
                        slotStroke.Transparency = 0.05
                    end
                end)
                hit.MouseLeave:Connect(function()
                    if slot.Parent then
                        TS:Create(slot,TweenInfo.new(0.12,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundColor3=Color3.fromRGB(17,17,21)}):Play()
                        slotStroke.Transparency = 0.42
                    end
                end)
                hit.Activated:Connect(function()
                    local e2 = avatarState()
                    e2.savedId = id
                    e2.savedName = tostring(fav.name or "Asset")
                    if e2.enabled then
                        local capturedGen = AV.gen
                        task.spawn(function()
                            avEquip(cat,id,e2.savedName,capturedGen)
                            avRefresh(cat.name)
                        end)
                    end
                    avRefresh(cat.name)
                    pcall(F.saveConfig)
                    avClosePicker()
                end)
            end
        end

        -- ============================================================
        -- CLEAN AVATAR PICKER VISUALS
        -- Remove border/stroke/line decorations that can stack visually
        -- and look like random boxes on mobile. The picker stays flat,
        -- clean and functional; accent is kept only through fills/text.
        -- ============================================================
        local function cleanAvatarPickerDecorations()
            local removeNames = {
                PremiumGlowOuter = true,
                PremiumGlowMid = true,
                AccentAura = true,
                AccentAuraGlow = true,
                FavoritesDecorOverlay = true,
                FavoritesTopLine = true,
                FavoritesBottomLine = true,
                AccentGlow = true,
                AccentLine = true,
            }
            for _, obj in ipairs(sg:GetDescendants()) do
                if obj:IsA("UIStroke") or obj:IsA("UIGradient") then
                    pcall(function() obj:Destroy() end)
                elseif removeNames[obj.Name] then
                    pcall(function() obj:Destroy() end)
                end
            end
            pcall(function()
                box.BorderSizePixel = 0
                search.BorderSizePixel = 0
                favoriteStrip.BorderSizePixel = 0
            end)
        end

        -- Run after all picker children exist so every old visual decoration
        -- from the previous styled version is removed in one pass.
        cleanAvatarPickerDecorations()

        local function clearCards()
            for _,o in ipairs(scroll:GetChildren()) do
                if o:IsA("TextButton") then o:Destroy() end
            end
            order = 0
        end

        local function addCard(item, expectedQuery)
            local id = tonumber(item.Id)
            if not id then return false end
            -- Prefix search: only show names whose BEGINNING matches the
            -- typed text. Example: "v" => V..., "ha" => Ha....
            local queryToMatch = (expectedQuery ~= nil) and expectedQuery or activeSearchQuery
            if not startsWithQuery(item.Name, queryToMatch) then
                return false
            end
            order += 1
            local card = Instance.new("TextButton")
            card.Name = "AC_Item_" .. tostring(id)
            card.Size = UDim2.new(0,105,0,122)
            card.BackgroundColor3 = Color3.fromRGB(16,16,18)
            card.BorderSizePixel = 0
            card.Text = ""
            card.AutoButtonColor = false
            card.LayoutOrder = order
            card.Parent = scroll
            corner(card,9)
            local cs = stroke(card,pickerAccent:Lerp(Color3.new(1,1,1),0.08),1,0.58)
            local cardTop = Instance.new("Frame")
            cardTop.Name = "AccentLine"
            cardTop.Size = UDim2.new(1,-18,0,2)
            cardTop.Position = UDim2.new(0,9,0,1)
            cardTop.BackgroundColor3 = pickerAccent
            cardTop.BackgroundTransparency = 0.78
            cardTop.BorderSizePixel = 0
            cardTop.ZIndex = 3
            cardTop.Parent = card
            corner(cardTop,4)

            local favBtn = Instance.new("TextButton")
            favBtn.Name = "FavoriteButton"
            favBtn.Size = UDim2.new(0,22,0,22)
            favBtn.Position = UDim2.new(1,-25,0,3)
            favBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
            favBtn.BackgroundTransparency = 0.18
            favBtn.BorderSizePixel = 0
            favBtn.Text = isFavorite(id) and "★" or "☆"
            favBtn.TextColor3 = isFavorite(id) and pickerAccent:Lerp(Color3.new(1,1,1),0.08) or Color3.fromRGB(205,205,215)
            favBtn.Font = Enum.Font.GothamBlack
            favBtn.TextSize = 12
            favBtn.AutoButtonColor = false
            favBtn.ZIndex = 20
            favBtn.Parent = card
            corner(favBtn,11)
            favBtn.Activated:Connect(function()
                local _, result = toggleFavorite(id, tostring(item.Name or "Asset"))
                if result == "full" then
                    favBtn.Text = "!"
                    favBtn.TextColor3 = Color3.fromRGB(255,120,120)
                    task.delay(0.7, function()
                        if favBtn.Parent then
                            local fav = isFavorite(id)
                            favBtn.Text = fav and "★" or "☆"
                            favBtn.TextColor3 = fav and Color3.fromRGB(255,215,70) or Color3.fromRGB(205,205,215)
                        end
                    end)
                else
                    local fav = isFavorite(id)
                    favBtn.Text = fav and "★" or "☆"
                    favBtn.TextColor3 = fav and Color3.fromRGB(255,215,70) or Color3.fromRGB(205,205,215)
                    refreshFavorites()
                end
            end)

            card.MouseEnter:Connect(function()
                if card.Parent then
                    TS:Create(card,TweenInfo.new(0.11,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundColor3=pickerAccent:Lerp(Color3.new(1,1,1),0.08)}):Play()
                    TS:Create(cs,TweenInfo.new(0.11,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency=0.16,Thickness=1.25}):Play()
                    TS:Create(cardTop,TweenInfo.new(0.11),{BackgroundTransparency=0.24}):Play()
                end
            end)
            card.MouseLeave:Connect(function()
                if card.Parent then
                    TS:Create(card,TweenInfo.new(0.14,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundColor3=Color3.fromRGB(16,16,18)}):Play()
                    TS:Create(cs,TweenInfo.new(0.14,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Transparency=0.58,Thickness=1}):Play()
                    TS:Create(cardTop,TweenInfo.new(0.14),{BackgroundTransparency=0.78}):Play()
                end
            end)

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(1,-10,0,78)
            img.Position = UDim2.new(0,5,0,5)
            img.BackgroundColor3 = Color3.fromRGB(24,24,27)
            img.BorderSizePixel = 0
            img.Image = "rbxthumb://type=Asset&id="..id.."&w=150&h=150"
            img.ScaleType = Enum.ScaleType.Fit
            img.Parent = card
            corner(img,7)

            local nm = Instance.new("TextLabel")
            nm.Size = UDim2.new(1,-8,0,30)
            nm.Position = UDim2.new(0,4,1,-34)
            nm.BackgroundTransparency = 1
            nm.Text = tostring(item.Name or "Asset")
            nm.TextColor3 = Color3.fromRGB(235,235,235)
            nm.Font = Enum.Font.GothamSemibold
            nm.TextSize = 9
            nm.TextWrapped = true
            nm.Parent = card

            local saved = S.avatarChanger[cat.name]
            if saved and tonumber(saved.savedId) == id then
                card.BackgroundColor3 = Color3.fromRGB(20,36,20)
                cs.Color = Color3.fromRGB(120,220,120)
                cs.Transparency = 0.15
            end

            card.MouseEnter:Connect(function()
                TS:Create(card,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,30,34)}):Play()
            end)
            card.MouseLeave:Connect(function()
                local ent = S.avatarChanger[cat.name]
                local selected = ent and tonumber(ent.savedId) == id
                TS:Create(card,TweenInfo.new(0.1),{BackgroundColor3=selected and Color3.fromRGB(20,36,20) or Color3.fromRGB(16,16,18)}):Play()
                cs.Color = selected and Color3.fromRGB(120,220,120) or Color3.fromRGB(70,70,75)
                cs.Transparency = selected and 0.15 or 0.55
            end)

            card.Activated:Connect(function()
                local ent = S.avatarChanger[cat.name]
                if not ent then
                    ent = {enabled=false,savedId=nil,savedName=""}
                    S.avatarChanger[cat.name] = ent
                end
                if ent.enabled and ent.savedId and ent.savedName ~= "" then
                    avRemove(cat,ent.savedName)
                end
                ent.savedId = id
                ent.savedName = tostring(item.Name or "Asset")
                if ent.enabled then
                    local capturedGen = AV.gen
                    task.spawn(function()
                        if capturedGen ~= AV.gen or not ent.enabled or not ent.savedId then return end
                        local applied = avEquip(cat,id,ent.savedName,capturedGen)
                        -- Keep the common path instant. Only retry Hair/Hats
                        -- once/twice when the accessory needs another frame
                        -- to attach; this avoids the old 4-attempt stall.
                        if not applied and (cat.name == "Hair" or cat.name == "Hats") then
                            for retry = 1, 2 do
                                task.wait(0.18 * retry)
                                if capturedGen ~= AV.gen or not ent.enabled or not ent.savedId then break end
                                applied = avEquip(cat,id,ent.savedName,capturedGen)
                                if applied then break end
                            end
                        end
                        avRefresh(cat.name)
                    end)
                end
                avRefresh(cat.name)
                refreshFavorites()
                pcall(F.saveConfig)
                avClosePicker()
            end)
            return true
        end

        local function load(keyword)
            clearCards()
            refreshFavorites()
            page = nil
            loadingMore = false
            order = 0
            activeSearchQuery = tostring(keyword or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
            searchGeneration += 1
            local thisSearch = searchGeneration
            local query = activeSearchQuery
            local found = 0
            local scannedPages = 0
            status.Text = query == "" and "Loading catalog..." or ("Searching prefix: " .. query)

            task.spawn(function()
                local ok, pages = pcall(function()
                    -- Keep the constructor/property setup compatible with the
                    -- normal Roblox AvatarEditorService catalog flow.
                    local params = CatalogSearchParams.new()
                    params.AssetTypes = {cat.type}
                    params.Limit = 30
                    params.IncludeOffSale = true
                    -- Do NOT assign nil to SearchKeyword. Some executor/runtime
                    -- builds reject a nil write and the picker then stays empty.
                    if query ~= "" then
                        params.SearchKeyword = query
                    end
                    local searchAsync = aes.SearchCatalogAsync
                    if type(searchAsync) == "function" then
                        return aes:SearchCatalogAsync(params)
                    end
                    return aes:SearchCatalog(params)
                end)
                if not ok or not pages then
                    if thisSearch == searchGeneration and AV.picker == sg then
                        status.Text = "Error loading catalog."
                    end
                    return
                end

                page = pages
                local seen = {}

                local function scanCurrentPage()
                    scannedPages += 1
                    local current = page:GetCurrentPage()
                    for _, item in ipairs(current) do
                        if thisSearch ~= searchGeneration or AV.picker ~= sg then
                            return false
                        end
                        local id = tonumber(item.Id)
                        if id and not seen[id] and startsWithQuery(item.Name, query) then
                            seen[id] = true
                            if addCard(item, query) then
                                found += 1
                            end
                        end
                    end
                    return true
                end

                -- Empty search: show the first page immediately and let the
                -- existing scrolling/pagination logic load more.
                if query == "" then
                    if not scanCurrentPage() then return end
                    status.Text = found > 0
                        and string.format("%d items loaded • scroll for more", found)
                        or "No results."
                    return
                end

                -- Prefix search: Roblox does the broad catalog query, then we
                -- enforce true STARTS-WITH matching on the returned items.
                -- Scan several pages incrementally so a single initial letter
                -- can find more matches without freezing the GUI indefinitely.
                local maxPages = SEARCH_MAX_AUTO_PAGES
                while scannedPages < maxPages do
                    if not scanCurrentPage() then return end
                    if thisSearch ~= searchGeneration or AV.picker ~= sg then return end
                    status.Text = string.format("Found %d items starting with \"%s\" • page %d", found, query, scannedPages)
                    if page.IsFinished then break end
                    local advanced = pcall(function()
                        page:AdvanceToNextPageAsync()
                    end)
                    if not advanced then break end
                    task.wait()
                end

                if thisSearch == searchGeneration and AV.picker == sg then
                    if found == 0 then
                        status.Text = "No items starting with \"" .. query .. "\"."
                    else
                        status.Text = string.format("%d items starting with \"%s\"", found, query)
                    end
                end
            end)
        end

        scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if loadingMore or activeSearchQuery ~= "" or not page or page.IsFinished then return end
            if scroll.CanvasPosition.Y + scroll.AbsoluteSize.Y < scroll.CanvasSize.Y.Offset - 90 then return end
            loadingMore = true
            local thisSearch = searchGeneration
            task.spawn(function()
                local ok = pcall(function() page:AdvanceToNextPageAsync() end)
                if ok and thisSearch == searchGeneration and AV.picker == sg then
                    local added = 0
                    for _, item in ipairs(page:GetCurrentPage()) do
                        local id = tonumber(item.Id)
                        if id then
                            local before = order
                            if addCard(item, "") and order > before then added += 1 end
                        end
                    end
                    status.Text = string.format("%d items loaded", order)
                end
                loadingMore = false
            end)
        end)

        local debounce = nil
        search:GetPropertyChangedSignal("Text"):Connect(function()
            if debounce then pcall(task.cancel,debounce) end
            debounce = task.delay(0.12,function()
                if AV.picker == sg then
                    load(search.Text)
                end
            end)
        end)

        backdrop.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                avClosePicker()
            end
        end)
        refreshFavorites()
        load("")
    end

    -- ================================================================
    -- AVATAR CHANGER UI
    -- ================================================================
    section(pageVIEW,"Avatar")
    local avMain = mkRow(pageVIEW,40)
    mkLabel(avMain,"Avatar Changer")

    local avHint = Instance.new("TextLabel")
    avHint.Size = UDim2.new(0,108,0,18)
    avHint.Position = UDim2.new(1,-150,0.5,-9)
    avHint.BackgroundTransparency = 1
    avHint.Text = "CUSTOM AVATAR"
    avHint.TextColor3 = COLORS.textDim
    avHint.Font = Enum.Font.GothamSemibold
    avHint.TextSize = 8
    avHint.TextXAlignment = Enum.TextXAlignment.Right
    avHint.Parent = avMain

    local avArrow = Instance.new("TextButton")
    avArrow.Size = UDim2.new(0,28,0,24)
    avArrow.Position = UDim2.new(1,-38,0.5,-12)
    avArrow.BackgroundColor3 = Color3.fromRGB(18,18,20)
    avArrow.BorderSizePixel = 0
    avArrow.Text = "▼"
    avArrow.TextColor3 = COLORS.white
    avArrow.Font = Enum.Font.GothamBold
    avArrow.TextSize = 13
    avArrow.AutoButtonColor = false
    avArrow.ZIndex = 8
    avArrow.Parent = avMain
    corner(avArrow,7)
    stroke(avArrow,COLORS.stroke,1,0.6)

    local avHolder = Instance.new("Frame")
    avHolder.Name = "VyxroAvatarChangerHolder"
    avHolder.BackgroundTransparency = 1
    avHolder.BorderSizePixel = 0
    avHolder.Size = UDim2.new(1,-4,0,0)
    avHolder.AutomaticSize = Enum.AutomaticSize.Y
    avHolder.Visible = false
    avHolder.LayoutOrder = avMain.LayoutOrder + 1
    avHolder.Parent = pageVIEW

    local avLayout = Instance.new("UIListLayout")
    avLayout.Padding = UDim.new(0,4)
    avLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    avLayout.Parent = avHolder

    local avOpen = false
    local function setAvatarExpanded(open)
        avOpen = open == true
        avHolder.Visible = avOpen
        avArrow.Text = avOpen and "▲" or "▼"
        task.defer(function()
            if _G._VersincClampCanvas then pcall(function() _G._VersincClampCanvas(pageVIEW) end) end
        end)
    end

    for _,cat in ipairs(AV.cats) do
        local row = mkRow(avHolder,38)
        local catLabel = mkLabel(row,cat.name)
        catLabel.Size = UDim2.new(0.34,0,1,0)

        local nm = Instance.new("TextLabel")
        nm.Name = "SelectedAsset"
        nm.Size = UDim2.new(0.25,0,0,22)
        nm.Position = UDim2.new(0.35,0,0.5,-11)
        nm.BackgroundColor3 = Color3.fromRGB(18,18,20)
        nm.BorderSizePixel = 0
        nm.Text = "None"
        nm.TextColor3 = COLORS.textDim
        nm.Font = Enum.Font.GothamSemibold
        nm.TextSize = 8
        nm.TextTruncate = Enum.TextTruncate.AtEnd
        nm.TextXAlignment = Enum.TextXAlignment.Center
        nm.ZIndex = 7
        nm.Parent = row
        corner(nm,7)
        stroke(nm,COLORS.strokeSoft,1,0.5)

        local pill,dot = mkPill(row,116)
        pill.Position = UDim2.new(0.63,0,0.5,-11)
        pill.Size = UDim2.new(0,48,0,22)
        local click = Instance.new("TextButton")
        click.Name = "ToggleClick"
        click.Size = UDim2.fromScale(1,1)
        click.BackgroundTransparency = 1
        click.BorderSizePixel = 0
        click.Text = ""
        click.AutoButtonColor = false
        click.ZIndex = 10
        click.Parent = pill

        local pick = Instance.new("TextButton")
        pick.Name = "PickButton"
        pick.Size = UDim2.new(0,52,0,24)
        pick.Position = UDim2.new(1,-58,0.5,-12)
        pick.BackgroundColor3 = Color3.fromRGB(238,238,238)
        pick.BorderSizePixel = 0
        pick.Text = "PICK"
        pick.TextColor3 = Color3.fromRGB(0,0,0)
        pick.Font = Enum.Font.GothamBold
        pick.TextSize = 9
        pick.AutoButtonColor = false
        pick.ZIndex = 9
        pick.Parent = row
        corner(pick,8)

        AV.visual[cat.name] = {pill=pill,dot=dot,name=nm}

        click.Activated:Connect(function()
            if S._anyKeyListening then return end
            local e = S.avatarChanger[cat.name]
            if not e then
                e={enabled=false,savedId=nil,savedName=""}
                S.avatarChanger[cat.name]=e
            end
            e.enabled = not e.enabled
            if e.enabled and e.savedId then
                local capturedGen = AV.gen
                task.spawn(function()
                    local applied = false
                    for attempt = 1, 4 do
                        if capturedGen ~= AV.gen or not e.enabled or not e.savedId then break end
                        applied = avEquip(cat,e.savedId,e.savedName,capturedGen)
                        if applied then break end
                        task.wait(0.25 * attempt)
                    end
                    avRefresh(cat.name)
                end)
            elseif not e.enabled then
                avRemove(cat,e.savedName)
            end
            avRefresh(cat.name)
            pcall(F.saveConfig)
        end)
        pick.Activated:Connect(function() avOpenPicker(cat) end)
        avRefresh(cat.name)
    end

    -- ================================================================
    -- AVATAR CHANGER UI POLISH V6 (VISUAL ONLY)
    -- Clean premium card design: no stray lines, no decorative bars,
    -- no extra shapes. Logic/callbacks remain untouched.
    -- ================================================================
    do
        local accent = S.themeColor or COLORS.accent or Color3.fromRGB(27,96,178)
        local function setGradient(obj, top, bottom, rotation)
            if not obj then return end
            local g = obj:FindFirstChild("VxyroAvatarGradient")
            if not g then
                g = Instance.new("UIGradient")
                g.Name = "VxyroAvatarGradient"
                g.Parent = obj
            end
            g.Color = ColorSequence.new(top, bottom)
            g.Rotation = rotation or 90
        end
        local function clean(obj)
            if not obj then return end
            for _,d in ipairs(obj:GetDescendants()) do
                if d:IsA("UIStroke") then d:Destroy() end
                if d.Name == "AvatarAccent" or d.Name == "ToggleShine" or d.Name == "RowStroke" or d.Name == "ToggleStroke" then
                    pcall(function() d:Destroy() end)
                end
            end
        end
        local function styleButton(btn, bg, hover, textColor, size)
            if not btn then return end
            btn.AutoButtonColor = false
            btn.BackgroundColor3 = bg
            btn.BorderSizePixel = 0
            btn.TextColor3 = textColor or Color3.fromRGB(242,246,252)
            btn.TextSize = size or 9
            btn.TextScaled = false
            btn.TextTruncate = Enum.TextTruncate.AtEnd
            btn.Font = Enum.Font.GothamBold
            btn.TextStrokeTransparency = 1
            local g = btn:FindFirstChild("VxyroAvatarGradient")
            if g then g.Color = ColorSequence.new(bg:Lerp(Color3.new(1,1,1),0.06), bg) end
            btn.MouseEnter:Connect(function()
                if btn.Parent then
                    btn.BackgroundColor3 = hover
                end
            end)
            btn.MouseLeave:Connect(function()
                if btn.Parent then
                    btn.BackgroundColor3 = bg
                end
            end)
        end

        clean(avMain)
        avMain.BackgroundColor3 = Color3.fromRGB(7,13,23)
        avMain.BackgroundTransparency = 0
        avMain.BorderSizePixel = 0
        corner(avMain,10)
        setGradient(avMain, Color3.fromRGB(13,24,42), Color3.fromRGB(5,10,18), 90)

        clean(avArrow)
        avArrow.BackgroundColor3 = Color3.fromRGB(12,26,45)
        avArrow.BorderSizePixel = 0
        avArrow.TextColor3 = Color3.fromRGB(224,235,247)
        avArrow.TextSize = 12
        avArrow.TextStrokeTransparency = 1
        corner(avArrow,8)
        setGradient(avArrow, Color3.fromRGB(18,38,64), Color3.fromRGB(8,18,31), 90)

        for _,obj in ipairs(avHolder:GetChildren()) do
            if obj:IsA("Frame") and obj ~= avHolder then
                clean(obj)
                obj.BackgroundColor3 = Color3.fromRGB(7,15,27)
                obj.BackgroundTransparency = 0
                obj.BorderSizePixel = 0
                corner(obj,9)
                setGradient(obj, Color3.fromRGB(12,25,43), Color3.fromRGB(6,12,21), 90)

                local nm = obj:FindFirstChild("SelectedAsset")
                if nm then
                    clean(nm)
                    nm.BackgroundColor3 = Color3.fromRGB(5,10,18)
                    nm.BackgroundTransparency = 0
                    nm.BorderSizePixel = 0
                    nm.TextColor3 = Color3.fromRGB(164,180,200)
                    nm.TextSize = 8
                    nm.TextTruncate = Enum.TextTruncate.AtEnd
                    nm.TextStrokeTransparency = 1
                    corner(nm,7)
                    setGradient(nm, Color3.fromRGB(8,17,30), Color3.fromRGB(4,9,16), 90)
                end

                local click = obj:FindFirstChild("ToggleClick", true)
                local pill = click and click.Parent
                if pill and pill:IsA("Frame") then
                    clean(pill)
                    pill.BorderSizePixel = 0
                    pill.BackgroundColor3 = Color3.fromRGB(5,10,18)
                    pill.BackgroundTransparency = 0
                    corner(pill,7)
                    local dot = pill:FindFirstChildWhichIsA("Frame")
                    if dot then
                        dot.BackgroundColor3 = Color3.fromRGB(110,126,145)
                        dot.BorderSizePixel = 0
                    end
                    setGradient(pill, Color3.fromRGB(9,20,34), Color3.fromRGB(4,8,15), 90)
                end

                local pick = obj:FindFirstChild("PickButton")
                if pick then
                    clean(pick)
                    corner(pick,7)
                    styleButton(pick, Color3.fromRGB(218,228,240), Color3.fromRGB(235,242,250), Color3.fromRGB(5,10,18), 9)
                    setGradient(pick, Color3.fromRGB(244,248,252), Color3.fromRGB(202,215,231), 90)
                end

                local lbl = obj:FindFirstChildOfClass("TextLabel")
                if lbl and lbl.Name ~= "SelectedAsset" then
                    lbl.TextColor3 = Color3.fromRGB(236,241,247)
                    lbl.TextSize = 10
                    lbl.TextTruncate = Enum.TextTruncate.AtEnd
                    lbl.TextStrokeTransparency = 1
                    lbl.Font = Enum.Font.GothamSemibold
                end
            end
        end

        -- Keep this tiny theme hook for existing callbacks/config refresh.
        _G._VxyroAvatarApplyAccent = function(col)
            accent = col or accent
            pcall(function()
                avArrow.TextColor3 = Color3.fromRGB(224,235,247)
            end)
        end
    end

    -- Final visual cleanup: only remove accidental lines/decorations.
    pcall(function()
        for _,root in ipairs({avMain,avArrow,avHolder}) do
            if root then
                root.BorderSizePixel = 0
                for _,obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("UIStroke") then obj:Destroy() end
                    if obj.Name == "AvatarAccent" or obj.Name == "ToggleShine" or obj.Name == "RowStroke" or obj.Name == "ToggleStroke" then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end)

avArrow.Activated:Connect(function() setAvatarExpanded(not avOpen) end)

-- ================================================================
    -- ================================================================
    -- AVA PRESET - FULL BODY / SINGLE CARD PER PRESET
    -- Uses HumanoidDescription so accessories + clothes are applied as
    -- one complete avatar appearance while preserving the selected body
    -- scales/body type from the current avatar.
    -- ================================================================
    do
        local AVP = {
            PURPLE = {
                hats = "1744060292,439945661,1125510,1029025",
                hair = "",
                accessories = {1744060292,439945661,1125510,1029025,11748356,8465506143,11444217173},
                shirt = 7424637509,
                pants = 7689651773, headless = true, korblox = "Right",
            },
            BLUE = {
                hats = "74891470",
                hair = "16630147,6346833550,6594911228,6594919952,6823338112,7097747842",
                accessories = {74891470,16630147,6346833550,6594911228,6594919952,6823338112,7097747842},
                shirt = 18423061209,
                pants = 18423154566, headless = true, korblox = "Right",
            },
            RED = {
                hats = "215718515,439945661",
                hair = "7183785281",
                accessories = {215718515,439945661,7183785281},
                shirt = 15998365201,
                pants = 7689651773, headless = true, korblox = "Right",
            },
            BLACK = {
                hats = "10159600649,439946249,17798262442,92482095662016",
                hair = "139101716417676",
                accessories = {10159600649,439946249,17798262442,92482095662016,139101716417676,12490213797},
                shirt = 18766106994,
                pants = 13925390578, headless = true, korblox = "Right",
            },
            GREEN = {
                hats = "553970961,1744060292",
                hair = "93268856876777",
                accessories = {553970961,1744060292,93268856876777},
                shirt = 9478068776,
                pants = 6348682339, headless = true, korblox = "Right",
            },
            WHITE = {
                hats = "74891470,215718515,439945661,1016143686,1744060292,10159600649,89012651581593,88365652378427",
                hair = "126447390530523",
                accessories = {74891470,215718515,439945661,1016143686,1744060292,10159600649,89012651581593,126447390530523},
                shirt = 88032876921227,
                pants = 108259950755140, headless = true, korblox = "Right",
            },
        }
        local AVP_ORDER = {"PURPLE","BLUE","RED","BLACK","GREEN","WHITE"}
        local AVP_COLORS = {
            PURPLE=Color3.fromRGB(180,90,255), BLUE=Color3.fromRGB(80,150,255),
            RED=Color3.fromRGB(255,85,90), BLACK=Color3.fromRGB(135,135,145),
            GREEN=Color3.fromRGB(80,220,130), WHITE=Color3.fromRGB(235,235,245),
        }

        local active = S.avaPresetEnabled == true
        local selected = (AVP[S.avaPresetName] and S.avaPresetName) or "PURPLE"
        local applying = false
        local applySerial = 0
        local viewportCache = {}
        local presetGuardConns = {}
        local presetGuardChar = nil
        local presetGuardToken = 0

        local function markPresetObjects(char)
            if not char then return end
            -- Mark both the wearable root and its descendants. Nuke checks
            -- ancestor markers, so this stays cheap and race-resistant.
            for _,obj in ipairs(char:GetChildren()) do
                if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                    pcall(function() obj:SetAttribute("_VxyroAvaPreset", true) end)
                end
            end
            for _,obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local parent=obj
                    while parent and parent ~= char do
                        local tagged=false
                        pcall(function() tagged = parent:GetAttribute("_VxyroAvaPreset") == true end)
                        if tagged then
                            pcall(function() obj:SetAttribute("_VxyroAvaPreset", true) end)
                            break
                        end
                        parent=parent.Parent
                    end
                end
            end
        end

        local MARKET = game:GetService("MarketplaceService")
        local ACCESSORY_SLOTS = {
            [8]="HatAccessory", [41]="HairAccessory", [42]="FaceAccessory", [43]="NeckAccessory",
            [44]="ShouldersAccessory", [45]="FrontAccessory", [46]="BackAccessory", [47]="WaistAccessory",
            [64]="ShirtAccessory", [65]="PantsAccessory", [66]="JacketAccessory", [67]="SweaterAccessory",
            [68]="ShortsAccessory", [69]="TShirtAccessory", [70]="DressSkirtAccessory",
        }

        local function appendId(desc, property, id)
            if not desc or not property or not id then return end
            pcall(function()
                local old = tostring(desc[property] or "")
                local sid = tostring(id)
                if old == "" then desc[property] = sid
                else
                    local exists = false
                    for n in old:gmatch("%d+") do if n == sid then exists=true; break end end
                    if not exists then desc[property] = old .. "," .. sid end
                end
            end)
        end

        local function addExtraAccessory(desc, id, skipSet)
            if not id or skipSet[id] then return end
            local ok, info = pcall(function()
                return MARKET:GetProductInfo(tonumber(id), Enum.InfoType.Asset)
            end)
            if not ok or type(info) ~= "table" then return end
            local slot = ACCESSORY_SLOTS[tonumber(info.AssetTypeId)]
            if slot then appendId(desc, slot, id) end
        end

        local function buildDescription(preset)
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local desc

            if hum then
                pcall(function()
                    local current = hum:GetAppliedDescription()
                    if current then
                        desc = current:Clone()
                        current:Destroy()
                    end
                end)
            end
            if not desc then
                desc = Instance.new("HumanoidDescription")
                pcall(function()
                    local current = Players:GetHumanoidDescriptionFromUserIdAsync(LP.UserId)
                    if current then
                        desc:Destroy()
                        desc = current:Clone()
                        current:Destroy()
                    end
                end)
            end

            -- Keep the current body-part assets/scales/colors (important for
            -- WOMAN/CLASSIC/body-type choices) and replace only the preset look.
            pcall(function() desc.HatAccessory="" end)
            pcall(function() desc.HairAccessory="" end)
            pcall(function() desc.FaceAccessory="" end)
            pcall(function() desc.NeckAccessory="" end)
            pcall(function() desc.ShouldersAccessory="" end)
            pcall(function() desc.FrontAccessory="" end)
            pcall(function() desc.BackAccessory="" end)
            pcall(function() desc.WaistAccessory="" end)
            pcall(function() desc.Shirt=0 end)
            pcall(function() desc.Pants=0 end)
            pcall(function() desc.GraphicTShirt=0 end)

            -- The source preset defines several rigid accessories plus
            -- clothing. Hats/Hair are assigned directly, while the remaining
            -- accessory IDs are classified through MarketplaceService just
            -- like the source build-set logic.
            pcall(function() desc.HatAccessory = preset.hats or "" end)
            pcall(function() desc.HairAccessory = preset.hair or "" end)
            pcall(function() desc.Shirt = tonumber(preset.shirt) or 0 end)
            pcall(function() desc.Pants = tonumber(preset.pants) or 0 end)

            local known = {}
            for n in tostring(preset.hats or ""):gmatch("%d+") do known[tonumber(n)] = true end
            for n in tostring(preset.hair or ""):gmatch("%d+") do known[tonumber(n)] = true end
            for _,id in ipairs(preset.accessories or {}) do
                addExtraAccessory(desc, tonumber(id), known)
            end
            return desc
        end

        local function _presetIdSet(preset)
            local set = {}
            local function addCsv(value)
                for n in tostring(value or ""):gmatch("%d+") do
                    set[tonumber(n)] = true
                end
            end
            addCsv(preset and preset.hats)
            addCsv(preset and preset.hair)
            for _,id in ipairs((preset and preset.accessories) or {}) do
                local n=tonumber(id)
                if n then set[n]=true end
            end
            return set
        end

        local function _presetHardApply(preset, char, hum, serial)
            if not preset or not char or not hum or serial ~= applySerial then return false end

            -- Hard fallback: rebuild only the wearable layer locally when the
            -- game's HumanoidDescription path silently fails. Body parts/scales
            -- remain untouched. This is based on the Avatar Changer path that
            -- is already present in this file, so it works in the same executor.
            pcall(function()
                for _,obj in ipairs(char:GetChildren()) do
                    if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                        obj:Destroy()
                    end
                end
            end)

            if serial ~= applySerial or not char.Parent then return false end

            -- Clothing
            if preset.shirt and tonumber(preset.shirt) then
                pcall(function()
                    local shirt=Instance.new("Shirt")
                    shirt.Name="AvaPresetShirt"
                    shirt.ShirtTemplate="rbxassetid://"..tostring(tonumber(preset.shirt))
                    shirt:SetAttribute("_VxyroAvaPreset",true)
                    shirt.Parent=char
                end)
            end
            if preset.pants and tonumber(preset.pants) then
                pcall(function()
                    local pants=Instance.new("Pants")
                    pants.Name="AvaPresetPants"
                    pants.PantsTemplate="rbxassetid://"..tostring(tonumber(preset.pants))
                    pants:SetAttribute("_VxyroAvaPreset",true)
                    pants.Parent=char
                end)
            end

            -- Accessories
            local ids=_presetIdSet(preset)
            for id in pairs(ids) do
                if serial ~= applySerial or not char.Parent then return false end
                local ok,got=pcall(function() return game:GetObjects("rbxassetid://"..tostring(id)) end)
                if ok and got and got[1] then
                    local obj=normalizeAsset(got[1])
                    if obj and obj:IsA("Accessory") then
                        local handle=obj:FindFirstChild("Handle")
                        if handle then
                            obj.Name="AvaPresetAccessory_"..tostring(id)
                            pcall(function() obj:SetAttribute("_VxyroAvaPreset",true) end)
                            obj.Parent=nil
                            local addOK=pcall(function() hum:AddAccessory(obj) end)
                            if not (addOK and obj.Parent==char and (handle:FindFirstChild("AccessoryWeld") or handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("WeldConstraint"))) then
                                pcall(function()
                                    obj.Parent=char
                                    handle.CanCollide=false; handle.CanTouch=false; handle.CanQuery=false; handle.Massless=true
                                    for _,j in ipairs(handle:GetChildren()) do
                                        if j:IsA("Weld") or j:IsA("ManualWeld") or j:IsA("WeldConstraint") or j:IsA("AccessoryWeld") then j:Destroy() end
                                    end
                                    local accAttachment=handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("HatAttachment") or handle:FindFirstChildOfClass("Attachment")
                                    local targetPart=char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
                                    local targetAttachment=nil
                                    if accAttachment then
                                        for _,body in ipairs(char:GetDescendants()) do
                                            if body:IsA("BasePart") then
                                                local a2=body:FindFirstChild(accAttachment.Name)
                                                if a2 and a2:IsA("Attachment") then targetPart=body; targetAttachment=a2; break end
                                            end
                                        end
                                    end
                                    if targetPart then
                                        if targetAttachment and accAttachment then
                                            handle.CFrame=targetAttachment.WorldCFrame*accAttachment.CFrame:Inverse()
                                        else
                                            handle.CFrame=targetPart.CFrame*CFrame.new(0,1.5,0)
                                        end
                                        local wc=Instance.new("WeldConstraint")
                                        wc.Name="AvaPresetManualWeld"
                                        wc.Part0=handle; wc.Part1=targetPart; wc.Parent=handle
                                    end
                                end)
                            end
                        end
                    end
                end
                task.wait(0.025)
            end
            markPresetObjects(char)
            return true
        end

        local function _presetDescriptionMatches(hum, wanted)
            if not hum or not wanted then return false end
            local ok,result=pcall(function()
                local got=hum:GetAppliedDescription()
                if not got then return false end
                local function setCsv(value)
                    local s={}
                    for n in tostring(value or ""):gmatch("%d+") do s[tonumber(n)]=true end
                    return s
                end
                local function sameCsv(a,b)
                    local sa,sb=setCsv(a),setCsv(b)
                    for id in pairs(sa) do if not sb[id] then return false end end
                    for id in pairs(sb) do if not sa[id] then return false end end
                    return true
                end
                local sameShirt=tonumber(got.Shirt)==tonumber(wanted.Shirt)
                local samePants=tonumber(got.Pants)==tonumber(wanted.Pants)
                local sameHat=sameCsv(got.HatAccessory,wanted.HatAccessory)
                local sameHair=sameCsv(got.HairAccessory,wanted.HairAccessory)
                got:Destroy()
                return sameShirt and samePants and sameHat and sameHair
            end)
            return ok and result==true
        end

        local function bindPresetGuard(char)
            presetGuardToken += 1
            local token = presetGuardToken
            for _, c in ipairs(presetGuardConns) do pcall(function() c:Disconnect() end) end
            table.clear(presetGuardConns)
            presetGuardChar = char
            if not char then return end
            -- Mark newly-created preset wearables as soon as they enter the character.
            local childAddedConn = char.ChildAdded:Connect(function(obj)
                if not active or token ~= presetGuardToken or char ~= LP.Character then return end
                if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                    pcall(function() obj:SetAttribute("_VxyroAvaPreset", true) end)
                    task.defer(function() pcall(function() markPresetObjects(char) end) end)
                end
            end)
            -- If another system removes one of the preset's wearable roots, restore
            -- the currently selected preset after the removal burst settles.
            local childRemovedConn = char.ChildRemoved:Connect(function(obj)
                if not active or token ~= presetGuardToken or char ~= LP.Character then return end
                if not (obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic")) then return end
                local myToken = token
                task.delay(0.45, function()
                    if not active or myToken ~= presetGuardToken or char ~= LP.Character then return end
                    if applying then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum or not char.Parent then return end
                    local preset = AVP[selected]
                    if not preset then return end
                    local desc = buildDescription(preset)
                    local matched = false
                    if desc then
                        matched = _presetDescriptionMatches(hum, desc)
                        pcall(function() desc:Destroy() end)
                    end
                    if not matched then
                        task.spawn(function() applyPreset(selected) end)
                    else
                        pcall(function() markPresetObjects(char) end)
                    end
                end)
            end)
            table.insert(presetGuardConns, childAddedConn)
            table.insert(presetGuardConns, childRemovedConn)
        end

        local function applyPreset(name)
            if not active then return false end
            local preset = AVP[name]
            if not preset then return false end
            -- A new preset selection supersedes any in-flight apply. The older
            -- worker sees a newer serial and exits at every destructive/apply step.
            applySerial += 1
            local serial = applySerial
            applying = true
            local ok = false
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            local workOK, workResult = pcall(function()
                if not hum or not avWaitChar(char, 8) then return false end
                if not active or serial ~= applySerial or char ~= LP.Character or not char.Parent then return false end

                local desc = buildDescription(preset)
                if desc and active and serial == applySerial then
                    -- Main path. Try Reset first, then normal ApplyDescription.
                    local applied = pcall(function() hum:ApplyDescriptionReset(desc) end)
                    if not applied then
                        applied = pcall(function() hum:ApplyDescription(desc) end)
                    end
                    pcall(function() desc:Destroy() end)

                    if applied then
                        if not active or serial ~= applySerial or char ~= LP.Character or not char.Parent then return false end
                        -- Give the character wearables their protection marker immediately.
                        -- This also closes the small window between ApplyDescriptionReset and verification.
                        for _ = 1, 4 do
                            if serial ~= applySerial or not char.Parent then break end
                            pcall(function() markPresetObjects(char) end)
                            task.wait(0.08)
                        end
                        if not active or serial ~= applySerial or char ~= LP.Character then return false end
                        task.wait(0.25)
                        if not active or serial ~= applySerial or char ~= LP.Character or not char.Parent then return false end
                        -- Verify the live Humanoid actually received this preset.
                        local verifyDesc = buildDescription(preset)
                        local matched = _presetDescriptionMatches(hum, verifyDesc)
                        pcall(function() verifyDesc:Destroy() end)
                        if matched then
                            ok=true
                        end
                    end
                end

                -- Reliable fallback when ApplyDescription is rejected, ignored,
                -- or overwritten by the experience.
                if not ok and active and serial == applySerial and char == LP.Character and char.Parent then
                    ok=_presetHardApply(preset,char,hum,serial)
                    task.wait(0.15)
                end

                if not active or serial ~= applySerial or char ~= LP.Character or not char.Parent then return false end

                local preset2 = AVP[name]
                if preset2 and preset2.headless then
                    pcall(function() if K7 and K7.applyHeadless then K7.applyHeadless(char, true) end end)
                end
                if preset2 and preset2.korblox == "Right" then
                    pcall(function()
                        if K7 and K7.setKorbloxSide then K7.setKorbloxSide(1) end
                        if K7 and K7.applyKorblox then K7.applyKorblox(char, true) end
                    end)
                end
                markPresetObjects(char)
                return ok
            end)

            if workOK then ok=workResult==true else ok=false end
            -- Only the newest apply worker may clear the busy flag.
            if serial == applySerial then
                applying = false
                if not ok then
                    warn("[Vyxro Duel] Ava Preset apply failed:", tostring(name))
                end
            end
            return ok
        end

        local function lazyViewport(name, viewport)
            if viewportCache[name] then return end
            viewportCache[name] = true
            task.spawn(function()
                local preset = AVP[name]
                local desc = buildDescription(preset)
                if not desc then return end
                local model
                pcall(function()
                    if Players.CreateHumanoidModelFromDescriptionAsync then
                        model = Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
                    end
                end)
                if not model then
                    pcall(function()
                        model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
                    end)
                end
                pcall(function() desc:Destroy() end)
                if not model or not viewport.Parent then return end
                model.Name = name .. "Preview"
                model.Parent = viewport
                local world = Instance.new("WorldModel")
                world.Name = "World"
                world.Parent = viewport
                model.Parent = world

                local camera = Instance.new("Camera")
                camera.Parent = viewport
                viewport.CurrentCamera = camera
                local root = model:FindFirstChild("HumanoidRootPart")
                if root then
                    model:PivotTo(CFrame.new(0,0,0))
                    local cf,size = model:GetBoundingBox()
                    local maxSize = math.max(size.X,size.Y,size.Z)
                    camera.CFrame = CFrame.lookAt(Vector3.new(0, math.max(1.0,size.Y*0.40), maxSize*2.0), Vector3.new(0, math.max(1.0,size.Y*0.42), 0))
                else
                    camera.CFrame = CFrame.new(Vector3.new(0,2,8), Vector3.new(0,2,0))
                end
            end)
        end

        local sg=Instance.new("ScreenGui")
        sg.Name="VxyroAvaPreset"
        sg.ResetOnSpawn=false
        sg.IgnoreGuiInset=true
        sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder=10020
        sg.Enabled=false
        local parentGui = nil
        pcall(function()
            if type(gethui)=="function" then parentGui=gethui() end
        end)
        if typeof(parentGui) ~= "Instance" then parentGui=LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui") end
        sg.Parent=parentGui

        local isMobile=UIS.TouchEnabled and not UIS.KeyboardEnabled
        local W=isMobile and 292 or 336
        local H=isMobile and 342 or 365
        local panel=Instance.new("Frame",sg)
        panel.AnchorPoint=Vector2.new(.5,.5)
        panel.Position=UDim2.fromScale(.5,.5)
        panel.Size=UDim2.fromOffset(W,H)
        panel.BackgroundColor3=Color3.fromRGB(9,9,12)
        panel.BorderSizePixel=0
        corner(panel,13)
        stroke(panel,Color3.fromRGB(65,65,75),1,.25)

        local title=Instance.new("TextLabel",panel)
        title.BackgroundTransparency=1
        title.Position=UDim2.fromOffset(12,8)
        title.Size=UDim2.new(1,-45,0,20)
        title.Text="AVA PRESET"
        title.TextColor3=COLORS.white
        title.Font=Enum.Font.GothamBlack
        title.TextSize=14
        title.TextXAlignment=Enum.TextXAlignment.Left

        local selectedLbl=Instance.new("TextLabel",panel)
        selectedLbl.BackgroundTransparency=1
        selectedLbl.Position=UDim2.fromOffset(12,27)
        selectedLbl.Size=UDim2.new(1,-45,0,10)
        selectedLbl.TextColor3=COLORS.textDim
        selectedLbl.Font=Enum.Font.GothamBold
        selectedLbl.TextSize=7
        selectedLbl.TextXAlignment=Enum.TextXAlignment.Left

        local close=Instance.new("TextButton",panel)
        close.Size=UDim2.fromOffset(24,24)
        close.Position=UDim2.new(1,-34,0,8)
        close.BackgroundColor3=Color3.fromRGB(24,24,28)
        close.BorderSizePixel=0
        close.Text="×"
        close.TextColor3=COLORS.white
        close.Font=Enum.Font.GothamBold
        close.TextSize=16
        close.AutoButtonColor=false
        corner(close,7)

        local scroll=Instance.new("ScrollingFrame",panel)
        scroll.Position=UDim2.fromOffset(9,48)
        scroll.Size=UDim2.new(1,-18,1,-57)
        scroll.BackgroundTransparency=1
        scroll.BorderSizePixel=0
        scroll.ScrollBarThickness=2
        scroll.CanvasSize=UDim2.fromOffset(0,0)

        local cols=isMobile and 2 or 3
        local gap=5
        local cellW=math.floor((W-18-gap*(cols-1))/cols)
        local cellH=isMobile and 118 or 120
        local grid=Instance.new("UIGridLayout",scroll)
        grid.CellSize=UDim2.fromOffset(cellW,cellH)
        grid.CellPadding=UDim2.fromOffset(gap,gap)
        grid.SortOrder=Enum.SortOrder.LayoutOrder
        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize=UDim2.fromOffset(0,grid.AbsoluteContentSize.Y+4)
        end)

        local cards={}
        local function refreshCards()
            selectedLbl.Text="SELECTED: "..selected..(active and " • ON" or " • OFF")
            for _,c in ipairs(cards) do
                local on=c.name==selected
                c.state.Text=on and "SELECTED" or "READY"
                c.button.Text=on and "SELECTED" or "USE"
                c.button.BackgroundColor3=on and AVP_COLORS[c.name] or Color3.fromRGB(232,232,237)
                c.button.TextColor3=on and Color3.new(1,1,1) or Color3.fromRGB(10,10,12)
            end
        end

        for index,name in ipairs(AVP_ORDER) do
            local card=Instance.new("Frame",scroll)
            card.LayoutOrder=index
            card.BackgroundColor3=Color3.fromRGB(16,16,21)
            card.BorderSizePixel=0
            corner(card,9)

            local bar=Instance.new("Frame",card)
            bar.Position=UDim2.fromOffset(5,5)
            bar.Size=UDim2.fromOffset(3,14)
            bar.BackgroundColor3=AVP_COLORS[name]
            bar.BorderSizePixel=0
            corner(bar,2)

            local nm=Instance.new("TextLabel",card)
            nm.BackgroundTransparency=1
            nm.Position=UDim2.fromOffset(13,4)
            nm.Size=UDim2.new(1,-17,0,15)
            nm.Text=name
            nm.TextColor3=COLORS.white
            nm.Font=Enum.Font.GothamBlack
            nm.TextSize=9
            nm.TextXAlignment=Enum.TextXAlignment.Left

            local st=Instance.new("TextLabel",card)
            st.BackgroundTransparency=1
            st.Position=UDim2.fromOffset(13,19)
            st.Size=UDim2.new(1,-17,0,9)
            st.TextColor3=COLORS.textDim
            st.Font=Enum.Font.GothamBold
            st.TextSize=6.5
            st.TextXAlignment=Enum.TextXAlignment.Left

            local view=Instance.new("ViewportFrame",card)
            view.Name="FullBodyPreview"
            view.Position=UDim2.fromOffset(5,31)
            view.Size=UDim2.new(1,-10,0,53)
            view.BackgroundColor3=Color3.fromRGB(10,10,14)
            view.BorderSizePixel=0
            view.Ambient=Color3.fromRGB(200,200,200)
            view.LightColor=Color3.fromRGB(255,255,255)
            view.LightDirection=Vector3.new(-1,-1,-1)
            corner(view,7)

            local btn=Instance.new("TextButton",card)
            btn.Position=UDim2.new(0,5,1,-23)
            btn.Size=UDim2.new(1,-10,0,18)
            btn.BorderSizePixel=0
            btn.AutoButtonColor=false
            btn.Font=Enum.Font.GothamBold
            btn.TextSize=6.5
            corner(btn,6)
            btn.Activated:Connect(function()
                if not active then return end
                selected=name
                S.avaPresetName=name
                refreshCards()
                -- Mark existing preset wearables before starting the replacement worker.
                pcall(function() markPresetObjects(LP.Character) end)
                task.spawn(function() applyPreset(name) end)
                pcall(F.saveConfig)
            end)
            table.insert(cards,{name=name,state=st,button=btn,viewport=view})
        end
        refreshCards()

        local function openPanel()
            sg.Enabled=true
            refreshCards()
            for _,c in ipairs(cards) do
                lazyViewport(c.name,c.viewport)
            end
        end
        close.Activated:Connect(function() sg.Enabled=false end)

        local openBtn=Instance.new("TextButton")
        openBtn.Text="OPEN"
        openBtn.TextColor3=COLORS.white
        openBtn.Font=Enum.Font.GothamBold
        openBtn.TextSize=9
        openBtn.AutoButtonColor=false
        openBtn.Size=UDim2.fromOffset(70,24)
        openBtn.Position=UDim2.new(1,-80,.5,-12)
        openBtn.BackgroundColor3=COLORS.row2
        openBtn.BorderSizePixel=0
        openBtn.ZIndex=6
        corner(openBtn,7)
        openBtn.Parent=mkRow(pageVIEW,34)
        mkLabel(openBtn.Parent,"Ava Preset")
        openBtn.Activated:Connect(openPanel)

        local toggle=mkToggle(pageVIEW,"Ava Preset",active,function(on)
            active=on==true
            S.avaPresetEnabled=active
            _G.__VxyroAvaPresetActive=active
            if active then
                bindPresetGuard(LP.Character)
                pcall(function() markPresetObjects(LP.Character) end)
                task.spawn(function() applyPreset(selected) end)
            else
                applySerial+=1
                applying = false
                presetGuardToken += 1
                for _, c in ipairs(presetGuardConns) do pcall(function() c:Disconnect() end) end
                table.clear(presetGuardConns)
                -- Re-enable normal Avatar Changer restoration path.
                AV.gen+=1
                task.defer(function() pcall(avApplyAll,AV.gen) end)
                -- Restore Remove Accessories watcher if it was enabled before the preset.
                if S.removeAccessoriesEnabled and F.startRemoveAccessories then
                    task.defer(function() pcall(F.startRemoveAccessories) end)
                end
            end
            refreshCards()
            pcall(F.saveConfig)
        end)
        UI.avaPresetToggle=toggle

        _G._VxyroAvaPreset={
            Open=openPanel,
            Close=function() sg.Enabled=false end,
            Toggle=function(v)
                active=v==true
                S.avaPresetEnabled=active
                _G.__VxyroAvaPresetActive=active
                if active then
                    bindPresetGuard(LP.Character)
                    pcall(function() markPresetObjects(LP.Character) end)
                    task.spawn(function() applyPreset(selected) end)
                end
                refreshCards()
            end,
            SelectSkin=function(n)
                if not AVP[n] then return false end
                -- Invalidate the previous worker before starting the new preset.
                applySerial += 1
                selected=n
                S.avaPresetName=n
                refreshCards()
                if active then
                    bindPresetGuard(LP.Character)
                    pcall(function() markPresetObjects(LP.Character) end)
                    task.spawn(function() applyPreset(selected) end)
                end
                return true
            end,
        }

        LP.CharacterAdded:Connect(function(char)
            if active then
                bindPresetGuard(char)
                pcall(function() markPresetObjects(char) end)
            end
            task.wait(1.0)
            if active and char.Parent then
                task.spawn(function() applyPreset(selected) end)
            end
        end)

        task.defer(function()
            selected=(AVP[S.avaPresetName] and S.avaPresetName) or selected
            active=S.avaPresetEnabled==true
            _G.__VxyroAvaPresetActive=active
            if active then bindPresetGuard(LP.Character) end
            refreshCards()
            if active then task.delay(.25,function() applyPreset(selected) end) end
        end)
    end

section(pageVIEW, "Music & Font")

UI.importedMusicVisual = mkToggle(pageVIEW, "Music Player", false, function(on)
    if on then
        if _G._VxyroImportedMusicOpen then
            pcall(_G._VxyroImportedMusicOpen)
        end
    else
        if _G._VxyroImportedMusicClose then
            pcall(_G._VxyroImportedMusicClose)
        end
    end
end)
_G.VxyroImportedMusicVisual = UI.importedMusicVisual
_G.VxyroMusicToggleVisual = UI.importedMusicVisual

_G.VxyroCustomFontSelected = _G.VxyroCustomFontSelected or _G.AmbitiousFontChoice or "Default"
_G.VxyroCustomFontEnabled = _G.VxyroCustomFontEnabled == true
UI.importedFontVisual = mkToggle(pageVIEW, "Custom Font", _G.VxyroCustomFontEnabled, function(on)
    _G.VxyroCustomFontEnabled = on == true
    local key = _G.VxyroCustomFontSelected or "Default"
    if _G.AmbitiousFonts and _G.AmbitiousFonts.set then
        if on then
            if key == "Default" then
                if _G.VxyroImportedOpenFontPicker then
                    pcall(_G.VxyroImportedOpenFontPicker)
                end
            else
                pcall(_G.AmbitiousFonts.set, key, true)
            end
        else
            pcall(_G.AmbitiousFonts.set, "Default", true)
        end
    end
    pcall(F.saveConfig)
end)
_G.VxyroImportedFontVisual = UI.importedFontVisual

UI.importedFontRow = mkRow(pageVIEW, 42)
mkLabel(UI.importedFontRow, "Custom Font Picker")
UI.importedFontButton = Instance.new("TextButton", UI.importedFontRow)
UI.importedFontButton.Size = UDim2.new(0, 70, 0, 26)
UI.importedFontButton.Position = UDim2.new(1, -80, 0.5, -13)
UI.importedFontButton.BackgroundColor3 = S.themeColor or COLORS.accent
UI.importedFontButton.BackgroundTransparency = 0.10
UI.importedFontButton.BorderSizePixel = 0
UI.importedFontButton.Text = "PICK"
UI.importedFontButton.TextColor3 = COLORS.white
UI.importedFontButton.Font = Enum.Font.GothamBlack
UI.importedFontButton.TextSize = 10
UI.importedFontButton.AutoButtonColor = false
UI.importedFontButton.ZIndex = 7
corner(UI.importedFontButton, 9)
stroke(UI.importedFontButton, S.themeColor or COLORS.stroke, 1, 0.45)
UI.importedFontButton.Activated:Connect(function()
    if _G.VxyroImportedOpenFontPicker then
        pcall(_G.VxyroImportedOpenFontPicker)
    end
end)


    AV.gen += 1
    local initialGen = AV.gen
    task.defer(function()
        if initialGen == AV.gen then pcall(function() avApplyAll(initialGen) end) end
    end)
    LP.CharacterAdded:Connect(function()
        AV.gen += 1
        local gen = AV.gen
        task.spawn(function()
            for _, delayTime in ipairs({0.7, 1.4, 2.5}) do
                task.wait(delayTime)
                if gen ~= AV.gen then return end
                pcall(function() avApplyAll(gen) end)
            end
        end)
    end)

    -- ================================================================
    -- CUSTOM TOOL SKIN (BAT + MEDUSA)
    -- ================================================================
    local SK = {
        assets = {
            DiamondSword = {cat="Bat", label="Diamond Sword", mesh="rbxassetid://8827558932", tex="rbxassetid://8827558969", scale=Vector3.new(0.2,0.2,0.2), c0=CFrame.new(-0.05,-0.1,-0.12)*CFrame.Angles(math.rad(90),math.rad(180),300), view=4.9},
            Katana = {cat="Bat", label="Katana", mesh="rbxassetid://13528902482", tex="rbxassetid://13528902373", scale=Vector3.new(1.4,1.4,1.4), c0=CFrame.new(0,0.6,0)*CFrame.Angles(math.rad(270),math.rad(180),math.rad(180)), view=6.6},
            Skull = {cat="Medusa", label="Skull", mesh="rbxassetid://2050312704", tex="rbxassetid://2050313393", scale=Vector3.new(1,1,1), c0=CFrame.new(0,0.65,-0.4)*CFrame.Angles(math.rad(330),0,0), view=4.2},
            GoldenDesertEagle = {cat="Medusa", label="Golden Desert Eagle", mesh="rbxassetid://430251413", tex="rbxassetid://435840335", scale=Vector3.new(0.01,0.01,0.01), c0=CFrame.new(0,0,-0.8)*CFrame.Angles(math.rad(330),math.rad(180),0), view=3.0},
        },
        tracked = setmetatable({}, {__mode="k"}),
        watchers = setmetatable({}, {__mode="k"}),
        pending = setmetatable({}, {__mode="k"}),
        enabled = false,
        picker = nil,
    }

    local function toolCategory(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = tostring(tool.Name or ""):lower()
        -- Keep the original imported matching rules, with a small fallback for
        -- common naming variants used by different game versions.
        if n:find("medusa",1,true) or n:find("stone",1,true) then return "Medusa" end
        if n:find("bat",1,true) or n:find("slap",1,true) then return "Bat" end
        return nil
    end

    local function selectedSkin(cat)
        local key = (cat == "Bat") and S.customToolSkinBat or S.customToolSkinMedusa
        if SK.assets[key] and SK.assets[key].cat == cat then return key end
        return (cat == "Bat") and "DiamondSword" or "GoldenDesertEagle"
    end

    local function buildReplica(handle, mode)
        if not handle or not handle.Parent then return end
        local old = handle:FindFirstChild("VyxroSkinReplica")
        if old then pcall(function() old:Destroy() end) end
        local data = SK.assets[mode]
        if not data then return end
        local model = Instance.new("Model")
        model.Name = "VyxroSkinReplica"
        local part = Instance.new("Part")
        part.Name = "MainPart"
        part.Size = Vector3.new(1,1,1)
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.Massless = true
        part.Transparency = 0
        part.Parent = model
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = data.mesh
        mesh.TextureId = data.tex
        mesh.Scale = data.scale
        mesh.Parent = part
        local weld = Instance.new("Motor6D")
        weld.Name = "VyxroSkinMotor"
        weld.Part0 = handle
        weld.Part1 = part
        weld.C0 = data.c0
        weld.Parent = part
        model.Parent = handle
        return model
    end

    local function hideOriginal(entry, obj)
        if not obj or not obj.Parent then return end
        if obj.Name == "VyxroSkinReplica" or obj:FindFirstAncestor("VyxroSkinReplica") then return end
        if entry.replica and obj:IsDescendantOf(entry.replica) then return end
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            if entry.original[obj] == nil then entry.original[obj] = obj.Transparency end
            pcall(function() obj.Transparency = 1 end)
        end
    end

    local function restoreTool(entry)
        for obj,val in pairs(entry.original or {}) do
            if obj and obj.Parent then pcall(function() obj.Transparency = val end) end
        end
        local handle = entry.tool and entry.tool:FindFirstChild("Handle")
        if handle then
            local rep = handle:FindFirstChild("VyxroSkinReplica")
            if rep then pcall(function() rep:Destroy() end) end
        end
    end

    local function teardownSkinTool(tool)
        local entry = SK.tracked[tool]
        if not entry then return end
        for _,c in ipairs(entry.conns) do pcall(function() c:Disconnect() end) end
        restoreTool(entry)
        SK.tracked[tool] = nil
    end

    local function setupSkinTool(tool)
        if not SK.enabled or SK.tracked[tool] then return end
        local cat = toolCategory(tool)
        if not cat then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then
            if SK.pending[tool] then return end
            local c
            c = tool.ChildAdded:Connect(function(child)
                if child.Name == "Handle" then
                    pcall(function() c:Disconnect() end)
                    SK.pending[tool] = nil
                    if SK.enabled then pcall(function() setupSkinTool(tool) end) end
                end
            end)
            SK.pending[tool] = c
            return
        end
        local entry = {tool=tool,cat=cat,original={},conns={},replica=nil}
        SK.tracked[tool] = entry
        for _,obj in ipairs(tool:GetDescendants()) do hideOriginal(entry,obj) end
        entry.replica = buildReplica(handle,selectedSkin(cat))
        entry.conns[#entry.conns+1] = tool.DescendantAdded:Connect(function(obj)
            task.defer(function()
                if SK.tracked[tool] then
                    if obj.Name == "VyxroSkinReplica" then return end
                    hideOriginal(entry,obj)
                end
            end)
        end)
        entry.conns[#entry.conns+1] = tool.AncestryChanged:Connect(function(_,parent)
            if not parent then teardownSkinTool(tool) end
        end)
    end

    local function watchSkinContainer(container)
        if not container or SK.watchers[container] then return end
        SK.watchers[container] = {container.ChildAdded:Connect(setupSkinTool)}
        for _,child in ipairs(container:GetChildren()) do setupSkinTool(child) end
    end

    local function unwatchSkinContainer(container)
        local cons = SK.watchers[container]
        if not cons then return end
        for _,c in ipairs(cons) do pcall(function() c:Disconnect() end) end
        SK.watchers[container]=nil
    end

    local function watchSkinAll()
        watchSkinContainer(LP:FindFirstChildOfClass("Backpack"))
        watchSkinContainer(LP.Character)
        task.defer(function()
            for _, delayTime in ipairs({0.05, 0.35, 1.0, 2.0}) do
                task.wait(delayTime)
                if not SK.enabled then break end
                watchSkinContainer(LP:FindFirstChildOfClass("Backpack"))
                watchSkinContainer(LP.Character)
            end
        end)
    end

    local function rebuildAllSkins()
        for tool,entry in pairs(SK.tracked) do
            if tool and tool.Parent then
                restoreTool(entry)
                for _,obj in ipairs(tool:GetDescendants()) do hideOriginal(entry,obj) end
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    pcall(function()
                        entry.replica = buildReplica(handle,selectedSkin(entry.cat))
                        for _,obj in ipairs(tool:GetDescendants()) do hideOriginal(entry,obj) end
                    end)
                end
            else
                SK.tracked[tool]=nil
            end
        end
    end

    local function skSet(cat,key)
        local data = SK.assets[key]
        if not data or data.cat ~= cat then return end
        if cat == "Bat" then S.customToolSkinBat = key else S.customToolSkinMedusa = key end
        rebuildAllSkins()
        pcall(F.saveFeatureConfigAndMain)
    end

    local function skNext(cat)
        local options = {}
        for key,data in pairs(SK.assets) do if data.cat == cat then options[#options+1]=key end end
        table.sort(options)
        local cur = (cat=="Bat") and S.customToolSkinBat or S.customToolSkinMedusa
        local idx=1
        for i,key in ipairs(options) do if key==cur then idx=i break end end
        idx=(idx%#options)+1
        skSet(cat,options[idx])
    end

    local function skinIntegrityPass(deep)
        if not SK.enabled then return end
        pcall(watchSkinAll)
        local bp = LP:FindFirstChildOfClass("Backpack")
        if bp then
            for _,child in ipairs(bp:GetChildren()) do pcall(setupSkinTool,child) end
        end
        local char = LP.Character
        if char then
            for _,child in ipairs(char:GetChildren()) do pcall(setupSkinTool,child) end
        end
        for tool,entry in pairs(SK.tracked) do
            if not tool or not tool.Parent then
                teardownSkinTool(tool)
            else
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local rep = handle:FindFirstChild("VyxroSkinReplica")
                    local part = rep and rep:FindFirstChild("MainPart")
                    local motor = part and part:FindFirstChild("VyxroSkinMotor")
                    local broken = (not rep) or (not part) or (not motor) or motor.Part0 ~= handle or motor.Part1 ~= part
                    if broken then
                        pcall(function() restoreTool(entry) end)
                        entry.replica = buildReplica(handle,selectedSkin(entry.cat))
                    end
                    if deep or broken then
                        for _,obj in ipairs(tool:GetDescendants()) do
                            pcall(hideOriginal,entry,obj)
                        end
                    end
                else
                    -- Tool handles can be inserted late by the game.
                    pcall(function() setupSkinTool(tool) end)
                end
            end
        end
    end

    local function skSetEnabled(on)
        SK.enabled = on and true or false
        S.customToolsEnabled = SK.enabled
        if SK.enabled then
            pcall(watchSkinAll)
            task.defer(function() pcall(skinIntegrityPass,true) end)
            for tool in pairs(SK.tracked) do if not tool.Parent then SK.tracked[tool]=nil end end
        else
            for tool in pairs(SK.tracked) do teardownSkinTool(tool) end
            for _,c in pairs(SK.pending) do pcall(function() c:Disconnect() end) end
            table.clear(SK.pending)
            for container in pairs(SK.watchers) do unwatchSkinContainer(container) end
        end
        -- Persist the real live module state, not only the UI state.
        pcall(function() if F and F.saveFeatureConfigAndMain then F.saveFeatureConfigAndMain() elseif F and F.saveConfig then F.saveConfig(true) end end)
    end

    task.spawn(function()
        local tickCount = 0
        while true do
            task.wait(0.35)
            if SK.enabled then
                tickCount += 1
                pcall(skinIntegrityPass, (tickCount % 4) == 0)
            end
        end
    end)

    LP.CharacterAdded:Connect(function()
        task.defer(function()
            for tool in pairs(SK.tracked) do teardownSkinTool(tool) end
            for _,c in pairs(SK.pending) do pcall(function() c:Disconnect() end) end
            table.clear(SK.pending)
            for container in pairs(SK.watchers) do unwatchSkinContainer(container) end
            if SK.enabled then
                watchSkinAll()
            end
        end)
    end)

    -- Keep references available for reset / load logic.
    _G.VxyroSetCustomToolSkin = skSet
    _G.VxyroSetCustomToolEnabled = skSetEnabled

    -- ================================================================
    -- SKIN TOOL UI: one OPEN button only
    -- ================================================================
    section(pageVIEW,"Skin Tool")
    local skinOpenRow = mkRow(pageVIEW,40)
    mkLabel(skinOpenRow,"Skin Tool")
    local skinOpenBtn = Instance.new("TextButton",skinOpenRow)
    skinOpenBtn.Size=UDim2.new(0,92,0,26)
    skinOpenBtn.Position=UDim2.new(1,-102,0.5,-13)
    skinOpenBtn.BackgroundColor3=Color3.fromRGB(238,238,241)
    skinOpenBtn.BorderSizePixel=0
    skinOpenBtn.Text="OPEN GUI"
    skinOpenBtn.TextColor3=Color3.fromRGB(8,8,10)
    skinOpenBtn.Font=Enum.Font.GothamBold
    skinOpenBtn.TextSize=10
    skinOpenBtn.AutoButtonColor=false
    skinOpenBtn.ZIndex=6
    skinOpenBtn.Parent=skinOpenRow
    corner(skinOpenBtn,8)
    local skinOpenStroke=stroke(skinOpenBtn,Color3.fromRGB(105,105,115),1,0.28)
    local skinOpenGradient=Instance.new("UIGradient")
    skinOpenGradient.Name="VyxroSkinOpenGradient"
    skinOpenGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(245,245,248)),ColorSequenceKeypoint.new(1,Color3.fromRGB(210,210,216))})
    skinOpenGradient.Rotation=90
    skinOpenGradient.Parent=skinOpenBtn
    skinOpenBtn.MouseEnter:Connect(function()
        skinOpenGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(228,228,233))})
        skinOpenStroke.Transparency=0.05
    end)
    skinOpenBtn.MouseLeave:Connect(function()
        skinOpenGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(245,245,248)),ColorSequenceKeypoint.new(1,Color3.fromRGB(210,210,216))})
        skinOpenStroke.Transparency=0.28
    end)

    local _vxPreviewSound = nil
    local _vxPreviewToken = 0

    local function cleanupSkinPreviewSound(sound)
        if not sound then return end
        pcall(function() sound:Stop() end)
        pcall(function() sound:Destroy() end)
        if _vxPreviewSound == sound then
            _vxPreviewSound = nil
        end
    end

    local function skinPreviewSound(cat)
        local previewIds = {
            Bat    = {id = "rbxassetid://5713085119", skip = 0.2},
            Medusa = {id = "rbxassetid://3102797479", skip = 0.0},
        }
        local data = previewIds[cat]
        if not data then return false end

        _vxPreviewToken += 1
        local myToken = _vxPreviewToken

        -- Satu preview aktif saja. Klik berikutnya menghentikan preview lama.
        if _vxPreviewSound then
            cleanupSkinPreviewSound(_vxPreviewSound)
        end

        local ok, result = pcall(function()
            local SoundService = game:GetService("SoundService")
            local ContentProvider = game:GetService("ContentProvider")

            local snd = Instance.new("Sound")
            snd.Name = "VxyroSkinToolPreview"
            snd.SoundId = data.id
            snd.Volume = 1
            snd.Looped = false
            snd.PlayOnRemove = false
            snd.Parent = SoundService
            _vxPreviewSound = snd

            -- Tunggu asset siap, tetapi jangan pernah memanggil Play lebih dari sekali.
            pcall(function()
                ContentProvider:PreloadAsync({snd})
            end)

            local loadDeadline = os.clock() + 4
            while snd.Parent and not snd.IsLoaded and os.clock() < loadDeadline do
                if myToken ~= _vxPreviewToken then return false end
                task.wait(0.05)
            end

            if myToken ~= _vxPreviewToken or not snd.Parent or not snd.IsLoaded then
                cleanupSkinPreviewSound(snd)
                return false
            end

            if data.skip and data.skip > 0 then
                pcall(function() snd.TimePosition = data.skip end)
            end

            local endedConn
            endedConn = snd.Ended:Connect(function()
                if endedConn then
                    pcall(function() endedConn:Disconnect() end)
                    endedConn = nil
                end
                cleanupSkinPreviewSound(snd)
            end)

            -- PERSIS SATU KALI PLAY. Tidak ada fallback kedua/ketiga dan tidak ada loop.
            snd:Play()

            -- Safety cleanup bila asset/client tidak pernah mengirim Ended.
            task.spawn(function()
                local deadline = os.clock() + 12
                while snd.Parent and myToken == _vxPreviewToken and os.clock() < deadline do
                    if not snd.IsPlaying and snd.TimePosition > 0 then break end
                    task.wait(0.1)
                end
                if endedConn then
                    pcall(function() endedConn:Disconnect() end)
                    endedConn = nil
                end
                if myToken == _vxPreviewToken then
                    cleanupSkinPreviewSound(snd)
                end
            end)

            return true
        end)

        if not ok then
            if _vxPreviewSound then cleanupSkinPreviewSound(_vxPreviewSound) end
            return false
        end
        return result == true
    end

    local skinGui=nil
    local function destroySkinGui()
        _G._VxyroSkinApplyAccent = nil
        if skinGui then pcall(function() skinGui:Destroy() end) end
        if _G._VyxroSkinPreviewSpin then pcall(function() _G._VyxroSkinPreviewSpin:Disconnect() end); _G._VyxroSkinPreviewSpin=nil end
        skinGui=nil
    end

    local function openSkinGui()
        if skinGui and skinGui.Parent then destroySkinGui(); return end
        skSetEnabled(true)
        S.customToolsEnabled = true
        pcall(F.saveFeatureConfigAndMain)

        local sg=Instance.new("ScreenGui")
        sg.Name="VyxroSkinToolGUI"
        sg.ResetOnSpawn=false
        sg.IgnoreGuiInset=true
        sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder=10051
        sg.Parent=safeParentGui()
        skinGui=sg

        local bg=Instance.new("Frame",sg)
        bg.Size=UDim2.fromScale(1,1); bg.BackgroundColor3=Color3.new(0,0,0); bg.BackgroundTransparency=0.46; bg.BorderSizePixel=0; bg.ZIndex=1
        local box=Instance.new("Frame",sg)
        box.Size=UDim2.new(0,390,0,430); box.Position=UDim2.new(0.5,-195,0.5,-215); box.BackgroundColor3=Color3.fromRGB(8,8,10); box.BorderSizePixel=0; box.ZIndex=2; corner(box,15); stroke(box,Color3.fromRGB(90,90,95),1,0.3)
        local ttl=Instance.new("TextLabel",box); ttl.Size=UDim2.new(1,-60,0,34); ttl.Position=UDim2.new(0,14,0,7); ttl.BackgroundTransparency=1; ttl.Text="SKIN TOOL"; ttl.TextColor3=Color3.new(1,1,1); ttl.Font=Enum.Font.GothamBlack; ttl.TextSize=14; ttl.TextXAlignment=Enum.TextXAlignment.Left; ttl.ZIndex=4
        local close=Instance.new("TextButton",box); close.Size=UDim2.new(0,30,0,30); close.Position=UDim2.new(1,-38,0,8); close.BackgroundColor3=Color3.fromRGB(24,24,27); close.BorderSizePixel=0; close.Text="X"; close.TextColor3=Color3.new(1,1,1); close.Font=Enum.Font.GothamBold; close.TextSize=12; close.AutoButtonColor=false; close.ZIndex=5; corner(close,8); close.Activated:Connect(destroySkinGui)
        local sub=Instance.new("TextLabel",box); sub.Size=UDim2.new(1,-28,0,20); sub.Position=UDim2.new(0,14,0,39); sub.BackgroundTransparency=1; sub.Text="Select a Bat or Medusa skin"; sub.TextColor3=Color3.fromRGB(150,150,155); sub.Font=Enum.Font.GothamSemibold; sub.TextSize=9; sub.TextXAlignment=Enum.TextXAlignment.Left; sub.ZIndex=4

        local tabs=Instance.new("Frame",box); tabs.Size=UDim2.new(1,-28,0,34); tabs.Position=UDim2.new(0,14,0,66); tabs.BackgroundColor3=Color3.fromRGB(18,18,20); tabs.BorderSizePixel=0; tabs.ZIndex=4; corner(tabs,9); stroke(tabs,Color3.fromRGB(65,65,70),1,0.55)
        local batTab=Instance.new("TextButton",tabs); batTab.Size=UDim2.new(0.5,-2,1,-4); batTab.Position=UDim2.new(0,2,0,2); batTab.BackgroundColor3=Color3.fromRGB(238,238,238); batTab.BorderSizePixel=0; batTab.Text="BAT"; batTab.TextColor3=Color3.fromRGB(0,0,0); batTab.Font=Enum.Font.GothamBlack; batTab.TextSize=10; batTab.ZIndex=5; corner(batTab,7)
        local medTab=Instance.new("TextButton",tabs); medTab.Size=UDim2.new(0.5,-2,1,-4); medTab.Position=UDim2.new(0.5,0,0,2); medTab.BackgroundColor3=Color3.fromRGB(25,25,28); medTab.BorderSizePixel=0; medTab.Text="MEDUSA"; medTab.TextColor3=Color3.fromRGB(225,225,225); medTab.Font=Enum.Font.GothamBlack; medTab.TextSize=10; medTab.ZIndex=5; corner(medTab,7)

        -- Preview 3D della skin selezionata
        local previewHolder=Instance.new("Frame",box); previewHolder.Size=UDim2.new(0,168,0,170); previewHolder.Position=UDim2.new(0,14,0,108); previewHolder.BackgroundColor3=Color3.fromRGB(12,12,15); previewHolder.BorderSizePixel=0; previewHolder.ZIndex=4; corner(previewHolder,12); stroke(previewHolder,Color3.fromRGB(65,65,70),1,0.55)
        local previewTitle=Instance.new("TextLabel",previewHolder); previewTitle.Size=UDim2.new(1,-16,0,18); previewTitle.Position=UDim2.new(0,8,0,5); previewTitle.BackgroundTransparency=1; previewTitle.Text="3D PREVIEW"; previewTitle.TextColor3=COLORS.textDim; previewTitle.Font=Enum.Font.GothamBlack; previewTitle.TextSize=8; previewTitle.TextXAlignment=Enum.TextXAlignment.Left; previewTitle.ZIndex=6
        local preview=Instance.new("ViewportFrame",previewHolder); preview.Size=UDim2.new(1,-12,1,-30); preview.Position=UDim2.new(0,6,0,24); preview.BackgroundColor3=Color3.fromRGB(7,7,9); preview.BackgroundTransparency=0.15; preview.BorderSizePixel=0; preview.ZIndex=5; preview.Ambient=Color3.fromRGB(200,200,210); preview.LightColor=Color3.fromRGB(255,255,255); preview.LightDirection=Vector3.new(-0.35,-1,-0.55); corner(preview,10)
        local previewWorld=Instance.new("WorldModel"); previewWorld.Parent=preview
        local previewPart=Instance.new("Part"); previewPart.Name="SkinPreviewPart"; previewPart.Size=Vector3.new(1,1,1); previewPart.Anchored=true; previewPart.CanCollide=false; previewPart.CanTouch=false; previewPart.CanQuery=false; previewPart.Transparency=0; previewPart.Parent=previewWorld
        local previewMesh=Instance.new("SpecialMesh"); previewMesh.MeshType=Enum.MeshType.FileMesh; previewMesh.Parent=previewPart
        local previewCam=Instance.new("Camera"); previewCam.FieldOfView=38; previewCam.Parent=preview
        preview.CurrentCamera=previewCam

        local list=Instance.new("Frame",box); list.Size=UDim2.new(0,186,0,170); list.Position=UDim2.new(0,190,0,108); list.BackgroundTransparency=1; list.ZIndex=4
        local info=Instance.new("TextLabel",list); info.Size=UDim2.new(1,0,0,20); info.BackgroundTransparency=1; info.Text=""; info.TextColor3=COLORS.textDim; info.Font=Enum.Font.GothamSemibold; info.TextSize=9; info.TextXAlignment=Enum.TextXAlignment.Left; info.ZIndex=5
        local choose1=Instance.new("TextButton",list); choose1.Size=UDim2.new(1,0,0,38); choose1.Position=UDim2.new(0,0,0,25); choose1.BackgroundColor3=Color3.fromRGB(20,20,23); choose1.BorderSizePixel=0; choose1.TextColor3=COLORS.white; choose1.Font=Enum.Font.GothamSemibold; choose1.TextSize=10; choose1.AutoButtonColor=false; choose1.ZIndex=5; corner(choose1,8); stroke(choose1,Color3.fromRGB(70,70,75),1,0.6)
        local choose2=Instance.new("TextButton",list); choose2.Size=UDim2.new(1,0,0,38); choose2.Position=UDim2.new(0,0,0,70); choose2.BackgroundColor3=Color3.fromRGB(20,20,23); choose2.BorderSizePixel=0; choose2.TextColor3=COLORS.white; choose2.Font=Enum.Font.GothamSemibold; choose2.TextSize=10; choose2.AutoButtonColor=false; choose2.ZIndex=5; corner(choose2,8); stroke(choose2,Color3.fromRGB(70,70,75),1,0.6)
        local state=Instance.new("TextLabel",list); state.Size=UDim2.new(1,0,0,36); state.Position=UDim2.new(0,0,0,118); state.BackgroundTransparency=1; state.TextColor3=Color3.fromRGB(150,150,155); state.Font=Enum.Font.GothamSemibold; state.TextSize=9; state.TextWrapped=true; state.TextXAlignment=Enum.TextXAlignment.Left; state.ZIndex=5

        local soundTitle=Instance.new("TextLabel",box); soundTitle.Size=UDim2.new(1,-28,0,18); soundTitle.Position=UDim2.new(0,14,0,292); soundTitle.BackgroundTransparency=1; soundTitle.Text="SOUND PREVIEW"; soundTitle.TextColor3=COLORS.textDim; soundTitle.Font=Enum.Font.GothamBlack; soundTitle.TextSize=9; soundTitle.TextXAlignment=Enum.TextXAlignment.Left; soundTitle.ZIndex=5
        local batSound=Instance.new("TextButton",box); batSound.Size=UDim2.new(0.5,-20,0,34); batSound.Position=UDim2.new(0,14,0,316); batSound.BackgroundColor3=Color3.fromRGB(20,20,23); batSound.BorderSizePixel=0; batSound.Text="▶ BAT SOUND"; batSound.TextColor3=COLORS.white; batSound.Font=Enum.Font.GothamBold; batSound.TextSize=9; batSound.AutoButtonColor=false; batSound.ZIndex=5; corner(batSound,8); stroke(batSound,Color3.fromRGB(70,70,75),1,0.6)
        local medSound=Instance.new("TextButton",box); medSound.Size=UDim2.new(0.5,-20,0,34); medSound.Position=UDim2.new(0.5,6,0,316); medSound.BackgroundColor3=Color3.fromRGB(20,20,23); medSound.BorderSizePixel=0; medSound.Text="▶ MEDUSA SOUND"; medSound.TextColor3=COLORS.white; medSound.Font=Enum.Font.GothamBold; medSound.TextSize=9; medSound.AutoButtonColor=false; medSound.ZIndex=5; corner(medSound,8); stroke(medSound,Color3.fromRGB(70,70,75),1,0.6)

        -- ============================================================
        -- SKIN TOOL UI POLISH V5 (VISUAL ONLY)
        -- Premium compact dark-blue design. No UIStroke lines or stray
        -- decorative shapes. Existing callbacks and logic are preserved.
        -- ============================================================
        local accent = S.themeColor or COLORS.accent or Color3.fromRGB(27,96,178)

        local function setGrad(obj, top, bottom, rotation)
            if not obj then return end
            local g = obj:FindFirstChild("ZeroSkinGradient")
            if not g then
                g = Instance.new("UIGradient")
                g.Name = "ZeroSkinGradient"
                g.Parent = obj
            end
            g.Color = ColorSequence.new(top, bottom)
            g.Rotation = rotation or 90
        end
        local function stripLines(obj)
            if not obj then return end
            for _,d in ipairs(obj:GetDescendants()) do
                if d:IsA("UIStroke") then d:Destroy() end
                if d.Name:match("Glow") or d.Name:match("Line") or d.Name:match("Accent") then
                    if d:IsA("Frame") or d:IsA("UIStroke") then pcall(function() d:Destroy() end) end
                end
            end
        end
        local function textClean(obj, size, color, font)
            if not obj then return end
            obj.Visible = true
            obj.TextTransparency = 0
            obj.TextScaled = false
            obj.TextSize = size
            obj.TextColor3 = color
            obj.TextStrokeTransparency = 1
            obj.TextTruncate = Enum.TextTruncate.AtEnd
            obj.Font = font or Enum.Font.GothamSemibold
            obj.ZIndex = 20
        end
        local function buttonClean(btn, bg, hover, color, size)
            if not btn then return end
            btn.AutoButtonColor = false
            btn.BackgroundColor3 = bg
            btn.BackgroundTransparency = 0
            btn.BorderSizePixel = 0
            btn.TextColor3 = color or Color3.fromRGB(240,244,249)
            btn.TextSize = size or 9
            btn.TextScaled = false
            btn.TextTruncate = Enum.TextTruncate.AtEnd
            btn.TextStrokeTransparency = 1
            btn.Font = Enum.Font.GothamBold
            btn.MouseEnter:Connect(function() if btn.Parent then btn.BackgroundColor3 = hover end end)
            btn.MouseLeave:Connect(function() if btn.Parent then btn.BackgroundColor3 = bg end end)
        end

        stripLines(box)
        box.BackgroundColor3 = Color3.fromRGB(5,11,19)
        box.BackgroundTransparency = 0
        box.BorderSizePixel = 0
        box.ClipsDescendants = true
        corner(box,15)
        setGrad(box, Color3.fromRGB(14,28,48), Color3.fromRGB(4,9,16), 100)

        textClean(ttl, 16, Color3.fromRGB(244,248,253), Enum.Font.GothamBlack)
        ttl.Position = UDim2.new(0,16,0,8)
        textClean(sub, 9, Color3.fromRGB(137,157,181), Enum.Font.GothamSemibold)
        close.BackgroundColor3 = Color3.fromRGB(10,22,38)
        close.BorderSizePixel = 0
        close.TextColor3 = Color3.fromRGB(220,231,242)
        close.TextSize = 12
        close.TextStrokeTransparency = 1
        close.AutoButtonColor = false
        corner(close,8)
        setGrad(close, Color3.fromRGB(18,37,62), Color3.fromRGB(7,15,26), 90)
        close.MouseEnter:Connect(function() if close.Parent then close.BackgroundColor3=Color3.fromRGB(22,46,77) end end)
        close.MouseLeave:Connect(function() if close.Parent then close.BackgroundColor3=Color3.fromRGB(10,22,38) end end)

        stripLines(tabs)
        tabs.BackgroundColor3 = Color3.fromRGB(7,16,28)
        tabs.BorderSizePixel = 0
        corner(tabs,9)
        setGrad(tabs, Color3.fromRGB(12,26,44), Color3.fromRGB(5,11,19), 90)
        for _,b in ipairs({batTab,medTab}) do
            b.BorderSizePixel = 0
            b.TextStrokeTransparency = 1
            corner(b,7)
        end
        buttonClean(batTab, accent, Color3.fromRGB(43,116,198), Color3.fromRGB(255,255,255), 10)
        buttonClean(medTab, Color3.fromRGB(10,22,38), Color3.fromRGB(20,40,66), Color3.fromRGB(202,216,232), 10)
        setGrad(batTab, Color3.fromRGB(54,127,207), accent, 90)
        setGrad(medTab, Color3.fromRGB(16,33,55), Color3.fromRGB(7,15,26), 90)

        stripLines(previewHolder)
        previewHolder.BackgroundColor3 = Color3.fromRGB(5,11,19)
        previewHolder.BorderSizePixel = 0
        corner(previewHolder,12)
        setGrad(previewHolder, Color3.fromRGB(12,27,46), Color3.fromRGB(4,9,16), 105)
        textClean(previewTitle, 8, Color3.fromRGB(132,153,178), Enum.Font.GothamBlack)
        preview.BackgroundColor3 = Color3.fromRGB(2,6,11)
        preview.BackgroundTransparency = 0
        preview.BorderSizePixel = 0
        corner(preview,10)

        textClean(info, 9, Color3.fromRGB(157,177,201), Enum.Font.GothamBlack)
        for _,b in ipairs({choose1,choose2}) do
            stripLines(b)
            buttonClean(b, Color3.fromRGB(8,18,31), Color3.fromRGB(16,36,60), Color3.fromRGB(236,242,249), 10)
            corner(b,9)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.TextYAlignment = Enum.TextYAlignment.Center
            b.TextWrapped = false
            setGrad(b, Color3.fromRGB(13,28,47), Color3.fromRGB(6,12,22), 90)
        end
        textClean(state, 9, Color3.fromRGB(161,181,204), Enum.Font.GothamMedium)
        state.TextWrapped = true
        state.TextXAlignment = Enum.TextXAlignment.Left
        state.TextYAlignment = Enum.TextYAlignment.Center
        state.TextTruncate = Enum.TextTruncate.AtEnd

        textClean(soundTitle, 9, Color3.fromRGB(145,166,190), Enum.Font.GothamBlack)
        for _,b in ipairs({batSound,medSound}) do
            stripLines(b)
            buttonClean(b, Color3.fromRGB(8,18,31), Color3.fromRGB(16,36,60), Color3.fromRGB(232,239,247), 9)
            corner(b,9)
            setGrad(b, Color3.fromRGB(14,29,48), Color3.fromRGB(6,12,22), 90)
        end
        for _,obj in ipairs({ttl,sub,close,batTab,medTab,previewTitle,info,choose1,choose2,state,soundTitle,batSound,medSound}) do
            if obj then obj.Visible=true; obj.TextTransparency=0; obj.TextStrokeTransparency=1; obj.ZIndex=20 end
        end

        local function applySkinAccent(col)
            accent = col or accent
            if batTab then
                batTab.BackgroundColor3 = accent
                setGrad(batTab, Color3.fromRGB(64,139,219), accent, 90)
            end
            if medTab then
                medTab.BackgroundColor3 = Color3.fromRGB(10,22,38)
                setGrad(medTab, Color3.fromRGB(16,33,55), Color3.fromRGB(7,15,26), 90)
            end
        end
        _G._VxyroSkinApplyAccent = applySkinAccent
        applySkinAccent(accent)

        local activeCat="Bat"
        local function refreshPreview(key)
            local def=SK.assets[key]
            if not def then return end
            previewMesh.MeshId=def.mesh
            previewMesh.TextureId=def.tex
            previewMesh.Scale=def.scale
            previewPart.CFrame=CFrame.new(0,0,0)
            local distance=tonumber(def.view) or 5
            previewCam.CFrame=CFrame.new(0,0,distance)
        end
        local previewSpinConn=nil
        local function startPreviewSpin()
            if previewSpinConn then pcall(function() previewSpinConn:Disconnect() end) end
            previewSpinConn=RunService.RenderStepped:Connect(function()
                if not (preview and preview.Parent and previewPart and previewPart.Parent) then return end
                local angle=(os.clock()*0.7)%((math.pi)*2)
                previewPart.CFrame=CFrame.Angles(0,angle,0)
            end)
            _G._VyxroSkinPreviewSpin=previewSpinConn
        end
        local function refresh()
            local cat=activeCat
            local options={}
            for key,data in pairs(SK.assets) do if data.cat==cat then options[#options+1]={key=key,label=data.label} end end
            table.sort(options,function(a,b) return a.label<b.label end)
            info.Text=(cat=="Bat") and "BAT SKINS" or "MEDUSA SKINS"
            local cur=(cat=="Bat") and S.customToolSkinBat or S.customToolSkinMedusa
            choose1.Text=options[1] and ((cur==options[1].key and "✓ " or "")..options[1].label) or "None"
            choose2.Text=options[2] and ((cur==options[2].key and "✓ " or "")..options[2].label) or "None"
            state.Text="Selected: "..tostring(SK.assets[cur] and SK.assets[cur].label or "None")
            info.TextTransparency = 0
            choose1.TextTransparency = 0
            choose2.TextTransparency = 0
            state.TextTransparency = 0
            refreshPreview(cur)
            local on=cat=="Bat"
            batTab.BackgroundColor3=on and accent or Color3.fromRGB(25,25,28)
            batTab.TextColor3=Color3.fromRGB(255,255,255)
            medTab.BackgroundColor3=on and Color3.fromRGB(25,25,28) or accent
            medTab.TextColor3=on and Color3.fromRGB(225,225,225) or Color3.fromRGB(255,255,255)
            applySkinAccent(accent)
        end
        local function selectOption(i)
            local cat=activeCat; local options={}
            for key,data in pairs(SK.assets) do if data.cat==cat then options[#options+1]={key=key,label=data.label} end end
            table.sort(options,function(a,b) return a.label<b.label end)
            if options[i] then skSet(cat,options[i].key); refresh() end
        end
        batTab.Activated:Connect(function() activeCat="Bat"; refresh() end)
        medTab.Activated:Connect(function() activeCat="Medusa"; refresh() end)
        choose1.Activated:Connect(function() selectOption(1) end)
        choose2.Activated:Connect(function() selectOption(2) end)
        batSound.Activated:Connect(function() skinPreviewSound("Bat") end)
        medSound.Activated:Connect(function() skinPreviewSound("Medusa") end)
        bg.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then destroySkinGui() end end)
        refresh()
        for _,obj in ipairs({box,tabs,previewHolder,preview,choose1,choose2,batSound,medSound,close}) do
            if obj then
                for _,ch in ipairs(obj:GetChildren()) do
                    if ch:IsA("UIStroke") then ch.Transparency = 1 end
                end
            end
        end
        startPreviewSpin()
        skSetEnabled(true)
        pcall(function() for _,c in ipairs(SK.watchers) do end end)
        pcall(function() rebuildAllSkins() end)
        pcall(function() if _G.AmbitiousCustomToolsRecheck then _G.AmbitiousCustomToolsRecheck() end end)
    end

    skinOpenBtn.Activated:Connect(openSkinGui)

    -- Kept for reset/load compatibility: the visible control is an OPEN button, not an on/off toggle.
    VS.setImportedSkinToolVisual = function(_) end

    -- ================================================================
    -- CUSTOM SOUND (BAT + MEDUSA)
-- NOTE: Medusa Sound below is the preview button only; duplicate custom-sound engine was removed.
    -- ================================================================
    local CSND = {
        sounds = {
            Bat={id="rbxassetid://5713085119",skip=0.2},
            Medusa={id="rbxassetid://3102797479",doublePlay=true,delay=0.5},
        },
        enabled=false,
        tracked=setmetatable({}, {__mode="k"}),
        watchers=setmetatable({}, {__mode="k"}),
        pending=setmetatable({}, {__mode="k"}),
    }

    local function csToolCategory(tool) return toolCategory(tool) end

    local function csPlay(entry)
        local snd=entry and entry.custom
        local d=entry and entry.data
        if not snd or not snd.Parent or not d or not CSND.enabled then return end
        local now = tick()
        if entry.lastPlay and (now - entry.lastPlay) < 0.09 then return end
        entry.lastPlay = now
        if entry.timer then pcall(task.cancel,entry.timer); entry.timer=nil end
        task.spawn(function()
            if not CSND.enabled or not snd or not snd.Parent then return end
            pcall(function()
                if not snd.IsLoaded then
                    game:GetService("ContentProvider"):PreloadAsync({snd})
                end
            end)
            if not CSND.enabled or not snd.Parent then return end
            pcall(function()
                snd:Stop()
                snd.TimePosition=d.skip or 0
                snd.Volume=1
                snd:Play()
            end)
        end)
        if d.doublePlay and d.delay then
            entry.timer=task.delay(d.delay,function()
                entry.timer=nil
                if not CSND.enabled or not snd or not snd.Parent then return end
                pcall(function() snd:Stop(); snd.TimePosition=d.skip or 0; snd.Volume=1; snd:Play() end)
            end)
        end
    end

    local function csHookSound(entry,snd)
        if not snd or not snd:IsA("Sound") or snd.Name=="VyxroCustomSound" then return end
        if entry.hooked[snd] then return end
        entry.hooked[snd]=snd.Volume
        local function trigger()
            if not CSND.enabled then return end
            if snd.Playing then
                pcall(function() snd.Volume=0; snd:Stop() end)
                csPlay(entry)
            end
        end
        entry.conns[#entry.conns+1]=snd:GetPropertyChangedSignal("Playing"):Connect(trigger)
        if snd.Playing then trigger() end
    end

    local function csTeardown(tool)
        local entry=CSND.tracked[tool]
        if not entry then return end
        if entry.timer then pcall(task.cancel,entry.timer) end
        for _,c in ipairs(entry.conns) do pcall(function() c:Disconnect() end) end
        if entry.custom then pcall(function() entry.custom:Destroy() end) end
        for snd,vol in pairs(entry.hooked) do if snd and snd.Parent then pcall(function() snd.Volume=vol end) end end
        CSND.tracked[tool]=nil
    end

    local function csSetupTool(tool)
        if not CSND.enabled or CSND.tracked[tool] then return end
        local cat=csToolCategory(tool); if not cat then return end
        local handle=tool:FindFirstChild("Handle")
        if not handle then
            if CSND.pending[tool] then return end
            local c
            c=tool.ChildAdded:Connect(function(child)
                if child.Name=="Handle" then
                    pcall(function() c:Disconnect() end)
                    CSND.pending[tool]=nil
                    if CSND.enabled then csSetupTool(tool) end
                end
            end)
            CSND.pending[tool]=c
            return
        end
        local data=CSND.sounds[cat]
        if not data or not data.id then return end
        local old=handle:FindFirstChild("VyxroCustomSound"); if old then pcall(function() old:Destroy() end) end
        local custom=Instance.new("Sound")
        custom.Name="VyxroCustomSound"; custom.SoundId=data.id; custom.Volume=1; custom.Looped=false; custom.RollOffMode=Enum.RollOffMode.Inverse; custom.MaxDistance=1000; custom.MinDistance=1000; custom.Parent=handle
        local entry={custom=custom,data=data,conns={},hooked={},timer=nil}; CSND.tracked[tool]=entry
        for _,d in ipairs(tool:GetDescendants()) do csHookSound(entry,d) end
        entry.conns[#entry.conns+1]=tool.DescendantAdded:Connect(function(d) if CSND.tracked[tool] then csHookSound(entry,d) end end)
        entry.conns[#entry.conns+1]=tool.AncestryChanged:Connect(function(_,parent) if not parent then csTeardown(tool) end end)
    end

    local function csWatch(container)
        if not container or CSND.watchers[container] then return end
        CSND.watchers[container]={container.ChildAdded:Connect(csSetupTool)}
        for _,child in ipairs(container:GetChildren()) do csSetupTool(child) end
    end
    local function csUnwatch(container)
        local conns=CSND.watchers[container]; if not conns then return end
        for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        CSND.watchers[container]=nil
    end
    local function csWatchAll()
        csWatch(LP:FindFirstChildOfClass("Backpack")); csWatch(LP.Character)
        task.defer(function()
            for _, delayTime in ipairs({0.05, 0.35, 1.0, 2.0}) do
                task.wait(delayTime)
                if not CSND.enabled then break end
                csWatch(LP:FindFirstChildOfClass("Backpack")); csWatch(LP.Character)
            end
        end)
    end
    local function csIntegrityPass()
        if not CSND.enabled then return end
        pcall(csWatchAll)
        local bp = LP:FindFirstChildOfClass("Backpack")
        if bp then for _,child in ipairs(bp:GetChildren()) do pcall(csSetupTool,child) end end
        local char = LP.Character
        if char then for _,child in ipairs(char:GetChildren()) do pcall(csSetupTool,child) end end
        for tool,entry in pairs(CSND.tracked) do
            if not tool or not tool.Parent then
                csTeardown(tool)
            else
                local handle=tool:FindFirstChild("Handle")
                if not handle then
                    csTeardown(tool)
                    pcall(csSetupTool,tool)
                else
                    local custom=handle:FindFirstChild("VyxroCustomSound")
                    if not custom then
                        csTeardown(tool)
                        pcall(csSetupTool,tool)
                    else
                        for _,obj in ipairs(tool:GetDescendants()) do pcall(csHookSound,entry,obj) end
                    end
                end
            end
        end
    end

    local function csSetEnabled(on)
        CSND.enabled=on and true or false
        S.customSoundsEnabled=CSND.enabled
        if CSND.enabled then
            pcall(csWatchAll)
            task.defer(function() pcall(csIntegrityPass) end)
        else
            for tool in pairs(CSND.tracked) do csTeardown(tool) end
            for _,c in pairs(CSND.pending) do pcall(function() c:Disconnect() end) end
            table.clear(CSND.pending)
            for container in pairs(CSND.watchers) do csUnwatch(container) end
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.35)
            if CSND.enabled then pcall(csIntegrityPass) end
        end
    end)
    LP.CharacterAdded:Connect(function(char)
        task.defer(function()
            for tool in pairs(CSND.tracked) do csTeardown(tool) end
            for _,c in pairs(CSND.pending) do pcall(function() c:Disconnect() end) end
            table.clear(CSND.pending)
            for container in pairs(CSND.watchers) do csUnwatch(container) end
            if CSND.enabled then csWatch(char); task.wait(0.1); csWatchAll() end
        end)
    end)

    local soundRow = mkToggle(pageVIEW,"Custom Sound",S.customSoundsEnabled,function(on)
        csSetEnabled(on)
        pcall(F.saveFeatureConfigAndMain)
    end)
    VS.setImportedCustomSoundVisual = soundRow

    -- ================================================================
    -- VIVID GRAPHICS
    -- ================================================================
    S.vividSettings = type(S.vividSettings)=="table" and S.vividSettings or {saturation=0.6,bloomIntensity=0.8,bloomSize=24,sunIntensity=0.2,dofFocus=25}
    local VI={picker=nil,effects={}}

    local function vividStop()
        for _,o in ipairs(Lighting:GetChildren()) do
            if o:GetAttribute("_VyxroImportedVivid") then pcall(function() o:Destroy() end) end
        end
        VI.effects={}
    end

    local function vividStart()
        vividStop()
        if not S.vividGraphicsEnabled then return false end
        local made=0
        local function make(className,name,apply)
            local ok,e=pcall(function()
                local obj=Instance.new(className)
                obj.Name=name
                obj:SetAttribute("_VyxroImportedVivid",true)
                obj.Parent=Lighting
                apply(obj)
                return obj
            end)
            if ok and e then
                VI.effects[#VI.effects+1]=e
                made+=1
            end
        end
        make("ColorCorrectionEffect","VyxroVividColor",function(c)
            c.Saturation=tonumber(S.vividSettings.saturation) or 0.6
            c.Contrast=0.4
            c.Brightness=0.05
            c.TintColor=Color3.fromRGB(255,240,220)
        end)
        make("BloomEffect","VyxroVividBloom",function(b)
            b.Intensity=tonumber(S.vividSettings.bloomIntensity) or 0.8
            b.Size=tonumber(S.vividSettings.bloomSize) or 24
            b.Threshold=1
        end)
        make("SunRaysEffect","VyxroVividSun",function(sun)
            sun.Intensity=tonumber(S.vividSettings.sunIntensity) or 0.2
            sun.Spread=0.8
        end)
        make("DepthOfFieldEffect","VyxroVividDOF",function(d)
            d.FocusDistance=tonumber(S.vividSettings.dofFocus) or 25
            d.InFocusRadius=10
            d.NearIntensity=0.2
            d.FarIntensity=0.4
        end)
        -- Atmosphere is optional; if a game/runtime rejects it, the other four effects still work.
        make("Atmosphere","VyxroVividAtmosphere",function(a)
            a.Density=0.3
            a.Offset=0.25
            a.Color=Color3.fromRGB(199,199,255)
            a.Decay=Color3.fromRGB(106,112,125)
            a.Glare=0.2
            a.Haze=1
        end)
        return made > 0
    end

    local function vividSet(name,value)
        local ranges={saturation={0,2},bloomIntensity={0,3},bloomSize={1,56},sunIntensity={0,1},dofFocus={1,100}}
        local r=ranges[name]; if not r then return end
        S.vividSettings[name]=math.clamp(tonumber(value) or S.vividSettings[name],r[1],r[2])
        if S.vividGraphicsEnabled then
            vividStart()
        end
        pcall(F.saveFeatureConfigAndMain)
    end
    local function vividOpenPicker()
        if VI.picker and VI.picker.Parent then VI.picker:Destroy(); VI.picker=nil; return end
        local sg=Instance.new("ScreenGui"); sg.Name="VyxroVividPicker"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true; sg.DisplayOrder=10052; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=safeParentGui(); VI.picker=sg
        local bg=Instance.new("Frame",sg); bg.Size=UDim2.fromScale(1,1); bg.BackgroundColor3=Color3.new(0,0,0); bg.BackgroundTransparency=0.48; bg.BorderSizePixel=0; bg.ZIndex=1
        local box=Instance.new("Frame",sg); box.Size=UDim2.new(0,320,0,330); box.Position=UDim2.new(0.5,-160,0.5,-165); box.BackgroundColor3=Color3.fromRGB(8,8,10); box.BorderSizePixel=0; box.ZIndex=2; corner(box,14); stroke(box,Color3.fromRGB(90,90,95),1,0.3)
        local ttl=Instance.new("TextLabel",box); ttl.Size=UDim2.new(1,-52,0,34); ttl.Position=UDim2.new(0,14,0,7); ttl.BackgroundTransparency=1; ttl.Text="VIVID GRAPHICS CHANGER"; ttl.TextColor3=Color3.new(1,1,1); ttl.Font=Enum.Font.GothamBlack; ttl.TextSize=12; ttl.TextXAlignment=Enum.TextXAlignment.Left
        local close=Instance.new("TextButton",box); close.Size=UDim2.new(0,30,0,30); close.Position=UDim2.new(1,-38,0,8); close.BackgroundColor3=Color3.fromRGB(24,24,27); close.BorderSizePixel=0; close.Text="X"; close.TextColor3=Color3.new(1,1,1); close.Font=Enum.Font.GothamBold; close.TextSize=12; close.AutoButtonColor=false; corner(close,8); close.Activated:Connect(function() if VI.picker then VI.picker:Destroy(); VI.picker=nil end end)
        local specs={{"Saturation","saturation",0.1},{"Bloom Intensity","bloomIntensity",0.1},{"Bloom Size","bloomSize",1},{"Sun Rays","sunIntensity",0.05},{"DOF Focus Dist","dofFocus",1}}
        for i,spec in ipairs(specs) do
            local y=48+(i-1)*50; local r=mkRow(box,40); r.Position=UDim2.new(0,10,0,y); r.Size=UDim2.new(1,-20,0,40);
            local label = mkLabel(r,spec[1])
            r.BackgroundColor3 = Color3.fromRGB(15,15,19)
            r.BackgroundTransparency = 0.03
            local rs = r:FindFirstChild("RowStroke")
            if rs then rs.Color=Color3.fromRGB(67,67,80); rs.Transparency=0.25; rs.Thickness=1.05 end
            label.TextColor3=Color3.fromRGB(240,240,247)
            label.TextStrokeColor3=Color3.fromRGB(0,0,0)
            label.TextStrokeTransparency=0.82
            label.Font=Enum.Font.GothamSemibold
            label.TextSize=10
            local val=Instance.new("TextLabel",r); val.Size=UDim2.new(0,58,0,24); val.Position=UDim2.new(1,-130,0.5,-12); val.BackgroundColor3=Color3.fromRGB(9,9,12); val.BorderSizePixel=0; val.TextColor3=Color3.fromRGB(248,248,252); val.Font=Enum.Font.GothamBlack; val.TextSize=10; val.TextStrokeColor3=Color3.fromRGB(0,0,0); val.TextStrokeTransparency=0.78; val.ZIndex=12; corner(val,7);
            local valStroke=stroke(val,Color3.fromRGB(92,78,118),1.1,0.20)
            local minus=Instance.new("TextButton",r); minus.Size=UDim2.new(0,24,0,24); minus.Position=UDim2.new(1,-64,0.5,-12); minus.BackgroundColor3=Color3.fromRGB(24,24,29); minus.BorderSizePixel=0; minus.Text="−"; minus.TextColor3=Color3.fromRGB(242,242,248); minus.Font=Enum.Font.GothamBlack; minus.TextSize=14; minus.TextTransparency=0; minus.TextStrokeColor3=Color3.fromRGB(0,0,0); minus.TextStrokeTransparency=0.72; minus.AutoButtonColor=false; minus.ZIndex=12; corner(minus,7); local ms=stroke(minus,Color3.fromRGB(73,73,86),1,0.30)
            local plus=Instance.new("TextButton",r); plus.Size=UDim2.new(0,24,0,24); plus.Position=UDim2.new(1,-32,0.5,-12); plus.BackgroundColor3=Color3.fromRGB(235,235,240); plus.BorderSizePixel=0; plus.Text="+"; plus.TextColor3=Color3.fromRGB(10,10,12); plus.Font=Enum.Font.GothamBlack; plus.TextSize=14; plus.TextTransparency=0; plus.TextStrokeColor3=Color3.fromRGB(255,255,255); plus.TextStrokeTransparency=0.85; plus.AutoButtonColor=false; plus.ZIndex=12; corner(plus,7); local ps=stroke(plus,Color3.fromRGB(160,160,170),1,0.18)
            minus.MouseEnter:Connect(function() minus.BackgroundColor3=Color3.fromRGB(40,40,48); ms.Transparency=0.04 end)
            minus.MouseLeave:Connect(function() minus.BackgroundColor3=Color3.fromRGB(24,24,29); ms.Transparency=0.30 end)
            plus.MouseEnter:Connect(function() plus.BackgroundColor3=Color3.fromRGB(250,250,253); ps.Transparency=0.04 end)
            plus.MouseLeave:Connect(function() plus.BackgroundColor3=Color3.fromRGB(235,235,240); ps.Transparency=0.18 end)
            local function refreshVal() local v=S.vividSettings[spec[2]]; if spec[2]=="saturation" or spec[2]=="bloomIntensity" then val.Text=string.format("%.1f",v) elseif spec[2]=="sunIntensity" then val.Text=string.format("%.2f",v) else val.Text=string.format("%.0f",v) end end
            refreshVal(); minus.Activated:Connect(function() vividSet(spec[2],(S.vividSettings[spec[2]] or 0)-spec[3]); refreshVal() end); plus.Activated:Connect(function() vividSet(spec[2],(S.vividSettings[spec[2]] or 0)+spec[3]); refreshVal() end)
        end
        local reset=Instance.new("TextButton",box); reset.Size=UDim2.new(1,-24,0,34); reset.Position=UDim2.new(0,12,1,-46); reset.BackgroundColor3=Color3.fromRGB(235,235,240); reset.BorderSizePixel=0; reset.Text="RESET DEFAULTS"; reset.TextColor3=Color3.fromRGB(9,9,12); reset.Font=Enum.Font.GothamBlack; reset.TextSize=10; reset.TextTransparency=0; reset.TextStrokeColor3=Color3.fromRGB(255,255,255); reset.TextStrokeTransparency=0.86; reset.AutoButtonColor=false; reset.ZIndex=12; corner(reset,9)
        local resetStroke=stroke(reset,Color3.fromRGB(154,154,165),1.15,0.18)
        reset.MouseEnter:Connect(function() reset.BackgroundColor3=Color3.fromRGB(250,250,253); resetStroke.Transparency=0.04 end)
        reset.MouseLeave:Connect(function() reset.BackgroundColor3=Color3.fromRGB(235,235,240); resetStroke.Transparency=0.18 end)
        local vivShadow=Instance.new("Frame",sg); vivShadow.Name="VyxroVividShadow"; vivShadow.Size=box.Size; vivShadow.Position=box.Position+UDim2.new(0,0,0,6); vivShadow.BackgroundColor3=Color3.fromRGB(0,0,0); vivShadow.BackgroundTransparency=0.58; vivShadow.BorderSizePixel=0; vivShadow.ZIndex=1; corner(vivShadow,15)
        box.ZIndex=4
        local vivLine=Instance.new("Frame",box); vivLine.Name="VyxroVividTopLine"; vivLine.Size=UDim2.new(1,-28,0,2); vivLine.Position=UDim2.new(0,14,0,58); vivLine.BackgroundColor3=S.themeColor or COLORS.accent; vivLine.BackgroundTransparency=0.10; vivLine.BorderSizePixel=0; vivLine.ZIndex=12; corner(vivLine,2); vivLine:SetAttribute("ThemeAccentFill",true)
        reset.Activated:Connect(function() S.vividSettings={saturation=0.6,bloomIntensity=0.8,bloomSize=24,sunIntensity=0.2,dofFocus=25}; if S.vividGraphicsEnabled then vividStart() end; pcall(F.saveFeatureConfigAndMain); if VI.picker then VI.picker:Destroy(); VI.picker=nil end; vividOpenPicker() end)
        bg.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then if VI.picker then VI.picker:Destroy(); VI.picker=nil end end end)
    end

    section(pageVIEW,"Vivid & Camera")
    VS.setImportedVividVisual=mkToggle(pageVIEW,"Vivid Graphics",S.vividGraphicsEnabled,function(on)
        S.vividGraphicsEnabled=on and true or false
        if S.vividGraphicsEnabled then
            task.defer(function() pcall(vividStart) end)
        else
            vividStop()
        end
        pcall(F.saveFeatureConfigAndMain)
    end)
    local vividRow=mkRow(pageVIEW,34); local vividRowLabel=mkLabel(vividRow,"Vivid Graphics Changer")
    vividRow.BackgroundColor3=Color3.fromRGB(14,14,18); vividRow.BackgroundTransparency=0.08
    local vividRowStroke=vividRow:FindFirstChild("RowStroke"); if vividRowStroke then vividRowStroke.Color=Color3.fromRGB(98,76,132); vividRowStroke.Transparency=0.27; vividRowStroke.Thickness=1.1 end
    vividRowLabel.TextColor3=Color3.fromRGB(245,245,250); vividRowLabel.TextStrokeColor3=Color3.fromRGB(0,0,0); vividRowLabel.TextStrokeTransparency=0.82
    local vividBtn=Instance.new("TextButton",vividRow); vividBtn.Size=UDim2.new(0,86,0,24); vividBtn.Position=UDim2.new(1,-94,0.5,-12); vividBtn.BackgroundColor3=Color3.fromRGB(232,232,237); vividBtn.BorderSizePixel=0; vividBtn.Text="OPEN"; vividBtn.TextColor3=Color3.fromRGB(9,9,12); vividBtn.Font=Enum.Font.GothamBlack; vividBtn.TextSize=10; vividBtn.TextTransparency=0; vividBtn.TextStrokeColor3=Color3.fromRGB(255,255,255); vividBtn.TextStrokeTransparency=0.88; vividBtn.AutoButtonColor=false; vividBtn.ZIndex=10; corner(vividBtn,8); local vividBtnStroke=stroke(vividBtn,Color3.fromRGB(153,153,165),1.05,0.18); vividBtn.MouseEnter:Connect(function() vividBtn.BackgroundColor3=Color3.fromRGB(250,250,253); vividBtnStroke.Transparency=0.04 end); vividBtn.MouseLeave:Connect(function() vividBtn.BackgroundColor3=Color3.fromRGB(232,232,237); vividBtnStroke.Transparency=0.18 end); vividBtn.Activated:Connect(vividOpenPicker)

    -- ================================================================
    -- MOTION BLUR
    -- ================================================================
    local MB={conn=nil,effect=nil,value=0,last=nil}
    local function mbStop()
        if MB.conn then pcall(function() MB.conn:Disconnect() end); MB.conn=nil end
        if MB.effect then pcall(function() MB.effect.Size=0; MB.effect.Enabled=false; MB.effect:Destroy() end) end
        MB.effect=nil; MB.value=0; MB.last=nil
    end
    local function mbStart()
        mbStop()
        if not S.motionBlurEnabled then return end
        local e=Instance.new("BlurEffect")
        e.Name="VyxroMotionBlur"
        e.Size=0
        e.Enabled=true
        e.Parent=Lighting
        MB.effect=e
        MB.last=workspace.CurrentCamera and workspace.CurrentCamera.CFrame or nil
        MB.value=0
        MB.conn=RunService.RenderStepped:Connect(function(dt)
            if not S.motionBlurEnabled then mbStop(); return end
            local cam=workspace.CurrentCamera
            if not cam then return end
            local cur=cam.CFrame
            if not MB.last then MB.last=cur; return end
            local angle=math.deg(math.acos(math.clamp(cur.LookVector:Dot(MB.last.LookVector),-1,1)))
            local travel=(cur.Position-MB.last.Position).Magnitude
            local target=math.min((angle*24)+(travel*2.5),14)
            local alpha=math.min(1,math.max(0,(dt or 0.016)*12))
            MB.value=MB.value+(target-MB.value)*alpha
            if MB.effect and MB.effect.Parent then
                pcall(function() MB.effect.Size=MB.value end)
            end
            MB.last=cur
        end)
    end
    VS.setImportedMotionBlurVisual=mkToggle(pageVIEW,"Motion Blur",S.motionBlurEnabled,function(on)
        S.motionBlurEnabled=on and true or false
        if S.motionBlurEnabled then mbStart() else mbStop() end
        pcall(F.saveFeatureConfigAndMain)
    end)

    -- Combined load/reset APIs. These are deliberately ordered so a broken
    -- optional feature cannot prevent Vivid/Motion Blur from being restored.
    local function applyImportedFeatureRuntime()
        -- Each feature is isolated so an error in Avatar/Vivid cannot prevent
        -- Skin Tool or Custom Sound from starting.
        pcall(function()
            for _,cat in ipairs(AV.cats) do avRefresh(cat.name) end
            pcall(function() avApplyAll(AV.gen) end)
        end)
        pcall(function()
            if S.customToolsEnabled then skSetEnabled(true) else skSetEnabled(false) end
        end)
        pcall(function()
            if S.customSoundsEnabled then csSetEnabled(true) else csSetEnabled(false) end
        end)
        pcall(function()
            if S.vividGraphicsEnabled then vividStart() else vividStop() end
        end)
        pcall(function()
            if S.motionBlurEnabled then mbStart() else mbStop() end
        end)
        pcall(function()
            if VS.setImportedCustomSoundVisual then VS.setImportedCustomSoundVisual(S.customSoundsEnabled == true) end
            if VS.setImportedVividVisual then VS.setImportedVividVisual(S.vividGraphicsEnabled == true) end
            if VS.setImportedMotionBlurVisual then VS.setImportedMotionBlurVisual(S.motionBlurEnabled == true) end
        end)
    end

    _G.VxyroImportedApplyLoaded=function()
        -- Apply once immediately; Avatar Changer itself is staged in a
        -- low-stutter queue. A single delayed pass covers late character
        -- construction without stacking five full runtime re-applications.
        applyImportedFeatureRuntime()
        task.delay(1.15, function()
            pcall(function()
                avApplyAll(AV.gen)
            end)
        end)
    end

    _G.VxyroImportedFeaturesReset=function()
        pcall(avClosePicker)
        pcall(function() if SK.picker then SK.picker:Destroy(); SK.picker=nil end end)
        pcall(function() if VI.picker then VI.picker:Destroy(); VI.picker=nil end end)
        pcall(function() skSetEnabled(false) end)
        pcall(function() csSetEnabled(false) end)
        local char=LP.Character
        if char then
            for _,o in ipairs(char:GetChildren()) do
                if (o:IsA("Accessory") or o:IsA("Shirt") or o:IsA("Pants") or o:IsA("ShirtGraphic")) and o.Name:sub(1,2)=="AC" then
                    pcall(function() o:Destroy() end)
                end
            end
        end
        for _,cat in ipairs(AV.cats) do
            local e=S.avatarChanger[cat.name]
            if e and e.savedId then avRemove(cat,e.savedName) end
            if e then e.enabled=false; e.savedId=nil; e.savedName="" end
            avRefresh(cat.name)
        end
        S.avatarChanger={}
        S.customToolsEnabled=false
        S.customSoundsEnabled=false
        S.customToolSkinBat="DiamondSword"
        S.customToolSkinMedusa="GoldenDesertEagle"
        S.vividGraphicsEnabled=false
        S.motionBlurEnabled=false
        S.vividSettings={saturation=0.6,bloomIntensity=0.8,bloomSize=24,sunIntensity=0.2,dofFocus=25}
        vividStop(); mbStop()
        destroySkinGui()
        if VS.setImportedCustomSoundVisual then VS.setImportedCustomSoundVisual(false) end
        if VS.setImportedVividVisual then VS.setImportedVividVisual(false) end
        if VS.setImportedMotionBlurVisual then VS.setImportedMotionBlurVisual(false) end
    end

    task.defer(function()
        pcall(function()
            if _G.VxyroImportedApplyLoaded then _G.VxyroImportedApplyLoaded() end
        end)
    end)
end

do
    -- ==================== SPACEDUELS STEAL BAR UI ====================
    -- Visual replacement only. Auto Steal logic and the original progressFill
    -- variable are intentionally preserved so all existing logic keeps working.
    local ibGui = Instance.new("ScreenGui")
    ibGui.Name = "LinxInfoBar"
    ibGui.ResetOnSpawn = false
    ibGui.IgnoreGuiInset = true
    ibGui.DisplayOrder = 12

    pcall(function()
        if gethui then ibGui.Parent = gethui() end
    end)
    if not ibGui.Parent then
        pcall(function() ibGui.Parent = game:GetService("CoreGui") end)
    end
    if not ibGui.Parent then
        ibGui.Parent = LP:WaitForChild("PlayerGui")
    end

    local ACCENT = Color3.fromRGB(255, 255, 255)
    local ACCENT2 = Color3.fromRGB(180, 180, 180)
    local WHITE = Color3.fromRGB(255, 255, 255)
    local BG = Color3.fromRGB(0, 0, 0)
    local BG2 = Color3.fromRGB(10, 10, 10)
    local DIM = Color3.fromRGB(155, 155, 155)
    local TRACK = Color3.fromRGB(8, 8, 8)

    local infoBar = Instance.new("Frame", ibGui)
    infoBar.Name = "StealBar"
    infoBar.Size = UDim2.new(0, 360, 0, 82)
    infoBar.Position = UDim2.new(0.5, -180, 1, -96)
    do
        local sp = S.stealBarPos
        if type(sp) == "table" and tonumber(sp.xs) and tonumber(sp.ys) then
            infoBar.Position = UDim2.new(tonumber(sp.xs), tonumber(sp.xo) or 0, tonumber(sp.ys), tonumber(sp.yo) or 0)
        end
    end
    infoBar.BackgroundColor3 = BG
    infoBar.BackgroundTransparency = 0.04
    infoBar.BorderSizePixel = 0
    infoBar.Active = true
    infoBar.Visible = false
    corner(infoBar, 14)
    stroke(infoBar, ACCENT, 1.4, 0.45)
    local stealBloom = stroke(infoBar, ACCENT2, 5, 0.965)
    stealBloom.Name = "StealBarGlow"
    TS:Create(stealBloom, TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.89}):Play()
    local infoBarGrad = Instance.new("UIGradient", infoBar)
    infoBarGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(18, 18, 18)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(10, 10, 10)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
    })
    infoBarGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.0),
        NumberSequenceKeypoint.new(0.5, 0.12),
        NumberSequenceKeypoint.new(1, 0.0),
    })
    infoBarGrad.Rotation = 90
    pcall(function() if _G.__VxyroGlossAttach then _G.__VxyroGlossAttach(infoBar, {z=2, radius=14, thickness=1.55, bloomThickness=5.5}) end end)

    do
        local aura = Instance.new("Frame", ibGui)
        aura.Name = "SpaceDuelsStatusAura"
        aura.Size = UDim2.new(0, 376, 0, 94)
        aura.Position = UDim2.new(infoBar.Position.X.Scale, infoBar.Position.X.Offset - 8, infoBar.Position.Y.Scale, infoBar.Position.Y.Offset - 6)
        aura.BackgroundColor3 = ACCENT
        aura.BackgroundTransparency = 0.96
        aura.BorderSizePixel = 0
        aura.ZIndex = 1
        corner(aura, 18)
        stroke(aura, ACCENT2, 1.2, 0.9)
        infoBar:GetPropertyChangedSignal("Position"):Connect(function()
            if aura and aura.Parent then
                aura.Position = UDim2.new(infoBar.Position.X.Scale, infoBar.Position.X.Offset - 8, infoBar.Position.Y.Scale, infoBar.Position.Y.Offset - 6)
            end
        end)
        task.spawn(function()
            while aura and aura.Parent do
                local pulse = (math.sin(tick() * 2.6) + 1) * 0.5
                aura.BackgroundTransparency = 0.975 - pulse * 0.025
                task.wait(0.05)
            end
        end)
    end

    do
        local pbScale = Instance.new("UIScale", infoBar)
        pbScale.Name = "PBScale"
        _G.__VersincProgressBarScaleObj = pbScale
        if _G._VersincApplyProgressBarScale then
            _G._VersincApplyProgressBarScale(S.progressBarScale or 100)
        else
            pbScale.Scale = math.clamp((tonumber(S.progressBarScale) or 100), 50, 200) / 100
        end
    end

    -- Top row
    local topRow = Instance.new("Frame", infoBar)
    topRow.Name = "TopRow"
    topRow.Size = UDim2.new(1, -20, 0, 22)
    topRow.Position = UDim2.new(0, 10, 0, 5)
    topRow.BackgroundTransparency = 1
    topRow.BorderSizePixel = 0
    topRow.ZIndex = 10

    local diamond = Instance.new("Frame", topRow)
    diamond.Size = UDim2.new(0, 8, 0, 8)
    diamond.AnchorPoint = Vector2.new(0, 0.5)
    diamond.Position = UDim2.new(0, 4, 0.5, 0)
    diamond.Rotation = 45
    diamond.BackgroundColor3 = ACCENT2
    diamond.BorderSizePixel = 0
    diamond.ZIndex = 12
    corner(diamond, 2)

    local title = Instance.new("TextLabel", topRow)
    title.Size = UDim2.new(0, 94, 1, 0)
    title.Position = UDim2.new(0, 18, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ZERO HUB"
    title.TextColor3 = WHITE
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 12
    local titleGrad = Instance.new("UIGradient", title)
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, WHITE),
        ColorSequenceKeypoint.new(1, ACCENT2),
    })

    local div1 = Instance.new("Frame", topRow)
    div1.Size = UDim2.new(0, 1, 0, 12)
    div1.AnchorPoint = Vector2.new(0, 0.5)
    div1.Position = UDim2.new(0, 116, 0.5, 0)
    div1.BackgroundColor3 = ACCENT
    div1.BackgroundTransparency = 0.55
    div1.BorderSizePixel = 0
    div1.ZIndex = 12

    local fpsLbl = Instance.new("TextLabel", topRow)
    fpsLbl.Size = UDim2.new(0, 92, 1, 0)
    fpsLbl.Position = UDim2.new(0, 124, 0, 0)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS --"
    fpsLbl.TextColor3 = DIM
    fpsLbl.Font = Enum.Font.GothamBold
    fpsLbl.TextSize = 10
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
    fpsLbl.ZIndex = 12

    local div2 = Instance.new("Frame", topRow)
    div2.Size = UDim2.new(0, 1, 0, 12)
    div2.AnchorPoint = Vector2.new(0, 0.5)
    div2.Position = UDim2.new(0, 221, 0.5, 0)
    div2.BackgroundColor3 = ACCENT
    div2.BackgroundTransparency = 0.55
    div2.BorderSizePixel = 0
    div2.ZIndex = 12

    local pingLbl = Instance.new("TextLabel", topRow)
    pingLbl.Size = UDim2.new(0, 100, 1, 0)
    pingLbl.Position = UDim2.new(0, 229, 0, 0)
    pingLbl.BackgroundTransparency = 1
    pingLbl.Text = "PING --ms"
    pingLbl.TextColor3 = DIM
    pingLbl.Font = Enum.Font.GothamBold
    pingLbl.TextSize = 10
    pingLbl.TextXAlignment = Enum.TextXAlignment.Left
    pingLbl.ZIndex = 12

    -- Bottom gauge plate
    local btm = Instance.new("Frame", infoBar)
    btm.Name = "StealSection"
    btm.Size = UDim2.new(1, -20, 0, 46)
    btm.Position = UDim2.new(0, 10, 0, 28)
    btm.BackgroundColor3 = BG2
    btm.BackgroundTransparency = 0.18
    btm.BorderSizePixel = 0
    btm.ZIndex = 9
    corner(btm, 10)
    stroke(btm, ACCENT, 1, 0.62)

    local statusDot = Instance.new("Frame", btm)
    statusDot.Size = UDim2.new(0, 7, 0, 7)
    statusDot.AnchorPoint = Vector2.new(0.5, 0.5)
    statusDot.Position = UDim2.new(0, 15, 0, 10)
    statusDot.Rotation = 45
    statusDot.BackgroundColor3 = DIM
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 15
    corner(statusDot, 2)

    progressRadLbl = Instance.new("TextLabel", btm)
    progressRadLbl.Size = UDim2.new(1, -138, 0, 13)
    progressRadLbl.Position = UDim2.new(0, 28, 0, 3)
    progressRadLbl.BackgroundTransparency = 1
    progressRadLbl.Text = "AUTO STEAL  [STANDBY]"
    progressRadLbl.TextColor3 = COLORS.white
    progressRadLbl.Font = Enum.Font.GothamBold
    progressRadLbl.TextSize = 10
    progressRadLbl.TextXAlignment = Enum.TextXAlignment.Left
    progressRadLbl.TextTruncate = Enum.TextTruncate.AtEnd
    progressRadLbl.ZIndex = 15

    local pctBadge = Instance.new("Frame", btm)
    pctBadge.Name = "PctBadge"
    pctBadge.Size = UDim2.new(0, 58, 0, 14)
    pctBadge.Position = UDim2.new(1, -68, 0, 3)
    pctBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    pctBadge.BackgroundTransparency = 0.45
    pctBadge.BorderSizePixel = 0
    pctBadge.ZIndex = 15
    corner(pctBadge, 5)
    stroke(pctBadge, ACCENT2, 1, 0.48)

    progressPct = Instance.new("TextLabel", pctBadge)
    progressPct.Size = UDim2.new(1, 0, 1, 0)
    progressPct.BackgroundTransparency = 1
    progressPct.Text = "0%"
    progressPct.TextColor3 = ACCENT2
    progressPct.Font = Enum.Font.GothamBlack
    progressPct.TextSize = 10
    progressPct.TextXAlignment = Enum.TextXAlignment.Center
    progressPct.ZIndex = 16

    -- Thick high-tech track from SpaceDuels HUD
    local pTrack = Instance.new("Frame", btm)
    pTrack.Name = "Track"
    pTrack.Size = UDim2.new(1, -20, 0, 18)
    pTrack.Position = UDim2.new(0, 10, 0, 20)
    pTrack.BackgroundColor3 = TRACK
    pTrack.BackgroundTransparency = 0.05
    pTrack.BorderSizePixel = 0
    pTrack.ZIndex = 11
    pTrack.ClipsDescendants = false
    corner(pTrack, 9)
    local trackStroke = stroke(pTrack, ACCENT, 1.3, 0.5)
    local pTrackGrad = Instance.new("UIGradient", pTrack)
    pTrackGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(22, 22, 22)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0)),
    })
    pTrackGrad.Rotation = 0

    local trackInner = Instance.new("Frame", pTrack)
    trackInner.Size = UDim2.new(1, -6, 0, 1)
    trackInner.Position = UDim2.new(0, 3, 0, 1)
    trackInner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    trackInner.BackgroundTransparency = 0.3
    trackInner.BorderSizePixel = 0
    trackInner.ZIndex = 12

    local clip = Instance.new("Frame", pTrack)
    clip.Name = "Clipper"
    clip.Size = UDim2.new(1, 0, 1, 0)
    clip.BackgroundTransparency = 1
    clip.BorderSizePixel = 0
    clip.ClipsDescendants = true
    clip.ZIndex = 13
    corner(clip, 9)

    local fillGlow = Instance.new("Frame", clip)
    fillGlow.Name = "FillGlow"
    fillGlow.Size = UDim2.new(0, 0, 1, 8)
    fillGlow.Position = UDim2.new(0, 0, 0.5, -4)
    fillGlow.BackgroundColor3 = ACCENT2
    fillGlow.BackgroundTransparency = 0.6
    fillGlow.BorderSizePixel = 0
    fillGlow.ZIndex = 13
    corner(fillGlow, 9)

    progressFill = Instance.new("Frame", clip)
    progressFill.Name = "Fill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = ACCENT
    progressFill.BackgroundTransparency = 0
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 14
    progressFill.ClipsDescendants = true
    corner(progressFill, 9)

    local fillGrad = Instance.new("UIGradient", progressFill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.25, ACCENT),
        ColorSequenceKeypoint.new(0.55, ACCENT2),
        ColorSequenceKeypoint.new(0.80, WHITE),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 255, 255)),
    })
    fillGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    0.35),
        NumberSequenceKeypoint.new(0.15, 0.0),
        NumberSequenceKeypoint.new(0.85, 0.0),
        NumberSequenceKeypoint.new(1,    0.25),
    })

    local shine = Instance.new("Frame", progressFill)
    shine.Name = "Shine"
    shine.AnchorPoint = Vector2.new(0.5, 0.5)
    shine.Position = UDim2.new(-0.25, 0, 0.5, 0)
    shine.Size = UDim2.new(0.28, 0, 2.5, 0)
    shine.BackgroundColor3 = WHITE
    shine.BackgroundTransparency = 0.35
    shine.BorderSizePixel = 0
    shine.ZIndex = 16
    corner(shine, 999)
    local shineGrad = Instance.new("UIGradient", shine)
    shineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.05),
        NumberSequenceKeypoint.new(1, 1),
    })

    local shine2 = Instance.new("Frame", progressFill)
    shine2.Name = "Shine2"
    shine2.AnchorPoint = Vector2.new(0.5, 0.5)
    shine2.Position = UDim2.new(-0.45, 0, 0.5, 0)
    shine2.Size = UDim2.new(0.16, 0, 2.2, 0)
    shine2.BackgroundColor3 = WHITE
    shine2.BackgroundTransparency = 0.6
    shine2.BorderSizePixel = 0
    shine2.ZIndex = 16
    corner(shine2, 999)
    local shineGrad2 = Instance.new("UIGradient", shine2)
    shineGrad2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })

    -- Milestones / cell dividers
    local marks = {}
    for i = 1, 9 do
        local line = Instance.new("Frame", clip)
        line.Name = "CellDiv_" .. i
        line.Size = UDim2.new(0, 1, 1, 0)
        line.Position = UDim2.new(i * 0.1, 0, 0, 0)
        line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        line.BackgroundTransparency = 0.45
        line.BorderSizePixel = 0
        line.ZIndex = 17
    end
    for _, pct in ipairs({0.25, 0.5, 0.75}) do
        local marker = Instance.new("Frame", pTrack)
        marker.Name = "Milestone_" .. math.floor(pct * 100)
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.Position = UDim2.new(pct, 0, 0.5, 0)
        marker.Size = UDim2.new(0, 2, 1, 6)
        marker.BackgroundColor3 = ACCENT2
        marker.BackgroundTransparency = 0.7
        marker.BorderSizePixel = 0
        marker.ZIndex = 18
        corner(marker, 99)
        table.insert(marks, {obj = marker, pct = pct})
    end

    -- Leading laser bead + rings
    local headRing2 = Instance.new("Frame", pTrack)
    headRing2.AnchorPoint = Vector2.new(0.5, 0.5)
    headRing2.Size = UDim2.new(0, 26, 0, 26)
    headRing2.Position = UDim2.new(0, 0, 0.5, 0)
    headRing2.BackgroundTransparency = 1
    headRing2.BorderSizePixel = 0
    headRing2.ZIndex = 20
    headRing2.Visible = false
    corner(headRing2, 99)
    local ring2Stroke = stroke(headRing2, ACCENT2, 1.2, 0.7)

    local headRing1 = Instance.new("Frame", pTrack)
    headRing1.AnchorPoint = Vector2.new(0.5, 0.5)
    headRing1.Size = UDim2.new(0, 20, 0, 20)
    headRing1.Position = UDim2.new(0, 0, 0.5, 0)
    headRing1.BackgroundTransparency = 1
    headRing1.BorderSizePixel = 0
    headRing1.ZIndex = 21
    headRing1.Visible = false
    corner(headRing1, 99)
    local ring1Stroke = stroke(headRing1, ACCENT2, 1.5, 0.3)

    local headBead = Instance.new("Frame", pTrack)
    headBead.AnchorPoint = Vector2.new(0.5, 0.5)
    headBead.Size = UDim2.new(0, 16, 0, 16)
    headBead.Position = UDim2.new(0, 0, 0.5, 0)
    headBead.BackgroundColor3 = WHITE
    headBead.BackgroundTransparency = 0.03
    headBead.BorderSizePixel = 0
    headBead.ZIndex = 22
    headBead.Visible = false
    corner(headBead, 99)
    local beadStroke = stroke(headBead, ACCENT2, 2.4, 0.15)

    local filament = Instance.new("Frame", headBead)
    filament.Size = UDim2.new(0, 1.5, 0, 26)
    filament.AnchorPoint = Vector2.new(0.5, 0.5)
    filament.Position = UDim2.new(0.5, 0, 0.5, 0)
    filament.BackgroundColor3 = WHITE
    filament.BackgroundTransparency = 0.25
    filament.BorderSizePixel = 0
    filament.ZIndex = 23

    local sparks = {}
    for i = 1, 6 do
        local spark = Instance.new("Frame", pTrack)
        spark.AnchorPoint = Vector2.new(0.5, 0.5)
        spark.Size = UDim2.new(0, 3, 0, 3)
        spark.BackgroundColor3 = (i % 2 == 0) and ACCENT2 or WHITE
        spark.BackgroundTransparency = 1
        spark.BorderSizePixel = 0
        spark.ZIndex = 19
        corner(spark, 99)
        sparks[i] = spark
    end

    local flash = Instance.new("Frame", clip)
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = WHITE
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.ZIndex = 24
    corner(flash, 9)

    local shock = Instance.new("Frame", pTrack)
    shock.AnchorPoint = Vector2.new(0.5, 0.5)
    shock.Position = UDim2.new(1, 0, 0.5, 0)
    shock.Size = UDim2.new(0, 12, 0, 12)
    shock.BackgroundTransparency = 1
    shock.BorderSizePixel = 0
    shock.ZIndex = 25
    corner(shock, 99)
    local shockStroke = stroke(shock, WHITE, 2.3, 1)

    -- Mark every Steal Bar border as theme-driven so the accent can be
    -- refreshed instantly when the user changes the main theme.
    for _,obj in ipairs(ibGui:GetDescendants()) do
        if obj:IsA("UIStroke") then
            obj:SetAttribute("StealAccent", true)
        end
    end

    local function applyStealAccent(col)
        col = col or S.themeColor or COLORS.accent or ACCENT
        ACCENT = col
        ACCENT2 = Color3.new(col.R * 0.62 + 0.18, col.G * 0.62 + 0.18, col.B * 0.62 + 0.18)
        FILL_LIGHT = col
        FILL_DARK = Color3.new(col.R * 0.45, col.G * 0.45, col.B * 0.45)
        pcall(function()
            diamond.BackgroundColor3 = ACCENT2
            div1.BackgroundColor3 = ACCENT
            div2.BackgroundColor3 = ACCENT
            for _,obj in ipairs(ibGui:GetDescendants()) do
                if obj:IsA("UIStroke") and obj:GetAttribute("StealAccent") then
                    obj.Color = ACCENT2
                    if obj.Parent == infoBar or obj.Parent == btm or obj == trackStroke then
                        obj.Color = ACCENT
                    end
                end
            end
            trackStroke.Color = ACCENT
            progressFill.BackgroundColor3 = FILL_LIGHT
            fillGlow.BackgroundColor3 = ACCENT2
            ring1Stroke.Color = ACCENT2
            ring2Stroke.Color = ACCENT2
            beadStroke.Color = ACCENT2
            stealBloom.Color = ACCENT2
            fillGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                ColorSequenceKeypoint.new(0.22, ACCENT2),
                ColorSequenceKeypoint.new(0.55, FILL_LIGHT),
                ColorSequenceKeypoint.new(0.86, WHITE),
                ColorSequenceKeypoint.new(1, WHITE),
            })
            titleGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, WHITE),
                ColorSequenceKeypoint.new(1, ACCENT2),
            })
        end)
    end
    _G._VxyroStealBarApplyAccent = applyStealAccent
    applyStealAccent(S.themeColor or COLORS.accent or ACCENT)

    local function pingMs()
        local ms = 0
        pcall(function()
            local Stats = game:GetService("Stats")
            local item = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            if item then
                local v = item:GetValue()
                if type(v) == "number" then ms = math.floor(v + 0.5) end
            end
        end)
        if ms <= 0 then
            pcall(function() ms = math.floor(((LP:GetNetworkPing() or 0) * 1000) + 0.5) end)
        end
        return math.max(0, ms)
    end

    local function clockText()
        local t = os.date("*t")
        local h, ap = t.hour, "AM"
        if h >= 12 then ap = "PM"; if h > 12 then h = h - 12 end end
        if h == 0 then h = 12 end
        return string.format("%d:%02d %s", h, t.min, ap)
    end

    local function execName()
        local name
        pcall(function() if identifyexecutor then local a, b = identifyexecutor(); name = a or b end end)
        if (not name or name == "") then
            pcall(function() if getexecutorname then name = getexecutorname() end end)
        end
        if type(name) ~= "string" or name == "" then name = "Unknown" end
        name = tostring(name):gsub("^%s+", ""):gsub("%s+$", "")
        if #name > 12 then name = name:sub(1, 12) end
        return name
    end

    local function infoText()
        return "RAD: " .. tostring(Steal.StealRadius) .. "  DUR: " .. tostring(Steal.StealDuration) .. "s"
    end

    local dragDown, dragStart, startPos, dragMoved = false, nil, nil, false
    local function persistStealBar()
        local p = infoBar.Position
        S.stealBarPos = {xs = p.X.Scale, xo = p.X.Offset, ys = p.Y.Scale, yo = p.Y.Offset}
        pcall(function() if F.saveConfig then F.saveConfig(true) end end)
    end
    infoBar.InputBegan:Connect(function(inp)
        if S.guiLocked == true then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragDown = true
            dragMoved = false
            dragStart = inp.Position
            startPos = infoBar.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragDown = false
                    if dragMoved then persistStealBar() end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragDown and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            if S.guiLocked == true then dragDown = false; return end
            local d = inp.Position - dragStart
            dragMoved = true
            infoBar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local lastProgress = 0
    local sparkTick = 0
    local lastHudUpdate = 0
    RunService.Heartbeat:Connect(function(dt)
        if not infoBar or not infoBar.Parent then return end
        local now = tick()
        local visible = autoStealEnabled == true
        infoBar.Visible = visible
        if not visible then
            headBead.Visible = false
            headRing1.Visible = false
            headRing2.Visible = false
            return
        end

        if now - lastHudUpdate >= 0.20 then
            lastHudUpdate = now
            local fps = math.floor(1 / math.max(dt, 1e-4))
            fpsLbl.Text = "FPS " .. tostring(fps)
            pingLbl.Text = "PING " .. tostring(pingMs()) .. "ms"
            progressRadLbl.Text = infoText()
        end

        diamond.Rotation = 45 + math.sin(now * 3) * 5
        local progress = 0
        pcall(function()
            progress = math.clamp((progressFill.Size.X.Scale or 0), 0, 1)
        end)

        if progress > 0.005 or isCurrentlyStealing then
            local p = math.clamp(progress, 0, 1)
            fillGlow.Size = UDim2.new(p, 0, 1, 8)
            fillGlow.BackgroundTransparency = 0.45 + math.sin(now * 11) * 0.12
            fillGrad.Rotation = math.sin(now * 4.5) * 30

            headBead.Visible = p > 0.015
            headRing1.Visible = p > 0.015
            headRing2.Visible = p > 0.015
            if headBead.Visible then
                headBead.Position = UDim2.new(p, 0, 0.5, 0)
                headRing1.Position = headBead.Position
                headRing2.Position = headBead.Position
                local s1 = 15 + (math.sin(now * 15) + 1) * 1.5
                headBead.Size = UDim2.new(0, s1, 0, s1)
                beadStroke.Transparency = 0.08 + math.sin(now * 12) * 0.10
                ring1Stroke.Transparency = 0.22 + math.sin(now * 10) * 0.18
                ring2Stroke.Transparency = 0.5 + math.sin(now * 8) * 0.18
            end

            sparkTick = sparkTick + dt
            for idx, spark in ipairs(sparks) do
                local off = ((sparkTick * 2.2 + idx * 0.11) % 1)
                local sx = p - off * 0.22
                if sx > 0 then
                    spark.Visible = true
                    spark.Position = UDim2.new(sx, 0, 0.5, math.sin(now * 18 + idx) * 4)
                    spark.BackgroundTransparency = 0.15 + off * 0.8
                else
                    spark.Visible = false
                end
            end

            shine.Position = UDim2.new((now * 1.35) % 1.6 - 0.3, 0, 0.5, 0)
            shine2.Position = UDim2.new(((now + 0.35) * 0.95) % 1.7 - 0.35, 0, 0.5, 0)
            shine.Visible = true
            shine2.Visible = true

            trackStroke.Color = ACCENT2
            trackStroke.Transparency = 0.25 + math.sin(now * 7) * 0.18

            statusDot.BackgroundColor3 = ACCENT2
            statusDot.BackgroundTransparency = (math.sin(now * 12) + 1) * 0.10

            for _, item in ipairs(marks) do
                if p >= item.pct then
                    item.obj.BackgroundColor3 = WHITE
                    item.obj.BackgroundTransparency = 0.12
                else
                    item.obj.BackgroundColor3 = ACCENT2
                    item.obj.BackgroundTransparency = 0.7
                end
            end

            if progress >= 0.99 and lastProgress < 0.99 then
                flash.BackgroundTransparency = 0.05
                pcall(function()
                    TS:Create(flash, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                    shock.Size = UDim2.new(0, 12, 0, 12)
                    shockStroke.Transparency = 0.1
                    TS:Create(shock, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 48, 0, 48)}):Play()
                    TS:Create(shockStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Transparency = 1}):Play()
                end)
            end
        else
            fillGlow.BackgroundTransparency = 1
            shine.Visible = false
            shine2.Visible = false
            for _, spark in ipairs(sparks) do spark.Visible = false end
            headBead.Visible = false
            headRing1.Visible = false
            headRing2.Visible = false
        end

        local pct = math.floor(progress * 100)
        progressPct.Text = tostring(pct) .. "%"
        progressPct.TextColor3 = progress >= 1 and WHITE or ACCENT2
        lastProgress = progress
    end)
end end function F.loadConfigKeys() local raw = nil
local function readExisting(path)
    if not _readfile then return nil end
    local ok, data = pcall(_readfile, path)
    if ok and type(data) == "string" and data ~= "" then return data end
    return nil
end
raw = readExisting(CONFIG_FILE) or readExisting(CONFIG_FILE_LEGACY)
if not raw or raw == "" then return end local ok,cfg=pcall(function() return HS:JSONDecode(raw) end) if not ok or not cfg then return end _savedCfg=cfg
_G.VxyroCustomFontSelected = (type(cfg.customFontSelected) == "string" and cfg.customFontSelected ~= "") and cfg.customFontSelected or (_G.VxyroCustomFontSelected or "Default")
_G.VxyroCustomFontEnabled = cfg.customFontEnabled == true
local function lk(e,d) if type(d)~="table" then return end;if d.kb and Enum.KeyCode[d.kb] then e.kb=Enum.KeyCode[d.kb] end;if d.gp and Enum.KeyCode[d.gp] then e.gp=Enum.KeyCode[d.gp] end end
lk(KB.DropBrainrot,cfg.dropBrainrotKey);lk(KB.AutoLeft,cfg.autoLeftKey);lk(KB.AutoRight,cfg.autoRightKey); lk(KB.AutoBat,cfg.autoBatKey);lk(KB.TPBat,cfg.tpBatKey);lk(KB.LaggerToggle,cfg.laggerToggleKey); lk(KB.TPFloor,cfg.tpFloorKey);lk(KB.InstaReset,cfg.instaResetKey);lk(KB.GuiHide,cfg.guiHideKey);lk(KB.SpeedToggle,cfg.speedToggleKey) if cfg.normalSpeed then NS=cfg.normalSpeed end if cfg.carrySpeed then CS=cfg.carrySpeed end if cfg.selectedStealMode == "Semi" or cfg.selectedStealMode == "Normal" then selectedStealMode = cfg.selectedStealMode end if type(cfg.aceStealRadii)=="table" then
AceStealRadii.Normal = tonumber(cfg.aceStealRadii.Normal) or AceStealRadii.Normal; AceStealRadii.Semi = tonumber(cfg.aceStealRadii.Semi) or AceStealRadii.Semi end if cfg.grabRadius and type(cfg.grabRadius)=="number" then autoStealRadius=cfg.grabRadius; Steal.StealRadius=cfg.grabRadius elseif selectedStealMode=="Semi" then autoStealRadius=AceStealRadii.Semi; Steal.StealRadius=autoStealRadius else autoStealRadius=AceStealRadii.Normal; Steal.StealRadius=autoStealRadius end if cfg.stealDuration and type(cfg.stealDuration)=="number" and cfg.stealDuration >= 0.1 then
Steal.StealDuration = cfg.stealDuration end if cfg.autoGrabStopEnabled ~= nil then autoGrabStopEnabled = cfg.autoGrabStopEnabled == true; Steal.AutoGrabStopEnabled = autoGrabStopEnabled end if cfg.autoGrabStopTime and type(cfg.autoGrabStopTime)=="number" and cfg.autoGrabStopTime > 0 then autoGrabStopTime = cfg.autoGrabStopTime; Steal.AutoGrabStopTime = cfg.autoGrabStopTime end if cfg.autoGrabDelayRadius and type(cfg.autoGrabDelayRadius)=="number" and cfg.autoGrabDelayRadius > 0 then autoGrabDelayRadius = cfg.autoGrabDelayRadius; Steal.AutoGrabDelayRadius = cfg.autoGrabDelayRadius end
Steal.StealRadius = tonumber(autoStealRadius) or Steal.StealRadius or 20 if cfg.laggerSpeed and type(cfg.laggerSpeed)=="number" then S.LAGGER_SPEED=cfg.laggerSpeed end if cfg.laggerCarrySpeed and type(cfg.laggerCarrySpeed)=="number" then S.LAGGER_CARRY_SPEED=cfg.laggerCarrySpeed end if cfg.autoTPHeight and type(cfg.autoTPHeight)=="number" then S.autoTPHeight=cfg.autoTPHeight end if cfg.autoSwing~=nil then S.autoSwingEnabled=cfg.autoSwing==true end if cfg.guiScale and type(cfg.guiScale)=="number" then task.defer(function()
if _G._VersincApplyGuiScale then _G._VersincApplyGuiScale(cfg.guiScale, true) end end) end if cfg.autoSaveEnabled ~= nil then S.autoSaveEnabled = cfg.autoSaveEnabled == true else S.autoSaveEnabled = true end if cfg.toggleNotifEnabled ~= nil then S.toggleNotifEnabled = cfg.toggleNotifEnabled == true else S.toggleNotifEnabled = true end _G.VyxroToggleNotifEnabled = S.toggleNotifEnabled if cfg.aimbotSpeed and type(cfg.aimbotSpeed) == "number" and cfg.aimbotSpeed > 0 then AIMBOT_SPEED = cfg.aimbotSpeed end tpBatMode = 1 if KB.TPBat.kb then TP_BAT_KEY = KB.TPBat.kb end if KB.TPBat.gp then TP_BAT_CONTROLLER = KB.TPBat.gp end
if cfg.tpBatLegacyKey and Enum.KeyCode[cfg.tpBatLegacyKey] and not (cfg.tpBatKey and type(cfg.tpBatKey)=="table") then TP_BAT_KEY = Enum.KeyCode[cfg.tpBatLegacyKey]; KB.TPBat.kb = TP_BAT_KEY end if type(cfg.mobileButtonPositions) == "table" then _G.VersincMobileButtonPositions = cfg.mobileButtonPositions end if cfg.mobileButtonScale and type(cfg.mobileButtonScale) == "number" then S.mobileButtonScale = cfg.mobileButtonScale end if cfg.hideMobileButtons ~= nil then S.hideMobileButtons = cfg.hideMobileButtons == true end if cfg.allLockButtons ~= nil then
S.allLockButtons = cfg.allLockButtons == true pcall(function() if VS and VS.setAllLockVisual then VS.setAllLockVisual(S.allLockButtons) end end) end if cfg.lockMobileButtons ~= nil then S.lockMobileButtons = cfg.lockMobileButtons == true end if cfg.moveButtons ~= nil then S.moveButtons = cfg.moveButtons == true end if type(cfg.stealBarPos) == "table" then S.stealBarPos = cfg.stealBarPos end if cfg.progressBarScale ~= nil then S.progressBarScale = math.clamp(tonumber(cfg.progressBarScale) or 100, 50, 200)
pcall(function() if _G._VersincApplyProgressBarScale then _G._VersincApplyProgressBarScale(S.progressBarScale) end end)
if type(cfg.avatarChanger) == "table" then S.avatarChanger = cfg.avatarChanger end
if cfg.avaPresetEnabled ~= nil then S.avaPresetEnabled = cfg.avaPresetEnabled == true end
if type(cfg.avaPresetName) == "string" then S.avaPresetName = cfg.avaPresetName end
end end function F.loadConfigState() local cfg=_savedCfg;if not cfg then cfg={} end
-- [FEATURESAVE] Prefer the canonical main config. The dedicated feature file is only
-- a fallback for configs created by older builds.
cfg = _savedCfg or cfg
if type(cfg.features) ~= "table" then
    pcall(function() F.loadFeatureConfig() end)
    cfg = _savedCfg or cfg
end
-- [SAVEFIX] Imported features must be restored AFTER buildGui(), because the GUI/module
-- initializers set their runtime defaults during construction.
do
    local fcfg = type(cfg.features) == "table" and cfg.features or cfg
    S.customToolsEnabled = fcfg.customToolsEnabled == true
    S.customSoundsEnabled = fcfg.customSoundsEnabled == true
    S.customToolSkinBat = tostring(fcfg.customToolSkinBat or "DiamondSword")
    S.customToolSkinMedusa = tostring(fcfg.customToolSkinMedusa or "GoldenDesertEagle")
    S.vividGraphicsEnabled = fcfg.vividGraphicsEnabled == true
    if type(fcfg.vividSettings) == "table" then
        S.vividSettings = {
            saturation = math.clamp(tonumber(fcfg.vividSettings.saturation) or 0.6, 0, 2),
            bloomIntensity = math.clamp(tonumber(fcfg.vividSettings.bloomIntensity) or 0.8, 0, 3),
            bloomSize = math.clamp(tonumber(fcfg.vividSettings.bloomSize) or 24, 1, 56),
            sunIntensity = math.clamp(tonumber(fcfg.vividSettings.sunIntensity) or 0.2, 0, 1),
            dofFocus = math.clamp(tonumber(fcfg.vividSettings.dofFocus) or 25, 1, 100),
        }
    end
    S.motionBlurEnabled = fcfg.motionBlurEnabled == true
end
-- Restore imported modules immediately after their saved state is decoded.
-- This removes startup timing/race issues for Skin Tool and Custom Sound.
pcall(function()
    if _G.VxyroImportedApplyLoaded then _G.VxyroImportedApplyLoaded() end
end)
_G.__VxyroNukeOptimizerConfigWanted = (cfg.nukeOptimizer == true) if type(cfg.backgroundPhotoEnabled)=="boolean" then S.backgroundPhotoEnabled = cfg.backgroundPhotoEnabled task.defer(function() pcall(function() if _G._VersincSetBackgroundPhotoEnabled then _G._VersincSetBackgroundPhotoEnabled(S.backgroundPhotoEnabled, true) end if VS and VS.setBackgroundPhotoVisual then VS.setBackgroundPhotoVisual(S.backgroundPhotoEnabled) end end) end) end if cfg.bgId ~= nil then S.currentBgId = cfg.bgId or "" task.defer(function() if _G._VersincApplyBackground then _G._VersincApplyBackground(S.currentBgId, true) end end) end if type(cfg.bgIntensity)=="number" then S.bgIntensity = cfg.bgIntensity end if type(cfg.spaceBgIndex)=="number" then S.spaceBgIndex = math.clamp(math.floor(cfg.spaceBgIndex), 1, 6) end if cfg.floatHeight ~= nil then S.floatHeight = math.clamp(tonumber(cfg.floatHeight) or 18, 4, 80) end if cfg.floatSpeed ~= nil then S.floatSpeed = math.clamp(tonumber(cfg.floatSpeed) or 10, 2, 30) end if cfg.floatEnabled ~= nil then S.floatEnabled = cfg.floatEnabled == true end if cfg.themeName and type(cfg.themeName)=="string" then
    S.currentThemeName = "ZERO"
    S.themeColor = Color3.fromRGB(27, 96, 178)
    task.defer(function() if _G._VersincApplyTheme then _G._VersincApplyTheme("ZERO") end end)
end pcall(function() if _G.__VxyroSpaceRefreshUI then _G.__VxyroSpaceRefreshUI() end end) if S.floatEnabled == true then task.defer(function() pcall(function() F.startFloat() end) end) end if UI.normalBox then UI.normalBox.Text=tostring(NS) end if UI.carryBox then UI.carryBox.Text=tostring(CS) end if UI.radInput then UI.radInput.Text = tostring(autoStealRadius or Steal.StealRadius or 20) end if UI.stealDurInput then UI.stealDurInput.Text = tostring(Steal.StealDuration or 1.3) end if UI.stopTimeInput then UI.stopTimeInput.Text = tostring(autoGrabStopTime or Steal.AutoGrabStopTime or 1.00) end
if UI.delayRadInput then UI.delayRadInput.Text = tostring(autoGrabDelayRadius or Steal.AutoGrabDelayRadius or 8) end if progressRadLbl then progressRadLbl.Text = string.format("Radius: %.0f", autoStealRadius or Steal.StealRadius or 20) end if UI.laggerBox then UI.laggerBox.Text=tostring(S.LAGGER_SPEED) end if UI.laggerCarryBox then UI.laggerCarryBox.Text=tostring(S.LAGGER_CARRY_SPEED) end if UI.autoTPHeightBox then UI.autoTPHeightBox.Text=tostring(S.autoTPHeight) end if VS.setAutoGrabStopVisual then pcall(function() VS.setAutoGrabStopVisual(autoGrabStopEnabled == true) end) end
task.spawn(function() task.wait(0.2) if cfg.antiRagdollMode and type(cfg.antiRagdollMode)=="number" then S.antiRagdollMode = (cfg.antiRagdollMode == 2) and 2 or 1 end if cfg.aimbotMode and type(cfg.aimbotMode)=="number" then S.aimbotMode = (cfg.aimbotMode == 2) and 2 or 1 end if cfg.antiRagdoll then S.antiRagdollEnabled=true if VS.setAntiRagVisual then VS.setAntiRagVisual(true) end task.wait(0.3); F.startAntiRagdoll() end if cfg.antiDieEnabled then S.antiDieEnabled = true if VS.setAntiDieVisual then VS.setAntiDieVisual(true) end F.startAntiDie() end if cfg.antiFlingShieldEnabled then
S.antiFlingShieldEnabled = true if VS.setAntiFlingVisual then VS.setAntiFlingVisual(true) end F.startAntiFlingShield() end if cfg.removeAccessories then S.removeAccessoriesEnabled = true if VS.setRemoveAccVisual then VS.setRemoveAccVisual(true) end F.startRemoveAccessories() end if cfg.infJumpMode == "manual" or cfg.infJumpMode == "hold" then S.infJumpMode = cfg.infJumpMode if UI.infJumpModeBtn then UI.infJumpModeBtn.Text = (S.infJumpMode == "manual") and "Manual" or "Hold" end end if cfg.infJump then infJumpEnabled = true if VS.setInfJumpVisual then VS.setInfJumpVisual(true) end
F.startInfJump() end if cfg.mirrorTPDown then F.setMirrorTPDown(true) if VS.setMirrorTPVisual then VS.setMirrorTPVisual(true) end end if cfg.aimbotSpeed and type(cfg.aimbotSpeed) == "number" and cfg.aimbotSpeed > 0 then AIMBOT_SPEED = cfg.aimbotSpeed if UI.aimbotSpeedBox then UI.aimbotSpeedBox.Text = tostring(AIMBOT_SPEED) end end -- Restore exactly one combat controller. New configs use combatMode; older configs
-- are inferred once so they cannot queue several mutually-exclusive modes.
do
    local combatMode = cfg.combatMode
    if type(combatMode) ~= "string" then
        if cfg.tpBat then combatMode = "tpBat"
        elseif cfg.autoRight then combatMode = "autoRight"
        elseif cfg.autoLeft then combatMode = "autoLeft"
        elseif cfg.aimbot then combatMode = "aimbot"
        elseif cfg.autoBat then combatMode = "autoBat"
        else combatMode = "none" end
    end
    _G.__VxyroCombatMode = combatMode
    if combatMode == "aimbot" and setAimbotState then
        local active = setAimbotState(true)
        if VS.setAimbotVisual then VS.setAimbotVisual(active == true) end
    elseif combatMode == "tpBat" and setTPBatState then
        setTPBatState(true)
    elseif combatMode == "autoLeft" and F.queueAutoLeftStart then
        local active = F.queueAutoLeftStart()
        if S.autoLeftSetVisual then S.autoLeftSetVisual(S.autoLeftEnabled == true) end
    elseif combatMode == "autoRight" and F.queueAutoRightStart then
        local active = F.queueAutoRightStart()
        if S.autoRightSetVisual then S.autoRightSetVisual(S.autoRightEnabled == true) end
    elseif combatMode == "autoBat" and F.queueAutoBatStart then
        F.queueAutoBatStart()
        if S.autoBatSetVisual then S.autoBatSetVisual(S.autoBatEnabled == true) end
    end
end
if cfg.antiBatBypass then S.antiBatBypassEnabled = true if F.startAimbotBypassAntiBat then pcall(F.startAimbotBypassAntiBat) end if VS.setAntiBatBypassVisual then VS.setAntiBatBypassVisual(true) end end if cfg.tpBat then if VS.setTPBatVisual then VS.setTPBatVisual(true) end if setTPBatState then setTPBatState(true) end end if UI and UI.aimbotModeBtn then UI.aimbotModeBtn.Text = ((S.aimbotMode or 1) == 2) and "MODE V2" or "MODE V1" end if cfg.autoStealEnabled then if VS.setInstaGrab then VS.setInstaGrab(true) end pcall(startAutoSteal) end if cfg.medusaCounter then S.medusaCounterEnabled=true;if VS.setMedusaVisual then VS.setMedusaVisual(true) end end if cfg.medusaReset or cfg.autoResetOnMedEnabled then
S.medusaResetEnabled=true; S.autoResetOnMedEnabled=true if VS.setMedusaResetVisual then VS.setMedusaResetVisual(true) end end if S.medusaCounterEnabled or S.medusaResetEnabled then F.setupMedusa(LP.Character) end if cfg.batCounter then S.batCounterEnabled=true;if VS.setBatCounterVisual then VS.setBatCounterVisual(true) end;S.startBatCounter() end if cfg.laggerMode then S.laggerToggled=true;S.speedMode=false;S.laggerPhase=cfg.laggerCarryMode and 2 or 1;F.refreshSpeedModeLabel() elseif cfg.carryMode then S.speedMode=false;F.toggleCarryMode() end if cfg.autoCarrySpeedEnabled then
S.autoCarrySpeedEnabled = true if S.setAutoCarrySpeedVisual then S.setAutoCarrySpeedVisual(true) end end if cfg.noPlayerCollisionEnabled then F.enableNoPlayerCollision() if VS.setNoPlayerCollisionVisual then VS.setNoPlayerCollisionVisual(true) end end if cfg.safeModeEnabled then S.safeModeEnabled = true if VS.setSafeModeVisual then VS.setSafeModeVisual(true) end end if cfg.autoTPEnabled then S.autoTPEnabled=true;if VS.setAutoTPVisual then VS.setAutoTPVisual(true) end;F.startAutoTP() end if VS.setAutoSwingVisual then VS.setAutoSwingVisual(S.autoSwingEnabled) end
if cfg.unwalkEnabled then S.unwalkEnabled=true;if VS.setUnwalkVisual then VS.setUnwalkVisual(true) end;task.spawn(function() task.wait(0.5);F.startUnwalk() end) end if cfg.keyboardOverlay then S.keyboardOverlayEnabled = true if VS.setKeyboardOverlayVisual then VS.setKeyboardOverlayVisual(true) end pcall(function() F.startKeyboardOverlay() end) end if cfg.antiLag then F.enableAntiLag();if VS.setAntiLagVisual then VS.setAntiLagVisual(true) end end
if cfg.stretchRez then enableStretchRez();if VS.setStretchRezVisual then VS.setStretchRezVisual(true) end end if cfg.showTracerEnabled then pcall(function() if F.clearTracers then F.clearTracers() end end) if VS.setShowTracerVisual then VS.setShowTracerVisual(true) end end if cfg.ragdollCountdownEnabled then F.setRagdollCountdown(true) if VS.setRagdollCdVisual then VS.setRagdollCdVisual(true) end end S.guiLocked = cfg.guiLocked and true or false if VS.setLockGuiVisual then VS.setLockGuiVisual(S.guiLocked) end if VS.setToggleNotifVisual then VS.setToggleNotifVisual(S.toggleNotifEnabled ~= false) end if type(cfg.hubPos) == "table" then S.hubPos = cfg.hubPos end
if type(cfg.miniPos) == "table" then S.miniPos = cfg.miniPos end if (S.hubPos or S.miniPos) and _G._VersincSetHubPos then pcall(function() _G._VersincSetHubPos(S.hubPos, S.miniPos) end) task.defer(function() pcall(function() _G._VersincSetHubPos(S.hubPos, S.miniPos) end) end) end if cfg.lockMobileButtons then S.lockMobileButtons = true if VS.setLockMobileButtonsVisual then VS.setLockMobileButtonsVisual(true) end end if cfg.hideMobileButtons then S.hideMobileButtons = true if VS.setHideMobileVisual then VS.setHideMobileVisual(true) end end if cfg.mobileButtonScale then
S.mobileButtonScale = tonumber(cfg.mobileButtonScale) or 0.80 end if type(cfg.mobileButtonPositions) == "table" then _G.VersincMobileButtonPositions = cfg.mobileButtonPositions end if cfg.autoResetOnMedEnabled then F.setAutoResetOnMed(true) if VS.setAutoResetOnMedVisual then VS.setAutoResetOnMedVisual(true) end end if cfg.lineESP or cfg.speedESP then if K7 then K7.lineESPEnabled = true; K7.speedESPEnabled = true end if VS.setLineESPVisual then VS.setLineESPVisual(true) end pcall(function() if K7 and K7.refreshESP then K7.refreshESP() end end) end if cfg.fovEnabled and K7 then
K7.fovEnabled = true if cfg.fovValue then K7.fovValue = tonumber(cfg.fovValue) or K7.fovValue end if VS.setFOVVisual then VS.setFOVVisual(true) end pcall(function() if K7.applyFOV then K7.applyFOV() end end) end if cfg.korbloxSide and type(cfg.korbloxSide)=="number" then korbloxSide = math.clamp(math.floor(cfg.korbloxSide), 1, 3) if K7 then K7.korbloxSide = korbloxSide end end if cfg.headless and K7 then K7.headlessEnabled = true if VS.setHeadlessVisual then VS.setHeadlessVisual(true) end task.spawn(function() local function applyH() local char = LP.Character if char and K7.applyHeadless then
pcall(K7.applyHeadless, char, true) end end task.wait(0.4); applyH(); task.wait(1.0); applyH() end) end if cfg.korblox and K7 then K7.korbloxEnabled = true if VS.setKorbloxVisual then VS.setKorbloxVisual(true) end task.spawn(function() local function applyK() local char = LP.Character if char and K7.applyKorblox then pcall(K7.applyKorblox, char, true) end end task.wait(0.5); applyK(); task.wait(1.2); applyK() end) end if cfg.bodyLock and K7 then K7.bodyLockEnabled = true if cfg.bodyLockRadius then K7.bodyLockRadius = tonumber(cfg.bodyLockRadius) or K7.bodyLockRadius end
if VS.setBodyLockVisual then VS.setBodyLockVisual(true) end pcall(function() if K7.startBodyLock then K7.startBodyLock() end end) end if K7 and cfg.animPack and type(cfg.animPack) == "string" then K7.animPackName = cfg.animPack if K7.ANIM_PACK_LIST then for i, n in ipairs(K7.ANIM_PACK_LIST) do if n == cfg.animPack then K7.animPackIndex = i break end end end if UI.animPackLbl then pcall(function() UI.animPackLbl.Text = K7.animPackName end) end end if cfg.animPackEnabled and K7 then K7.animPackEnabled = true if VS.setAnimPackVisual then VS.setAnimPackVisual(true) end task.spawn(function()
task.wait(0.6) pcall(function() if K7.applyAnimPack then K7.applyAnimPack(K7.animPackName) end end) task.wait(1.2) pcall(function() if K7.animPackEnabled and K7.applyAnimPack then K7.applyAnimPack(K7.animPackName) end end) end) end if cfg.skyTheme and K7 and K7.applySkyTheme then pcall(function() K7.applySkyTheme(cfg.skyTheme) end) end
    end) end S.introEnabled = S.introEnabled ~= false function F.playVyxroDuelIntro() if S.introEnabled == false then return end local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5) if not pg then return end
local old = pg:FindFirstChild("VyxroDuelIntro") if old then old:Destroy() end
if _VXYRO_LOW_END then
    local sg = Instance.new("ScreenGui")
    sg.Name = "VyxroDuelIntro"
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 9999
    sg.ResetOnSpawn = false
    sg.Parent = pg
    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.fromScale(1,1)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BorderSizePixel = 0
    local title = Instance.new("TextLabel", bg)
    title.AnchorPoint = Vector2.new(0.5,0.5)
    title.Position = UDim2.fromScale(0.5,0.48)
    title.Size = UDim2.fromOffset(340,40)
    title.BackgroundTransparency = 1
    title.Text = "Zero Hub"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 28
    task.delay(0.85, function() pcall(function() if _G._VxyroStopIntroMusic then _G._VxyroStopIntroMusic() end end); if sg and sg.Parent then sg:Destroy() end end)
    return
end
local sg = Instance.new("ScreenGui"); sg.Name = "VyxroDuelIntro"; sg.IgnoreGuiInset = true; sg.DisplayOrder = 9999; sg.ResetOnSpawn = false; sg.Parent = pg; local skipped = false local function skipIntro() if skipped then return end skipped = true; S.introEnabled = false pcall(function() if _G._VxyroStopIntroMusic then _G._VxyroStopIntroMusic() end end); pcall(function() if sg then sg:Destroy() end end) end
local bg = Instance.new("Frame", sg); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0); bg.BorderSizePixel = 0; local skipBtn = Instance.new("TextButton", bg); skipBtn.Name = "SkipIntro"; skipBtn.AnchorPoint = Vector2.new(1, 0); skipBtn.Position = UDim2.new(1, -16, 0, 16); skipBtn.Size = UDim2.new(0, 88, 0, 32); skipBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32); skipBtn.BackgroundTransparency = 0.15; skipBtn.BorderSizePixel = 0; skipBtn.Text = "SKIP"; skipBtn.TextColor3 = Color3.fromRGB(192, 198, 210); skipBtn.Font = Enum.Font.GothamBold; skipBtn.TextSize = 13; skipBtn.ZIndex = 20; Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 8); local skStroke = Instance.new("UIStroke", skipBtn); skStroke.Color = Color3.fromRGB(180, 180, 190); skStroke.Thickness = 1; skStroke.Transparency = 0.35; skipBtn.Activated:Connect(skipIntro); skipBtn.MouseButton1Click:Connect(skipIntro); local title = Instance.new("TextLabel", bg); title.AnchorPoint = Vector2.new(0.5, 0.5); title.Position = UDim2.new(0.5, 0, 0.48, 0); title.Size = UDim2.new(0, 420, 0, 40); title.BackgroundTransparency = 1; title.Text = "Zero Hub"; title.TextColor3 = Color3.fromRGB(192, 198, 210); title.Font = Enum.Font.GothamBlack; title.TextSize = 36; title.TextTransparency = 1; local sub = Instance.new("TextLabel", bg); sub.AnchorPoint = Vector2.new(0.5, 0); sub.Position = UDim2.new(0.5, 0, 0.48, 28); sub.Size = UDim2.new(0, 420, 0, 22); sub.BackgroundTransparency = 1; sub.Text = "ZERO HUB"; sub.TextColor3 = Color3.fromRGB(180, 190, 210); sub.Font = Enum.Font.GothamBold; sub.TextSize = 14; sub.TextTransparency = 1; local line = Instance.new("Frame", bg); line.AnchorPoint = Vector2.new(0.5, 0); line.Position = UDim2.new(0.5, 0, 0.48, 54); line.Size = UDim2.new(0, 0, 0, 2); line.BackgroundColor3 = Color3.fromRGB(220, 220, 230); line.BorderSizePixel = 0; TS:Create(title, TweenInfo.new(0.7, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play(); TS:Create(sub, TweenInfo.new(0.85, Enum.EasingStyle.Quad), { TextTransparency = 0.15 }):Play(); TS:Create(line, TweenInfo.new(0.9, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 140, 0, 2) }):Play()
task.delay(2.15, function() if skipped or not sg or not sg.Parent then return end TS:Create(title, TweenInfo.new(0.55), { TextTransparency = 1 }):Play(); TS:Create(sub, TweenInfo.new(0.55), { TextTransparency = 1 }):Play(); TS:Create(line, TweenInfo.new(0.55), { BackgroundTransparency = 1 }):Play(); TS:Create(bg, TweenInfo.new(0.65), { BackgroundTransparency = 1 }):Play() task.delay(0.7, function() pcall(function() if _G._VxyroStopIntroMusic then _G._VxyroStopIntroMusic() end end); if sg and sg.Parent then sg:Destroy() end end) end) end

-- ============================================================
-- INTRO MUSIC SAFETY WATCHDOG
-- Stops stale intro audio if the intro GUI is removed by another routine.
-- ============================================================
task.spawn(function()
    local seen = false
    local deadline = os.clock() + 12
    while os.clock() < deadline do
        local gui = LP:FindFirstChild("VyxroDuelIntro")
        if gui and gui.Parent then
            seen = true
        elseif seen then
            pcall(function() if _G._VxyroStopIntroMusic then _G._VxyroStopIntroMusic() end end)
            break
        end
        task.wait(0.08)
    end
end)

-- ============================================================
-- NUKE OPTIMIZER INTEGRATION
-- Added as a GUI-controlled feature; disabled by default.
-- ============================================================
-- Nuke Optimizer - extracted from Vasper_v3.5_AntiE01_AutoSteal_SEMI_CHECKED_FIXED.lua
-- Standalone extraction.
-- Toggle:
--   _G._nukeStart()  -> ON
--   _G._nukeStop()   -> OFF
--
-- Compatible with the original Minecraft-texture preservation hooks when
-- those functions/state exist. Otherwise it safely falls back to normal
-- optimization behavior.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

_G._NukeOn = _G._NukeOn or false
_G._NukeConns = _G._NukeConns or {}
_G._NukeThreads = _G._NukeThreads or {}

-- Minimal state fallback so this extracted module can run by itself.
local NukeState = _G.VasperNukeState or {}
NukeState.minecraftTextureEnabled = NukeState.minecraftTextureEnabled == true
_G.VasperNukeState = NukeState

local function IsMinecraftTextureObject(obj)
    if _G.IsMinecraftTextureObject then
        local ok, result = pcall(_G.IsMinecraftTextureObject, obj)
        if ok then return result end
    end
    return obj and type(obj.Name) == "string"
        and obj.Name:sub(1, #"__MC_V5__") == "__MC_V5__"
end

local function IsMinecraftLightingObject(obj)
    if _G.IsMinecraftLightingObject then
        local ok, result = pcall(_G.IsMinecraftLightingObject, obj)
        if ok then return result end
    end
    return obj and (obj.Name == "__MC_V5_Sky" or obj.Name == "__MC_V5_Atmos")
end

local function RefreshMinecraftAfterNuke()
    if not NukeState.minecraftTextureEnabled then return end
    local create = _G.minecraftCreateSkyAndAtmosphere or minecraftCreateSkyAndAtmosphere
    local repair = _G.integrityRepair or integrityRepair
    local scanFn = _G.scan or scan

    task.spawn(function()
        for _ = 1, 5 do
            if not NukeState.minecraftTextureEnabled then return end
            pcall(function()
                if create then create() end
            end)
            pcall(function()
                if repair then repair() end
            end)
            pcall(function()
                if scanFn then scanFn() end
            end)
            task.wait(0.22)
        end
    end)
end

_G._nukeStart = function()
        if _G._NukeOn then
            RefreshMinecraftAfterNuke()
            return
        end
        _G._NukeOn=true
        local Lighting=game:GetService("Lighting")
        local MaterialService=game:GetService("MaterialService")
        local XMin,XMax=-560,-240
        local ClothingClasses={"Shirt","Pants","ShirtGraphic","Accessory","Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
        local BASE_NAMES={"baseplate","spawnlocation","spawn location","spawn"}

        -- Objects created by Vyxro's Avatar Changer must survive Nuke Optimizer.
        -- Use an attribute marker so normal game accessories/clothes can still
        -- be optimized away. Descendants inherit protection via ancestor lookup.
        -- AVA PRESET / AVATAR CHANGER PROTECTION
        -- The preset uses _VxyroAvaPreset, while the Avatar Changer uses
        -- _VyxroAvatarChanger. Both markers must survive the nuke pass.
        local function IsVyxroAvatarObject(obj)
            local cur = obj
            while cur and cur ~= workspace do
                local marked = false
                pcall(function()
                    marked = cur:GetAttribute("_VyxroAvatarChanger") == true
                        or cur:GetAttribute("_VxyroAvaPreset") == true
                end)
                if marked then return true end
                cur = cur.Parent
            end
            return false
        end

        -- When Ava Preset is enabled, never optimize the local
        -- character through the global workspace scan. This is intentionally
        -- stronger than marker-only protection because HumanoidDescription
        -- may create Shirt/Pants/Accessory instances before the preset
        -- marker can be attached, which otherwise creates a race with Nuke.
        local function IsLocalAvaPresetObject(obj)
            if not obj or not LP.Character then return false end
            if S.avaPresetEnabled ~= true then return false end
            local ok, inside = pcall(function() return obj:IsDescendantOf(LP.Character) end)
            return ok and inside == true
        end

        local function IsVyxroProtectedLighting(obj)
            if not obj then return false end
            if obj.Name == "VyxroMotionBlur" then return true end
            if type(obj.Name) == "string" and obj.Name:sub(1,10) == "VyxroVivid" then return true end
            local marked = false
            pcall(function() marked = obj:GetAttribute("_VyxroImportedVivid") == true end)
            return marked
        end

        local function SafeDestroy(obj)
            if IsLocalAvaPresetObject(obj) then return end
            if IsVyxroAvatarObject(obj) or IsVyxroProtectedLighting(obj) then return end
            if IsMinecraftTextureObject(obj) or IsMinecraftLightingObject(obj) then return end
            if obj.Name=="Overhead" then return end
            pcall(function() obj:Destroy() end)
        end
        local function IsClothing(obj)
            for _,c in ipairs(ClothingClasses) do if obj:IsA(c) then return true end end
            return false
        end
        local function IsCharacterPart(obj)
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr.Character and obj:IsDescendantOf(plr.Character) then return true end
            end
            return false
        end
        local function IsOutOfRange(obj)
            if obj:IsA("BasePart") then local x=obj.Position.X; return x<XMin or x>XMax end
            return false
        end
        local function IsBase(obj)
            if not obj:IsA("BasePart") then return false end
            local nl=obj.Name:lower()
            for _,n in ipairs(BASE_NAMES) do if nl:find(n,1,true) then return true end end
            return false
        end
        local function IsInBase(obj)
            local p=obj.Parent
            while p and p~=workspace do
                if IsBase(p) then return true end
                p=p.Parent
            end
            return false
        end
        local function MakeTransparent(obj)
            if IsMinecraftTextureObject(obj) then return end
            pcall(function()
                if IsBase(obj) and not IsCharacterPart(obj) then
                    obj.Transparency=1; obj.CastShadow=false
                end
            end)
        end
        local function StripObject(obj)
            if IsVyxroAvatarObject(obj) or IsVyxroProtectedLighting(obj) then return end
            if IsMinecraftTextureObject(obj) or IsMinecraftLightingObject(obj) then return end
            pcall(function()
                if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                    SafeDestroy(obj)
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    pcall(function() obj.Enabled=false end)
                    SafeDestroy(obj)
                elseif obj:IsA("SurfaceAppearance") then
                    SafeDestroy(obj)
                elseif obj:IsA("BasePart") then
                    obj.CastShadow=false
                    -- Minecraft Texture owns the visual material/color behavior while active.
                    if not NukeState.minecraftTextureEnabled then
                        obj.Material=Enum.Material.Plastic
                        obj.MaterialVariant=""
                        obj.Reflectance=0
                    end
                end
            end)
        end
        local function CleanObject(obj)
            if IsVyxroAvatarObject(obj) or IsVyxroProtectedLighting(obj) then return end
            if IsMinecraftTextureObject(obj) or IsMinecraftLightingObject(obj) then return end
            pcall(function()
                if obj:IsA("SurfaceAppearance") then
                    -- Do not fight active Minecraft Texture on MeshParts.
                    if NukeState.minecraftTextureEnabled then return end
                    SafeDestroy(obj)
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    if not (obj.Name=="face" and obj.Parent and obj.Parent.Name=="Head") then SafeDestroy(obj) end
                elseif obj:IsA("SpecialMesh") then
                    obj.TextureId=""
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    SafeDestroy(obj)
                elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    SafeDestroy(obj)
                elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                    SafeDestroy(obj)
                elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
                    SafeDestroy(obj)
                elseif obj:IsA("BasePart") then
                    obj.CastShadow=false
                    if not NukeState.minecraftTextureEnabled then
                        obj.Material=Enum.Material.Plastic
                        obj.MaterialVariant=""
                        obj.Reflectance=0
                    end
                end
            end)
        end
        local function ApplyGreySky()
            pcall(function()
                if NukeState.minecraftTextureEnabled then
                    minecraftCreateSkyAndAtmosphere()
                    return
                end
                for _,obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("Sky") then obj:Destroy() end
                end
                local sky=Instance.new("Sky")
                sky.SkyboxBk=""; sky.SkyboxDn=""; sky.SkyboxFt=""; sky.SkyboxLf=""; sky.SkyboxRt=""; sky.SkyboxUp=""
                sky.CelestialBodiesShown=false
                sky.Name="_VezyNukeSky"
                sky.Parent=Lighting
            end)
        end
        local function OptimizeLighting()
            Lighting.GlobalShadows=false
            Lighting.FogEnd=9e9
            Lighting.FogStart=9e9
            Lighting.EnvironmentDiffuseScale=0
            Lighting.EnvironmentSpecularScale=0
            Lighting.Brightness=1.5
            Lighting.Ambient=Color3.fromRGB(60,60,60)
            for _,v in ipairs(Lighting:GetChildren()) do
                local preserve = (NukeState.minecraftTextureEnabled and IsMinecraftLightingObject(v)) or IsVyxroProtectedLighting(v)
                if not preserve and (v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("Clouds")) then
                    v:Destroy()
                end
            end
            ApplyGreySky()
        end
        local function ApplyTerrain()
            pcall(function() local T=workspace.Terrain; T.Decoration=false; T.WaterWaveSize=0; T.WaterWaveSpeed=0; T.WaterReflectance=0; T.WaterTransparency=1 end)
        end
        local function OptimizeCharacter(char)
            if not char then return end
            -- Local Ava Preset character is completely excluded from Nuke.
            if char == LP.Character and S.avaPresetEnabled == true then return end
            if IsVyxroAvatarObject(char) then return end
            task.spawn(function()
                task.wait(0.3)
                if not _G._NukeOn then return end
                for _,obj in ipairs(char:GetDescendants()) do
                    if IsVyxroAvatarObject(obj) then
                    elseif IsMinecraftTextureObject(obj) then
                    elseif IsClothing(obj) then SafeDestroy(obj)
                    else CleanObject(obj) end
                end
                RefreshMinecraftAfterNuke()
            end)
        end
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01; settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01 end)
        pcall(function() if setfpscap then setfpscap(999) end end)

        table.insert(_G._NukeThreads,task.spawn(function()
            if not game:IsLoaded() then game.Loaded:Wait() end
            OptimizeLighting(); ApplyTerrain()
            if NukeState.minecraftTextureEnabled then pcall(minecraftCreateSkyAndAtmosphere) end
            for _,obj in ipairs(workspace:GetDescendants()) do
                if not _G._NukeOn then return end
                -- IMPORTANT: check local preset protection BEFORE IsClothing.
                -- Otherwise Shirt/Pants/Accessory are destroyed by the generic
                -- clothing branch before character protection can run.
                if IsLocalAvaPresetObject(obj) or IsVyxroAvatarObject(obj) then
                elseif IsMinecraftTextureObject(obj) or IsMinecraftLightingObject(obj) then
                elseif IsBase(obj) then MakeTransparent(obj)
                elseif IsClothing(obj) then SafeDestroy(obj)
                elseif IsInBase(obj) then
                elseif IsCharacterPart(obj) then
                elseif IsOutOfRange(obj) then SafeDestroy(obj)
                else CleanObject(obj); StripObject(obj) end
            end
            if NukeState.minecraftTextureEnabled then RefreshMinecraftAfterNuke() end
        end))

        table.insert(_G._NukeConns,workspace.DescendantAdded:Connect(function(obj)
            if not _G._NukeOn then return end
            task.defer(function()
                if not _G._NukeOn then return end
                if IsLocalAvaPresetObject(obj) then return end
                if IsVyxroAvatarObject(obj) or IsVyxroProtectedLighting(obj) then return end
                if S.avaPresetEnabled == true and LP.Character and obj:IsDescendantOf(LP.Character) then return end
                if IsMinecraftTextureObject(obj) or IsMinecraftLightingObject(obj) then return end
                if IsBase(obj) then MakeTransparent(obj); return end
                if IsClothing(obj) then SafeDestroy(obj)
                elseif IsInBase(obj) then
                elseif IsCharacterPart(obj) then
                elseif IsOutOfRange(obj) then SafeDestroy(obj)
                else CleanObject(obj); StripObject(obj) end
            end)
        end))

        table.insert(_G._NukeConns,Lighting.DescendantAdded:Connect(function(obj)
            if not _G._NukeOn then return end
            if IsVyxroProtectedLighting(obj) then return end
            if NukeState.minecraftTextureEnabled and IsMinecraftLightingObject(obj) then return end
            if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then SafeDestroy(obj) end
        end))

        table.insert(_G._NukeConns,MaterialService.DescendantAdded:Connect(function(obj)
            if not _G._NukeOn then return end
            SafeDestroy(obj)
        end))

        for _,plr in ipairs(Players:GetPlayers()) do
            OptimizeCharacter(plr.Character)
            table.insert(_G._NukeConns,plr.CharacterAdded:Connect(OptimizeCharacter))
        end
        table.insert(_G._NukeConns,Players.PlayerAdded:Connect(function(plr)
            table.insert(_G._NukeConns,plr.CharacterAdded:Connect(OptimizeCharacter))
        end))
        table.insert(_G._NukeThreads,task.spawn(function()
            while _G._NukeOn do
                task.wait(15)
                pcall(function() collectgarbage("collect") end)
                if NukeState.minecraftTextureEnabled then RefreshMinecraftAfterNuke() end
            end
        end))
        RefreshMinecraftAfterNuke()
    end
    
_G._nukeStop = function()
    _G._NukeOn = false

    for _, c in ipairs(_G._NukeConns) do
        pcall(function() c:Disconnect() end)
    end
    _G._NukeConns = {}
    _G._NukeThreads = {}
end

-- Optional convenience toggle.
_G.VxyroToggleNukeOptimizer = function(enabled)
    if enabled then
        _G._nukeStart()
    else
        _G._nukeStop()
    end
end

local okKeys, errKeys = pcall(F.loadConfigKeys) if not okKeys then warn("[Vyxro Duel] F.loadConfigKeys error:", tostring(errKeys)) end
local okGui, errGui = pcall(F.buildGui)
if not okGui then
    warn("[Vyxro Duel] GUI error:", tostring(errGui))
    print("[Vyxro Duel] GUI FAILED:", tostring(errGui))
else
    _genv.__VyxroDuelLoaded = true
    print("[Vyxro Duel] GUI built OK")
    task.defer(function()
        pcall(function()
            -- Clean only the current Vyxro GUI, never arbitrary CoreGui/PlayerGui elements.
            local currentGui = main and main.Parent
            if not currentGui then return end
            -- Keep exactly one UnifiedBackgroundControl in the active Vxyro GUI.
            local keep=nil
            for _,obj in ipairs(currentGui:GetDescendants()) do
                if obj:IsA("GuiObject") then
                    local n=tostring(obj.Name)
                    if n=="LegacyUnifiedBackgroundToggleRow" or n=="LegacyBackgroundPhotoToggle" or n=="BgToggleRow" or n=="ColorThemePicker" then
                        obj:Destroy()
                    elseif n=="UnifiedBackgroundControl" then
                        if keep then obj:Destroy() else keep=obj end
                    end
                end
            end
        end)
    end)
    task.defer(function() task.wait(0.15) pcall(function() F.playVyxroDuelIntro() end) end)
end

-- ============================================================
-- ============================================================
-- POST-BUILD FOV OVERRIDE
-- Kept in a function scope so the large hub chunk stays below Luau's
-- main-function local/register limit.
-- ============================================================
_genv.__VxyroInstallFOVOverride = function()
    -- Disconnect the previous run before installing new camera/respawn watchers.
    local oldFovRuntime = rawget(_genv, "__VxyroFOVRuntime")
    if type(oldFovRuntime) == "table" and type(oldFovRuntime.stop) == "function" then
        pcall(oldFovRuntime.stop)
    end
    local __VXYRO_FOV_CONN = nil
    local __VXYRO_FOV_CAMERA_CONN = nil
    local __VXYRO_FOV_CHAR_CONN = nil

    local function __VXYRO_FOV_TARGET()
        return math.clamp(tonumber((K7 and K7.fovValue) or (_G._VezyFOV) or 70) or 70, 40, 120)
    end

    local function __VXYRO_FOV_DISCONNECT()
        if __VXYRO_FOV_CONN then pcall(function() __VXYRO_FOV_CONN:Disconnect() end); __VXYRO_FOV_CONN=nil end
    end

    local function __VXYRO_FOV_APPLY()
        __VXYRO_FOV_DISCONNECT()
        if not K7 then return end
        if not K7.fovEnabled then
            pcall(function()
                local cam=workspace.CurrentCamera
                if cam then cam.FieldOfView=70 end
            end)
            return
        end
        local target=__VXYRO_FOV_TARGET()
        K7.fovValue=target
        _G._VezyFOV=target
        pcall(function()
            local cam=workspace.CurrentCamera
            if cam and not (State and State.stretchedResEnabled) then cam.FieldOfView=target end
        end)
        __VXYRO_FOV_CONN=RunService.RenderStepped:Connect(function()
            if not K7 or not K7.fovEnabled then return end
            if State and State.stretchedResEnabled then return end
            local cam=workspace.CurrentCamera
            if cam and cam.FieldOfView~=target then pcall(function() cam.FieldOfView=target end) end
        end)
    end

    local function __VXYRO_FOV_STOP()
        __VXYRO_FOV_DISCONNECT()
        pcall(function()
            local cam=workspace.CurrentCamera
            if cam then cam.FieldOfView=70 end
        end)
    end

    -- Replace the function used by the existing FOV toggle/UI.
    K7.applyFOV=__VXYRO_FOV_APPLY
    K7.stopFOV=__VXYRO_FOV_STOP

    -- Camera replacement/respawn rebinding from the requested FOV behavior.
    pcall(function()
        __VXYRO_FOV_CAMERA_CONN=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            task.defer(function()
                if K7 and K7.fovEnabled then __VXYRO_FOV_APPLY() end
            end)
        end)
    end)
    pcall(function()
        __VXYRO_FOV_CHAR_CONN=LP.CharacterAdded:Connect(function()
            task.defer(function()
                if K7 and K7.fovEnabled then __VXYRO_FOV_APPLY() end
            end)
        end)
    end)

    _genv.__VxyroFOVRuntime = {
        stop = function()
            __VXYRO_FOV_DISCONNECT()
            if __VXYRO_FOV_CAMERA_CONN then pcall(function() __VXYRO_FOV_CAMERA_CONN:Disconnect() end); __VXYRO_FOV_CAMERA_CONN=nil end
            if __VXYRO_FOV_CHAR_CONN then pcall(function() __VXYRO_FOV_CHAR_CONN:Disconnect() end); __VXYRO_FOV_CHAR_CONN=nil end
        end,
    }
end
pcall(_genv.__VxyroInstallFOVOverride)

_genv.__VxyroLoadConfigStateOK, _genv.__VxyroLoadConfigStateErr = pcall(F.loadConfigState)
if not _genv.__VxyroLoadConfigStateOK then warn("[Vyxro Duel] F.loadConfigState error:", tostring(_genv.__VxyroLoadConfigStateErr)) end
-- Final post-load passes: some games create the real Tool/Handle a moment after spawn.
task.spawn(function()
    for _,delayTime in ipairs({0.2,0.6,1.2,2.0,3.0}) do
        task.wait(delayTime)
        pcall(function() if _G.VxyroImportedApplyLoaded then _G.VxyroImportedApplyLoaded() end end)
    end
end)
task.defer(function()
    task.wait(0.05)
    pcall(function() if _G._VersincSyncGui then _G._VersincSyncGui() end end)
end)

-- Restore Nuke Optimizer only after the saved config has been loaded and the start function exists.
task.defer(function()
    task.wait(0.15)
    local wanted = (_G.__VxyroNukeOptimizerConfigWanted == true)
    if wanted and _G._nukeStart then
        local ok, err = pcall(_G._nukeStart)
        if not ok then
            warn("[Vyxro Duel] Nuke Optimizer restore failed: " .. tostring(err))
        elseif VS and VS.setNukeOptimizerVisual then
            pcall(VS.setNukeOptimizerVisual, true)
        end
    else
        if _G._nukeStop then pcall(_G._nukeStop) end
        if VS and VS.setNukeOptimizerVisual then pcall(VS.setNukeOptimizerVisual, false) end
    end
end)

pcall(function()
    if _G.__VxyroGlossAttach and main and main.Parent then
        _G.__VxyroGlossAttach(main, {z=2, radius=22, thickness=1.55, bloomThickness=6.0})
    end
    local pg = LP and LP:FindFirstChildOfClass("PlayerGui")
    local containers = {}
    if pg then table.insert(containers, pg) end
    pcall(function() if type(gethui) == "function" and gethui() then table.insert(containers, gethui()) end end)
    pcall(function() table.insert(containers, game:GetService("CoreGui")) end)
    for _,parent in ipairs(containers) do
        for _,child in ipairs(parent:GetChildren()) do
            if child.Name == "BlessHighPingAlert" then
                local bar = child:FindFirstChild("AlertBar", true)
                if bar and _G.__VxyroGlossAttach then _G.__VxyroGlossAttach(bar, {z=101, radius=20, thickness=1.45, bloomThickness=5.5}) end
            elseif child.Name == "VyxroE01Notification" then
                local frame = child:FindFirstChild("E01Capsule", true)
                if frame and _G.__VxyroGlossAttach then _G.__VxyroGlossAttach(frame, {z=11, radius=19, thickness=1.45, bloomThickness=5.2}) end
            elseif child.Name == "VyxroTogglePingNotif" then
                for _,card in ipairs(child:GetDescendants()) do
                    if card:IsA("Frame") and card.Name == "Inner" and _G.__VxyroGlossAttach then
                        _G.__VxyroGlossAttach(card, {z=1, radius=15, thickness=1.15, bloomThickness=4.3})
                    end
                end
            end
        end
    end
end)
pcall(function() F.buildMobileButtons() if F.applyMobileButtonSize then F.applyMobileButtonSize() end
if F.applyMobileButtonsHidden then F.applyMobileButtonsHidden() end end) print("[Vyxro Duel] Loaded (performance profile)" .. (_VXYRO_LOW_END and " [LOW-END]" or " [PC]"))
-- VXYRO IMPORTED FEATURES (ISOLATED)
-- Source: AmbitiousTest.lua (15)-2.txt
-- Only: Music Player + Custom Fonts.
-- The imported code is isolated in its own function scope so it cannot
-- exhaust the main Luau local/register budget of the Vxyro hub.
-- Initialization is guarded so an imported feature cannot abort the hub.
-- ============================================================
task.spawn(function()
  xpcall(function()
    do
  local VXYRO_TweenService = game:GetService("TweenService")
  local VXYRO_SoundService = game:GetService("SoundService")
  local VXYRO_HubGui = _G.VxyroMainGui
  if not (typeof(VXYRO_HubGui) == "Instance") then
    pcall(function()
      if type(gethui) == "function" then
        VXYRO_HubGui = gethui()
      end
    end)
  end
  if not (typeof(VXYRO_HubGui) == "Instance") then
    VXYRO_HubGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
  end

  -- The imported widgets run outside F.buildGui, so its local corner()/stroke()
  -- helpers are not visible here. Provide local equivalents.
  local function corner(obj, radius)
    if not obj then return nil end
    local c = obj:FindFirstChildOfClass("UICorner")
    if not c then c = Instance.new("UICorner"); c.Parent = obj end
    c.CornerRadius = UDim.new(0, tonumber(radius) or 10)
    return c
  end

  local function stroke(obj, color, thickness, transparency)
    if not obj then return nil end
    local st = obj:FindFirstChildOfClass("UIStroke")
    if not st then st = Instance.new("UIStroke"); st.Parent = obj end
    st.Color = color or Color3.fromRGB(90, 90, 105)
    st.Thickness = thickness or 1
    st.Transparency = transparency == nil and 0.5 or transparency
    return st
  end

  -- A ScreenGui must be parented to the actual GUI container, not another
  -- ScreenGui. Keep VXYRO_HubGui as the text root, and resolve its render
  -- parent for newly opened popup ScreenGuis.
  local function getPopupParent()
    local parent = nil
    pcall(function() parent = VXYRO_HubGui and VXYRO_HubGui.Parent end)
    if typeof(parent) == "Instance" then return parent end
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
    if pg then return pg end
    return VXYRO_HubGui
  end

  local function fetchExternal(url)
    if type(game.HttpGet) == "function" then
      local ok, data = pcall(function() return game:HttpGet(url) end)
      if ok and type(data) == "string" and #data > 0 then return data end
    end
    local req = (type(request) == "function" and request)
      or (type(http_request) == "function" and http_request)
      or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
    if req then
      local ok, res = pcall(function() return req({Url = url, Method = "GET"}) end)
      if ok and type(res) == "table" then
        local body = res.Body or res.body
        if type(body) == "string" and #body > 0 then return body end
      end
    end
    return nil
  end

  local function getCustomAsset(path)
    if type(getcustomasset) == "function" then
      local ok, id = pcall(getcustomasset, path)
      if ok and id then return id end
    end
    if type(getsynasset) == "function" then
      local ok, id = pcall(getsynasset, path)
      if ok and id then return id end
    end
    return nil
  end

  local function VXYRO_tween(obj, props, duration)
    if not obj then return nil end
    local ok, tw = pcall(function()
      return VXYRO_TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
      )
    end)
    if ok and tw then
      tw:Play()
      return tw
    end
    return nil
  end

  -- Source UI expects these accent hooks. Vxyro has its own accent system,
  -- so this fallback keeps imported widgets functional and follows the
  -- current Vxyro theme when possible.
  if type(_G._AmbitiousRegAccent) ~= "function" then
    _G._AmbitiousRegAccent = function(_, grad)
      if not grad then return end
      local c = (S and S.themeColor) or Color3.fromRGB(147, 51, 234)
      pcall(function()
        grad.Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, c:Lerp(Color3.new(1,1,1), 0.30)),
          ColorSequenceKeypoint.new(0.5, c),
          ColorSequenceKeypoint.new(1, c:Lerp(Color3.new(0,0,0), 0.30)),
        })
      end)
    end
  end

  -- ---------------- MUSIC PLAYER ----------------
  local function _VxyroMusicNotify(msg)
    pcall(function()
      if _G.E01Notification and _G.E01Notification.show then
        -- Keep this non-intrusive; the E01 API only accepts show/hide.
        -- Failure messages are intentionally not forced through it.
      end
    end)
  end

-- ============================================================
-- CUSTOM FONTS
-- Applica un font a TUTTO il testo della hub: righe, sezioni, bottoni,
-- popup, lock e minimize, barra dell'auto grab, avvisi, e anche
-- l'etichetta sopra la testa — che non sta dentro la hub ma sulla Head
-- del personaggio, quindi va inseguita a parte a ogni respawn.
--
-- PERCHE' CENTINAIA E NON CINQUANTA.
-- Enum.Font ha una cinquantina di voci ed e' l'API vecchia: ogni voce e'
-- una combinazione famiglia+peso gia' decisa. Quella nuova e' FontFace,
-- che prende famiglia, PESO e stile separatamente. Si ricavano quindi le
-- famiglie uniche da Enum.Font e si moltiplicano per i nove pesi
-- (Thin..Heavy) e per corsivo si'/no: da ~25 famiglie vengono centinaia
-- di combinazioni vere, non nomi diversi per lo stesso disegno.
--
-- "Default" non e' un font: e' il ripristino. Di ogni elemento si salva
-- il FontFace ORIGINALE la prima volta che lo si tocca, cosi' tornare
-- indietro rimette esattamente quello che aveva ciascuno invece di
-- appiattire tutto su un font solo.
--
-- La tabella dei font originali e' STRONG di proposito: con __mode="k"
-- Luau scarterebbe le chiavi Instance anche se gli oggetti sono vivi
-- nella GUI, e al ripristino ci si ritroverebbe senza il valore da
-- rimettere.
--
-- Tutto su _G: zero local aggiunti al chunk principale.
-- ============================================================
_G.AmbitiousFonts = _G.AmbitiousFonts or {}
_G.AmbitiousFonts.orig = _G.AmbitiousFonts.orig or {}
_G.AmbitiousFonts.conns = _G.AmbitiousFonts.conns or {}
-- TextSize di partenza di ogni elemento, per l'adattamento automatico.
-- Strong come orig: senza il valore originale il ripristino non tornerebbe.
_G.AmbitiousFonts.size = _G.AmbitiousFonts.size or {}
_G.AmbitiousFontChoice = _G.VxyroCustomFontSelected or _G.AmbitiousFontChoice or "Default"

-- Nome breve del peso, per l'etichetta della card.
_G.AmbitiousFonts.WEIGHT_LABEL = {
  Thin = "Thin", ExtraLight = "ExLight", Light = "Light", Regular = "",
  Medium = "Medium", SemiBold = "SemiBold", Bold = "Bold",
  ExtraBold = "ExBold", Heavy = "Heavy",
}
-- Exact exclusion marker used by the supplied Starborn source.
pcall(function()
  if not _G.AmbitiousFonts.builderIconsStr then
    local bif = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json")
    _G.AmbitiousFonts.builderIconsStr = tostring(bif)
  end
end)

-- ============================================================
-- STARBORN CUSTOM FONT (top of the font picker)
-- Source supplied by the user. Loaded safely and cached so the
-- font picker can use it like every other FontFace entry.
-- ============================================================
_G.AmbitiousFonts.starbornFont = nil
pcall(function()
  if not (getcustomasset and writefile and isfile) then return end

  -- Refresh the supplied Starborn asset so an older/corrupted local
  -- starborn.ttf/json cannot make the picker silently use another font.
  local ttfOk, ttfData = pcall(game.HttpGet, game, "https://files.catbox.moe/pwgdui.ttf")
  if ttfOk and type(ttfData) == "string" and #ttfData >= 1000 then
    pcall(writefile, "starborn.ttf", ttfData)
  end

  if not isfile("starborn.ttf") then return end

  local json = game:GetService("HttpService"):JSONEncode({
    name = "Starborn",
    faces = {{
      name = "Regular",
      weight = 400,
      style = "normal",
      assetId = getcustomasset("starborn.ttf"),
    }}
  })
  pcall(writefile, "starborn.json", json)

  local ok, font = pcall(function()
    return Font.new(getcustomasset("starborn.json"))
  end)
  if ok and font then
    _G.AmbitiousFonts.starbornFont = font
  end
end)

-- Invalidate the cached catalog on every execution so the newly added
-- Starborn entry is not hidden by an older _G.AmbitiousFonts.cache.
_G.AmbitiousFonts.cache = nil

-- Catalogo completo, costruito una volta sola e tenuto in cache: sono
-- centinaia di voci, rifarle a ogni apertura del popup sarebbe sprecato.
function _G.AmbitiousFonts.list()
  local F = _G.AmbitiousFonts
  if F.cache then return F.cache end

  local out = {}
  if F.starbornFont then
    out[#out + 1] = { key = "Starborn", label = "Starborn", font = F.starbornFont }
  end
  out[#out + 1] = { key = "Default", label = "Default", font = nil }

  -- Famiglie uniche ricavate da Enum.Font. Si parte da li' perche' e'
  -- l'unico elenco che il motore garantisce: niente id inventati.
  local seen, families = {}, {}
  for _, item in ipairs(Enum.Font:GetEnumItems()) do
    if item.Name ~= "Unknown" then
      local ok, f = pcall(function() return Font.fromEnum(item) end)
      if ok and f and f.Family and not seen[f.Family] then
        seen[f.Family] = true
        -- Nome leggibile: dal percorso rbxasset si tiene solo il file.
        local nice = tostring(f.Family):match("([^/\\]+)%.json$")
                  or tostring(f.Family):match("([^/\\]+)$")
                  or item.Name
        families[#families + 1] = { family = f.Family, nice = nice }
      end
    end
  end

  for _, fam in ipairs(families) do
    for _, w in ipairs(Enum.FontWeight:GetEnumItems()) do
      for _, italic in ipairs({false, true}) do
        local ok, f = pcall(function()
          return Font.new(fam.family, w,
            italic and Enum.FontStyle.Italic or Enum.FontStyle.Normal)
        end)
        if ok and f then
          local wl = F.WEIGHT_LABEL[w.Name] or w.Name
          local label = fam.nice
          if wl ~= "" then label = label .. " " .. wl end
          if italic then label = label .. " Italic" end
          out[#out + 1] = {
            key = fam.family .. "|" .. w.Name .. "|" .. (italic and "i" or "n"),
            label = label,
            font = f,
          }
        end
      end
    end
  end

  F.cache = out
  return out
end

function _G.AmbitiousFonts.byKey(key)
  for _, e in ipairs(_G.AmbitiousFonts.list()) do
    if e.key == key then return e end
  end
  return nil
end

-- I contenitori da percorrere. VXYRO_HubGui copre tutte le ScreenGui della hub;
-- il billboard sopra la testa vive sulla Head e va aggiunto a mano.
function _G.AmbitiousFonts.roots()
  local F = _G.AmbitiousFonts
  local list, seen = {}, {}
  local function add(root)
    if root and root.Parent and not seen[root] then
      seen[root] = true
      list[#list + 1] = root
    end
  end

  -- Hub sendiri.
  add(_G.VxyroMainGui or VXYRO_HubGui)

  -- GUI milik game. Questo era il pezzo mancante: il vecchio picker
  -- cercava quasi esclusivamente la hub, quindi il font sembrava
  -- "solo per la GUI" e non toccava testo creato dal gioco.
  add(PlayerGui)

  -- Il popup del player/font puo' vivere nel contenitore protetto dell'
  -- executor (gethui/CoreGui) invece che dentro PlayerGui. Aggiungendolo
  -- qui il font scelto segue anche queste finestre.
  pcall(function() add(getPopupParent()) end)

  -- Testi 3D / world-space: BillboardGui e SurfaceGui vengono registrati
  -- separatamente per evitare di fare GetDescendants() dell'intero
  -- Workspace a ogni cambio font. La prima scansione avviene UNA volta.
  F.worldRoots = F.worldRoots or setmetatable({}, {__mode = "k"})
  if not F.worldScanDone then
    F.worldScanDone = true
    pcall(function()
      for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
          F.worldRoots[d] = true
        end
      end
    end)
  end
  for root in pairs(F.worldRoots) do
    add(root)
  end

  -- Overhead del player: supporta entrambe le versioni usate nei file
  -- originali/mergeati.
  local char = LP.Character
  local head = char and char:FindFirstChild("Head")
  if head then
    add(head:FindFirstChild("LinxHeadIndicator"))
    add(head:FindFirstChild("AmbitiousHubOverheadInfo"))
  end
  return list
end

-- Un simbolo solo: freccette, "-", "+", "X". Restano com'erano, font
-- compreso. Un glifo del genere non e' scrittura, e' un segno grafico
-- disegnato apposta per quel quadratino: prendendo il font scelto puo'
-- venire tutt'altra forma, storto o di un peso che stona. Il controllo e'
-- sui caratteri veri e non sui byte, se no una freccia ne conterebbe tre.
function _G.AmbitiousFonts.isGlyph(obj)
  local t = obj.Text
  if t == nil then return false end
  -- Una lettera o una cifra sono scrittura anche da sole: la "Q" di una
  -- keybind o la "X" di un bottone sono caratteri normali, e devono
  -- seguire il font come tutto il resto. L'esenzione vale solo per i
  -- segni: ▲ ▼ ◀ ▶ - +.
  if string.match(t, "%w") then return false end
  local ok, n = pcall(function() return utf8.len(t) end)
  return ok and n ~= nil and n <= 1
end

function _G.AmbitiousFonts.applyOne(obj, font)
  if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
    return
  end
  -- Font picker previews must keep their own sample font.
  if obj:GetAttribute("AmbFontLock") then return end
  local F = _G.AmbitiousFonts

  -- STARBORN: match the supplied Starborn script behavior as closely as
  -- possible. It uses the FontFace directly and does not resize the text.
  local isStarborn = (font ~= nil and F.starbornFont ~= nil and tostring(font) == tostring(F.starbornFont))
  if isStarborn then
    -- Zero Hub uses text strokes on many labels. Starborn must still be
    -- applied to those labels; only BuilderIcons and explicitly locked
    -- picker previews stay excluded.
    local fstr = tostring(obj.FontFace)
    if fstr == tostring(F.builderIconsStr or "") or fstr:find("BuilderIcons", 1, true) then
      return
    end
    pcall(function() obj.FontFace = F.starbornFont end)
    return
  end

  -- Other picker fonts keep the existing Vxyro behavior.
  if F.orig[obj] == nil then
    F.orig[obj] = obj.FontFace
    F.size[obj] = obj.TextSize
  end
  if F.isGlyph(obj) then font = nil end
  pcall(function()
    obj.FontFace = font or F.orig[obj]
    if F.size[obj] then obj.TextSize = F.size[obj] end
  end)
end

-- ADATTAMENTO AUTOMATICO DELLA MISURA
-- Ogni famiglia ha larghezze diverse: lo stesso testo che con Gotham sta
-- dentro la riga, con un font piu' largo esce dai margini.
--
-- La misura si CALCOLA, non si cerca a tentativi: GetTextBoundsAsync dice
-- quanto occuperebbe quel testo con quel font a quella misura, e con due
-- divisioni si ricava di quanto scalare. Ogni scritta e' a posto al primo
-- colpo, anche quelle che in quel momento non sono a schermo — le
-- dimensioni esistono comunque, mentre TextFits lo calcola il motore solo
-- su cio' che disegna, ed era per quello che si adattava la sola tab
-- aperta.
--
-- MARGIN: non basta che il testo "ci stia", deve anche non arrivare
-- appiccicato al bottone che ha accanto. Si toglie quel tanto di spazio
-- dai lati prima di fare il conto.
--
-- Su "Default" non gira affatto: le misure restano quelle di sempre.
_G.AmbitiousFonts.MIN_SIZE = 7    -- sotto e' illeggibile
_G.AmbitiousFonts.MARGIN   = 8    -- respiro ai lati, in pixel
_G.AmbitiousFonts.MAX_GROW = 1.35 -- quanto al massimo puo' crescere
-- Chiavi deboli: qui non si conserva niente da ripristinare, sono solo
-- appunti su chi e' gia' stato agganciato. Se l'oggetto sparisce dalla
-- GUI puo' sparire anche l'appunto.
_G.AmbitiousFonts.tconns = _G.AmbitiousFonts.tconns
  or setmetatable({}, {__mode = "k"})
-- Lunghezza del testo con cui ogni scritta e' stata adattata l'ultima
-- volta, per non rifare il conto a vuoto su un contatore che cambia cifra
-- restando lungo uguale.
_G.AmbitiousFonts.lastLen = _G.AmbitiousFonts.lastLen
  or setmetatable({}, {__mode = "k"})

function _G.AmbitiousFonts.params()
  local F = _G.AmbitiousFonts
  if F.gtbp == nil then
    local ok, p = pcall(function() return Instance.new("GetTextBoundsParams") end)
    F.gtbp = (ok and p) or false
  end
  return F.gtbp or nil
end

-- ------------------------------------------------------------
-- Il conto e' in DUE parti, e la differenza e' tutta qui.
--
-- 1) LA MISURA (costosa): quanto occupa quel testo col font nuovo e
--    quanto occupava col font originale. Da queste due nasce il rapporto
--    s0 — quanto scalare per avere lo stesso ingombro che la scritta
--    aveva su Default. Non c'entra niente con la casella, quindi si puo'
--    fare subito, anche su una scritta appena nata che non e' ancora
--    stata impaginata.
--
-- 2) IL CONTENIMENTO (gratis): il testo deve stare dentro la sua casella.
--    Qui serve la dimensione vera, ma NON serve rimisurare niente: le
--    dimensioni del testo sono gia' in cache, e ridurle allo spazio
--    disponibile sono due divisioni.
--
-- Separandole si risolve il problema di prima. Le scritte dei popup
-- nascono mentre il riquadro si sta ancora aprendo, e la loro casella in
-- quel momento e' piu' piccola di quella finale: con un conto solo o si
-- sbagliava, o bisognava aspettare e correggere dopo — ed era quello che
-- si vedeva cambiare sotto gli occhi. Adesso la parte 1 si applica
-- all'istante e la parte 2 si riapplica da sola a ogni variazione della
-- casella, quindi mentre il popup si ingrandisce il testo lo segue e
-- arriva gia' giusto. Stessa cosa per una freccetta o una riga dentro una
-- tendina chiusa: quando compare e prende una dimensione, si sistema da
-- se' senza che nessuno la tocchi.
-- ------------------------------------------------------------
_G.AmbitiousFonts.m = _G.AmbitiousFonts.m or setmetatable({}, {__mode = "k"})
_G.AmbitiousFonts.aconns = _G.AmbitiousFonts.aconns
  or setmetatable({}, {__mode = "k"})
_G.AmbitiousFonts.stamp = _G.AmbitiousFonts.stamp or 0

-- Parte 2: solo aritmetica sui numeri gia' in cache.
function _G.AmbitiousFonts.reclamp(obj)
  local F = _G.AmbitiousFonts
  local c = F.m[obj]
  if not c then return end
  -- Stessa esenzione di fitOne: un simbolo solo resta com'era.
  if F.isGlyph(obj) then
    if obj.TextSize ~= c.base then obj.TextSize = c.base end
    return
  end
  local s = c.s0
  local box = obj.AbsoluteSize
  if box.X > 1 and box.Y > 1 then
    -- AutomaticSize: su quell'asse la casella non e' un limite, e' il
    -- testo stesso a deciderla. Contenere il testo dentro una casella che
    -- lo insegue non ha senso e per di piu' si morde la coda: cambio la
    -- misura -> cambia la casella -> l'aggancio scatta -> ricontengo ->
    -- cambio di nuovo la misura, e si finisce dove capita. Il contatore
    -- degli MS e quello degli FPS sono gli unici due cosi' fatti nella
    -- barra, ed e' per questo che uno dei due si ritrovava con una misura
    -- che non c'entrava niente.
    local auto = obj.AutomaticSize
    local freeX = (auto == Enum.AutomaticSize.X or auto == Enum.AutomaticSize.XY)
    local freeY = (auto == Enum.AutomaticSize.Y or auto == Enum.AutomaticSize.XY)
    if not freeY then
      s = math.min(s, math.max(box.Y - 2, 1) / c.by)
    end
    -- Il respiro laterale e' in pixel, ma su una casella stretta 8px sono
    -- un quinto dello spazio: sotto una certa larghezza si accorcia con
    -- lei, se no le scritte piccole (FPS, MS, la percentuale) si
    -- ridurrebbero a niente.
    if not (freeX or c.wrapped) then
      s = math.min(s, math.max(box.X - math.min(F.MARGIN, box.X * 0.08), 1) / c.bx)
    end
  end
  local want = math.floor(c.base * s + 0.5)
  if want < F.MIN_SIZE then want = F.MIN_SIZE end
  if obj.TextSize ~= want then obj.TextSize = want end
end

-- Parte 1: le due misurazioni, e il rapporto con l'ingombro di Default.
function _G.AmbitiousFonts.measure(obj)
  local F = _G.AmbitiousFonts
  local font = F.current()
  if not font then return false end
  local prm = F.params()
  if not prm then return false end
  F.tsvc = F.tsvc or game:GetService("TextService")

  local base = F.size[obj]
  if not base then base = obj.TextSize; F.size[obj] = base end

  local txt = obj.Text
  if txt == nil or txt == "" then
    F.m[obj] = {base = base, bx = 1, by = 1, s0 = 1, stamp = F.stamp, text = txt}
    return true
  end

  -- Con TextWrapped la larghezza e' vincolata e quello che conta e'
  -- l'altezza; senza, si misura su una riga sola.
  local wrapped = obj.TextWrapped and obj.AbsoluteSize.X > 1
  prm.Text = txt
  prm.Size = base
  prm.Width = wrapped and obj.AbsoluteSize.X or 0

  prm.Font = font
  local ok, b = pcall(function() return F.tsvc:GetTextBoundsAsync(prm) end)
  if not (ok and b and b.X > 0 and b.Y > 0) then return false end

  -- L'ingombro col font ORIGINALE e' il riferimento: e' com'era la GUI su
  -- Default. Il font nuovo va portato li' — se disegna piu' largo si
  -- rimpicciolisce, se disegna piu' stretto si INGRANDISCE.
  local s0 = 1
  local of = F.orig[obj]
  if of then
    prm.Font = of
    local ok2, b2 = pcall(function() return F.tsvc:GetTextBoundsAsync(prm) end)
    if ok2 and b2 and b2.X > 0 and b2.Y > 0 then
      -- Il confronto e' sulla LARGHEZZA: l'altezza dei due riquadri e'
      -- quasi sempre la stessa (la misura del font e' gia' l'altezza
      -- della riga) e quel rapporto vale circa 1 sempre. Sul testo a capo
      -- vale l'opposto, li' la larghezza e' fissa per definizione.
      s0 = wrapped and (b2.Y / b.Y) or (b2.X / b.X)
    end
  end
  -- Tetto alla crescita: un font molto stretto non deve diventare enorme
  -- solo perche' la casella e' larga.
  if s0 > F.MAX_GROW then s0 = F.MAX_GROW end

  F.m[obj] = {base = base, bx = b.X, by = b.Y, s0 = s0,
              wrapped = wrapped, stamp = F.stamp, text = txt}
  return true
end

-- Misura se serve, poi contiene. noBox e' rimasto per compatibilita': la
-- casella ormai la guarda solo reclamp, che e' gratis.
function _G.AmbitiousFonts.fitOne(obj)
  local F = _G.AmbitiousFonts
  local currentFont = F.current()
  if not currentFont then return end
  if obj:GetAttribute("AmbFontLock") then return end
  if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
  if obj.TextScaled then return end
  -- Supplied Starborn script does not perform size fitting: preserve the
  -- original TextSize exactly.
  if F.starbornFont and tostring(currentFont) == tostring(F.starbornFont) then
    return true
  end

  -- I BOTTONI DI UN SEGNO SOLO NON SI TOCCANO, ne' nel font ne' nella
  -- misura: il criterio "stesso ingombro che aveva su Default" su un
  -- simbolo non vuol dire niente, e ricalcolarlo produceva solo quelle
  -- variazioni che sembravano un difetto quando li premevi.
  if F.isGlyph(obj) then return true end

  local c = F.m[obj]
  if not (c and c.stamp == F.stamp and c.text == obj.Text) then
    if not F.measure(obj) then return false end
  end
  F.reclamp(obj)
  return true
end

-- Aggancia una scritta: da qui in poi si tiene aggiornata da sola.
-- Un aggancio per oggetto, fatto una volta sola.
function _G.AmbitiousFonts.watch(obj)
  local F = _G.AmbitiousFonts
  if F.aconns[obj] then return end
  -- La casella cambia: durante l'apertura di un popup, con la GUI Scale,
  -- quando una tendina si apre. Qui non si rimisura niente, si ricontiene
  -- e basta.
  F.aconns[obj] = obj:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    local G = _G.AmbitiousFonts
    if not G.current() then return end
    if G.m[obj] then G.reclamp(obj) else pcall(G.fitOne, obj) end
  end)
  if F.tconns[obj] then return end
  -- Il testo cambia: LOCK che diventa UNLOCK, una keybind, un contatore.
  -- Un contatore che passa da 58 a 59 pero' occupa lo stesso spazio, e
  -- rimisurarlo a ogni cifra sarebbe lavoro buttato su roba che cambia
  -- anche piu' volte al secondo: si rifa il conto quando cambia la
  -- lunghezza.
  F.tconns[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
    local G = _G.AmbitiousFonts
    if not G.current() then return end
    if G.lastLen[obj] == #obj.Text then return end
    G.lastLen[obj] = #obj.Text
    -- Anche il font va rideciso: una scritta puo' diventare un simbolo
    -- solo (o smettere di esserlo) e l'esenzione cambia con lei.
    pcall(G.applyOne, obj, G.current())
    if not (G.starbornFont and G.current() and tostring(G.current()) == tostring(G.starbornFont)) then
      pcall(G.fitOne, obj)
    end
  end)
end

function _G.AmbitiousFonts.fit(pass)
  local F = _G.AmbitiousFonts
  if F.starbornFont and F.current() and tostring(F.current()) == tostring(F.starbornFont) then
    return
  end
  F.fitToken = (F.fitToken or 0) + 1
  local myToken = F.fitToken
  if not F.current() then return end   -- Default: nessuna modifica
  F.tsvc = F.tsvc or game:GetService("TextService")

  task.spawn(function()
    local list = {}
    for _, root in ipairs(F.roots()) do
      for _, d in ipairs(root:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox"))
           and not d.TextScaled and not d:GetAttribute("AmbFontLock") then
          list[#list + 1] = d
        end
      end
    end

    for _, o in ipairs(list) do
      if F.fitToken ~= myToken then return end   -- font cambiato nel frattempo
      if o.Parent then
        F.fitOne(o)
        F.lastLen[o] = #o.Text
        F.watch(o)
      end
    end

    -- Un ripasso comunque: un font appena scelto puo' non essere ancora
    -- stato caricato dal motore, e finche' non lo e' le misure che
    -- tornano sono quelle del ripiego. Il secondo giro cade a
    -- caricamento finito. La cache viene buttata apposta, se no si
    -- riuserebbero proprio i numeri sbagliati.
    pass = (tonumber(pass) or 0) + 1
    if pass < 3 then
      task.delay(pass == 1 and 0.35 or 1.5, function()
        if F.fitToken ~= myToken then return end
        F.stamp = F.stamp + 1
        F.fit(pass)
      end)
    end
  end)
end

-- Font attualmente scelto, oppure nil se siamo su "Default".
function _G.AmbitiousFonts.current()
  local key = _G.VxyroCustomFontSelected or _G.AmbitiousFontChoice
  if not key or key == "Default" then return nil end
  local e = _G.AmbitiousFonts.byKey(key)
  return e and e.font or nil
end

function _G.AmbitiousFonts.applyAll()
  local F = _G.AmbitiousFonts
  local font = F.current()
  for _, root in ipairs(F.roots()) do
    F.applyOne(root, font)
    for _, d in ipairs(root:GetDescendants()) do
      F.applyOne(d, font)
    end
  end
  F.fit()
end

-- Aggancio a eventi, non a un loop: i popup e le righe create dopo
-- devono nascere gia' col font giusto, ma senza riscandire niente.
function _G.AmbitiousFonts.hook()
  local F = _G.AmbitiousFonts
  for _, c in ipairs(F.conns) do pcall(function() c:Disconnect() end) end
  F.conns = {}
  F.worldRoots = F.worldRoots or setmetatable({}, {__mode = "k"})

  local function applyAdded(d)
    if _G.AmbitiousFontChoice == "Default" then return end
    pcall(F.applyOne, d, F.current())
    if not (F.starbornFont and F.current() and tostring(F.current()) == tostring(F.starbornFont)) then
      pcall(F.fitOne, d)
    end
    pcall(F.watch, d)
  end

  for _, root in ipairs(F.roots()) do
    if root and root.DescendantAdded then
      F.conns[#F.conns + 1] = root.DescendantAdded:Connect(applyAdded)
    end
  end

  -- Se nasce un nuovo BillboardGui/SurfaceGui nel mondo, lo memorizziamo
  -- come root. Se invece nasce direttamente un TextLabel dentro un root
  -- già noto, applyAdded() lo prende al volo.
  F.conns[#F.conns + 1] = Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
      F.worldRoots[d] = true
    end
    applyAdded(d)
  end)
  F.conns[#F.conns + 1] = Workspace.DescendantRemoving:Connect(function(d)
    F.worldRoots[d] = nil
  end)
end

function _G.AmbitiousFonts.set(key, skipSave)
  key = key or "Default"
  if key == "Starborn" and not _G.AmbitiousFonts.starbornFont then
    pcall(function()
      if getcustomasset and isfile and isfile("starborn.json") then
        local asset = getcustomasset("starborn.json")
        local ok, font = pcall(function() return Font.new(asset) end)
        if ok and font then _G.AmbitiousFonts.starbornFont = font end
      end
    end)
  end
  if key == "Starborn" and not _G.AmbitiousFonts.starbornFont then return false end
  _G.AmbitiousFontChoice = key
  _G.VxyroCustomFontSelected = key
  -- Font diverso, misure diverse: quello che c'e' in cache non vale piu'.
  _G.AmbitiousFonts.stamp = (_G.AmbitiousFonts.stamp or 0) + 1
  _G.AmbitiousFonts.applyAll()
  _G.AmbitiousFonts.hook()
  if not skipSave then pcall(function() if F and F.saveConfig then F.saveConfig() end end) end
end

-- Il catalogo si costruisce una volta sola; farlo adesso in sottofondo
-- vuol dire che al primo click sul PICK e' gia' pronto in cache.
task.spawn(function() pcall(_G.AmbitiousFonts.list) end)


-- Apply persisted font selection after the font module exists. The selected
-- key remains stored separately so disabling the font does not forget it.
task.defer(function()
  local key = _G.VxyroCustomFontSelected or "Default"
  local enabled = _G.VxyroCustomFontEnabled == true
  if _G.AmbitiousFonts and _G.AmbitiousFonts.byKey and _G.AmbitiousFonts.set then
    if _G.AmbitiousFonts.byKey(key) then
      if enabled then
        pcall(_G.AmbitiousFonts.set, key, true)
      else
        pcall(_G.AmbitiousFonts.set, "Default", true)
      end
    else
      _G.VxyroCustomFontSelected = "Default"
      pcall(_G.AmbitiousFonts.set, "Default", true)
    end
  end
  if _G.VxyroImportedFontVisual then
    pcall(_G.VxyroImportedFontVisual, enabled)
  end
  if enabled and key == "Starborn" then
    task.delay(0.75, function()
      pcall(function()
        if _G.AmbitiousFonts and _G.AmbitiousFonts.byKey and _G.AmbitiousFonts.byKey("Starborn") then
          _G.AmbitiousFonts.set("Starborn", true)
        end
      end)
    end)
  end
end)

-- Final Starborn verification pass. The supplied font source applies the
-- actual FontFace directly; this pass catches labels created during startup
-- after the main GUI finishes building.
task.delay(1.0, function()
  pcall(function()
    if _G.VxyroCustomFontEnabled == true and _G.VxyroCustomFontSelected == "Starborn" then
      if _G.AmbitiousFonts and _G.AmbitiousFonts.set then
        _G.AmbitiousFonts.set("Starborn", true)
      end
    end
  end)
end)

-- L'etichetta sopra la testa viene ricreata a ogni respawn: si riapplica
-- il font e si riaggancia il listener sul nuovo billboard.
if not _G.AmbitiousFonts.charConn then
  _G.AmbitiousFonts.charConn = LP.CharacterAdded:Connect(function()
    task.delay(1.5, function()
      if _G.AmbitiousFontChoice == "Default" then return end
      pcall(_G.AmbitiousFonts.applyAll)
      pcall(_G.AmbitiousFonts.hook)
    end)
  end)
end

-- MUSIC PLAYER (stessa logica dell'intro: download -> cache -> getcustomasset)
-- ============================================================
_VxyroImportedMusicOptions = _VxyroImportedMusicOptions or {
  {name="Gelato", url="https://files.catbox.moe/sospih.mp3", file="AmbitiousHubMusic1.mp3"},
  {name="Meant To Be", url="https://files.catbox.moe/smt6l8.mp3", file="AmbitiousHubMusic2.mp3"},
  {name="Beccaria San Vittore RMX", url="https://files.catbox.moe/2r8auq.mp3", file="AmbitiousHubMusic3.mp3"},
  {name="The Box", url="https://files.catbox.moe/yumqjl.mp3", file="AmbitiousHubMusic4.mp3"},
  {name="Mu Ammar Gheddafi RMX", url="https://files.catbox.moe/qcuden.mp3", file="AmbitiousHubMusic5.mp3"},
  {name="Marocchino RMX", url="https://files.catbox.moe/iyav31.mp3", file="AmbitiousHubMusic6.mp3"},
  {name="Gotham Mashup", url="https://files.catbox.moe/7eof36.mp3", file="AmbitiousHubMusic7.mp3"},
  {name="Goosebumps", url="https://files.catbox.moe/6wqcck.mp3", file="AmbitiousHubMusic8.mp3"},
  {name="Houdini", url="https://files.catbox.moe/gsuxur.mp3", file="AmbitiousHubMusic9.mp3"},
  {name="Magnolia", url="https://files.catbox.moe/ursllw.mp3", file="AmbitiousHubMusic10.mp3"},
  {name="Redemption RMX", url="https://files.catbox.moe/kjxkv7.mp3", file="AmbitiousHubMusic11.mp3"},
  {name="Evicted RMX", url="https://files.catbox.moe/s28bh5.mp3", file="AmbitiousHubMusic12.mp3"},
  {name="Lyfe RMX", url="https://files.catbox.moe/8hciqx.mp3", file="AmbitiousHubMusic13.mp3"},
  {name="No Refunds RMX", url="https://files.catbox.moe/uz9hot.mp3", file="AmbitiousHubMusic14.mp3"},
  {name="8 AM In Manny RMX", url="https://files.catbox.moe/xh4t0r.mp3", file="AmbitiousHubMusic15.mp3"},
  {name="Us Vs Them RMX", url="https://files.catbox.moe/po5fbj.mp3", file="AmbitiousHubMusic16.mp3"},
  {name="Reflection 2 RMX", url="https://files.catbox.moe/kcst57.mp3", file="AmbitiousHubMusic17.mp3"},
  {name="I Know You Care RMX", url="https://files.catbox.moe/c2en1v.mp3", file="AmbitiousHubMusic18.mp3"},
  {name="Bubblegum RMX", url="https://files.catbox.moe/8xf15k.mp3", file="AmbitiousHubMusic19.mp3"},
  {name="Cream RMX", url="https://files.catbox.moe/yfhgqz.mp3", file="AmbitiousHubMusic20.mp3"},
  {name="Panzerknacker.wav", url="https://files.catbox.moe/izcvhm.mp3", file="AmbitiousHubMusic21.mp3"},
  {name="Freaked Out", url="https://files.catbox.moe/dyt2ja.mp3", file="AmbitiousHubMusic22.mp3"},
  {name="Scam Likely", url="https://files.catbox.moe/pr85mz.mp3", file="AmbitiousHubMusic23.mp3"},
  {name="Pure Cocaine", url="https://files.catbox.moe/dvjtjk.mp3", file="AmbitiousHubMusic24.mp3"},
  {name="Tesla", url="https://files.catbox.moe/n85fch.mp3", file="AmbitiousHubMusic25.mp3"},
  {name="Piazza Di Spaccio 2 RMX", url="https://files.catbox.moe/0ompvn.mp3", file="AmbitiousHubMusic26.mp3"},
  {name="Benef RMX", url="https://files.catbox.moe/swcqe5.mp3", file="AmbitiousHubMusic27.mp3"},
  {name="Accavallato RMX", url="https://files.catbox.moe/pme01q.mp3", file="AmbitiousHubMusic28.mp3"},
  {name="Hd RMX", url="https://files.catbox.moe/oa3ylr.mp3", file="AmbitiousHubMusic29.mp3"},
  {name="Vyzee", url="https://files.catbox.moe/gmxz02.mp3", file="AmbitiousHubMusic30.mp3"},
  {name="Addiction", url="https://files.catbox.moe/unkq06.mp3", file="AmbitiousHubMusic31.mp3"},
  {name="America RMX", url="https://files.catbox.moe/k09ioc.mp3", file="AmbitiousHubMusic32.mp3"},
  {name="Sprinter", url="https://files.catbox.moe/0gyb73.mp3", file="AmbitiousHubMusic33.mp3"},
  {name="Band4Band", url="https://files.catbox.moe/47dehm.mp3", file="AmbitiousHubMusic34.mp3"},
  {name="Doja RMX", url="https://files.catbox.moe/8ze5d8.mp3", file="AmbitiousHubMusic35.mp3"},
  {name="Opinel RMX", url="https://files.catbox.moe/hf6pdq.mp3", file="AmbitiousHubMusic36.mp3"},
  {name="Vrp RMX", url="https://files.catbox.moe/hjzkbu.mp3", file="AmbitiousHubMusic37.mp3"},
  {name="Tarantelle RMX", url="https://files.catbox.moe/0e9jwg.mp3", file="AmbitiousHubMusic38.mp3"},
  {name="Hood RMX", url="https://files.catbox.moe/raewna.mp3", file="AmbitiousHubMusic39.mp3"},
  {name="Mask RMX", url="https://files.catbox.moe/ghqz2q.mp3", file="AmbitiousHubMusic40.mp3"},
  {name="Spinnin RMX", url="https://files.catbox.moe/r9achz.mp3", file="AmbitiousHubMusic41.mp3"},
  {name="Dnd RMX", url="https://files.catbox.moe/1d83ju.mp3", file="AmbitiousHubMusic42.mp3"},
  {name="Xnx RMX", url="https://files.catbox.moe/a2e54o.mp3", file="AmbitiousHubMusic43.mp3"},
  {name="Hypebae RMX", url="https://files.catbox.moe/oj6hix.mp3", file="AmbitiousHubMusic44.mp3"},
  {name="Mercedes Nero RMX", url="https://h.uguu.se/dCgHArHt.mp3", file="AmbitiousHubMusic45.mp3", rev=2},
  {name="Dissenatori RMX", url="https://files.catbox.moe/fbjq0w.mp3", file="AmbitiousHubMusic46.mp3"},
  {name="British RMX", url="https://files.catbox.moe/jn9mmr.mp3", file="AmbitiousHubMusic47.mp3"},
  {name="Go Go Jack RMX", url="https://files.catbox.moe/u31krk.mp3", file="AmbitiousHubMusic48.mp3"},
  {name="Darkmoney RMX", url="https://files.catbox.moe/rz4mzu.mp3", file="AmbitiousHubMusic49.mp3"},
  {name="Ghetto RMX", url="https://files.catbox.moe/omj56p.mp3", file="AmbitiousHubMusic50.mp3"},
  {name="Copacabana RMX", url="https://files.catbox.moe/g43412.mp3", file="AmbitiousHubMusic51.mp3"},
}

selectedMusicSong = selectedMusicSong or 1
musicPlayerVolume = musicPlayerVolume or 1
-- Velocita' di riproduzione: 1 = normale, passo 0.1, da 0.1 a 2.
musicPlayerSpeed = musicPlayerSpeed or 1
musicAutoPlayNext = musicAutoPlayNext == true
musicShuffleEnabled = musicShuffleEnabled == true
musicLoopEnabled = musicLoopEnabled == true
_musicPlayerSound = nil
_musicPlayerToken = 0
musicSongCache = musicSongCache or {}
musicSongDownloading = musicSongDownloading or {}
-- Revisioni gia' ripulite in questa esecuzione, per non ricontrollare
-- il disco a ogni canzone caricata.
musicRevCleaned = musicRevCleaned or {}
_G.AmbitiousMusicRefreshUI = nil
_G.AmbitiousMusicCloseUI = nil

function _VxyroImportedMusicGetSongName()
  local opt = _VxyroImportedMusicOptions[selectedMusicSong]
  return opt and opt.name or "No Song"
end

-- Indice casuale garantito diverso da quello corrente
function _VxyroImportedMusicRandomIndex()
  local total = #_VxyroImportedMusicOptions
  if total <= 1 then return 1 end
  local r = math.random(1, total - 1)
  if r >= selectedMusicSong then r = r + 1 end
  return r
end

function _VxyroImportedMusicRefreshUI()
  if _G.AmbitiousMusicRefreshUI then pcall(_G.AmbitiousMusicRefreshUI) end
end

function _VxyroImportedMusicCacheSong(option, allowDownload)
  if not option or not option.url or option.url == "" then return nil end
  if type(writefile) ~= "function" or type(getCustomAsset) ~= "function" then return nil end
  local baseName = option.file or ("AmbitiousHubMusic_" .. tostring(option.name or "song") .. ".mp3")
  -- REVISIONE DEL FILE.
  -- Se cambia il link di una canzone, chi ha gia' scaricato la vecchia se
  -- la ritrova in cache per sempre: il nome del file e' lo stesso e non c'e'
  -- modo di accorgersi che il contenuto non e' piu' quello giusto.
  -- Invece di storpiare il nome (o di scrivere una cancellazione una-tantum
  -- per quella singola canzone, che resterebbe li' come codice morto), la
  -- voce porta un campo "rev": alzarlo di 1 basta e avanza.
  --   rev assente o 1 -> AmbitiousHubMusic45.mp3
  --   rev = 2         -> AmbitiousHubMusic45_r2.mp3
  -- La prima volta che si tocca una canzone con rev > 1 si cancellano dal
  -- disco tutte le revisioni precedenti, quindi non si accumula niente.
  -- E' generico: la prossima volta che cambi un link non serve altro codice.
  local rev = math.max(math.floor(tonumber(option.rev) or 1), 1)
  local stem = baseName:gsub("%.mp3$", "")
  local fileName = (rev > 1) and (stem .. "_r" .. rev .. ".mp3") or baseName

  if rev > 1 and not musicRevCleaned[baseName] then
    musicRevCleaned[baseName] = true
    for r = 1, rev - 1 do
      local oldName = (r > 1) and (stem .. "_r" .. r .. ".mp3") or baseName
      musicSongCache[oldName] = nil
      pcall(function()
        if isfile and isfile(oldName) and delfile then delfile(oldName) end
      end)
    end
  end
  local function loadExisting()
    if musicSongCache[fileName] then return musicSongCache[fileName] end
    local hasFile = false
    pcall(function() hasFile = isfile and isfile(fileName) end)
    if hasFile then
      local ok = pcall(function() musicSongCache[fileName] = getCustomAsset(fileName) end)
      if ok and musicSongCache[fileName] then return musicSongCache[fileName] end
    end
    return nil
  end
  local cached = loadExisting()
  if cached then return cached end
  if allowDownload == false then return nil end
  if musicSongDownloading[fileName] then
    local waitStart = tick()
    while musicSongDownloading[fileName] and tick() - waitStart < 15 do task.wait(0.05) end
    cached = loadExisting()
    if cached then return cached end
  end
  musicSongDownloading[fileName] = true
  local ok = pcall(function()
    local data = fetchExternal(option.url)
    if data and #data > 0 then
      writefile(fileName, data)
      musicSongCache[fileName] = getCustomAsset(fileName)
    end
  end)
  musicSongDownloading[fileName] = nil
  if ok and musicSongCache[fileName] then return musicSongCache[fileName] end
  return loadExisting()
end

function _VxyroImportedMusicCreateSound(option, name)
  if not option then return nil end
  local soundId = _VxyroImportedMusicCacheSong(option, true)
  if not soundId then return nil end
  local sound = Instance.new("Sound")
  sound.Name = name or "AmbitiousHubMusicPlayer"
  sound.Volume = musicPlayerVolume
  sound.PlaybackSpeed = musicPlayerSpeed
  sound.Looped = false
  sound.SoundId = soundId
  sound.Parent = VXYRO_SoundService
  return sound
end

-- Fade away identico a quello dell'intro
function _VxyroImportedMusicFadeOut(sound, dur)
  if not sound then return end
  dur = dur or 1.5
  pcall(function()
    VXYRO_TweenService:Create(sound, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Volume = 0}):Play()
  end)
  task.delay(dur + 0.1, function()
    pcall(function()
      if sound and sound.Parent then
        sound:Stop()
        sound:Destroy()
      end
    end)
  end)
end

function _VxyroImportedMusicStop(fade)
  _musicPlayerToken = _musicPlayerToken + 1
  local sound = _musicPlayerSound
  _musicPlayerSound = nil
  if sound then
    if fade == false then
      pcall(function() sound:Stop(); sound:Destroy() end)
    else
      _VxyroImportedMusicFadeOut(sound, 1.5)
    end
  end
  _VxyroImportedMusicRefreshUI()
end

function _VxyroImportedMusicPlay(index)
  index = tonumber(index) or selectedMusicSong
  local total = #_VxyroImportedMusicOptions
  if total <= 0 then return end
  if index < 1 then index = total end
  if index > total then index = 1 end
  if not _VxyroImportedMusicOptions[index] then return end
  selectedMusicSong = index
  _VxyroImportedMusicStop(true)
  local token = _musicPlayerToken
  _VxyroImportedMusicRefreshUI()
  task.spawn(function()
    local option = _VxyroImportedMusicOptions[index]
    local sound = _VxyroImportedMusicCreateSound(option, "AmbitiousHubMusicPlayer_" .. tostring(token))
    if token ~= _musicPlayerToken then
      if sound then pcall(function() sound:Destroy() end) end
      return
    end
    if not sound then _VxyroMusicNotify("SONG FAILED"); return end
    sound.Volume = musicPlayerVolume
    sound.PlaybackSpeed = musicPlayerSpeed
    sound.TimePosition = 0
    _musicPlayerSound = sound
    local loadStart = tick()
    while sound and sound.Parent and not sound.IsLoaded and tick() - loadStart < 15 do task.wait(0.05) end
    if token ~= _musicPlayerToken then
      pcall(function() if sound and sound.Parent then sound:Destroy() end end)
      return
    end
    pcall(function() sound:Play() end)
    _VxyroImportedMusicRefreshUI()

    local endedConn
    endedConn = sound.Ended:Connect(function()
      if endedConn then pcall(function() endedConn:Disconnect() end) end
      if token ~= _musicPlayerToken then return end
      if musicLoopEnabled then
        _VxyroImportedMusicPlay(selectedMusicSong)
      elseif musicShuffleEnabled then
        _VxyroImportedMusicPlay(_VxyroImportedMusicRandomIndex())
      elseif musicAutoPlayNext then
        _VxyroImportedMusicPlay(selectedMusicSong + 1)
      else
        _VxyroImportedMusicStop(false)
      end
    end)

    -- Fade away sul finale della traccia (come l'intro)
    task.spawn(function()
      while token == _musicPlayerToken and sound and sound.Parent do
        local len = sound.TimeLength
        if len and len > 1 then
          local remaining = len - sound.TimePosition
          if remaining <= 1.6 and sound.IsPlaying and sound:GetAttribute("_amFaded") ~= true then
            sound:SetAttribute("_amFaded", true)
            local d = math.clamp(remaining - 0.05, 0.2, 1.5)
            pcall(function()
              VXYRO_TweenService:Create(sound, TweenInfo.new(d, Enum.EasingStyle.Linear), {Volume = 0}):Play()
            end)
          end
        end
        task.wait(0.1)
      end
    end)
  end)
end

function _VxyroImportedMusicPauseToggle()
  local sound = _musicPlayerSound
  if not sound or not sound.Parent then
    _VxyroImportedMusicPlay(selectedMusicSong)
    return
  end
  if sound.IsPlaying then
    pcall(function() sound:Pause() end)
  else
    pcall(function() sound:Resume() end)
  end
  _VxyroImportedMusicRefreshUI()
end

function _VxyroImportedMusicNext()
  if musicShuffleEnabled then
    _VxyroImportedMusicPlay(_VxyroImportedMusicRandomIndex())
  else
    _VxyroImportedMusicPlay(selectedMusicSong + 1)
  end
  F.saveConfig()
end

function _VxyroImportedMusicPrev()
  if musicShuffleEnabled then
    _VxyroImportedMusicPlay(_VxyroImportedMusicRandomIndex())
  else
    _VxyroImportedMusicPlay(selectedMusicSong - 1)
  end
  F.saveConfig()
end

function _VxyroImportedMusicSeek(delta)
  local sound = _musicPlayerSound
  if not sound or not sound.Parent then return end
  local len = sound.TimeLength or 0
  -- Il delta arriva in secondi "di ascolto": va convertito in secondi di
  -- traccia, altrimenti a 2x un salto di 10s ne farebbe 10 sul display ma
  -- 10 sulla traccia, cioe' 5 percepiti.
  local sp = tonumber(musicPlayerSpeed) or 1
  if sp <= 0 then sp = 1 end
  local newPos = sound.TimePosition + ((tonumber(delta) or 0) * sp)
  if newPos < 0 then newPos = 0 end
  if len > 0 and newPos > (len - 0.2) then newPos = math.max(len - 0.2, 0) end
  pcall(function() sound.TimePosition = newPos end)
  if len > 0 and (len - newPos) > 1.8 then
    pcall(function()
      sound:SetAttribute("_amFaded", false)
      sound.Volume = musicPlayerVolume
    end)
  end
  _VxyroImportedMusicRefreshUI()
end

-- Velocita': stesso schema del volume. Si arrotonda al decimo cosi' i
-- click di < e > non accumulano errore in virgola mobile (0.1 + 0.2 ...).
function _VxyroImportedMusicSetSpeed(v)
  v = math.clamp(math.floor((tonumber(v) or 1) * 10 + 0.5) / 10, 0.1, 2)
  musicPlayerSpeed = v
  local sound = _musicPlayerSound
  if sound and sound.Parent then
    pcall(function() sound.PlaybackSpeed = v end)
  end
  if F.saveConfig then pcall(F.saveConfig) end
  _VxyroImportedMusicRefreshUI()
end

function _VxyroImportedMusicSetVolume(v)
  v = math.clamp(math.floor((tonumber(v) or 1) * 100 + 0.5) / 100, 0, 2)
  musicPlayerVolume = v
  local sound = _musicPlayerSound
  if sound and sound.Parent and sound:GetAttribute("_amFaded") ~= true then
    pcall(function() sound.Volume = v end)
  end
  if F.saveConfig then pcall(F.saveConfig) end
  _VxyroImportedMusicRefreshUI()
end

  -- Safe wrappers for source popup helper calls.
  -- The source UI assumes the helper exists in the same lexical scope.
  local mpGui = nil

  function _VxyroImportedMusicClose()
    _G.AmbitiousMusicRefreshUI = nil
    if mpGui and mpGui.Parent then
      local fr = mpGui:FindFirstChild("Frame")
      if fr then
        pcall(function()
          VXYRO_TweenService:Create(fr, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end)
      end
      local g = mpGui
      mpGui = nil
      task.delay(0.25, function()
        pcall(function() if g and g.Parent then g:Destroy() end end)
      end)
    else
      mpGui = nil
    end
    if _G.VxyroMusicToggleVisual then
      pcall(_G.VxyroMusicToggleVisual, false)
    end
  end
  _G.AmbitiousMusicCloseUI = _VxyroImportedMusicClose

  local function _mpFmtTime(t)
    t = math.max(0, math.floor(tonumber(t) or 0))
    return string.format("%d:%02d", math.floor(t / 60), t % 60)
  end

  local function _mpSmallBtn(parent, name, text, size, pos, textSize)
    local b = Instance.new("TextButton")
    b.Name = name
    b.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    b.BackgroundTransparency = 0.05
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = textSize or 13
    b.Font = Enum.Font.GothamBlack
    b.TextXAlignment = Enum.TextXAlignment.Center
    b.TextYAlignment = Enum.TextYAlignment.Center
    b.AutoButtonColor = false
    b.Size = size
    b.Position = pos
    b.ZIndex = 6
    b.Parent = parent
    corner(b, 10)
    stroke(b, Color3.fromRGB(82, 82, 82), 1, 0.5)
    b.MouseEnter:Connect(function()
      VXYRO_tween(b, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}, 0.1)
    end)
    b.MouseLeave:Connect(function()
      VXYRO_tween(b, {BackgroundColor3 = Color3.fromRGB(7, 7, 7)}, 0.1)
    end)
    return b
  end

  local function _mpToggleRow(parent, labelText, getVal, setVal, yPos)
    local f = Instance.new("Frame")
    f.Name = labelText
    f.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    f.BackgroundTransparency = 0.1
    f.BorderSizePixel = 0
    f.Size = UDim2.new(1, -24, 0, 36)
    f.Position = UDim2.new(0, 12, 0, yPos)
    f.ZIndex = 4
    f.Parent = parent
    corner(f, 9)
    stroke(f, Color3.fromRGB(82, 82, 82), 1, 0.45)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency = 0.35
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -92, 1, 0)
    lbl.ZIndex = 5
    lbl.Parent = f

    local pillBg = Instance.new("Frame")
    pillBg.Name = "PillBg"
    pillBg.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    pillBg.BackgroundTransparency = 0
    pillBg.BorderSizePixel = 0
    pillBg.Size = UDim2.new(0, 60, 0, 24)
    pillBg.Position = UDim2.new(1, -72, 0.5, -12)
    pillBg.ZIndex = 5
    pillBg.Parent = f
    corner(pillBg, 12)

    local pillBgStroke = Instance.new("UIStroke")
    pillBgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pillBgStroke.Color = Color3.fromRGB(82, 82, 82)
    pillBgStroke.Thickness = 1
    pillBgStroke.Transparency = 0.5
    pillBgStroke.Parent = pillBg

    local pillBgGrad = Instance.new("UIGradient")
    pillBgGrad.Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
      ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 245, 245)),
      ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120)),
    })
    pillBgGrad.Rotation = 18
    pillBgGrad.Enabled = false
    pillBgGrad.Parent = pillBg
  
    local pill = Instance.new("TextButton")
    pill.Name = "Pill"
    pill.BackgroundTransparency = 1
    pill.BorderSizePixel = 0
    pill.Text = "OFF"
    pill.TextColor3 = Color3.fromRGB(175, 175, 175)
    pill.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    pill.TextStrokeTransparency = 0.35
    pill.TextSize = 11
    pill.Font = Enum.Font.GothamBlack
    pill.AutoButtonColor = false
    pill.Size = UDim2.new(0, 60, 0, 24)
    pill.Position = UDim2.new(1, -72, 0.5, -12)
    pill.ZIndex = 7
    pill.Parent = f
    corner(pill, 12)

    local function apply(v)
      local onBase = Color3.fromRGB(245, 245, 245)
      local onEdge = Color3.fromRGB(235, 235, 235)
      if v then
        pill.Text = "ON"
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pillBg.BackgroundColor3 = onBase
        pillBgGrad.Enabled = true
        pillBgStroke.Color = onEdge
        pillBgStroke.Transparency = 0.15
      else
        pill.Text = "OFF"
        pill.TextColor3 = Color3.fromRGB(175, 175, 175)
        pillBg.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
        pillBgGrad.Enabled = false
        pillBgStroke.Color = Color3.fromRGB(82, 82, 82)
        pillBgStroke.Transparency = 0.5
      end
    end

    apply(getVal() == true)
    pill.MouseButton1Click:Connect(function()
      local nv = not (getVal() == true)
      setVal(nv)
      apply(nv)
    end)

    pill.MouseEnter:Connect(function()
      VXYRO_tween(pillBg, {Size = UDim2.new(0, 66, 0, 28), Position = UDim2.new(1, -75, 0.5, -14)}, 0.12)
      VXYRO_tween(pill, {Size = UDim2.new(0, 66, 0, 28), Position = UDim2.new(1, -75, 0.5, -14)}, 0.12)
    end)
    pill.MouseLeave:Connect(function()
      VXYRO_tween(pillBg, {Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -72, 0.5, -12)}, 0.12)
      VXYRO_tween(pill, {Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -72, 0.5, -12)}, 0.12)
    end)

    return f, apply
  end

  -- Use the original source UI body, adapted to Vxyro services/helpers.

function _VxyroImportedMusicOpen()
  if mpGui and mpGui.Parent then return end

  mpGui = Instance.new("ScreenGui")
  mpGui.Name = "AmbitiousHubMusicPlayer"
  mpGui.ResetOnSpawn = false
  mpGui.IgnoreGuiInset = true
  mpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  mpGui.DisplayOrder = 9999
  mpGui.Parent = getPopupParent()

  local backdrop = Instance.new("Frame")
  backdrop.Name = "Backdrop"
  backdrop.Size = UDim2.new(1, 0, 1, 0)
  backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  backdrop.BackgroundTransparency = 0.46
  backdrop.BorderSizePixel = 0
  backdrop.ZIndex = 1
  backdrop.Parent = mpGui

  -- Pannello piu' arioso: header -> now playing -> progress -> controlli
  -- -> opzioni -> volume/speed -> playlist.
  local W, H = 392, 590
  local frame = Instance.new("Frame")
  frame.Name = "Frame"
  frame.Size = UDim2.new(0, W, 0, H)
  frame.AnchorPoint = Vector2.new(0.5, 0.5)
  frame.Position = UDim2.new(0.5, 0, 0.5, 0)
  frame.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
  frame.BorderSizePixel = 0
  frame.ZIndex = 2
  frame.Parent = mpGui

  local mpScale = Instance.new("UIScale")
  mpScale.Name = "MusicPlayerScale"
  mpScale.Scale = 0.78
  mpScale.Parent = frame

  corner(frame, 20)
  stroke(frame, Color3.fromRGB(92, 92, 96), 1.2, 0.18)
  local mpGlow = Instance.new("UIStroke")
  mpGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  mpGlow.Color = Color3.fromRGB(225, 225, 235)
  mpGlow.Thickness = 7
  mpGlow.Transparency = 0.965
  mpGlow.Parent = frame
  VXYRO_TweenService:Create(mpGlow, TweenInfo.new(1.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.90}):Play()

  local mpBgGrad = Instance.new("UIGradient")
  mpBgGrad.Name = "BackgroundGradient"
  mpBgGrad.Rotation = 115
  mpBgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 24)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(8, 8, 11)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 18)),
  })
  mpBgGrad.Parent = frame

  local innerStroke = Instance.new("UIStroke")
  innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  innerStroke.Color = Color3.fromRGB(255, 255, 255)
  innerStroke.Thickness = 0.6
  innerStroke.Transparency = 0.9
  innerStroke.Parent = frame

  local topGlow = Instance.new("Frame")
  topGlow.Name = "TopGlow"
  topGlow.Size = UDim2.new(1, -24, 0, 4)
  topGlow.Position = UDim2.new(0, 12, 0, 48)
  topGlow.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
  topGlow.BorderSizePixel = 0
  topGlow.ZIndex = 4
  topGlow.Parent = frame
  corner(topGlow, 2)
  local topGrad = Instance.new("UIGradient")
  topGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 110, 110)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 110, 110)),
  })
  topGrad.Parent = topGlow

  local title = Instance.new("TextLabel")
  title.Name = "Title"
  title.BackgroundTransparency = 1
  title.Text = "MUSIC PLAYER"
  title.TextColor3 = Color3.fromRGB(255, 255, 255)
  title.Font = Enum.Font.GothamBlack
  title.TextSize = 14
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.Size = UDim2.new(1, -72, 0, 42)
  title.Position = UDim2.new(0, 16, 0, 4)
  title.ZIndex = 4
  title.Parent = frame

  local subtitle = Instance.new("TextLabel")
  subtitle.Name = "Subtitle"
  subtitle.BackgroundTransparency = 1
  subtitle.Text = "NOW PLAYING"
  subtitle.TextColor3 = Color3.fromRGB(155, 155, 155)
  subtitle.Font = Enum.Font.GothamBold
  subtitle.TextSize = 9
  subtitle.TextXAlignment = Enum.TextXAlignment.Left
  subtitle.Size = UDim2.new(0, 110, 0, 14)
  subtitle.Position = UDim2.new(0, 17, 0, 34)
  subtitle.ZIndex = 4
  subtitle.Parent = frame

  local closeBtn = Instance.new("TextButton")
  closeBtn.Name = "CloseBtn"
  closeBtn.Size = UDim2.new(0, 34, 0, 34)
  closeBtn.Position = UDim2.new(1, -46, 0, 8)
  closeBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
  closeBtn.BorderSizePixel = 0
  closeBtn.Text = "X"
  closeBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
  closeBtn.Font = Enum.Font.GothamBlack
  closeBtn.TextSize = 13
  closeBtn.AutoButtonColor = false
  closeBtn.ZIndex = 5
  closeBtn.Parent = frame
  corner(closeBtn, 10)
  stroke(closeBtn, Color3.fromRGB(88, 88, 88), 1, 0.4)
  closeBtn.MouseEnter:Connect(function() VXYRO_tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(54, 54, 54)}, 0.12) end)
  closeBtn.MouseLeave:Connect(function() VXYRO_tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}, 0.12) end)
  closeBtn.Activated:Connect(_VxyroImportedMusicClose)

  local nowCard = Instance.new("Frame")
  nowCard.Name = "NowPlaying"
  nowCard.Size = UDim2.new(1, -24, 0, 84)
  nowCard.Position = UDim2.new(0, 12, 0, 62)
  nowCard.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
  nowCard.BorderSizePixel = 0
  nowCard.ZIndex = 3
  nowCard.Parent = frame
  corner(nowCard, 14)
  stroke(nowCard, Color3.fromRGB(72, 72, 72), 1, 0.4)
  local nowGlow = Instance.new("UIStroke")
  nowGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  nowGlow.Color = Color3.fromRGB(205, 205, 215)
  nowGlow.Thickness = 4
  nowGlow.Transparency = 0.965
  nowGlow.Parent = nowCard
  VXYRO_TweenService:Create(nowGlow, TweenInfo.new(1.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.925}):Play()

  local disk = Instance.new("Frame")
  disk.Name = "Artwork"
  disk.Size = UDim2.new(0, 58, 0, 58)
  disk.Position = UDim2.new(0, 12, 0.5, -29)
  disk.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
  disk.BorderSizePixel = 0
  disk.ZIndex = 4
  disk.Parent = nowCard
  corner(disk, 16)
  local diskGrad = Instance.new("UIGradient")
  diskGrad.Rotation = 35
  diskGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 115, 115)),
  })
  diskGrad.Parent = disk

  local diskText = Instance.new("TextLabel")
  diskText.BackgroundTransparency = 1
  diskText.Size = UDim2.new(1, 0, 1, 0)
  diskText.Text = "♪"
  diskText.TextColor3 = Color3.fromRGB(255, 255, 255)
  diskText.TextSize = 25
  diskText.Font = Enum.Font.GothamBlack
  diskText.ZIndex = 5
  diskText.Parent = disk

  local nameLbl = Instance.new("TextLabel")
  nameLbl.Name = "SongName"
  nameLbl.BackgroundTransparency = 1
  nameLbl.Text = _VxyroImportedMusicGetSongName()
  nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
  nameLbl.Font = Enum.Font.GothamBlack
  nameLbl.TextSize = 16
  nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
  nameLbl.TextXAlignment = Enum.TextXAlignment.Left
  nameLbl.Size = UDim2.new(1, -92, 0, 26)
  nameLbl.Position = UDim2.new(0, 84, 0, 16)
  nameLbl.ZIndex = 5
  nameLbl.Parent = nowCard

  local counterLbl = Instance.new("TextLabel")
  counterLbl.Name = "TrackCounter"
  counterLbl.BackgroundTransparency = 1
  counterLbl.Text = "TRACK 1 / " .. tostring(#_VxyroImportedMusicOptions)
  counterLbl.TextColor3 = Color3.fromRGB(150, 150, 168)
  counterLbl.Font = Enum.Font.GothamBold
  counterLbl.TextSize = 9
  counterLbl.TextXAlignment = Enum.TextXAlignment.Left
  counterLbl.Size = UDim2.new(1, -92, 0, 14)
  counterLbl.Position = UDim2.new(0, 84, 0, 45)
  counterLbl.ZIndex = 5
  counterLbl.Parent = nowCard

  local barBg = Instance.new("Frame")
  barBg.Name = "ProgressBg"
  barBg.Size = UDim2.new(1, -30, 0, 7)
  barBg.Position = UDim2.new(0, 15, 0, 158)
  barBg.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
  barBg.BorderSizePixel = 0
  barBg.ZIndex = 4
  barBg.Parent = frame
  corner(barBg, 4)

  local barFill = Instance.new("Frame")
  barFill.Name = "ProgressFill"
  barFill.Size = UDim2.new(0, 0, 1, 0)
  barFill.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
  barFill.BorderSizePixel = 0
  barFill.ZIndex = 5
  barFill.Parent = barBg
  corner(barFill, 4)
  local barGrad = Instance.new("UIGradient")
  barGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 135, 135)),
  })
  barGrad.Parent = barFill

  local curLbl = Instance.new("TextLabel")
  curLbl.BackgroundTransparency = 1
  curLbl.Text = "0:00"
  curLbl.TextColor3 = Color3.fromRGB(145, 145, 145)
  curLbl.Font = Enum.Font.GothamBold
  curLbl.TextSize = 9
  curLbl.TextXAlignment = Enum.TextXAlignment.Left
  curLbl.Size = UDim2.new(0, 55, 0, 14)
  curLbl.Position = UDim2.new(0, 14, 0, 168)
  curLbl.ZIndex = 4
  curLbl.Parent = frame

  local totLbl = curLbl:Clone()
  totLbl.Name = "TotalTime"
  totLbl.TextXAlignment = Enum.TextXAlignment.Right
  totLbl.Position = UDim2.new(1, -69, 0, 168)
  totLbl.Parent = frame

  local ctrl = Instance.new("Frame")
  ctrl.Name = "Controls"
  ctrl.BackgroundTransparency = 1
  ctrl.Size = UDim2.new(1, -24, 0, 52)
  ctrl.Position = UDim2.new(0, 12, 0, 188)
  ctrl.ZIndex = 4
  ctrl.Parent = frame

  local prevBtn = _mpSmallBtn(ctrl, "PrevSong", "PREV", UDim2.new(0, 62, 0, 36), UDim2.new(0, 0, 0, 8), 9)
  local backBtn = _mpSmallBtn(ctrl, "Back10", "-10", UDim2.new(0, 46, 0, 36), UDim2.new(0.5, -106, 0, 8), 10)
  local nextBtn = _mpSmallBtn(ctrl, "NextSong", "NEXT", UDim2.new(0, 62, 0, 36), UDim2.new(1, -62, 0, 8), 9)
  local fwdBtn = _mpSmallBtn(ctrl, "Fwd10", "+10", UDim2.new(0, 46, 0, 36), UDim2.new(0.5, 60, 0, 8), 10)

  local playHolder = Instance.new("Frame")
  playHolder.Name = "PlayHolder"
  playHolder.Size = UDim2.new(0, 64, 0, 46)
  playHolder.Position = UDim2.new(0.5, -32, 0, 3)
  playHolder.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
  playHolder.BorderSizePixel = 0
  playHolder.ZIndex = 6
  playHolder.Parent = ctrl
  corner(playHolder, 14)
  stroke(playHolder, Color3.fromRGB(230, 230, 230), 1.4, 0.15)
  local playGrad = Instance.new("UIGradient")
  playGrad.Rotation = 20
  playGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125)),
  })
  playGrad.Parent = playHolder
  local playBtn = Instance.new("TextButton")
  playBtn.Name = "PlayPause"
  playBtn.Size = UDim2.new(1, 0, 1, 0)
  playBtn.BackgroundTransparency = 1
  playBtn.BorderSizePixel = 0
  playBtn.Text = "PLAY"
  playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  playBtn.Font = Enum.Font.GothamBlack
  playBtn.TextSize = 10
  playBtn.AutoButtonColor = false
  playBtn.ZIndex = 7
  playBtn.Parent = playHolder
  playBtn.Activated:Connect(function() _VxyroImportedMusicPauseToggle() end)
  for _, pair in ipairs({
    {prevBtn, function() _VxyroImportedMusicPrev() end},
    {nextBtn, function() _VxyroImportedMusicNext() end},
    {backBtn, function() _VxyroImportedMusicSeek(-10) end},
    {fwdBtn, function() _VxyroImportedMusicSeek(10) end},
  }) do
    pair[1].Activated:Connect(pair[2])
  end

  local optBar = Instance.new("Frame")
  optBar.Name = "Options"
  optBar.BackgroundTransparency = 1
  optBar.Size = UDim2.new(1, -24, 0, 38)
  optBar.Position = UDim2.new(0, 12, 0, 246)
  optBar.ZIndex = 4
  optBar.Parent = frame

  local function optPill(labelText, getVal, setVal, x)
    local b = Instance.new("TextButton")
    b.Name = labelText:gsub("%s", "")
    b.Size = UDim2.new(1/3, -8, 1, 0)
    b.Position = UDim2.new(x, 4, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.ZIndex = 5
    b.Parent = optBar
    corner(b, 11)
    stroke(b, Color3.fromRGB(75, 75, 90), 1, 0.5)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 9, 0.5, -3.5)
    dot.BackgroundColor3 = Color3.fromRGB(82, 82, 82)
    dot.BorderSizePixel = 0
    dot.ZIndex = 6
    dot.Parent = b
    corner(dot, 4)
    local tx = Instance.new("TextLabel")
    tx.BackgroundTransparency = 1
    tx.Text = labelText
    tx.TextColor3 = Color3.fromRGB(205, 205, 205)
    tx.Font = Enum.Font.GothamBold
    tx.TextSize = 9
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.Size = UDim2.new(1, -22, 1, 0)
    tx.Position = UDim2.new(0, 21, 0, 0)
    tx.ZIndex = 6
    tx.Parent = b
    local function paint(on)
      local ac = _G._VxyroMusicAccent or (S.themeColor or Color3.fromRGB(245,245,247))
      dot.BackgroundColor3 = on and ac or Color3.fromRGB(82, 82, 82)
      tx.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(165, 165, 165)
      VXYRO_tween(b, {BackgroundColor3 = on and ac:Lerp(Color3.new(0,0,0), 0.58) or Color3.fromRGB(20, 20, 26)}, 0.12)
    end
    b.Activated:Connect(function() setVal(not getVal()); paint(getVal()) end)
    return paint
  end

  local paintAuto = optPill("AUTO NEXT", function() return musicAutoPlayNext end, function(v) musicAutoPlayNext = v; if F and F.saveConfig then pcall(F.saveConfig) end end, 0)
  local paintShuffle = optPill("SHUFFLE", function() return musicShuffleEnabled end, function(v) musicShuffleEnabled = v; if F and F.saveConfig then pcall(F.saveConfig) end end, 1/3)
  local paintLoop = optPill("LOOP", function() return musicLoopEnabled end, function(v) musicLoopEnabled = v; if F and F.saveConfig then pcall(F.saveConfig) end end, 2/3)

  local function adjustRow(name, labelText, valueText, downFn, upFn, y)
    local row = Instance.new("Frame")
    row.Name = name
    row.Size = UDim2.new(1, -24, 0, 34)
    row.Position = UDim2.new(0, 12, 0, y)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BorderSizePixel = 0
    row.ZIndex = 4
    row.Parent = frame
    corner(row, 10)
    stroke(row, Color3.fromRGB(68, 68, 68), 1, 0.52)
    local lab = Instance.new("TextLabel")
    lab.BackgroundTransparency = 1
    lab.Text = labelText
    lab.TextColor3 = Color3.fromRGB(222, 222, 232)
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 10
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Size = UDim2.new(1, -126, 1, 0)
    lab.Position = UDim2.new(0, 12, 0, 0)
    lab.ZIndex = 5
    lab.Parent = row

    local down = _mpSmallBtn(row, name .. "Down", "-", UDim2.new(0, 25, 0, 24), UDim2.new(1, -111, 0.5, -12), 12)
    local val = Instance.new("TextLabel")
    val.Name = "Value"
    val.Size = UDim2.new(0, 50, 0, 24)
    val.Position = UDim2.new(1, -82, 0.5, -12)
    val.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
    val.BorderSizePixel = 0
    val.Text = valueText()
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.Font = Enum.Font.GothamBlack
    val.TextSize = 10
    val.ZIndex = 5
    val.Parent = row
    corner(val, 7)
    stroke(val, Color3.fromRGB(82, 82, 82), 1, 0.55)
    local up = _mpSmallBtn(row, name .. "Up", "+", UDim2.new(0, 25, 0, 24), UDim2.new(1, -40, 0.5, -12), 12)
    down.Activated:Connect(function() downFn(); val.Text = valueText() end)
    up.Activated:Connect(function() upFn(); val.Text = valueText() end)
    return val
  end

  local volValue = adjustRow("Volume", "VOLUME", function() return string.format("%.2f", musicPlayerVolume) end, function() _VxyroImportedMusicSetVolume(musicPlayerVolume - 0.05) end, function() _VxyroImportedMusicSetVolume(musicPlayerVolume + 0.05) end, 292)
  local spdValue = adjustRow("Speed", "PLAYBACK SPEED", function() return string.format("%.1fx", musicPlayerSpeed) end, function() _VxyroImportedMusicSetSpeed(musicPlayerSpeed - 0.1) end, function() _VxyroImportedMusicSetSpeed(musicPlayerSpeed + 0.1) end, 332)

  local playlistHead = Instance.new("TextLabel")
  playlistHead.Name = "PlaylistTitle"
  playlistHead.BackgroundTransparency = 1
  playlistHead.Text = "PLAYLIST"
  playlistHead.TextColor3 = Color3.fromRGB(185, 185, 185)
  playlistHead.Font = Enum.Font.GothamBold
  playlistHead.TextSize = 9
  playlistHead.TextXAlignment = Enum.TextXAlignment.Left
  playlistHead.Position = UDim2.new(0, 14, 0, 374)
  playlistHead.Size = UDim2.new(1, -28, 0, 14)
  playlistHead.ZIndex = 4
  playlistHead.Parent = frame

  local search = Instance.new("TextBox")
  search.Name = "Search"
  search.Size = UDim2.new(1, -24, 0, 30)
  search.Position = UDim2.new(0, 12, 0, 390)
  search.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
  search.BorderSizePixel = 0
  search.Text = ""
  search.PlaceholderText = "Search song..."
  search.PlaceholderColor3 = Color3.fromRGB(105, 105, 105)
  search.TextColor3 = Color3.fromRGB(240, 240, 240)
  search.Font = Enum.Font.Gotham
  search.TextSize = 10
  search.ClearTextOnFocus = false
  search.ZIndex = 5
  search.Parent = frame
  corner(search, 9)
  stroke(search, Color3.fromRGB(68, 68, 68), 1, 0.55)
  search.TextXAlignment = Enum.TextXAlignment.Left
  search.Position = UDim2.new(0, 12, 0, 390)

  local list = Instance.new("ScrollingFrame")
  list.Name = "Playlist"
  list.Size = UDim2.new(1, -24, 0, 152)
  list.Position = UDim2.new(0, 12, 0, 426)
  list.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
  list.BorderSizePixel = 0
  list.ScrollBarThickness = 3
  list.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
  list.CanvasSize = UDim2.new(0, 0, 0, 0)
  list.ZIndex = 4
  list.Parent = frame
  corner(list, 11)
  stroke(list, Color3.fromRGB(60, 60, 60), 1, 0.55)

  local layout = Instance.new("UIListLayout")
  layout.Padding = UDim.new(0, 5)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  layout.Parent = list

  local function rebuildPlaylist()
    for _, child in ipairs(list:GetChildren()) do
      if child:IsA("TextButton") then child:Destroy() end
    end
    local q = string.lower(search.Text or "")
    local count = 0
    for i, opt in ipairs(_VxyroImportedMusicOptions) do
      if q == "" or string.find(string.lower(opt.name), q, 1, true) then
        count = count + 1
        local b = Instance.new("TextButton")
        b.Name = "Track" .. tostring(i)
        b.LayoutOrder = count
        b.Size = UDim2.new(1, -10, 0, 28)
        local _mac = _G._VxyroMusicAccent or (S.themeColor or Color3.fromRGB(245,245,247))
        b.BackgroundColor3 = (i == selectedMusicSong) and _mac:Lerp(Color3.new(0,0,0), 0.58) or Color3.fromRGB(20, 20, 20)
        b.BorderSizePixel = 0
        b.Text = string.format("%02d  %s", i, opt.name)
        b.TextColor3 = (i == selectedMusicSong) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 190, 190)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 9
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.AutoButtonColor = false
        b.ZIndex = 5
        b.Parent = list
        corner(b, 8)
        b.Activated:Connect(function()
          selectedMusicSong = i
          _VxyroImportedMusicPlay(i)
          rebuildPlaylist()
        end)
      end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, count * 33 + 6)
  end
  rebuildPlaylist()
  search:GetPropertyChangedSignal("Text"):Connect(rebuildPlaylist)

  local function refresh()
    if not (mpGui and mpGui.Parent) then return end
    nameLbl.Text = _VxyroImportedMusicGetSongName()
    counterLbl.Text = "TRACK " .. tostring(selectedMusicSong) .. " / " .. tostring(#_VxyroImportedMusicOptions)
    volValue.Text = string.format("%.2f", musicPlayerVolume)
    spdValue.Text = string.format("%.1fx", musicPlayerSpeed)
    paintAuto(musicAutoPlayNext == true)
    paintShuffle(musicShuffleEnabled == true)
    paintLoop(musicLoopEnabled == true)
    local sound = _musicPlayerSound
    local alive = sound and sound.Parent
    playBtn.Text = (alive and sound.IsPlaying) and "PAUSE" or "PLAY"
    if alive then
      local sp = tonumber(musicPlayerSpeed) or 1
      if sp <= 0 then sp = 1 end
      local len = (sound.TimeLength or 0) / sp
      local pos = (sound.TimePosition or 0) / sp
      if len > 0 then
        barFill.Size = UDim2.new(math.clamp(pos / len, 0, 1), 0, 1, 0)
        curLbl.Text = _mpFmtTime(pos)
        totLbl.Text = _mpFmtTime(len)
      else
        barFill.Size = UDim2.new(0, 0, 1, 0)
        curLbl.Text = "0:00"
        totLbl.Text = "--:--"
      end
    else
      barFill.Size = UDim2.new(0, 0, 1, 0)
      curLbl.Text = "0:00"
      totLbl.Text = "0:00"
    end
  end

  -- Music Player uses the same accent as the main Vxyro theme while keeping
  -- its monochrome base. The hook updates the live window immediately.
  _G._VxyroImportedMusicApplyAccent = function(col)
    pcall(function() mpGlow.Color = col; nowGlow.Color = col end)
    if typeof(col) ~= "Color3" then return end
    _G._VxyroMusicAccent = col
    if not (mpGui and mpGui.Parent and frame and frame.Parent) then return end
    pcall(function()
      local dark = col:Lerp(Color3.new(0,0,0), 0.58)
      local soft = col:Lerp(Color3.new(1,1,1), 0.22)
      local fs = frame:FindFirstChildOfClass("UIStroke")
      if fs then fs.Color = col end
      if innerStroke then innerStroke.Color = col end
      if topGlow then topGlow.BackgroundColor3 = col end
      if topGrad then
        topGrad.Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, col:Lerp(Color3.new(0,0,0), 0.42)),
          ColorSequenceKeypoint.new(0.5, col:Lerp(Color3.new(1,1,1), 0.35)),
          ColorSequenceKeypoint.new(1, col:Lerp(Color3.new(0,0,0), 0.42)),
        })
      end
      if disk then disk.BackgroundColor3 = col end
      if diskGrad then
        diskGrad.Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, col:Lerp(Color3.new(1,1,1), 0.18)),
          ColorSequenceKeypoint.new(1, col:Lerp(Color3.new(0,0,0), 0.35)),
        })
      end
      if barFill then barFill.BackgroundColor3 = col end
      if barGrad then
        barGrad.Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, col:Lerp(Color3.new(1,1,1), 0.08)),
          ColorSequenceKeypoint.new(1, col:Lerp(Color3.new(0,0,0), 0.30)),
        })
      end
      if playHolder then
        playHolder.BackgroundColor3 = col
        local st = playHolder:FindFirstChildOfClass("UIStroke")
        if st then st.Color = soft end
      end
      for _, obj in ipairs({nowCard, barBg}) do
        if obj then
          local st = obj:FindFirstChildOfClass("UIStroke")
          if st then st.Color = col end
        end
      end
      for _, n in ipairs({"PrevSong","Back10","NextSong","Fwd10"}) do
        local b = ctrl and ctrl:FindFirstChild(n)
        if b then
          local st = b:FindFirstChildOfClass("UIStroke")
          if st then st.Color = col end
        end
      end
      if closeBtn then
        local st = closeBtn:FindFirstChildOfClass("UIStroke")
        if st then st.Color = col end
      end
      for _, d in ipairs(optBar:GetChildren()) do
        if d:IsA("TextButton") then
          local st = d:FindFirstChildOfClass("UIStroke")
          if st then st.Color = col end
          local isOn = (d.Name == "AUTONEXT" and musicAutoPlayNext) or (d.Name == "SHUFFLE" and musicShuffleEnabled) or (d.Name == "LOOP" and musicLoopEnabled)
          if isOn then d.BackgroundColor3 = dark end
        end
      end
      for _, d in ipairs(list:GetChildren()) do
        if d:IsA("TextButton") and d.Name == ("Track" .. tostring(selectedMusicSong)) then
          d.BackgroundColor3 = dark
          d.TextColor3 = Color3.fromRGB(255,255,255)
          local st = d:FindFirstChildOfClass("UIStroke")
          if st then st.Color = col end
        end
      end
    end)
  end
  _G._VxyroImportedMusicApplyAccent(S.themeColor or Color3.fromRGB(245,245,247))

  _G.AmbitiousMusicRefreshUI = refresh
  refresh()
  rebuildPlaylist()

  task.spawn(function()
    while mpGui and mpGui.Parent do
      pcall(refresh)
      task.wait(0.2)
    end
  end)

  backdrop.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      _VxyroImportedMusicClose()
    end
  end)

  frame.Size = UDim2.new(0, 0, 0, 0)
  frame.Position = UDim2.new(0.5, 0, 0.5, 0)
  VXYRO_TweenService:Create(frame, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, W, 0, H),
    Position = UDim2.new(0.5, 0, 0.5, 0)
  }):Play()
end
  local fontPickerGui = nil
  local fontPickerClosing = false

  local function closeFontPicker()
    local g = fontPickerGui
    if not (g and g.Parent) then
      fontPickerGui = nil
      fontPickerClosing = false
      return
    end
    if fontPickerClosing then return end
    fontPickerClosing = true

    -- Release the singleton immediately so a new OPEN/PICK cannot stack a
    -- second picker behind the closing one. The screen is disabled during
    -- the exit animation, so it can no longer intercept touches.
    if fontPickerGui == g then fontPickerGui = nil end
    pcall(function() g.Enabled = false end)

    local fr = g:FindFirstChild("Frame")
    if fr then
      pcall(function() fr.BackgroundTransparency = 1 end)
    end
    pcall(function() g:Destroy() end)
    fontPickerClosing = false
  end
  _G.AmbitiousFontPickerClose = closeFontPicker

  -- ---------------- FONT PICKER ----------------

function _VxyroImportedOpenFontPicker()
      -- Singleton: never create stacked Font Picker ScreenGuis. If one is
      -- already open, keep it and bring it to the front instead.
      if fontPickerGui and fontPickerGui.Parent then
        pcall(function() fontPickerGui.Enabled = true end)
        pcall(function() fontPickerGui.DisplayOrder = 9999 end)
        return true
      end
      fontPickerGui = nil
      fontPickerClosing = false

      -- Cleanup an orphaned picker left by an earlier failed close.
      pcall(function()
        local parent = getPopupParent()
        local old = parent and parent:FindFirstChild("AmbitiousHubFontPicker")
        if old then old:Destroy() end
      end)

      fontPickerGui = Instance.new("ScreenGui")
      fontPickerGui.Name = "AmbitiousHubFontPicker"
      fontPickerGui.ResetOnSpawn = false
      fontPickerGui.IgnoreGuiInset = true
      fontPickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
      fontPickerGui.DisplayOrder = 9999
      fontPickerGui.Parent = getPopupParent()
      local fpGui = fontPickerGui

      local fpBack = Instance.new("Frame")
      fpBack.Name = "Backdrop"
      fpBack.Size = UDim2.new(1, 0, 1, 0)
      fpBack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
      fpBack.BackgroundTransparency = 0.45
      fpBack.BorderSizePixel = 0
      fpBack.ZIndex = 1
      fpBack.Active = true
      fpBack.Parent = fpGui

      local fpFrame = Instance.new("Frame")
      fpFrame.Name = "Frame"
      fpFrame.Size = UDim2.new(0, 320, 0, 440)
      fpFrame.Position = UDim2.new(0.5, -160, 0.5, -220)
      fpFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
      fpFrame.BorderSizePixel = 0
      fpFrame.ZIndex = 2
      fpFrame.Parent = fpGui
      corner(fpFrame, 14)
      stroke(fpFrame, Color3.fromRGB(90, 90, 105), 1.2, 0.3)

      local fpBar = Instance.new("Frame")
      fpBar.Name = "TitleBar"
      fpBar.Size = UDim2.new(1, 0, 0, 44)
      fpBar.Position = UDim2.new(0, 0, 0, 0)
      fpBar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
      fpBar.BackgroundTransparency = 0.15
      fpBar.BorderSizePixel = 0
      fpBar.ZIndex = 3
      fpBar.Parent = fpFrame
      corner(fpBar, 14)

      local fpTitle = Instance.new("TextLabel")
      fpTitle.Name = "Title"
      fpTitle.Size = UDim2.new(1, -54, 1, 0)
      fpTitle.Position = UDim2.new(0, 14, 0, 0)
      fpTitle.BackgroundTransparency = 1
      fpTitle.Text = "SELECT FONT"
      fpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
      fpTitle.Font = Enum.Font.GothamBlack
      fpTitle.TextSize = 14
      fpTitle.TextXAlignment = Enum.TextXAlignment.Left
      fpTitle.ZIndex = 4
      fpTitle.Parent = fpBar

      local fpClose = Instance.new("TextButton")
      fpClose.Name = "CloseBtn"
      fpClose.Size = UDim2.new(0, 32, 0, 32)
      fpClose.Position = UDim2.new(1, -44, 0, 6)
      fpClose.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
      fpClose.BackgroundTransparency = 0.1
      fpClose.BorderSizePixel = 0
      fpClose.Text = "X"
      fpClose.TextColor3 = Color3.fromRGB(255, 255, 255)
      fpClose.Font = Enum.Font.GothamBlack
      fpClose.TextSize = 12
      fpClose.AutoButtonColor = false
      fpClose.ZIndex = 20
      fpClose.Parent = fpBar
      corner(fpClose, 10)
      stroke(fpClose, Color3.fromRGB(90, 90, 105), 1, 0.4)

      fpClose.MouseEnter:Connect(function()
        VXYRO_tween(fpClose, {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}, 0.12)
      end)
      fpClose.MouseLeave:Connect(function()
        VXYRO_tween(fpClose, {BackgroundColor3 = Color3.fromRGB(25, 25, 28)}, 0.12)
      end)
      fpClose.Activated:Connect(closeFontPicker)

      local fpScroll = Instance.new("ScrollingFrame")
      fpScroll.Name = "Scroll"
      fpScroll.Size = UDim2.new(1, -14, 1, -58)
      fpScroll.Position = UDim2.new(0, 7, 0, 50)
      fpScroll.BackgroundTransparency = 1
      fpScroll.BorderSizePixel = 0
      fpScroll.ScrollBarThickness = 4
      fpScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
      fpScroll.ZIndex = 3
      fpScroll.Parent = fpFrame

      -- RIUSO DELLE CARD (niente UIGridLayout)
      -- I font sono centinaia: creare una card per ognuno vuol dire
      -- migliaia di istanze in un colpo solo, ed e' quello lo scatto
      -- all'apertura. Qui le card create sono solo quelle che entrano
      -- nello schermo piu' una riga di margine: scorrendo non se ne
      -- creano altre, si riscrive il contenuto di quelle che ci sono.
      -- La griglia viene calcolata a mano perche' un UIGridLayout
      -- pretenderebbe che tutte le celle esistessero davvero: le misure
      -- pero' sono identiche a quelle dello Sky Picker (108 + 10 di gap).
      local FP_COLS, FP_CELL, FP_GAP = 3, 92, 7
      local FP_STEP = FP_CELL + FP_GAP
      local fpList = _G.AmbitiousFonts.list()
      local fpRows = math.ceil(#fpList / FP_COLS)
      -- L'altezza del canvas e' quella che avrebbero TUTTE le righe: la
      -- barra di scorrimento resta giusta anche se le card non esistono.
      fpScroll.CanvasSize = UDim2.new(0, 0, 0, 12 + fpRows * FP_STEP)

      local fpPool = {}

      local function fpEntryOf(card)
        local idx = card:GetAttribute("FontIdx")
        return idx and fpList[idx] or nil
      end

      local function fpPaint()
        for _, c in ipairs(fpPool) do
          local e = fpEntryOf(c)
          local sel = (e ~= nil and (_G.VxyroCustomFontSelected or _G.AmbitiousFontChoice or "Default") == e.key)
          local st = c:FindFirstChildOfClass("UIStroke")
          if st then
            VXYRO_tween(st, {
              Color = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 58),
              Transparency = sel and 0 or 0.55,
              Thickness = sel and 2.4 or 1.2,
            }, 0.12)
          end
        end
      end

      local function fpBind(card, idx)
        local e = fpList[idx]
        if not e then
          card:SetAttribute("FontIdx", nil)
          card.Visible = false
          return
        end
        local row = math.floor((idx - 1) / FP_COLS)
        local col = (idx - 1) % FP_COLS
        card.Position = UDim2.new(0, 8 + col * FP_STEP, 0, 6 + row * FP_STEP)
        card:SetAttribute("FontIdx", idx)
        local prv = card:FindFirstChild("Preview")
        if prv then
          if e.font then prv.FontFace = e.font else prv.Font = Enum.Font.GothamBlack end
        end
        local nl = card:FindFirstChild("FontName")
        if nl then nl.Text = e.label end
        card.Visible = true
      end

      -- Quante card servono davvero: le righe visibili piu' due di
      -- margine, cosi' scorrendo non si vede mai un buco.
      for j = 1, (math.ceil(370 / FP_STEP) + 2) * FP_COLS do
        local card = Instance.new("TextButton")
        card.Name = "FontCard_" .. tostring(j)
        card.Size = UDim2.new(0, FP_CELL, 0, FP_CELL)
        card.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        card.BackgroundTransparency = 0
        card.BorderSizePixel = 0
        card.Text = ""
        card.AutoButtonColor = false
        card.Visible = false
        card.ZIndex = 4
        card.ClipsDescendants = true
        card.Parent = fpScroll
        corner(card, 14)

        local cardStroke = Instance.new("UIStroke")
        cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        cardStroke.Color = Color3.fromRGB(50, 50, 58)
        cardStroke.Thickness = 1.2
        cardStroke.Transparency = 0.55
        cardStroke.Parent = card

        -- ANTEPRIMA. L'attributo la mette fuori dalla portata del motore
        -- dei font: senza, il font appena scelto verrebbe applicato anche
        -- a lei — sta dentro la hub come tutto il resto — e i campioni
        -- diventerebbero tutti uguali.
        local prv = Instance.new("TextLabel")
        prv.Name = "Preview"
        prv.BackgroundTransparency = 1
        prv.Size = UDim2.new(1, -8, 0, 48)
        prv.Position = UDim2.new(0, 4, 0, 6)
        prv.Text = "Aa"
        prv.TextColor3 = Color3.fromRGB(255, 255, 255)
        prv.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        prv.TextStrokeTransparency = 0.4
        prv.TextSize = 29
        prv.Font = Enum.Font.GothamBlack
        prv.ZIndex = 5
        prv.Parent = card
        prv:SetAttribute("AmbFontLock", true)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Name = "FontName"
        nameLbl.Size = UDim2.new(1, -6, 0, 28)
        nameLbl.Position = UDim2.new(0, 3, 1, -31)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = ""
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.TextStrokeTransparency = 0.4
        nameLbl.Font = Enum.Font.GothamBlack
        nameLbl.TextSize = 8
        nameLbl.TextWrapped = true
        nameLbl.ZIndex = 6
        nameLbl.Parent = card
        nameLbl:SetAttribute("AmbFontLock", true)

        card.MouseEnter:Connect(function()
          VXYRO_tween(cardStroke, {Transparency = 0, Thickness = 2.4}, 0.12)
          VXYRO_tween(prv, {TextSize = 34}, 0.12)
        end)
        card.MouseLeave:Connect(function()
          local e = fpEntryOf(card)
          local sel = (e ~= nil and (_G.VxyroCustomFontSelected or _G.AmbitiousFontChoice or "Default") == e.key)
          VXYRO_tween(cardStroke, {
            Transparency = sel and 0 or 0.55,
            Thickness = sel and 2.4 or 1.2,
          }, 0.12)
          VXYRO_tween(prv, {TextSize = 34}, 0.12)
        end)

        card.Activated:Connect(function()
          local e = fpEntryOf(card)
          if not e then return end
          local applied = true
          -- Always remember the selected font. When Custom Font is off we
          -- only defer application; enabling it later must use this choice.
          _G.VxyroCustomFontSelected = e.key
          _G.AmbitiousFontChoice = e.key
          if _G.VxyroCustomFontEnabled == true then
            applied = (_G.AmbitiousFonts.set(e.key, true) ~= false)
          end
          if not applied then
            _G.VxyroCustomFontSelected = e.key
            _G.AmbitiousFontChoice = e.key
          end
          pcall(function() if F and F.saveConfig then F.saveConfig() end end)
          fpPaint()
        end)

        fpPool[#fpPool + 1] = card
      end

      -- Si ridisegna solo quando cambia la prima riga visibile: durante
      -- uno scorrimento fluido la maggior parte dei frame non fa nulla.
      local fpFirstRow = -1
      local function fpRender()
        local first = math.max(0, math.floor((fpScroll.CanvasPosition.Y - 8) / FP_STEP) - 1)
        if first == fpFirstRow then return end
        fpFirstRow = first
        for j, card in ipairs(fpPool) do
          fpBind(card, first * FP_COLS + j)
        end
        fpPaint()
      end
      fpScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(fpRender)
      fpRender()

      fpBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
          closeFontPicker()
        end
      end)

      fpFrame.Size = UDim2.new(0, 0, 0, 0)
      fpFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
      VXYRO_TweenService:Create(fpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 440),
        Position = UDim2.new(0.5, -160, 0.5, -220)
      }):Play()
end
  local function waitImportedReady(fn, timeout)
    local deadline = os.clock() + (timeout or 3)
    while os.clock() < deadline do
      if type(fn) == "function" then
        local ok = pcall(fn)
        if ok then return true end
      end
      task.wait(0.05)
    end
    return false
  end

  -- Publish a safe runtime UI sync hook. The actual toggle rows are created
  -- inside F.buildGui below, where pageMOVE/pageVIEW/mkToggle are in scope.
  _G._VxyroImportedMusicOpen = function()
    return waitImportedReady(_VxyroImportedMusicOpen, 3)
  end
  _G._VxyroImportedMusicClose = function()
    return waitImportedReady(_VxyroImportedMusicClose, 3)
  end
  _G._VxyroImportedMusicStop = _VxyroImportedMusicStop
  _G.VxyroImportedOpenFontPicker = function()
    return waitImportedReady(_VxyroImportedOpenFontPicker, 3)
  end
  _G.VxyroImportedSyncUI = function()
    pcall(function()
      if _G.VxyroImportedMusicVisual then
        _G.VxyroImportedMusicVisual(false)
      end
      if _G.VxyroImportedFontVisual then
        _G.VxyroImportedFontVisual(_G.VxyroCustomFontEnabled == true)
      end
    end)
  end
  _G.VxyroImportedSyncUI()
    end
  end, function(err)
    warn('[Vxyro Duel] Imported features init failed: '..tostring(err))
  end)
end)

-- [HIGH PING ALERT]
task.spawn(function()
	local env = (getgenv and getgenv()) or _G
	env.__BLESS_HIGH_PING_RUN = (env.__BLESS_HIGH_PING_RUN or 0) + 1
	local thisRun = env.__BLESS_HIGH_PING_RUN
	env.__BLESS_INTRO_FINISHED_RUN = 0
	local function getPingMilliseconds()
		local ok, value = pcall(function()
			local stats = game:GetService("Stats")
			local network = stats:FindFirstChild("Network")
			local serverStats = network and network:FindFirstChild("ServerStatsItem")
			local pingItem = serverStats and (
				serverStats:FindFirstChild("Data Ping") or
				serverStats:FindFirstChild("Ping")
			)
			if not pingItem then return nil end
			local numericValue
			pcall(function() numericValue = pingItem:GetValue() end)
			if type(numericValue) == "number" then return numericValue end
			local valueString = pingItem:GetValueString()
			return tonumber(tostring(valueString):match("[%d%.]+"))
		end)
		return ok and tonumber(value) or nil
	end

	local function showHighPingAlert(pingValue)
		local TweenService = game:GetService("TweenService")
		local CoreGui = game:GetService("CoreGui")
		local Players = game:GetService("Players")
		local player = Players.LocalPlayer
		local playerGui = player and player:FindFirstChildOfClass("PlayerGui")

		pcall(function()
			local old = CoreGui:FindFirstChild("BlessHighPingAlert")
			if old then old:Destroy() end
		end)
		pcall(function()
			local old = playerGui and playerGui:FindFirstChild("BlessHighPingAlert")
			if old then old:Destroy() end
		end)

		local gui = Instance.new("ScreenGui")
		gui.Name = "BlessHighPingAlert"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 10000
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

		local parented = pcall(function() gui.Parent = CoreGui end)
		if not parented or not gui.Parent then gui.Parent = playerGui end
		if not gui.Parent then gui:Destroy() return end

		local shadow = Instance.new("Frame")
		shadow.Name = "Shadow"
		shadow.AnchorPoint = Vector2.new(0.5, 0)
		shadow.Position = UDim2.new(0.5, 0, 0, -66)
		shadow.Size = UDim2.new(0.82, 0, 0, 58)
		shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
		shadow.BackgroundTransparency = 1
		shadow.BorderSizePixel = 0
		shadow.ZIndex = 98
		shadow.Parent = gui
		local shadowSize = Instance.new("UISizeConstraint")
		shadowSize.MinSize = Vector2.new(246, 58)
		shadowSize.MaxSize = Vector2.new(420, 58)
		shadowSize.Parent = shadow
		Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 15)

		local bar = Instance.new("Frame")
		bar.Name = "AlertBar"
		bar.AnchorPoint = Vector2.new(0.5, 0)
		bar.Position = UDim2.new(0.5, 0, 0, -72)
		bar.Size = UDim2.new(0.82, 0, 0, 56)
		bar.BackgroundColor3 = Color3.fromRGB(11,11,13)
		bar.BackgroundTransparency = 0.02
		bar.BorderSizePixel = 0
		bar.ClipsDescendants = true
		bar.ZIndex = 100
		bar.Parent = gui
		local barSize = Instance.new("UISizeConstraint")
		barSize.MinSize = Vector2.new(244, 56)
		barSize.MaxSize = Vector2.new(420, 56)
		barSize.Parent = bar
		Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 15)

		local barStroke = Instance.new("UIStroke")
		barStroke.Color = Color3.fromRGB(255,255,255)
		barStroke.Transparency = 0.18
		barStroke.Thickness = 1.15
		barStroke.Parent = bar

		local leftRail = Instance.new("Frame")
		leftRail.Name = "AccentRail"
		leftRail.Size = UDim2.new(0, 3, 0, 31)
		leftRail.Position = UDim2.new(0, 9, 0.5, -15.5)
		leftRail.BackgroundColor3 = Color3.fromRGB(255,255,255)
		leftRail.BackgroundTransparency = 0.08
		leftRail.BorderSizePixel = 0
		leftRail.ZIndex = 102
		leftRail.Parent = bar
		Instance.new("UICorner", leftRail).CornerRadius = UDim.new(1,0)

		local icon = Instance.new("Frame")
		icon.Name = "WarnIcon"
		icon.Size = UDim2.new(0, 22, 0, 22)
		icon.Position = UDim2.new(0, 19, 0.5, -11)
		icon.BackgroundColor3 = Color3.fromRGB(255,255,255)
		icon.BackgroundTransparency = 0.02
		icon.BorderSizePixel = 0
		icon.ZIndex = 102
		icon.Parent = bar
		Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)
		local iconStroke = Instance.new("UIStroke", icon)
		iconStroke.Color = Color3.fromRGB(255,255,255)
		iconStroke.Thickness = 1
		iconStroke.Transparency = 0.05

		local iconLbl = Instance.new("TextLabel")
		iconLbl.BackgroundTransparency = 1
		iconLbl.Size = UDim2.new(1,0,1,0)
		iconLbl.Font = Enum.Font.GothamBlack
		iconLbl.TextSize = 14
		iconLbl.TextColor3 = Color3.fromRGB(10,10,12)
		iconLbl.Text = "!"
		iconLbl.ZIndex = 103
		iconLbl.Parent = icon

		local textWrap = Instance.new("Frame")
		textWrap.Name = "TextWrap"
		textWrap.BackgroundTransparency = 1
		textWrap.Position = UDim2.new(0, 48, 0, 0)
		textWrap.Size = UDim2.new(1, -126, 1, 0)
		textWrap.ZIndex = 102
		textWrap.Parent = bar

		local eyebrow = Instance.new("TextLabel")
		eyebrow.Name = "Eyebrow"
		eyebrow.BackgroundTransparency = 1
		eyebrow.Size = UDim2.new(1,0,0,10)
		eyebrow.Position = UDim2.new(0,0,0,7)
		eyebrow.Font = Enum.Font.GothamBold
		eyebrow.TextSize = 7
		eyebrow.TextColor3 = Color3.fromRGB(128,128,134)
		eyebrow.TextXAlignment = Enum.TextXAlignment.Left
		eyebrow.Text = "NETWORK"
		eyebrow.TextTruncate = Enum.TextTruncate.AtEnd
		eyebrow.ZIndex = 103
		eyebrow.Parent = textWrap

		local mainLbl = Instance.new("TextLabel")
		mainLbl.Name = "MainText"
		mainLbl.BackgroundTransparency = 1
		mainLbl.Size = UDim2.new(1,0,0,16)
		mainLbl.Position = UDim2.new(0,0,0,18)
		mainLbl.Font = Enum.Font.GothamBlack
		mainLbl.TextSize = 10
		mainLbl.TextColor3 = Color3.fromRGB(250,250,252)
		mainLbl.TextXAlignment = Enum.TextXAlignment.Left
		mainLbl.Text = "HIGH LATENCY"
		mainLbl.TextTruncate = Enum.TextTruncate.AtEnd
		mainLbl.ZIndex = 103
		mainLbl.Parent = textWrap

		local hint = Instance.new("TextLabel")
		hint.Name = "Hint"
		hint.BackgroundTransparency = 1
		hint.Size = UDim2.new(1,0,0,9)
		hint.Position = UDim2.new(0,0,0,35)
		hint.Font = Enum.Font.Gotham
		hint.TextSize = 7
		hint.TextColor3 = Color3.fromRGB(92,92,98)
		hint.TextXAlignment = Enum.TextXAlignment.Left
		hint.Text = "Connection delay detected"
		hint.TextTruncate = Enum.TextTruncate.AtEnd
		hint.ZIndex = 103
		hint.Parent = textWrap

		local badge = Instance.new("Frame")
		badge.Name = "LatencyBadge"
		badge.AnchorPoint = Vector2.new(1, 0.5)
		badge.Position = UDim2.new(1, -11, 0.5, 0)
		badge.Size = UDim2.new(0, 66, 0, 27)
		badge.BackgroundColor3 = Color3.fromRGB(255,255,255)
		badge.BackgroundTransparency = 0.04
		badge.BorderSizePixel = 0
		badge.ZIndex = 102
		badge.Parent = bar
		Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 8)
		local badgeStroke = Instance.new("UIStroke", badge)
		badgeStroke.Color = Color3.fromRGB(255,255,255)
		badgeStroke.Thickness = 1
		badgeStroke.Transparency = 0.06

		local badgeText = Instance.new("TextLabel")
		badgeText.BackgroundTransparency = 1
		badgeText.Size = UDim2.new(1, -6, 1, 0)
		badgeText.Position = UDim2.new(0, 3, 0, 0)
		badgeText.Font = Enum.Font.GothamBlack
		badgeText.TextSize = 9
		badgeText.TextColor3 = Color3.fromRGB(10,10,12)
		badgeText.TextTruncate = Enum.TextTruncate.AtEnd
		badgeText.Text = (type(pingValue) == "number") and string.format("%d MS", math.floor(pingValue + 0.5)) or "HIGH"
		badgeText.ZIndex = 103
		badgeText.Parent = badge

		local baseLine = Instance.new("Frame")
		baseLine.Name = "LifetimeTrack"
		baseLine.Position = UDim2.new(0, 11, 1, -3)
		baseLine.Size = UDim2.new(1, -22, 0, 2)
		baseLine.BackgroundColor3 = Color3.fromRGB(42,42,46)
		baseLine.BorderSizePixel = 0
		baseLine.ZIndex = 102
		baseLine.Parent = bar
		Instance.new("UICorner", baseLine).CornerRadius = UDim.new(1,0)
		local lineFill = Instance.new("Frame")
		lineFill.Size = UDim2.new(1,0,1,0)
		lineFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
		lineFill.BorderSizePixel = 0
		lineFill.ZIndex = 103
		lineFill.Parent = baseLine
		Instance.new("UICorner", lineFill).CornerRadius = UDim.new(1,0)

		pcall(function()
			if _G.__VxyroGlossAttach then
				_G.__VxyroGlossAttach(bar, {z=101, radius=15, thickness=1.35, bloomThickness=4.8, specWidth=9})
			end
		end)

		bar.BackgroundTransparency = 0.02
		barStroke.Transparency = 1
		shadow.BackgroundTransparency = 1
		local slideIn = TweenService:Create(bar, TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0,9)})
		local shadowIn = TweenService:Create(shadow, TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0,14), BackgroundTransparency = 0.58})
		local strokeIn = TweenService:Create(barStroke, TweenInfo.new(0.22), {Transparency = 0.18})
		slideIn:Play(); shadowIn:Play(); strokeIn:Play()
		TweenService:Create(lineFill, TweenInfo.new(3.0, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,1,0)}):Play()
		slideIn.Completed:Wait()

		task.wait(3)

		local slideOut = TweenService:Create(bar, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(0.5,0,0,-72), BackgroundTransparency = 1})
		local shadowOut = TweenService:Create(shadow, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(0.5,0,0,-66), BackgroundTransparency = 1})
		local strokeOut = TweenService:Create(barStroke, TweenInfo.new(0.20), {Transparency = 1})
		local allText = {iconLbl, eyebrow, mainLbl, hint, badgeText}
		for _, obj in ipairs(allText) do
			TweenService:Create(obj, TweenInfo.new(0.16), {TextTransparency = 1}):Play()
		end
		slideOut:Play(); shadowOut:Play(); strokeOut:Play()
		slideOut.Completed:Wait()
		gui:Destroy()
	end

	task.wait(5)

	local _alertRunning = false
	while env.__BLESS_HIGH_PING_RUN == thisRun do
		local ping = getPingMilliseconds()
		local highPing = (ping and ping > 150) or (ping == nil)
		if highPing and not _alertRunning then
			_alertRunning = true
			task.spawn(function()
				showHighPingAlert(ping)
				_alertRunning = false
			end)
		end
		task.wait(13)
	end
end)



-- ============================================================
-- ============================================================
-- ============================================================
