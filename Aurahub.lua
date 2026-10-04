-- [[ 1. СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ ]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ 2. НАСТРОЙКИ AURA HUB ]]
local Settings = {
    AutoFarm = false,
    FarmDelay = 1,
    RareHighlight = false,
    PlayerESP = false,
    HomeCFrame = nil -- База сохраняется автоматически при включении
}

local EggFolder = Workspace:WaitForChild("AreaEggSlotsClient", 5) or Workspace

-- [[ 3. СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА (AuraHub) ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AuraHub"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главная рамка
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 330)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Градиентная рамка
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(130, 80, 230)

-- Фон с падающими частицами пыли
local ParticleContainer = Instance.new("Frame", MainFrame)
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.ZIndex = 1

task.spawn(function()
    while task.wait(0.2) do
        if MainFrame.Visible then
            local p = Instance.new("Frame", ParticleContainer)
            local size = math.random(2, 4)
            p.Size = UDim2.new(0, size, 0, size)
            p.Position = UDim2.new(math.random(), 0, -0.05, 0)
            p.BackgroundColor3 = Color3.fromRGB(180, 140, 255)
            p.BackgroundTransparency = math.random(3, 7) / 10
            p.BorderSizePixel = 0
            Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

            local tween = TweenService:Create(p, TweenInfo.new(math.random(3, 6), Enum.EasingStyle.Linear), {
                Position = UDim2.new(p.Position.X.Scale, math.random(-20, 20), 1.05, 0),
                BackgroundTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function() p:Destroy() end)
        end
    end
end)

-- Хедер
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(24, 22, 35)
Header.BorderSizePixel = 0
Header.ZIndex = 2
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", Header)
Title.Text = "  ✨ AuraHub — Steal an Egg"
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 3

-- Кнопка закрытия (×)
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.ZIndex = 3
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Маленький сворачиваемый виджет
local MinimizedFrame = Instance.new("Frame", ScreenGui)
MinimizedFrame.Size = UDim2.new(0, 50, 0, 50)
MinimizedFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MinimizedFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
MinimizedFrame.Visible = false
MinimizedFrame.Active = true
MinimizedFrame.Draggable = true
Instance.new("UICorner", MinimizedFrame).CornerRadius = UDim.new(0, 12)
local MinStroke = Instance.new("UIStroke", MinimizedFrame)
MinStroke.Color = Color3.fromRGB(150, 90, 255)
MinStroke.Thickness = 2

local OpenBtn = Instance.new("TextButton", MinimizedFrame)
OpenBtn.Size = UDim2.new(1, 0, 1, 0)
OpenBtn.BackgroundTransparency = 1
OpenBtn.Text = "✨"
OpenBtn.TextSize = 22

-- Кнопка свертывания (-)
local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -68, 0.5, -14)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.ZIndex = 3
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizedFrame.Position = UDim2.new(0, MainFrame.AbsolutePosition.X, 0, MainFrame.AbsolutePosition.Y)
    MinimizedFrame.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MinimizedFrame.Visible = false
    MainFrame.Visible = true
end)

-- Сайдбар
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.Size = UDim2.new(0, 130, 1, -62)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 2

local TabList = Instance.new("UIListLayout", TabBar)
TabList.Padding = UDim.new(0, 6)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 150, 0, 52)
ContentArea.Size = UDim2.new(1, -160, 1, -62)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 2

local Tabs = {}
local function CreateTab(name, iconId)
    local Button = Instance.new("TextButton", TabBar)
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(28, 26, 40)
    Button.Text = ""
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    local Icon = Instance.new("ImageLabel", Button)
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.Position = UDim2.new(0, 10, 0.5, -10)
    Icon.Image = "rbxassetid://" .. tostring(iconId)
    Icon.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Button)
    Label.Text = name
    Label.Position = UDim2.new(0, 36, 0, 0)
    Label.Size = UDim2.new(1, -36, 1, 0)
    Label.TextColor3 = Color3.fromRGB(220, 220, 240)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(150, 90, 255)

    local PageList = Instance.new("UIListLayout", Page)
    PageList.Padding = UDim.new(0, 8)

    Button.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Page.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 26, 40)}):Play()
        end
        Page.Visible = true
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(130, 70, 220)}):Play()
    end)

    Tabs[name] = {Button = Button, Page = Page}
    return Page
end

-- Создаем вкладку Главная с иконкой домика (ID 7539983773)
local MainPage = CreateTab("Main", 7539983773)
local VisualsPage = CreateTab("Visuals", 7539983773)

Tabs["Main"].Page.Visible = true
Tabs["Main"].Button.BackgroundColor3 = Color3.fromRGB(130, 70, 220)

-- [[ 4. ЭЛЕМЕНТЫ УПРАВЛЕНИЯ ]]
local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 22, 35)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "  " .. text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Position = UDim2.new(1, -44, 0.2, 0)
    ToggleBtn.Size = UDim2.new(0, 34, 0, 22)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(130, 70, 220) or Color3.fromRGB(50, 50, 70)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(130, 70, 220) or Color3.fromRGB(50, 50, 70)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(state)
    end)
end

-- [[ 5. УЛУЧШЕННЫЙ АВТО-ФАРМ ЛОГИКА ]]

-- Поиск лучшего/ближайшего яйца
local function GetBestEggPart()
    local bestPart = nil
    pcall(function()
        for _, slot in pairs(EggFolder:GetChildren()) do
            local part = slot:FindFirstChild("Hitbox") 
                or slot:FindFirstChild("AreaEggHover") 
                or slot:FindFirstChildWhichIsA("BasePart", true)
            if part then
                bestPart = part -- Выбирается доступный объект яйца
            end
        end
    end)
    return bestPart
end

CreateToggle(MainPage, "Smart Auto Farm", Settings.AutoFarm, function(v)
    Settings.AutoFarm = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Сохраняем позицию базы при включении функции
        Settings.HomeCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

CreateToggle(VisualsPage, "Highlight Rare Eggs", Settings.RareHighlight, function(v) Settings.RareHighlight = v end)
CreateToggle(VisualsPage, "Player ESP", Settings.PlayerESP, function(v) Settings.PlayerESP = v end)

-- Цикл автофарма: ТП к яйцу -> Кража -> ТП на базу
task.spawn(function()
    while task.wait(Settings.FarmDelay) do
        if Settings.AutoFarm then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local eggPart = GetBestEggPart()

                if hrp and eggPart then
                    -- 1. Телепорт к яйцу
                    hrp.CFrame = eggPart.CFrame * CFrame.new(0, 2, 0)
                    task.wait(0.2)

                    -- 2. Эмуляция зажатия кнопки E (Кража)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(1.2) -- Время воровства
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

                    -- 3. Возврат на базу
                    if Settings.HomeCFrame then
                        hrp.CFrame = Settings.HomeCFrame
                    end
                end
            end)
        end
    end
end)

-- Подсветка яиц
RunService.RenderStepped:Connect(function()
    if Settings.RareHighlight then
        pcall(function()
            for _, slot in pairs(EggFolder:GetChildren()) do
                if not slot:FindFirstChild("AuraHighlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "AuraHighlight"
                    h.FillColor = Color3.fromRGB(160, 60, 255)
                    h.OutlineColor = Color3.fromRGB(0, 255, 200)
                    h.FillTransparency = 0.4
                    h.Parent = slot
                end
            end
        end)
    end
end)
