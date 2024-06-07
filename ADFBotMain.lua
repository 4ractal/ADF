
--------------settings--------------

getgenv().botfarmenabled = botfarmenabled or true         
getgenv().antiafk = antiafk or true                   
getgenv().checkForResultsDelay = checkForResultsDelay or 5          
getgenv().dontrender = dontrender or true
getgenv().webhook = webhook or nil

----------------------------------

repeat task.wait() until game:IsLoaded()

local moduleScript = game:GetService("ReplicatedStorage").Actions
local actionRemote = moduleScript.Action
local encryptedRemotes = {}

local lp = game:GetService('Players').LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local lpgui = lp.PlayerGui
local guipages = lpgui:WaitForChild('PAGES')

local placeId = game.PlaceId
local lobbyId = 17017769292
local serverIds = {
    17018663967,                                                                --windmill village
}

------------------------------------

local success, scriptContent = pcall(require, moduleScript)                     --decompiles the Actions modulescript which contains every encrypted remote name
if success then
    encryptedRemotes = scriptContent
--[[
else
    warn("Failed to require ModuleScript:", script:GetFullName())
    (DO NOT EXECUTE THIS LINE ABOVE, PRINT'S TRIP ANTICHEAT?)
]]--
end

---------------------webhook stuff----------------------

local function firehook(themessage)
    local success, response = pcall(function()
        return request({
            Url = webhook,
            Body = http:JSONEncode(themessage),
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
        })
    end)
end

local teleportedout = {
    content = nil,
    embeds = { {
      title = "Error!",
      description = lp.Name .. " disconnected and requested to teleport back to lobby.",
      color = math.random(1, 16777214),
      footer = {
        text = string.format("Logged: %s (UTC)", DateTime.now():FormatUniversalTime("LTS", "en-us"))
      }
    } },
    attachments = { }
}

------------------------------------

local leaveGameServerArgs = {
    [1] = encryptedRemotes['GAME_MODE_SELECTED_CTS']['name'],                   --returns to main lobby (from match results button not the other remote)
    [2] = "NormalLobby"
}

------------------------------------

if botfarmenabled then
    if dontrender then
        task.spawn(function()
            task.wait(1)
            game:GetService('RunService'):Set3dRenderingEnabled(false)          --turns off rendering
            --game:GetService('RunService'):Set3dRenderingEnabled(true)
        end)
    end

    if antiafk then
        task.spawn(function()
            local GC = getconnections or get_signal_cons
            if GC then
                for i,v in pairs(GC(lp.Idled)) do
                    if v["Disable"] then
                        v["Disable"](v)
                    elseif v["Disconnect"] then
                        v["Disconnect"](v)
                    end
                end
            else
                local VirtualUser = cloneref(game:GetService("VirtualUser"))
                lp.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
    end
    
    if placeId == lobbyId then 
        local detector = Vector3.new(-189.03, 16.74, -316.26)
        
        repeat 
            task.wait(1)
        until lpgui.UI.GUIs:FindFirstChild('p0wley', true)
       
        task.spawn(function()
            while true do
                char:FindFirstChild('HumanoidRootPart').Position = detector + Vector3.new(math.random(-2,2),math.random(-2,2),math.random(-2,2))
                task.wait(1)
            end
        end)
        
    elseif table.find(serverIds, placeId) then                                  --else if place is in the whitelisted table of ids
        if placeId == serverIds[1] then
            char:FindFirstChild('HumanoidRootPart').Position = Vector3.new(-1660, 30, -530)
            task.wait()
            char:FindFirstChild('HumanoidRootPart').Position = Vector3.new(-1660, 30, -530)
        end
        
        task.wait(3)

        if not lpgui:FindFirstChild('PAGES') then
            if webhook then
                firehook(teleportedout)
            end
            game:GetService('TeleportService'):Teleport(17017769292)
        end

        workspace.CurrentCamera.CFrame = CFrame.Angles(-math.rad(90), 0, 0)
        lp.CameraMaxZoomDistance = math.huge
        lp.CameraMinZoomDistance = math.huge

        task.spawn(function()
            while true do
                if guipages.MatchResultPage.Visible then
                    actionRemote:FireServer(unpack(leaveGameServerArgs))
                    break
                end
                task.wait(checkForResultsDelay)
            end
        end)
    end
end