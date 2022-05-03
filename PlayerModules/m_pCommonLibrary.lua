-- POLI Common Library Version 1.0 --
local CommonLibrary = {}

function CommonLibrary.formatNumberToProper(number)
	return "$"..number:reverse():gsub("...","%0,",math.floor((#number - 1 ) / 3)):reverse()
end

function CommonLibrary.wipeConnections(connections)
	for _, connection in pairs(connections) do
		connection:Disconnect()
	end
end

function CommonLibrary.floatMod(a, b)
	local mod
	if a < 0 then
		mod = -a
	else
		mod = a
	end
	if b < 0 then
		b = -b
	end
	while mod >= b do
		mod = mod - b
	end
	if a < 0 then
		return -mod
	end
	
	return mod
end

return CommonLibrary
