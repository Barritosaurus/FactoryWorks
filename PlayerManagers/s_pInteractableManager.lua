------------------------------------------------------------------
------------------------------------------------------------------
  -- 					pInteractableManager			      --
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
local  AssignPlayerDomain = ServerFunctions:WaitForChild("AssignPlayerDomain")
local CheckResourceIncome = ServerFunctions:WaitForChild("CheckResourceIncome")
local 	  CheckButtonCost = ServerFunctions:WaitForChild("CheckResourceCost")
local 			 CheckVIP = ServerFunctions:WaitForChild("CheckVIP")

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
local 		  resourceList = {}
local      connectionTable = {}

-- Custom Lerp Animation Variables --
local    shift = nil
local 	rotate = nil
local 	  fade = nil
local 	 reset = nil
local newFrame = nil
local 	resetY = nil

-- GUI Variables -- 
local    PlayerGUI = nil
local   PrimaryGUI = nil
local    TickSound = nil
local OdometerMenu = nil
local     Odometer = nil
local 	  odomutex = false




-------------------------
-------------------------
 -- HANDLER FUNCTIONS --
-------------------------
-------------------------
local function initializeQuarry()
	if DataLibrary.StoredProgress then
		-- Initialize quarry progression --
		local quarryConnection;
		local     domain = 	assignedDomain
		local  quarry = domain.Quarry

		local tier1 = DataLibrary.StoredProgress["Copper"][1] -- Copper completed?
		local tier2 = DataLibrary.StoredProgress["Aluminum"][1] -- Aluminum completed?
		local tier3 = DataLibrary.StoredProgress["Silver"][1] -- Silver completed?

		if tier1 then
			local blockade = quarry["Quarry Tier 1"]:FindFirstChild("Blockade")
			if blockade then
				blockade:Destroy()
			end
		end

		if tier2 then
			local blockade = quarry["Quarry Tier 2"]:FindFirstChild("Blockade")
			if blockade then
				blockade:Destroy()
			end
		end

		if tier3 then
			local blockade = quarry["Quarry Tier 3"]:FindFirstChild("Blockade")
			if blockade then
				blockade:Destroy()
			end
		end
	else
		warn("Progess save not found.")
	end
end

