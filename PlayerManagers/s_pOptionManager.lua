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
local             Mouse = nil

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
local characterLoaded = false
local connectionTable = {}

-- Player Values --
local pAssignedDomain = nil
local        pLoading = nil
local    	pSetting1 = nil
local    	pSetting2 = nil
local 	 pMusicVolume = nil
local      pSFXVolume = nil

-- GUI Variables -- 
local	  PlayerGUI = nil
local 	 PrimaryGUI = nil
local  	    MenuGUI = nil
local      MainMenu = nil
local  	  GUISounds = nil
local   MusicSlider = nil
local     SFXSlider = nil
local    MusicValue = nil
local      SFXValue = nil
local AnimateButton = nil
local    MuteButton = nil
local AnimateToggle = nil
local  AnimateValue = nil
local    MuteToggle = nil
local     MuteValue = nil
local MusicDetector = nil
local   SFXDetector = nil
local     MouseHeld = false

-- Sound Variables --
local  MenuOpen2 = nil
local MenuClose2 = nil
local  MenuSlide = nil
local MenuSwitch = nil

-- Constants --
local   SLIDER_POS_MAX
local SLIDER_VALUE_MAX
local   SLIDER_POS_MIN
local SLIDER_VALUE_MIN
local OFF_COLOR = Color3.fromRGB(83, 83, 83)
local ON_COLOR = Color3.fromRGB(0, 145, 255)
local OFF_POS = UDim2.new(0.04, 0, 0.143, 0)
local ON_POS = UDim2.new(0.41, 0,0.143, 0)
local NEW_SIZE


-------------------------
-------------------------
 -- HANDLER FUNCTIONS --
-------------------------
-------------------------
local function initializeButtons()
	-- Initialize game settings --
	SLIDER_POS_MAX = 0.715
	SLIDER_VALUE_MAX = 0.682
	SLIDER_POS_MIN = 0.157
	SLIDER_VALUE_MIN = 0.0
	
	
	SFXSlider.Position = UDim2.new(math.clamp(pSFXVolume.Value, SLIDER_POS_MIN, SLIDER_POS_MAX), 0, SFXSlider.Position.Y.Scale, 0)
	MusicSlider.Position = UDim2.new(math.clamp(pMusicVolume.Value, SLIDER_POS_MIN, SLIDER_POS_MAX), 0, MusicSlider.Position.Y.Scale, 0)
	
	SFXValue.Size = UDim2.new(math.clamp(pSFXVolume.Value - SFXSlider.Size.X.Scale, SLIDER_POS_MIN, SLIDER_POS_MAX), 0, SFXValue.Size.Y.Scale, 0)
	MusicValue.Size = UDim2.new(math.clamp(pMusicVolume.Value - MusicSlider.Size.X.Scale, SLIDER_VALUE_MIN, SLIDER_VALUE_MAX), 0, SFXValue.Size.Y.Scale, 0)
	
	
	if pSetting1.Value then
		MuteToggle.MuteSlider.Position = ON_POS
		MuteValue.ImageColor3 = ON_COLOR
	else
		MuteToggle.MuteSlider.Position = OFF_POS
		MuteValue.ImageColor3 = OFF_COLOR
	end
	
	if pSetting2.Value then
		AnimateToggle.AnimationSlider.Position = ON_POS
		AnimateValue.ImageColor3 = ON_COLOR
	else
		AnimateToggle.AnimationSlider.Position = OFF_POS
		AnimateValue.ImageColor3 = OFF_COLOR
	end
	
	-- Sliders for Music and SFX volume --
	local SFXSliderConnection
	SFXSliderConnection = SFXDetector.MouseButton1Down:Connect(function()
		
		MouseHeld = true

		while MouseHeld do
			NEW_SIZE = math.clamp((UserInputService:GetMouseLocation().X - SFXDetector.AbsolutePosition.X) / workspace.CurrentCamera.ViewportSize.X * 5, 0, 1.1)
			pSFXVolume.Value =  SLIDER_VALUE_MAX * NEW_SIZE
			
			SFXSlider.Position = UDim2.new(math.clamp(SLIDER_VALUE_MAX * NEW_SIZE, SLIDER_POS_MIN, SLIDER_POS_MAX), 0, SFXSlider.Position.Y.Scale, 0)
			SFXValue.Size      = UDim2.new(math.clamp(SLIDER_VALUE_MAX * NEW_SIZE - SFXSlider.Size.X.Scale, SLIDER_VALUE_MIN, SLIDER_VALUE_MAX), 0, SFXValue.Size.Y.Scale, 0)

			local t = tick()
			while (tick() - t) < 0.05 do
				game:GetService("RunService").Heartbeat:Wait()
			end
			
		end
	end)
	table.insert(connectionTable, SFXSliderConnection)
	
	local MusicSliderConnection
	MusicSliderConnection = MusicDetector.MouseButton1Down:Connect(function()
		
		MouseHeld = true
		
		while MouseHeld do
			NEW_SIZE = math.clamp((UserInputService:GetMouseLocation().X - MusicDetector.AbsolutePosition.X) / workspace.CurrentCamera.ViewportSize.X * 5, 0, 1.1)
			pMusicVolume.Value = SLIDER_VALUE_MAX * NEW_SIZE
			
			MusicSlider.Position = UDim2.new(math.clamp(SLIDER_VALUE_MAX * NEW_SIZE, SLIDER_POS_MIN, SLIDER_POS_MAX), 0, MusicSlider.Position.Y.Scale, 0)
			MusicValue.Size      = UDim2.new(math.clamp(SLIDER_VALUE_MAX * NEW_SIZE - MusicSlider.Size.X.Scale, SLIDER_VALUE_MIN, SLIDER_VALUE_MAX), 0, MusicValue.Size.Y.Scale, 0)
			
			local t = tick()
			while (tick() - t) < 0.05 do
				game:GetService("RunService").Heartbeat:Wait()
			end
			
		end
	end)
	table.insert(connectionTable, MusicSliderConnection)
	
	local MouseReleaseConnection
	MouseReleaseConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			MouseHeld = false
		end
		
	end)
	table.insert(connectionTable, MouseReleaseConnection)

	
	-- Mute and Animate Buttons --
	local MuteButtonConnection
	MuteButtonConnection = MuteButton.MouseButton1Down:Connect(function()
		pSetting1.Value = not pSetting1.Value
		if pSetting1.Value then
			MuteToggle.MuteSlider.Position = ON_POS
			MuteValue.ImageColor3 = ON_COLOR
		else
			MuteToggle.MuteSlider.Position = OFF_POS
			MuteValue.ImageColor3 = OFF_COLOR
		end
		
	end)
	table.insert(connectionTable, MuteButtonConnection)
	
	local AnimationButtonConnection
	AnimationButtonConnection = AnimateButton.MouseButton1Down:Connect(function()
		pSetting2.Value = not pSetting2.Value
		if pSetting2.Value then
			AnimateToggle.AnimationSlider.Position = ON_POS
			AnimateValue.ImageColor3 = ON_COLOR
		else
			AnimateToggle.AnimationSlider.Position = OFF_POS
			AnimateValue.ImageColor3 = OFF_COLOR
		end
		
	end)
	table.insert(connectionTable, AnimationButtonConnection)
	
