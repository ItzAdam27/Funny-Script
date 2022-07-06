
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

getgenv().tracersEnabled = true
getgenv().guiKey = Enum.KeyCode.LeftControl
getgenv().logKey = Enum.KeyCode.RightAlt

getgenv().espEnabled = false
getgenv().canCast = true
getgenv().canSnap = true
getgenv().ambiance = false
getgenv().chatLog = false
getgenv().trinketEsp = false

local headOff = Vector3.new(0,0.5,0)
local legOff = Vector3.new(0,3,0)

player.CameraMaxZoomDistance = 50000000
player.CameraMinZoomDistance = 0

local gates = {}

for i,v in pairs(workspace.Gates:GetChildren()) do
    if v:IsA("BasePart") then
        gates[v.Name] = v
    end
end

local function getCloseToGates(chr)
    local closestGate = nil
    local dist = nil
    for i,v in pairs(gates) do
        local check = math.abs((chr.HumanoidRootPart.Position-v.Position).Magnitude)
        if check < 500 then
            closestGate = v
            dist = check
        end
    end
    return closestGate, dist
end

local function boxesp(v)
    
    local boxOutline = Drawing.new("Square")
    boxOutline.Visible = false
    boxOutline.Color = Color3.new(0,0,0)
    boxOutline.Thickness = 3
    boxOutline.Transparency = 1
    boxOutline.Filled = false
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1,0,0)
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false
    
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.new(1,1,1)
    nameText.Font = 2
    nameText.Size = 13
    
    local toolText = Drawing.new("Text")
    toolText.Visible = false
    toolText.Center = true
    toolText.Outline = true
    toolText.Color = Color3.new(1,1,1)
    toolText.Font = 2
    toolText.Size = 13
    
    local extraInfoText = Drawing.new("Text")
    extraInfoText.Visible = false
    extraInfoText.Center = true
    extraInfoText.Outline = true
    extraInfoText.Color = Color3.new(1,1,1)
    extraInfoText.Font = 2
    extraInfoText.Size = 13
    
    local healthOutline = Drawing.new("Square")
    healthOutline.Visible = false
    healthOutline.Color = Color3.new(0,0,0)
    healthOutline.Thickness = 3
    healthOutline.Transparency = 1
    healthOutline.Filled = false
    
    local health = Drawing.new("Square")
    health.Visible = false
    health.Color = Color3.new(1,0,0)
    health.Thickness = 1
    health.Transparency = 1
    health.Filled = true
    
    local tracer = Drawing.new("Line")
    tracer.Color = Color3.new(1,1,1)
    tracer.Thickness = 1
    tracer.Transparency = 1
    
    local connection = nil
    
    connection = rs.RenderStepped:Connect(function()
        if getgenv().espEnabled and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v ~= player and v.Character.Humanoid.Health > 0 then
            if not v:FindFirstChild("Data") and not v:FindFirstChild("oName") and not v:FindFirstChild("HouseName") then return end
            local vector, onScreen = camera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)
            
            local boxRoot = v.Character.HumanoidRootPart
            local head = v.Character.Head
            local rootPosition, rootVis = camera:worldToViewportPoint(boxRoot.Position)
            local headPosition = camera:worldToViewportPoint(head.Position+headOff)
            local legPosition = camera:worldToViewportPoint(boxRoot.Position-legOff)
            
            if onScreen then
                if tracersEnabled then
                    tracer.From = Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/1)
                    tracer.To = Vector2.new(vector.X,vector.Y)
                    tracer.Visible = true
                end
                
                boxOutline.Size = Vector2.new(camera.ViewportSize.X/rootPosition.Z,headPosition.Y-legPosition.Y)
                boxOutline.Position = Vector2.new(rootPosition.X - boxOutline.Size.X/2, rootPosition.Y - boxOutline.Size.Y/2)
                boxOutline.Visible = true
            
                box.Size = Vector2.new(camera.ViewportSize.X/rootPosition.Z,headPosition.Y-legPosition.Y)
                box.Position = Vector2.new(rootPosition.X - box.Size.X/2, rootPosition.Y - box.Size.Y/2)
                box.Visible = true
                
                healthOutline.Size = Vector2.new(2,headPosition.Y-legPosition.Y)
                healthOutline.Position = boxOutline.Position - Vector2.new(6,0) --Vector2.new((rootPosition.X-(boxOutline.Size.X+healthOutline.Size.X)), rootPosition.Y - healthOutline.Size.Y/2)
                healthOutline.Visible = true
                
                health.Size = Vector2.new(2,(headPosition.Y-legPosition.Y)*(game:GetService("Players")[v.Character.Name].Character.Humanoid["Health"]/game:GetService("Players")[v.Character.Name].Character.Humanoid["MaxHealth"])) --/ math.clamp(, 0, game:GetService("Players")[v.Character.Name].Character.Humanoid["MaxHealth"]))--Vector2.new(10,headPosition.Y-legPosition.Y*(character.Humanoid.Health/character.Humanoid.MaxHealth))
                health.Position = Vector2.new(box.Position.X-6,box.Position.Y+(1/health.Size.Y))--Vector2.new((rootPosition.X-(box.Size.X+health.Size.X)), rootPosition.Y - health.Size.Y/2)
                health.Color = Color3.fromRGB(255 - 255 / game:GetService("Players")[v.Character.Name].Character.Humanoid["MaxHealth"]/game:GetService("Players")[v.Character.Name].Character.Humanoid["Health"], 255 / game:GetService("Players")[v.Character.Name].Character.Humanoid["MaxHealth"]/game:GetService("Players")[v.Character.Name].Character.Humanoid["Health"], 0)
                health.Visible = true
                
                local text = ""
                
                text = text.."["..math.floor(v.Character.Humanoid.Health+0.5) .. " / "..math.floor(v.Character.Humanoid.MaxHealth+0.5).."]"
                text = text.." "..v.Name .. " | " ..v.Data.oName.Value
                text = text.." ["..math.round(math.abs((v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)+0.5).."]"
                
                local gate,dist = getCloseToGates(v.Character)
                if gate and dist then
                    text = text.." | "..gate.Name.." "..tostring(math.floor(dist+0.5))
                    nameText.Color = Color3.new(1,0,0)
                else
                    nameText.Color = Color3.new(1,1,1)
                end
                
                if v.Character.Torso.Middle.Gate.Enabled then
                    nameText.Color = Color3.new(0,0,1)
                end
                
                --nameText.Size = camera.ViewportSize.X/rootPosition.Z
                nameText.Position = Vector2.new(rootPosition.X-nameText.Size/2,rootPosition.Y-box.Position.Y/4+13)
                nameText.Text = text
                nameText.Visible = true
                
                local extraText = ""
                extraText = extraText.."["..v.Data.Artifact.Value.." |"
                extraText = extraText.." "..v.Data.Race.Value.." |"
                extraText = extraText.." "..v.Data.Class.Value.."]"
                
                extraInfoText.Position = nameText.Position + Vector2.new(0,13)
                extraInfoText.Text = extraText
                extraInfoText.Visible = true
                
                local findTool = v.Character:FindFirstChildWhichIsA("Tool")
                if findTool then
                    findTool = findTool.Name
                end
                
                toolText.Position = nameText.Position - Vector2.new(0,toolText.Size)
                toolText.Text =  findTool or "No Tool"
                toolText.Text = "["..toolText.Text.."]"
                toolText.Visible = true
            
            else
                boxOutline.Visible = false
                box.Visible = false
                healthOutline.Visible = false
                health.Visible = false
                nameText.Visible = false
                toolText.Visible = false
                extraInfoText.Visible = false
                tracer.Visible = false
            end
        else
            boxOutline.Visible = false
            box.Visible = false
            healthOutline.Visible = false
            health.Visible = false
            nameText.Visible = false
            toolText.Visible = false
            extraInfoText.Visible = false
            tracer.Visible = false
            if not v.Character then boxOutline:Remove() box:Remove() nameText:Remove() toolText:Remove() extraInfoText:Remove() healthOutline:Remove() health:Remove() tracer:Remove() connection:Disconnect() return end
        end
    end)    
