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
local DefaultWalkspeed = 16
local CurrentWalkspeed = DefaultWalkspeed
local DefaultJumpPower = 50
local CurrentJumpPower = DefaultJumpPower
local UIVisible = true
local JumpButtonVisible = true
local CurrentTab = "Speed" -- "Speed" or "Protection"

-- Anti-damage features
local AntiFallDamage = false
local AntiWaterDamage = false
local DamageConnections = {}
local LastHealth = nil
local FallStartHeight = nil

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EnhancedControlGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame - Responsive with tab system
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = IsMobile and UDim2.new(0, 420, 0, 450) or UDim2.new(0, 400, 0, 420)
MainFrame.Position = UDim2.new(0.5, IsMobile and -210 or -200, 0.5, IsMobile and -225 or -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Gradient Background
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

-- Shadow effect
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

-- Title Gradient
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
}
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

-- Title Fix
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
TitleText.Text = "Game Enhancement"
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

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -40, 0, 40)
TabContainer.Position = UDim2.new(0, 20, 0, 70)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

-- Speed Tab Button
local SpeedTabButton = Instance.new("TextButton")
SpeedTabButton.Name = "SpeedTabButton"
SpeedTabButton.Size = UDim2.new(0.5, -5, 1, 0)
SpeedTabButton.Position = UDim2.new(0, 0, 0, 0)
SpeedTabButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpeedTabButton.Text = "⚡ Speed & Jump"
SpeedTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedTabButton.TextScaled = true
SpeedTabButton.Font = Enum.Font.SourceSansBold
SpeedTabButton.BorderSizePixel = 0
SpeedTabButton.Parent = TabContainer

local SpeedTabCorner = Instance.new("UICorner")
SpeedTabCorner.CornerRadius = UDim.new(0, 8)
SpeedTabCorner.Parent = SpeedTabButton

-- Protection Tab Button
local ProtectionTabButton = Instance.new("TextButton")
ProtectionTabButton.Name = "ProtectionTabButton"
ProtectionTabButton.Size = UDim2.new(0.5, -5, 1, 0)
ProtectionTabButton.Position = UDim2.new(0.5, 5, 0, 0)
ProtectionTabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ProtectionTabButton.Text = "🛡️ Protection"
ProtectionTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ProtectionTabButton.TextScaled = true
ProtectionTabButton.Font = Enum.Font.SourceSansBold
ProtectionTabButton.BorderSizePixel = 0
ProtectionTabButton.Parent = TabContainer

local ProtectionTabCorner = Instance.new("UICorner")
ProtectionTabCorner.CornerRadius = UDim.new(0, 8)
ProtectionTabCorner.Parent = ProtectionTabButton

-- Content Frame (Parent for both tabs)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -40, 1, -130)
ContentFrame.Position = UDim2.new(0, 20, 0, 120)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Speed Tab Content
local SpeedContent = Instance.new("Frame")
SpeedContent.Name = "SpeedContent"
SpeedContent.Size = UDim2.new(1, 0, 1, 0)
SpeedContent.BackgroundTransparency = 1
SpeedContent.Parent = ContentFrame

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
SpeedLabel.Parent = SpeedContent

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
SpeedValueLabel.Parent = SpeedContent

-- Speed Slider Background
local SliderBG = Instance.new("Frame")
SliderBG.Name = "SliderBackground"
SliderBG.Size = UDim2.new(1, 0, 0, 20)
SliderBG.Position = UDim2.new(0, 0, 0, 50)
SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBG.BorderSizePixel = 0
SliderBG.Parent = SpeedContent

local SliderBGCorner = Instance.new("UICorner")
SliderBGCorner.CornerRadius = UDim.new(0, 10)
SliderBGCorner.Parent = SliderBG

-- Speed Slider Fill
local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new((CurrentWalkspeed - 0) / 200, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBG

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 10)
SliderFillCorner.Parent = SliderFill

-- Speed Slider Button
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

-- Speed Control Buttons
local SpeedControlFrame = Instance.new("Frame")
SpeedControlFrame.Name = "SpeedControlFrame"
SpeedControlFrame.Size = UDim2.new(1, 0, 0, 40)
SpeedControlFrame.Position = UDim2.new(0, 0, 0, 80)
SpeedControlFrame.BackgroundTransparency = 1
SpeedControlFrame.Parent = SpeedContent

