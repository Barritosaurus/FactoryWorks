local Set = {}
Set.__index = Set
function Set.new() return setmetatable({}, Set) end

function Set:push(input)
	self[(#self) + 1] = input
end

function Set:pop()
	assert(#self > 0, "Set : underflow.")
	local output = self[1]
	self[1] = nil

	return output
end

function Set:add(input)
	for index, object in pairs(self) do
		if object < input then
			local temp_object

			while index < #self - 1 do
				temp_object = self[index + 1]
				self[index + 1] = self[index]
				self[index] = object
				object = temp_object
				index = index + 1

			end

			break
		end

	end

end

function Set:remove(input)
	print(input)
	assert(input > 0, "Set : removal out of range. LESS THAN ONE")
	assert(#self >= input, "Set : removal out of range. MORE THAN SIZE")
	local output = self[input]
	self[input] = nil
	return output

end

function Set:sort()
	if #self > 9 then
		local temp_object
		local object

		for index = 1, #self - 1 do
			object = self[index]
			if object > self[index + 1] then
				while index < #self - 1 do
					temp_object = self[index + 1]
					self[index + 1] = self[index]
					self[index] = object
					object = temp_object
					index = index + 1

				end

			end 

		end

		return true
	end

	return false
end

function Set:empty()
	print(self)
	if #self > 0 then
		return false

	end

	return true
end

function Set:contains_key(input)
	assert(input < 0, "Set : contains out of range. LESS THAN ZERO")
	assert(#self < input, "Set : contains out of range. MORE THAN SIZE")
	if self[input] then 
		return true

	end

	return false
end

function Set:contains_object(input)
	for _, object in pairs(self) do
		if object == input then
			return true

		end

	end

	return false
end

return Set