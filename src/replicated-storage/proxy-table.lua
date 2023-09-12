--[[
    Wrap a table such that you can assign callbacks to when changes.
    Callbacks are called when you connect them, btw.
]]

local ALL_CHANGES_KEY = "__ALL_CHANGES__"
local mt = {
	__index = function(self, k)
		return self.__data[k]
	end,
	__newindex = function(self, k, v)
        -- truly modify the data
		self.__data[k] = v

		-- callbacks specific to this key
		if self.__callbacks[k] then
			for callback, _ in pairs(self.__callbacks[k]) do
				callback(k, v)
			end
		end

		-- all callbacks
		if self.__callbacks[ALL_CHANGES_KEY] then
			for callback, _ in pairs(self.__callbacks[ALL_CHANGES_KEY]) do
				callback(k, v)
			end
		end
	end,
	__iter = function(self)
		return pairs(self.__data)
	end,
	__len = function(self)
		return #self.__data
	end,
}
local function changed(self, key, callback)
	if callback == nil then
		callback = key
		key = ALL_CHANGES_KEY
	end
	assert(typeof(callback) == "function")

	-- get/initialize table of callbacks
	if self.__callbacks[key] == nil then
		self.__callbacks[key] = {}
	end

	-- add callback to that table
	self.__callbacks[key][callback] = true

    -- call callback on current value
    callback(key, self[key])

    -- return disconnect() method
	return function()
		self.__callbacks[key][callback] = nil
	end
end

return function(data)
	return setmetatable({
		__callbacks = {},
		__data = data,
		changed = changed,
	}, mt)
end
