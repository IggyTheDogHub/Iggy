--[[
    ========================================================================
    IGGY HUB — OFFICIAL LOADER (v32 Architecture + Junkie Key System)
    - Powered by Junkie (jnkie.com)
    - Service: IGGY HUB (Identifier: 1203818, Provider: Iggy)
    - Auto-detects & verifies saved key (IggyKey.txt)
    - Shows authentic v32 KeySystemUI modal if key is missing/invalid
    - Seamlessly launches main script upon successful authentication
    ========================================================================
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(1)

if getgenv and getgenv()._IGGY_LOADER_RUNNING then
    return
end
if getgenv then
    getgenv()._IGGY_LOADER_RUNNING = true
end

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gethui = gethui or function() return CoreGui end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local isfile = isfile or function() return false end
local setclipboard = setclipboard or toclipboard or function(txt) end

-------------------------------------------------------------------------------
-- JUNKIE AUTHENTICATION SDK SETUP
-------------------------------------------------------------------------------
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "IGGY HUB"
Junkie.identifier = "1203818"
Junkie.provider = "Iggy"

local KEY_FILE = "IggyKey.txt"

-- Verify key with Junkie
local function verifyJunkieKey(key)
    if not key or key == "" then
        return false, "Key cannot be empty."
    end
    
    local ok, res = pcall(function()
        return Junkie.check_key(key)
    end)

    if ok and typeof(res) == "table" then
        if res.valid == true then
            return true, "Key valid."
        else
            return false, res.error or "Invalid or expired key."
        end
    end

    return false, "Failed to connect to authentication server."
end

-- Get checkpoint / key link from Junkie
local function getCheckpointLink()
    local ok, link = pcall(function()
        return Junkie.get_key_link()
    end)
    if ok and link and link ~= "" then
        return true, link
    end
    return false, link or "Failed to connect to authentication server."
end

-------------------------------------------------------------------------------
-- SCRIPT LAUNCHER (Executes IggyHub script when authenticated)
-------------------------------------------------------------------------------
local function launchScript()
    if getgenv then
        getgenv()._IGGY_LOADER_RUNNING = nil
    end

    -- Run the game script / example script
    local ran = false
    pcall(function()
        if isfile and isfile("Example_Script.lua") then
            loadstring(readfile("Example_Script.lua"))()
            ran = true
        end
    end)

    if not ran then
        -- Default fallback template using cloud IggyLib
        local Iggy = loadstring(game:HttpGet("https://raw.githubusercontent.com/IggyTheDogHub/Iggy/refs/heads/main/IggyLib.lua"))()
        local Window = Iggy:CreateWindow({
            Title = "IggyHub",
            SubTitle = "v1.0",
            Size = UDim2.new(0, 720, 0, 460),
            ToggleKey = Enum.KeyCode.RightControl
        })
        Iggy:Notify({
            Title = "Iggy Hub",
            Description = "Authenticated with Junkie!",
            Time = 4
        })
    end
end

-------------------------------------------------------------------------------
-- STEP 1: CHECK FOR SAVED KEY (SILENT LOGIN)
-------------------------------------------------------------------------------
local savedKey = ""
local hasSavedKey = false

pcall(function()
    if isfile and isfile(KEY_FILE) then
        local content = readfile(KEY_FILE)
        if content and content:gsub("%s+", "") ~= "" then
            savedKey = content:gsub("%s+", "")
            hasSavedKey = true
        end
    end
end)

if hasSavedKey then
    local isValid = verifyJunkieKey(savedKey)
    if isValid then
        -- Saved key is valid! Skip UI and launch immediately
        launchScript()
        return
    end
end

-------------------------------------------------------------------------------
-- STEP 2: SHOW IGGY KEY SYSTEM UI
-------------------------------------------------------------------------------
local KeySystemUI = nil
local okLoadUI, uiModule = pcall(function()
    if isfile and isfile("KeySystemUI.lua") then
        return loadstring(readfile("KeySystemUI.lua"))()
    end
    -- Fallback to GitHub if local file doesn't exist
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/IggyTheDogHub/Iggy/refs/heads/main/KeySystemUI.lua"))()
end)

if okLoadUI and uiModule then
    KeySystemUI = uiModule
else
    error("[IggyHub Loader] Could not load KeySystemUI")
end

KeySystemUI:Create({
    Title = "IggyHub",
    Subtitle = "KEY SYSTEM",
    DiscordLink = "https://discord.gg/6UBrrVchnh",
    OnGetKey = function(statusMsg)
        statusMsg.TextColor3 = Color3.fromRGB(245, 245, 250)
        statusMsg.Text = "Generating checkpoint link..."
        task.spawn(function()
            local success, link = getCheckpointLink()
            if success and link then
                setclipboard(link)
                statusMsg.TextColor3 = Color3.fromRGB(100, 240, 140)
                statusMsg.Text = "Checkpoint link copied to clipboard!"
            else
                statusMsg.TextColor3 = Color3.fromRGB(255, 100, 100)
                statusMsg.Text = link or "Failed to get link. Please try again."
            end
        end)
    end,
    OnSubmit = function(key)
        local valid, msg = verifyJunkieKey(key)
        if valid then
            pcall(function()
                writefile(KEY_FILE, key)
            end)
            task.spawn(function()
                task.wait(0.5)
                launchScript()
            end)
            return true, "Key validated! Loading IggyHub..."
        else
            return false, msg or "Invalid or expired key."
        end
    end,
    OnClose = function()
        if getgenv then
            getgenv()._IGGY_LOADER_RUNNING = nil
        end
    end
})