-- Decrease Speed Button
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

-- Speed Display
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

-- Increase Speed Button
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

-- Jump Power Section
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Name = "JumpLabel"
JumpLabel.Size = UDim2.new(1, 0, 0, 25)
JumpLabel.Position = UDim2.new(0, 0, 0, 130)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "🚀 Jump Power Control"
JumpLabel.TextColor3 = Color3.fromRGB(255, 170, 50)
JumpLabel.TextScaled = true
JumpLabel.Font = Enum.Font.SourceSansBold
JumpLabel.Parent = SpeedContent

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
JumpValueLabel.Parent = SpeedContent

-- Jump Slider Background
local JumpSliderBG = Instance.new("Frame")
JumpSliderBG.Name = "JumpSliderBackground"
JumpSliderBG.Size = UDim2.new(1, 0, 0, 20)
JumpSliderBG.Position = UDim2.new(0, 0, 0, 180)
JumpSliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JumpSliderBG.BorderSizePixel = 0
JumpSliderBG.Parent = SpeedContent

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
JumpControlFrame.Parent = SpeedContent

-- Decrease Jump Button
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

-- Jump Display
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

-- Increase Jump Button
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

-- Protection Tab Content
local ProtectionContent = Instance.new("Frame")
ProtectionContent.Name = "ProtectionContent"
ProtectionContent.Size = UDim2.new(1, 0, 1, 0)
ProtectionContent.BackgroundTransparency = 1
ProtectionContent.Visible = false
ProtectionContent.Parent = ContentFrame

-- Protection Title
local ProtectionTitle = Instance.new("TextLabel")
ProtectionTitle.Name = "ProtectionTitle"
ProtectionTitle.Size = UDim2.new(1, 0, 0, 30)
ProtectionTitle.Position = UDim2.new(0, 0, 0, 0)
ProtectionTitle.BackgroundTransparency = 1
ProtectionTitle.Text = "🛡️ Protection Features"
ProtectionTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
ProtectionTitle.TextScaled = true
ProtectionTitle.Font = Enum.Font.SourceSansBold
ProtectionTitle.Parent = ProtectionContent

-- Anti Fall Damage Section
local AntiFallFrame = Instance.new("Frame")
AntiFallFrame.Name = "AntiFallFrame"
AntiFallFrame.Size = UDim2.new(1, 0, 0, 100)
AntiFallFrame.Position = UDim2.new(0, 0, 0, 40)
AntiFallFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
AntiFallFrame.BorderSizePixel = 0
AntiFallFrame.Parent = ProtectionContent

local AntiFallFrameCorner = Instance.new("UICorner")
AntiFallFrameCorner.CornerRadius = UDim.new(0, 8)
AntiFallFrameCorner.Parent = AntiFallFrame

-- Anti Fall Icon
local AntiFallIcon = Instance.new("TextLabel")
AntiFallIcon.Name = "AntiFallIcon"
AntiFallIcon.Size = UDim2.new(0, 60, 0, 60)
AntiFallIcon.Position = UDim2.new(0, 10, 0.5, -30)
AntiFallIcon.BackgroundTransparency = 1
AntiFallIcon.Text = "🪂"
AntiFallIcon.TextScaled = true
AntiFallIcon.Font = Enum.Font.SourceSansBold
AntiFallIcon.Parent = AntiFallFrame

-- Anti Fall Text
local AntiFallText = Instance.new("TextLabel")
AntiFallText.Name = "AntiFallText"
AntiFallText.Size = UDim2.new(1, -170, 0, 25)
AntiFallText.Position = UDim2.new(0, 80, 0, 15)
AntiFallText.BackgroundTransparency = 1
AntiFallText.Text = "Anti Fall Damage"
AntiFallText.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiFallText.TextScaled = true
AntiFallText.TextXAlignment = Enum.TextXAlignment.Left
AntiFallText.Font = Enum.Font.SourceSansBold
AntiFallText.Parent = AntiFallFrame

