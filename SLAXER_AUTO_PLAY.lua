-- DEOBF BY PRINCE 

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

local WHITE = Color3.fromRGB(255, 0, 0)

-- ========== WAYPOINTS ==========
local leftWaypoints = {
    Vector3.new(-476.85, -6.59, 94.91),
    Vector3.new(-485.55, -4.53, 100.61),
    Vector3.new(-475.60, -6.59, 92.80),
    Vector3.new(-475.26, -6.57, 21.54),
}
local rightWaypoints = {
    Vector3.new(-475.77, -6.57, 26.76),
    Vector3.new(-485.85, -4.48, 20.13),
    Vector3.new(-475.83, -6.59, 26.54),
    Vector3.new(-476.17, -6.09, 97.73),
}

-- ========== CONFIG ==========
local ConfigFileName = "SLAXER_AUTOPLAY_CONFIG.json"
local Values = { GoingSpeed = 60, StealSpeed = 29 }

local function loadConfig()
    if not readfile or not isfile then return end
    pcall(function()
        if isfile(ConfigFileName) then
            local data = HttpService:JSONDecode(readfile(ConfigFileName))
            Values.GoingSpeed = data.GoingSpeed or 55
            Values.StealSpeed = data.StealSpeed or 29
        end
    end)
end

local function saveConfig()
    if not writefile then return end
    pcall(function()
        writefile(ConfigFileName, HttpService:JSONEncode(Values))
    end)
end
loadConfig()

-- ========== PROXY ==========
local proxy = nil
local function ensureProxy()
    local char = Player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    if not proxy or proxy.Parent ~= char then
        if proxy then proxy:Destroy() end
        proxy = Instance.new("Part")
        proxy.Name = "SLAXER_AutoPlayProxy"
        proxy.Size = Vector3.new(1,1,1)
        proxy.Transparency = 1
        proxy.CanCollide = false
        proxy.Massless = true
        proxy.Parent = char
        local weld = Instance.new("Weld")
        weld.Part0 = hrp
        weld.Part1 = proxy
        weld.C0 = CFrame.new(0,0,0)
        weld.Parent = proxy
    end
    return proxy
end

-- ========== MOVEMENT HELPER ==========
local function moveTo(target, speed)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dir = (target - hrp.Position)
    local moveDir = Vector3.new(dir.X, 0, dir.Z).Unit
    local hum = Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:Move(moveDir, false) end
    if proxy then
        local currentVel = proxy.AssemblyLinearVelocity
        proxy.AssemblyLinearVelocity = Vector3.new(moveDir.X * speed, currentVel.Y, moveDir.Z * speed)
    end
end

local function stopMoving()
    if proxy then proxy.AssemblyLinearVelocity = Vector3.new(0,0,0) end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:Move(Vector3.zero, false) end
end

-- ========== PATROL LOGIC ==========
local activeConnection = nil
local activeWaypoints = nil
local waypointIndex = 1
local currentPhase = 1

local function startPatrol(waypoints)
    if activeConnection then activeConnection:Disconnect() end
    activeWaypoints = waypoints
    waypointIndex = 1
    currentPhase = 1
    ensureProxy()
    activeConnection = RunService.Stepped:Connect(function()
        if not activeWaypoints then return end
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local target = activeWaypoints[waypointIndex]
        if not target then return end
        
        local dist = (target - hrp.Position).Magnitude
        local speed = (currentPhase <= 2) and Values.GoingSpeed or Values.StealSpeed
        if dist < 2.5 then
            waypointIndex = waypointIndex + 1
            if waypointIndex > #activeWaypoints then
                activeConnection:Disconnect()
                activeConnection = nil
                activeWaypoints = nil
                if Enabled.AutoLeft then
                    Enabled.AutoLeft = false
                    if updateButtonUI then updateButtonUI() end
                elseif Enabled.AutoRight then
                    Enabled.AutoRight = false
                    if updateButtonUI then updateButtonUI() end
                end
                stopMoving()
                return
            end
            if waypointIndex == 3 then
                currentPhase = 3
            end
        else
            moveTo(target, speed)
        end
    end)
end

local function stopPatrol()
    if activeConnection then activeConnection:Disconnect(); activeConnection = nil end
    activeWaypoints = nil
    waypointIndex = 1
    stopMoving()
end

-- ========== UI ==========
local Enabled = { AutoLeft = false, AutoRight = false }
local isLocked = false
local updateButtonUI = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SLAXERAUTOPLAY"
screenGui.ResetOnSpawn = false
pcall(function()
    if gethui then screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(screenGui) screenGui.Parent = game:GetService("CoreGui")
    else screenGui.Parent = Player:WaitForChild("PlayerGui") end
end)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 140, 0, 119)
panel.Position = UDim2.new(0.5, -70, 0.5, -60)
panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
panel.BackgroundTransparency = 0
panel.BorderSizePixel = 0
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", panel).Color = WHITE
panel.UIStroke.Thickness = 1.5

