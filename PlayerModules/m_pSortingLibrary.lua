-- POLI Sorting / Searching Library Version 1.0 --
local SortingTable = {}
function SortingTable.GetDamerauLeveshteinDistance(searchText, currentItemName)
	-- Finds the 'distance' from one string to another, basically allows us to have a modest fuzzy-search.
	local searchStringSize = #searchText
	local itemStringSize = #currentItemName
	local insertion
	local deletion
	local subsitution
	local normal
	local transposition
	local comparisonTable = {}
	for indexR = 0, searchStringSize do
		comparisonTable[indexR] = {}
		for indexC = 0, itemStringSize do
			comparisonTable[indexR][indexC] = 0
		end
	end
	for index = 1, searchStringSize do
		comparisonTable[index][0] = index
	end
	for index = 1, itemStringSize do
		comparisonTable[0][index] = index
	end
	for indexR = 1, searchStringSize do
		for indexC = 1, itemStringSize do
			if (searchText:byte(indexR) == currentItemName:byte(indexR)) then
				comparisonTable[indexR][indexC] = comparisonTable[indexR - 1][indexC - 1]
			else
				insertion = comparisonTable[indexR][indexC - 1] + 1
				deletion = comparisonTable[indexR - 1][indexC] + 1
				subsitution = comparisonTable[indexR - 1][indexC - 1] + 1
				comparisonTable[indexR][indexC] = math.min(insertion, deletion, subsitution)
			end
			if indexR > 1 and indexC > 1 and searchText:byte(indexR) == currentItemName:byte(indexC) and searchText[indexR - 1] == currentItemName[indexC] then
				normal = comparisonTable[indexR][indexC]
				transposition = comparisonTable[indexR - 2][indexC - 2] + 1
				comparisonTable[indexR][indexC] = math.min(normal, transposition)
			end
		end
	end
	insertion = nil
	deletion = nil
	subsitution = nil
	normal = nil
	transposition = nil
	return comparisonTable[searchStringSize][itemStringSize]
end

function SortingTable.FixStringForComparison(currentWord, comparisonString)
	if #currentWord > #comparisonString then
		local requiredLength = #currentWord - #comparisonString
		for iterator = 1, requiredLength do
			if currentWord:byte(iterator) ~= comparisonString:byte(iterator) then
				comparisonString = "_"..comparisonString
			else
				comparisonString = comparisonString.."_"
			end
		end
		requiredLength = nil
		return comparisonString
	else
		return comparisonString
	end
end

function SortingTable.DeepCopy(original)
	-- Allows for us to use the object 'struct'.
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = SortingTable.DeepCopy(v)
		end
		copy[k] = v 
	end
	return copy
end

function SortingTable.ResizeWindow(currentWindow, yAbsolute)
	-- This function resizes the inventory's scale to remain consistent regardless of items stored.
	currentWindow.CanvasSize = UDim2.new(0, 0, 0, yAbsolute + 0.25)
end

function SortingTable.SearchByText(searchText, currentItems, currentWindow)
	-- This function will sort and exclude by a given search enty searchText until a match is found, or no valid match is found.
	if searchText == "n/a" then
		-- Reset inventory once search bar is empty.
		for _, currentItem in pairs(currentItems:GetChildren())do
			if not currentItem:IsA("UIGridLayout") then
				currentItem.Visible = true
			end
		end
		SortingTable.ResizeWindow(currentWindow, currentWindow.AbsoluteSize.Y)
		return
	end
	for _, currentItem in pairs(currentItems:GetChildren()) do
		-- Find objects such that name is valid to searchText.	
		if not currentItem:IsA("UIGridLayout") and #(currentItem.Name) >= #searchText then
			if string.sub(currentItem.ItemName.Text:lower(), 1, #searchText) == searchText:lower() then
				currentItem.Visible = true
			else
				for _, currentWord in pairs(string.split(currentItem.ItemName.Text, " ")) do
					if SortingTable.GetDamerauLeveshteinDistance(currentWord:lower(), SortingTable.FixStringForComparison(currentWord, searchText:lower())) < 3 then
						currentItem.Visible = true
						break
					else
						currentItem.Visible = false
					end
				end
			end
		end
	end
	SortingTable.ResizeWindow(currentWindow, currentWindow.AbsoluteSize.Y)
end

function SortingTable.SortByType(sortType, currentItems)
	-- This function will sort by type, excluding those that are not within sortType.
	for _, currentItem in pairs(currentItems) do
		-- Find objects such that name is valid to searchText.
		if currentItem.Type == sortType then
			--currentItem.Visible = true
			print("Item with matching type Found!")
		else
			--currentItem.Visible = false
		end
	end
end

function SortingTable.SortByValue(givenTable, sortedByHighestValue)
	-- This function will sort by numeric value dominance (0 - 999,999) or (999,099 - 0).
	if sortedByHighestValue then
		sortedByHighestValue = false
		table.sort(givenTable, function(a,b) return a.Value < b.Value end)
	else
		sortedByHighestValue = true
		table.sort(givenTable, function(a,b) return a.Value > b.Value end)
	end
end

function SortingTable.SortByName(givenTable, sortedByHighestAlphabet)
	-- This function will sort by alphabetic dominance (A - Z) or (Z - A).
	if sortedByHighestAlphabet then
		sortedByHighestAlphabet = false
		table.sort(givenTable, function(a,b) return string.sub(a.Name:lower(), 1, 1) > string.sub(b.Name:lower(), 1, 1) end)
	else
		sortedByHighestAlphabet = true
		table.sort(givenTable, function(a,b) return string.sub(a.Name:lower(), 1, 1) < string.sub(b.Name:lower(), 1, 1) end)
	end
end

return SortingTable
