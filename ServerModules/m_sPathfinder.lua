local m_sPathfinder = {}


--------------
-- Services --
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-------------
-- Defines --
-------------
local FLOAT_MAX = 999999999999.99
local   INT_MAX = 999999999999
local     DEBUG = 1


---------------------
-- Data Structures --
---------------------
local Set = require(ReplicatedStorage.Server.ServerModules:WaitForChild("m_sSet"))


-----------
-- Types --
-----------
local n_pair = {}
n_pair.__index = n_pair
function n_pair.new(a, b) return setmetatable({first = a, second = b}, n_pair) end

local s_pair = {}
s_pair.__index = s_pair
function s_pair.new(a, b) return setmetatable({key = a, n_pair = b}, s_pair) end

local node = {}
node.__index = node
function node.new(p1, p2, f1, g1, h1) return setmetatable({parent_1 = p1, parent_2 = p2, f = f1, g = g1, h = h1}, node) end


---------------
-- Constants --
---------------
local MAX_ROW = nil
local MAX_COL = nil
local     MAP = nil


--------------------
-- Function Calls --
--------------------
local getEuclideanDistance
local getManhattanDistance
local getChebyshevDistance
local getDiagonalDistance
local nodeBoundsCheck
local nodeBlockedCheck
local nodeReached
local calculateHeuristic


--------------------------
-- Function Declaration --
--------------------------
getEuclideanDistance = function(a, b)
	return math.sqrt((a * a) + (b * b))
end

getManhattanDistance = function(a, b)
	return a + b
end

getChebyshevDistance = function(a, b)
	return math.max(a, b)
end

getDiagonalDistance = function(a, b)
	return 14 * math.max(a, b) + 10 * math.min(a, b)
end

getHeuristic = function(a, b, destination)
	return getEuclideanDistance(a * destination.first - a * destination.first, b * destination.second - b * destination.second)
end


----------------------
-- Module Functions --
----------------------
nodeBoundsCheck = function(row, col)
	return (row >= 1) and (row <= MAX_ROW) and (col >= 1) and (col <= MAX_COL)
end

nodeBlockedCheck = function(row, col)
	if MAP[row][col] then
		return true
	else
		return false
	end
end

nodeReached = function(row, col, destination)
	if row == destination.first and col == destination.second then
		return true
	else
		return false
	end
end

