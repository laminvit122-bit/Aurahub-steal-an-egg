-- [[ 1. СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ ]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- [[ 2. Полный массив настроек AuraHub ]]
local Settings = {
    SpeedHack = false,
    WalkSpeed = 16,
    
    RareHighlight = false,
    OnlyRare = false,
    HighlightColor = Color3.fromRGB(160, 60, 255),
    
    PlayerESP = false,
    ParticlesEnabled = true
}

local EggFolder = Workspace:WaitForChild("AreaEggSlotsClient", 5) or Workspace

-- [[ 3. СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AuraHub_Full_Fixed"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главное окно
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(130, 80, 230)

-- [[ Надежное перетаскивание окна ]]
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(MainFrame)

-- Частицы фона
local ParticleContainer = Instance.new("Frame", MainFrame)
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.ZIndex = 1
ParticleContainer.ClipsDescendants = true

task.spawn(function()
    while task.wait(0.2) do
        if MainFrame.Visible and Settings.ParticlesEnabled then
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

-- Шапка
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(24, 22, 35)
Header.BorderSizePixel = 0
Header.ZIndex = 2
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", Header)
Title.Text = "  AuraHub — Steal an Egg"
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 3

-- Закрытие и сворачивание
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

local MinimizedFrame = Instance.new("Frame", ScreenGui)
MinimizedFrame.Size = UDim2.new(0, 44, 0, 44)
MinimizedFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MinimizedFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
MinimizedFrame.Visible = false
MinimizedFrame.Active = true
Instance.new("UICorner", MinimizedFrame).CornerRadius = UDim.new(0, 10)

MakeDraggable(MinimizedFrame)

local MinStroke = Instance.new("UIStroke", MinimizedFrame)
MinStroke.Color = Color3.fromRGB(150, 90, 255)
MinStroke.Thickness = 2

local OpenBtn = Instance.new("TextButton", MinimizedFrame)
OpenBtn.Size = UDim2.new(1, 0, 1, 0)
OpenBtn.BackgroundTransparency = 1
OpenBtn.Text = "A"
OpenBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizedFrame.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizedFrame.Visible = false
end)

-- Сайдбар и вкладки
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.Size = UDim2.new(0, 130, 1, -62)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 2
Instance.new("UIListLayout", TabBar).Padding = UDim.new(0, 6)

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

    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

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

-- Вкладки AuraHub
local MainPage = CreateTab("Main", 7539983773)
local VisualsPage = CreateTab("Visuals", 17412298151)
local SettingsPage = CreateTab("Settings", 11956055886)

Tabs["Main"].Page.Visible = true
Tabs["Main"].Button.BackgroundColor3 = Color3.fromRGB(130, 70, 220)

-- [[ ВСПЛЫВАЮЩИЕ НАСТРОЙКИ В КНОПКАХ (С ШЕСТЕРЕНКОЙ) ]]
local function CreateToggleWithSettings(parent, text, defaultState, onToggle, createSubSettingsFunc)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.BackgroundColor3 = Color3.fromRGB(24, 22, 35)
    Container.ClipsDescendants = true
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local HeaderFrame = Instance.new("Frame", Container)
    HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
    HeaderFrame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", HeaderFrame)
    Label.Text = "  " .. text
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local ToggleBtn = Instance.new("TextButton", HeaderFrame)
    ToggleBtn.Position = UDim2.new(1, -44, 0.2, 0)
    ToggleBtn.Size = UDim2.new(0, 34, 0, 22)
    ToggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(130, 70, 220) or Color3.fromRGB(50, 50, 70)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local state = defaultState
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(130, 70, 220) or Color3.fromRGB(50, 50, 70)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        onToggle(state)
    end)

    if createSubSettingsFunc then
        local GearSubBtn = Instance.new("ImageButton", HeaderFrame)
        GearSubBtn.Size = UDim2.new(0, 22, 0, 22)
        GearSubBtn.Position = UDim2.new(1, -74, 0.2, 0)
        GearSubBtn.BackgroundTransparency = 1
        GearSubBtn.Image = "rbxassetid://7059346373"
        GearSubBtn.ImageColor3 = Color3.fromRGB(180, 180, 210)

        local SubPanel = Instance.new("Frame", Container)
        SubPanel.Position = UDim2.new(0, 0, 0, 40)
        SubPanel.Size = UDim2.new(1, 0, 0, 0)
        SubPanel.BackgroundTransparency = 1

        createSubSettingsFunc(SubPanel)

        local isOpened = false
        local rot = 0

        GearSubBtn.MouseButton1Click:Connect(function()
            isOpened = not isOpened
            rot = rot + 180
            
            TweenService:Create(GearSubBtn, TweenInfo.new(0.3), {Rotation = rot}):Play()
            
            local targetHeight = isOpened and 100 or 40
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -10, 0, targetHeight)
            }):Play()
        end)
    end
end

