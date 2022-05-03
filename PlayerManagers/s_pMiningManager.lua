------------------------------------------------------------------
------------------------------------------------------------------
  -- 					  pMiningManager			          --
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
local  UserInputService = game:GetService("UserInputService")
local      TweenService = game:GetService("TweenService")
local        RunService = game:GetService('RunService')
local           Players = game:GetService("Players")

-- Player --
local            Player = Players.LocalPlayer
local     PlayerScripts = Player.PlayerScripts
local     PlayerModules = PlayerScripts:WaitForChild("PlayerModules")
local      PlayerValues = PlayerScripts:WaitForChild("PlayerValues")

-- Modules --
local    SortingLibrary = require(PlayerModules:WaitForChild("m_pSortingLibrary"))
local     CommonLibrary = require(PlayerModules:WaitForChild("m_pCommonLibrary"))
local       DataLibrary = require(PlayerModules:WaitForChild("m_pData"))

-- Replicated Storage --
local      ServerEvents = ReplicatedStorage.Server.ServerEvents
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions
local      SharedAssets = ReplicatedStorage.SharedAssets
local             Items = SharedAssets.Items

-- Gamespace --
local        CurrentMap = workspace.CurrentMap
local           Domains = CurrentMap.Domains

-- Events / Functions --
local AssignPlayerDomain  = ServerFunctions:WaitForChild("AssignPlayerDomain")
local CheckResourceIncome = ServerFunctions:WaitForChild("CheckResourceIncome")
local CheckButtonCost     = ServerFunctions:WaitForChild("CheckResourceCost")
local CheckVIP            = ServerFunctions:WaitForChild("CheckVIP")

-- Script Values --
local       assignedDomain = 0
local      characterLoaded = false
local       currencyUpdate = nil
local 	     playerLoading = nil
local playerEditingOptions = nil
local 	  resourceProgress = nil
local 		 domainButtons = {}
local 		resourceIncome = {}
local 		  animateTable = {}
local 	   connectionTable = {}
local 		  resourceList = {}
local      connectionTable = {}

-- GUI Variables -- 
local    PlayerGUI = nil
local   PrimaryGUI = nil


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




---------------------
---------------------
 -- HANDLE PLAYER --
---------------------
---------------------
local function onPlayerSpawn(Character)
	
	-- On Death Connection --
	local OnDeathDataRefresh
	OnDeathDataRefresh = Character:WaitForChild("Humanoid").Died:Connect(function()
		for _, connection in pairs(connectionTable) do
			connection:Disconnect()
		end
	end)
	table.insert(connectionTable, OnDeathDataRefresh)

	-- Initialize player objects --
	
end


------------------------------------------------
------------------------------------------------
 -- SPAWN CONNECTION AND FAILSAFE CONNECTION --
------------------------------------------------
------------------------------------------------
Player.CharacterAdded:Connect(function(Character)
	characterLoaded = true
	assignedDomain = Domains[AssignPlayerDomain:InvokeServer()]
	onPlayerSpawn(Character)
end)

-- Failsafe --
while not Player.Character do
	game:GetService("RunService").Heartbeat:Wait()
end
if characterLoaded == false then
	assignedDomain = Domains[AssignPlayerDomain:InvokeServer()]
	onPlayerSpawn(Player.Character)
end