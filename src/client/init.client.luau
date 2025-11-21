--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Curve = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("curve"))
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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

local function OnBagClick(part: Instance) 
    print(part.Name)
    ReplicatedStorage.Remotes.BagClicked:FireServer(part.Name)
end

--Bag spawner
ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpawnBag").OnClientEvent:Connect(function(id: string, material: Enum.Material, color: Color3, cFrame: CFrame)
    local newBag: BasePart = Instance.new("Part")
    newBag.Material = material
    newBag.Anchored = true
    newBag.Size = Vector3.new(2,2,3)
    newBag.Color = color
    newBag.CFrame = cFrame + Vector3.new(0,10,0)
    newBag.Transparency = 1
    newBag:AddTag("Bag")
    newBag.Name = id

    local newClickDetector = Instance.new("ClickDetector")
    newClickDetector.Parent = newBag
    newClickDetector.MouseClick:Connect(function(_)  
        OnBagClick(newBag)
    end)
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


-- Conveyor animation
RunService.RenderStepped:Connect(function(deltaTime: number) 
    for index, animationData in pairs(animatedBags) do
        local newT = animationData.t + 5*(deltaTime / bezierFunction:d1t(animationData.t).Magnitude)

        -- Deletion animation
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

        -- Step forward
        animationData.t = newT
        animationData.part.CFrame = bezierFunction:locationAt(newT) + Vector3.new(0,1.5,0)
        animationData.part.AssemblyLinearVelocity = animationData.part.CFrame.LookVector * 5
    end
end)



--Slider GUI
local rail = game.Players.LocalPlayer.PlayerGui.SliderGui.Rail::Frame
local sliderButton = game.Players.LocalPlayer.PlayerGui.SliderGui.Rail.Slider::TextButton

local function PercentageToTime(n: number): number
    return n*2 + 1
end
sliderButton.Text = string.format("%.1f", PercentageToTime(0))

sliderButton.MouseButton1Down:Connect(function()
    local percentage = 0
    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
        local mouse = game.Players.LocalPlayer:GetMouse() 
        percentage = math.clamp((mouse.x - rail.AbsolutePosition.X)/rail.AbsoluteSize.X, 0, 1)
        sliderButton.Position = UDim2.new(percentage, 0, 0, 0)
        sliderButton.Text = string.format("%.1f", PercentageToTime(percentage))
        RunService.RenderStepped:Wait()
    end
    ReplicatedStorage.Remotes.ChangeRate:FireServer(PercentageToTime(percentage))
end)
