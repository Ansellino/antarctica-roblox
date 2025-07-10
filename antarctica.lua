-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- Mobile Detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local DefaultWalkspeed = 1
local CurrentWalkspeed = DefaultWalkspeed
local DefaultJumpPower = 1
local CurrentJumpPower = DefaultJumpPower
local UIVisible = true
local JumpButtonVisible = true

-- Anti-damage features
local AntiFallDamage = false
local AntiWaterDamage = false
local OriginalMaxHealth = nil
local DamageConnections = {}

-- Membuat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WalkspeedGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame - Responsive untuk mobile dengan tinggi yang disesuaikan
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
-- Ukuran responsif: lebih besar di mobile dengan tinggi yang disesuaikan untuk jump controls dan anti-damage features
MainFrame.Size = IsMobile and UDim2.new(0, 420, 0, 600) or UDim2.new(0, 400, 0, 570)
MainFrame.Position = UDim2.new(0.5, IsMobile and -210 or -200, 0.5, IsMobile and -300 or -285)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Membuat rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Gradient Background untuk main frame
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

-- Shadow effect untuk main frame
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 6, 1, 6)
Shadow.Position = UDim2.new(0, -3, 0, -3)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.8
Shadow.BorderSizePixel = 0
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 15)
ShadowCorner.Parent = Shadow



-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Gradient untuk title bar
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
}
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

-- Fix untuk rounded corner di bottom
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -90, 1, 0)
TitleText.Position = UDim2.new(0, 20, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Speed & Jump Controller"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextScaled = true
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.SourceSansBold
TitleText.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0.5, -20)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Gradient untuk Close Button
local CloseGradient = Instance.new("UIGradient")
CloseGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 40, 40))
}
CloseGradient.Rotation = 90
CloseGradient.Parent = CloseButton

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -40, 1, -80)
ContentFrame.Position = UDim2.new(0, 20, 0, 70)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Speed Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "💨 Speed Control"
SpeedLabel.TextColor3 = Color3.fromRGB(100, 170, 255)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Parent = ContentFrame

-- Speed Value Display
local SpeedValueLabel = Instance.new("TextLabel")
SpeedValueLabel.Name = "SpeedValueLabel"
SpeedValueLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedValueLabel.Position = UDim2.new(0, 0, 0, 25)
SpeedValueLabel.BackgroundTransparency = 1
SpeedValueLabel.Text = "Current: " .. CurrentWalkspeed
SpeedValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedValueLabel.TextScaled = true
SpeedValueLabel.Font = Enum.Font.SourceSans
SpeedValueLabel.Parent = ContentFrame

-- Slider Background
local SliderBG = Instance.new("Frame")
SliderBG.Name = "SliderBackground"
SliderBG.Size = UDim2.new(1, 0, 0, 20)
SliderBG.Position = UDim2.new(0, 0, 0, 50)
SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBG.BorderSizePixel = 0
SliderBG.Parent = ContentFrame

local SliderBGCorner = Instance.new("UICorner")
SliderBGCorner.CornerRadius = UDim.new(0, 10)
SliderBGCorner.Parent = SliderBG

-- Slider Fill
local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new((CurrentWalkspeed - 0) / 200, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBG

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 10)
SliderFillCorner.Parent = SliderFill

-- Slider Button
local SliderButton = Instance.new("Frame")
SliderButton.Name = "SliderButton"
SliderButton.Size = UDim2.new(0, 20, 0, 20)
SliderButton.Position = UDim2.new((CurrentWalkspeed - 0) / 200, -10, 0.5, -10)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.BorderSizePixel = 0
SliderButton.Parent = SliderBG

local SliderButtonCorner = Instance.new("UICorner")
SliderButtonCorner.CornerRadius = UDim.new(1, 0)
SliderButtonCorner.Parent = SliderButton

-- Jump Power Section
-- Jump Label
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Name = "JumpLabel"
JumpLabel.Size = UDim2.new(1, 0, 0, 25)
JumpLabel.Position = UDim2.new(0, 0, 0, 130)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "🚀 Jump Power Control"
JumpLabel.TextColor3 = Color3.fromRGB(255, 170, 50)
JumpLabel.TextScaled = true
JumpLabel.Font = Enum.Font.SourceSansBold
JumpLabel.Parent = ContentFrame

