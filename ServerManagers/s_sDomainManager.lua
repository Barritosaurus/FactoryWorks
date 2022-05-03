------------------------------------------------------------------
------------------------------------------------------------------
  -- 					  sDomainManager			          --
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
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions

-- Gamespace --
local        CurrentMap = workspace.CurrentMap
local           Domains = CurrentMap.Domains

-- Events / Functions --
local  AssignPlayerDomain = ServerFunctions:WaitForChild("AssignPlayerDomain")

-- Script Values --
local connectionTable = {}
local domainTable = {
	[1] = {ID = "Domain1", User = "Empty"},
	[2] = {ID = "Domain2", User = "Empty"},
	[3] = {ID = "Domain3", User = "Empty"},
	[4] = {ID = "Domain4", User = "Empty"},
	[5] = {ID = "Domain5", User = "Empty"},
	[6] = {ID = "Domain6", User = "Empty"},
	[7] = {ID = "Domain7", User = "Empty"},
	[8] = {ID = "Domain8", User = "Empty"},
	[9] = {ID = "Domain9", User = "Empty"},
	[10] = {ID = "Domain10", User = "Empty"},
	[11] = {ID = "Domain11", User = "Empty"},
	[12] = {ID = "Domain12", User = "Empty"},
}




------------------------
------------------------
 -- LISTEN FUNCTIONS --
------------------------
------------------------
AssignPlayerDomain.OnServerInvoke = function(player)
	local count = 1
	for _, domain in pairs(domainTable) do
		if domain.User == tostring(player) then
			return domain.ID
		end
		count += 1
	end
	return -1
end




-------------------------
-------------------------
 -- HANDLER FUNCTIONS --
-------------------------
-------------------------
local function respawnPlayer(Player, Domain)
	
	-- Spawn Character --
	Player:LoadCharacter()
	
	-- Failsafe --
	while not Player.Character do
		game:GetService("RunService").Heartbeat:Wait()
	end
	
	-- Declarations --
	local Character = Player.Character
	local Humanoid = Character.Humanoid
	local spawnConnection = nil
	
	-- Move Character to Proper Domain --
	Character:SetPrimaryPartCFrame(Domain:WaitForChild("SpawnNode").CFrame)
	
	-- Respawn Connection --
	spawnConnection = Humanoid.Died:Connect(function()
		spawnConnection:Disconnect()
		Character = nil
		Humanoid = nil
		spawnConnection = nil
		respawnPlayer(Player, Domain)
	end)
end


local function assignDomain(Player)
	
	-- Declarations --
	local count = 1
	local Domain = nil
	
	-- Assign player a domain --
	for _, domain in pairs(domainTable) do
		if domain.User == "Empty" then
			domainTable[count].User = tostring(Player)
			break
		end
		count += 1
	end
	
	Domain = Domains:FindFirstChild("Domain"..count)
	
	-- Initial Spawn --
	respawnPlayer(Player, Domain)
end


local function clearDomain(Player)
	local count = 1
	for _, domain in pairs(domainTable) do
		if domain.User == tostring(Player) then
			domainTable[count].User = "Empty"
			break
		end
		count += 1
	end
end




-------------------
-------------------
 -- Connections --
-------------------
-------------------
game.Players.PlayerAdded:Connect(assignDomain)
game.Players.PlayerRemoving:Connect(clearDomain)
