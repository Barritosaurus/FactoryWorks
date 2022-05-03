------------------------------------------------------------------
------------------------------------------------------------------
  -- 					    pLoadManager 					  --
  --               	  Created by Polipiolypus				  --
  -- 			Handles the overall loading of the game       --
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
local        RunService = game:GetService('RunService')
local           Players = game:GetService("Players")	

-- Files --
local      ServerEvents = ReplicatedStorage.Server.ServerEvents
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions
local      SharedAssets = ReplicatedStorage.SharedAssets
local             Items = SharedAssets.Items
local            Player = Players.LocalPlayer
local     PlayerScripts = Player.PlayerScripts
local     PlayerModules = PlayerScripts:WaitForChild("PlayerModules")
local      PlayerValues = PlayerScripts:WaitForChild("PlayerValues")

-- Modules --
local m_pSortingLibrary = require(PlayerModules:WaitForChild("m_pSortingLibrary"))
local           m_pData = require(PlayerModules:WaitForChild("m_pData"))
local        CurrentMap = workspace.CurrentMap
local           Domains = CurrentMap.Domains

-- Events / Functions --
local ServerEvents = ReplicatedStorage.Server.ServerEvents
local ServerFunctions = ReplicatedStorage.Server.ServerFunctions
local f_sAssignPlayerDomain = ServerFunctions:WaitForChild("AssignPlayerDomain")
local f_sCheckButtonCost = ServerFunctions:WaitForChild("CheckResourceCost")
local f_sCheckVIP = ServerFunctions:WaitForChild("CheckVIP")

-- Player Values --
local pAssignedDomain = 0
local pDomainButtons = {}
local pPlayerLoading = nil
local pEditingOptions = nil
local characterLoaded = false
local resourceProgress = nil

-- Main Declarations --
local CurrentProgress = nil
local ConnectionTable = {}

-- Main Declarations --
local function onPlayerSpawn(Character)
	-- Variable Redeclaration --

	-- Player Values --
	pAssignedDomain = PlayerValues:WaitForChild("int_pAssignedDomain")
	pPlayerLoading = PlayerValues:WaitForChild("bool_pLoading")
	
	-- Dying should hypothetically be impossible for the user, but just incase. --
	-- On Death Connection --
	local t = tick()
	while (tick() - t) < 10 do
		game:GetService("RunService").Heartbeat:Wait()
	end

	CurrentProgress = m_pData.StoredProgress

	local OnDeathDataRefresh
	OnDeathDataRefresh = Character:WaitForChild("Humanoid").Died:Connect(function()
		table.insert(ConnectionTable, OnDeathDataRefresh)
		for _, connection in pairs(ConnectionTable) do
			connection:Disconnect()
		end
	end)
end


------------------------------------------------
------------------------------------------------
-- SPAWN CONNECTION AND FAILSAFE CONNECTION --
------------------------------------------------
------------------------------------------------
Player.CharacterAdded:Connect(function(Character)
	characterLoaded = true
	--pAssignedDomain = Domains["Domain "..AssignPlayerDomain:InvokeServer()]
	onPlayerSpawn(Character)
end)

-- Failsafe --
while not Player.Character do
	game:GetService("RunService").Heartbeat:Wait()
end
if characterLoaded == false then
	--pAssignedDomain.Value = Domains["Domain "..AssignPlayerDomain:InvokeServer()]
	onPlayerSpawn(Player.Character)
end