-- Jump Value Display
local JumpValueLabel = Instance.new("TextLabel")
JumpValueLabel.Name = "JumpValueLabel"
JumpValueLabel.Size = UDim2.new(1, 0, 0, 20)
JumpValueLabel.Position = UDim2.new(0, 0, 0, 155)
JumpValueLabel.BackgroundTransparency = 1
JumpValueLabel.Text = "Current: " .. CurrentJumpPower
JumpValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JumpValueLabel.TextScaled = true
JumpValueLabel.Font = Enum.Font.SourceSans
JumpValueLabel.Parent = ContentFrame

-- Jump Slider Background
local JumpSliderBG = Instance.new("Frame")
JumpSliderBG.Name = "JumpSliderBackground"
JumpSliderBG.Size = UDim2.new(1, 0, 0, 20)
JumpSliderBG.Position = UDim2.new(0, 0, 0, 180)
JumpSliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JumpSliderBG.BorderSizePixel = 0
JumpSliderBG.Parent = ContentFrame

local JumpSliderBGCorner = Instance.new("UICorner")
JumpSliderBGCorner.CornerRadius = UDim.new(0, 10)
JumpSliderBGCorner.Parent = JumpSliderBG

-- Jump Slider Fill
local JumpSliderFill = Instance.new("Frame")
JumpSliderFill.Name = "JumpSliderFill"
JumpSliderFill.Size = UDim2.new((CurrentJumpPower - 0) / 500, 0, 1, 0)
JumpSliderFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
JumpSliderFill.BorderSizePixel = 0
JumpSliderFill.Parent = JumpSliderBG

local JumpSliderFillCorner = Instance.new("UICorner")
JumpSliderFillCorner.CornerRadius = UDim.new(0, 10)
JumpSliderFillCorner.Parent = JumpSliderFill

-- Jump Slider Button
local JumpSliderButton = Instance.new("Frame")
JumpSliderButton.Name = "JumpSliderButton"
JumpSliderButton.Size = UDim2.new(0, 20, 0, 20)
JumpSliderButton.Position = UDim2.new((CurrentJumpPower - 0) / 500, -10, 0.5, -10)
JumpSliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JumpSliderButton.BorderSizePixel = 0
JumpSliderButton.Parent = JumpSliderBG

local JumpSliderButtonCorner = Instance.new("UICorner")
JumpSliderButtonCorner.CornerRadius = UDim.new(1, 0)
JumpSliderButtonCorner.Parent = JumpSliderButton

-- Jump Control Buttons
local JumpControlFrame = Instance.new("Frame")
JumpControlFrame.Name = "JumpControlFrame"
JumpControlFrame.Size = UDim2.new(1, 0, 0, 40)
JumpControlFrame.Position = UDim2.new(0, 0, 0, 210)
JumpControlFrame.BackgroundTransparency = 1
JumpControlFrame.Parent = ContentFrame

-- Decrease Jump Button (-)
local DecreaseJumpButton = Instance.new("TextButton")
DecreaseJumpButton.Name = "DecreaseJumpButton"
DecreaseJumpButton.Size = IsMobile and UDim2.new(0, 45, 0, 40) or UDim2.new(0, 35, 0, 35)
DecreaseJumpButton.Position = UDim2.new(0, 0, 0.5, IsMobile and -20 or -17.5)
DecreaseJumpButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
DecreaseJumpButton.Text = "−"
DecreaseJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecreaseJumpButton.TextSize = IsMobile and 24 or 20
DecreaseJumpButton.Font = Enum.Font.SourceSansBold
DecreaseJumpButton.BorderSizePixel = 0
DecreaseJumpButton.Parent = JumpControlFrame

local DecreaseJumpCorner = Instance.new("UICorner")
DecreaseJumpCorner.CornerRadius = UDim.new(0, 8)
DecreaseJumpCorner.Parent = DecreaseJumpButton

