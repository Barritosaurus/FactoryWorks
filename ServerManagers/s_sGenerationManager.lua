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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local        RunService = game:GetService('RunService')
local           Players = game:GetService("Players")

-- Replicated Storage --
local      ServerEvents = ReplicatedStorage.Server.ServerEvents
local     ServerModules = ReplicatedStorage.Server.ServerModules
local   ServerFunctions = ReplicatedStorage.Server.ServerFunctions

-- Gamespace --
local        CurrentMap = workspace.CurrentMap

-- Data Structures --
local Stack = require(ServerModules:WaitForChild("m_sStack"))
local Queue = require(ServerModules:WaitForChild("m_sQueue"))
local Pathfinder = require(ServerModules:WaitForChild("m_sPathfinder"))
local Generator = require(ServerModules:WaitForChild("m_sCaveGenerator"))

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


------------------------------------
------------------------------------
 -- NATURAL GENERATION FUNCTIONS --
------------------------------------
------------------------------------
--[[
-- Script Values --
local       nodeGraph = {}
local      modelTable = {}
local    fullNodeList = {}
local connectionTable = {}
local initialNodeList = {}

-- Config Values --
local MAX_CONNECTIONS = 6
local SMOOTH_ITERATIONS = 16
local     X_DIMENSION = 96
local     Z_DIMENSION = 96
local       CUBE_SIZE = 32
local   PERCENT_WALLS = 48
local object = ReplicatedStorage.Stone -- TEMP

local function RandomPercent(percent)
	local random = Random.new()
	if percent >= random:NextInteger(1, 101) then
		return 1
	end
	
	return 0
end

local function BoundsCheck(x, z)
	if x < 1 or z < 1 then
		return true
	elseif x > X_DIMENSION - 1 or z > Z_DIMENSION - 1 then
			
		return true
	end
	
	return false
end

local function WallCheck(x, z)
	if BoundsCheck(x, z) then
		return true
	end
	
	if nodeGraph[x][z] == 1 then
		return true
	end
	
	return false
end

local function GetAdjacentWalls(x, z, sx, sz)
	local startX = x - sx
	local startZ = z - sz
	local endX = x + sx
	local endZ = z + sz
	local wallCount = 0
	
	for iz = startZ, endZ do
		for ix = startX, endX do
			if not (ix == x and iz == z) then
				if WallCheck(ix, iz) then
					wallCount += 1
				end
			end
		end
	end
	
	return wallCount
end

local function PlaceWall(x, z)
	local wallCount = GetAdjacentWalls(x, z, 1, 1)
	
	if nodeGraph[x][z] == 1 then
		if wallCount >= 4 then
			return 1
		end
		
		if wallCount < 2 then
			return 0
		end
	else
		if wallCount >= 5 then
			return 1
		end
	end
end

local function MakeCaverns()
	for x = 1, X_DIMENSION do
		for z = 1, Z_DIMENSION do
			nodeGraph[x][z] = PlaceWall(x, z)
		end
	end
end


local function RandomFillMap()
	nodeGraph = table.create(X_DIMENSION)
	for x = 1, X_DIMENSION do
		local zTable = table.create(Z_DIMENSION, 0)
		nodeGraph[x] = zTable
	end
	
	local mapMiddle
	for x = 1, X_DIMENSION do
		for z = 1, Z_DIMENSION do
			if z == 0 then
				nodeGraph[x][z] = 1
			elseif x == 0 then
				nodeGraph[x][z] = 1
			elseif z == Z_DIMENSION - 1 then
				nodeGraph[x][z] = 1
			elseif x == X_DIMENSION - 1 then
				nodeGraph[x][z] = 1
			else
				mapMiddle = Z_DIMENSION / 2
				
				if z == mapMiddle then
					nodeGraph[x][z] = 0
				else
					nodeGraph[x][z] = RandomPercent(PERCENT_WALLS)
				end
			end
		end
	end
	
	for x = 0, SMOOTH_ITERATIONS do
		MakeCaverns()
	end
end
]]--



----------------------------------------
----------------------------------------
 -- ISAAC-STYLE GENERATION FUNCTIONS --
