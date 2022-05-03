----------------------------
--  POLI SaveData System  --
--         	v1.0          --
----------------------------

------------------
-- Return Table --
------------------
local DataSavingModule = {}


--------------
-- Services --
--------------
local  DataStoreService = game:GetService("DataStoreService")
local        playerData = DataStoreService:GetDataStore("PlayerData")
local     ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local      ServerEvents = ReplicatedStorage.Server.ServerEvents
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions
local     ServerModules = ReplicatedStorage.Server.ServerModules
local    m_sDataSession = require(ServerModules:WaitForChild("m_sDataSession"))

-----------------------
-- Control Variables --
-----------------------
local AUTOSAVE_INTERVAL = 120
local CURRENT_VERSION = 1

-------------------
-- Default Table --
-------------------

-- Deep Copy --
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local newData = {
	playerProgress = { 
     -- ["Resource"] : Finished, Premium, Tier# --
		  ["Copper"] = {false, false, 1},
			 ["Tin"] = {false, false, 0},
			["Coal"] = {false, false, 0},
		["Aluminum"] = {false, false, 0},
			["Iron"] = {false, false, 0},
			["Lead"] = {false, false, 0},
		  ["Silver"] = {false, false, 0},
		["Tungsten"] = {false, false, 0},
		    ["Gold"] = {false, false, 0},
	    ["Platinum"] = {false, false, 0}
	},
	playerUpgrades = {
		     ["VIP"] = false, 
		["Upgrade1"] = false, -- Factory Value 1
		["Upgrade2"] = false, -- Factory Speed 1
		["Upgrade3"] = false, -- Factory Value 2
		["Upgrade4"] = false, -- Factory Speed 2
		["Upgrade5"] = false, -- Factory Value 3
		["Upgrade6"] = false  -- Factory Speed 3
		
	},
	playerOptions = {
		["Option1"] = true, -- Animate Parts
		["Option2"] = false, -- Full Mute
		["SFXVolume"] = 0.05,  -- SFX Volume
		["MusicVolume"] = 0.05  -- Music Volume
	}
}

local mt = {
	__len = function(tbl)
		local count = 0
		for index, value in pairs(tbl) do
			count = count + 1
		end
		return count
	end
}


-------------------------
-- Update Version Data --
-------------------------
local function updateData(oldData)
	warn("Data mismatch, correcting.")
	-- This is how we update the old data. --
	
	--[[
	if oldData.dataVersion == CURRENT_VERSION - 1 then
		oldData.savedData.playerProgress["NewResource"] = {false, false, 0}
		oldData.savedData.playerUpgrades["NewUpgrade"] = false
	end
	]]--
	return oldData
end

-------------------------------
-- Add Playerdata to Session --
-------------------------------
local function setupPlayerData(player)
	print("Getting ", player.Name ,"'s data...")
	local playerUserId = "user_" .. player.UserId
	local success, data = pcall(function()
		return playerData:GetAsync(playerUserId)
	end)
	if success then
		if data then
			if data.dataVersion ~= CURRENT_VERSION then
				local oldData = deepCopy(data)
				data = updateData(oldData)
				data.dataVersion = CURRENT_VERSION
			end
			-- Data exists for this player
			local newData = {
				ID = playerUserId,
				dataVersion = data.dataVersion,
				playerCurrency = data.playerCurrency,
				savedData = data.savedData
			}
			table.insert(m_sDataSession, newData)
		else
			-- Data store is working, but no current data for this player
			print("No data found, generating default!")
			local newData = {
				ID = playerUserId,
				dataVersion = CURRENT_VERSION,
				playerCurrency = 111999999999,
				savedData = newData
			}
			playerData:SetAsync(playerUserId, newData)
			table.insert(m_sDataSession, newData)
		end
	else
		warn("Cannot access data store for user, attempting to set default!")
	end
end

----------------------
-- Save Player Data --
----------------------
DataSavingModule.savePlayerData = function(playerUserId)
	print("Saving ",playerUserId,"'s data...")
	local tries = 0	
	local success
	repeat
		tries = tries + 1
		success = pcall(function()
			local iterator = 0
			for i, object in ipairs(m_sDataSession) do
				iterator = i
				if object.ID == playerUserId then
					break
				end
			end
			print("Serverside :", m_sDataSession[iterator])
			playerData:UpdateAsync(playerUserId, function(oldValue)
				return m_sDataSession[iterator]
			end)
			
			playerData:RemoveAsync(playerUserId)
		end)
		if not success then wait(2.5) end
	until tries == 3 or success
	if not success then
		warn("Cannot save data for user!")
	else
		print("Succesfully saved user data for ", playerUserId, "!")
	end
end

-------------------------
-- Save on Player Exit --
-------------------------
local function saveOnExit(player)
	local playerUserId = "user_" .. player.UserId
	DataSavingModule.savePlayerData(playerUserId)
end

----------------------------
-- Periodically Save Data --
----------------------------
local function autoSave()
	while true do
		for i, object in ipairs(m_sDataSession) do
			DataSavingModule.savePlayerData(m_sDataSession[i].ID)
			local t = tick()
			while (tick() - t) < 1 do
				game:GetService("RunService").Heartbeat:Wait()
			end
		end	

		local t = tick()
		while (tick() - t) < AUTOSAVE_INTERVAL do
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
end

--------------
-- Autosave --
--------------
spawn(autoSave)

--------------------
-- Connect Events --
--------------------
game.Players.PlayerAdded:Connect(setupPlayerData)
game.Players.PlayerRemoving:Connect(saveOnExit)

return DataSavingModule