-- MAIN TAB: Speed Hack
CreateToggleWithSettings(MainPage, "Speed Hack", Settings.SpeedHack, function(v)
    Settings.SpeedHack = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end, function(subPanel)
    local SpeedLabel = Instance.new("TextLabel", subPanel)
    SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 0)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed Value: " .. tostring(Settings.WalkSpeed)
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
    SpeedLabel.Font = Enum.Font.GothamBold
    SpeedLabel.TextSize = 12
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBack = Instance.new("Frame", subPanel)
    SliderBack.Size = UDim2.new(1, -20, 0, 6)
    SliderBack.Position = UDim2.new(0, 10, 0, 25)
    SliderBack.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
    Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame", SliderBack)
    SliderFill.Size = UDim2.new((Settings.WalkSpeed - 16) / 134, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(130, 80, 230)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local SliderKnob = Instance.new("Frame", SliderBack)
    SliderKnob.Size = UDim2.new(0, 14, 0, 14)
    SliderKnob.Position = UDim2.new((Settings.WalkSpeed - 16) / 134, -7, 0.5, -7)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(220, 200, 255)
    Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
        
        local speedVal = math.floor(16 + (pos * 134)) -- Позволяет ставить скорость от 16 до 150 без лимита
        Settings.WalkSpeed = speedVal
        SpeedLabel.Text = "Speed Value: " .. tostring(speedVal)
    end

    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end)

-- VISUALS TAB: Highlight Eggs
CreateToggleWithSettings(VisualsPage, "Highlight Eggs", Settings.RareHighlight, function(v)
    Settings.RareHighlight = v
end, function(subPanel)
    local FilterBtn = Instance.new("TextButton", subPanel)
    FilterBtn.Size = UDim2.new(1, -20, 0, 30)
    FilterBtn.Position = UDim2.new(0, 10, 0, 5)
    FilterBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
    FilterBtn.Text = "Only Rare Eggs: OFF"
    FilterBtn.TextColor3 = Color3.fromRGB(200, 200, 230)
    FilterBtn.Font = Enum.Font.Gotham
    FilterBtn.TextSize = 12
    Instance.new("UICorner", FilterBtn).CornerRadius = UDim.new(0, 6)

    FilterBtn.MouseButton1Click:Connect(function()
        Settings.OnlyRare = not Settings.OnlyRare
        FilterBtn.Text = "Only Rare Eggs: " .. (Settings.OnlyRare and "ON" or "OFF")
        FilterBtn.BackgroundColor3 = Settings.OnlyRare and Color3.fromRGB(130, 70, 220) or Color3.fromRGB(35, 30, 50)
    end)
end)

-- VISUALS TAB: Player ESP
CreateToggleWithSettings(VisualsPage, "Player ESP", Settings.PlayerESP, function(v)
    Settings.PlayerESP = v
end)

-- SETTINGS TAB
local function CreateButton(parent, text, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 22, 35)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local ActionBtn = Instance.new("TextButton", Frame)
    ActionBtn.Size = UDim2.new(1, 0, 1, 0)
    ActionBtn.BackgroundTransparency = 1
    ActionBtn.Text = text
    ActionBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
    ActionBtn.Font = Enum.Font.GothamSemibold
    ActionBtn.TextSize = 13

    ActionBtn.MouseButton1Click:Connect(callback)
end

CreateButton(SettingsPage, "Toggle UI Particles", function()
    Settings.ParticlesEnabled = not Settings.ParticlesEnabled
    ParticleContainer.Visible = Settings.ParticlesEnabled
end)

-- [[ ИСПОЛНЕНИЕ ФУНКЦИЙ ]]

-- Speed Hack Loop
RunService.Stepped:Connect(function()
    pcall(function()
        if Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        end
    end)
end)

-- Highlight Eggs Loop
RunService.RenderStepped:Connect(function()
    if Settings.RareHighlight then
        pcall(function()
            for _, slot in pairs(EggFolder:GetChildren()) do
                local isRare = slot.Name:lower():find("rare") or slot.Name:lower():find("legendary") or slot.Name:lower():find("mythic") or slot.Name:lower():find("godly")
                
                if not Settings.OnlyRare or (Settings.OnlyRare and isRare) then
                    if not slot:FindFirstChild("AuraHighlight") then
                        local h = Instance.new("Highlight")
                        h.Name = "AuraHighlight"
                        h.FillColor = Settings.HighlightColor
                        h.OutlineColor = Color3.fromRGB(0, 255, 200)
                        h.FillTransparency = 0.4
                        h.Parent = slot
                    end
                elseif Settings.OnlyRare and not isRare and slot:FindFirstChild("AuraHighlight") then
                    slot.AuraHighlight:Destroy()
                end
            end
        end)
    else
        pcall(function()
            for _, slot in pairs(EggFolder:GetChildren()) do
                if slot:FindFirstChild("AuraHighlight") then
                    slot.AuraHighlight:Destroy()
                end
            end
        end)
    end
end)