-- Jump Power Display
local JumpDisplay = Instance.new("TextLabel")
JumpDisplay.Name = "JumpDisplay"
JumpDisplay.Size = IsMobile and UDim2.new(1, -110, 0, 30) or UDim2.new(1, -90, 0, 25)
JumpDisplay.Position = IsMobile and UDim2.new(0, 55, 0.5, -15) or UDim2.new(0, 45, 0.5, -12.5)
JumpDisplay.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
JumpDisplay.Text = "Jump: " .. math.floor(CurrentJumpPower)
JumpDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpDisplay.TextScaled = true
JumpDisplay.Font = Enum.Font.SourceSansBold
JumpDisplay.BorderSizePixel = 0
JumpDisplay.Parent = JumpControlFrame

local JumpDisplayCorner = Instance.new("UICorner")
JumpDisplayCorner.CornerRadius = UDim.new(0, 6)
JumpDisplayCorner.Parent = JumpDisplay

-- Increase Jump Button (+)
local IncreaseJumpButton = Instance.new("TextButton")
IncreaseJumpButton.Name = "IncreaseJumpButton"
IncreaseJumpButton.Size = IsMobile and UDim2.new(0, 45, 0, 40) or UDim2.new(0, 35, 0, 35)
IncreaseJumpButton.Position = IsMobile and UDim2.new(1, -45, 0.5, -20) or UDim2.new(1, -35, 0.5, -17.5)
IncreaseJumpButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
IncreaseJumpButton.Text = "+"
IncreaseJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IncreaseJumpButton.TextSize = IsMobile and 24 or 20
IncreaseJumpButton.Font = Enum.Font.SourceSansBold
IncreaseJumpButton.BorderSizePixel = 0
IncreaseJumpButton.Parent = JumpControlFrame

local IncreaseJumpCorner = Instance.new("UICorner")
IncreaseJumpCorner.CornerRadius = UDim.new(0, 8)
IncreaseJumpCorner.Parent = IncreaseJumpButton

-- Speed Control Buttons dengan layout yang lebih rapi
-- Container untuk speed control buttons
local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Name = "SpeedControlFrame"
SpeedControlFrame.Size = UDim2.new(1, 0, 0, 40)
SpeedControlFrame.Position = UDim2.new(0, 0, 0, 80)
SpeedControlFrame.BackgroundTransparency = 1
SpeedControlFrame.Parent = ContentFrame

-- Decrease Speed Button (-)
local DecreaseButton = Instance.new("TextButton")
DecreaseButton.Name = "DecreaseButton"
DecreaseButton.Size = IsMobile and UDim2.new(0, 45, 0, 40) or UDim2.new(0, 35, 0, 35)
DecreaseButton.Position = UDim2.new(0, 0, 0.5, IsMobile and -20 or -17.5)
DecreaseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
DecreaseButton.Text = "−"
DecreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecreaseButton.TextSize = IsMobile and 24 or 20
DecreaseButton.Font = Enum.Font.SourceSansBold
DecreaseButton.BorderSizePixel = 0
DecreaseButton.Parent = SpeedControlFrame

local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 8)
DecreaseCorner.Parent = DecreaseButton

-- Speed Display dalam speed control
local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Name = "SpeedDisplay"
SpeedDisplay.Size = IsMobile and UDim2.new(1, -110, 0, 30) or UDim2.new(1, -90, 0, 25)
SpeedDisplay.Position = IsMobile and UDim2.new(0, 55, 0.5, -15) or UDim2.new(0, 45, 0.5, -12.5)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedDisplay.Text = "Speed: " .. math.floor(CurrentWalkspeed)
SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedDisplay.TextScaled = true
SpeedDisplay.Font = Enum.Font.SourceSansBold
SpeedDisplay.BorderSizePixel = 0
SpeedDisplay.Parent = SpeedControlFrame

local SpeedDisplayCorner = Instance.new("UICorner")
SpeedDisplayCorner.CornerRadius = UDim.new(0, 6)
SpeedDisplayCorner.Parent = SpeedDisplay

-- Increase Speed Button (+)
local IncreaseButton = Instance.new("TextButton")
IncreaseButton.Name = "IncreaseButton"
IncreaseButton.Size = IsMobile and UDim2.new(0, 45, 0, 40) or UDim2.new(0, 35, 0, 35)
IncreaseButton.Position = IsMobile and UDim2.new(1, -45, 0.5, -20) or UDim2.new(1, -35, 0.5, -17.5)
IncreaseButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
IncreaseButton.Text = "+"
IncreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IncreaseButton.TextSize = IsMobile and 24 or 20
IncreaseButton.Font = Enum.Font.SourceSansBold
IncreaseButton.BorderSizePixel = 0
IncreaseButton.Parent = SpeedControlFrame

