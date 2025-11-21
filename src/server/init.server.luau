--!strict

local ConveyorTrack = require(script:WaitForChild("ConveyorTrack"))

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnBagRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpawnBag")
local endParts = ConveyorTrack:Construct()

endParts.ending.Touched:Connect(function(touchedPart)
    if touchedPart:HasTag("Bag") then
        touchedPart:Destroy()
    end
end)

while true do
    local materials = Enum.Material:GetEnumItems()
    local randomMaterial = materials[math.random(1, #materials)]
    local randomColor = Color3.fromHSV(math.random(0,359)/360, 0.7, 0.8)

    SpawnBagRemote:FireAllClients(HttpService:GenerateGUID(), randomMaterial, randomColor, endParts.start.CFrame)

    task.wait(1)
end