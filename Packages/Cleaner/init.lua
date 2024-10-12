local Cleaner = {}
Cleaner.__index = Cleaner

function Cleaner.new(instance)
	local self = setmetatable({}, Cleaner)
	self._Objects = {}
	if instance then
		self:BindInstance(instance)
	end
	return self
end

function Cleaner:Add(value)
	if table.find(self._Objects, value) then
		return
	end
	table.insert(self._Objects, value)
end

function Cleaner:Destroy()
	for _, value in self._Objects do
		if typeof(value) == "function" then
			task.spawn(value)
		end
		if typeof(value) == "Instance" then
			value:Destroy()
		end
		if typeof(value) == "RBXScriptConnection" then
			value:Disconnect()
		end
		if typeof(value) == "table" then
			local func = value.Destroy
			if func and typeof(func) == "function" then
				func(value)
			end
		end
	end
	self._Objects = {}
end

function Cleaner:BindInstance(instance: Instance)
	return self:Add(instance.Destroying:Connect(function()
		self:Destroy()
	end))
end

return Cleaner
