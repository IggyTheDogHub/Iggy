--[[
    ========================================================================
    IGGY UI LIBRARY (IggyLib) — v1.0 COMPLETE REUSABLE SUITE
    Authentic v32 Aesthetic & Layout Engine. Zero external dependencies.
    Includes full component suite:
      - Window (Draggable header, Acrylic blur, Floating Dog minimize button)
      - Sidebar Category Tabs & User Avatar
      - SubTabs Capsule with animated glowing underline indicator
      - GroupBox Cards & Dividers
      - Pill Toggles (3-layer authentic v32 track, liquid, fill & knob)
      - Dropdowns & Multi-Select Dropdowns (live search filter, auto-close)
      - 2-Tier Sliders (drag track + manual number input pill)
      - Buttons (with click feedback pulse)
      - Text Inputs (rounded pill with placeholder)
      - Keybind Badges (interactive key listener)
      - Status Banners (colored season/event cards with icon & subtitle)
      - Server / Event Cards (server region, player count, tag pills, join button)
      - Top Search Bars (integrated list filtering)
      - On-Screen Notifications (Library:Notify)
    ========================================================================
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gethui = gethui or function() return CoreGui end
local getasset = getcustomasset or getsynasset or function(path) return path end
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

-- Asset Resolver
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
        if ok and res and res ~= "" then
            return res
        end
    end
    return name
end

local IggyLib = {}
IggyLib.__index = IggyLib

local function tween(obj, props, duration, style, dir)
    duration = duration or 0.18
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
    t:Play()
    return t
end

-- ========================================================================
-- GLOBAL NOTIFICATION SYSTEM
-- ========================================================================
local notificationHolder = nil

local function getNotificationHolder()
    if notificationHolder and notificationHolder.Parent then
        return notificationHolder
    end
    local root = gethui():FindFirstChild("IggyUI_NotifyRoot")
    if not root then
        root = Instance.new("ScreenGui")
        root.Name = "IggyUI_NotifyRoot"
        root.DisplayOrder = 2147483647
        root.ResetOnSpawn = false
        root.Parent = gethui()
    end
    notificationHolder = Instance.new("Frame")
    notificationHolder.Name = "NotificationHolder"
    notificationHolder.Size = UDim2.new(0, 300, 1, -20)
    notificationHolder.Position = UDim2.new(1, -310, 0, 10)
    notificationHolder.BackgroundTransparency = 1
    notificationHolder.Parent = root

    local nLayout = Instance.new("UIListLayout")
    nLayout.FillDirection = Enum.FillDirection.Vertical
    nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    nLayout.Padding = UDim.new(0, 8)
    nLayout.Parent = notificationHolder

    return notificationHolder
end

function IggyLib:Notify(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Iggy Hub"
    local desc = cfg.Description or cfg.Text or ""
    local duration = cfg.Time or cfg.Duration or 3.5

    local holder = getNotificationHolder()

    local card = Instance.new("Frame")
    card.Name = "Notification"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(240, 240, 245)
    stroke.Transparency = 0.8
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, 0, 0, 16)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLabel.TextSize = 12
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card

    if desc ~= "" then
        local dLabel = Instance.new("TextLabel")
        dLabel.Size = UDim2.new(1, 0, 0, 0)
        dLabel.Position = UDim2.new(0, 0, 0, 18)
        dLabel.AutomaticSize = Enum.AutomaticSize.Y
        dLabel.BackgroundTransparency = 1
        dLabel.Text = desc
        dLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
        dLabel.TextSize = 11
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextWrapped = true
        dLabel.Parent = card
    end

    card.Position = UDim2.new(1, 40, 0, 0)
    tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.25)

    task.delay(duration, function()
        if card and card.Parent then
            local t = tween(card, { Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1 }, 0.25)
            t.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

-- ========================================================================
-- CONFIGURATION & PERSISTENCE ENGINE
-- ========================================================================
local HttpService = game:GetService("HttpService")
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local listfiles = listfiles or function() return {} end
local delfile = delfile or deletefile or function() end

local CONFIG_DIR = "IggyHub/configs"
local SETTINGS_FILE = "IggyHub/settings.json"

local function ensureDirs()
    pcall(function()
        if not isfolder("IggyHub") then makefolder("IggyHub") end
        if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
    end)
end

local function loadAppSettings()
    ensureDirs()
    local ok, res = pcall(function()
        if isfile(SETTINGS_FILE) then
            return HttpService:JSONDecode(readfile(SETTINGS_FILE))
        end
    end)
    if ok and type(res) == "table" then
        return res
    end
    return { autoload = false, autosave = false, active = "Default" }
end

local function saveAppSettings(tbl)
    ensureDirs()
    pcall(function()
        writefile(SETTINGS_FILE, HttpService:JSONEncode(tbl))
    end)
end

local function getAvailableConfigs()
    ensureDirs()
    local configs = {"Default"}
    local seen = {["Default"] = true}
    local ok, files = pcall(listfiles, CONFIG_DIR)
    if ok and type(files) == "table" then
        for _, filePath in ipairs(files) do
            local name = filePath:match("([^/\\]+)%.json$")
            if name and not seen[name] then
                seen[name] = true
                table.insert(configs, name)
            end
        end
    end
    return configs
end

-- ========================================================================
-- CREATE WINDOW
-- ========================================================================
function IggyLib:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "IggyHub"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local windowSize = config.Size or UDim2.new(0, 720, 0, 460)

    if getgenv and getgenv()._IGGY_HUB_RUNNING then
        pcall(function()
            if getgenv()._IGGY_WINDOW and getgenv()._IGGY_WINDOW.Destroy then
                getgenv()._IGGY_WINDOW:Destroy()
            end
        end)
    end
    if getgenv then
        getgenv()._IGGY_HUB_RUNNING = true
    end

    pcall(function()
        local old = gethui():FindFirstChild("IggyUI_Root")
        if old then old:Destroy() end
    end)

    local appSettings = loadAppSettings()

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        ToggleKey = toggleKey,
        IsMinimized = false,
        StreamerMode = false,
        DiscordLink = config.Discord or "https://discord.gg/6UBrrVchnh",
        Flags = {},
        ConfigElements = {},
        ActiveConfig = appSettings.active or "Default",
        AutoloadEnabled = appSettings.autoload or false,
        AutosaveEnabled = appSettings.autosave or false
    }

    if getgenv then
        getgenv()._IGGY_WINDOW = Window
    end

    function Window:Destroy()
        if getgenv then
            getgenv()._IGGY_HUB_RUNNING = nil
            getgenv()._IGGY_LOADER_RUNNING = nil
            getgenv()._IGGY_WINDOW = nil
        end
        pcall(function()
            if ScreenGui then ScreenGui:Destroy() end
        end)
        pcall(function()
            local ft = gethui():FindFirstChild("FloatingDogButton", true)
            if ft then ft:Destroy() end
        end)
    end

    local autosaveDebounceThread = nil
    Window.SaveActiveConfigDirect = function()
        if not Window.AutosaveEnabled then return end
        if autosaveDebounceThread then
            task.cancel(autosaveDebounceThread)
        end
        autosaveDebounceThread = task.delay(0.3, function()
            Window:SaveConfig(Window.ActiveConfig)
        end)
    end

    function Window:SaveConfig(name)
        name = name or Window.ActiveConfig or "Default"
        ensureDirs()
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(Window.Flags)
        end)
        if ok and encoded then
            local filePath = CONFIG_DIR .. "/" .. name .. ".json"
            local writeOk = pcall(writefile, filePath, encoded)
            if writeOk then
                return true
            end
        end
        return false
    end

    function Window:LoadConfig(name)
        name = name or Window.ActiveConfig or "Default"
        ensureDirs()
        local filePath = CONFIG_DIR .. "/" .. name .. ".json"
        if not isfile(filePath) then
            return false, "File does not exist"
        end
        local ok, content = pcall(readfile, filePath)
        if not ok or not content or content == "" then
            return false, "Failed to read file"
        end
        local decOk, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if not decOk or type(data) ~= "table" then
            return false, "Failed to parse JSON"
        end

        for flagName, val in pairs(data) do
            local element = Window.ConfigElements[flagName]
            if element and type(element.Set) == "function" then
                pcall(element.Set, val)
            else
                Window.Flags[flagName] = val
            end
        end
        Window.ActiveConfig = name
        local curSettings = loadAppSettings()
        curSettings.active = name
        saveAppSettings(curSettings)
        return true
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IggyUI_Root"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = gethui()
    Window.ScreenGui = ScreenGui

    -- Main Window Frame (Exact v32: 720x460, 0.2 transparency, 14px corner)
    local MainUI = Instance.new("Frame")
    MainUI.Name = "MainUI"
    MainUI.Size = windowSize
    MainUI.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainUI.AnchorPoint = Vector2.new(0.5, 0.5)
    MainUI.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    MainUI.BackgroundTransparency = 0.20
    MainUI.BorderSizePixel = 0
    MainUI.ClipsDescendants = true
    MainUI.Parent = ScreenGui
    Window.MainUI = MainUI

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainUI

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1
    MainStroke.Color = Color3.fromRGB(240, 240, 240)
    MainStroke.Transparency = 0.90
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainUI

    -- Header Dragging
    local dragging = false
    local dragInput, dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        if delta.Magnitude > 3 then
            MainUI.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    MainUI.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mPos = input.Position
            local mainPos = MainUI.AbsolutePosition
            if mPos.Y > mainPos.Y + 48 then
                return
            end
            dragging = true
            dragStart = input.Position
            startPos = MainUI.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainUI.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- Top-Left Glowing Iggy Logo
    local LogoGlow = Instance.new("ImageLabel")
    LogoGlow.Name = "LogoGlow"
    LogoGlow.Size = UDim2.new(0, 78, 0, 78)
    LogoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoGlow.Position = UDim2.new(0, 36, 0, 33)
    LogoGlow.BackgroundTransparency = 1
    LogoGlow.Image = resolveAsset("LogoGlow.png")
    LogoGlow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    LogoGlow.ImageTransparency = 0.55
    LogoGlow.ZIndex = 0
    LogoGlow.Parent = MainUI

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "IggyLogo"
    Logo.Size = UDim2.new(0, 50, 0, 50)
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.Position = UDim2.new(0, 36, 0, 33)
    Logo.BackgroundTransparency = 1
    Logo.Image = resolveAsset("Iggy_Option1.png")
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Logo.ZIndex = 2
    Logo.Parent = MainUI

    -- Top-Right Hide / Minimize Button
    local HideUIBg = Instance.new("Frame")
    HideUIBg.Name = "HideUIBg"
    HideUIBg.Size = UDim2.new(0, 34, 0, 34)
    HideUIBg.Position = UDim2.new(1, -14, 0, 10)
    HideUIBg.AnchorPoint = Vector2.new(1, 0)
    HideUIBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    HideUIBg.BackgroundTransparency = 1
    HideUIBg.ZIndex = 99
    HideUIBg.Parent = MainUI

    local HideCorner = Instance.new("UICorner")
    HideCorner.CornerRadius = UDim.new(1, 0)
    HideCorner.Parent = HideUIBg

    local HideStroke = Instance.new("UIStroke")
    HideStroke.Name = "UIStroke"
    HideStroke.Thickness = 1
    HideStroke.Color = Color3.fromRGB(240, 240, 240)
    HideStroke.Transparency = 1
    HideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    HideStroke.Parent = HideUIBg

    local HideUIBtn = Instance.new("ImageButton")
    HideUIBtn.Name = "HideUI"
    HideUIBtn.Size = UDim2.new(0, 20, 0, 20)
    HideUIBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
    HideUIBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    HideUIBtn.BackgroundTransparency = 1
    HideUIBtn.Image = resolveAsset("HideUIIcon.png")
    HideUIBtn.ImageColor3 = Color3.fromRGB(245, 245, 250)
    HideUIBtn.ZIndex = 100
    HideUIBtn.Parent = HideUIBg

    local isScrolledGlobal = false

    HideUIBtn.MouseEnter:Connect(function()
        tween(HideUIBg, { BackgroundTransparency = 0.05 })
        tween(HideStroke, { Transparency = 0.65 })
        tween(HideUIBtn, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
    end)

    HideUIBtn.MouseLeave:Connect(function()
        tween(HideUIBg, { BackgroundTransparency = isScrolledGlobal and 0.25 or 1 })
        tween(HideStroke, { Transparency = isScrolledGlobal and 0.85 or 1 })
        tween(HideUIBtn, { ImageColor3 = Color3.fromRGB(245, 245, 250) })
    end)

    -- Floating Dog Button (60fps drag)
    local FloatingToggle = Instance.new("ImageButton")
    FloatingToggle.Name = "FloatingDogButton"
    FloatingToggle.Size = UDim2.new(0, 50, 0, 50)
    FloatingToggle.Position = UDim2.new(0, 24, 0, 140)
    FloatingToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    FloatingToggle.BackgroundTransparency = 0.15
    FloatingToggle.Visible = false
    FloatingToggle.ZIndex = 999
    FloatingToggle.AutoButtonColor = false
    FloatingToggle.Parent = ScreenGui

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(0, 12)
    FloatCorner.Parent = FloatingToggle

    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Thickness = 1.2
    FloatStroke.Color = Color3.fromRGB(240, 240, 245)
    FloatStroke.Transparency = 0.75
    FloatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    FloatStroke.Parent = FloatingToggle

    local FloatGlow = Instance.new("ImageLabel")
    FloatGlow.Name = "Glow"
    FloatGlow.Size = UDim2.new(0, 72, 0, 72)
    FloatGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    FloatGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatGlow.BackgroundTransparency = 1
    FloatGlow.Image = resolveAsset("LogoGlow.png")
    FloatGlow.ImageTransparency = 0.5
    FloatGlow.ZIndex = 998
    FloatGlow.Parent = FloatingToggle

    local FloatIcon = Instance.new("ImageLabel")
    FloatIcon.Name = "Icon"
    FloatIcon.Size = UDim2.new(0, 50, 0, 50)
    FloatIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    FloatIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatIcon.BackgroundTransparency = 1
    FloatIcon.Image = resolveAsset("Iggy_Option1.png")
    FloatIcon.ScaleType = Enum.ScaleType.Fit
    FloatIcon.ZIndex = 1000
    FloatIcon.Parent = FloatingToggle

    local isFloatDragging = false
    local floatDragConn = nil

    FloatingToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isFloatDragging = true
            local mousePos = UserInputService:GetMouseLocation()
            local startClickPos = input.Position
            local offset = mousePos - FloatingToggle.AbsolutePosition

            if floatDragConn then floatDragConn:Disconnect() end
            floatDragConn = RunService.RenderStepped:Connect(function()
                local curMouse = UserInputService:GetMouseLocation()
                FloatingToggle.Position = UDim2.new(0, curMouse.X - offset.X, 0, curMouse.Y - offset.Y)
            end)

            local endConn
            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    isFloatDragging = false
                    if floatDragConn then
                        floatDragConn:Disconnect()
                        floatDragConn = nil
                    end
                    endConn:Disconnect()
                    local dist = (endInput.Position - startClickPos).Magnitude
                    if dist < 6 then
                        FloatingToggle.Visible = false
                        MainUI.Visible = true
                        Window.IsMinimized = false
                    end
                end
            end)
        end
    end)

    local function toggleWindow()
        Window.IsMinimized = not Window.IsMinimized
        if Window.IsMinimized then
            MainUI.Visible = false
            FloatingToggle.Visible = true
        else
            FloatingToggle.Visible = false
            MainUI.Visible = true
        end
    end

    HideUIBtn.MouseButton1Click:Connect(toggleWindow)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Window.ToggleKey then
            toggleWindow()
        end
    end)

    -- Left Sidebar MainTabs
    local MainTabs = Instance.new("Frame")
    MainTabs.Name = "MainTabs"
    MainTabs.Size = UDim2.new(0, 40, 0, 0)
    MainTabs.Position = UDim2.new(0, 16, 0, 70)
    MainTabs.BackgroundTransparency = 1
    MainTabs.AutomaticSize = Enum.AutomaticSize.Y
    MainTabs.Parent = MainUI

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Vertical
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout.Padding = UDim.new(0, 8)
    TabsLayout.Parent = MainTabs

    -- Bottom Avatar Frame
    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Name = "AvatarFrame"
    AvatarFrame.Size = UDim2.new(0, 44, 0, 44)
    AvatarFrame.Position = UDim2.new(0, 14, 1, -58)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AvatarFrame.BackgroundTransparency = 0
    AvatarFrame.Parent = MainUI

    local AvatarFrameCorner = Instance.new("UICorner")
    AvatarFrameCorner.CornerRadius = UDim.new(1, 0)
    AvatarFrameCorner.Parent = AvatarFrame

    local AvatarFrameStroke = Instance.new("UIStroke")
    AvatarFrameStroke.Thickness = 1.2
    AvatarFrameStroke.Color = Color3.fromRGB(240, 240, 240)
    AvatarFrameStroke.Transparency = 1
    AvatarFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    AvatarFrameStroke.Parent = AvatarFrame

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Name = "Avatar"
    AvatarImg.Size = UDim2.new(0, 38, 0, 38)
    AvatarImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    AvatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
    AvatarImg.BackgroundTransparency = 1
    if LocalPlayer then
        AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=420&h=420"
    end
    AvatarImg.Parent = AvatarFrame

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImg

    local AvatarStroke = Instance.new("UIStroke")
    AvatarStroke.Thickness = 1.5
    AvatarStroke.Color = Color3.fromRGB(30, 30, 30)
    AvatarStroke.Parent = AvatarImg

    local SidebarPrivacyIcon = Instance.new("ImageLabel")
    SidebarPrivacyIcon.Name = "SidebarPrivacyIcon"
    SidebarPrivacyIcon.Size = UDim2.new(0, 22, 0, 22)
    SidebarPrivacyIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    SidebarPrivacyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    SidebarPrivacyIcon.BackgroundTransparency = 1
    SidebarPrivacyIcon.Image = "rbxassetid://7733774495"
    SidebarPrivacyIcon.ImageColor3 = Color3.fromRGB(245, 245, 250)
    SidebarPrivacyIcon.Visible = false
    SidebarPrivacyIcon.Parent = AvatarFrame

    local SidebarAvatarBtn = Instance.new("ImageButton")
    SidebarAvatarBtn.Name = "SidebarAvatarBtn"
    SidebarAvatarBtn.Size = UDim2.new(1, 0, 1, 0)
    SidebarAvatarBtn.BackgroundTransparency = 1
    SidebarAvatarBtn.ZIndex = 10
    SidebarAvatarBtn.Parent = AvatarFrame

    SidebarAvatarBtn.Activated:Connect(function()
        if Window.ToggleStreamerMode then
            Window.ToggleStreamerMode()
        end
    end)

    Window.SidebarAvatarFrame = AvatarFrame
    Window.SidebarAvatarStroke = AvatarFrameStroke
    Window.SidebarAvatarImg = AvatarImg
    Window.SidebarPrivacyIcon = SidebarPrivacyIcon

    -- Right Content Wrapper
    local ContentWrapper = Instance.new("Frame")
    ContentWrapper.Name = "ContentWrapper"
    ContentWrapper.Size = UDim2.new(1, -84, 1, -20)
    ContentWrapper.Position = UDim2.new(0, 72, 0, 10)
    ContentWrapper.BackgroundTransparency = 1
    ContentWrapper.Parent = MainUI

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.FillDirection = Enum.FillDirection.Vertical
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = ContentWrapper

    -- Horizontal Sub-Tabs Bar (RealTabs)
    local RealTabs = Instance.new("Frame")
    RealTabs.Name = "RealTabs"
    RealTabs.Size = UDim2.new(1, 0, 0, 38)
    RealTabs.BackgroundTransparency = 1
    RealTabs.ZIndex = 2
    RealTabs.Parent = ContentWrapper

    local TabsInner = Instance.new("Frame")
    TabsInner.Name = "Inner"
    TabsInner.Size = UDim2.new(0, 0, 1, 0)
    TabsInner.Position = UDim2.new(0.5, 0, 0, 0)
    TabsInner.AnchorPoint = Vector2.new(0.5, 0)
    TabsInner.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TabsInner.BackgroundTransparency = 1
    TabsInner.AutomaticSize = Enum.AutomaticSize.X
    TabsInner.Parent = RealTabs

    local TabsInnerCorner = Instance.new("UICorner")
    TabsInnerCorner.CornerRadius = UDim.new(0, 16)
    TabsInnerCorner.Parent = TabsInner

    local TabsInnerStroke = Instance.new("UIStroke")
    TabsInnerStroke.Thickness = 1
    TabsInnerStroke.Color = Color3.fromRGB(240, 240, 240)
    TabsInnerStroke.Transparency = 1
    TabsInnerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TabsInnerStroke.Parent = TabsInner

    local TabsInnerPad = Instance.new("UIPadding")
    TabsInnerPad.PaddingLeft = UDim.new(0, 14)
    TabsInnerPad.PaddingRight = UDim.new(0, 14)
    TabsInnerPad.PaddingTop = UDim.new(0, 2)
    TabsInnerPad.PaddingBottom = UDim.new(0, 2)
    TabsInnerPad.Parent = TabsInner

    local BtnContainer = Instance.new("Frame")
    BtnContainer.Name = "BtnContainer"
    BtnContainer.Size = UDim2.new(0, 0, 1, 0)
    BtnContainer.BackgroundTransparency = 1
    BtnContainer.AutomaticSize = Enum.AutomaticSize.X
    BtnContainer.Parent = TabsInner

    local RealTabsLayout = Instance.new("UIListLayout")
    RealTabsLayout.FillDirection = Enum.FillDirection.Horizontal
    RealTabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RealTabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RealTabsLayout.Padding = UDim.new(0, 18)
    RealTabsLayout.Parent = BtnContainer

    local SubIndicator = Instance.new("Frame")
    SubIndicator.Name = "SubIndicator"
    SubIndicator.Size = UDim2.new(0, 52, 0, 1.5)
    SubIndicator.Position = UDim2.new(0, 0, 1, -2)
    SubIndicator.AnchorPoint = Vector2.new(0, 1)
    SubIndicator.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    SubIndicator.BorderSizePixel = 0
    SubIndicator.Parent = TabsInner

    local SubIndicatorCorner = Instance.new("UICorner")
    SubIndicatorCorner.CornerRadius = UDim.new(1, 0)
    SubIndicatorCorner.Parent = SubIndicator

    -- Content Container (TabFrameMain)
    local TabFrameMain = Instance.new("Frame")
    TabFrameMain.Name = "TabFrameMain"
    TabFrameMain.Size = UDim2.new(1, 0, 1, -46)
    TabFrameMain.BackgroundTransparency = 1
    TabFrameMain.BorderSizePixel = 0
    TabFrameMain.ClipsDescendants = false
    TabFrameMain.Parent = ContentWrapper

    -- Scroll Listener for Subtabs Acrylic Capsule
    local currentScrollConn = nil
    local function attachScrollListener(sf)
        if currentScrollConn then
            currentScrollConn:Disconnect()
            currentScrollConn = nil
        end
        if not sf then return end
        local isScrolled = false
        local function checkScroll()
            local nowScrolled = sf.CanvasPosition.Y > 6
            if nowScrolled ~= isScrolled then
                isScrolled = nowScrolled
                isScrolledGlobal = nowScrolled
                local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                tween(TabsInner, { BackgroundTransparency = isScrolled and 0.15 or 1 })
                tween(TabsInnerStroke, { Transparency = isScrolled and 0.85 or 1 })
                tween(HideUIBg, { BackgroundTransparency = isScrolled and 0.25 or 1 })
                tween(HideStroke, { Transparency = isScrolled and 0.85 or 1 })
            end
        end
        currentScrollConn = sf:GetPropertyChangedSignal("CanvasPosition"):Connect(checkScroll)
        checkScroll()
    end

    local currentOpenDropdownCloser = nil

    -- ====================================================================
    -- TAB BUILDER (Sidebar Category)
    -- ====================================================================
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        if tabName == "Settings" and Window.SettingsTab then
            return Window.SettingsTab
        end
        local tabIcon = tabConfig.Icon or "Main.png"
        local tabOrder = #Window.Tabs + 1

        local Tab = {
            Name = tabName,
            Icon = tabIcon,
            SubTabs = {},
            ActiveSubTab = nil,
            Order = tabOrder
        }

        local btn = Instance.new("TextButton")
        btn.Name = tabName .. "Button"
        btn.Size = UDim2.new(0, 40, 0, 39)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        btn.BackgroundTransparency = (tabOrder == 1) and 0 or 1
        btn.LayoutOrder = tabOrder
        btn.Text = ""
        btn.Parent = MainTabs

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 9)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(200, 200, 200)
        stroke.Transparency = (tabOrder == 1) and 0 or 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = btn

        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
        overlay.BackgroundTransparency = (tabOrder == 1) and 0.8 or 1
        overlay.BorderSizePixel = 0
        overlay.Parent = btn

        local overlayCorner = Instance.new("UICorner")
        overlayCorner.CornerRadius = UDim.new(0, 9)
        overlayCorner.Parent = overlay

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 25, 0, 25)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = resolveAsset(tabIcon)
        icon.ImageColor3 = Color3.fromRGB(245, 245, 250)
        icon.ImageTransparency = (tabOrder == 1) and 0 or 0.4
        icon.Parent = btn

        Tab.SidebarElements = { btn = btn, stroke = stroke, overlay = overlay, icon = icon }

        local function activateTab()
            for _, t in ipairs(Window.Tabs) do
                local isActive = (t == Tab)
                tween(t.SidebarElements.btn, { BackgroundTransparency = isActive and 0 or 1 })
                tween(t.SidebarElements.stroke, { Transparency = isActive and 0 or 1 })
                tween(t.SidebarElements.overlay, { BackgroundTransparency = isActive and 0.8 or 1 })
                tween(t.SidebarElements.icon, { ImageTransparency = isActive and 0 or 0.4 })
            end
            Window.ActiveTab = Tab
            Tab:RenderSubTabs(Tab.ActiveSubTab or Tab.SubTabs[1])
        end

        Tab.Activate = activateTab
        btn.MouseButton1Click:Connect(activateTab)
        btn.Activated:Connect(activateTab)

        -- ----------------------------------------------------------------
        -- RENDER SUBTABS
        -- ----------------------------------------------------------------
        function Tab:RenderSubTabs(targetSubTab)
            for _, ch in ipairs(BtnContainer:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end

            targetSubTab = targetSubTab or Tab.ActiveSubTab or Tab.SubTabs[1]
            Tab.ActiveSubTab = targetSubTab

            local firstTabFrame = nil
            local subTabButtons = {}

            for idx, sub in ipairs(Tab.SubTabs) do
                local isSelected = (sub == targetSubTab)
                local tabFrame = Instance.new("Frame")
                tabFrame.Name = sub.Name .. "TopTab"
                tabFrame.Size = UDim2.new(0, 0, 0, 28)
                tabFrame.AutomaticSize = Enum.AutomaticSize.X
                tabFrame.BackgroundTransparency = 1
                tabFrame.LayoutOrder = idx
                tabFrame.Parent = BtnContainer

                if isSelected then
                    firstTabFrame = tabFrame
                end

                local tabLabel = Instance.new("TextLabel")
                tabLabel.Name = "Label"
                tabLabel.Size = UDim2.new(0, 0, 1, 0)
                tabLabel.AutomaticSize = Enum.AutomaticSize.X
                tabLabel.BackgroundTransparency = 1
                tabLabel.Text = sub.Name
                tabLabel.TextColor3 = isSelected and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(160, 160, 160)
                tabLabel.TextSize = 14
                tabLabel.Font = Enum.Font.GothamMedium
                tabLabel.Parent = tabFrame

                local hitBtn = Instance.new("TextButton")
                hitBtn.Size = UDim2.new(1, 0, 1, 0)
                hitBtn.BackgroundTransparency = 1
                hitBtn.Text = ""
                hitBtn.ZIndex = 5
                hitBtn.Parent = tabFrame

                subTabButtons[sub] = { frame = tabFrame, label = tabLabel }

                local function onSelectSubTab()
                    if currentOpenDropdownCloser then
                        currentOpenDropdownCloser()
                    end
                    for s, data in pairs(subTabButtons) do
                        local active = (s == sub)
                        tween(data.label, { TextColor3 = active and Color3.fromRGB(245, 245, 250) or Color3.fromRGB(160, 160, 160) })
                    end
                    local padOffset = TabsInnerPad and TabsInnerPad.PaddingLeft.Offset or 0
                    local targetX = tabFrame.AbsolutePosition.X - TabsInner.AbsolutePosition.X - padOffset
                    local targetWidth = tabFrame.AbsoluteSize.X
                    tween(SubIndicator, {
                        Position = UDim2.new(0, targetX, 1, -2),
                        Size = UDim2.new(0, targetWidth, 0, 1.5)
                    }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                    Tab:ShowSubTab(sub)
                end

                hitBtn.MouseButton1Click:Connect(onSelectSubTab)
                hitBtn.Activated:Connect(onSelectSubTab)
            end

            task.defer(function()
                if firstTabFrame then
                    local padOffset = TabsInnerPad and TabsInnerPad.PaddingLeft.Offset or 0
                    local targetX = firstTabFrame.AbsolutePosition.X - TabsInner.AbsolutePosition.X - padOffset
                    local targetWidth = firstTabFrame.AbsoluteSize.X
                    SubIndicator.Position = UDim2.new(0, targetX, 1, -2)
                    SubIndicator.Size = UDim2.new(0, targetWidth, 0, 1.5)
                end
            end)

            if targetSubTab then
                Tab:ShowSubTab(targetSubTab)
            end
        end

        function Tab:ShowSubTab(targetSub)
            Tab.ActiveSubTab = targetSub
            for _, t in ipairs(Window.Tabs) do
                for _, s in ipairs(t.SubTabs) do
                    if s.ScrollFrame then
                        s.ScrollFrame.Visible = (t == Tab and s == targetSub)
                    end
                end
            end
            if targetSub and targetSub.ScrollFrame then
                attachScrollListener(targetSub.ScrollFrame)
            end
        end

        function Tab:SwitchSubTab(subOrName)
            local targetSub = nil
            if type(subOrName) == "string" then
                for _, s in ipairs(Tab.SubTabs) do
                    if s.Name == subOrName then
                        targetSub = s
                        break
                    end
                end
            elseif type(subOrName) == "table" then
                targetSub = subOrName
            end
            if targetSub then
                Tab:RenderSubTabs(targetSub)
            end
        end

        -- ----------------------------------------------------------------
        -- CREATE SUBTAB
        -- ----------------------------------------------------------------
        function Tab:CreateSubTab(subName)
            local SubTab = {
                Name = subName,
                Cards = {},
                Elements = {}
            }

            local scroll = Instance.new("ScrollingFrame")
            scroll.Name = tabName .. "_" .. subName .. "Content"
            scroll.Size = UDim2.new(1, 0, 1, 0)
            scroll.Position = UDim2.new(0, 0, 0, 0)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ClipsDescendants = false
            scroll.Visible = false
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = Color3.fromRGB(245, 245, 250)
            scroll.ScrollBarImageTransparency = 0
            scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.Parent = TabFrameMain

            local sLayout = Instance.new("UIListLayout")
            sLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sLayout.Padding = UDim.new(0, 6)
            sLayout.Parent = scroll

            local sPad = Instance.new("UIPadding")
            sPad.PaddingTop = UDim.new(0, 4)
            sPad.PaddingBottom = UDim.new(0, 16)
            sPad.PaddingLeft = UDim.new(0, 2)
            sPad.PaddingRight = UDim.new(0, 8)
            sPad.Parent = scroll

            SubTab.ScrollFrame = scroll

            -- ------------------------------------------------------------
            -- ADD SEARCH BAR (Direct on SubTab, like Image 2)
            -- ------------------------------------------------------------
            function SubTab:AddSearchBar(opt)
                opt = opt or {}
                local placeholder = opt.Placeholder or "Search..."
                local callback = opt.Callback or function() end

                local sFrame = Instance.new("Frame")
                sFrame.Name = "SearchFrame"
                sFrame.Size = UDim2.new(1, 0, 0, 28)
                sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                sFrame.BackgroundTransparency = 0.1
                sFrame.BorderSizePixel = 0
                sFrame.LayoutOrder = 0
                sFrame.Parent = scroll

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(0, 6)
                sCorner.Parent = sFrame

                local sStroke = Instance.new("UIStroke")
                sStroke.Thickness = 1
                sStroke.Color = Color3.fromRGB(240, 240, 240)
                sStroke.Transparency = 0.90
                sStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                sStroke.Parent = sFrame

                local sIcon = Instance.new("ImageLabel")
                sIcon.Name = "SIcon"
                sIcon.Size = UDim2.new(0, 14, 0, 14)
                sIcon.Position = UDim2.new(0, 8, 0.5, -7)
                sIcon.BackgroundTransparency = 1
                sIcon.Image = resolveAsset("SearchIcon.png")
                sIcon.ImageColor3 = Color3.fromRGB(120, 120, 125)
                sIcon.Parent = sFrame

                local sBox = Instance.new("TextBox")
                sBox.Name = "SearchBox"
                sBox.Size = UDim2.new(1, -40, 1, 0)
                sBox.Position = UDim2.new(0, 28, 0, 0)
                sBox.BackgroundTransparency = 1
                sBox.Text = ""
                sBox.TextColor3 = Color3.fromRGB(225, 225, 225)
                sBox.TextSize = 11
                sBox.Font = Enum.Font.Gotham
                sBox.TextXAlignment = Enum.TextXAlignment.Left
                sBox.PlaceholderText = placeholder
                sBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 108)
                sBox.ClearTextOnFocus = false
                sBox.Parent = sFrame

                sBox:GetPropertyChangedSignal("Text"):Connect(function()
                    pcall(callback, sBox.Text)
                end)

                return {
                    GetText = function() return sBox.Text end,
                    SetText = function(t) sBox.Text = t end
                }
            end

            -- ------------------------------------------------------------
            -- ADD BANNER / STATUS CARD (Direct on SubTab, like Image 1)
            -- ------------------------------------------------------------
            function SubTab:AddBanner(opt)
                opt = opt or {}
                local title = opt.Title or "Status"
                local subtitle = opt.Subtitle or ""
                local iconText = opt.IconText or opt.Icon or "🍂"
                local color = opt.Color or Color3.fromRGB(210, 115, 55)
                local bgColor = opt.BackgroundColor or Color3.fromRGB(
                    math.floor(color.R * 255 * 0.22),
                    math.floor(color.G * 255 * 0.22),
                    math.floor(color.B * 255 * 0.22)
                )

                local card = Instance.new("Frame")
                card.Name = "Banner_" .. title
                card.Size = UDim2.new(1, 0, 0, 55)
                card.BackgroundColor3 = bgColor
                card.BackgroundTransparency = 0
                card.BorderSizePixel = 0
                card.LayoutOrder = #SubTab.Elements + 1
                card.Parent = scroll

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = card

                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 2
                stroke.Color = color
                stroke.Transparency = 0
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = card

                local iconLbl = Instance.new("TextLabel")
                iconLbl.Name = "IconLabel"
                iconLbl.Size = UDim2.new(0, 28, 0, 28)
                iconLbl.Position = UDim2.new(0, 12, 0.5, -14)
                iconLbl.BackgroundTransparency = 1
                iconLbl.Text = iconText
                iconLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                iconLbl.TextSize = 22
                iconLbl.Font = Enum.Font.GothamBold
                iconLbl.TextXAlignment = Enum.TextXAlignment.Center
                iconLbl.TextYAlignment = Enum.TextYAlignment.Center
                iconLbl.Parent = card

                local tLbl = Instance.new("TextLabel")
                tLbl.Name = "TitleLabel"
                tLbl.Size = UDim2.new(1, -60, 0, 16)
                tLbl.Position = UDim2.new(0, 50, 0, 10)
                tLbl.BackgroundTransparency = 1
                tLbl.Text = title
                tLbl.TextColor3 = Color3.fromRGB(210, 210, 215)
                tLbl.TextSize = 13
                tLbl.Font = Enum.Font.GothamBold
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.TextYAlignment = Enum.TextYAlignment.Center
                tLbl.RichText = true
                tLbl.Parent = card

                local sLbl = Instance.new("TextLabel")
                sLbl.Name = "SubtitleLabel"
                sLbl.Size = UDim2.new(1, -60, 0, 14)
                sLbl.Position = UDim2.new(0, 50, 0, 30)
                sLbl.BackgroundTransparency = 1
                sLbl.Text = subtitle
                sLbl.TextColor3 = Color3.fromRGB(160, 160, 165)
                sLbl.TextSize = 11
                sLbl.Font = Enum.Font.Gotham
                sLbl.TextXAlignment = Enum.TextXAlignment.Left
                sLbl.TextYAlignment = Enum.TextYAlignment.Center
                sLbl.RichText = true
                sLbl.Parent = card

                table.insert(SubTab.Elements, card)

                return {
                    SetTitle = function(newT) tLbl.Text = newT end,
                    SetSubtitle = function(newS) sLbl.Text = newS end,
                    SetColor = function(newC)
                        stroke.Color = newC
                        card.BackgroundColor3 = Color3.fromRGB(
                            math.floor(newC.R * 255 * 0.22),
                            math.floor(newC.G * 255 * 0.22),
                            math.floor(newC.B * 255 * 0.22)
                        )
                    end,
                    Instance = card
                }
            end

            -- ------------------------------------------------------------
            -- ADD SERVER / EVENT CARD (Direct on SubTab, like Image 2)
            -- ------------------------------------------------------------
            function SubTab:AddServerCard(opt)
                opt = opt or {}
                local title = opt.Title or "Server"
                local players = opt.Players or "0/20"
                local uptime = opt.Uptime or ""
                local tags = opt.Tags or {}
                local details = opt.Details or ""
                local onJoin = opt.OnJoin or opt.Callback or function() end

                local card = Instance.new("Frame")
                card.Name = "ServerCard_" .. title
                card.Size = UDim2.new(1, 0, 0, 100)
                card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                card.BackgroundTransparency = 0.10
                card.BorderSizePixel = 0
                card.ClipsDescendants = true
                card.LayoutOrder = #SubTab.Elements + 1
                card.Parent = scroll

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = card

                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 1
                stroke.Color = Color3.fromRGB(240, 240, 240)
                stroke.Transparency = 0.90
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = card

                local header = Instance.new("Frame")
                header.Name = "Header"
                header.Size = UDim2.new(1, -90, 0, 22)
                header.Position = UDim2.new(0, 12, 0, 8)
                header.BackgroundTransparency = 1
                header.Parent = card

                local sLbl = Instance.new("TextLabel")
                sLbl.Name = "ServerLabel"
                sLbl.Size = UDim2.new(1, 0, 1, 0)
                sLbl.BackgroundTransparency = 1
                sLbl.RichText = true
                sLbl.Text = string.format("<b><font color='rgb(232,232,236)'>%s</font></b>   <b>%s</b>   %s", title, players, uptime)
                sLbl.TextColor3 = Color3.fromRGB(155, 155, 162)
                sLbl.TextSize = 11
                sLbl.Font = Enum.Font.Gotham
                sLbl.TextXAlignment = Enum.TextXAlignment.Left
                sLbl.TextYAlignment = Enum.TextYAlignment.Center
                sLbl.Parent = header

                local divider = Instance.new("Frame")
                divider.Name = "Divider"
                divider.Size = UDim2.new(1, -118, 0, 1)
                divider.Position = UDim2.new(0, 12, 0, 34)
                divider.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
                divider.BorderSizePixel = 0
                divider.Parent = card

                -- Badges container
                local bFrame = Instance.new("Frame")
                bFrame.Name = "EventBadges"
                bFrame.Size = UDim2.new(1, -118, 0, 24)
                bFrame.Position = UDim2.new(0, 12, 0, 41)
                bFrame.BackgroundTransparency = 1
                bFrame.ClipsDescendants = true
                bFrame.Parent = card

                local bLayout = Instance.new("UIListLayout")
                bLayout.FillDirection = Enum.FillDirection.Horizontal
                bLayout.Padding = UDim.new(0, 5)
                bLayout.SortOrder = Enum.SortOrder.LayoutOrder
                bLayout.Parent = bFrame

                for bIdx, tagText in ipairs(tags) do
                    local bPill = Instance.new("TextLabel")
                    bPill.Name = "Badge_" .. bIdx
                    bPill.Size = UDim2.new(0, 0, 0, 20)
                    bPill.AutomaticSize = Enum.AutomaticSize.X
                    bPill.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
                    bPill.BackgroundTransparency = 0.86
                    bPill.BorderSizePixel = 0
                    bPill.Text = "  " .. tagText .. "  "
                    bPill.TextColor3 = Color3.fromRGB(245, 245, 250)
                    bPill.TextSize = 9
                    bPill.Font = Enum.Font.GothamBold
                    bPill.TextXAlignment = Enum.TextXAlignment.Center
                    bPill.TextYAlignment = Enum.TextYAlignment.Center
                    bPill.Parent = bFrame

                    local bCorner = Instance.new("UICorner")
                    bCorner.CornerRadius = UDim.new(0, 6)
                    bCorner.Parent = bPill
                end

                local dLbl = Instance.new("TextLabel")
                dLbl.Name = "Details"
                dLbl.Size = UDim2.new(1, -24, 0, 0)
                dLbl.Position = UDim2.new(0, 12, 0, 68)
                dLbl.BackgroundTransparency = 1
                dLbl.Text = details
                dLbl.TextColor3 = Color3.fromRGB(160, 160, 165)
                dLbl.TextSize = 10
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextXAlignment = Enum.TextXAlignment.Left
                dLbl.TextYAlignment = Enum.TextYAlignment.Top
                dLbl.Parent = card

                local joinBtn = Instance.new("TextButton")
                joinBtn.Name = "JoinButton"
                joinBtn.Size = UDim2.new(0, 70, 0, 24)
                joinBtn.Position = UDim2.new(1, -12, 0, 7)
                joinBtn.AnchorPoint = Vector2.new(1, 0)
                joinBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
                joinBtn.BorderSizePixel = 0
                joinBtn.Text = "JOIN"
                joinBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
                joinBtn.TextSize = 10
                joinBtn.Font = Enum.Font.GothamBold
                joinBtn.Parent = card

                local jCorner = Instance.new("UICorner")
                jCorner.CornerRadius = UDim.new(0, 6)
                jCorner.Parent = joinBtn

                joinBtn.MouseButton1Click:Connect(function()
                    pcall(onJoin)
                end)

                table.insert(SubTab.Elements, card)

                return {
                    SetDetails = function(newDet) dLbl.Text = newDet end,
                    Instance = card
                }
            end

            -- ------------------------------------------------------------
            -- CREATE CARD (Exact v32 GroupBox & Separator)
            -- ------------------------------------------------------------
            function SubTab:CreateCard(cardTitle)
                local Card = {
                    ItemCount = 0,
                    LayoutIndex = 1
                }

                -- 1. Separator Header
                local sep = Instance.new("Frame")
                sep.Name = "Seperator"
                sep.Size = UDim2.new(1, 0, 0, 16)
                sep.BackgroundTransparency = 1
                sep.LayoutOrder = #SubTab.Cards * 2 + 1
                sep.Parent = scroll

                local sepLbl = Instance.new("TextLabel")
                sepLbl.Name = "SepLabel"
                sepLbl.Size = UDim2.new(1, -4, 0, 16)
                sepLbl.Position = UDim2.new(0, 4, 0, 0)
                sepLbl.BackgroundTransparency = 1
                sepLbl.Text = string.upper(cardTitle or "")
                sepLbl.TextColor3 = Color3.fromRGB(160, 160, 165)
                sepLbl.TextSize = 11
                sepLbl.Font = Enum.Font.GothamMedium
                sepLbl.TextXAlignment = Enum.TextXAlignment.Left
                sepLbl.TextYAlignment = Enum.TextYAlignment.Center
                sepLbl.Parent = sep

                -- 2. GroupBox Container
                local gb = Instance.new("Frame")
                gb.Name = "GroupBox"
                gb.Size = UDim2.new(1, 0, 0, 0)
                gb.AutomaticSize = Enum.AutomaticSize.Y
                gb.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                gb.BackgroundTransparency = 0.10000000149011612
                gb.BorderSizePixel = 0
                gb.ClipsDescendants = false
                gb.LayoutOrder = #SubTab.Cards * 2 + 2
                gb.Parent = scroll

                local gbCorner = Instance.new("UICorner")
                gbCorner.CornerRadius = UDim.new(0, 12)
                gbCorner.Parent = gb

                local gbStroke = Instance.new("UIStroke")
                gbStroke.Thickness = 1
                gbStroke.Color = Color3.fromRGB(240, 240, 240)
                gbStroke.Transparency = 0.90
                gbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                gbStroke.Parent = gb

                local gbLayout = Instance.new("UIListLayout")
                gbLayout.SortOrder = Enum.SortOrder.LayoutOrder
                gbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                gbLayout.Padding = UDim.new(0, 4)
                gbLayout.Parent = gb

                local gbPad = Instance.new("UIPadding")
                gbPad.PaddingTop = UDim.new(0, 5)
                gbPad.PaddingBottom = UDim.new(0, 4)
                gbPad.PaddingLeft = UDim.new(0, 0)
                gbPad.PaddingRight = UDim.new(0, 0)
                gbPad.Parent = gb

                Card.Container = gb

                local function addDivider()
                    if Card.ItemCount > 0 then
                        local div = Instance.new("Frame")
                        div.Name = "Divider"
                        div.Size = UDim2.new(1, -26, 0, 1)
                        div.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                        div.BackgroundTransparency = 0.94
                        div.BorderSizePixel = 0
                        div.LayoutOrder = Card.LayoutIndex
                        div.Parent = gb
                        Card.LayoutIndex = Card.LayoutIndex + 1
                    end
                end

                -- --------------------------------------------------------
                -- 1. ADD TOGGLE (Exact v32)
                -- --------------------------------------------------------
                function Card:AddToggle(opt)
                    opt = opt or {}
                    local name = opt.Name or "Toggle"
                    local default = opt.Default or false
                    local callback = opt.Callback or function() end

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local btn = Instance.new("TextButton")
                    btn.Name = "Toggle"
                    btn.Size = UDim2.new(1, 0, 0, 31)
                    btn.BackgroundTransparency = 1
                    btn.Text = ""
                    btn.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    btn.Parent = gb

                    local tc = Instance.new("Frame")
                    tc.Name = "TextContainer"
                    tc.Size = UDim2.new(1, -70, 1, 0)
                    tc.Position = UDim2.new(0, 13, 0, 0)
                    tc.BackgroundTransparency = 1
                    tc.Parent = btn

                    local lbl = Instance.new("TextLabel")
                    lbl.Name = "ToggleLabel"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.Position = UDim2.new(0, 0, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = name
                    lbl.TextColor3 = Color3.fromRGB(225, 225, 225)
                    lbl.TextSize = 11
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.TextYAlignment = Enum.TextYAlignment.Center
                    lbl.Parent = tc

                    local track = Instance.new("Frame")
                    track.Name = "PillTrack"
                    track.Size = UDim2.new(0, 40, 0, 22)
                    track.Position = UDim2.new(1, -50, 0.5, 0)
                    track.AnchorPoint = Vector2.new(0, 0.5)
                    track.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
                    track.BorderSizePixel = 0
                    track.Parent = btn

                    local trackCorner = Instance.new("UICorner")
                    trackCorner.CornerRadius = UDim.new(1, 0)
                    trackCorner.Parent = track

                    local trackStroke = Instance.new("UIStroke")
                    trackStroke.Thickness = 1
                    trackStroke.Color = Color3.fromRGB(245, 245, 250)
                    trackStroke.Transparency = default and 0 or 0.8
                    trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    trackStroke.Parent = track

                    local fill = Instance.new("Frame")
                    fill.Name = "PillFill"
                    fill.Size = UDim2.new(1, 0, 1, 0)
                    fill.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
                    fill.BackgroundTransparency = default and 0 or 1
                    fill.BorderSizePixel = 0
                    fill.Parent = track

                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(1, 0)
                    fillCorner.Parent = fill

                    local liquid = Instance.new("Frame")
                    liquid.Name = "PillLiquid"
                    liquid.Size = UDim2.new(0, 16, 0, 14)
                    liquid.Position = UDim2.new(0, default and 21 or 3, 0.5, 0)
                    liquid.AnchorPoint = Vector2.new(0, 0.5)
                    liquid.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
                    liquid.BackgroundTransparency = 0.24
                    liquid.BorderSizePixel = 0
                    liquid.Parent = track

                    local liquidCorner = Instance.new("UICorner")
                    liquidCorner.CornerRadius = UDim.new(1, 0)
                    liquidCorner.Parent = liquid

                    local knob = Instance.new("Frame")
                    knob.Name = "PillKnob"
                    knob.Size = UDim2.new(0, 16, 0, 14)
                    knob.Position = UDim2.new(0, default and 21 or 3, 0.5, 0)
                    knob.AnchorPoint = Vector2.new(0, 0.5)
                    knob.BackgroundColor3 = default and Color3.fromRGB(30, 30, 35) or Color3.fromRGB(240, 240, 255)
                    knob.BorderSizePixel = 0
                    knob.Parent = track

                    local knobCorner = Instance.new("UICorner")
                    knobCorner.CornerRadius = UDim.new(1, 0)
                    knobCorner.Parent = knob

                    local isToggled = default

                    local function setToggle(val)
                        isToggled = val
                        local targetX = isToggled and 21 or 3
                        local targetTrans = isToggled and 0 or 1
                        local targetKnobColor = isToggled and Color3.fromRGB(30, 30, 35) or Color3.fromRGB(240, 240, 255)
                        local targetStrokeTrans = isToggled and 0 or 0.8

                        tween(knob, { Position = UDim2.new(0, targetX, 0.5, 0), BackgroundColor3 = targetKnobColor })
                        tween(liquid, { Position = UDim2.new(0, targetX, 0.5, 0) })
                        tween(fill, { BackgroundTransparency = targetTrans })
                        tween(trackStroke, { Transparency = targetStrokeTrans })
                        pcall(callback, isToggled)

                        local flagName = opt.Flag or name
                        if flagName and not opt.NoConfig then
                            Window.Flags[flagName] = isToggled
                            if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                Window.SaveActiveConfigDirect()
                            end
                        end
                    end

                    btn.MouseButton1Click:Connect(function()
                        setToggle(not isToggled)
                    end)

                    local toggleObj = {
                        Set = setToggle,
                        GetValue = function() return isToggled end
                    }

                    local flagName = opt.Flag or name
                    if flagName and not opt.NoConfig then
                        Window.ConfigElements[flagName] = toggleObj
                        Window.Flags[flagName] = default
                    end

                    return toggleObj
                end

                -- --------------------------------------------------------
                -- 2. ADD DROPDOWN (Exact v32)
                -- --------------------------------------------------------
                function Card:AddDropdown(opt)
                    opt = opt or {}
                    local name = opt.Name or "Dropdown"
                    local options = opt.Options or {}
                    local default = opt.Default or (options[1] or "None")
                    local callback = opt.Callback or function() end

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local dropFrame = Instance.new("Frame")
                    dropFrame.Name = "Dropdown"
                    dropFrame.Size = UDim2.new(1, 0, 0, 31)
                    dropFrame.BackgroundTransparency = 1
                    dropFrame.ClipsDescendants = true
                    dropFrame.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    dropFrame.Parent = gb

                    local dropBtn = Instance.new("TextButton")
                    dropBtn.Name = "DropButton"
                    dropBtn.Size = UDim2.new(1, 0, 0, 31)
                    dropBtn.BackgroundTransparency = 1
                    dropBtn.Text = ""
                    dropBtn.Parent = dropFrame

                    local dropTitle = Instance.new("TextLabel")
                    dropTitle.Name = "Droptitle"
                    dropTitle.Size = UDim2.new(0, 410, 0, 30)
                    dropTitle.Position = UDim2.new(0, 13, 0, 0)
                    dropTitle.BackgroundTransparency = 1
                    dropTitle.Text = name .. " : " .. tostring(default)
                    dropTitle.TextColor3 = Color3.fromRGB(225, 225, 225)
                    dropTitle.TextSize = 11
                    dropTitle.Font = Enum.Font.Gotham
                    dropTitle.TextXAlignment = Enum.TextXAlignment.Left
                    dropTitle.TextYAlignment = Enum.TextYAlignment.Center
                    dropTitle.Parent = dropFrame

                    local dropImg = Instance.new("ImageLabel")
                    dropImg.Name = "DropImage"
                    dropImg.Size = UDim2.new(0, 20, 0, 20)
                    dropImg.Position = UDim2.new(1, -35, 0, 5)
                    dropImg.BackgroundTransparency = 1
                    dropImg.Image = resolveAsset("DropdownArrow.png")
                    dropImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    dropImg.Parent = dropFrame

                    -- Search Box
                    local searchBox = Instance.new("TextBox")
                    searchBox.Name = "SearchBox"
                    searchBox.Size = UDim2.new(1, -26, 0, 24)
                    searchBox.Position = UDim2.new(0, 13, 0, 34)
                    searchBox.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
                    searchBox.BackgroundTransparency = 0.3
                    searchBox.PlaceholderText = "Search..."
                    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
                    searchBox.Text = ""
                    searchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
                    searchBox.TextSize = 11
                    searchBox.Font = Enum.Font.Gotham
                    searchBox.Visible = false
                    searchBox.ClearTextOnFocus = false
                    searchBox.Parent = dropFrame

                    local searchCorner = Instance.new("UICorner")
                    searchCorner.CornerRadius = UDim.new(0, 6)
                    searchCorner.Parent = searchBox

                    -- Options Scrolling Frame
                    local dropScroll = Instance.new("ScrollingFrame")
                    dropScroll.Name = "DropScroll"
                    dropScroll.Size = UDim2.new(1, -26, 0, 114)
                    dropScroll.Position = UDim2.new(0, 13, 0, 62)
                    dropScroll.BackgroundTransparency = 1
                    dropScroll.BorderSizePixel = 0
                    dropScroll.ScrollBarThickness = 2
                    dropScroll.ScrollBarImageColor3 = Color3.fromRGB(245, 245, 250)
                    dropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    dropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    dropScroll.Parent = dropFrame

                    local dLayout = Instance.new("UIListLayout")
                    dLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    dLayout.Padding = UDim.new(0, 2)
                    dLayout.Parent = dropScroll

                    local isOpen = false
                    local selectedVal = default

                    local function closeDropdown()
                        if not isOpen then return end
                        isOpen = false
                        tween(dropFrame, { Size = UDim2.new(1, 0, 0, 31) })
                        tween(dropImg, { Rotation = 0 })
                        searchBox.Visible = false
                        if currentOpenDropdownCloser == closeDropdown then
                            currentOpenDropdownCloser = nil
                        end
                    end

                    local function openDropdown()
                        if isOpen then return end
                        if currentOpenDropdownCloser then
                            currentOpenDropdownCloser()
                        end
                        isOpen = true
                        currentOpenDropdownCloser = closeDropdown
                        tween(dropFrame, { Size = UDim2.new(1, 0, 0, 180) })
                        tween(dropImg, { Rotation = 180 })
                        searchBox.Visible = true
                    end

                    dropBtn.MouseButton1Click:Connect(function()
                        if isOpen then closeDropdown() else openDropdown() end
                    end)

                    local function populateOptions(opts)
                        for _, ch in ipairs(dropScroll:GetChildren()) do
                            if ch:IsA("TextButton") then ch:Destroy() end
                        end
                        for oIdx, optText in ipairs(opts) do
                            local optBtn = Instance.new("TextButton")
                            optBtn.Name = "Option_" .. oIdx
                            optBtn.Size = UDim2.new(1, 0, 0, 22)
                            optBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                            optBtn.BackgroundTransparency = 1
                            optBtn.Text = optText
                            optBtn.TextColor3 = (optText == selectedVal) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 185)
                            optBtn.TextSize = 11
                            optBtn.Font = Enum.Font.Gotham
                            optBtn.TextXAlignment = Enum.TextXAlignment.Left
                            optBtn.LayoutOrder = oIdx
                            optBtn.Parent = dropScroll

                            local oPad = Instance.new("UIPadding")
                            oPad.PaddingLeft = UDim.new(0, 8)
                            oPad.Parent = optBtn

                            optBtn.MouseEnter:Connect(function()
                                tween(optBtn, { BackgroundTransparency = 0.5, TextColor3 = Color3.fromRGB(255, 255, 255) })
                            end)
                            optBtn.MouseLeave:Connect(function()
                                tween(optBtn, { BackgroundTransparency = 1, TextColor3 = (optText == selectedVal) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 185) })
                            end)

                            optBtn.MouseButton1Click:Connect(function()
                                selectedVal = optText
                                dropTitle.Text = name .. " : " .. optText
                                closeDropdown()
                                pcall(callback, optText)

                                local flagName = opt.Flag or name
                                if flagName and not opt.NoConfig then
                                    Window.Flags[flagName] = optText
                                    if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                        Window.SaveActiveConfigDirect()
                                    end
                                end
                            end)
                        end
                    end

                    populateOptions(options)

                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local q = string.lower(searchBox.Text)
                        for _, btnOpt in ipairs(dropScroll:GetChildren()) do
                            if btnOpt:IsA("TextButton") then
                                if q == "" or string.find(string.lower(btnOpt.Text), q, 1, true) then
                                    btnOpt.Visible = true
                                else
                                    btnOpt.Visible = false
                                end
                            end
                        end
                    end)

                    local dropObj = {
                        Set = function(val)
                            selectedVal = val
                            dropTitle.Text = name .. " : " .. tostring(val)
                            pcall(callback, val)

                            local flagName = opt.Flag or name
                            if flagName and not opt.NoConfig then
                                Window.Flags[flagName] = val
                                if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                    Window.SaveActiveConfigDirect()
                                end
                            end
                        end,
                        Refresh = populateOptions,
                        GetValue = function() return selectedVal end
                    }

                    local flagName = opt.Flag or name
                    if flagName and not opt.NoConfig then
                        Window.ConfigElements[flagName] = dropObj
                        Window.Flags[flagName] = default
                    end

                    return dropObj
                end

                -- --------------------------------------------------------
                -- 2b. ADD MULTI-SELECT DROPDOWN
                -- --------------------------------------------------------
                function Card:AddMultiDropdown(opt)
                    opt = opt or {}
                    local name = opt.Name or "MultiDropdown"
                    local options = opt.Options or {}
                    local default = opt.Default or {}
                    local callback = opt.Callback or function() end

                    local selectedMap = {}
                    if type(default) == "table" then
                        for _, v in ipairs(default) do selectedMap[v] = true end
                    end

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local dropFrame = Instance.new("Frame")
                    dropFrame.Name = "MultiDropdown"
                    dropFrame.Size = UDim2.new(1, 0, 0, 31)
                    dropFrame.BackgroundTransparency = 1
                    dropFrame.ClipsDescendants = true
                    dropFrame.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    dropFrame.Parent = gb

                    local dropBtn = Instance.new("TextButton")
                    dropBtn.Name = "DropButton"
                    dropBtn.Size = UDim2.new(1, 0, 0, 31)
                    dropBtn.BackgroundTransparency = 1
                    dropBtn.Text = ""
                    dropBtn.Parent = dropFrame

                    local function getDisplaySummary()
                        local activeList = {}
                        for _, optText in ipairs(options) do
                            if selectedMap[optText] then table.insert(activeList, optText) end
                        end
                        if #activeList == 0 then return "None" end
                        return table.concat(activeList, ", ")
                    end

                    local dropTitle = Instance.new("TextLabel")
                    dropTitle.Name = "Droptitle"
                    dropTitle.Size = UDim2.new(0, 410, 0, 30)
                    dropTitle.Position = UDim2.new(0, 13, 0, 0)
                    dropTitle.BackgroundTransparency = 1
                    dropTitle.Text = name .. " : " .. getDisplaySummary()
                    dropTitle.TextColor3 = Color3.fromRGB(225, 225, 225)
                    dropTitle.TextSize = 11
                    dropTitle.Font = Enum.Font.Gotham
                    dropTitle.TextXAlignment = Enum.TextXAlignment.Left
                    dropTitle.TextYAlignment = Enum.TextYAlignment.Center
                    dropTitle.Parent = dropFrame

                    local dropImg = Instance.new("ImageLabel")
                    dropImg.Name = "DropImage"
                    dropImg.Size = UDim2.new(0, 20, 0, 20)
                    dropImg.Position = UDim2.new(1, -35, 0, 5)
                    dropImg.BackgroundTransparency = 1
                    dropImg.Image = resolveAsset("DropdownArrow.png")
                    dropImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    dropImg.Parent = dropFrame

                    local searchBox = Instance.new("TextBox")
                    searchBox.Name = "SearchBox"
                    searchBox.Size = UDim2.new(1, -26, 0, 24)
                    searchBox.Position = UDim2.new(0, 13, 0, 34)
                    searchBox.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
                    searchBox.BackgroundTransparency = 0.3
                    searchBox.PlaceholderText = "Search..."
                    searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
                    searchBox.Text = ""
                    searchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
                    searchBox.TextSize = 11
                    searchBox.Font = Enum.Font.Gotham
                    searchBox.Visible = false
                    searchBox.ClearTextOnFocus = false
                    searchBox.Parent = dropFrame

                    local searchCorner = Instance.new("UICorner")
                    searchCorner.CornerRadius = UDim.new(0, 6)
                    searchCorner.Parent = searchBox

                    local dropScroll = Instance.new("ScrollingFrame")
                    dropScroll.Name = "DropScroll"
                    dropScroll.Size = UDim2.new(1, -26, 0, 114)
                    dropScroll.Position = UDim2.new(0, 13, 0, 62)
                    dropScroll.BackgroundTransparency = 1
                    dropScroll.BorderSizePixel = 0
                    dropScroll.ScrollBarThickness = 2
                    dropScroll.ScrollBarImageColor3 = Color3.fromRGB(245, 245, 250)
                    dropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    dropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    dropScroll.Parent = dropFrame

                    local dLayout = Instance.new("UIListLayout")
                    dLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    dLayout.Padding = UDim.new(0, 2)
                    dLayout.Parent = dropScroll

                    local isOpen = false

                    local function closeDropdown()
                        if not isOpen then return end
                        isOpen = false
                        tween(dropFrame, { Size = UDim2.new(1, 0, 0, 31) })
                        tween(dropImg, { Rotation = 0 })
                        searchBox.Visible = false
                        if currentOpenDropdownCloser == closeDropdown then
                            currentOpenDropdownCloser = nil
                        end
                    end

                    local function openDropdown()
                        if isOpen then return end
                        if currentOpenDropdownCloser then
                            currentOpenDropdownCloser()
                        end
                        isOpen = true
                        currentOpenDropdownCloser = closeDropdown
                        tween(dropFrame, { Size = UDim2.new(1, 0, 0, 180) })
                        tween(dropImg, { Rotation = 180 })
                        searchBox.Visible = true
                    end

                    dropBtn.MouseButton1Click:Connect(function()
                        if isOpen then closeDropdown() else openDropdown() end
                    end)

                    local function populateOptions(opts)
                        for _, ch in ipairs(dropScroll:GetChildren()) do
                            if ch:IsA("TextButton") then ch:Destroy() end
                        end
                        for oIdx, optText in ipairs(opts) do
                            local optBtn = Instance.new("TextButton")
                            optBtn.Name = "Option_" .. oIdx
                            optBtn.Size = UDim2.new(1, 0, 0, 22)
                            optBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                            optBtn.BackgroundTransparency = selectedMap[optText] and 0.5 or 1
                            optBtn.Text = (selectedMap[optText] and "✓ " or "  ") .. optText
                            optBtn.TextColor3 = selectedMap[optText] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 185)
                            optBtn.TextSize = 11
                            optBtn.Font = Enum.Font.Gotham
                            optBtn.TextXAlignment = Enum.TextXAlignment.Left
                            optBtn.LayoutOrder = oIdx
                            optBtn.Parent = dropScroll

                            local oPad = Instance.new("UIPadding")
                            oPad.PaddingLeft = UDim.new(0, 8)
                            oPad.Parent = optBtn

                            optBtn.MouseButton1Click:Connect(function()
                                selectedMap[optText] = not selectedMap[optText]
                                optBtn.Text = (selectedMap[optText] and "✓ " or "  ") .. optText
                                optBtn.TextColor3 = selectedMap[optText] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 185)
                                optBtn.BackgroundTransparency = selectedMap[optText] and 0.5 or 1
                                dropTitle.Text = name .. " : " .. getDisplaySummary()

                                local res = {}
                                for _, k in ipairs(options) do
                                    if selectedMap[k] then table.insert(res, k) end
                                end
                                pcall(callback, res)

                                local flagName = opt.Flag or name
                                if flagName and not opt.NoConfig then
                                    Window.Flags[flagName] = res
                                    if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                        Window.SaveActiveConfigDirect()
                                    end
                                end
                            end)
                        end
                    end

                    populateOptions(options)

                    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local q = string.lower(searchBox.Text)
                        for _, btnOpt in ipairs(dropScroll:GetChildren()) do
                            if btnOpt:IsA("TextButton") then
                                local pureText = btnOpt.Text:gsub("✓%s*", ""):gsub("^%s*", "")
                                if q == "" or string.find(string.lower(pureText), q, 1, true) then
                                    btnOpt.Visible = true
                                else
                                    btnOpt.Visible = false
                                end
                            end
                        end
                    end)

                    local multiDropObj = {
                        Set = function(tbl)
                            selectedMap = {}
                            if type(tbl) == "table" then
                                for _, v in ipairs(tbl) do selectedMap[v] = true end
                            end
                            populateOptions(options)
                            dropTitle.Text = name .. " : " .. getDisplaySummary()
                            pcall(callback, tbl)

                            local flagName = opt.Flag or name
                            if flagName and not opt.NoConfig then
                                Window.Flags[flagName] = tbl
                                if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                    Window.SaveActiveConfigDirect()
                                end
                            end
                        end,
                        Refresh = populateOptions,
                        GetValue = function()
                            local res = {}
                            for _, k in ipairs(options) do
                                if selectedMap[k] then table.insert(res, k) end
                            end
                            return res
                        end
                    }

                    local flagName = opt.Flag or name
                    if flagName and not opt.NoConfig then
                        Window.ConfigElements[flagName] = multiDropObj
                        local defRes = {}
                        if type(default) == "table" then
                            for _, v in ipairs(default) do table.insert(defRes, v) end
                        end
                        Window.Flags[flagName] = defRes
                    end

                    return multiDropObj
                end

                -- --------------------------------------------------------
                -- 3. ADD BUTTON (Exact v32)
                -- --------------------------------------------------------
                function Card:AddButton(opt)
                    opt = opt or {}
                    local name = opt.Name or "Button"
                    local callback = opt.Callback or function() end

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local btn = Instance.new("TextButton")
                    btn.Name = "Button"
                    btn.Size = UDim2.new(1, 0, 0, 31)
                    btn.BackgroundTransparency = 1
                    btn.Text = name
                    btn.TextColor3 = Color3.fromRGB(225, 225, 225)
                    btn.TextSize = 11
                    btn.Font = Enum.Font.Gotham
                    btn.TextXAlignment = Enum.TextXAlignment.Center
                    btn.TextYAlignment = Enum.TextYAlignment.Center
                    btn.TextWrapped = true
                    btn.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    btn.Parent = gb

                    btn.MouseButton1Click:Connect(function()
                        tween(btn, { TextColor3 = Color3.fromRGB(120, 200, 255) }, 0.08)
                        task.delay(0.12, function()
                            tween(btn, { TextColor3 = Color3.fromRGB(225, 225, 225) }, 0.15)
                        end)
                        pcall(callback)
                    end)

                    return btn
                end

                -- --------------------------------------------------------
                -- 4. ADD INPUT / TEXTBOX (Exact v32 Textboxx)
                -- --------------------------------------------------------
                function Card:AddInput(opt)
                    opt = opt or {}
                    local name = opt.Name or "Input"
                    local placeholder = opt.Placeholder or "Write amount here."
                    local default = opt.Default or ""
                    local callback = opt.Callback or function() end

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local row = Instance.new("Frame")
                    row.Name = "Textboxx"
                    row.Size = UDim2.new(1, 0, 0, 31)
                    row.BackgroundTransparency = 1
                    row.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    row.Parent = gb

                    local lbl = Instance.new("TextLabel")
                    lbl.Name = "TextboxTitle"
                    lbl.Size = UDim2.new(0, 300, 0, 30)
                    lbl.Position = UDim2.new(0, 13, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = name
                    lbl.TextColor3 = Color3.fromRGB(225, 225, 225)
                    lbl.TextSize = 11
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.TextYAlignment = Enum.TextYAlignment.Center
                    lbl.Parent = row

                    local box = Instance.new("TextBox")
                    box.Name = "Textbox"
                    box.Size = UDim2.new(0, 160, 0, 20)
                    box.Position = UDim2.new(1, -10, 0, 5)
                    box.AnchorPoint = Vector2.new(1, 0)
                    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    box.BorderSizePixel = 0
                    box.PlaceholderText = placeholder
                    box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                    box.Text = default
                    box.TextColor3 = Color3.fromRGB(255, 255, 255)
                    box.TextSize = 11
                    box.Font = Enum.Font.GothamMedium
                    box.TextXAlignment = Enum.TextXAlignment.Center
                    box.ClearTextOnFocus = false
                    box.Parent = row

                    local bCorner = Instance.new("UICorner")
                    bCorner.CornerRadius = UDim.new(1, 0)
                    bCorner.Parent = box

                    local bStroke = Instance.new("UIStroke")
                    bStroke.Thickness = 1
                    bStroke.Color = Color3.fromRGB(55, 55, 62)
                    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    bStroke.Parent = box

                    local bPad = Instance.new("UIPadding")
                    bPad.PaddingLeft = UDim.new(0, 8)
                    bPad.PaddingRight = UDim.new(0, 8)
                    bPad.Parent = box

                    box.FocusLost:Connect(function()
                        pcall(callback, box.Text)

                        local flagName = opt.Flag or name
                        if flagName and not opt.NoConfig then
                            Window.Flags[flagName] = box.Text
                            if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                Window.SaveActiveConfigDirect()
                            end
                        end
                    end)

                    local inputObj = {
                        Set = function(txt)
                            box.Text = tostring(txt)
                            pcall(callback, txt)

                            local flagName = opt.Flag or name
                            if flagName and not opt.NoConfig then
                                Window.Flags[flagName] = tostring(txt)
                                if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                    Window.SaveActiveConfigDirect()
                                end
                            end
                        end,
                        GetValue = function() return box.Text end
                    }

                    local flagName = opt.Flag or name
                    if flagName and not opt.NoConfig then
                        Window.ConfigElements[flagName] = inputObj
                        Window.Flags[flagName] = default
                    end

                    return inputObj
                end

                -- --------------------------------------------------------
                -- 5. ADD SLIDER (Exact v32: 51px Height with Pill Value & Track)
                -- --------------------------------------------------------
                function Card:AddSlider(opt)
                    opt = opt or {}
                    local name = opt.Name or "Slider"
                    local minVal = opt.Min or 0
                    local maxVal = opt.Max or 100
                    local default = opt.Default or minVal
                    local isFloat = opt.Precise or false
                    local callback = opt.Callback or function() end

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local sliderFrame = Instance.new("Frame")
                    sliderFrame.Name = "Slider"
                    sliderFrame.Size = UDim2.new(1, 0, 0, 51)
                    sliderFrame.BackgroundTransparency = 1
                    sliderFrame.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    sliderFrame.Parent = gb

                    local lbl = Instance.new("TextLabel")
                    lbl.Name = "SliderTitle"
                    lbl.Size = UDim2.new(0, 300, 0, 30)
                    lbl.Position = UDim2.new(0, 13, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = name
                    lbl.TextColor3 = Color3.fromRGB(225, 225, 225)
                    lbl.TextSize = 12
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.TextYAlignment = Enum.TextYAlignment.Center
                    lbl.Parent = sliderFrame

                    local sVal = Instance.new("TextBox")
                    sVal.Name = "SliderValue"
                    sVal.Size = UDim2.new(0, 50, 0, 20)
                    sVal.Position = UDim2.new(1, -10, 0, 5)
                    sVal.AnchorPoint = Vector2.new(1, 0)
                    sVal.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    sVal.Text = isFloat and string.format("%.2f", default) or tostring(math.round(default))
                    sVal.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sVal.TextSize = 11
                    sVal.Font = Enum.Font.GothamMedium
                    sVal.TextXAlignment = Enum.TextXAlignment.Center
                    sVal.ClearTextOnFocus = false
                    sVal.Parent = sliderFrame

                    local sValCorner = Instance.new("UICorner")
                    sValCorner.CornerRadius = UDim.new(1, 0)
                    sValCorner.Parent = sVal

                    local sValStroke = Instance.new("UIStroke")
                    sValStroke.Thickness = 1
                    sValStroke.Color = Color3.fromRGB(55, 55, 62)
                    sValStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    sValStroke.Parent = sVal

                    local sBtn = Instance.new("TextButton")
                    sBtn.Name = "SliderButton"
                    sBtn.Size = UDim2.new(1, -20, 0, 14)
                    sBtn.Position = UDim2.new(0, 10, 0, 31)
                    sBtn.BackgroundTransparency = 1
                    sBtn.Text = ""
                    sBtn.Parent = sliderFrame

                    local track = Instance.new("Frame")
                    track.Name = "Bar1"
                    track.Size = UDim2.new(1, 0, 0, 4)
                    track.Position = UDim2.new(0, 0, 0.5, 0)
                    track.AnchorPoint = Vector2.new(0, 0.5)
                    track.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
                    track.BorderSizePixel = 0
                    track.Parent = sBtn

                    local trackCorner = Instance.new("UICorner")
                    trackCorner.CornerRadius = UDim.new(1, 0)
                    trackCorner.Parent = track

                    local initialPct = math.clamp((default - minVal) / (maxVal - minVal), 0, 1)

                    local bar = Instance.new("Frame")
                    bar.Name = "Bar"
                    bar.Size = UDim2.new(initialPct, 0, 1, 0)
                    bar.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
                    bar.BorderSizePixel = 0
                    bar.Parent = track

                    local barCorner = Instance.new("UICorner")
                    barCorner.CornerRadius = UDim.new(1, 0)
                    barCorner.Parent = bar

                    local knob = Instance.new("Frame")
                    knob.Name = "SliderKnob"
                    knob.Size = UDim2.new(0, 12, 0, 12)
                    knob.Position = UDim2.new(initialPct, 0, 0.5, 0)
                    knob.AnchorPoint = Vector2.new(0.5, 0.5)
                    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    knob.BorderSizePixel = 0
                    knob.Parent = sBtn

                    local knobCorner = Instance.new("UICorner")
                    knobCorner.CornerRadius = UDim.new(1, 0)
                    knobCorner.Parent = knob

                    local curVal = default
                    local isDragging = false

                    local function updateSlider(mouseX)
                        local absPos = sBtn.AbsolutePosition.X
                        local absWidth = sBtn.AbsoluteSize.X
                        if absWidth <= 0 then absWidth = 1 end
                        local pct = math.clamp((mouseX - absPos) / absWidth, 0, 1)
                        bar.Size = UDim2.new(pct, 0, 1, 0)
                        knob.Position = UDim2.new(pct, 0, 0.5, 0)

                        local val = minVal + pct * (maxVal - minVal)
                        curVal = val
                        if isFloat then
                            sVal.Text = string.format("%.2f", val)
                        else
                            sVal.Text = tostring(math.round(val))
                        end
                        pcall(callback, curVal)
                    end

                    sBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDragging = true
                            updateSlider(input.Position.X)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            updateSlider(input.Position.X)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if isDragging then
                                isDragging = false
                                local flagName = opt.Flag or name
                                if flagName and not opt.NoConfig then
                                    Window.Flags[flagName] = curVal
                                    if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                        Window.SaveActiveConfigDirect()
                                    end
                                end
                            end
                        end
                    end)

                    sVal.FocusLost:Connect(function()
                        local num = tonumber(sVal.Text)
                        if num then
                            num = math.clamp(num, minVal, maxVal)
                            local pct = (num - minVal) / (maxVal - minVal)
                            bar.Size = UDim2.new(pct, 0, 1, 0)
                            knob.Position = UDim2.new(pct, 0, 0.5, 0)
                            curVal = num
                            pcall(callback, curVal)

                            local flagName = opt.Flag or name
                            if flagName and not opt.NoConfig then
                                Window.Flags[flagName] = curVal
                                if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                    Window.SaveActiveConfigDirect()
                                end
                            end
                        end
                    end)

                    local sliderObj = {
                        Set = function(val)
                            val = math.clamp(val, minVal, maxVal)
                            local pct = (val - minVal) / (maxVal - minVal)
                            bar.Size = UDim2.new(pct, 0, 1, 0)
                            knob.Position = UDim2.new(pct, 0, 0.5, 0)
                            curVal = val
                            if isFloat then
                                sVal.Text = string.format("%.2f", val)
                            else
                                sVal.Text = tostring(math.round(val))
                            end
                            pcall(callback, curVal)

                            local flagName = opt.Flag or name
                            if flagName and not opt.NoConfig then
                                Window.Flags[flagName] = curVal
                                if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                    Window.SaveActiveConfigDirect()
                                end
                            end
                        end,
                        GetValue = function() return curVal end
                    }

                    local flagName = opt.Flag or name
                    if flagName and not opt.NoConfig then
                        Window.ConfigElements[flagName] = sliderObj
                        Window.Flags[flagName] = default
                    end

                    return sliderObj
                end

                -- --------------------------------------------------------
                -- 6. ADD KEYBIND (Exact v32)
                -- --------------------------------------------------------
                function Card:AddKeybind(opt)
                    opt = opt or {}
                    local name = opt.Name or "Keybind"
                    local default = opt.Default or Enum.KeyCode.Unknown
                    local callback = opt.Callback or function() end

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local row = Instance.new("Frame")
                    row.Name = "KeybindRow"
                    row.Size = UDim2.new(1, 0, 0, 31)
                    row.BackgroundTransparency = 1
                    row.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    row.Parent = gb

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, -100, 1, 0)
                    lbl.Position = UDim2.new(0, 13, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = name
                    lbl.TextColor3 = Color3.fromRGB(225, 225, 225)
                    lbl.TextSize = 11
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.TextYAlignment = Enum.TextYAlignment.Center
                    lbl.Parent = row

                    local badge = Instance.new("TextButton")
                    badge.Name = "KeybindBadge"
                    badge.Size = UDim2.new(0, 0, 0, 18)
                    badge.AutomaticSize = Enum.AutomaticSize.X
                    badge.Position = UDim2.new(1, -14, 0.5, 0)
                    badge.AnchorPoint = Vector2.new(1, 0.5)
                    badge.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    badge.BorderSizePixel = 0
                    badge.AutoButtonColor = false
                    badge.Text = (default and default.Name) or "None"
                    badge.TextColor3 = Color3.fromRGB(120, 120, 130)
                    badge.TextSize = 9
                    badge.Font = Enum.Font.GothamMedium
                    badge.Parent = row

                    local bCorner = Instance.new("UICorner")
                    bCorner.CornerRadius = UDim.new(0, 4)
                    bCorner.Parent = badge

                    local bStroke = Instance.new("UIStroke")
                    bStroke.Thickness = 1
                    bStroke.Color = Color3.fromRGB(55, 55, 62)
                    bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    bStroke.Parent = badge

                    local bPad = Instance.new("UIPadding")
                    bPad.PaddingLeft = UDim.new(0, 6)
                    bPad.PaddingRight = UDim.new(0, 6)
                    bPad.Parent = badge

                    local currentKey = default
                    local listening = false

                    badge.MouseButton1Click:Connect(function()
                        if listening then return end
                        listening = true
                        badge.Text = "..."
                        badge.TextColor3 = Color3.fromRGB(120, 200, 255)

                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input, gpe)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                currentKey = input.KeyCode
                                badge.Text = input.KeyCode.Name
                                badge.TextColor3 = Color3.fromRGB(120, 120, 130)
                                listening = false
                                conn:Disconnect()
                                pcall(callback, currentKey)

                                local flagName = opt.Flag or name
                                if flagName and not opt.NoConfig then
                                    Window.Flags[flagName] = currentKey.Name
                                    if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                        Window.SaveActiveConfigDirect()
                                    end
                                end
                            end
                        end)
                    end)

                    local keybindObj = {
                        Set = function(key)
                            if type(key) == "string" then
                                key = Enum.KeyCode[key] or Enum.KeyCode.Unknown
                            end
                            currentKey = key
                            badge.Text = (key and key.Name) or "None"
                            pcall(callback, key)

                            local flagName = opt.Flag or name
                            if flagName and not opt.NoConfig then
                                Window.Flags[flagName] = (key and key.Name) or "Unknown"
                                if Window.AutosaveEnabled and Window.SaveActiveConfigDirect then
                                    Window.SaveActiveConfigDirect()
                                end
                            end
                        end,
                        GetValue = function() return currentKey end
                    }

                    local flagName = opt.Flag or name
                    if flagName and not opt.NoConfig then
                        Window.ConfigElements[flagName] = keybindObj
                        Window.Flags[flagName] = (default and default.Name) or "Unknown"
                    end

                    return keybindObj
                end

                -- --------------------------------------------------------
                -- 7. ADD LABEL (Exact v32)
                -- --------------------------------------------------------
                function Card:AddLabel(opt)
                    opt = opt or {}
                    local text = opt.Text or ""

                    addDivider()
                    Card.ItemCount = Card.ItemCount + 1

                    local lbl = Instance.new("TextLabel")
                    lbl.Name = "Label"
                    lbl.Size = UDim2.new(1, -26, 0, 24)
                    lbl.Position = UDim2.new(0, 13, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = text
                    lbl.TextColor3 = Color3.fromRGB(180, 180, 185)
                    lbl.TextSize = 11
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.TextYAlignment = Enum.TextYAlignment.Center
                    lbl.LayoutOrder = Card.LayoutIndex
                    Card.LayoutIndex = Card.LayoutIndex + 1
                    lbl.Parent = gb

                    return {
                        SetText = function(newTxt)
                            lbl.Text = newTxt
                        end
                    }
                end

                function Card:AddBanner(opt)
                    return SubTab:AddBanner(opt)
                end

                function Card:AddSearchBar(opt)
                    return SubTab:AddSearchBar(opt)
                end

                function Card:AddServerCard(opt)
                    return SubTab:AddServerCard(opt)
                end

                table.insert(SubTab.Cards, Card)
                return Card
            end

            local configIdx = nil
            for i, s in ipairs(Tab.SubTabs) do
                if s.Name == "Config" and subName ~= "Config" then
                    configIdx = i
                    break
                end
            end

            if configIdx then
                table.insert(Tab.SubTabs, configIdx, SubTab)
            else
                table.insert(Tab.SubTabs, SubTab)
            end

            if Window.ActiveTab == Tab or Window.ActiveTab == nil then
                Window.ActiveTab = Tab
                task.defer(function()
                    if Window.ActiveTab == Tab then
                        Tab:RenderSubTabs(Tab.ActiveSubTab or Tab.SubTabs[1])
                    end
                end)
            end

            return SubTab
        end

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Window.ActiveTab = Tab
            task.defer(function()
                if Window.ActiveTab == Tab then
                    activateTab()
                end
            end)
        end

        return Tab
    end

    function Window:Destroy()
        pcall(function()
            if ScreenGui then ScreenGui:Destroy() end
            if FloatingToggle then FloatingToggle:Destroy() end
        end)
    end

    function Window:Notify(cfg)
        return IggyLib:Notify(cfg)
    end

    -- ====================================================================
    -- BUILT-IN SETTINGS TAB (Exact v32: Always Top of Sidebar, Order 1)
    -- SubTabs: [1] "Settings" (Permanent First), ...custom..., [Last] "Config" (Permanent Last)
    -- ====================================================================
    local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "Settings.png" })
    Window.SettingsTab = SettingsTab

    -- 1. FIRST SUBTAB: "Settings" (Exact v32 Recreation)
    local SettingsSub = SettingsTab:CreateSubTab("Settings")
    Window.SettingsSubTab = SettingsSub

    -- Top SearchBarCard (Exact v32: 36px height, rounded 10, inner bar)
    local searchCard = Instance.new("Frame")
    searchCard.Name = "SearchBarCard"
    searchCard.Size = UDim2.new(1, 0, 0, 36)
    searchCard.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    searchCard.BackgroundTransparency = 0.10
    searchCard.BorderSizePixel = 0
    searchCard.LayoutOrder = 1
    searchCard.Parent = SettingsSub.ScrollFrame

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 10)
    searchCorner.Parent = searchCard

    local searchStroke = Instance.new("UIStroke")
    searchStroke.Thickness = 1
    searchStroke.Color = Color3.fromRGB(240, 240, 240)
    searchStroke.Transparency = 0.90
    searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    searchStroke.Parent = searchCard

    local innerBar = Instance.new("Frame")
    innerBar.Name = "InnerBar"
    innerBar.Size = UDim2.new(1, -12, 0, 26)
    innerBar.Position = UDim2.new(0, 6, 0, 5)
    innerBar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    innerBar.BorderSizePixel = 0
    innerBar.Parent = searchCard

    local ibCorner = Instance.new("UICorner")
    ibCorner.CornerRadius = UDim.new(0, 7)
    ibCorner.Parent = innerBar

    local sIcon = Instance.new("ImageLabel")
    sIcon.Size = UDim2.new(0, 14, 0, 14)
    sIcon.Position = UDim2.new(0, 7, 0.5, -7)
    sIcon.BackgroundTransparency = 1
    sIcon.Image = resolveAsset("SearchIcon.png")
    sIcon.ImageColor3 = Color3.fromRGB(90, 90, 95)
    sIcon.Parent = innerBar

    local sInput = Instance.new("TextBox")
    sInput.Size = UDim2.new(1, -70, 1, 0)
    sInput.Position = UDim2.new(0, 28, 0, 0)
    sInput.BackgroundTransparency = 1
    sInput.Text = ""
    sInput.PlaceholderText = "Search features..."
    sInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 128)
    sInput.TextColor3 = Color3.fromRGB(215, 215, 220)
    sInput.TextSize = 11
    sInput.Font = Enum.Font.Gotham
    sInput.TextXAlignment = Enum.TextXAlignment.Left
    sInput.ClearTextOnFocus = false
    sInput.Parent = innerBar

    table.insert(SettingsSub.Elements, searchCard)

    -- Original IggyHub StatusCard: User Profile + Live Telemetry (Ping, FPS, Session)
    local statusCard = Instance.new("Frame")
    statusCard.Name = "StatusCard"
    statusCard.Size = UDim2.new(1, 0, 0, 76)
    statusCard.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    statusCard.BackgroundTransparency = 0.10
    statusCard.BorderSizePixel = 0
    statusCard.LayoutOrder = 2
    statusCard.Parent = SettingsSub.ScrollFrame

    local scCorner = Instance.new("UICorner")
    scCorner.CornerRadius = UDim.new(0, 12)
    scCorner.Parent = statusCard

    local scStroke = Instance.new("UIStroke")
    scStroke.Thickness = 1
    scStroke.Color = Color3.fromRGB(240, 240, 240)
    scStroke.Transparency = 0.90
    scStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    scStroke.Parent = statusCard

    -- Left: Interactive Avatar Button (Click to toggle Streamer Mode)
    local avatarBtn = Instance.new("TextButton")
    avatarBtn.Name = "AvatarButton"
    avatarBtn.Size = UDim2.new(0, 50, 0, 50)
    avatarBtn.Position = UDim2.new(0, 13, 0.5, 0)
    avatarBtn.AnchorPoint = Vector2.new(0, 0.5)
    avatarBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    avatarBtn.BorderSizePixel = 0
    avatarBtn.AutoButtonColor = false
    avatarBtn.Text = ""
    avatarBtn.Active = true
    avatarBtn.ClipsDescendants = true
    avatarBtn.Parent = statusCard

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(1, 0)
    rCorner.Parent = avatarBtn

    local rStroke = Instance.new("UIStroke")
    rStroke.Thickness = 1.2
    rStroke.Color = Color3.fromRGB(240, 240, 240)
    rStroke.Transparency = 0.85
    rStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rStroke.Parent = avatarBtn

    local headshot = Instance.new("ImageLabel")
    headshot.Name = "AvatarImg"
    headshot.Size = UDim2.new(0.9, 0, 0.9, 0)
    headshot.Position = UDim2.new(0.5, 0, 0.5, 0)
    headshot.AnchorPoint = Vector2.new(0.5, 0.5)
    headshot.BackgroundTransparency = 1
    headshot.Active = false
    headshot.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer and LocalPlayer.UserId or 0) .. "&w=420&h=420"
    headshot.Parent = avatarBtn

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(1, 0)
    hCorner.Parent = headshot

    -- Privacy Icon for Streamer Mode (pure white eye-slash icon matching monochrome theme)
    local privacyIcon = Instance.new("ImageLabel")
    privacyIcon.Name = "PrivacyIcon"
    privacyIcon.Size = UDim2.new(0.55, 0, 0.55, 0)
    privacyIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    privacyIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    privacyIcon.BackgroundTransparency = 1
    privacyIcon.Active = false
    privacyIcon.Image = "rbxassetid://7733774495"
    privacyIcon.ImageColor3 = Color3.fromRGB(245, 245, 250)
    privacyIcon.Visible = false
    privacyIcon.Parent = avatarBtn

    -- User Info (Display Name + Permanently Masked @Username + Redacted Blocks)
    local rawName = LocalPlayer and LocalPlayer.Name or "Player"
    local rawDisplay = LocalPlayer and LocalPlayer.DisplayName or rawName
    local maskedName = #rawName > 3 and (rawName:sub(1, 3) .. "*****") or (rawName .. "*****")

    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "UserInfo"
    infoFrame.Size = UDim2.new(0, 180, 0, 50)
    infoFrame.Position = UDim2.new(0, 72, 0.5, 0)
    infoFrame.AnchorPoint = Vector2.new(0, 0.5)
    infoFrame.BackgroundTransparency = 1
    infoFrame.Parent = statusCard

    local dLabel = Instance.new("TextLabel")
    dLabel.Name = "DisplayName"
    dLabel.Size = UDim2.new(1, 0, 0, 18)
    dLabel.Position = UDim2.new(0, 0, 0, 1)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = rawDisplay
    dLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
    dLabel.TextSize = 15
    dLabel.Font = Enum.Font.GothamBold
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.TextTruncate = Enum.TextTruncate.AtEnd
    dLabel.Parent = infoFrame

    local uLabel = Instance.new("TextLabel")
    uLabel.Name = "UsernameMask"
    uLabel.Size = UDim2.new(1, 0, 0, 15)
    uLabel.Position = UDim2.new(0, 0, 0, 19)
    uLabel.BackgroundTransparency = 1
    uLabel.Text = "@" .. maskedName
    uLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    uLabel.TextSize = 11
    uLabel.Font = Enum.Font.GothamMedium
    uLabel.TextXAlignment = Enum.TextXAlignment.Left
    uLabel.Parent = infoFrame

    -- Redacted Pill 1 (Replaces DisplayName when Streamer Mode is ON)
    local redactName = Instance.new("Frame")
    redactName.Name = "RedactName"
    redactName.Size = UDim2.new(0, 115, 0, 15)
    redactName.Position = UDim2.new(0, 0, 0, 6)
    redactName.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    redactName.BorderSizePixel = 0
    redactName.Visible = false
    redactName.Parent = infoFrame

    local rnCorner = Instance.new("UICorner")
    rnCorner.CornerRadius = UDim.new(0, 4)
    rnCorner.Parent = redactName

    local rnStroke = Instance.new("UIStroke")
    rnStroke.Thickness = 1
    rnStroke.Color = Color3.fromRGB(240, 240, 240)
    rnStroke.Transparency = 0.88
    rnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    rnStroke.Parent = redactName

    -- Redacted Pill 2 (Replaces Username when Streamer Mode is ON)
    local redactUser = Instance.new("Frame")
    redactUser.Name = "RedactUser"
    redactUser.Size = UDim2.new(0, 80, 0, 12)
    redactUser.Position = UDim2.new(0, 0, 0, 26)
    redactUser.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    redactUser.BorderSizePixel = 0
    redactUser.Visible = false
    redactUser.Parent = infoFrame

    local ruCorner = Instance.new("UICorner")
    ruCorner.CornerRadius = UDim.new(0, 4)
    ruCorner.Parent = redactUser

    local ruStroke = Instance.new("UIStroke")
    ruStroke.Thickness = 1
    ruStroke.Color = Color3.fromRGB(240, 240, 240)
    ruStroke.Transparency = 0.88
    ruStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ruStroke.Parent = redactUser

    local statusPill = Instance.new("Frame")
    statusPill.Name = "StatusPill"
    statusPill.Size = UDim2.new(1, 0, 0, 14)
    statusPill.Position = UDim2.new(0, 0, 0, 35)
    statusPill.BackgroundTransparency = 1
    statusPill.Parent = infoFrame

    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 0, 0.5, 0)
    dot.AnchorPoint = Vector2.new(0, 0.5)
    dot.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
    dot.BorderSizePixel = 0
    dot.Parent = statusPill

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(1, 0)
    dCorner.Parent = dot

    local statText = Instance.new("TextLabel")
    statText.Name = "StatusText"
    statText.Size = UDim2.new(1, -12, 1, 0)
    statText.Position = UDim2.new(0, 10, 0, 0)
    statText.BackgroundTransparency = 1
    statText.Text = "Online"
    statText.TextColor3 = Color3.fromRGB(130, 130, 140)
    statText.TextSize = 10
    statText.Font = Enum.Font.Gotham
    statText.TextXAlignment = Enum.TextXAlignment.Left
    statText.Parent = statusPill

    -- Streamer Mode Toggle via Avatar Button
    local isStreamer = false
    local function setStreamerMode(active)
        isStreamer = active
        Window.StreamerMode = active
        if isStreamer then
            avatarBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
            rStroke.Color = Color3.fromRGB(245, 245, 250)
            rStroke.Thickness = 1.5
            rStroke.Transparency = 0.2
            headshot.Visible = false
            privacyIcon.Visible = true

            -- Sync Bottom-Left Sidebar Avatar
            if Window.SidebarAvatarImg then
                Window.SidebarAvatarImg.Visible = false
            end
            if Window.SidebarPrivacyIcon then
                Window.SidebarPrivacyIcon.Visible = true
            end
            if Window.SidebarAvatarFrame then
                Window.SidebarAvatarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            end
            if Window.SidebarAvatarStroke then
                Window.SidebarAvatarStroke.Color = Color3.fromRGB(245, 245, 250)
                Window.SidebarAvatarStroke.Transparency = 0.3
            end

            dLabel.Visible = false
            uLabel.Visible = false
            redactName.Visible = true
            redactUser.Visible = true
            statusPill.Visible = false

            Window:Notify({
                Title = "Streamer Mode",
                Description = "Streamer mode ENABLED. Tap avatar to restore.",
                Time = 2.5
            })
        else
            avatarBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
            rStroke.Color = Color3.fromRGB(240, 240, 240)
            rStroke.Thickness = 1.2
            rStroke.Transparency = 0.85
            headshot.Visible = true
            privacyIcon.Visible = false

            -- Restore Bottom-Left Sidebar Avatar
            if Window.SidebarAvatarImg then
                Window.SidebarAvatarImg.Visible = true
            end
            if Window.SidebarPrivacyIcon then
                Window.SidebarPrivacyIcon.Visible = false
            end
            if Window.SidebarAvatarFrame then
                Window.SidebarAvatarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
            if Window.SidebarAvatarStroke then
                Window.SidebarAvatarStroke.Transparency = 1
            end

            dLabel.Visible = true
            uLabel.Visible = true
            redactName.Visible = false
            redactUser.Visible = false
            statusPill.Visible = true

            dot.BackgroundColor3 = Color3.fromRGB(60, 220, 120)
            statText.Text = "Online"
            statText.TextColor3 = Color3.fromRGB(130, 130, 140)

            Window:Notify({
                Title = "Streamer Mode",
                Description = "Streamer mode DISABLED.",
                Time = 2
            })
        end
    end

    Window.ToggleStreamerMode = function()
        setStreamerMode(not isStreamer)
    end

    avatarBtn.Activated:Connect(function()
        setStreamerMode(not isStreamer)
    end)

    -- Right: Discord Button
    local discordBtn = Instance.new("TextButton")
    discordBtn.Name = "DiscordBtn"
    discordBtn.Size = UDim2.new(0, 100, 0, 28)
    discordBtn.Position = UDim2.new(1, -14, 0.5, 0)
    discordBtn.AnchorPoint = Vector2.new(1, 0.5)
    discordBtn.BackgroundColor3 = Color3.fromRGB(42, 46, 64)
    discordBtn.BorderSizePixel = 0
    discordBtn.AutoButtonColor = false
    discordBtn.Text = "💬 Discord"
    discordBtn.TextColor3 = Color3.fromRGB(225, 230, 255)
    discordBtn.TextSize = 11
    discordBtn.Font = Enum.Font.GothamMedium
    discordBtn.Parent = statusCard

    local discCorner = Instance.new("UICorner")
    discCorner.CornerRadius = UDim.new(0, 6)
    discCorner.Parent = discordBtn

    local discStroke = Instance.new("UIStroke")
    discStroke.Thickness = 1
    discStroke.Color = Color3.fromRGB(88, 101, 242)
    discStroke.Transparency = 0.4
    discStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    discStroke.Parent = discordBtn

    discordBtn.MouseEnter:Connect(function()
        tween(discordBtn, { BackgroundColor3 = Color3.fromRGB(54, 60, 84) }, 0.12)
    end)
    discordBtn.MouseLeave:Connect(function()
        tween(discordBtn, { BackgroundColor3 = Color3.fromRGB(42, 46, 64) }, 0.12)
    end)

    discordBtn.MouseButton1Click:Connect(function()
        local link = Window.DiscordLink or "https://discord.gg/6UBrrVchnh"
        pcall(function()
            if setclipboard then
                setclipboard(link)
            elseif toclipboard then
                toclipboard(link)
            end
        end)
        Window:Notify({
            Title = "Discord Invite",
            Description = "Copied invite link: " .. link,
            Time = 2.5
        })
    end)

    table.insert(SettingsSub.Elements, statusCard)

    -- GroupBox: SETTINGS (Exact v32: Auto Execute, Anti AFK, UI Toggle Key)
    local builtinSettingsCard = SettingsSub:CreateCard("SETTINGS")

    local autoExecConn = nil
    local function getReExecutionPayload()
        if Window.ScriptLoaderCode and Window.ScriptLoaderCode ~= "" then
            return Window.ScriptLoaderCode
        end
        return 'task.wait(1.2); pcall(function() if isfile and isfile("Loader.lua") then loadstring(readfile("Loader.lua"))() elseif isfile and isfile("Example_Script.lua") then loadstring(readfile("Example_Script.lua"))() end end)'
    end

    builtinSettingsCard:AddToggle({
        Name = "Auto Execute Script",
        Default = false,
        Callback = function(enabled)
            if enabled then
                local payload = getReExecutionPayload()

                -- 1. Queue on Teleport (Immediate Server Hop / Rejoin Persistence)
                if queue_on_teleport then
                    pcall(function() queue_on_teleport(payload) end)
                end

                if autoExecConn then autoExecConn:Disconnect() end
                if LocalPlayer then
                    autoExecConn = LocalPlayer.OnTeleport:Connect(function()
                        if queue_on_teleport then
                            pcall(function() queue_on_teleport(payload) end)
                        end
                    end)
                end

                -- 2. Executor autoexec folder persistence (if supported)
                pcall(function()
                    if isfolder and isfolder("autoexec") and writefile then
                        writefile("autoexec/IggyHub.lua", payload)
                    end
                end)

                Window:Notify({
                    Title = "Auto Execute",
                    Description = "Auto Execute ENABLED (Teleport & Rejoin active)",
                    Time = 2.5
                })
            else
                if autoExecConn then
                    autoExecConn:Disconnect()
                    autoExecConn = nil
                end

                pcall(function()
                    if isfile and isfile("autoexec/IggyHub.lua") and delfile then
                        delfile("autoexec/IggyHub.lua")
                    end
                end)

                Window:Notify({
                    Title = "Auto Execute",
                    Description = "Auto Execute DISABLED",
                    Time = 2
                })
            end
        end
    })

    local antiAfkConn = nil
    builtinSettingsCard:AddToggle({
        Name = "Anti AFK",
        Default = true,
        Callback = function(enabled)
            if enabled then
                if not antiAfkConn and LocalPlayer then
                    local VirtualUser = game:GetService("VirtualUser")
                    antiAfkConn = LocalPlayer.Idled:Connect(function()
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new(0, 0))
                        end)
                    end)
                end
            else
                if antiAfkConn then
                    antiAfkConn:Disconnect()
                    antiAfkConn = nil
                end
            end
        end
    })

    builtinSettingsCard:AddKeybind({
        Name = "UI Toggle Key",
        Default = Window.ToggleKey,
        Callback = function(key)
            Window.ToggleKey = key
            Window:Notify({
                Title = "Keybind Updated",
                Description = "Menu toggle key set to: " .. key.Name,
                Time = 2.5
            })
        end
    })

    -- GroupBox: SERVER UTILITIES (Ping, FPS, Session, Players + Rejoin, Server Hop, Unload/Copy)
    local utilSep = Instance.new("Frame")
    utilSep.Name = "Seperator"
    utilSep.Size = UDim2.new(1, 0, 0, 16)
    utilSep.BackgroundTransparency = 1
    utilSep.LayoutOrder = 10
    utilSep.Parent = SettingsSub.ScrollFrame

    local utilSepLbl = Instance.new("TextLabel")
    utilSepLbl.Name = "SepLabel"
    utilSepLbl.Size = UDim2.new(1, -4, 0, 16)
    utilSepLbl.Position = UDim2.new(0, 4, 0, 0)
    utilSepLbl.BackgroundTransparency = 1
    utilSepLbl.Text = "SERVER UTILITIES"
    utilSepLbl.TextColor3 = Color3.fromRGB(160, 160, 165)
    utilSepLbl.TextSize = 11
    utilSepLbl.Font = Enum.Font.GothamMedium
    utilSepLbl.TextXAlignment = Enum.TextXAlignment.Left
    utilSepLbl.Parent = utilSep

    local utilCard = Instance.new("Frame")
    utilCard.Name = "UtilCard"
    utilCard.Size = UDim2.new(1, 0, 0, 78)
    utilCard.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    utilCard.BackgroundTransparency = 0.10
    utilCard.BorderSizePixel = 0
    utilCard.LayoutOrder = 11
    utilCard.Parent = SettingsSub.ScrollFrame

    local ucCorner = Instance.new("UICorner")
    ucCorner.CornerRadius = UDim.new(0, 12)
    ucCorner.Parent = utilCard

    local ucStroke = Instance.new("UIStroke")
    ucStroke.Thickness = 1
    ucStroke.Color = Color3.fromRGB(240, 240, 240)
    ucStroke.Transparency = 0.90
    ucStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ucStroke.Parent = utilCard

    local statRow = Instance.new("Frame")
    statRow.Name = "StatRow"
    statRow.Size = UDim2.new(1, -24, 0, 20)
    statRow.Position = UDim2.new(0, 12, 0, 8)
    statRow.BackgroundTransparency = 1
    statRow.Parent = utilCard

    -- Col 1: Ping
    local pingLbl = Instance.new("TextLabel")
    pingLbl.Name = "PingLabel"
    pingLbl.Size = UDim2.new(0.25, 0, 1, 0)
    pingLbl.Position = UDim2.new(0, 0, 0, 0)
    pingLbl.BackgroundTransparency = 1
    pingLbl.Text = "Ping: 50 ms"
    pingLbl.TextColor3 = Color3.fromRGB(175, 175, 185)
    pingLbl.TextSize = 11
    pingLbl.Font = Enum.Font.GothamMedium
    pingLbl.TextXAlignment = Enum.TextXAlignment.Left
    pingLbl.Parent = statRow

    -- Col 2: FPS
    local fpsLbl = Instance.new("TextLabel")
    fpsLbl.Name = "FPSLabel"
    fpsLbl.Size = UDim2.new(0.25, 0, 1, 0)
    fpsLbl.Position = UDim2.new(0.25, 0, 0, 0)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS: 60"
    fpsLbl.TextColor3 = Color3.fromRGB(175, 175, 185)
    fpsLbl.TextSize = 11
    fpsLbl.Font = Enum.Font.GothamMedium
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Center
    fpsLbl.Parent = statRow

    -- Col 3: Session
    local sessionLbl = Instance.new("TextLabel")
    sessionLbl.Name = "SessionLabel"
    sessionLbl.Size = UDim2.new(0.25, 0, 1, 0)
    sessionLbl.Position = UDim2.new(0.50, 0, 0, 0)
    sessionLbl.BackgroundTransparency = 1
    sessionLbl.Text = "Session: 0m 0s"
    sessionLbl.TextColor3 = Color3.fromRGB(175, 175, 185)
    sessionLbl.TextSize = 11
    sessionLbl.Font = Enum.Font.GothamMedium
    sessionLbl.TextXAlignment = Enum.TextXAlignment.Center
    sessionLbl.Parent = statRow

    -- Col 4: Players
    local playersLbl = Instance.new("TextLabel")
    playersLbl.Name = "PlayersLabel"
    playersLbl.Size = UDim2.new(0.25, 0, 1, 0)
    playersLbl.Position = UDim2.new(0.75, 0, 0, 0)
    playersLbl.BackgroundTransparency = 1
    local curPlayers = #Players:GetPlayers()
    playersLbl.Text = "Players: " .. tostring(curPlayers) .. "/" .. tostring(Players.MaxPlayers > 0 and Players.MaxPlayers or 20)
    playersLbl.TextColor3 = Color3.fromRGB(175, 175, 185)
    playersLbl.TextSize = 11
    playersLbl.Font = Enum.Font.GothamMedium
    playersLbl.TextXAlignment = Enum.TextXAlignment.Right
    playersLbl.Parent = statRow

    -- Background FPS & Server Telemetry Updater
    local uStartTime = os.time()
    local uFrameCount = 0
    local uLastFpsCalc = os.clock()
    local uCurrentFps = 60

    local uFpsConn = RunService.RenderStepped:Connect(function()
        uFrameCount = uFrameCount + 1
        local now = os.clock()
        if now - uLastFpsCalc >= 0.5 then
            uCurrentFps = math.round(uFrameCount / (now - uLastFpsCalc))
            uFrameCount = 0
            uLastFpsCalc = now
        end
    end)

    task.spawn(function()
        while task.wait(1) do
            if not utilCard or not utilCard.Parent then
                if uFpsConn then uFpsConn:Disconnect() end
                break
            end
            local sDiff = os.time() - uStartTime
            local sm = math.floor(sDiff / 60)
            local ss = sDiff % 60
            sessionLbl.Text = string.format("Session: %dm %ds", sm, ss)
            fpsLbl.Text = string.format("FPS: %d", uCurrentFps)
            pcall(function()
                local pingVal = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                pingLbl.Text = string.format("Ping: %d ms", pingVal)
            end)
            local pCount = #Players:GetPlayers()
            local pMax = Players.MaxPlayers > 0 and Players.MaxPlayers or 20
            playersLbl.Text = string.format("Players: %d/%d", pCount, pMax)
        end
    end)

    local btnRow = Instance.new("Frame")
    btnRow.Name = "BtnRow"
    btnRow.Size = UDim2.new(1, -24, 0, 30)
    btnRow.Position = UDim2.new(0, 12, 0, 36)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = utilCard

    local btnRowLayout = Instance.new("UIListLayout")
    btnRowLayout.FillDirection = Enum.FillDirection.Horizontal
    btnRowLayout.Padding = UDim.new(0, 8)
    btnRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    btnRowLayout.Parent = btnRow

    local function createUtilButton(title, order, cb)
        local ub = Instance.new("TextButton")
        ub.Name = title .. "Btn"
        ub.Size = UDim2.new(1/3, -6, 1, 0)
        ub.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        ub.Text = title
        ub.TextColor3 = Color3.fromRGB(230, 230, 235)
        ub.TextSize = 11
        ub.Font = Enum.Font.GothamMedium
        ub.LayoutOrder = order
        ub.Parent = btnRow

        local ubc = Instance.new("UICorner")
        ubc.CornerRadius = UDim.new(0, 8)
        ubc.Parent = ub

        local ubs = Instance.new("UIStroke")
        ubs.Thickness = 1
        ubs.Color = Color3.fromRGB(50, 50, 58)
        ubs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ubs.Parent = ub

        ub.MouseButton1Click:Connect(cb)
        return ub
    end

    createUtilButton("Rejoin Server", 1, function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end)

    createUtilButton("Server Hop", 2, function()
        Window:Notify({
            Title = "Server Hop",
            Description = "Finding a new server...",
            Time = 3
        })
    end)

    createUtilButton("Unload UI", 3, function()
        Window:Destroy()
    end)

    table.insert(SettingsSub.Elements, utilCard)

    -- 2. LAST SUBTAB: "Config" (Exact v32: Automation & Configuration Profile)
    local ConfigSub = SettingsTab:CreateSubTab("Config")
    Window.ConfigSubTab = ConfigSub

    -- Card 1: AUTOMATION (Autoload & Autosave)
    local autoCard = ConfigSub:CreateCard("AUTOMATION")

    autoCard:AddToggle({
        Name = "Autoload Config",
        Default = Window.AutoloadEnabled,
        NoConfig = true,
        Callback = function(state)
            Window.AutoloadEnabled = state
            local cur = loadAppSettings()
            cur.autoload = state
            saveAppSettings(cur)
            Window:Notify({
                Title = "Config",
                Description = "Autoload " .. (state and "Enabled" or "Disabled"),
                Time = 2
            })
        end
    })

    autoCard:AddToggle({
        Name = "Autosave Config",
        Default = Window.AutosaveEnabled,
        NoConfig = true,
        Callback = function(state)
            Window.AutosaveEnabled = state
            local cur = loadAppSettings()
            cur.autosave = state
            saveAppSettings(cur)
            Window:Notify({
                Title = "Config",
                Description = "Autosave " .. (state and "Enabled" or "Disabled"),
                Time = 2
            })
            if state then
                Window:SaveConfig(Window.ActiveConfig)
            end
        end
    })

    -- Card 2: CONFIGURATION PROFILE
    local cfgCard = ConfigSub:CreateCard("CONFIGURATION PROFILE")

    local cfgDropdown
    cfgDropdown = cfgCard:AddDropdown({
        Name = "Select Config",
        Options = getAvailableConfigs(),
        Default = Window.ActiveConfig,
        NoConfig = true,
        Callback = function(c)
            Window.ActiveConfig = c
            local cur = loadAppSettings()
            cur.active = c
            saveAppSettings(cur)
        end
    })

    local enteredConfigName = ""
    cfgCard:AddInput({
        Name = "Config Name",
        Placeholder = "Write config name here.",
        Default = "",
        NoConfig = true,
        Callback = function(name)
            enteredConfigName = name
        end
    })

    cfgCard:AddButton({
        Name = "Create Config",
        Callback = function()
            local cleanName = enteredConfigName:gsub("[%c%p%s]", "_")
            if cleanName == "" then
                Window:Notify({ Title = "Config", Description = "Please enter a valid config name.", Time = 2.5 })
                return
            end
            Window.ActiveConfig = cleanName
            local ok = Window:SaveConfig(cleanName)
            if ok then
                local cur = loadAppSettings()
                cur.active = cleanName
                saveAppSettings(cur)
                if cfgDropdown then
                    cfgDropdown.Refresh(getAvailableConfigs())
                    cfgDropdown.Set(cleanName)
                end
                Window:Notify({ Title = "Config", Description = "Config '" .. cleanName .. "' created!", Time = 2.5 })
            else
                Window:Notify({ Title = "Config", Description = "Failed to create config.", Time = 2.5 })
            end
        end
    })

    cfgCard:AddButton({
        Name = "Save Config",
        Callback = function()
            local target = Window.ActiveConfig or "Default"
            local ok = Window:SaveConfig(target)
            if ok then
                Window:Notify({ Title = "Config", Description = "Config '" .. target .. "' saved!", Time = 2.5 })
            else
                Window:Notify({ Title = "Config", Description = "Failed to save config.", Time = 2.5 })
            end
        end
    })

    cfgCard:AddButton({
        Name = "Load Config",
        Callback = function()
            local target = Window.ActiveConfig or "Default"
            local ok, err = Window:LoadConfig(target)
            if ok then
                Window:Notify({ Title = "Config", Description = "Config '" .. target .. "' loaded!", Time = 2.5 })
            else
                Window:Notify({ Title = "Config", Description = "Failed to load config: " .. tostring(err or "error"), Time = 2.5 })
            end
        end
    })

    cfgCard:AddButton({
        Name = "Delete Config",
        Callback = function()
            local target = Window.ActiveConfig or "Default"
            if target == "Default" then
                Window:Notify({ Title = "Config", Description = "Cannot delete 'Default' profile.", Time = 2.5 })
                return
            end
            pcall(function()
                delfile(CONFIG_DIR .. "/" .. target .. ".json")
            end)
            Window.ActiveConfig = "Default"
            local cur = loadAppSettings()
            cur.active = "Default"
            saveAppSettings(cur)
            if cfgDropdown then
                cfgDropdown.Refresh(getAvailableConfigs())
                cfgDropdown.Set("Default")
            end
            Window:Notify({ Title = "Config", Description = "Config '" .. target .. "' deleted.", Time = 2.5 })
        end
    })

    if Window.AutoloadEnabled then
        task.spawn(function()
            task.wait(0.6)
            if Window.AutoloadEnabled and Window.ActiveConfig then
                local ok = Window:LoadConfig(Window.ActiveConfig)
                if ok then
                    Window:Notify({
                        Title = "Config",
                        Description = "Autoloaded '" .. Window.ActiveConfig .. "'",
                        Time = 3
                    })
                end
            end
        end)
    end

    return Window
end

return IggyLib