local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 8)
IncreaseCorner.Parent = IncreaseButton

-- Reset Button
local ResetButton = Instance.new("TextButton")
ResetButton.Name = "ResetButton"
ResetButton.Size = UDim2.new(0.45, -5, 0, 35)
ResetButton.Position = UDim2.new(0, 0, 0, 260)
ResetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ResetButton.Text = "Reset"
ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetButton.TextScaled = true
ResetButton.Font = Enum.Font.SourceSansBold
ResetButton.BorderSizePixel = 0
ResetButton.Parent = ContentFrame

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 8)
ResetCorner.Parent = ResetButton

-- Gradient untuk Reset Button
local ResetGradient = Instance.new("UIGradient")
ResetGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 70, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
}
ResetGradient.Rotation = 90
ResetGradient.Parent = ResetButton

-- Apply Button
local ApplyButton = Instance.new("TextButton")
ApplyButton.Name = "ApplyButton"
ApplyButton.Size = UDim2.new(0.45, -5, 0, 35)
ApplyButton.Position = UDim2.new(0.55, 5, 0, 260)
ApplyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ApplyButton.Text = "Apply"
ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyButton.TextScaled = true
ApplyButton.Font = Enum.Font.SourceSansBold
ApplyButton.BorderSizePixel = 0
ApplyButton.Parent = ContentFrame

local ApplyCorner = Instance.new("UICorner")
ApplyCorner.CornerRadius = UDim.new(0, 8)
ApplyCorner.Parent = ApplyButton

-- Gradient untuk Apply Button
local ApplyGradient = Instance.new("UIGradient")
ApplyGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 190, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 200))
}
ApplyGradient.Rotation = 90
ApplyGradient.Parent = ApplyButton

-- Toggle Jump Button
local ToggleJumpButton = Instance.new("TextButton")
ToggleJumpButton.Name = "ToggleJumpButton"
ToggleJumpButton.Size = UDim2.new(1, 0, 0, 30)
ToggleJumpButton.Position = UDim2.new(0, 0, 0, 305)
ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleJumpButton.Text = "Hide Jump Button"
ToggleJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleJumpButton.TextScaled = true
ToggleJumpButton.Font = Enum.Font.SourceSansBold
ToggleJumpButton.BorderSizePixel = 0
ToggleJumpButton.Parent = ContentFrame

local ToggleJumpCorner = Instance.new("UICorner")
ToggleJumpCorner.CornerRadius = UDim.new(0, 8)
ToggleJumpCorner.Parent = ToggleJumpButton

-- Gradient untuk Toggle Jump Button
local ToggleJumpGradient = Instance.new("UIGradient")
ToggleJumpGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
}
ToggleJumpGradient.Rotation = 90
ToggleJumpGradient.Parent = ToggleJumpButton

-- Hide UI Button (di dalam content frame, di atas hide button utama)
local HideUIButton = Instance.new("TextButton")
HideUIButton.Name = "HideUIButton"
HideUIButton.Size = UDim2.new(1, 0, 0, 30)
HideUIButton.Position = UDim2.new(0, 0, 0, 445)
HideUIButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
HideUIButton.Text = "Hide Interface"
HideUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideUIButton.TextScaled = true
HideUIButton.Font = Enum.Font.SourceSansBold
HideUIButton.BorderSizePixel = 0
HideUIButton.Parent = ContentFrame

local HideUICorner = Instance.new("UICorner")
HideUICorner.CornerRadius = UDim.new(0, 8)
HideUICorner.Parent = HideUIButton

-- Gradient untuk hide UI button
local HideUIGradient = Instance.new("UIGradient")
HideUIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 140, 140)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))
}
HideUIGradient.Rotation = 90
HideUIGradient.Parent = HideUIButton

