--------------
-- Services --
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


-------------
-- Storage --
-------------
local      ServerEvents = ReplicatedStorage.Server.ServerEvents
local     ServerModules = ReplicatedStorage.Server.ServerModules
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions


-------------
-- Modules --
-------------
local Pathfinder = require(ServerModules:WaitForChild("m_sPathfinder"))
local CaveGenerator = require(ServerModules:WaitForChild("m_sCaveGenerator"))


---------------
-- Variables --
---------------
local                 npc = script.Parent
local            npcTimer = 0
local    npcCurrentTarget = nil
local            rootPart = npc:WaitForChild("RootPart")
local hitBoxOverlapParams = OverlapParams.new()

-- This will be used for FOV calculations, if you wish to use FOV calculations then set this to the 'head' part; otherwise nil. --
local npcHead = npc:WaitForChild("Head")


--------------------
-- Overlap Params --
--------------------
hitBoxOverlapParams.FilterDescendantsInstances = workspace.CurrentMap.Players
hitBoxOverlapParams.FilterType = Enum.RaycastFilterType.Whitelist 


------------
-- Config --
------------
local               DEBUG_MODE = false
local          NPC_IS_HUMANOID = false
local     NPC_ACTIVATION_RANGE = 250
local        NPC_ATTACK_DAMAGE = 25
local         NPC_ATTACK_RANGE = 5
local                FOV_ANGLE = 90
local      NPC_FOLLOWING_RANGE = 50
local       NPC_MOVEMENT_SPEED = 20
local   NPC_MAX_SEARCH_QUERIES = 3
local NPC_MAX_PATHFINDING_COST = 10
local    NPC_LOGIC_CYCLE_DELAY = 0.25
local           STATE_SLEEPING = 1
local          STATE_FOLLOWING = 2
local          STATE_SEARCHING = 3
local            STATE_PATHING = 4
local             STATE_WANDER = 5
local          STATE_ATTACKING = 6


------------
-- Tables --
------------
local connectionTable = {}
local      playersHit = {}
local       pathTable = nil


-----------
-- Logic --
-----------
local          enabled = false
local    playersInArea = 0
local npcSearchQueries = 0
local  npcCurrentState = 1
local    npcStateNames = {
	[1] = "Sleeping",
	[2] = "Following",
	[3] = "Searching",
	[4] = "Pathing",
	[5] = "Wandering",
	[6] = "Attacking"
}


---------------
-- Functions --
---------------
local checkDistanceToPlayers
local checkFieldOfViewForPlayers
local findValidPathOnMap
local findValidPointOnMap
local npcDirect
local npcSearch
local npcPath
local npcFollow
local npcAttack
local npcSleep
local npcWander
local npcEnable
local npcDestroy
local npcStates = {
	[1] = npcSleep(),
	[2] = npcFollow(),
	[3] = npcSearch(),
	[4] = npcPath(),
	[5] = npcWander(),
	[6] = npcAttack()
}


-- Declarations --
findValidPathOnMap = function()
	-- A* Pathfinding for 2D Gridbased Map --

end 

findValidPointOnMap = function()
	-- Find valid point for 2D Gridbased Map --

end

if NPC_IS_HUMANOID then
	
	------------------------
	-- ROBLOX HUMANOID AI --
	------------------------
	
	
	---------------
	-- Variables --
	---------------
	local humanoid = npc:WaitForChild("Humanoid")
	local targetPart = nil
	
	
	---------------
	-- Functions --
	---------------
	checkDistanceToPlayers = function()
		return (targetPart.Position - rootPart.Position).Magnitude
	end

	checkFieldOfViewForPlayers = function()

	end

	npcDirect = function()
		if DEBUG_MODE then
			print("NPC : ", npc.Name, " | Current state : ", npcStateNames[npcCurrentState])
		end

		assert(npcStates[npcCurrentState])

	end

	npcSearch = function()
		if checkDistanceToPlayers() then
			if npcSearchQueries < NPC_MAX_SEARCH_QUERIES then
				npcSearchQueries += 1
				npcCurrentState = STATE_PATHING

			else
				npcSearchQueries = 0
				npcCurrentState = STATE_WANDER

			end

		else
			npcSearchQueries = 0
			npcCurrentState = STATE_SLEEPING

		end

	end

	npcPath = function()
		if pathTable then
			local nextNode = pathTable.pop()
			if nextNode then
				npc:MoveTo(nextNode)

			else
				pathTable = nil
				npcCurrentState = STATE_SEARCHING

			end

		else
			pathTable = findValidPathOnMap()

		end

	end

	npcFollow = function()
		if checkFieldOfViewForPlayers() then
			if (npc.HumanoidRootPart.Position - npcCurrentTarget.Position).Magnitude < NPC_ATTACK_RANGE then
				npcCurrentState = STATE_ATTACKING
			end
		else
			npcCurrentState = STATE_SEARCHING
		end

	end

	npcAttack = function()
		for _, playerPart in pairs(workspace:GetPartBoundsInBox(rootPart.CFrame, rootPart.Size, hitBoxOverlapParams)) do
			if not table.find(playersHit, playerPart.Parent) then
				table.insert(playersHit, playerPart.Parent)
				playerPart.Parent:TakeDamage(NPC_ATTACK_DAMAGE)
			end
		end
		table.clear(playersHit)

		npcCurrentState = STATE_FOLLOWING
	end

	npcSleep = function()
		if checkDistanceToPlayers() then

		elseif checkFieldOfViewForPlayers() then
			npcCurrentState = STATE_FOLLOWING
		end

	end

	npcWander = function()
		if checkFieldOfViewForPlayers() then
			npcCurrentState = STATE_FOLLOWING
		else
			humanoid:MoveTo(findValidPointOnMap(npc.HumanoidRootPart.Position))
		end

	end

	npcEnable = function()
		enabled = true

		local onDeathConnection
		onDeathConnection = npc.Died:Connect(function()
			enabled = false
			npcDestroy()
		end)
		table.insert(connectionTable, onDeathConnection)

		while enabled do
			npcDirect()
			npcTimer = tick()
			while (tick() - npcTimer) > NPC_LOGIC_CYCLE_DELAY do
				RunService.Heartbeat:Wait()
			end

		end

		npcDestroy()
	end

	npcDestroy = function()
		for _, connection in pairs(connectionTable) do
			connection:Disconnect()
		end
	end
	
	
	----------------
	-- Enable NPC --
	----------------
	npcEnable()
	
	
