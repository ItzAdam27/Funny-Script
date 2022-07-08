local rs = game:GetService("RunService")
local unitData = require(game:GetService("ReplicatedStorage"):WaitForChild("src"):WaitForChild("Data"):WaitForChild("Units"))

local player = game.Players.LocalPlayer
local stats = player:WaitForChild("_stats")

game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
   if State == Enum.TeleportState.Started then
       syn.queue_on_teleport('loadstring(game:HttpGet(("https://raw.githubusercontent.com/ItzAdam27/Funny-Script/main/AnimeAdventures.lua"),true))()')
   end
end)

local unitAttributes = {
    ["Luffo"] = "Ground",
    ["Orwin"] = "Hybrid","Summon",
    ["Bakujo"] = "Ground",
    ["Usoap"] = "Hill",
    ["Underhaul"] = "Ground",
}

if workspace:WaitForChild("_MAP_CONFIG"):WaitForChild("IsLobby").Value then
    
    local txt = ""
    task.wait(5)
    
    for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("collection"):WaitForChild("grid"):WaitForChild("List"):WaitForChild("Outer"):WaitForChild("UnitFrames"):GetChildren()) do
        if v:IsA("ImageButton") then
            if v.Equipped.Visible then
                txt = txt..v["_uuid"].Value.." = "..v.name.Text..","
            end
        end
    end
    
    writefile("EquippedUnits.txt",txt)
    
    local found = false
    for i,v in pairs(game:GetService("Workspace"):WaitForChild("_LOBBIES"):WaitForChild("Story"):GetChildren()) do
        if v.Owner.Value == nil then
            if not found then
                found = true
                game:GetService("ReplicatedStorage"):WaitForChild("endpoints"):WaitForChild("client_to_server"):WaitForChild("request_join_lobby"):InvokeServer(v.Name)
                local args = {
                    [1] = v.Name,
                    [2] = "namek_level_1",
                    [3] = false,
                    [4] = "Normal"
                }
                game:GetService("ReplicatedStorage").endpoints.client_to_server:WaitForChild("request_lock_level"):InvokeServer(unpack(args))
                game:GetService("ReplicatedStorage").endpoints.client_to_server:WaitForChild("request_start_game"):InvokeServer(v.Name)
            end
        end
    end

elseif not workspace["_MAP_CONFIG"].IsLobby.Value then
 
    local fileExists = isfile("EquippedUnits.txt")
    if not fileExists then game.Players.LocalPlayer:Kick("Couldn't get equipped units, check your antivirus.") end
    local equippedUnits = readfile("EquippedUnits.txt")
    local unitTbl = {}
    for i,v in pairs(string.split(equippedUnits,",")) do
        table.insert(unitTbl,v)
    end
    
    local uuidToName = {}
    local unitAmounts = {}
    for i,v in pairs(unitTbl) do
        local split = string.split(v," = ")
        if split[1] == nil or split[2] == nil then continue end
        uuidToName[split[1]] = split[2]
        unitAmounts[split[1]] = 0
    end
    
    local equippedData = {}
    local unitCap = {}
    
    for i,v in pairs(unitData) do
        for i2,v2 in pairs(v) do
            for i3,v3 in pairs(uuidToName) do
                if v2 == v3 then
                    equippedData[v3] = v
                    unitCap[i3] = equippedData[v3].spawn_cap
                end
            end
        end
    end
    game:GetService("ReplicatedStorage"):WaitForChild("endpoints")
    local spawnRemote = game:GetService("ReplicatedStorage").endpoints:WaitForChild("client_to_server"):WaitForChild("spawn_unit")
    local upgradeRemote = game:GetService("ReplicatedStorage").endpoints.client_to_server:WaitForChild("upgrade_unit_ingame")
    
    local function handleUnits(uuid,id)
        
        local cframe = CFrame.new(-2947.876708984375, 91.80620574951172, -699.498046875) * CFrame.Angles(0, -0, -0)
        local units = {}
        local totalUnits = tonumber(equippedData[id].spawn_cap)
        
        rs.RenderStepped:Connect(function()
            if stats.resource.Value >= tonumber(equippedData[id].cost) and #units < totalUnits then
                    
                local shouldSpawn = true
                for i,v in pairs(unitAmounts) do
                    if i == uuid then continue end
                  print(type(v)) print(type(unitAmounts[uuid]))
                    if v < unitAmounts[uuid] and not unitCap[i] > v then
                        shouldSpawn = false
                    end
                end
                    
                if shouldSpawn then spawnRemote:InvokeServer(uuid,cframe) end
                task.wait(0.25)
                
                
                
                for i,v in pairs(workspace["_UNITS"]:GetChildren()) do
                    if v:IsA("Model") and v.Name == equippedData[id].id and not table.find(units,v) then
                        amount = unitAmounts[uuid]
                        unitAmounts[uuid] = amount+1
                        table.insert(units,v)
                    end
                end
            end
            for i,v in pairs(units) do
                local unitStats = v["_stats"]
                if not equippedData[id].upgrade[unitStats.upgrade.Value+1] then continue end
                if tonumber(equippedData[id].upgrade[unitStats.upgrade.Value+1].cost) <= stats.resource.Value then
                    upgradeRemote:InvokeServer(v)
                end
            end
        end)
    end
    
    local function automation()
        game:GetService("ReplicatedStorage").endpoints.client_to_server:WaitForChild("vote_wave_skip")
        while wait(5) do
            game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_wave_skip:InvokeServer()
        end
    end
    
    game:GetService("Workspace")["_DATA"].GameFinished.Changed:Connect(function()
        task.wait(1)
        game:GetService("ReplicatedStorage").endpoints["client_to_server"]["teleport_back_to_lobby"]:InvokeServer()
    end)
    
    game:GetService("Workspace")["_DATA"].VoteStart.StartTime.Changed:Connect(function()
        game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
    end)
    
    coroutine.wrap(automation)()
    
    for i,v in pairs(uuidToName) do
        coroutine.wrap(handleUnits)(i,v)
    end

end