local function createButtonConnection(newButton)
	
	-- Connections --
	local buttonConnections = {}

	-- Variables --
	local buttonName = newButton.Name
	local     domain = assignedDomain
	local  factories = domain.Factories
	local factoryType

	-- Normal Variables
	local resourceProgress = DataLibrary.StoredProgress[newButton.Name][3]
	local     normalHitbox = newButton.Normal:WaitForChild("Hitbox")
	local         placebox = newButton.Normal.Placebox

	-- Premium Variables --
	local premiumStatus = DataLibrary.StoredProgress[newButton.Name][2]
	
	-- Get Server Data --
	resourceList = CheckButtonCost:InvokeServer()
	
	-- Determine Premium --
	if premiumStatus then
		factoryType = buttonName.." | Tier "..resourceProgress.." | Premium"
	else
		factoryType = buttonName.." | Tier "..resourceProgress
	end
	if CheckVIP:InvokeServer() then
		factoryType = factoryType.." | VIP"
	end
	
	-- Incase Player has Died --
	if factories:FindFirstChild(factoryType) then
		factories[factoryType]:Destroy()
	end

	-- Determine if button is valid --
	if resourceProgress > 0 and resourceProgress < 5 then 
		local cost = resourceList[newButton.Name][resourceProgress + 1]
		local billboard = normalHitbox.Billboard

		billboard.ResourceLabel.Text = newButton.Name.." Tier "..resourceProgress + 1
		billboard.PriceLabel.Text = CommonLibrary.formatNumberToProper(tostring(cost))

		-- Button Connection --
		local normalButtonConnection
		normalButtonConnection = normalHitbox.Touched:Connect(function(touchingPart)
			if touchingPart.Parent and touchingPart.Parent:FindFirstChild("Humanoid") then
				if DataLibrary.StoredCurrency > cost then
					normalButtonConnection:Disconnect()
					normalButtonConnection = nil

					local touchedPlayer = touchingPart.Parent
					local endingConnection

					endingConnection = normalHitbox.TouchEnded:Connect(function(endPart)
						if touchingPart == endPart then
							CommonLibrary.wipeConnections(buttonConnections)
							endingConnection = nil

							DataLibrary.StoredCurrency = DataLibrary.StoredCurrency - cost
							DataLibrary.StoredProgress[newButton.Name][3] = resourceProgress + 1

							if resourceProgress + 1 > 4 then
								DataLibrary.StoredProgress[newButton.Name][1] = true
							end
							
							if factories:FindFirstChild(factoryType) then
								factories[factoryType]:Destroy()
							end

							local t = tick()
							while (tick() - t) < 1 do
								game:GetService("RunService").Heartbeat:Wait()
							end

							createButtonConnection(newButton)
						end
					end)

					table.insert(buttonConnections, endingConnection)
				end
			end
		end)

		table.insert(buttonConnections, normalButtonConnection)

		local  itemCopy = Items[newButton.Name][factoryType]:Clone()
		local itemPivot = itemCopy:GetPivot()

		itemCopy.Parent = factories
		itemCopy:PivotTo(
			CFrame.new(itemPivot.Position + placebox.Position) * 
				CFrame.Angles(math.rad(itemCopy.PrimaryPart.Orientation.x), 
					math.rad(placebox.Orientation.y), math.rad(itemCopy.PrimaryPart.Orientation.z)))
		
		-- Add to animation tables --
		if itemCopy.Animate then
			for _, animatedPart in pairs(itemCopy.Animate:GetChildren()) do
				local ResetPos = Instance.new("Vector3Value")
				ResetPos.Parent = animatedPart
				ResetPos.Name = "ResetPos"
				animatedPart.ResetPos.Value = animatedPart.Position
			end
		end
	elseif resourceProgress <= 0 then
		local cost = resourceList[newButton.Name][resourceProgress + 1]
		local billboard = normalHitbox.Billboard

		billboard.ResourceLabel.Text = newButton.Name.." Tier "..resourceProgress + 1
		billboard.PriceLabel.Text = CommonLibrary.formatNumberToProper(tostring(cost))

		-- Button Connection --
		local normalButtonConnection
		normalButtonConnection = normalHitbox.Touched:Connect(function(touchingPart)
			if touchingPart.Parent and touchingPart.Parent:FindFirstChild("Humanoid") then
				if DataLibrary.StoredCurrency > cost then
					normalButtonConnection:Disconnect()
					normalButtonConnection = nil

					local touchedPlayer = touchingPart.Parent
					local endingConnection

					endingConnection = normalHitbox.TouchEnded:Connect(function(endPart)
						if touchingPart == endPart then
							CommonLibrary.wipeConnections(buttonConnections)
							endingConnection = nil

							DataLibrary.StoredCurrency = DataLibrary.StoredCurrency - cost
							DataLibrary.StoredProgress[newButton.Name][3] = resourceProgress + 1

							if resourceProgress + 1 > 4 then
								DataLibrary.StoredProgress[newButton.Name][1] = true
							end


							local t = tick()
							while (tick() - t) < 1 do
								game:GetService("RunService").Heartbeat:Wait()
							end

							createButtonConnection(newButton)
						end
					end)

					table.insert(buttonConnections, endingConnection)
				end
			end
		end)

		table.insert(buttonConnections, normalButtonConnection)
	else
		local  itemCopy = Items[newButton.Name][factoryType]:Clone()
		local itemPivot = itemCopy:GetPivot()
		local billboard = normalHitbox.Billboard

		itemCopy.Parent = factories
		itemCopy:PivotTo(CFrame.new(itemPivot.Position + placebox.Position) * CFrame.Angles(math.rad(itemCopy.PrimaryPart.Orientation.x), math.rad(placebox.Orientation.y), math.rad(itemCopy.PrimaryPart.Orientation.z)))
		
		
		-- Add to animation tables --
		if itemCopy.Animate then
			for _, animatedPart in pairs(itemCopy.Animate:GetChildren()) do
				local ResetPos = Instance.new("Vector3Value")
				ResetPos.Parent = animatedPart
				ResetPos.Name = "ResetPos"
				animatedPart.ResetPos.Value = animatedPart.Position
			end
		end
		
		billboard.ResourceLabel.Text = " "
		billboard.PriceLabel.Text = " "

		for _, currentPart in pairs(newButton.Normal.Color:GetChildren()) do
			currentPart.Color = Color3.fromRGB(255, 74, 77)
		end
	end

	-- Determine if we need the Premium Button Connection --
	if not premiumStatus then
		-- Create Premium Button Connection --
		local premiumHitbox = newButton.Premium:WaitForChild("Hitbox")
		local premButtonConnection
		
		if resourceProgress <= 0 then
			premiumHitbox.Available.Enabled = false
			premiumHitbox.Unavailable.Enabled = true

			for _, currentPart in pairs(newButton.Premium.Color:GetChildren()) do
				currentPart.Color = Color3.fromRGB(255, 74, 77)
			end
		else
			
			premiumHitbox.Available.Enabled = true
			premiumHitbox.Unavailable.Enabled = false
			for _, currentPart in pairs(newButton.Premium.Color:GetChildren()) do
				currentPart.Color = Color3.fromRGB(0, 229, 0)
			end
			
			premButtonConnection = premiumHitbox.Touched:Connect(function(touchingPart)
				if touchingPart.Parent and touchingPart.Parent:FindFirstChild("Humanoid") then
					premButtonConnection:Disconnect()
					premButtonConnection = nil

					local touchedPlayer = touchingPart.Parent
					local endingConnection

					endingConnection = premiumHitbox.TouchEnded:Connect(function(endPart)
						if touchingPart == endPart then
							CommonLibrary.wipeConnections(buttonConnections)
							endingConnection = nil

							DataLibrary.StoredProgress[newButton.Name][2] = true
							
							if factories:FindFirstChild(factoryType) then
								factories[factoryType]:Destroy()
							end

							local t = tick()
							while (tick() - t) < 1 do
								game:GetService("RunService").Heartbeat:Wait()
							end

							createButtonConnection(newButton)
						end
					end)
					table.insert(buttonConnections, endingConnection)
				end
			end)

			table.insert(buttonConnections, premButtonConnection)
		end
	else
		-- Destroy Premium Button --
		local premium = newButton:FindFirstChild("Premium")
		if premium then
			premium:Destroy()
		end
	end
	initializeQuarry()
end

local function initializeButtons()
	-- Initialize factory progression buttons --
	for _, newButton in pairs(assignedDomain.Buttons:GetChildren()) do
		if DataLibrary.StoredProgress then
			createButtonConnection(newButton)
		else
			warn("Progess save not found.")
		end
	end
end




---------------------
---------------------
 -- HANDLE PLAYER --
---------------------
---------------------
local function onPlayerSpawn(Character)

	-- Player Values --
	playerLoading = PlayerValues:WaitForChild("bool_pLoading")

	-- On Death Connection --
	local OnDeathDataRefresh
	OnDeathDataRefresh = Character:WaitForChild("Humanoid").Died:Connect(function()
		for _, connection in pairs(connectionTable) do
			connection:Disconnect()
		end
	end)
	table.insert(connectionTable, OnDeathDataRefresh)
	
	-- Validate data --
	while not DataLibrary.StoredProgress do
		local t = tick()
		while (tick() - t) < 1 do
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
	
	-- Initialize player objects --
	initializeButtons()
	initializeQuarry()
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