end

local function trinketEspFunc(v)
    
    local trinketText = Drawing.new("Text")
    trinketText.Visible = false
    trinketText.Center = true
    trinketText.Outline = true
    trinketText.Color = Color3.new(1,1,1)
    trinketText.Font = 2
    trinketText.Size = 13
    
    local trinket = v:FindFirstChildWhichIsA("BasePart")
    
    local connection
    
    connection = rs.RenderStepped:Connect(function()
        if trinketEsp and workspace.MouseIgnore:FindFirstChild(v.Name) then
            local vector, onScreen = camera:worldToViewportPoint(trinket.Position)
            
            if onScreen then
                trinketText.Position = Vector2.new(vector.X,vector.Y)
                trinketText.Text = trinket.Name.. " ["..math.floor(math.abs((hrp.Position-trinket.Position).Magnitude)+0.5).."]"
                trinketText.Visible = true
            else
                trinketText.Visible = false
            end
        else
            trinketText.Visible = false
            if not workspace.MouseIgnore:FindFirstChild(v.Name) then trinketText:Remove() connection:Disconnect() return end
        end
    end)
end

local function chatLogFunc(v)
    v.Chatted:Connect(function(msg)
        if chatLog then
            if string.find(msg,"/") then
                rconsoleprint("@@RED@@")
                rconsoleinfo(v.Name..": "..msg)
            else
                rconsoleprint("@@WHITE@@")
                rconsoleinfo(v.Name..": "..msg)
            end
        end
    end)