-- Anti Fall Description
local AntiFallDesc = Instance.new("TextLabel")
AntiFallDesc.Name = "AntiFallDesc"
AntiFallDesc.Size = UDim2.new(1, -170, 0, 20)
AntiFallDesc.Position = UDim2.new(0, 80, 0, 45)
AntiFallDesc.BackgroundTransparency = 1
AntiFallDesc.Text = "Prevents damage from falling"
AntiFallDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
AntiFallDesc.TextScaled = true
AntiFallDesc.TextXAlignment = Enum.TextXAlignment.Left
AntiFallDesc.Font = Enum.Font.SourceSans
AntiFallDesc.Parent = AntiFallFrame

-- Anti Fall Toggle
local AntiFallToggle = Instance.new("TextButton")
AntiFallToggle.Name = "AntiFallToggle"
AntiFallToggle.Size = UDim2.new(0, 80, 0, 40)
AntiFallToggle.Position = UDim2.new(1, -90, 0.5, -20)
AntiFallToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AntiFallToggle.Text = "OFF"
AntiFallToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiFallToggle.TextScaled = true
AntiFallToggle.Font = Enum.Font.SourceSansBold
AntiFallToggle.BorderSizePixel = 0
AntiFallToggle.Parent = AntiFallFrame

local AntiFallCorner = Instance.new("UICorner")
AntiFallCorner.CornerRadius = UDim.new(0, 8)
AntiFallCorner.Parent = AntiFallToggle

-- Anti Water Damage Section
local AntiWaterFrame = Instance.new("Frame")
AntiWaterFrame.Name = "AntiWaterFrame"
AntiWaterFrame.Size = UDim2.new(1, 0, 0, 100)
AntiWaterFrame.Position = UDim2.new(0, 0, 0, 150)
AntiWaterFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
AntiWaterFrame.BorderSizePixel = 0
AntiWaterFrame.Parent = ProtectionContent

local AntiWaterFrameCorner = Instance.new("UICorner")
AntiWaterFrameCorner.CornerRadius = UDim.new(0, 8)
AntiWaterFrameCorner.Parent = AntiWaterFrame

-- Anti Water Icon
local AntiWaterIcon = Instance.new("TextLabel")
AntiWaterIcon.Name = "AntiWaterIcon"
AntiWaterIcon.Size = UDim2.new(0, 60, 0, 60)
AntiWaterIcon.Position = UDim2.new(0, 10, 0.5, -30)
AntiWaterIcon.BackgroundTransparency = 1
AntiWaterIcon.Text = "💧"
AntiWaterIcon.TextScaled = true
AntiWaterIcon.Font = Enum.Font.SourceSansBold
AntiWaterIcon.Parent = AntiWaterFrame

-- Anti Water Text
local AntiWaterText = Instance.new("TextLabel")
AntiWaterText.Name = "AntiWaterText"
AntiWaterText.Size = UDim2.new(1, -170, 0, 25)
AntiWaterText.Position = UDim2.new(0, 80, 0, 15)
AntiWaterText.BackgroundTransparency = 1
AntiWaterText.Text = "Anti Water Damage"
AntiWaterText.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiWaterText.TextScaled = true
AntiWaterText.TextXAlignment = Enum.TextXAlignment.Left
AntiWaterText.Font = Enum.Font.SourceSansBold
AntiWaterText.Parent = AntiWaterFrame

-- Anti Water Description
local AntiWaterDesc = Instance.new("TextLabel")
AntiWaterDesc.Name = "AntiWaterDesc"
AntiWaterDesc.Size = UDim2.new(1, -170, 0, 20)
AntiWaterDesc.Position = UDim2.new(0, 80, 0, 45)
AntiWaterDesc.BackgroundTransparency = 1
AntiWaterDesc.Text = "Prevents drowning damage"
AntiWaterDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
AntiWaterDesc.TextScaled = true
AntiWaterDesc.TextXAlignment = Enum.TextXAlignment.Left
AntiWaterDesc.Font = Enum.Font.SourceSans
AntiWaterDesc.Parent = AntiWaterFrame

-- Anti Water Toggle
local AntiWaterToggle = Instance.new("TextButton")
AntiWaterToggle.Name = "AntiWaterToggle"
AntiWaterToggle.Size = UDim2.new(0, 80, 0, 40)
AntiWaterToggle.Position = UDim2.new(1, -90, 0.5, -20)
AntiWaterToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AntiWaterToggle.Text = "OFF"
AntiWaterToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiWaterToggle.TextScaled = true
AntiWaterToggle.Font = Enum.Font.SourceSansBold
AntiWaterToggle.BorderSizePixel = 0
AntiWaterToggle.Parent = AntiWaterFrame

