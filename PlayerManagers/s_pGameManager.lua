------------------------------------------------------------------
------------------------------------------------------------------
  -- 					   pGameManager 					  --
  --               	  Created by Polipiolypus				  --
  -- Handles most of the core functionality on the clientside --
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
local CheckVIP            = ServerFunctions:WaitForChild("CheckVIP")

-- Script Values --
local  assignedDomain = 0
local characterLoaded = false
local  currencyUpdate = nil
local   domainButtons = {}
local unanimatedParts = {}
local   animatedParts = {}
local  resourceIncome = {}
local    animateTable = {}
local ConnectionTable = {}
local 	  tickersList = {}

-- Custom Lerp Animation Variables --
local shift    = nil
local rotate   = nil
local fade     = nil
local reset    = nil
local newFrame = nil
local resetY   = nil

-- GUI Variables -- 
local    PlayerGUI = nil
local   PrimaryGUI = nil
local    TickSound = {}
local    CurrSound = 1
local OdometerMenu = nil
local     Odometer = nil
local 	  odomutex = false




--------------
--------------
 -- CONFIG --
--------------
--------------

-- Custom Lerp Config --
local lerpFrames = 20
local   timeTick = 0.25 / lerpFrames

-- Odometer Animation Variables --
local animationFrames = 4            -- Total frames for the 'slide animation'
local  timeToComplete = 0.008         -- Time to complete a single animation.
local       maxNumber = 999999999999 -- Maximum number allowed.
local          offset = 0.085
local    storedNumber = 0




-----------------------------
-----------------------------
 -- Custom Lerp Functions --
-----------------------------
-----------------------------
function removekey(actualTable, key)
	for index, objAtKey in pairs(actualTable) do
		if objAtKey == key then
			table.remove(actualTable, index)
			break
		end
	end
end

local function cheapLerp(object, desiredFrame, desiredTransparency, resetEnd)
	if desiredFrame then
		removekey(unanimatedParts, object)
		table.insert(animatedParts, object)

		local originalFrame = object.CFrame
		local originalTransparency = object.Transparency
		local percentageOfLerp
		
		
		for elapsedFrames = 0, lerpFrames, 1 do
			percentageOfLerp = elapsedFrames / lerpFrames
			object.CFrame = originalFrame:lerp(desiredFrame, percentageOfLerp)
			object.Transparency = desiredTransparency * percentageOfLerp
			local t = tick()
			while (tick() - t) < timeTick do
				game:GetService("RunService").RenderStepped:Wait()
			end
		end
		
		local resetPos = object:FindFirstChild("ResetPos")
		if resetEnd and resetPos then
			object.Position = resetPos.Value
			object.Transparency = originalTransparency
		end
		
		originalFrame = nil
		originalTransparency = nil
		percentageOfLerp = nil
		
		removekey(animatedParts, object)
		table.insert(unanimatedParts, object)
	end
end




--------------------------
--------------------------
 -- Odometer Functions --
--------------------------
--------------------------

