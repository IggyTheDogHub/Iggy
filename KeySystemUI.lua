--[[
    ========================================================================
    IGGY HUB — KEY SYSTEM UI (v32 Authentic Modal)
    Standalone, sleek, monochrome authentication window.
    ========================================================================
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local gethui = gethui or function() return CoreGui end
local getasset = getcustomasset or getsynasset or function(path) return path end
local setclipboard = setclipboard or toclipboard or function(txt) end

local KeySystemUI = {}

local function resolveAsset(name)
    if not name or name == "" then return "" end
    if name:find("rbxassetid://") or name:find("http") then return name end
    local paths = {
        "IggyUI/assets/" .. name,
        "assets/" .. name,
        "ZenithUI/assets/" .. name
    }
    for _, p in ipairs(paths) do
        local ok, res = pcall(getasset, p)
        if ok and res and res ~= "" then return res end
    end
    return name
end

local function tween(obj, props, duration, easing)
    local info = TweenInfo.new(duration or 0.22, easing or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function KeySystemUI:Create(config)
    config = config or {}
    local Title = config.Title or "IggyHub"
    local Subtitle = config.Subtitle or "KEY SYSTEM"
    local DiscordLink = config.DiscordLink or "https://discord.gg/6UBrrVchnh"
    local OnGetKey = config.OnGetKey or function() end
    local OnSubmit = config.OnSubmit or function(key) end
    local OnClose = config.OnClose or function() end

    -- Destroy any previous instance
    local prev = gethui():FindFirstChild("IggyKeySystem")
    if prev then prev:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IggyKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = gethui()

    -- Center Modal Frame
    local Modal = Instance.new("Frame")
    Modal.Name = "KeyModal"
    Modal.Size = UDim2.new(0, 440, 0, 316)
    Modal.Position = UDim2.new(0.5, 0, 0.5, 0)
    Modal.AnchorPoint = Vector2.new(0.5, 0.5)
    Modal.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
    Modal.BackgroundTransparency = 0.15
    Modal.BorderSizePixel = 0
    Modal.ClipsDescendants = true
    Modal.Parent = ScreenGui

    local ModalCorner = Instance.new("UICorner")
    ModalCorner.CornerRadius = UDim.new(0, 14)
    ModalCorner.Parent = Modal

    local ModalStroke = Instance.new("UIStroke")
    ModalStroke.Thickness = 1
    ModalStroke.Color = Color3.fromRGB(240, 240, 240)
    ModalStroke.Transparency = 0.88
    ModalStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ModalStroke.Parent = Modal

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Modal.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mPos = input.Position
            local mainPos = Modal.AbsolutePosition
            if mPos.Y > mainPos.Y + 48 then return end
            dragging = true
            dragStart = input.Position
            startPos = Modal.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Modal.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 3 then
                Modal.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    -- Header: Glowing Iggy Logo
    local LogoGlow = Instance.new("ImageLabel")
    LogoGlow.Name = "LogoGlow"
    LogoGlow.Size = UDim2.new(0, 56, 0, 56)
    LogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoGlow.Position = UDim2.new(0, 32, 0, 28)
    LogoGlow.BackgroundTransparency = 1
    LogoGlow.Image = resolveAsset("LogoGlow.png")
    LogoGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    LogoGlow.ImageTransparency = 0.55
    LogoGlow.ZIndex = 0
    LogoGlow.Parent = Modal

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "IggyLogo"
    Logo.Size = UDim2.new(0, 36, 0, 36)
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.Position = UDim2.new(0, 32, 0, 28)
    Logo.BackgroundTransparency = 1
    Logo.Image = resolveAsset("Iggy_Option1.png")
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Logo.ZIndex = 2
    Logo.Parent = Modal

    -- Title & Subtitle Badge
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 100, 0, 20)
    TitleLabel.Position = UDim2.new(0, 58, 0, 18)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Modal

    local Badge = Instance.new("Frame")
    Badge.Name = "Badge"
    Badge.Size = UDim2.new(0, 78, 0, 16)
    Badge.Position = UDim2.new(0, 126, 0, 20)
    Badge.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    Badge.BorderSizePixel = 0
    Badge.Parent = Modal

    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 4)
    BadgeCorner.Parent = Badge

    local BadgeStroke = Instance.new("UIStroke")
    BadgeStroke.Thickness = 1
    BadgeStroke.Color = Color3.fromRGB(240, 240, 240)
    BadgeStroke.Transparency = 0.88
    BadgeStroke.Parent = Badge

    local BadgeText = Instance.new("TextLabel")
    BadgeText.Size = UDim2.new(1, 0, 1, 0)
    BadgeText.BackgroundTransparency = 1
    BadgeText.Text = Subtitle
    BadgeText.TextColor3 = Color3.fromRGB(180, 180, 190)
    BadgeText.TextSize = 9
    BadgeText.Font = Enum.Font.GothamBold
    BadgeText.Parent = Badge

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -12, 0, 14)
    CloseBtn.AnchorPoint = Vector2.new(1, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    CloseBtn.BackgroundTransparency = 0.6
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Modal

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseBtn

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Thickness = 1
    CloseStroke.Color = Color3.fromRGB(240, 240, 240)
    CloseStroke.Transparency = 0.88
    CloseStroke.Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function()
        tween(CloseBtn, { TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.2 })
    end)
    CloseBtn.MouseLeave:Connect(function()
        tween(CloseBtn, { TextColor3 = Color3.fromRGB(160, 160, 170), BackgroundTransparency = 0.6 })
    end)
    CloseBtn.Activated:Connect(function()
        OnClose()
        ScreenGui:Destroy()
    end)

    -- Divider Line
    local Div = Instance.new("Frame")
    Div.Name = "Divider"
    Div.Size = UDim2.new(1, -26, 0, 1)
    Div.Position = UDim2.new(0, 13, 0, 52)
    Div.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Div.BackgroundTransparency = 0.90
    Div.BorderSizePixel = 0
    Div.Parent = Modal

    -- Description / Info Text
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Name = "InfoLabel"
    InfoLabel.Size = UDim2.new(1, -26, 0, 20)
    InfoLabel.Position = UDim2.new(0, 13, 0, 64)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "Enter your 24-hour access key to continue."
    InfoLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.GothamMedium
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.Parent = Modal

    -- Key Input Container (Pill Style)
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Size = UDim2.new(1, -26, 0, 42)
    InputFrame.Position = UDim2.new(0, 13, 0, 94)
    InputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    InputFrame.BackgroundTransparency = 0.2
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Modal

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputFrame

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Thickness = 1
    InputStroke.Color = Color3.fromRGB(240, 240, 240)
    InputStroke.Transparency = 0.88
    InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    InputStroke.Parent = InputFrame

    -- Key Input TextBox
    local KeyTextBox = Instance.new("TextBox")
    KeyTextBox.Name = "KeyTextBox"
    KeyTextBox.Size = UDim2.new(1, -78, 1, 0)
    KeyTextBox.Position = UDim2.new(0, 14, 0, 0)
    KeyTextBox.BackgroundTransparency = 1
    KeyTextBox.Text = ""
    KeyTextBox.PlaceholderText = "Paste access key here..."
    KeyTextBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 120)
    KeyTextBox.TextColor3 = Color3.fromRGB(245, 245, 250)
    KeyTextBox.TextSize = 13
    KeyTextBox.Font = Enum.Font.GothamMedium
    KeyTextBox.TextXAlignment = Enum.TextXAlignment.Left
    KeyTextBox.ClearTextOnFocus = false
    KeyTextBox.Parent = InputFrame

    -- Paste Clipboard Button inside Input
    local PasteBtn = Instance.new("TextButton")
    PasteBtn.Name = "PasteBtn"
    PasteBtn.Size = UDim2.new(0, 56, 0, 26)
    PasteBtn.Position = UDim2.new(1, -8, 0.5, 0)
    PasteBtn.AnchorPoint = Vector2.new(1, 0.5)
    PasteBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    PasteBtn.BackgroundTransparency = 0.2
    PasteBtn.Text = "PASTE"
    PasteBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    PasteBtn.TextSize = 10
    PasteBtn.Font = Enum.Font.GothamBold
    PasteBtn.AutoButtonColor = false
    PasteBtn.Parent = InputFrame

    local PasteCorner = Instance.new("UICorner")
    PasteCorner.CornerRadius = UDim.new(0, 6)
    PasteCorner.Parent = PasteBtn

    local PasteStroke = Instance.new("UIStroke")
    PasteStroke.Thickness = 1
    PasteStroke.Color = Color3.fromRGB(240, 240, 240)
    PasteStroke.Transparency = 0.88
    PasteStroke.Parent = PasteBtn

    PasteBtn.MouseEnter:Connect(function()
        tween(PasteBtn, { BackgroundColor3 = Color3.fromRGB(36, 36, 44), TextColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    PasteBtn.MouseLeave:Connect(function()
        tween(PasteBtn, { BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(200, 200, 210) })
    end)
    PasteBtn.Activated:Connect(function()
        local clip = nil
        local ok, res = pcall(function() return getclipboard and getclipboard() end)
        if ok and res and res ~= "" then clip = res end
        if clip then
            KeyTextBox.Text = clip
        end
    end)

    -- Status Feedback Message
    local StatusMsg = Instance.new("TextLabel")
    StatusMsg.Name = "StatusMsg"
    StatusMsg.Size = UDim2.new(1, -26, 0, 16)
    StatusMsg.Position = UDim2.new(0, 13, 0, 142)
    StatusMsg.BackgroundTransparency = 1
    StatusMsg.Text = ""
    StatusMsg.TextColor3 = Color3.fromRGB(200, 200, 210)
    StatusMsg.TextSize = 11
    StatusMsg.Font = Enum.Font.GothamMedium
    StatusMsg.TextXAlignment = Enum.TextXAlignment.Left
    StatusMsg.Parent = Modal

    -- Action Buttons Row
    local ActionsRow = Instance.new("Frame")
    ActionsRow.Name = "ActionsRow"
    ActionsRow.Size = UDim2.new(1, -26, 0, 38)
    ActionsRow.Position = UDim2.new(0, 13, 0, 164)
    ActionsRow.BackgroundTransparency = 1
    ActionsRow.Parent = Modal

    local ActionsLayout = Instance.new("UIListLayout")
    ActionsLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ActionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ActionsLayout.Padding = UDim.new(0, 8)
    ActionsLayout.Parent = ActionsRow

    -- 1. "Get Key" Button
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.LayoutOrder = 1
    GetKeyBtn.Size = UDim2.new(0, 140, 1, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    GetKeyBtn.BackgroundTransparency = 0.2
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    GetKeyBtn.TextSize = 12
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.Parent = ActionsRow

    local GkCorner = Instance.new("UICorner")
    GkCorner.CornerRadius = UDim.new(0, 10)
    GkCorner.Parent = GetKeyBtn

    local GkStroke = Instance.new("UIStroke")
    GkStroke.Thickness = 1
    GkStroke.Color = Color3.fromRGB(240, 240, 240)
    GkStroke.Transparency = 0.88
    GkStroke.Parent = GetKeyBtn

    GetKeyBtn.MouseEnter:Connect(function()
        tween(GetKeyBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 38), TextColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        tween(GetKeyBtn, { BackgroundColor3 = Color3.fromRGB(22, 22, 26), TextColor3 = Color3.fromRGB(220, 220, 230) })
    end)
    GetKeyBtn.Activated:Connect(function()
        OnGetKey(StatusMsg)
    end)

    -- 2. "Submit Key" Button (High Contrast White / Accent)
    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Name = "VerifyBtn"
    VerifyBtn.LayoutOrder = 2
    VerifyBtn.Size = UDim2.new(1, -148, 1, 0)
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    VerifyBtn.BackgroundTransparency = 0
    VerifyBtn.Text = "Submit Key"
    VerifyBtn.TextColor3 = Color3.fromRGB(12, 12, 14)
    VerifyBtn.TextSize = 13
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.AutoButtonColor = false
    VerifyBtn.Parent = ActionsRow

    local VfCorner = Instance.new("UICorner")
    VfCorner.CornerRadius = UDim.new(0, 10)
    VfCorner.Parent = VerifyBtn

    local VfStroke = Instance.new("UIStroke")
    VfStroke.Thickness = 1
    VfStroke.Color = Color3.fromRGB(255, 255, 255)
    VfStroke.Transparency = 0.6
    VfStroke.Parent = VerifyBtn

    VerifyBtn.MouseEnter:Connect(function()
        tween(VerifyBtn, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    VerifyBtn.MouseLeave:Connect(function()
        tween(VerifyBtn, { BackgroundColor3 = Color3.fromRGB(245, 245, 250) })
    end)

    local isVerifying = false
    VerifyBtn.Activated:Connect(function()
        if isVerifying then return end
        local key = KeyTextBox.Text:gsub("%s+", "")
        if key == "" then
            StatusMsg.TextColor3 = Color3.fromRGB(255, 100, 100)
            StatusMsg.Text = "Please enter or paste your key first!"
            return
        end

        isVerifying = true
        VerifyBtn.Text = "Verifying..."
        StatusMsg.TextColor3 = Color3.fromRGB(245, 245, 250)
        StatusMsg.Text = "Validating access key..."

        task.spawn(function()
            local success, message = OnSubmit(key)
            isVerifying = false
            VerifyBtn.Text = "Submit Key"
            if success then
                StatusMsg.TextColor3 = Color3.fromRGB(100, 240, 140)
                StatusMsg.Text = "Key valid! Loading IggyHub..."
                task.wait(0.6)
                ScreenGui:Destroy()
            else
                StatusMsg.TextColor3 = Color3.fromRGB(255, 100, 100)
                StatusMsg.Text = message or "Invalid or expired key. Please try again."
            end
        end)
    end)

    -- ========================================================================
    -- GET PREMIUM CARD (Bottom Row)
    -- ========================================================================
    local PremiumCard = Instance.new("Frame")
    PremiumCard.Name = "PremiumCard"
    PremiumCard.Size = UDim2.new(1, -26, 0, 48)
    PremiumCard.Position = UDim2.new(0, 13, 0, 210)
    PremiumCard.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    PremiumCard.BackgroundTransparency = 0.2
    PremiumCard.BorderSizePixel = 0
    PremiumCard.Parent = Modal

    local PremCorner = Instance.new("UICorner")
    PremCorner.CornerRadius = UDim.new(0, 10)
    PremCorner.Parent = PremiumCard

    local PremStroke = Instance.new("UIStroke")
    PremStroke.Thickness = 1
    PremStroke.Color = Color3.fromRGB(240, 240, 240)
    PremStroke.Transparency = 0.88
    PremStroke.Parent = PremiumCard

    -- Star / Crown Icon Badge
    local PremBadge = Instance.new("TextLabel")
    PremBadge.Name = "PremBadge"
    PremBadge.Size = UDim2.new(0, 24, 0, 24)
    PremBadge.Position = UDim2.new(0, 12, 0.5, 0)
    PremBadge.AnchorPoint = Vector2.new(0, 0.5)
    PremBadge.BackgroundTransparency = 1
    PremBadge.Text = "⭐"
    PremBadge.TextSize = 16
    PremBadge.Font = Enum.Font.GothamBold
    PremBadge.Parent = PremiumCard

    -- Left Title & Subtitle Stack
    local PremTitle = Instance.new("TextLabel")
    PremTitle.Name = "PremTitle"
    PremTitle.Size = UDim2.new(0, 180, 0, 18)
    PremTitle.Position = UDim2.new(0, 42, 0, 7)
    PremTitle.BackgroundTransparency = 1
    PremTitle.Text = "Get Premium"
    PremTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
    PremTitle.TextSize = 13
    PremTitle.Font = Enum.Font.GothamBold
    PremTitle.TextXAlignment = Enum.TextXAlignment.Left
    PremTitle.Parent = PremiumCard

    local PremSub = Instance.new("TextLabel")
    PremSub.Name = "PremSub"
    PremSub.Size = UDim2.new(0, 220, 0, 14)
    PremSub.Position = UDim2.new(0, 42, 0, 26)
    PremSub.BackgroundTransparency = 1
    PremSub.Text = "Bypass keys & instant access"
    PremSub.TextColor3 = Color3.fromRGB(140, 140, 150)
    PremSub.TextSize = 11
    PremSub.Font = Enum.Font.GothamMedium
    PremSub.TextXAlignment = Enum.TextXAlignment.Left
    PremSub.Parent = PremiumCard

    -- Right Side "Buy" Button (Exact style as Submit Key)
    local BuyBtn = Instance.new("TextButton")
    BuyBtn.Name = "BuyBtn"
    BuyBtn.Size = UDim2.new(0, 72, 0, 30)
    BuyBtn.Position = UDim2.new(1, -10, 0.5, 0)
    BuyBtn.AnchorPoint = Vector2.new(1, 0.5)
    BuyBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    BuyBtn.BackgroundTransparency = 0
    BuyBtn.Text = "Buy"
    BuyBtn.TextColor3 = Color3.fromRGB(12, 12, 14)
    BuyBtn.TextSize = 12
    BuyBtn.Font = Enum.Font.GothamBold
    BuyBtn.AutoButtonColor = false
    BuyBtn.Parent = PremiumCard

    local BuyCorner = Instance.new("UICorner")
    BuyCorner.CornerRadius = UDim.new(0, 8)
    BuyCorner.Parent = BuyBtn

    local BuyStroke = Instance.new("UIStroke")
    BuyStroke.Thickness = 1
    BuyStroke.Color = Color3.fromRGB(255, 255, 255)
    BuyStroke.Transparency = 0.6
    BuyStroke.Parent = BuyBtn

    BuyBtn.MouseEnter:Connect(function()
        tween(BuyBtn, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    BuyBtn.MouseLeave:Connect(function()
        tween(BuyBtn, { BackgroundColor3 = Color3.fromRGB(245, 245, 250) })
    end)

    BuyBtn.Activated:Connect(function()
        setclipboard(DiscordLink)
        StatusMsg.TextColor3 = Color3.fromRGB(100, 240, 140)
        StatusMsg.Text = "Discord invite copied! Join server to get Premium."
        
        -- Subtle click feedback pulse
        tween(BuyBtn, { BackgroundColor3 = Color3.fromRGB(100, 240, 140) }, 0.1)
        task.delay(0.2, function()
            tween(BuyBtn, { BackgroundColor3 = Color3.fromRGB(245, 245, 250) }, 0.2)
        end)
    end)

    -- Footer Subtext
    local Footer = Instance.new("TextLabel")
    Footer.Name = "Footer"
    Footer.Size = UDim2.new(1, -26, 0, 16)
    Footer.Position = UDim2.new(0, 13, 1, -22)
    Footer.BackgroundTransparency = 1
    Footer.Text = "Keys are hardware-bound and expire after 24 hours."
    Footer.TextColor3 = Color3.fromRGB(110, 110, 120)
    Footer.TextSize = 10
    Footer.Font = Enum.Font.Gotham
    Footer.TextXAlignment = Enum.TextXAlignment.Center
    Footer.Parent = Modal

    return {
        ScreenGui = ScreenGui,
        Modal = Modal,
        KeyTextBox = KeyTextBox,
        StatusMsg = StatusMsg,
        Destroy = function()
            ScreenGui:Destroy()
        end
    }
end

return KeySystemUI
