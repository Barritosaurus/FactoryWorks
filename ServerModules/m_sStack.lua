local Stack = {}
Stack.__index = Stack
function Stack.new() return setmetatable({}, Stack) end

-- put a new object onto a stack
function Stack:push(input)
	print(#self)
	self[(#self) + 1] = input
end
-- take an object off a stack
function Stack:pop()
	assert(#self > 0, "Stack underflow")
	local output = self[#self]
	self[#self] = nil
	return output
end

return Stack