local AntiWaterCorner = Instance.new("UICorner")
AntiWaterCorner.CornerRadius = UDim.new(0, 8)
AntiWaterCorner.Parent = AntiWaterToggle

-- Bottom buttons container
local BottomButtons = Instance.new("Frame")
BottomButtons.Name = "BottomButtons"
BottomButtons.Size = UDim2.new(1, -40, 0, 40)
BottomButtons.Position = UDim2.new(0, 20, 1, -50)
BottomButtons.BackgroundTransparency = 1
BottomButtons.Parent = MainFrame

-- Hide UI Button
local HideUIButton = Instance.new("TextButton")
HideUIButton.Name = "HideUIButton"
HideUIButton.Size = UDim2.new(0.48, -2.5, 1, 0)
HideUIButton.Position = UDim2.new(0, 0, 0, 0)
HideUIButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
HideUIButton.Text = "Hide UI"
HideUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HideUIButton.TextScaled = true
HideUIButton.Font = Enum.Font.SourceSansBold
HideUIButton.BorderSizePixel = 0
HideUIButton.Parent = BottomButtons

local HideUICorner = Instance.new("UICorner")
HideUICorner.CornerRadius = UDim.new(0, 8)
HideUICorner.Parent = HideUIButton

-- Toggle Jump Button
local ToggleJumpButton = Instance.new("TextButton")
ToggleJumpButton.Name = "ToggleJumpButton"
ToggleJumpButton.Size = UDim2.new(0.48, -2.5, 1, 0)
ToggleJumpButton.Position = UDim2.new(0.52, 2.5, 0, 0)
ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
ToggleJumpButton.Text = "Hide Jump Btn"
ToggleJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleJumpButton.TextScaled = true
ToggleJumpButton.Font = Enum.Font.SourceSansBold
ToggleJumpButton.BorderSizePixel = 0
ToggleJumpButton.Parent = BottomButtons

local ToggleJumpCorner = Instance.new("UICorner")
ToggleJumpCorner.CornerRadius = UDim.new(0, 8)
ToggleJumpCorner.Parent = ToggleJumpButton

-- Floating Show Button
local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 100, 0, 40)
ShowButton.Position = UDim2.new(0, 10, 0.5, -20)
ShowButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ShowButton.Text = "Show UI"
ShowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowButton.TextScaled = true
ShowButton.Font = Enum.Font.SourceSansBold
ShowButton.BorderSizePixel = 0
ShowButton.Visible = false
ShowButton.Active = true
ShowButton.Draggable = true
ShowButton.Parent = ScreenGui

local ShowCorner = Instance.new("UICorner")
ShowCorner.CornerRadius = UDim.new(0, 10)
ShowCorner.Parent = ShowButton

-- Floating Jump Button
local JumpButton = Instance.new("TextButton")
JumpButton.Name = "JumpButton"
JumpButton.Size = IsMobile and UDim2.new(0, 100, 0, 100) or UDim2.new(0, 90, 0, 90)
JumpButton.Position = IsMobile and UDim2.new(1, -130, 1, -130) or UDim2.new(1, -120, 1, -120)
JumpButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
JumpButton.Text = "JUMP"
JumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpButton.TextScaled = true
JumpButton.Font = Enum.Font.SourceSansBold
JumpButton.BorderSizePixel = 0
JumpButton.Active = true
JumpButton.Draggable = true
JumpButton.Parent = ScreenGui

local JumpButtonCorner = Instance.new("UICorner")
JumpButtonCorner.CornerRadius = UDim.new(0.5, 0)
JumpButtonCorner.Parent = JumpButton

-- Functions
local function SwitchTab(tabName)
    CurrentTab = tabName
    if tabName == "Speed" then
        SpeedContent.Visible = true
        ProtectionContent.Visible = false
        SpeedTabButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        ProtectionTabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    else
        SpeedContent.Visible = false
        ProtectionContent.Visible = true
        SpeedTabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        ProtectionTabButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
end

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
        if Humanoid.UseJumpPower then
            Humanoid.JumpPower = CurrentJumpPower
        else
            Humanoid.JumpHeight = CurrentJumpPower / 2.5
        end
    end
end

