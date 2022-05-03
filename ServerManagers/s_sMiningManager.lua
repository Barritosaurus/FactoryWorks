--[[
local positions = {
	Vector3.new(8,0,0);
	Vector3.new(-8,0,0);
	Vector3.new(0,8,0);
	Vector3.new(0,-8,0);
	Vector3.new(0,0,8);
	Vector3.new(0,0,-8);
}

local cavecreation = {

}

function Generate(pos)
	if pos then
		for _, pos2 in pairs(positions) do
			local newPos = pos + pos2
			local previouslyGenerated
			
			for _, generated in pairs(workspace.CurrentMap.Generated:GetChildren()) do
				if generated.Value == newPos then
					previouslyGenerated = true
				end
			end
			
			if newPos.Y > 2066.5 then
				previouslyGenerated = true
			end
			
			if not previouslyGenerated then
				local ore = game.ReplicatedStorage.SharedAssets.Ores.Stone:Clone()
				local cd = Instance.new("ClickDetector", ore)
				
				ore.Position = newPos
				ore.Parent = workspace.CurrentMap.Mine
				
				cd.MouseClick:Connect(function()
					Generate(ore.Position)
					ore:Destroy()
				end)
				
				local val = Instance.new("Vector3Value")
				val.Value = newPos
				val.Parent = workspace.CurrentMap.Generated
			end
		end
	end
end

function GenerateCave()
	
end

for _, ore in pairs(workspace.CurrentMap.Mine:GetChildren()) do
	local cd = Instance.new("ClickDetector", ore)
	cd.MouseClick:Connect(function()
		Generate(ore.Position)
		ore:Destroy()
	end)
	local val = Instance.new("Vector3Value")
	val.Value = ore.Position
	val.Parent = workspace.CurrentMap.Generated
end

]]--

--[[

local Seed = tick()
print("Seed is: "..Seed)
local Resolution = 8
local NumWorm = 1

while wait() do
	NumWorm = NumWorm + 1
	local sX = math.noise(NumWorm / Resolution + .1, Seed)
	local sY = math.noise(NumWorm / Resolution + sX + .1, Seed)
	local sZ = math.noise(NumWorm / Resolution + sY + .1, Seed)
	local WormCF = CFrame.new(sX * 500, sY * 500, sZ * 500)
	print("Worm "..NumWorm.." spawning at "..WormCF.X..", "..WormCF.Y..", "..WormCF.Z)
	local Dist = (math.noise(NumWorm/Resolution+WormCF.p.magnitude,Seed) + .5) * 500

	for i = 1, Dist do
		wait()
		local X,Y,Z = math.noise(WormCF.X / Resolution + .1, Seed), math.noise(WormCF.Y / Resolution + .1,Seed), math.noise(WormCF.Z / Resolution + .1, Seed)
		WormCF = WormCF * CFrame.Angles(X * 2, Y * 2, Z * 2) * CFrame.new(0, 0, -Resolution)
		--Generate(WormCF.p)
	end
end
]]


------------------------------------------------------------------
------------------------------------------------------------------
  -- 					     sMining			              --
  --               	  Created by Polipiolypus				  --
------------------------------------------------------------------
------------------------------------------------------------------




-------------------------------------
-------------------------------------
-- INITALIZATION AND DECLARATION --
-------------------------------------
-------------------------------------

-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local        RunService = game:GetService('RunService')
local           Players = game:GetService("Players")

-- Replicated Storage --
local      ServerEvents = ReplicatedStorage.Server.ServerEvents
local     ServerModules = ReplicatedStorage.Server.ServerModules
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions
local         Resources = ReplicatedStorage.SharedAssets.Resources

-- Gamespace --
local        CurrentMap = workspace.CurrentMap
local         MineNodes = CurrentMap.MineNodes
local     MineResources = CurrentMap.MineResources

-- Data Structures --
local Stack = require(ReplicatedStorage.Server.ServerModules:WaitForChild("m_sStack"))
local Queue = require(ReplicatedStorage.Server.ServerModules:WaitForChild("m_sQueue"))

-- Functions --
local PlaceOre
local BeginPlacement

-- Tables --
local ResourceTable = Resources:GetChildren()


---------------------------------
---------------------------------
 -- NODE GENERATION FUNCTIONS --
---------------------------------
---------------------------------

PlaceOre = function(node)
	if node then
		local resource = ResourceTable[math.random(1, #ResourceTable)]:Clone()
		resource.Parent = MineResources
		resource:PivotTo(node.CFrame)

		local boundingBox = Instance.new("Part")
		local orientation, size = resource:GetBoundingBox()
		boundingBox.Parent = resource
		boundingBox.Size = size
		boundingBox.CFrame = resource:GetPivot()
		boundingBox.CanCollide = false
		boundingBox.Transparency = 0.5
		boundingBox.Anchored = true

		resource.AncestryChanged:Connect(function()
			PlaceOre(node)
			resource:Destroy()
		end)
	end
end

-- Generate Ores --
for _, node in pairs(MineNodes:GetChildren()) do
	local resource = ResourceTable[math.random(1, #ResourceTable)]:Clone()
	resource.Parent = MineResources
	resource:PivotTo(node.CFrame)
	
	local boundingBox = Instance.new("Part")
	local orientation, size = resource:GetBoundingBox()
	boundingBox.Name = "BoundingBox"
	boundingBox.Parent = resource
	boundingBox.Size = size
	boundingBox.CFrame = resource:GetPivot()
	boundingBox.CanCollide = false
	boundingBox.Transparency = 0.5
	boundingBox.Anchored = true
	
	resource.AncestryChanged:Connect(function()
		PlaceOre(node)
		resource:Destroy()
	end)
end