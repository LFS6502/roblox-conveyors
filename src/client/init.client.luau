--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Curve = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("curve"))
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local bezierPoints = workspace:WaitForChild("BezierPoints")

local bezierFunction = Curve.BezierCubic.fromPositions(
    bezierPoints:WaitForChild("A").Position, 
    bezierPoints:WaitForChild("B").Position, 
    bezierPoints:WaitForChild("C").Position, 
    bezierPoints:WaitForChild("D").Position
)

local Debris = game:GetService("Debris")

type AnimationData = {part: BasePart, t: number}
local animatedBags: {AnimationData} = {}

ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpawnBag").OnClientEvent:Connect(function(id: string, material: Enum.Material, color: Color3, cFrame: CFrame)
    local newBag: BasePart = Instance.new("Part")
    newBag.Material = material
    newBag.Anchored = true
    newBag.Size = Vector3.new(2,2,3)
    newBag.Color = Color3.fromHSV(math.random(0,359)/360, 0.7, 0.8)
    newBag.CFrame = cFrame + Vector3.new(0,10,0)
    newBag.Transparency = 1
    newBag:AddTag("Bag")
    newBag.Name = id
    newBag.Parent = workspace.Bags

    local tween = TweenService:Create(
        newBag, 
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {
            CFrame = cFrame + Vector3.new(0, 1.5, 0),
            Transparency = 0
        }
    )
    tween:Play()
    tween.Completed:Wait()

    table.insert(animatedBags, {part = newBag, t = 0})
    Debris:AddItem(newBag, 20)
end)

RunService.RenderStepped:Connect(function(deltaTime: number) 
    for index, animationData in pairs(animatedBags) do
        local newT = animationData.t + 10*(deltaTime / bezierFunction:d1t(animationData.t).Magnitude)

        if newT >= 1 then
            table.remove(animatedBags, index)
            local tween = TweenService:Create(
                animationData.part, 
                TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
                {
                    CFrame = animationData.part.CFrame + Vector3.new(0, 5, 0),
                    Transparency = 1
                }
            )
            tween:Play()
            tween.Completed:Wait()
            animationData.part:Destroy()
            continue
        end

        animationData.t = newT
        animationData.part.CFrame = bezierFunction:locationAt(newT) + Vector3.new(0,1.5,0)
    end
end)