end

for i,v in pairs(game:GetService("Players"):GetPlayers()) do
    coroutine.wrap(boxesp)(v)
    coroutine.wrap(chatLogFunc)(v)
end

game:GetService("Players").PlayerAdded:Connect(function(v)
    repeat
        wait()
    until v.Character:IsADescendantOf(workspace.Alive)
    coroutine.wrap(boxesp)(v)
    coroutine.wrap(chatLogFunc)(v)
end)

local part1 = nil
local part2 = nil

local function createPart()
    
    local yAngle = nil
    local xOffset = nil
    if part1 then
        yAngle = 15
        xOffset = 4
    else
        yAngle = -15
        xOffset = -4
    end
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(4,5,1)
    part.CanCollide = false
    part.Anchored = false
    part.Massless = true
    part.Transparency = 1
    
    local motor6D = Instance.new("Motor6D")
    motor6D.Parent = part
    motor6D.Part0 = hrp
    motor6D.Part1 = part
    motor6D.C0 = part.CFrame * CFrame.new(xOffset,0,-5)
    motor6D.C1 = CFrame.Angles(math.rad(45),math.rad(yAngle),math.rad(0))
    
    part.Parent = workspace
    
    return part
    
end

local function createGui(part)
    
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Parent = part
    surfaceGui.Face = Enum.NormalId.Back
    local backgroundFrame = Instance.new("Frame")
    backgroundFrame.Name = "BackgroundFrame"
    backgroundFrame.Size = UDim2.fromScale(1,1)
    backgroundFrame.BackgroundColor3 = Color3.fromHex("C77DFF")
    backgroundFrame.Transparency = 0.75
    backgroundFrame.BorderSizePixel = 0
    backgroundFrame.Parent = surfaceGui
    
    local uiLayout = Instance.new("UIListLayout")
    uiLayout.Padding = UDim.new(0.05,0)
    uiLayout.HorizontalAlignment = "Center"
    uiLayout.VerticalAlignment = "Center"
    uiLayout.SortOrder = "LayoutOrder"
    uiLayout.Parent = backgroundFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(0.9,0.15)
    button.BackgroundColor3 = Color3.fromHex("240046")
    button.TextColor3 = Color3.fromHex("E0AAFF")
    button.TextStrokeColor3 = Color3.fromHex("10002B")
    button.TextStrokeTransparency = 0
    button.TextScaled = true
    button.RichText = true
    button.Font = Enum.Font.Roboto
    button.Text = "<b>Button1</b>"
    button.BackgroundTransparency = 0.15
    button.LayoutOrder = 1
    button.Name = "Button1"
    button.Parent = backgroundFrame
    
    for i = 1,4 do
        
        local clone = button:Clone()
        clone.Name = "Button".. i+1
        clone.Text = "<b>"..clone.Name.."</b>"
        clone.LayoutOrder = i+1
        clone.Parent = backgroundFrame
        
    end    
    