else
	
	------------------------
	-- CUSTOM HUMANOID AI --
	------------------------
	
	---------------
	-- Variables --
	---------------
	local val_health      = npc:WaitForChild("val_health")
	local val_healthregen = npc:WaitForChild("val_healthregen")
	local val_movespeed   = npc:WaitForChild("val_movespeed")
	local targetPart      = nil


	---------------
	-- Functions --
	---------------
	checkForObjectsInPath = function()
		if DEBUG_MODE then
			print("NPC : ", npc.Name, " | Casting ray at ", targetPart)
		end
		
		local newRay = Ray.new()
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {npc}
		params.FilterType = Enum.RaycastFilterType.Blacklist
		local result = workspace:Raycast(npcHead, npcHead.CFrame.LookVector * NPC_ACTIVATION_RANGE, params)		
		
		if result then
			if DEBUG_MODE then
				print("NPC : ", npc.Name, " | Ray struck at ", result.Position)
			end
			
			if result == targetPart then
				return false
			end
			
		end
		
		return true
	end
	
	checkDistanceToPlayers = function()
		return (targetPart.Position - rootPart.Position).Magnitude
	end

	checkFieldOfViewForPlayers = function()
		if npcHead then
			local angle = math.deg(math.acos(npcHead.LookVector:Dot(targetPart.Position - rootPart.Position).Unit))
			
			if angle <= FOV_ANGLE then
				if checkForObjectsInPath(rootPart, targetPart) then
					return false
				end
			end
		end
		
		return true
	end
	
	moveTo = function()
		
	end

	npcDirect = function()
		if DEBUG_MODE then
			print("NPC : ", npc.Name, " | Current state : ", npcStateNames[npcCurrentState])
		end

		assert(npcStates[npcCurrentState])

	end

	npcSearch = function()
		if checkDistanceToPlayers() then
			if npcSearchQueries < NPC_MAX_SEARCH_QUERIES then
				npcSearchQueries += 1
				npcCurrentState = STATE_PATHING

			else
				npcSearchQueries = 0
				npcCurrentState = STATE_WANDER

			end

		else
			npcSearchQueries = 0
			npcCurrentState = STATE_SLEEPING

		end

	end

	npcPath = function()
		if pathTable then
			local nextNode = pathTable.pop()
			if nextNode then
				npc:MoveTo(nextNode)

			else
				pathTable = nil
				npcCurrentState = STATE_SEARCHING

			end

		else
			pathTable = findValidPathOnMap()

		end

	end

	npcFollow = function()
		if checkFieldOfViewForPlayers() then
			if (npc.HumanoidRootPart.Position - npcCurrentTarget.Position).Magnitude < NPC_ATTACK_RANGE then
				npcCurrentState = STATE_ATTACKING
			end
		else
			npcCurrentState = STATE_SEARCHING
		end

	end

	npcAttack = function()
		for _, playerPart in pairs(workspace:GetPartBoundsInBox(rootPart.CFrame, rootPart.Size, hitBoxOverlapParams)) do
			if not table.find(playersHit, playerPart.Parent) then
				table.insert(playersHit, playerPart.Parent)
				playerPart.Parent:TakeDamage(NPC_ATTACK_DAMAGE)
			end
		end
		table.clear(playersHit)

		npcCurrentState = STATE_FOLLOWING
	end

	npcSleep = function()
		if checkDistanceToPlayers() then

		elseif checkFieldOfViewForPlayers() then
			npcCurrentState = STATE_FOLLOWING
		end

	end

	npcWander = function()
		if checkFieldOfViewForPlayers() then
			npcCurrentState = STATE_FOLLOWING
		else
			moveTo(findValidPointOnMap(npc.HumanoidRootPart.Position))
		end

	end

	npcEnable = function()
		enabled = true

		local onDeathConnection
		onDeathConnection = val_health:GetPropertyChangedSignal():Connect(function()
			if val_health < 1 then
				enabled = false
				npcDestroy()
			end
		end)
		table.insert(connectionTable, onDeathConnection)

		while enabled do
			npcDirect()
			npcTimer = tick()
			while (tick() - npcTimer) > NPC_LOGIC_CYCLE_DELAY do
				RunService.Heartbeat:Wait()
			end

		end

		npcDestroy()
	end

	npcDestroy = function()
		for _, connection in pairs(connectionTable) do
			connection:Disconnect()
		end
	end


	----------------
	-- Enable NPC --
	----------------
	npcEnable()
end