-- Anti-Damage Section
-- Anti-Fall Damage Section
local AntiFallLabel = Instance.new("TextLabel")
AntiFallLabel.Name = "AntiFallLabel"
AntiFallLabel.Size = UDim2.new(1, 0, 0, 25)
AntiFallLabel.Position = UDim2.new(0, 0, 0, 360)
AntiFallLabel.BackgroundTransparency = 1
AntiFallLabel.Text = "🛡️ Protection Features"
AntiFallLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
AntiFallLabel.TextScaled = true
AntiFallLabel.Font = Enum.Font.SourceSansBold
AntiFallLabel.Parent = ContentFrame

-- Anti Fall Damage Toggle
local AntiFallToggle = Instance.new("TextButton")
AntiFallToggle.Name = "AntiFallToggle"
AntiFallToggle.Size = UDim2.new(0.48, -2.5, 0, 30)
AntiFallToggle.Position = UDim2.new(0, 0, 0, 385)
AntiFallToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AntiFallToggle.Text = "Anti Fall Damage: OFF"
AntiFallToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiFallToggle.TextScaled = true
AntiFallToggle.Font = Enum.Font.SourceSansBold
AntiFallToggle.BorderSizePixel = 0
AntiFallToggle.Parent = ContentFrame

local AntiFallCorner = Instance.new("UICorner")
AntiFallCorner.CornerRadius = UDim.new(0, 8)
AntiFallCorner.Parent = AntiFallToggle

-- Anti Water Damage Toggle
local AntiWaterToggle = Instance.new("TextButton")
AntiWaterToggle.Name = "AntiWaterToggle"
AntiWaterToggle.Size = UDim2.new(0.48, -2.5, 0, 30)
AntiWaterToggle.Position = UDim2.new(0.52, 2.5, 0, 385)
AntiWaterToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AntiWaterToggle.Text = "Anti Water Damage: OFF"
AntiWaterToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiWaterToggle.TextScaled = true
AntiWaterToggle.Font = Enum.Font.SourceSansBold
AntiWaterToggle.BorderSizePixel = 0
AntiWaterToggle.Parent = ContentFrame

local AntiWaterCorner = Instance.new("UICorner")
AntiWaterCorner.CornerRadius = UDim.new(0, 8)
AntiWaterCorner.Parent = AntiWaterToggle

-- Functions
local function UpdateWalkspeed(speed)
    CurrentWalkspeed = math.clamp(speed, 0, 200)
    SpeedValueLabel.Text = "Current: " .. math.floor(CurrentWalkspeed)
    SpeedDisplay.Text = "Speed: " .. math.floor(CurrentWalkspeed)
    
    local percentage = (CurrentWalkspeed - 0) / 200
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderButton.Position = UDim2.new(percentage, -10, 0.5, -10)
end

local function UpdateJumpPower(jumpPower)
    CurrentJumpPower = math.clamp(jumpPower, 0, 500)
    JumpValueLabel.Text = "Current: " .. math.floor(CurrentJumpPower)
    JumpDisplay.Text = "Jump: " .. math.floor(CurrentJumpPower)
    
    local percentage = (CurrentJumpPower - 0) / 500
    JumpSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    JumpSliderButton.Position = UDim2.new(percentage, -10, 0.5, -10)
end

local function ApplyWalkspeed()
    if Humanoid then
        Humanoid.WalkSpeed = CurrentWalkspeed
    end
end

local function ApplyJumpPower()
    if Humanoid then
        -- Check if the humanoid uses JumpHeight (newer system) or JumpPower (older system)
        if Humanoid.UseJumpPower then
            Humanoid.JumpPower = CurrentJumpPower
        else
            -- Convert JumpPower to JumpHeight for newer system
            Humanoid.JumpHeight = CurrentJumpPower * 0.35 -- Conversion factor
        end
    end
end

local function ApplyAll()
    ApplyWalkspeed()
    ApplyJumpPower()
end

local function ResetWalkspeed()
    UpdateWalkspeed(DefaultWalkspeed)
    UpdateJumpPower(DefaultJumpPower)
    ApplyAll()
end

local function IncreaseSpeed()
    local newSpeed = CurrentWalkspeed + 1
    UpdateWalkspeed(newSpeed)
    ApplyWalkspeed()
end

local function DecreaseSpeed()
    local newSpeed = CurrentWalkspeed - 1
    UpdateWalkspeed(newSpeed)
    ApplyWalkspeed()
