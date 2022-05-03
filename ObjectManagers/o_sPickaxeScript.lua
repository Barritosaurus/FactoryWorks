------------------------------------------------------------------
------------------------------------------------------------------
  -- 					    sGeneration			              --
  --               	  Created by Polipiolypus				  --
------------------------------------------------------------------
------------------------------------------------------------------




-------------------------------------
-------------------------------------
 -- INITALIZATION AND DECLARATION --
-------------------------------------
-------------------------------------

-- Services --
local    ReplicatedStorage = game:GetService("ReplicatedStorage")
local           RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local     UserInputService = game:GetService("UserInputService")
local    CollectionService = game:GetService("CollectionService")
local               Debris = game:GetService("Debris")
local              Players = game:GetService("Players")

-- Files --
local      ServerEvents = ReplicatedStorage.Server.ServerEvents
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions
local      SharedAssets = ReplicatedStorage.SharedAssets
local             Items = SharedAssets.Items
local            Player = Players.LocalPlayer
local             Mouse = Player:GetMouse()
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

-- Script Variables --
while not Player.Character do
	game:GetService("RunService").Heartbeat:Wait()
end
local Tool = script.Parent
local Handle = Tool.Handle
local Face = Handle.Face
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local mouseHeld
local toolEquipped
local animationNum = 1
local waiting = false
local hit = false
local rayPart = ReplicatedStorage:WaitForChild("RayPart")

-- Animations --
local idleAnim = Tool.Animations.Idle
local swing1Anim = Tool.Animations.Swing1
local swing2Anim = Tool.Animations.Swing2
local swing3Anim = Tool.Animations.Swing3

-- Sounds --
local StoneHit = Tool.Sounds["Audio/LightStoneHit1"]

-- Load Animations --
local Idle = Humanoid:LoadAnimation(idleAnim)
local Swing1 = Humanoid:LoadAnimation(swing1Anim)
local Swing2 = Humanoid:LoadAnimation(swing2Anim)
local Swing3 = Humanoid:LoadAnimation(swing3Anim)

-- Script Tables --
local ConnectionTable = {}
local SoundTable = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil
}
local AnimationTable = {
	[1] = Idle,
	[2] = Swing1,
	[3] = Swing2,
	[4] = Swing3
}


-- Script Functions --
local equipTool
local unequipTool
local onClick




-------------------
-------------------
-- CONNECTIONS --
-------------------
-------------------
local EquipConnection
local UnequipConnection
local OnDeathDataRefresh 
local RenderStepConnection
OnDeathDataRefresh = Character:WaitForChild("Humanoid").Died:Connect(function()
	for _, connection in pairs(ConnectionTable) do
		connection:Disconnect()
	end
	
	OnDeathDataRefresh:Disconnect()
	EquipConnection:Disconnect()
	UnequipConnection:Disconnect()
end)




-----------------
-----------------
 -- FUNCTIONS --
-----------------
-----------------
equipTool = function()
	toolEquipped = true
	
	-- Assign Variables --
	
	
	-- Load Animations --
	Idle = Humanoid:LoadAnimation(idleAnim)
	Swing1 = Humanoid:LoadAnimation(swing1Anim)
	Swing2 = Humanoid:LoadAnimation(swing2Anim)
	Swing3 = Humanoid:LoadAnimation(swing3Anim)
	Idle:Play()
	
	-- Add Connections --
	ContextActionService:BindActionAtPriority("onClick", onClick, true, 200, Enum.UserInputType.MouseButton1, Enum.UserInputType.Gamepad1)
	RenderStepConnection = RunService.RenderStepped:Connect(function()
		if mouseHeld and not waiting and Humanoid then
			whileClicked()
		end
	end)
	table.insert(ConnectionTable, RenderStepConnection)

end

unequipTool = function()
	toolEquipped = false
	
	-- Dereference --
	Idle:Stop()
	Swing1:Stop()
	Idle:Destroy()
	Swing1:Destroy()
	Swing2:Destroy()
	Swing3:Destroy()
	
	-- Remove Connections --
	for _, connection in pairs(ConnectionTable) do
		connection:Disconnect()
	end
	ContextActionService:UnbindAction("onClick")

end

onClick = function(actionName, inputState)
	if inputState == Enum.UserInputState.Begin then
		mouseHeld = true
	end

	if inputState == Enum.UserInputState.End then
		mouseHeld = false
	end
