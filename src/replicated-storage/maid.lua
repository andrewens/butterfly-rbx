--[[
    Implement Maid object, which holds other objects / methods for cleanup later.
]]

-- private
local function isValidTask(value)
	if typeof(value) == "table" then
		return typeof(value.Destroy) == "function"
	end
	return typeof(value) == "function" or typeof(value) == "Instance" or typeof(value) == "RBXScriptConnection"
end
local function assertIsValidTask(value)
	if not isValidTask(value) then
		error(tostring(value) .. ' (type="' .. tostring(typeof(value)) .. '") is not a valid task')
	end
end

-- public
local function doCleaning(self) 
    for _, Task in pairs(self.__tasks) do
        if typeof(Task) == "function" then
            Task()
		elseif typeof(Task) == "RBXScriptConnection" then
			Task:Disconnect()
        else
            Task:Destroy()
        end
    end
    self.__tasks = {}
end
local function giveTask(self, newTask) 
    assertIsValidTask(newTask)
    table.insert(self.__tasks, newTask)
end

local MethodAliases = {
    Destroy = doCleaning,
    destroy = doCleaning,
    DoCleaning = doCleaning,
    doCleaning = doCleaning,
    giveTask = giveTask,
    GiveTask = giveTask,
}
local mt = {
	__index = function(self, k)
        if isValidTask(k) then
            giveTask(self, k)
            return true
        end
        return MethodAliases[k]
    end,
	__newindex = function(self, k, v)
		if isValidTask(k) then
			giveTask(self, k)
		end
		if isValidTask(v) then
			giveTask(self, v)
		end
	end,
	__call = giveTask,
}

-- maid constructor
return function(tasks)
	if tasks then
		assert(typeof(tasks) == "table")
		for k, v in pairs(tasks) do
			assert(isValidTask(v))
		end
	end

	return setmetatable({
		__tasks = tasks or {},
	}, mt)
end
