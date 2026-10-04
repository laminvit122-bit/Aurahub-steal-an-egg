-- [[ 1. СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- [[ 2. НАСТРОЙКИ ]]
local Settings = {
    SpeedHack = false,
    WalkSpeed = 5 -- Начальная скорость
}

-- [[ 3. СОЗДАНИЕ ИНТЕРФЕЙСА ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHack_Standalone"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Функция для свободного перетаскивания (Draggable)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

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
            update(input)
        end
    end)
end

-- [[ 4. ПЛАВАЮЩАЯ КНОПКА-ШЕСТЕРЕНКА В ПРАВОМ НИЖНЕМ УГЛУ ]]
local GearButton = Instance.new("ImageButton", ScreenGui)
GearButton.Name = "FloatingGearButton"
GearButton.Size = UDim2.new(0, 48, 0, 48)
GearButton.Position = UDim2.new(1, -70, 1, -70)
GearButton.BackgroundColor3 = Color3.fromRGB(25, 22, 38)
GearButton.Image = "rbxassetid://7059346373"
GearButton.ImageColor3 = Color3.fromRGB(200, 150, 255)
GearButton.Active = true
Instance.new("UICorner", GearButton).CornerRadius = UDim.new(0, 12)

local GearStroke = Instance.new("UIStroke", GearButton)
GearStroke.Color = Color3.fromRGB(130, 80, 230)
GearStroke.Thickness = 1.5

MakeDraggable(GearButton)

-- [[ 5. ВЫЕЗЖАЮЩАЯ ПАНЕЛЬ НАСТРОЕК ]]
local SpeedPanel = Instance.new("Frame", ScreenGui)
SpeedPanel.Name = "SpeedHackPanel"
SpeedPanel.Size = UDim2.new(0, 300, 0, 110)
SpeedPanel.Position = UDim2.new(1, -320, 1, 100) -- Изначально скрыта за нижней границей
SpeedPanel.BackgroundColor3 = Color3.fromRGB(18, 16, 26)
SpeedPanel.BorderSizePixel = 0
SpeedPanel.ClipsDescendants = true
SpeedPanel.Active = true
Instance.new("UICorner", SpeedPanel).CornerRadius = UDim.new(0, 12)

local PanelStroke = Instance.new("UIStroke", SpeedPanel)
PanelStroke.Color = Color3.fromRGB(130, 80, 230)
PanelStroke.Thickness = 1.5

MakeDraggable(SpeedPanel)

-- Шапка выезжающей панели
local MainToggleFrame = Instance.new("Frame", SpeedPanel)
MainToggleFrame.Size = UDim2.new(1, 0, 0, 40)
MainToggleFrame.BackgroundTransparency = 1

local TitleLabel = Instance.new("TextLabel", MainToggleFrame)
TitleLabel.Text = "  Speed Hack"
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1

-- Кнопка переключения Speed Hack (Вкл/Выкл)
local ToggleBtn = Instance.new("TextButton", MainToggleFrame)
ToggleBtn.Position = UDim2.new(1, -44, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 34, 0, 22)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
ToggleBtn.Text = ""
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.SpeedHack = not Settings.SpeedHack
    local targetColor = Settings.SpeedHack and Color3.fromRGB(130, 70, 220) or Color3.fromRGB(50, 50, 70)
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    
    if not Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Маленькая шестеренка прямо в блоке функции
local InnerGearBtn = Instance.new("ImageButton", MainToggleFrame)
InnerGearBtn.Size = UDim2.new(0, 22, 0, 22)
InnerGearBtn.Position = UDim2.new(1, -74, 0.2, 0)
InnerGearBtn.BackgroundTransparency = 1
InnerGearBtn.Image = "rbxassetid://7059346373"
InnerGearBtn.ImageColor3 = Color3.fromRGB(180, 180, 210)

-- Ползунок настройки скорости внутри панели
local SpeedText = Instance.new("TextLabel", SpeedPanel)
SpeedText.Size = UDim2.new(1, -20, 0, 20)
SpeedText.Position = UDim2.new(0, 10, 0, 45)
SpeedText.BackgroundTransparency = 1
SpeedText.Text = "Speed: 5"
SpeedText.TextColor3 = Color3.fromRGB(200, 180, 255)
SpeedText.Font = Enum.Font.GothamSemibold
SpeedText.TextSize = 12
SpeedText.TextXAlignment = Enum.TextXAlignment.Left

local SliderBack = Instance.new("Frame", SpeedPanel)
SliderBack.Size = UDim2.new(1, -20, 0, 8)
SliderBack.Position = UDim2.new(0, 10, 0, 75)
SliderBack.BackgroundColor3 = Color3.fromRGB(38, 32, 52)
Instance.new("UICorner", SliderBack).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame", SliderBack)
SliderFill.Size = UDim2.new(0, 0, 1, 0) -- Начинается с 0 (скорость 5)
SliderFill.BackgroundColor3 = Color3.fromRGB(130, 80, 230)
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderKnob = Instance.new("Frame", SliderBack)
SliderKnob.Size = UDim2.new(0, 16, 0, 16)
SliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
SliderKnob.BackgroundColor3 = Color3.fromRGB(220, 200, 255)
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

-- Логика движения ползунка
local dragging = false
local minSpeed = 5
local maxSpeed = 150 -- Максимальная скорость регулируется без ограничений

local function UpdateSlider(input)
    local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
    SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
    
    local speedVal = math.floor(minSpeed + (pos * (maxSpeed - minSpeed)))
    Settings.WalkSpeed = speedVal
    SpeedText.Text = "Speed: " .. tostring(speedVal)
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

-- [[ 6. АНИМАЦИИ ВРАЩЕНИЯ И ВЫЕЗЖАНИЯ ПАНЕЛИ ]]
local panelOpen = false
local gearRotation = 0

GearButton.MouseButton1Click:Connect(function()
    panelOpen = not panelOpen
    gearRotation = gearRotation + 180

    -- Вращение главной плавающей шестеренки
    TweenService:Create(GearButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = gearRotation
    }):Play()

    -- Выезжание/скрытие панели
    local targetY = panelOpen and -140 or 100
    TweenService:Create(SpeedPanel, TweenInfo.new(0.4, Enum.EasingStyle.Back, panelOpen and Enum.EasingDirection.Out or Enum.EasingDirection.In), {
        Position = UDim2.new(1, -320, 1, targetY)
    }):Play()
end)

-- Вращение внутренней шестеренки на кнопке функции
local innerRot = 0
InnerGearBtn.MouseButton1Click:Connect(function()
    innerRot = innerRot + 180
    TweenService:Create(InnerGearBtn, TweenInfo.new(0.3), {Rotation = innerRot}):Play()
end)

-- [[ 7. РАБОТА СПИДХАКА ]]
RunService.Stepped:Connect(function()
    pcall(function()
        if Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        end
    end)
end)