----------------------------------------
----------------------------------------
--[[

-- Variables --
local MAX_ROOMS = 4
local MIN_ROOMS = 2
local X_SIZE = 128
local Z_SIZE = 128
local MIDPOINT = {x = math.floor(X_SIZE / 2), z = math.floor(Z_SIZE / 2)}
local MazeRandom = Random.new()
local mazeRunning = true

-- Objects --
local doors = {
	north = nil,
	east = nil,
	south = nil,
	west = nil
}
local mazeObject = {
	x = 0,
	z = 0,
	doors = nil
}


-- Tables --
local treeMaze = {}
local mazeGraph = {}

-- Functions --
local GenerateBinaryTreeMaze
local MazeDeterminePlacement
local MazeCreateRoom

MazeCreateRoom = function(x, z)
	local newRoom = deepCopy(mazeObject)
	local roomDoors = deepCopy(doors)

	newRoom.x = x
	newRoom.z = z
	newRoom.doors = roomDoors

	table.insert(treeMaze, newRoom)
	mazeGraph[x][z] = true
	
	return newRoom
end

MazeDeterminePlacement = function(currRoom, direction)
	if not currRoom then return end
	if direction == 1 then -- north
		if currRoom.z - 1 > 0 then
			if mazeGraph[currRoom.x][currRoom.z - 1] == false then
				MazeCreateRoom(currRoom.x, currRoom.z - 1)
			end
		end
	end
	if direction == 2 then -- east
		if currRoom.x - 1 > 0 then
			if mazeGraph[currRoom.x - 1][currRoom.z] == false then
				MazeCreateRoom(currRoom.x - 1, currRoom.z)
			end
		end
	end
	if direction == 3 then -- south
		if currRoom.z + 1 < Z_SIZE then
			if mazeGraph[currRoom.x][currRoom.z + 1] == false then
				MazeCreateRoom(currRoom.x, currRoom.z + 1)
			end
		end
	end
	if direction == 4 then -- west
		if currRoom.x + 1 < Z_SIZE then
			if mazeGraph[currRoom.x + 1][currRoom.z] == false then
				MazeCreateRoom(currRoom.x + 1, currRoom.z)
			end
		end
	end
	if #treeMaze >= MAX_ROOMS then
		mazeRunning = false
	end
	
	MazeDeterminePlacement(currRoom, math.random(1, 4))
end

GenerateBinaryTreeMaze = function()
	math.randomseed(678678)
	mazeGraph = table.create(X_SIZE)
	for x = 1, X_SIZE do
		local zTable = table.create(Z_SIZE, false)
		mazeGraph[x] = zTable
	end
	
	local centerRoom = deepCopy(mazeObject)
	local centerDoors = deepCopy(doors)
	local skew = {math.random(1, 2), math.random(3, 4)}
	local direction
	
	centerRoom.x = MIDPOINT.x
	centerRoom.z= MIDPOINT.z
	centerRoom.doors = centerDoors
	
	table.insert(treeMaze, centerRoom)
	mazeGraph[centerRoom.x][centerRoom.z] = true
	
	local count = 0
	while count < 500 do
		direction = math.random(1, 2)
		MazeDeterminePlacement(centerRoom, skew[direction])
		if not mazeRunning then
			break
		end
		count += 1
	end
end
]]--




------------------------------------------
------------------------------------------
 -- DUNGEON-STYLE GENERATION FUNCTIONS --
------------------------------------------
------------------------------------------
-- Variables --
local     MAX_ROOMS = 2048
local CURRENT_ROOMS = 0
local   X_DIMENSION = 128	
local   Y_DIMENSION = 128
local    X_MIDPOINT = math.floor(X_DIMENSION / 2)
local    Y_MIDPOINT = math.floor(Y_DIMENSION / 2)
local    MAX_FLOORS = 1
local     CUBE_SIZE = 32
local          Wall = ReplicatedStorage.Wall -- TEMP
local         Empty = ReplicatedStorage.Empty
local          Exit = ReplicatedStorage.Exit
local      Entrance = ReplicatedStorage.Entrance
local 		   Path = ReplicatedStorage.Path

local total_models = 0


-- Objects --
local newObject
local floorNum = 1
local Room = {
	x = 0,
	y = 0,
	Doors = {
		Door1 = nil,
		Door2 = nil,
		Door3 = nil,
		Door4 = nil
	}
}
Room.__index = Room
function Room.new() return setmetatable({}, Room) end


-- Tables --
local dungeonGraph = {}
local roomTable = {}
local wallBounds = {
	[1] = {x = -1, y = -1},
	[2] = {x = 0, y = -1},
	[3] = {x = 1, y = -1},
	[4] = {x = -1, y = 0},
	[5] = {x = 1, y = 0},
	[6] = {x = -1, y = 1},
	[7] = {x = 0, y = 1},
	[8] = {x = 1, y = 1}
}


-- Functions --
local GenerateDungeon
local DeterminePlacement
local DetermineRoom
local CreateRoom

CreateRoom = function(x, y)
	local newRoom = Room.new()
	
	newRoom.x = x
	newRoom.y = y

	--table.insert(dungeonGraph, newRoom)
	table.insert(roomTable, newRoom)
	dungeonGraph[x][y] = true
	CURRENT_ROOMS += 1
	
	return newRoom
end

DetermineRoom = function(x, y)
	for _, bounds in pairs(wallBounds) do
		if not dungeonGraph[x + bounds.x][y + bounds.y] then
			local position = Vector3.new(CUBE_SIZE * (x + bounds.x), Wall.Position.Y + -(CUBE_SIZE * floorNum), CUBE_SIZE * (y + bounds.y))
			local new_object = Wall:Clone()
			
			new_object.Parent = CurrentMap.Generated
			new_object.Position = position
		end
	end
end

