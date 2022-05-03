local m_sCaveGenerator = {}


--------------
-- Services --
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")


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


---------------
-- Gamespace --
---------------
local CurrentMap = workspace.CurrentMap


-------------
-- Defines --
-------------
local FLOAT_MAX = 999999999999.99
local   INT_MAX = 999999999999
local     DEBUG = 1


------------
-- Config --
------------
local     MAX_ROOMS = 1028 -- Max is 4000
local   X_DIMENSION = 256	
local   Y_DIMENSION = 256 
local       X_START = 0    -- Keep these within bounds.
local       Y_START = 1977
local	    Z_START = 0
local    MAX_FLOORS = 1    -- Floors will always be connected by a entrance and exit, you may choose where the initial entrance is.
local     ROOM_SIZE = 32   -- This generation is limited by size, you must maintain an equal sizing of 32 x 32 x 32.
local          Wall = ReplicatedStorage.Wall
local         Empty = ReplicatedStorage.Empty
local          Exit = ReplicatedStorage.Exit
local      Entrance = ReplicatedStorage.Entrance
local 		   Path = ReplicatedStorage.Path


---------------
-- Constants --
---------------
local 	    MAX_ROW = nil
local       MAX_COL = nil
local    X_MIDPOINT = math.floor(X_DIMENSION / 2)
local    Y_MIDPOINT = math.floor(Y_DIMENSION / 2)


---------------
-- Variables --
---------------
local   current_map = {}
local  total_models = 0
local current_rooms = 0
local    new_object = nil
local     floor_num = 1
local        curr_x = X_START
local        curr_y = Z_START
local         end_x = 0
local         end_y = 0


-------------
-- Objects --
-------------
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


------------
-- Tables --
------------
local dungeon_graph = {}
local room_table = {}
local wall_bounds = {
	[1] = {x = -1, y = -1},
	[2] = {x = 0, y = -1},
	[3] = {x = 1, y = -1},
	[4] = {x = -1, y = 0},
	[5] = {x = 1, y = 0},
	[6] = {x = -1, y = 1},
	[7] = {x = 0, y = 1},
	[8] = {x = 1, y = 1}
}


---------------------------
-- Function Declarations --
---------------------------
local createRoom
local determineRoom
local determinePlacement
local generateFloor


----------------------
-- Helper Functions --
----------------------
createRoom = function(x, y)
	local newRoom = Room.new()

	newRoom.x = x
	newRoom.y = y
	table.insert(room_table, newRoom)
	dungeon_graph[x][y] = true
	current_rooms += 1

	return newRoom
end

determineRoom = function(x, y)
	for _, bounds in pairs(wall_bounds) do
		if not dungeon_graph[x + bounds.x][y + bounds.y] then
			local position = Vector3.new(ROOM_SIZE * (x - X_MIDPOINT + bounds.x), Y_START - (ROOM_SIZE * (floor_num - 1)), ROOM_SIZE * (y - Y_MIDPOINT + bounds.y))
			local new_object = Wall:Clone()

			new_object.Parent = CurrentMap.Generated
			new_object.Position = position
		end
	end
end

determinePlacement = function(room, direction)
	if current_rooms >= MAX_ROOMS then return end
	
	if direction == 1 and room.y - 1 > 1 then
		-- 'Upwards'
		if not dungeon_graph[room.x][room.y - 1] then
			determinePlacement(createRoom(room.x, room.y - 1), math.random(1, 4))
		else
			determinePlacement(Vector2.new(room.x, room.y - 1), math.random(1, 4)) -- dungeon_graph[room.x][room.y - 1]
		end
		
	elseif direction == 2 and room.x + 1 <= X_DIMENSION then
		-- 'Right'
		if not dungeon_graph[room.x + 1][room.y] then
			determinePlacement(createRoom(room.x + 1, room.y), math.random(1, 4))
		else
			determinePlacement(Vector2.new(room.x + 1, room.y), math.random(1, 4)) -- dungeon_graph[room.x + 1][room.y]
		end
		
	elseif direction == 3 and room.y + 1 <= Y_DIMENSION then
		-- 'Down'
		if not dungeon_graph[room.x][room.y + 1] then
			determinePlacement(createRoom(room.x, room.y + 1), math.random(1, 4))
		else
			determinePlacement(Vector2.new(room.x, room.y + 1), math.random(1, 4)) -- dungeon_graph[room.x][room.y + 1]
		end
		
	elseif direction == 4 and room.x - 1 > 1 then
		-- 'Left'
		if not dungeon_graph[room.x - 1][room.y] then
			determinePlacement(createRoom(room.x - 1, room.y), math.random(1, 4))
		else
			determinePlacement(Vector2.new(room.x - 1, room.y), math.random(1, 4)) -- dungeon_graph[room.x - 1][room.y]
		end
		
	else
		determinePlacement(room, math.random(1, 4))
	end
	
end

generateFloor = function()
	dungeon_graph = {}
	room_table = {}
	
	-- Prepare table --
	dungeon_graph = table.create(X_DIMENSION)
	for x = 1, X_DIMENSION + 2 do
		local yTable = table.create(Y_DIMENSION + 2, false)
		dungeon_graph[x] = yTable
	end
	
	-- Set center room --
	local center_room = Room.new()
	center_room.x = X_MIDPOINT
	center_room.y = Y_MIDPOINT
	table.insert(room_table, center_room)
	dungeon_graph[X_MIDPOINT][Y_MIDPOINT] = true
	current_rooms += 1
	
	-- Begin generation --
	local direction = math.random(1, 4)
	determinePlacement(center_room, direction)
	
	-- Populate floors with models --
	for x = 1, #room_table do
		if room_table[x] then
			local position = Vector3.new(ROOM_SIZE * (room_table[x].x - X_MIDPOINT), Y_START - (ROOM_SIZE * (floor_num - 1)), ROOM_SIZE * (room_table[x].y - Y_MIDPOINT))
			determineRoom(room_table[x].x, room_table[x].y)

			if x == 1 then
				new_object = Entrance:Clone()
				curr_x = room_table[x].x
				curr_y = room_table[x].y
				total_models += 1

			elseif x == #room_table then
				new_object = Exit:Clone()
				end_x = room_table[x].x
				end_y = room_table[x].y
				total_models += 1

			else
				new_object = Empty:Clone()
				total_models += 1

			end

			new_object.Parent = workspace
			new_object.Position = position

		end

	end
	
	
	floor_num += 1
	current_rooms = 0
	X_MIDPOINT = room_table[#room_table].x
	Y_MIDPOINT = room_table[#room_table].y

	table.insert(current_map, dungeon_graph)
end


----------------------
-- Module Functions --
----------------------
function m_sCaveGenerator:getNumFloors()
	return MAX_FLOORS
end

function m_sCaveGenerator:getFloorMap()
	return current_map
end

function m_sCaveGenerator:getFloor(y)
	return math.ceil(math.abs((y - Y_START) / ROOM_SIZE))
end

function m_sCaveGenerator:getXY()
	return Vector2.new(X_DIMENSION, Y_DIMENSION)
end

function m_sCaveGenerator:generateCave()
	
	if DEBUG == 1 then
		print("Generation DEBUG : Beginning generation of ", MAX_FLOORS, " floors...")
	end
	
	for i = 1, MAX_FLOORS do
		generateFloor()
	end
	
	if DEBUG == 1 then
		print("Generation DEBUG : Finished generation of ", MAX_FLOORS, " floors! Total models added : ", total_models)
	end
end

return m_sCaveGenerator
