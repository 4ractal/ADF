--------------settings--------------

getgenv().autofarm = autofarm or true
getgenv().unitslot = unitslot or "One"                    
getgenv().maxunits = maxunits or 3                       
getgenv().startplacingunitsWave = startplacingunitsWave or 4           
getgenv().unitplacedelay = unitplacedelay or 5               
getgenv().checkForResultsDelay = checkForResultsDelay or 3       
getgenv().leaveatwave = leaveatwave or 999                 
getgenv().friendsonly = friendsonly or false                 
getgenv().mission = mission or "FooshaVillage_Infinite"   
getgenv().normalorhard = normalorhard or "Hard"            
getgenv().antiafk = antiafk or true                     
getgenv().dontrender = dontrender or false                    
getgenv().webhook = webhook or nil

--------------important paths------------------------

repeat task.wait() until game:IsLoaded()

local vim = game:GetService('VirtualInputManager')
local moduleScript = game:GetService("ReplicatedStorage").Actions
local actionRemote = moduleScript.Action
local encryptedRemotes = {}

local lp = game:GetService('Players').LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local lpgui = lp.PlayerGui
local guipages = lpgui:WaitForChild('PAGES')
local http = game:GetService("HttpService")

local placeId = game.PlaceId
local lobbyId = 17017769292
local serverIds = {
    17018663967,                                                                --windmill village
}

----------------modulescript decompiler---------------

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

-----------remote arg tables--------------------------

local gameSettingsArgs = {
    [1] = encryptedRemotes['CHANGE_MATCH_DATA']['name'],		                --locks in game settings
    [2] = {
        ["Chapter"] = mission,		                                            --FooshaVillage_Chapter1, FooshaVillage_Infinite
        ["FriendsOnly"] = friendsonly,
        ["Difficulty"] = normalorhard
    }
}

local startServerTeleportArgs = {
    [1] = encryptedRemotes['START_MATCH']['name']		                        --starts teleport to game server
}

local leaveGameServerArgs = {
    [1] = encryptedRemotes['GAME_MODE_SELECTED_CTS']['name'],                   --returns to main lobby (from match results button not the other remote)
    [2] = "NormalLobby"
}

-----------------main loop-----------------------------

if autofarm then
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
    
    if placeId == lobbyId then                                                  --if place is main lobby
        local detector = Vector3.new(-189.03, 16.74, -316.26)
            
        --auto quest claim code goes here

        repeat 
            char:FindFirstChild('HumanoidRootPart').Position = detector
            task.wait(0.5)
        until guipages.MatchPage.Visible

        actionRemote:FireServer(unpack(gameSettingsArgs))

        repeat
            task.wait(1)
        until (lpgui.HUD.MatchDisplayHolder.MatchDisplayFrame:FindFirstChild("FF_MACHINE") and lpgui.HUD.MatchDisplayHolder.MatchDisplayFrame:FindFirstChild("animeIaststandFAN500") and lpgui.HUD.MatchDisplayHolder.MatchDisplayFrame:FindFirstChild("animeadventursIover"))                                                        --allow everyone to join lobby

        actionRemote:FireServer(unpack(startServerTeleportArgs))

        if webhook then
            local matchteleporting = {
                content = nil,
                embeds = { {
                  title = "Attempting Match Teleport...",
                  color = math.random(1, 16777214),
                  fields = { {
                    name = "Current Gems:",
                    value = lpgui.HUD.Toolbar.CurrencyList.Gems.TextLabel.Text,
                    inline = true
                  }, {
                    name = "Quests to Claim:",
                    value = "W.I.P.",
                    inline = true
                  } },
                  footer = {
                    text = string.format("Logged: %s (UTC)", DateTime.now():FormatUniversalTime("LTS", "en-us"))
                  }
                } },
                username = "gems machine",
                avatar_url = "https://img.freepik.com/premium-photo/pile-colorful-gemstones-with-word-diamond-bottom_836919-2575.jpg",
                attachments = { }
            }

            firehook(matchteleporting)
        end
    elseif table.find(serverIds, placeId) then                                  --else if place is in the whitelisted table of ids
        local startingcoords
        
        if placeId == serverIds[1] then
            startingcoords = -1675.47
        end 

        task.spawn(function()
            while true do
                if guipages.MatchResultPage.Visible then
                    actionRemote:FireServer(unpack(leaveGameServerArgs))
                    if webhook then
                        local finishmatch = {
                            content = nil,
                            embeds = { {
                                title = "Match Finished!",
                                color = math.random(1, 16777214),
                                fields = { {
                                name = "No. of Players:",
                                value = tostring(#game:GetService("Players"):GetPlayers()),
                                inline = true
                                }, {
                                name = "Waves Completed:",
                                value = lpgui.WaveTopBar.Wave.WaveFrame.TextLabel.Text,
                                inline = true
                                }, {
                                name = "Time Taken:",
                                value = guipages.MatchResultPage.Main.Statistics.Time.CategoryStat.Text,
                                inline = true
                                } },
                                footer = {
                                text = string.format("Logged: %s (UTC)", DateTime.now():FormatUniversalTime("LTS", "en-us"))
                                }
                            } },
                            username = "gems machine",
                            avatar_url = "https://img.freepik.com/premium-photo/pile-colorful-gemstones-with-word-diamond-bottom_836919-2575.jpg",
                            attachments = { }
                        }

                        firehook(finishmatch)
                    end
                    break
                end
                task.wait(checkForResultsDelay)
            end
        end)

        repeat
            task.wait(1) 
        until tonumber(lpgui:FindFirstChild('WaveTopBar').Wave.WaveFrame.TextLabel.Text) >= startplacingunitsWave 

        task.wait(5)            --buffer to allow us to collect the current wave's money

        local cam = workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Scriptable

        for i = 1, maxunits, 1 do
            cam.CFrame = CFrame.new((startingcoords - i*10), 30, -540.5, 0, 1, 0, 0, 0, 1, 1, 0, 0)
            
            task.wait(1)

            vim:SendKeyEvent(true, Enum.KeyCode[unitslot],false,nil)
            task.wait()
            vim:SendKeyEvent(false, Enum.KeyCode[unitslot],false,nil)
    
            task.wait(1)
            
            vim:SendMouseButtonEvent(0.5, 0.5, 0, true, nil, 1)
            task.wait()
            vim:SendMouseButtonEvent(0.5, 0.5, 0, false, nil, 1)
            task.wait()
            vim:SendMouseButtonEvent(0.5, 0.5, 0, true, nil, 1)
            task.wait()
            vim:SendMouseButtonEvent(0.5, 0.5, 0, false, nil, 1)
            task.wait(unitplacedelay)
        end  
    end
end