end

whileClicked = function()
	waiting = true
	
	Idle:Stop()
	Swing1:Play()
	
	local animationTime = Swing1.Length / 2
	local t = tick()
	while (tick() - t) < animationTime do
		game:GetService("RunService").RenderStepped:Wait()		
	end
	
	for numRaycast = 1, 3 do
		local t = tick()
		while (tick() - t) < animationTime / 3 do
			game:GetService("RunService").RenderStepped:Wait()		
		end
		
		if Mouse.Target and Mouse.Target.Name == "BoundingBox" and not hit then
			if (Mouse.Target.Position - Character.HumanoidRootPart.Position).Magnitude < 15 then
				hit = true
				Mouse.Target.Parent:Destroy()
				StoneHit:Play()
			end
		end
	end

	waiting = false
	hit = false
	
	if toolEquipped then
		Idle:Play()
	end
end

EquipConnection = Tool.Equipped:Connect(equipTool)
UnequipConnection = Tool.Unequipped:Connect(unequipTool)






-- Folders --
local       Animations = Tool.Animations
local impactAnimations = Animations.impactAnimations
local  swingAnimations = Animations.swingAnimations
local       Sounds = Tool.Sounds
local ImpactSounds = Sounds.ImpactSounds
local  SwingSounds = Sounds.SwingSounds

-- Configuration --
local NUM_SWING_CHECKS = 5
local MAX_TOOL_RANGE = 15

-- Variables --
local impactAnimationTable = {}
local  swingAnimationTable = {}
local     impactSoundTable = {}
local      swingSoundTable = {}
local        idleAnimation = nil
local          hitDetected = false
local        currAnimation = nil
local            currSound = nil

-- Load Animations --
for _, newAnimation in pairs(impactAnimations:GetChildren()) do
    table.insert(impactAnimationTable, newAnimation)
end

for _, newAnimation in pairs(swingAnimations:GetChildren()) do
    table.insert(swingAnimationTable, newAnimation)
end

-- Load Sounds --
for _, newSound in pairs(ImpactSounds:GetChildren()) do
    table.insert(impactSoundTable, newSound)
end

for _, newSound in pairs(SwingSounds:GetChildren()) do
    table.insert(swingSoundTable, newSound)
end

-- Tool Functions --
local playRandomImpactAnimation
local playRandomSwingAnimation
local playRandomImpactSound
local playRandomSwingSound
local toolSwing
local toolOnHit


playRandomImpactAnimation = function()
    currAnimation = math.random(1, #impactAnimationTable)
    impactAnimationTable[currAnimation]:Play()
    return impactAnimationTable[currAnimation]
end

playRandomSwingAnimation = function()
    currAnimation = math.random(1, #swingAnimationTable)
    swingAnimationTable[currAnimation]:Play()
    return swingAnimationTable[currAnimation]
end

playRandomImpactSound = function()
    currSound = math.random(1, #impactSoundTable)
    impactSoundTable[currSound]:Play()
    return impactSoundTable[currSound]
end

playRandomSwingSound = function()
    currSound = math.random(1, #swingSoundTable)
    swingSoundTable[currSound]:Play()
    return swingSoundTable[currSound]
end

toolSwing = function()
    local anim = playRandomSwingAnimation()
    local sound = playRandomSwingSound()
	local animationTime = anim.length

    -- Delay initial detection --
	local t = tick()
	while (tick() - t) < animationTime / 2 do
		game:GetService("RunService").RenderStepped:Wait()		
	end

    -- Check for impacts --
	animationTime = animationTime / 2
    for i = 1, NUM_SWING_CHECKS do

        if Mouse.Target and Mouse.Target.Name == "BoundingBox" and not hitDetected then
            if (Character.HumanoidRootPart.Position - Mouse.Target.Position).Magnitude < MAX_TOOL_RANGE then
                hitDetected = true
                anim:Stop()
                toolOnHit()
                break
            end
        end

        	local t = tick()
	while (tick() - t) < animationTime / NUM_SWING_CHECKS do
		game:GetService("RunService").RenderStepped:Wait()		
	end
    end

    hitDetected = false
end

toolOnHit = function()
    local anim = playRandomImpactAnimation()
    local sound = playRandomImpactSound()
	local animationTime = anim.length()

    -- Delay initial detection --
    local t = tick()
	while t > animationTime / 2 do
        RunService.RenderStepped:Wait()
    end
end