function m_sPathfinder:generatePath(source, destination)
	-- Check if initialized. --
	if MAP then
		
		-- Convert source and destination to pairs. --
		source = n_pair.new(source.x, source.y)
		destination = n_pair.new(destination.x, destination.y)

		
		-- Check Source / Destination for errors. --
		if not nodeBoundsCheck(source.first, source.second) then
			error("Pathfinder : Provided source node is out of range!")
		end

		if not nodeBoundsCheck(destination.first, destination.second) then
			error("Pathfinder : Provided destination node is out of range!")
		end

		if not nodeBlockedCheck(source.first, source.second) then
			error("Pathfinder : Source node is blocked / impassable!")
		end

		if not nodeBlockedCheck(destination.first, destination.second) then
			error("Pathfinder : Destination node is blocked / impassable!")
		end
		
		if DEBUG then
			print("Pathfinder DEBUG : Pathfinding started!")
		end
		
		
		-- Create node table. --
		local node_table = {}
		local temp_table = {}
		local a, b
		for a = 1, MAX_ROW do
			temp_table = {}
			for b = 1, MAX_COL do
				local new_node = node.new(-1, -1, FLOAT_MAX, FLOAT_MAX, FLOAT_MAX)
				table.insert(temp_table, new_node)
			end
			table.insert(node_table, temp_table)
		end
		
		
		-- Prepare initial node. --
		a = source.first
		b = source.second
		node_table[a][b].f = 0.0
		node_table[a][b].g = 0.0
		node_table[a][b].h = 0.0
		node_table[a][b].parent_1 = a
		node_table[a][b].parent_2 = b
		
		
		-- Create open set. --
		local open_list = Set.new()
		local set_pair = s_pair.new(0.0, n_pair.new(a, b))
		table.insert(open_list, set_pair)
		
		-- Create closed table. --
		local closed_list = {}
		for a = 1, MAX_ROW do
			table.insert(closed_list, table.create(MAX_COL, false))
		end
		
		
		-- Create core loop. --
		local found_destination = false
		local iterations = 0
		while #open_list > 0 do
			iterations = iterations + 1

			-- Declaration --
			local g_new, h_new, f_new
			
			-- Move to next best node. --
			local current_pair = open_list[1]
			table.remove(open_list, 1)
			
			-- Mark path as true. --
			a = current_pair.n_pair.first
			b = current_pair.n_pair.second
			closed_list[a][b] = true
			
			-- Check X - 1, Y - 0 (North)--
			if nodeBoundsCheck(a - 1, b) then
				if nodeReached(a - 1, b, destination) then
					
					-- Destination reached. --
					node_table[a - 1][b].parent_1 = a
					node_table[a - 1][b].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table
						
				elseif not closed_list[a - 1][b] and nodeBlockedCheck(a - 1, b) then
					
					-- Determine cost. --
					g_new = node_table[a][b].g + 1.0
					h_new = getHeuristic(a - 1, b, destination)
					f_new = g_new + h_new
					
					if node_table[a - 1][b].f == FLOAT_MAX or node_table[a - 1][b].f > f_new then
						
						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a - 1, b)))
						
						-- Set node information. --
						node_table[a - 1][b].f = f_new
						node_table[a - 1][b].g = g_new
						node_table[a - 1][b].h = h_new
						node_table[a - 1][b].parent_1 = a
						node_table[a - 1][b].parent_2 = b
						
					end
				end
			end
			
			-- Check X + 1, Y - 0 (South)--
			if nodeBoundsCheck(a + 1, b) then
				if nodeReached(a + 1, b, destination) then

					-- Destination reached. --
					node_table[a + 1][b].parent_1 = a
					node_table[a + 1][b].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table

				elseif not closed_list[a + 1][b] and nodeBlockedCheck(a + 1, b) then

					-- Determine cost. --
					g_new = node_table[a][b].g + 1.0
					h_new = getHeuristic(a + 1, b, destination)
					f_new = g_new + h_new

					if node_table[a + 1][b].f == FLOAT_MAX or node_table[a + 1][b].f > f_new then

						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a + 1, b)))

						-- Set node information. --
						node_table[a + 1][b].f = f_new
						node_table[a + 1][b].g = g_new
						node_table[a + 1][b].h = h_new
						node_table[a + 1][b].parent_1 = a
						node_table[a + 1][b].parent_2 = b

					end
				end
			end
			
			-- Check X - 0, Y + 1 (East)--
			if nodeBoundsCheck(a, b + 1) then
				if nodeReached(a, b + 1, destination) then

					-- Destination reached. --
					node_table[a][b + 1].parent_1 = a
					node_table[a][b + 1].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table

				elseif not closed_list[a][b + 1] and nodeBlockedCheck(a, b + 1) then

					-- Determine cost. --
					g_new = node_table[a][b].g + 1.0
					h_new = getHeuristic(a, b + 1, destination)
					f_new = g_new + h_new

					if node_table[a][b + 1].f == FLOAT_MAX or node_table[a][b + 1].f > f_new then

						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a, b + 1)))

						-- Set node information. --
						node_table[a][b + 1].f = f_new
						node_table[a][b + 1].g = g_new
						node_table[a][b + 1].h = h_new
						node_table[a][b + 1].parent_1 = a
						node_table[a][b + 1].parent_2 = b

					end
				end
			end
			
			-- Check X - 0, Y - 1 (West)--
			if nodeBoundsCheck(a, b - 1) then
				if nodeReached(a, b - 1, destination) then

					-- Destination reached. --
					node_table[a][b - 1].parent_1 = a
					node_table[a][b - 1].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table

				elseif not closed_list[a][b - 1] and nodeBlockedCheck(a, b - 1) then

					-- Determine cost. --
					g_new = node_table[a][b].g + 1.0
					h_new = getHeuristic(a, b - 1, destination)
					f_new = g_new + h_new

					if node_table[a][b - 1].f == FLOAT_MAX or node_table[a][b - 1].f > f_new then

						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a, b - 1)))

						-- Set node information. --
						node_table[a][b - 1].f = f_new
						node_table[a][b - 1].g = g_new
						node_table[a][b - 1].h = h_new
						node_table[a][b - 1].parent_1 = a
						node_table[a][b - 1].parent_2 = b

					end
				end
			end
			
			-- Check X - 1, Y + 1 (North-East)--
			if nodeBoundsCheck(a - 1, b + 1) then
				if nodeReached(a - 1, b + 1, destination) then

					-- Destination reached. --
					node_table[a - 1][b + 1].parent_1 = a
					node_table[a - 1][b + 1].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table

				elseif not closed_list[a - 1][b + 1] and nodeBlockedCheck(a - 1, b + 1) then

					-- Determine cost. --
					g_new = node_table[a][b].g + 1.414
					h_new = getHeuristic(a - 1, b + 1, destination)
					f_new = g_new + h_new

					if node_table[a - 1][b + 1].f == FLOAT_MAX or node_table[a - 1][b + 1].f > f_new then

						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a - 1, b + 1)))

						-- Set node information. --
						node_table[a - 1][b + 1].f = f_new
						node_table[a - 1][b + 1].g = g_new
						node_table[a - 1][b + 1].h = h_new
						node_table[a - 1][b + 1].parent_1 = a
						node_table[a - 1][b + 1].parent_2 = b

					end
				end
			end
			
			-- Check X - 1, Y - 1 (North-West)--
			if nodeBoundsCheck(a - 1, b - 1) then
				if nodeReached(a - 1, b - 1, destination) then

					-- Destination reached. --
					node_table[a - 1][b - 1].parent_1 = a
					node_table[a - 1][b - 1].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table

				elseif not closed_list[a - 1][b - 1] and nodeBlockedCheck(a - 1, b - 1) then

					-- Determine cost. --
					g_new = node_table[a][b].g + 1.414
					h_new = getHeuristic(a - 1, b - 1, destination)
					f_new = g_new + h_new

					if node_table[a - 1][b - 1].f == FLOAT_MAX or node_table[a - 1][b - 1].f > f_new then

						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a - 1, b - 1)))

						-- Set node information. --
						node_table[a - 1][b - 1].f = f_new
						node_table[a - 1][b - 1].g = g_new
						node_table[a - 1][b - 1].h = h_new
						node_table[a - 1][b - 1].parent_1 = a
						node_table[a - 1][b - 1].parent_2 = b

					end
				end
			end
			
			-- Check X + 1, Y + 1 (South-East)--
			if nodeBoundsCheck(a + 1, b + 1) then
				if nodeReached(a + 1, b + 1, destination) then

					-- Destination reached. --
					node_table[a + 1][b + 1].parent_1 = a
					node_table[a + 1][b + 1].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table

				elseif not closed_list[a + 1][b + 1] and nodeBlockedCheck(a + 1, b + 1) then

					-- Determine cost. --
					g_new = node_table[a][b].g + 1.414
					h_new = getHeuristic(a + 1, b + 1, destination)
					f_new = g_new + h_new

					if node_table[a + 1][b + 1].f == FLOAT_MAX or node_table[a + 1][b + 1].f > f_new then

						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a + 1, b + 1)))

						-- Set node information. --
						node_table[a + 1][b + 1].f = f_new
						node_table[a + 1][b + 1].g = g_new
						node_table[a + 1][b + 1].h = h_new
						node_table[a + 1][b + 1].parent_1 = a
						node_table[a + 1][b + 1].parent_2 = b

					end
				end
			end
			
			-- Check X + 1, Y - 1 (South-West)--
			if nodeBoundsCheck(a + 1, b - 1) then
				if nodeReached(a + 1, b - 1, destination) then

					-- Destination reached. --
					node_table[a + 1][b - 1].parent_1 = a
					node_table[a + 1][b - 1].parent_2 = b
					found_destination = true
					if DEBUG == 1 or 2 then
						print("Pathfinder DEBUG : Destination found!")
					end
					return node_table

				elseif not closed_list[a + 1][b - 1] and nodeBlockedCheck(a + 1, b - 1) then

					-- Determine cost. --
					g_new = node_table[a][b].g + 1.414
					h_new = getHeuristic(a + 1, b - 1, destination)
					f_new = g_new + h_new

					if node_table[a + 1][b - 1].f == FLOAT_MAX or node_table[a + 1][b - 1].f > f_new then

						-- Add node to open set. --
						table.insert(open_list, s_pair.new(f_new, n_pair.new(a + 1, b - 1)))

						-- Set node information. --
						node_table[a + 1][b - 1].f = f_new
						node_table[a + 1][b - 1].g = g_new
						node_table[a + 1][b - 1].h = h_new
						node_table[a + 1][b - 1].parent_1 = a
						node_table[a + 1][b - 1].parent_2 = b

					end
				end
			end
			
			table.sort(open_list, function(a, b)
				return a.key < b.key
			end)
			
			if DEBUG == 2 then
				print("Pathfinder DEBUG : Iteration ", iterations, " Path - ", open_list)
			end
		end
		
		-- Error on failure. --
		if not found_destination then
			error("Pathfinder : Was unable to find the destination within the table!")
		end
		
		
	else
		-- Error without initialization. --
		error("Pathfinder : m_sPathfinder must be initialized with a 2D bool table to function, please use m_sPathfinder:initializePath(table)!")
	end
	