end

for i,v in pairs(workspace.MouseIgnore:GetChildren()) do
    if v:IsA("Model") then
        coroutine.wrap(trinketEspFunc)(v)
    end
end

workspace.MouseIgnore.ChildAdded:Connect(function(added)
    if added:IsA("Model") then
        coroutine.wrap(trinketEspFunc)(added)
    end
end)

local function changeGuiVisiblity()
    part1.SurfaceGui.Enabled = not part1.SurfaceGui.Enabled
    part2.SurfaceGui.Enabled = not part2.SurfaceGui.Enabled
end

local function espButtonFunc()
    getgenv().espEnabled = not getgenv().espEnabled
end

local function chatLogButtonFunc()
    chatLog = not chatLog
end

local spells = {
    ["Ignis"] = {100,80,60,50},
    ["Gelidus"] = {100,85},
    ["Viribus"] = {35,5,70,60},
    ["Telorum"] = {90,80},
    ["Velo"] = {100,0,65,45},
    ["Catena"] = {70,20,60,45},
    ["Gate"] = {1,0,80,70},
    ["Snarvindur"] = {60,50,35,10},
    ["Percutiens"] = {75,55,75,55},
    ["Fimbulvetr"] = {95,60},
    
}

local manaOverlay = Drawing.new("Image")
manaOverlay.Data = game:HttpGet("https://i.imgur.com/HHyosGU.png")
manaOverlay.Position = Vector2.new(15,camera.ViewportSize.Y/2)
manaOverlay.Size = Vector2.new(165,346)

local manaText = Drawing.new("Text")
manaText.Center = true
manaText.Outline = true
manaText.Color = Color3.new(1,1,1)
manaText.Font = 2
manaText.Size = 13
manaText.Position = manaOverlay.Position + Vector2.new(manaOverlay.Size.X,manaOverlay.Size.Y/2)

local spellOverlay = Drawing.new("Square")
spellOverlay.Color = Color3.new(1,0,0)
spellOverlay.Thickness = 1
spellOverlay.Transparency = 0.5
spellOverlay.Filled = true

local snapOverlay = Drawing.new("Square")
snapOverlay.Color = Color3.new(0,0,1)
snapOverlay.Thickness = 1
snapOverlay.Transparency = 0.5
snapOverlay.Filled = true

local function updateMana()
    rs.RenderStepped:Connect(function()
        if character:FindFirstChild("Stats") and character.Stats:FindFirstChild("Mana") then
            local mana = character.Stats.Mana.Value
            manaText.Text = tostring(math.round(mana+0.5)).."%"
            local tool = character:FindFirstChildWhichIsA("Tool")
            if tool and spells[tool.Name] and mana then
                if spells[tool.Name][1] > mana and spells[tool.Name][2] < mana then
                    canCast = true
                else
                    canCast = false
                end
                if spells[tool.Name][3] then
                    if spells[tool.Name][3] > mana and spells[tool.Name][4] < mana then
                        canSnap = true
                    else
                        canSnap = false
                    end
                end
            else
                canCast = false
                canSnap = false
            end
        end
    end)
end

coroutine.wrap(updateMana)()