end




---------------------
---------------------
 -- HANDLE PLAYER --
---------------------
---------------------
local function onPlayerSpawn(Character)
	
	-- Retrieve Mouse --
	Mouse = Player:GetMouse()
	
	-- Reassign GUI --
	PlayerGUI = Player.PlayerGui
	PrimaryGUI = PlayerGUI:WaitForChild("PrimaryGUI")
	MenuGUI = PlayerGUI:WaitForChild("MenuGUI")
	GUISounds = PrimaryGUI:WaitForChild("GUISounds")
	MainMenu = MenuGUI:WaitForChild("MainMenu")
	
	-- Retrieve Sliders --
	MusicSlider = MainMenu.Images:WaitForChild("MusicSlider")
	SFXSlider = MainMenu.Images:WaitForChild("SFXSlider")
	MusicValue = MainMenu.Images:WaitForChild("MusicValue")
	SFXValue = MainMenu.Images:WaitForChild("SFXValue")
	MusicDetector = MainMenu.Buttons:WaitForChild("MusicDetector")
	SFXDetector = MainMenu.Buttons:WaitForChild("SFXDetector")
	
	-- Retrieve Buttons --
	AnimateButton = MainMenu.Buttons:WaitForChild("Animate")
	MuteButton = MainMenu.Buttons:WaitForChild("Mute")
	AnimateToggle = MainMenu.Images:WaitForChild("AnimationToggle")
	MuteToggle = MainMenu.Images:WaitForChild("MuteToggle")
	AnimateValue = MainMenu.Images:WaitForChild("AnimationValue")
	MuteValue = MainMenu.Images:WaitForChild("MuteValue")
	
	-- Reassign Audio --
	MenuOpen2 = GUISounds.MenuOpen2
	MenuClose2 = GUISounds.MenuClose2
	--MenuSlide = nil
	--MenuSwitch = nil
	
	-- Reassign Player Values --
	pAssignedDomain = PlayerValues:WaitForChild("int_pAssignedDomain")
	pLoading = PlayerValues:WaitForChild("bool_pLoading")
	pSetting1 = PlayerValues:WaitForChild("bool_pSetting1")
	pSetting2 = PlayerValues:WaitForChild("bool_pSetting2")
	pMusicVolume = PlayerValues:WaitForChild("int_pMusicVolume")
	pSFXVolume = PlayerValues:WaitForChild("int_pSFXVolume")

	-- On Death Connection --
	local OnDeathDataRefresh
	OnDeathDataRefresh = Character:WaitForChild("Humanoid").Died:Connect(function()
		for _, connection in pairs(connectionTable) do
			connection:Disconnect()
		end
		
		DataLibrary.StoredOptions.Option1 = pSetting1.Value
		DataLibrary.StoredOptions.Option2 = pSetting2.Value
		DataLibrary.StoredOptions.SFXVolume = pSFXVolume.Value
		DataLibrary.StoredOptions.MusicVolume = pMusicVolume.Value
		
	end)
	table.insert(connectionTable, OnDeathDataRefresh)

	-- Validate data --
	while not DataLibrary.StoredProgress do
		local t = tick()
		while (tick() - t) < 1 do
			game:GetService("RunService").Heartbeat:Wait()
		end
		
	end
	
	pSetting1.Value = DataLibrary.StoredOptions.Option1
	pSetting2.Value = DataLibrary.StoredOptions.Option2
	pSFXVolume.Value = DataLibrary.StoredOptions.SFXVolume
	pMusicVolume.Value = DataLibrary.StoredOptions.MusicVolume

	-- Initialize player objects --
	initializeButtons()
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

-- Failsafe --
while not Player.Character do
	game:GetService("RunService").Heartbeat:Wait()
end
if characterLoaded == false then
	onPlayerSpawn(Player.Character)
end