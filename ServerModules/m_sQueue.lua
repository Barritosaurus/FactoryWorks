local Queue = {}
Queue.__index = Queue

function Queue.new() return setmetatable({}, Queue) end

function Queue:push(input)
	self[(#self) + 1] = input
end

function Queue:remove(input)
	assert(input < 0, "Queue : removal out of range. LESS THAN ZERO")
	assert(#self < input, "Queue : removal out of range. MORE THAN SIZE")
	local output = self[input]
	self[input] = nil
	return output
end

function Queue:pop()
	assert(#self > 0, "Queue : underflow.")
	local output = self[1]
	self[1] = nil
	return output
end

return Queue