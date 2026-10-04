-- [[ 1. СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ ]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ 2. НАСТРОЙКИ СКТРИПТА ]]
local Settings = {
    AutoSteal = false,
    StealDelay = 0.3,
    AutoCollectPets = false,
    RareEggHighlight = false,
    PlayerESP = false,
    TargetRarities = {"Legendary", "Mythical", "Secret", "Cube"}
}

-- Точные пути на основе скриншотов Dex Explorer
local EggFolder = Workspace:WaitForChild("AreaEggSlotsClient", 5) or Workspace

-- [[ 3. СОЗДАНИЕ GUI ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnEggGUI_Adapted"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 330)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(32, 30, 48)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Text = "  STEAL AN EGG — Hub (Dex Mode)"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(180, 120, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Sidebar / Tabs
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 10, 0, 50)
TabBar.Size = UDim2.new(0, 120, 1, -60)
TabBar.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabBar)
TabList.Padding = UDim.new(0, 6)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 140, 0, 50)
ContentArea.Size = UDim2.new(1, -150, 1, -60)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local Button = Instance.new("TextButton", TabBar)
    Button.Size = UDim2.new(1, 0, 0, 34)
    Button.BackgroundColor3 = Color3.fromRGB(35, 33, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(220, 220, 240)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(160, 90, 255)

    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 8)

    Button.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Page.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 33, 50)}):Play()
        end
        Page.Visible = true
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(140, 70, 220)}):Play()
    end)

    Tabs[name] = {Button = Button, Page = Page}
    return Page
end

local MainPage = CreateTab("Main")
local VisualsPage = CreateTab("Visuals")
local TeleportsPage = CreateTab("Teleports")

Tabs["Main"].Page.Visible = true
Tabs["Main"].Button.BackgroundColor3 = Color3.fromRGB(140, 70, 220)

-- [[ 4. ЭЛЕМЕНТЫ УПРАВЛЕНИЯ ]]
local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "  " .. text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Position = UDim2.new(1, -42, 0.2, 0)
    ToggleBtn.Size = UDim2.new(0, 32, 0, 20)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(140, 70, 220) or Color3.fromRGB(60, 60, 80)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(140, 70, 220) or Color3.fromRGB(60, 60, 80)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(state)
    end)
end

local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(48, 38, 70)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

    Button.MouseButton1Click:Connect(callback)
end

CreateToggle(MainPage, "Auto Steal Egg", Settings.AutoSteal, function(v) Settings.AutoSteal = v end)
CreateToggle(MainPage, "Auto Collect Pets", Settings.AutoCollectPets, function(v) Settings.AutoCollectPets = v end)
CreateToggle(VisualsPage, "Highlight Eggs", Settings.RareEggHighlight, function(v) 
    Settings.RareEggHighlight = v 
    if not v then
        for _, eggModel in pairs(EggFolder:GetChildren()) do
            if eggModel:FindFirstChild("EggHighlight") then
                eggModel.EggHighlight:Destroy()
            end
        end
    end
end)
CreateToggle(VisualsPage, "Player ESP", Settings.PlayerESP, function(v) Settings.PlayerESP = v end)

-- [[ 5. ПОИСК И ТЕЛЕПОРТАЦИЯ К ЯЙЦАМ ]]

-- Функция получения позиции/Part любого яйца из AreaEggSlotsClient
local function GetEggPart(eggContainer)
    if eggContainer:IsA("BasePart") then
        return eggContainer
    end
    -- Поиск Hitbox или Cube из Explorer
    local targetPart = eggContainer:FindFirstChild("Hitbox") 
        or eggContainer:FindFirstChild("AreaEggHover")
        or eggContainer:FindFirstChildWhichIsA("BasePart", true)
    return targetPart
end

local function GetClosestEgg()
    local closestPart, minDistance = nil, math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local hrpPos = char.HumanoidRootPart.Position

    pcall(function()
        for _, slot in pairs(EggFolder:GetChildren()) do
            local part = GetEggPart(slot)
            if part then
                local dist = (part.Position - hrpPos).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closestPart = part
                end
            end
        end
    end)
    return closestPart
end

-- 1. Auto Steal Egg Loop
task.spawn(function()
    while task.wait(Settings.StealDelay) do
        if Settings.AutoSteal then
            pcall(function()
                local eggPart = GetClosestEgg()
                local char = LocalPlayer.Character
                if eggPart and char and char:FindFirstChild("HumanoidRootPart") then
                    -- Перемещение прямо к хитбоксу яйца
                    char.HumanoidRootPart.CFrame = eggPart.CFrame * CFrame.new(0, 2, 0)
                end
            end)
        end
    end
end)

-- 2. Highlight Eggs
RunService.RenderStepped:Connect(function()
    if Settings.RareEggHighlight then
        pcall(function()
            for _, slot in pairs(EggFolder:GetChildren()) do
                if not slot:FindFirstChild("EggHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "EggHighlight"
                    highlight.FillColor = Color3.fromRGB(180, 0, 255)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 200)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = slot
                end
            end
        end)
    end
end)

-- 3. Teleport Button
CreateButton(TeleportsPage, "Teleport to Nearest Egg", function()
    pcall(function()
        local eggPart = GetClosestEgg()
        local char = LocalPlayer.Character
        if eggPart and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = eggPart.CFrame * CFrame.new(0, 3, 0)
        end
    end)
end)

-- 4. Player ESP
local ESPContainer = {}

RunService.RenderStepped:Connect(function()
    if not Settings.PlayerESP then
        for _, gui in pairs(ESPContainer) do
            if gui then gui:Destroy() end
        end
        ESPContainer = {}
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))

            if onScreen then
                local espTag = ESPContainer[player.Name]
                if not espTag then
                    espTag = Instance.new("TextLabel")
                    espTag.Size = UDim2.new(0, 180, 0, 20)
                    espTag.BackgroundTransparency = 1
                    espTag.TextColor3 = Color3.fromRGB(0, 255, 180)
                    espTag.Font = Enum.Font.GothamBold
                    espTag.TextSize = 12
                    espTag.Parent = ScreenGui
                    ESPContainer[player.Name] = espTag
                end

                local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local dist = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
                espTag.Text = string.format("%s [%d m]", player.Name, dist)
                espTag.Position = UDim2.new(0, vector.X - 90, 0, vector.Y)
                espTag.Visible = true
            else
                if ESPContainer[player.Name] then
                    ESPContainer[player.Name].Visible = false
                end
            end
        end
    end
end)
