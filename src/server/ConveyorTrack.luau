local module = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function module:Construct()
    local Curve = require(ReplicatedStorage.Packages.curve)

    local bezierPoints = workspace:WaitForChild("BezierPoints")

    local bezierTrack = Instance.new("Model")

    local bezierFunction = Curve.BezierCubic.fromPositions(bezierPoints.A.Position, bezierPoints.B.Position, bezierPoints.C.Position, bezierPoints.D.Position)

    local steps = 120
    local conveyorWidth = 5

    local totalLength = 0

    for i = 1, steps-1 do
        local t = i/steps
        local next = (i+1)/steps

        local segmentCFrame = bezierFunction:locationAt(t)
        local segmentVector = bezierFunction:locationAt(next).Position - segmentCFrame.Position
        local segmentLength = segmentVector.Magnitude

        totalLength += segmentLength


        local newSegment = Instance.new("Part")
        newSegment.Size = Vector3.new(conveyorWidth, 1, segmentLength+0.1)
        newSegment.Anchored = true
        newSegment.AssemblyLinearVelocity = segmentVector.Unit * 20
        newSegment.CFrame = segmentCFrame
        newSegment.Color = Color3.new(0,0,0)
        newSegment.Material = Enum.Material.SmoothPlastic
        newSegment.Parent = bezierTrack

        local offsets = {-conveyorWidth/2, conveyorWidth/2}
        for _, offset in pairs(offsets) do
            local newSideWall = Instance.new("Part")
            newSideWall.Size = Vector3.new(1, 3, segmentLength+0.2)
            newSideWall.Anchored = true
            newSideWall.CFrame = segmentCFrame + (segmentCFrame.RightVector * offset)
            newSideWall.Color = Color3.new(0.2,0.2,0.2)
            newSideWall.Material = Enum.Material.SmoothPlastic
            newSideWall.Parent = bezierTrack
        end
    end

    bezierTrack.Parent = workspace
    print(`Total conveyor length: {totalLength}`)
end

return module