-- Note : This is absolutely awful and I hate myself for even making this jank, I know of a way to make this like O(n) and 
-- honestly look much better. Will upgrade this once game is released, it works for now...
local function formatNumberToProper(numberString, numTickers)	
	local fixedNumber = "$"..numberString:reverse():gsub("...","%0,",math.floor((#numberString - 1 ) / 3)):reverse()
	local fixedLength = fixedNumber:len()
	for currentNumber = 1, (numTickers - fixedLength) - 1, 1 do
		fixedNumber = ' '..fixedNumber
	end
	return fixedNumber
end

local function sineCheapInterpolation(object, desiredPosition)
	local originalPosition = object.Position
	local percentageOfLerp
	for elapsedFrames = 0, animationFrames, 1 do
		percentageOfLerp = elapsedFrames / animationFrames
		object.Position = originalPosition:lerp(desiredPosition, TweenService:GetValue(percentageOfLerp, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))

		local t = tick()
		while (tick() - t) < timeToComplete / animationFrames do
			game:GetService("RunService").RenderStepped:Wait()
		end
	end
	originalPosition = nil
	percentageOfLerp = nil
	
	TickSound[CurrSound]:Play()
	CurrSound = CurrSound + 1
	if CurrSound > 5 then
		CurrSound = 1
	end
end

local function sineCheapTransparency(object, desiredTransparency)
	local originalTransparency = object.TextTransparency
	local percentageOfLerp
	for elapsedFrames = 0, animationFrames, 1 do
		percentageOfLerp = elapsedFrames / animationFrames
		object.TextTransparency = originalTransparency + (desiredTransparency - originalTransparency) * percentageOfLerp

		local t = tick()
		while (tick() - t) < timeToComplete / animationFrames do
			game:GetService("RunService").RenderStepped:Wait()
		end
	end
	object.TextTransparency = originalTransparency
	originalTransparency = nil
	percentageOfLerp = nil
end

local function shiftNumber(currentCharacter, oldCharacter, displayLabel)
	local lowerLabel = displayLabel:WaitForChild("Lower", 1)
	local upperLabel = displayLabel:WaitForChild("Upper", 1)
	
	if not lowerLabel then
		return
	end
	if not upperLabel then
		return
	end
	
	local displayLabelPosition = displayLabel.Position
	local lowerLabelPosition = lowerLabel.Position
	local upperLabelPosition = upperLabel.Position
	if currentCharacter ~= oldCharacter and displayLabel then
		if currentCharacter == ',' or currentCharacter == '$' or currentCharacter == ' ' then
			--[[
			coroutine.wrap(function()
				sineCheapTransparency(displayLabel, 0.5)
				displayLabel.TextTransparency = 0.0
				displayLabel.TextStrokeTransparency = 0.11
			end)()
			coroutine.wrap(function()
				sineCheapTransparency(upperLabel, 0.0)
				upperLabel.TextTransparency = 0.5
				upperLabel.TextStrokeTransparency = 0.11
			end)()
			]]--
			
			coroutine.wrap(function()
				sineCheapInterpolation(displayLabel, displayLabel.Position + UDim2.new(0,0, -0.65,0))
				displayLabel.Position = UDim2.new(displayLabelPosition.X.Scale, 0, resetY, 0) 
				displayLabel.Text = currentCharacter
			end)()

			local t = tick()
			while (tick() - t) < timeToComplete + offset do
				RunService.RenderStepped:Wait()
			end
		elseif oldCharacter == ',' or oldCharacter == '$' or oldCharacter == ' ' then
			for iterator = 0, currentCharacter, 1 do
				upperLabel.Text = iterator
				lowerLabel.Text = iterator
				
				--[[
				upperLabel.TextTransparency = 1
				upperLabel.TextStrokeTransparency = 1
				coroutine.wrap(function()
					sineCheapTransparency(displayLabel, 0.5)
					displayLabel.TextTransparency = 0.0
					displayLabel.TextStrokeTransparency = 0.11
				end)()
				coroutine.wrap(function()
					sineCheapTransparency(upperLabel, 0.0)
					upperLabel.TextTransparency = 0.5
					upperLabel.TextStrokeTransparency = 0.11
				end)()
				]]--
				
				coroutine.wrap(function()
					sineCheapInterpolation(displayLabel, displayLabel.Position + UDim2.new(0,0, -0.65,0))
					displayLabel.Position = UDim2.new(displayLabelPosition.X.Scale, 0, resetY, 0) 
					displayLabel.Text = iterator
				end)()

				local t = tick()
				while (tick() - t) < timeToComplete + offset do
					RunService.RenderStepped:Wait()
				end
			end
			displayLabel.Text = currentCharacter
		elseif currentCharacter > oldCharacter then
			for iterator = tonumber(displayLabel.Text) + 1, currentCharacter, 1 do
				upperLabel.Text = iterator
				lowerLabel.Text = iterator
				
				--[[
				upperLabel.TextTransparency = 1
				upperLabel.TextStrokeTransparency = 1
				coroutine.wrap(function()
					sineCheapTransparency(displayLabel, 0.5)
					displayLabel.TextTransparency = 0.0
					displayLabel.TextStrokeTransparency = 0.11
				end)()
				coroutine.wrap(function()
					sineCheapTransparency(lowerLabel, 0.0)
					lowerLabel.TextTransparency = 0.5
					lowerLabel.TextStrokeTransparency = 0.11
				end)()
				]]--
				
				coroutine.wrap(function()
					sineCheapInterpolation(displayLabel, displayLabel.Position + UDim2.new(0,0, -0.65,0))
					displayLabel.Position = UDim2.new(displayLabelPosition.X.Scale, 0, resetY, 0) 
					displayLabel.Text = iterator
				end)()

				local t = tick()
				while (tick() - t) < timeToComplete + offset do
					RunService.RenderStepped:Wait()
				end
			end
		else
			for iterator = tonumber(displayLabel.Text) - 1, currentCharacter, -1 do
				upperLabel.Text = iterator
				lowerLabel.Text = iterator
				
				--[[
				lowerLabel.TextTransparency = 1
				lowerLabel.TextStrokeTransparency = 1
				coroutine.wrap(function()
					sineCheapTransparency(displayLabel, 0.5)
					displayLabel.TextTransparency = 0.0
					displayLabel.TextStrokeTransparency = 0.11
				end)()
				coroutine.wrap(function()
					sineCheapTransparency(upperLabel, 0.0)
					upperLabel.TextTransparency = 0.5
					upperLabel.TextStrokeTransparency = 0.11
				end)()
				]]--
				
				coroutine.wrap(function()
					sineCheapInterpolation(displayLabel, displayLabel.Position + UDim2.new(0,0, 0.65,0))
					displayLabel.Position = UDim2.new(displayLabelPosition.X.Scale, 0, resetY, 0) 
					displayLabel.Text = iterator
				end)()

				local t = tick()
				while (tick() - t) < timeToComplete + offset do
					RunService.RenderStepped:Wait()
				end
			end
		end
	end
end

local function changeCurrentNumbers(number)
	odomutex = true
	storedNumber = number
	if number > maxNumber then
		number = maxNumber
	end
	
	local initialNumber = number
	local numberString = formatNumberToProper(tostring(initialNumber), #tickersList)
	local numberLength = numberString:len()
	
	for currentNumber = 0, numberLength - 1, 1 do
		local displayLabel = tickersList[currentNumber + 1]
		local currentCharacter = string.sub(numberString, numberLength - currentNumber, numberLength - currentNumber)
		if displayLabel.Visible == false then
			displayLabel.Visible = true
		end
		
		shiftNumber(currentCharacter, displayLabel.Text, displayLabel)
	end
	odomutex = false
end

local function initializeNumbers(number)
	if number > maxNumber then
		number = maxNumber
	end
	
	local initialNumber = number
	local numberString = formatNumberToProper(tostring(initialNumber), #tickersList)
	local numberLength = numberString:len()
	
	for currentNumber = 0, numberLength - 1, 1 do
		local displayLabel = tickersList[currentNumber + 1]
		local currentCharacter = string.sub(numberString, numberLength - currentNumber, numberLength - currentNumber)
		if displayLabel.Visible == false then
			displayLabel.Visible = true
		end
		displayLabel.Text = currentCharacter
	end
end




-------------------------
-------------------------
 -- HANDLER FUNCTIONS --
-------------------------
-------------------------
local function HandleIncome()
	
end

local function HandleAnimations(model)
	if CommonLibrary.floatMod(resourceIncome[model.FactoryType.Value][DataLibrary.StoredProgress[model.FactoryType.Value][3]].speed, frameTime) == 0 then
		currencyUpdate = resourceIncome[model.FactoryType.Value][DataLibrary.StoredProgress[model.FactoryType.Value][3]].money
		if DataLibrary.StoredProgress[model.FactoryType.Value][2] then
			currencyUpdate = math.ceil(currencyUpdate * 1.2)
		end

		for _, animatedPart in pairs(model:FindFirstChild("Animate"):GetChildren()) do
			if table.find(animatedParts, animatedPart) == nil then
				shift = animatedPart:FindFirstChild("Shift")
				rotate = animatedPart:FindFirstChild("Rotate")
				fade = animatedPart:FindFirstChild("Fade")
				reset = animatedPart:FindFirstChild("Reset")

				if shift and fade and reset then
					newFrame = (animatedPart.CFrame * CFrame.new(shift.Value.X, shift.Value.Y, shift.Value.Z) * CFrame.Angles(math.rad(rotate.Value.X), math.rad(rotate.Value.Y), math.rad(rotate.Value.Z)))
					coroutine.wrap(function()
						cheapLerp(animatedPart, newFrame, fade.Value, reset.Value)
					end)()
				end
			end
		end

		DataLibrary.StoredCurrency = DataLibrary.StoredCurrency + currencyUpdate
	end
end
	
local function StartGame()
	
	-- Initial Setup --
	tickersList = Odometer:GetChildren()
	table.sort(tickersList, function(a, b)
		return a.Name < b.Name
	end)
	initializeNumbers(DataLibrary.StoredCurrency)
	
	-- Central Loop --
	while animateObjects do
		local t = tick()
		while (tick() - t) < 0.1 do
			RunService.RenderStepped:Wait()
		end
		currencyUpdate = nil
		frameTime += 0.25

		coroutine.wrap(function()
			if assignedDomain then
				local LoadedFactories = assignedDomain.Factories:GetChildren()
				for _, model in pairs(LoadedFactories) do

					-- Animate --
					if model and model.FactoryType then
						coroutine.wrap(function()
							HandleAnimations(model)
						end)()
					end
					
					-- Adjust money --
					if not odomutex then
						coroutine.wrap(function()
							changeCurrentNumbers(DataLibrary.StoredCurrency)
						end)()
					end
				end			
			end
		end)()
		
		if frameTime >= 4.0 then
			frameTime = 0.0
		end
	end
end




---------------------
---------------------
 -- HANDLE PLAYER --
---------------------
---------------------
local function onPlayerSpawn(Character)
	-- Animation Redeclaration --
	animateTable   = {}
	animateObjects = true
	frameTime      = 0.0
	
	-- GUI Redeclaration
	PlayerGUI      = Player.PlayerGui
	PrimaryGUI     = PlayerGUI:WaitForChild("PrimaryGUI")
	TickSound[1]   = PrimaryGUI.PlayerInfo:WaitForChild("Audio/OdometerTick1")
	TickSound[2]   = PrimaryGUI.PlayerInfo:WaitForChild("Audio/OdometerTick2")
	TickSound[3]   = PrimaryGUI.PlayerInfo:WaitForChild("Audio/OdometerTick3")
	TickSound[4]   = PrimaryGUI.PlayerInfo:WaitForChild("Audio/OdometerTick4")
	TickSound[5]   = PrimaryGUI.PlayerInfo:WaitForChild("Audio/OdometerTick5")
	CurrSound      = 1
	OdometerMenu   = PrimaryGUI.PlayerInfo.OdometerBackplate.OdometerMenu
	Odometer       = OdometerMenu.Odometer
	resetY         = OdometerMenu.Odometer.A.Position.Y
	resourceIncome = CheckResourceIncome:InvokeServer()

	-- On Death Event --
	local OnDeathDataRefresh
	OnDeathDataRefresh = Character:WaitForChild("Humanoid").Died:Connect(function()
		animateObjects = false
		for _, connection in pairs(ConnectionTable) do
			connection:Disconnect()
		end
		DataLibrary.SaveAllData()
	end)
	table.insert(ConnectionTable, OnDeathDataRefresh)
	
	-- Retrieve data from cache --
	DataLibrary.GetAllData()
	
	-- Begin game --
	StartGame()
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
while not Player.Character do
	game:GetService("RunService").Heartbeat:Wait()
end
if characterLoaded == false then
	assignedDomain = Domains[AssignPlayerDomain:InvokeServer()]
	onPlayerSpawn(Player.Character)
end