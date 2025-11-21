--!strict

local ConveyorTrack = require(script:WaitForChild("ConveyorTrack"))

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnBagRemote = ReplicatedStorage.Remotes.SpawnBag
local endParts = ConveyorTrack:Construct()

local designatedPlayer: Player?
game.Players.PlayerAdded:Once(function(player: Player)
    designatedPlayer = player
    local SliderGui = player:WaitForChild("PlayerGui"):WaitForChild("SliderGui")::ScreenGui
    SliderGui.Enabled = true
end)

ReplicatedStorage.Remotes.BagClicked.OnServerEvent:Connect(function(player: Player, partName: string)
    
    print(partName)

end)

local waitTime = 1
ReplicatedStorage.Remotes.ChangeRate.OnServerEvent:Connect(function(player: Player, wait: number)
    if player == designatedPlayer then
        waitTime = math.clamp(wait, 1, 3)
    end
end)

while true do
    local materials = Enum.Material:GetEnumItems()
    local randomMaterial = materials[math.random(1, #materials)]
    local randomColor = Color3.fromHSV(math.random(0,359)/360, 0.7, 0.8)

    SpawnBagRemote:FireAllClients(HttpService:GenerateGUID(), randomMaterial, randomColor, endParts.start.CFrame)

    task.wait(waitTime)
end