end

local function IncreaseJump()
    local newJumpPower = CurrentJumpPower + 1
    UpdateJumpPower(newJumpPower)
    ApplyJumpPower()
end

local function DecreaseJump()
    local newJumpPower = CurrentJumpPower - 1
    UpdateJumpPower(newJumpPower)
    ApplyJumpPower()
end

local function ToggleJumpButtonVisibility()
    JumpButtonVisible = not JumpButtonVisible
    JumpButton.Visible = JumpButtonVisible
    
    if JumpButtonVisible then
        ToggleJumpButton.Text = "Hide Jump Button"
        ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        
        -- Animasi fade in untuk jump button
        JumpButton.BackgroundTransparency = 1
        JumpButton.TextTransparency = 1
        TweenService:Create(JumpButton, TweenInfo.new(0.3), {
            BackgroundTransparency = 0,
            TextTransparency = 0
        }):Play()
    else
        ToggleJumpButton.Text = "Show Jump Button"
        ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    end
end

local function DoJump()
    if Humanoid and Humanoid.Parent and Humanoid.Parent:FindFirstChild("HumanoidRootPart") then
        -- Apply current jump power before jumping
        ApplyJumpPower()
        
        -- Make the character jump
        Humanoid.Jump = true
        
        -- Visual feedback - button press effect
        local originalSize = JumpButton.Size
        TweenService:Create(JumpButton, TweenInfo.new(0.1), {
            Size = originalSize * 0.9
        }):Play()
        
        wait(0.1)
        TweenService:Create(JumpButton, TweenInfo.new(0.1), {
            Size = originalSize
        }):Play()
    end
end

-- Anti-Damage Functions
local function ToggleAntiFallDamage()
    AntiFallDamage = not AntiFallDamage
    
    if AntiFallDamage then
        AntiFallToggle.Text = "Anti Fall Damage: ON"
        AntiFallToggle.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Store original max health if not already stored
        if not OriginalMaxHealth and Humanoid then
            OriginalMaxHealth = Humanoid.MaxHealth
        end
        
        -- Prevent fall damage by monitoring health changes
        if DamageConnections.FallDamage then
            DamageConnections.FallDamage:Disconnect()
        end
        
        -- More comprehensive fall damage protection
        DamageConnections.FallDamage = RunService.Heartbeat:Connect(function()
            if Humanoid and Humanoid.Health < Humanoid.MaxHealth and Humanoid.Health > 0 then
                -- Check if the character is falling or just landed
                local humanoidState = Humanoid:GetState()
                if humanoidState == Enum.HumanoidStateType.Freefall or 
                   humanoidState == Enum.HumanoidStateType.Flying or
                   humanoidState == Enum.HumanoidStateType.Landed then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end
        end)
        
        -- Additional protection through HealthChanged event
        DamageConnections.FallDamageHealth = Humanoid.HealthChanged:Connect(function(health)
            if health < Humanoid.MaxHealth and health > 0 then
                -- Small delay to ensure it's damage and not intentional health change
                task.wait(0.01)
                if Humanoid and Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end
        end)
    else
        AntiFallToggle.Text = "Anti Fall Damage: OFF"
        AntiFallToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        -- Disconnect fall damage protection
        if DamageConnections.FallDamage then
            DamageConnections.FallDamage:Disconnect()
            DamageConnections.FallDamage = nil
        end
        if DamageConnections.FallDamageHealth then
            DamageConnections.FallDamageHealth:Disconnect()
            DamageConnections.FallDamageHealth = nil
        end
    end
end