local lighting = game:GetService("Lighting")
local prevAmbiance = Color3.fromRGB(125,125,100)
local function destroyAmbianceFunc()
    if ambiance then
        lighting.FogEnd = 1000000
        lighting.GlobalShadows = true
        lighting.Ambient = Color3.new(1,1,1)
        for i,v in pairs(lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
    else
        if lighting.Ambient == Color3.new(1,1,1) then
            lighting.Ambient (125,125,100)
        end
    end
end

lighting:GetPropertyChangedSignal("FogEnd"):Connect(destroyAmbianceFunc)

local function overlayButtonFunc()
    manaOverlay.Visible = not manaOverlay.Visible
    manaText.Visible = not manaText.Visible
    spellOverlay.Visible = not spellOverlay.Visible
    snapOverlay.Visible = not snapOverlay.Visible
end

local function ambianceButtonFunc()
    ambiance = not ambiance
    if ambiance then
        destroyAmbianceFunc()
    end
end

local function trinketEspButtonFunc()
    trinketEsp = not trinketEsp
end

uis.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode == guiKey then
        changeGuiVisiblity()
    elseif input.KeyCode == logKey then
        player:Kick("Instant Logged")
    end
end)

getgenv().hasSpellEquipped = false

character.ChildAdded:Connect(function(added)
    if spells[added.Name] then
        hasSpellEquipped = true
        spellOverlay.Size = Vector2.new(28,manaOverlay.Size.Y*((spells[added.Name][1]-spells[added.Name][2])/100))
        spellOverlay.Position = Vector2.new(manaOverlay.Position.X+7,((manaOverlay.Position.Y+manaOverlay.Size.Y)-(manaOverlay.Size.Y*(spells[added.Name][1]/100))))
        if spells[added.Name][3] then
            snapOverlay.Size = Vector2.new(28,manaOverlay.Size.Y*((spells[added.Name][3]-spells[added.Name][4])/100))
            snapOverlay.Position = Vector2.new(manaOverlay.Position.X+7,((manaOverlay.Position.Y+manaOverlay.Size.Y)-(manaOverlay.Size.Y*(spells[added.Name][3]/100))))
        end
    end
end)

character.ChildRemoved:Connect(function(removed)
    if spells[removed.Name] then
        hasSpellEquipped = false
        spellOverlay.Size = Vector2.new(0,0)
        snapOverlay.Size = Vector2.new(0,0)
    end
end)

local mt = getrawmetatable(game)
local namecall = mt.__namecall
setreadonly(mt,false)
mt.__namecall = newcclosure(function(self,...) -- self ( the instance )  and args 

    if getnamecallmethod() == 'FireServer' and tostring(self) == 'M1' then -- checking if we're firing a remote
        if not canCast and hasSpellEquipped and manaOverlay.Visible then
            print(canCast,hasSpellEquipped,manaOverlay.Visible)
            return
        end
    end
    if getnamecallmethod() == 'FireServer' and tostring(self) == 'M2' then -- checking if we're firing a remote
        if not canSnap and hasSpellEquipped and manaOverlay.Visible then
            return
        end
    end
    return namecall(self,...)
end)
setreadonly(mt,true)

part1 = createPart()
part2 = createPart()
createGui(part1)
createGui(part2)

local espButton = part2.SurfaceGui.BackgroundFrame.Button1
local overlayButton = part1.SurfaceGui.BackgroundFrame.Button1
local ambianceButton = part1.SurfaceGui.BackgroundFrame.Button2
local chatLogButton = part2.SurfaceGui.BackgroundFrame.Button2
local trinketEspButton = part1.SurfaceGui.BackgroundFrame.Button3

espButton.Name = "EspButton"
espButton.Text = "<b>Esp Toggle</b>"
espButton.Activated:Connect(espButtonFunc)
overlayButton.Name = "OverlayButton"
overlayButton.Text = "<b>Toggle Overlay</b>"
overlayButton.Activated:Connect(overlayButtonFunc)
ambianceButton.Name = "AmbianceButton"
ambianceButton.Text = "<b>Ambiance</b>"
ambianceButton.Activated:Connect(ambianceButtonFunc)
chatLogButton.Name = "ChatLog"
chatLogButton.Text = "<b>Chat Log</b>"
chatLogButton.Activated:Connect(chatLogButtonFunc)
trinketEspButton.Name = "TrinketEsp"
trinketEspButton.Text = "<b>Trinket Esp</b>"
trinketEspButton.Activated:Connect(trinketEspButtonFunc)