DeterminePlacement = function(room, direction)
	if CURRENT_ROOMS >= MAX_ROOMS then return end
	if direction == 1 and room.y - 1 > 1 then
		-- 'Upwards'
		if not dungeonGraph[room.x][room.y - 1] then
			DeterminePlacement(CreateRoom(room.x, room.y - 1), math.random(1, 4))
		else
			DeterminePlacement(Vector2.new(room.x, room.y - 1), math.random(1, 4)) -- dungeonGraph[room.x][room.y - 1]
		end
	elseif direction == 2 and room.x + 1 <= X_DIMENSION then
		-- 'Right'
		if not dungeonGraph[room.x + 1][room.y] then
			DeterminePlacement(CreateRoom(room.x + 1, room.y), math.random(1, 4))
		else
			DeterminePlacement(Vector2.new(room.x + 1, room.y), math.random(1, 4)) -- dungeonGraph[room.x + 1][room.y]
		end
	elseif direction == 3 and room.y + 1 <= Y_DIMENSION then
		-- 'Down'
		if not dungeonGraph[room.x][room.y + 1] then
			DeterminePlacement(CreateRoom(room.x, room.y + 1), math.random(1, 4))
		else
			DeterminePlacement(Vector2.new(room.x, room.y + 1), math.random(1, 4)) -- dungeonGraph[room.x][room.y + 1]
		end
	elseif direction == 4 and room.x - 1 > 1 then
		-- 'Left'
		if not dungeonGraph[room.x - 1][room.y] then
			DeterminePlacement(CreateRoom(room.x - 1, room.y), math.random(1, 4))
		else
			DeterminePlacement(Vector2.new(room.x - 1, room.y), math.random(1, 4)) -- dungeonGraph[room.x - 1][room.y]
		end
	else
		DeterminePlacement(room, math.random(1, 4))
	end
end

GenerateDungeon = function()
	dungeonGraph = table.create(X_DIMENSION)
	for x = 1, X_DIMENSION + 2 do
		local yTable = table.create(Y_DIMENSION + 2, false)
		dungeonGraph[x] = yTable
	end

	local centerRoom = Room.new()
	
	centerRoom.x = X_MIDPOINT
	centerRoom.y = Y_MIDPOINT
	
	--table.insert(dungeonGraph, centerRoom)
	table.insert(roomTable, centerRoom)
	dungeonGraph[X_MIDPOINT][Y_MIDPOINT] = true
	CURRENT_ROOMS += 1
	
	local direction = math.random(1, 4) --newRandom:NextInteger(1, 4)
	DeterminePlacement(centerRoom, direction)
end

-------------------------
-------------------------
 -- HANDLER FUNCTIONS --
-------------------------
-------------------------

print("Beginning generation of ", MAX_FLOORS, " floors...")
local start_x = 0
local start_y = 0
local end_x = 0
local end_y = 0
for i = 1, MAX_FLOORS do
	dungeonGraph = {}
	roomTable = {}
	
	GenerateDungeon()
	
	for x = 1, #roomTable do
		if roomTable[x] then
			
			local position = Vector3.new(CUBE_SIZE * roomTable[x].x, Wall.Position.Y + -(CUBE_SIZE * floorNum), CUBE_SIZE * roomTable[x].y)
			DetermineRoom(roomTable[x].x, roomTable[x].y)


			if x == 1 then
				newObject = Entrance:Clone()
				start_x = roomTable[x].x
				start_y = roomTable[x].y
				total_models += 1
			elseif x == #roomTable then
				newObject = Exit:Clone()
				end_x = roomTable[x].x
				end_y = roomTable[x].y
				total_models += 1
			else
				newObject = Empty:Clone()
				total_models += 1
			end

			newObject.Parent = workspace
			newObject.Position = position
		end
	end
	
	floorNum += 1
	CURRENT_ROOMS = 0
	X_MIDPOINT = roomTable[#roomTable].x
	Y_MIDPOINT = roomTable[#roomTable].y
	
	--table.clear(dungeonGraph)
	table.clear(roomTable)
end
print("Finished generation of ", MAX_FLOORS, " floors! Total models added : ", total_models)
Pathfinder:initializePath(dungeonGraph, X_DIMENSION, Y_DIMENSION)
local cell = Pathfinder:generatePath(Vector2.new(start_x, start_y), Vector2.new(end_x, end_y))
local row = end_x
local col = end_y

local path = {}
while not (cell[row][col].parent_1 == row and cell[row][col].parent_2 == col) do
	local newVec = Vector2.new(row, col)
	--Path.push(newVec)
	table.insert(path, newVec)
	local temp_row = cell[row][col].parent_1
	local temp_col = cell[row][col].parent_2
	row = temp_row
	col = temp_col
end

while #path > 0 do
	local point = path[#path] --Path.pop()
	table.remove(path, #path)
	local position = Vector3.new(CUBE_SIZE * point.x, Wall.Position.Y + -(CUBE_SIZE * floorNum), CUBE_SIZE * point.y)
	newObject = Path:Clone()
	newObject.Parent = workspace
	newObject.Position = position
	wait(0.25)
end




--Generator:generateCave()