local titleBar = Instance.new("Frame", panel)
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(0.65, 0, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SLAXER AUTO PLAY"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.TextXAlignment = Enum.TextXAlignment.Left

local discordSub = Instance.new("TextLabel", titleBar)
discordSub.Size = UDim2.new(0.65, 0, 1, 0)
discordSub.Position = UDim2.new(0, 6, 0, 12)
discordSub.BackgroundTransparency = 1
discordSub.Text = "discord.gg/slaxer"
discordSub.TextColor3 = Color3.fromRGB(200, 200, 200)
discordSub.Font = Enum.Font.Gotham
discordSub.TextSize = 7

local lockBtn = Instance.new("TextButton", titleBar)
lockBtn.Size = UDim2.new(0, 20, 0, 20)
lockBtn.Position = UDim2.new(1, -24, 0, 3)
lockBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
lockBtn.Text = "🔓"
lockBtn.TextColor3 = WHITE
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 12
lockBtn.AutoButtonColor = false
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 4)

local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if isLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging or isLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
lockBtn.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    lockBtn.Text = isLocked and "🔒" or "🔓"
    lockBtn.BackgroundColor3 = isLocked and WHITE or Color3.fromRGB(20, 20, 20)
end)

local content = Instance.new("Frame", panel)
content.Size = UDim2.new(1, -12, 1, -34)
content.Position = UDim2.new(0, 6, 0, 30)
content.BackgroundTransparency = 1

local function makeSpeedRow(y, label, key)
    local lbl = Instance.new("TextLabel", content)
    lbl.Size = UDim2.new(0.55, 0, 0, 18)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 9
    local box = Instance.new("TextBox", content)
    box.Size = UDim2.new(0.35, 0, 0, 18)
    box.Position = UDim2.new(0.65, 0, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    box.Text = tostring(Values[key])
    box.TextColor3 = WHITE
    box.Font = Enum.Font.GothamBold
    box.TextSize = 9
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            n = math.clamp(n, 10, 200)
            Values[key] = n
            box.Text = tostring(n)
            saveConfig()
        else
            box.Text = tostring(Values[key])
        end
    end)
end

makeSpeedRow(0, "Going Spd", "GoingSpeed")
makeSpeedRow(19, "Steal Spd", "StealSpeed")

local leftBtn = Instance.new("TextButton", content)
leftBtn.Size = UDim2.new(0.48, 0, 0, 30)
leftBtn.Position = UDim2.new(0, 0, 0, 40)
leftBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
leftBtn.Text = "LEFT: OFF"
leftBtn.TextColor3 = WHITE
leftBtn.Font = Enum.Font.GothamBold
leftBtn.TextSize = 10
Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 4)

local rightBtn = Instance.new("TextButton", content)
rightBtn.Size = UDim2.new(0.48, 0, 0, 30)
rightBtn.Position = UDim2.new(0.52, 0, 0, 40)
rightBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
rightBtn.Text = "RIGHT: OFF"
rightBtn.TextColor3 = WHITE
rightBtn.Font = Enum.Font.GothamBold
rightBtn.TextSize = 10
Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 4)

updateButtonUI = function()
    leftBtn.BackgroundColor3 = Enabled.AutoLeft and WHITE or Color3.fromRGB(20, 20, 20)
    leftBtn.Text = Enabled.AutoLeft and "LEFT: ON" or "LEFT: OFF"
    rightBtn.BackgroundColor3 = Enabled.AutoRight and WHITE or Color3.fromRGB(20, 20, 20)
    rightBtn.Text = Enabled.AutoRight and "RIGHT: ON" or "RIGHT: OFF"
end

leftBtn.MouseButton1Click:Connect(function()
    if Enabled.AutoLeft then
        stopPatrol()
        Enabled.AutoLeft = false
        updateButtonUI()
    else
        stopPatrol()
        Enabled.AutoRight = false
        Enabled.AutoLeft = true
        updateButtonUI()
        startPatrol(leftWaypoints)
    end
end)

rightBtn.MouseButton1Click:Connect(function()
    if Enabled.AutoRight then
        stopPatrol()
        Enabled.AutoRight = false
        updateButtonUI()
    else
        stopPatrol()
        Enabled.AutoLeft = false
        Enabled.AutoRight = true
        updateButtonUI()
        startPatrol(rightWaypoints)
    end
end)

updateButtonUI()

-- Auto-anti drop
RunService.Stepped:Connect(function()
    local c = Player.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < -10 then
            hrp.Position = Vector3.new(hrp.Position.X, -6.5, hrp.Position.Z)
        end
    end
end)

Player.CharacterAdded:Connect(function()
    task.wait(0.8)
    if Enabled.AutoLeft then
        stopPatrol()
        startPatrol(leftWaypoints)
    elseif Enabled.AutoRight then
        stopPatrol()
        startPatrol(rightWaypoints)
    end
end)

print("✅ SLAXER AUTO PLAY v1")