-- Improved Anti-Damage Functions
local function ToggleAntiFallDamage()
    AntiFallDamage = not AntiFallDamage
    
    if AntiFallDamage then
        AntiFallToggle.Text = "ON"
        AntiFallToggle.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Disconnect existing connections
        if DamageConnections.FallDamage then
            DamageConnections.FallDamage:Disconnect()
        end
        if DamageConnections.StateChanged then
            DamageConnections.StateChanged:Disconnect()
        end
        
        -- Store initial health
        LastHealth = Humanoid.Health
        
        -- Monitor state changes for fall detection
        DamageConnections.StateChanged = Humanoid.StateChanged:Connect(function(old, new)
            -- When entering freefall, record height
            if new == Enum.HumanoidStateType.Freefall and Character:FindFirstChild("HumanoidRootPart") then
                FallStartHeight = Character.HumanoidRootPart.Position.Y
            end
            
            -- When landing, prevent damage
            if old == Enum.HumanoidStateType.Freefall and new == Enum.HumanoidStateType.Landed then
                -- Force health to stay at previous value
                if Humanoid.Health < LastHealth then
                    Humanoid.Health = LastHealth
                end
            end
        end)
        
        -- Continuous health monitoring
        DamageConnections.FallDamage = RunService.Heartbeat:Connect(function()
            if Humanoid and Humanoid.Health > 0 then
                -- If health decreased and we're in a fall-related state
                if Humanoid.Health < LastHealth then
                    local state = Humanoid:GetState()
                    if state == Enum.HumanoidStateType.Freefall or 
                       state == Enum.HumanoidStateType.Landed or
                       state == Enum.HumanoidStateType.Flying then
                        Humanoid.Health = LastHealth
                    else
                        -- Update last health if damage wasn't from falling
                        LastHealth = Humanoid.Health
                    end
                else
                    LastHealth = Humanoid.Health
                end
            end
        end)
    else
        AntiFallToggle.Text = "OFF"
        AntiFallToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        -- Disconnect all fall damage connections
        if DamageConnections.FallDamage then
            DamageConnections.FallDamage:Disconnect()
            DamageConnections.FallDamage = nil
        end
        if DamageConnections.StateChanged then
            DamageConnections.StateChanged:Disconnect()
            DamageConnections.StateChanged = nil
        end
    end
end

local function ToggleAntiWaterDamage()
    AntiWaterDamage = not AntiWaterDamage
    
    if AntiWaterDamage then
        AntiWaterToggle.Text = "ON"
        AntiWaterToggle.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
        
        -- Disconnect existing connections
        if DamageConnections.WaterDamage then
            DamageConnections.WaterDamage:Disconnect()
        end
        
        -- Store initial health
        LastHealth = Humanoid.Health
        
        -- Monitor for water damage
        DamageConnections.WaterDamage = RunService.Heartbeat:Connect(function()
            if Humanoid and Humanoid.Health > 0 then
                local state = Humanoid:GetState()
                
                -- Check if in water-related states
                if state == Enum.HumanoidStateType.Swimming then
                    -- If health decreased while swimming, restore it
                    if Humanoid.Health < LastHealth then
                        Humanoid.Health = LastHealth
                    end
                elseif Humanoid.Health > LastHealth then
                    -- Update last health if it increased
                    LastHealth = Humanoid.Health
                elseif Humanoid.Health < LastHealth and state ~= Enum.HumanoidStateType.Swimming then
                    -- Update last health if damage wasn't from water
                    LastHealth = Humanoid.Health
                end
            end
        end)
    else
        AntiWaterToggle.Text = "OFF"
        AntiWaterToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        -- Disconnect water damage protection
        if DamageConnections.WaterDamage then
            DamageConnections.WaterDamage:Disconnect()
            DamageConnections.WaterDamage = nil
        end
    end
end

local function ToggleJumpButtonVisibility()
    JumpButtonVisible = not JumpButtonVisible
    JumpButton.Visible = JumpButtonVisible
    
    if JumpButtonVisible then
        ToggleJumpButton.Text = "Hide Jump Btn"
        ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    else
        ToggleJumpButton.Text = "Show Jump Btn"
        ToggleJumpButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end