end

function m_sPathfinder:initializePath(map, rows, cols)
	MAX_ROW = rows
	MAX_COL = cols
	MAP = map
	
	if DEBUG == 2 then
		print("Pathfinder DEBUG : Provided MAX_ROW is ", MAX_ROW)
		print("Pathfinder DEBUG : Provided MAX_COL is ", MAX_COL)
		print("Pathfinder DEBUG : Provided MAP is ", MAP)
	end
end

function m_sPathfinder:testRun()
	local grid = {
	{ 1, 0, 1, 1, 1, 1, 0, 1, 1, 1 },
	{ 1, 1, 1, 0, 1, 1, 1, 0, 1, 1 },
	{ 1, 1, 1, 0, 1, 1, 0, 1, 0, 1 },
	{ 0, 0, 1, 0, 1, 0, 0, 0, 0, 1 },
	{ 1, 1, 1, 0, 1, 1, 1, 0, 1, 0 },
	{ 1, 0, 1, 1, 1, 1, 0, 1, 0, 0 },
	{ 1, 0, 0, 0, 0, 1, 0, 0, 0, 1 },
	{ 1, 0, 1, 1, 1, 1, 0, 1, 1, 1 },
	{ 1, 1, 1, 0, 0, 0, 1, 0, 0, 1 }
	}
	local source = Vector2.new(1, 9)
	local destination = Vector2.new(1, 1)
	
	m_sPathfinder:initializePath(grid, 10, 9)
	m_sPathfinder:generatePath(source, destination)
end

return m_sPathfinder
