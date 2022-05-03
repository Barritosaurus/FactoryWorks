-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local  UserInputService = game:GetService("UserInputService")
local      TweenService = game:GetService("TweenService")
local        RunService = game:GetService("RunService")
local           Players = game:GetService("Players")
local            Player = Players.LocalPlayer

-- Config --


-- Variables --


-- Gui Objects --
local  playerGui = nil
local primaryGui = nil
local    menuGui = nil
local    editGui = nil
local   errorGui = nil
local confirmGui = nil

-- Tables --
local connectionTable = {}
local shopTable = {}
local craftingTable = {}

-- Functions --
local handlePurchase
local throwError
local throwConfirm
local checkPlayerMoney
local equipNewHead
local equipNewBase
local addItem 
local removeItem 
local openMenu
local closeMenu
local onPlayerSpawn

-- Declarations --
handlePurchase = function()
	
end

throwError = function(text)
	local newError = errorGui:Clone()
	newError.Parent = playerGui
	newError.errorMessage.text = text
	newError.enabled = true

	local ErrorCLickConnection
	ErrorCLickConnection = newError.exitButton.MouseButton1Click:Connection(function()
		newError:Destroy()
		ErrorCLickConnection:Disconnect()
	end)
end

throwConfirm = function()
	
end

checkPlayerMoney = function()
	
end

equipNewHead = function()

end

equipNewBase = function()

end

addItem = function(newItem)
	local itemName = newItem.itemName
	local itemCost = newItem.itemCost
	local itemType = newItem.itemType
	local itemButton = ReplicatedStorage.SharedAssets.Interfaces.ItemButton1

	local OnClickConnection
	OnClickConnection = itemButton.MouseButton1Click:Connect(function()
		if checkPlayerMoney(itemCost) then
			local newConfirm = confirmGui:Clone()
			newConfirm.Parent = playerGui
			newConfirm.confirmMessage.text = tostring("Are you sure you want to purchase ", itemName, " for ", itemCost, " ? ")
			newConfirm.enabled = true

			local CancelClickConnection
			CancelClickConnection = newConfirm.exitButton.MouseButton1Click:Connection(function()
				newConfirm:Destroy()
				CancelClickConnection:Disconnect()
			end)
			
			local ConfirmClickConnection
			ConfirmClickConnection = newConfirm.confirmButton.MouseButton1Click:Connection(function()
				if handlePurchase(itemName) then
					
				else
					throwError(tostring("Error occured while purchasing ", itemName, "! Error Code : 1"))
				end
			end)
		else
			throwError("You do not have enough money to purchase this item!")
		end
	end)
	table.insert(connectionTable, OnClickConnection)
end

removeItem = function()

end

onPlayerSpawn = function(Character)

	-- GUI Redeclaration --
	playerGui = Player.playerGui
	primaryGui = playerGui:WaitForChild("PrimaryGUI")
	menuGui = playerGui:WaitForChild("MenuGUI")
	editGui = playerGui:WaitForChild("EditGUI")
	errorGui = playerGui:WaitForChild("ErrorGUI")

	-- Assemble Item Table --
	for _, newItem in pairs(shopTable) do
		addItem(newItem)
	end

	-- On Death Event --
	local OnDeathDataRefresh
	OnDeathDataRefresh = Character:WaitForChild("Humanoid").Died:Connect(function()
		for _, connection in pairs(connectionTable) do
			connection:Disconnect()
		end
	end)
	table.insert(connectionTable, OnDeathDataRefresh)
end

------------------------------------------------
------------------------------------------------
-- SPAWN CONNECTION AND FAILSAFE CONNECTION --
------------------------------------------------
------------------------------------------------
Player.CharacterAdded:Connect(function(Character)
	characterLoaded = true
	onPlayerSpawn(Character)
end)
while not Player.Character do
	game:GetService("RunService").Heartbeat:Wait()
end
if characterLoaded == false then
	onPlayerSpawn(Player.Character)
end