local function ToggleAntiWaterDamage()
    AntiWaterDamage = not AntiWaterDamage
    
    if AntiWaterDamage then
        AntiWaterToggle.Text = "Anti Water Damage: ON"
        AntiWaterToggle.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
        
        -- Store original max health if not already stored
        if not OriginalMaxHealth and Humanoid then
            OriginalMaxHealth = Humanoid.MaxHealth
        end
        
        -- Prevent water damage by monitoring health and position
        if DamageConnections.WaterDamage then
            DamageConnections.WaterDamage:Disconnect()
        end
        
        DamageConnections.WaterDamage = RunService.Heartbeat:Connect(function()
            if Humanoid and Character and Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = Character.HumanoidRootPart
                local humanoidState = Humanoid:GetState()
                
                -- Check if player is in water or swimming
                if humanoidState == Enum.HumanoidStateType.Swimming or 
                   humanoidState == Enum.HumanoidStateType.PlatformStanding then
                    -- Restore health if it's not at maximum
                    if Humanoid.Health < Humanoid.MaxHealth then
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end
                
                -- Additional check: if position Y is below certain threshold (indicating water)
                if humanoidRootPart.Position.Y < -10 and Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end
        end)
        
        -- Additional protection through HealthChanged event for water damage
        DamageConnections.WaterDamageHealth = Humanoid.HealthChanged:Connect(function(health)
            if health < Humanoid.MaxHealth and health > 0 then
                local humanoidState = Humanoid:GetState()
                if humanoidState == Enum.HumanoidStateType.Swimming then
                    task.wait(0.01)
                    if Humanoid and Humanoid.Health < Humanoid.MaxHealth then
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end
            end
        end)
    else
        AntiWaterToggle.Text = "Anti Water Damage: OFF"
        AntiWaterToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        -- Disconnect water damage protection
        if DamageConnections.WaterDamage then
            DamageConnections.WaterDamage:Disconnect()
            DamageConnections.WaterDamage = nil
        end
        if DamageConnections.WaterDamageHealth then
            DamageConnections.WaterDamageHealth:Disconnect()
            DamageConnections.WaterDamageHealth = nil
        end
    end
end

-- Slider functionality
local dragging = false
local jumpDragging = false

-- Mouse/Touch input untuk slider
SliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        -- Update posisi langsung saat klik/touch
        local mouse = input.Position
        local relativeX = mouse.X - SliderBG.AbsolutePosition.X
        local percentage = math.clamp(relativeX / SliderBG.AbsoluteSize.X, 0, 1)
        local speed = percentage * 200
        UpdateWalkspeed(speed)
    end
end)

SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

-- Jump Slider functionality
JumpSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        jumpDragging = true
        -- Update posisi langsung saat klik/touch
        local mouse = input.Position
        local relativeX = mouse.X - JumpSliderBG.AbsolutePosition.X
        local percentage = math.clamp(relativeX / JumpSliderBG.AbsoluteSize.X, 0, 1)
        local jumpPower = percentage * 500
        UpdateJumpPower(jumpPower)
    end
end)

JumpSliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        jumpDragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        jumpDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if dragging then
            local mouse = input.Position
            local relativeX = mouse.X - SliderBG.AbsolutePosition.X
            local percentage = math.clamp(relativeX / SliderBG.AbsoluteSize.X, 0, 1)
            local speed = percentage * 200
            UpdateWalkspeed(speed)
        end
        
        if jumpDragging then
            local mouse = input.Position
            local relativeX = mouse.X - JumpSliderBG.AbsolutePosition.X
            local percentage = math.clamp(relativeX / JumpSliderBG.AbsoluteSize.X, 0, 1)
            local jumpPower = percentage * 500
            UpdateJumpPower(jumpPower)
        end
    end
end)

-- Button connections
ResetButton.MouseButton1Click:Connect(ResetWalkspeed)
ApplyButton.MouseButton1Click:Connect(ApplyAll)
CloseButton.MouseButton1Click:Connect(ToggleUI)
HideUIButton.MouseButton1Click:Connect(HideUI)
ShowButton.MouseButton1Click:Connect(ShowUI)
IncreaseButton.MouseButton1Click:Connect(IncreaseSpeed)
DecreaseButton.MouseButton1Click:Connect(DecreaseSpeed)
IncreaseJumpButton.MouseButton1Click:Connect(IncreaseJump)
DecreaseJumpButton.MouseButton1Click:Connect(DecreaseJump)
ToggleJumpButton.MouseButton1Click:Connect(ToggleJumpButtonVisibility)
JumpButton.MouseButton1Click:Connect(DoJump)

-- Anti-damage button connections
AntiFallToggle.MouseButton1Click:Connect(ToggleAntiFallDamage)
AntiWaterToggle.MouseButton1Click:Connect(ToggleAntiWaterDamage)