local function DoJump()
    if Humanoid and Humanoid.Parent then
        ApplyJumpPower()
        Humanoid.Jump = true
        
        -- Visual feedback
        local originalSize = JumpButton.Size
        TweenService:Create(JumpButton, TweenInfo.new(0.1), {
            Size = originalSize * 0.9
        }):Play()
        
        task.wait(0.1)
        TweenService:Create(JumpButton, TweenInfo.new(0.1), {
            Size = originalSize
        }):Play()
    end
end

local function HideUI()
    UIVisible = false
    MainFrame.Visible = false
    ShowButton.Visible = true
end

local function ShowUI()
    UIVisible = true
    MainFrame.Visible = true
    ShowButton.Visible = false
end

-- Slider functionality
local dragging = false
local jumpDragging = false

-- Speed slider events
SliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        local mouse = input.Position
        local relativeX = mouse.X - SliderBG.AbsolutePosition.X
        local percentage = math.clamp(relativeX / SliderBG.AbsoluteSize.X, 0, 1)
        local speed = percentage * 200
        UpdateWalkspeed(speed)
        ApplyWalkspeed()
    end
end)

SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

-- Jump slider events
JumpSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        jumpDragging = true
        local mouse = input.Position
        local relativeX = mouse.X - JumpSliderBG.AbsolutePosition.X
        local percentage = math.clamp(relativeX / JumpSliderBG.AbsoluteSize.X, 0, 1)
        local jumpPower = percentage * 500
        UpdateJumpPower(jumpPower)
        ApplyJumpPower()
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
            ApplyWalkspeed()
        end
        
        if jumpDragging then
            local mouse = input.Position
            local relativeX = mouse.X - JumpSliderBG.AbsolutePosition.X
            local percentage = math.clamp(relativeX / JumpSliderBG.AbsoluteSize.X, 0, 1)
            local jumpPower = percentage * 500
            UpdateJumpPower(jumpPower)
            ApplyJumpPower()
        end
    end
end)

-- Button connections
SpeedTabButton.MouseButton1Click:Connect(function() SwitchTab("Speed") end)
ProtectionTabButton.MouseButton1Click:Connect(function() SwitchTab("Protection") end)
CloseButton.MouseButton1Click:Connect(function() ToggleUI() end)
HideUIButton.MouseButton1Click:Connect(HideUI)
ShowButton.MouseButton1Click:Connect(ShowUI)
ToggleJumpButton.MouseButton1Click:Connect(ToggleJumpButtonVisibility)
JumpButton.MouseButton1Click:Connect(DoJump)

-- Speed controls
IncreaseButton.MouseButton1Click:Connect(function()
    UpdateWalkspeed(CurrentWalkspeed + 1)
    ApplyWalkspeed()
end)

DecreaseButton.MouseButton1Click:Connect(function()
    UpdateWalkspeed(CurrentWalkspeed - 1)
    ApplyWalkspeed()
end)

IncreaseJumpButton.MouseButton1Click:Connect(function()
    UpdateJumpPower(CurrentJumpPower + 5)
    ApplyJumpPower()
end)

DecreaseJumpButton.MouseButton1Click:Connect(function()
    UpdateJumpPower(CurrentJumpPower - 5)
    ApplyJumpPower()
end)

-- Protection toggles
AntiFallToggle.MouseButton1Click:Connect(ToggleAntiFallDamage)
AntiWaterToggle.MouseButton1Click:Connect(ToggleAntiWaterDamage)

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    
    -- Reapply settings
    ApplyWalkspeed()
    ApplyJumpPower()
    
    -- Reapply anti-damage if enabled
    if AntiFallDamage then
        AntiFallDamage = false
        ToggleAntiFallDamage()
    end
    
    if AntiWaterDamage then
        AntiWaterDamage = false
        ToggleAntiWaterDamage()
    end
end)

-- Toggle UI with RightShift (PC only)
if not IsMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            if UIVisible then
                HideUI()
            else
                ShowUI()
            end
        end
    end)
end

-- Initial setup
UpdateWalkspeed(DefaultWalkspeed)
UpdateJumpPower(DefaultJumpPower)
ApplyWalkspeed()
ApplyJumpPower()

-- Notification
game.StarterGui:SetCore("SendNotification", {
    Title = "Enhanced Game Controller",
    Text = "Loaded successfully! Use tabs to switch between Speed/Jump and Protection features.",
    Duration = 5
})