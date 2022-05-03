local m_pData = {}

-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local           Players = game:GetService("Players")
local            Player = Players.LocalPlayer
local     PlayerScripts = Player.PlayerScripts
local     PlayerModules = PlayerScripts:WaitForChild("PlayerModules")
local      PlayerValues = PlayerScripts:WaitForChild("PlayerValues")
local m_pSortingLibrary = require(PlayerModules:WaitForChild("m_pSortingLibrary"))

-- Declarations --
local ServerFunctions = ReplicatedStorage.Server.ServerFunctions
local GetUserData = ServerFunctions:WaitForChild("GetUserData")
local SendUserData = ServerFunctions:WaitForChild("SendUserData")
local StoredCurrency = 0
local StoredProgress = {}
local StoredUpgrades = {}
local StoredOptions = {}
local ServerData = {}

-- Functions --
function m_pData.GetAllData()
	while not ServerData or not ServerData.savedData do
		ServerData = m_pSortingLibrary.DeepCopy(GetUserData:InvokeServer())
		
		local t = tick()
		while (tick() - t) < 0.05 do
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
	
	m_pData.StoredCurrency = ServerData["playerCurrency"]
	m_pData.StoredProgress = ServerData.savedData["playerProgress"]
	m_pData.StoredUpgrades = ServerData.savedData["playerUpgrades"]
	m_pData.StoredOptions = ServerData.savedData["playerOptions"]
	
	print("Stored Progress ", ServerData)
end

function m_pData.SaveAllData()
	-- Sends all current data-tables to the server to be saved, returns true if successful and false if unsuccessful.
	ServerData.playerCurrency = m_pData.StoredCurrency
	ServerData.savedData["playerProgress"] = m_pData.StoredProgress
	ServerData.savedData["playerUpgrades"] = m_pData.StoredUpgrades
	ServerData.savedData["playerOptions"] = m_pData.StoredOptions
	
	print("Requesting data save...")
	print("Saved Progress ", ServerData)
	
	SendUserData:InvokeServer(ServerData)
	
	if not SendUserData:InvokeServer(ServerData) then
		-- Output a GUI message to warn user of failed datasave, allowing them to forcibly save data via button press. --
		error("Request failed! Please stay connected until a data-save request is successful.")
		return false
	else
		print("Request complete!")
		return true
	end
end

return m_pData