-- Toggle UI dengan RightShift (hanya untuk PC)
if not IsMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            ToggleUI()
        end
    end)
end

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    
    -- Restore original max health
    if OriginalMaxHealth then
        Humanoid.MaxHealth = OriginalMaxHealth
        Humanoid.Health = OriginalMaxHealth
    end
    
    ApplyAll()
    
    -- Reapply anti-damage features if they were enabled
    if AntiFallDamage then
        AntiFallDamage = false  -- Reset to trigger the toggle function
        ToggleAntiFallDamage()
    end
    
    if AntiWaterDamage then
        AntiWaterDamage = false  -- Reset to trigger the toggle function
        ToggleAntiWaterDamage()
    end
end)

-- Button hover effects
local function ButtonHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

ButtonHover(ResetButton, Color3.fromRGB(60, 60, 60), Color3.fromRGB(90, 90, 90))
ButtonHover(ApplyButton, Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 190, 255))
ButtonHover(CloseButton, Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 80, 80))
ButtonHover(HideUIButton, Color3.fromRGB(120, 120, 120), Color3.fromRGB(150, 150, 150))
ButtonHover(ShowButton, Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 150, 230))
ButtonHover(IncreaseButton, Color3.fromRGB(100, 255, 100), Color3.fromRGB(120, 255, 120))
ButtonHover(DecreaseButton, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 120, 120))
ButtonHover(IncreaseJumpButton, Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 190, 30))
ButtonHover(DecreaseJumpButton, Color3.fromRGB(255, 140, 0), Color3.fromRGB(255, 160, 30))

-- Hover effects untuk anti-damage buttons
AntiFallToggle.MouseEnter:Connect(function()
    local targetColor = AntiFallDamage and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(100, 100, 100)
    TweenService:Create(AntiFallToggle, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end)

AntiFallToggle.MouseLeave:Connect(function()
    local targetColor = AntiFallDamage and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(80, 80, 80)
    TweenService:Create(AntiFallToggle, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end)

AntiWaterToggle.MouseEnter:Connect(function()
    local targetColor = AntiWaterDamage and Color3.fromRGB(120, 190, 255) or Color3.fromRGB(100, 100, 100)
    TweenService:Create(AntiWaterToggle, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end)

AntiWaterToggle.MouseLeave:Connect(function()
    local targetColor = AntiWaterDamage and Color3.fromRGB(100, 170, 255) or Color3.fromRGB(80, 80, 80)
    TweenService:Create(AntiWaterToggle, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
end)

-- Hover effect untuk JumpButton
JumpButton.MouseEnter:Connect(function()
    TweenService:Create(JumpButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 190, 30)
    }):Play()
end)

JumpButton.MouseLeave:Connect(function()
    TweenService:Create(JumpButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    }):Play()
end)

-- Hover effect untuk SpeedDisplay
SpeedDisplay.MouseEnter:Connect(function()
    TweenService:Create(SpeedDisplay, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    }):Play()
end)

SpeedDisplay.MouseLeave:Connect(function()
    TweenService:Create(SpeedDisplay, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    }):Play()
end)

-- Hover effect untuk JumpDisplay
JumpDisplay.MouseEnter:Connect(function()
    TweenService:Create(JumpDisplay, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    }):Play()
end)

JumpDisplay.MouseLeave:Connect(function()
    TweenService:Create(JumpDisplay, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    }):Play()
end)

-- Initial setup
UpdateWalkspeed(DefaultWalkspeed)
UpdateJumpPower(DefaultJumpPower)

-- Auto-enable anti-damage features for better protection
ToggleAntiFallDamage() -- Enable anti-fall damage by default
ToggleAntiWaterDamage() -- Enable anti-water damage by default

-- Notification
local notificationText = IsMobile and 
    "Successfully loaded! Mobile-friendly UI with Speed & Jump controls + Anti-Damage features + Jump Button. Use Hide/Show buttons to toggle." or
    "Successfully loaded! Speed & Jump controls + Anti-Damage features + Jump Button. Use Hide/Show buttons or RightShift to toggle UI"

game.StarterGui:SetCore("SendNotification", {
    Title = "Enhanced Speed & Jump Script",
    Text = notificationText,
    Duration = 5
})