local Data = {}
Data.__index = Data

function Data.new(dataTable: table)
	local self = setmetatable({}, Data)
	self.Data = dataTable or {}
	return self
end

function Data:Set(path, value)
	self.Data[path] = value
	return value
end

function Data:Get(path)
	return self.Data[path]
end

function Data:Increment(path, amount)
	return self:Set(path, (self:Get(path) or 0) + (amount or 1))
end

return Data
