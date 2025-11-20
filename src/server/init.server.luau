local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Curve = require(ReplicatedStorage.Packages.curve)

local bezierPoints = workspace:WaitForChild("BezierPoints")

local bezierTrack = Instance.new("Model")

local bezierFunction = Curve.BezierCubic.fromPositions(bezierPoints.A.Position, bezierPoints.B.Position, bezierPoints.C.Position, bezierPoints.D.Position)

local steps = 100
for i = 1, steps-1 do
    local t = i/steps
    local next = (i+1)/steps

    local newSegment = Instance.new("Part")
    local segmentCFrame = bezierFunction:locationAt(t)
    local segmentVector = bezierFunction:locationAt(next).Position - segmentCFrame.Position
    local segmentLength = segmentVector.Magnitude

    newSegment.Size = Vector3.new(5,1, segmentLength+0.1)
    newSegment.Anchored = true
    newSegment.CFrame = segmentCFrame
    newSegment.Parent = bezierTrack
end

bezierTrack.Parent = workspace
print("hi")