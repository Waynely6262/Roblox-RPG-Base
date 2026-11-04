type Disconnectable = RBXScriptConnection | { Disconnect: (self) -> () }

local privateVar = {}

local ConnectionHandler = {}
ConnectionHandler.__index = ConnectionHandler

function ConnectionHandler.new()

	local self = {}

	privateVar[self] = {
		Connections = {}
	}

	return setmetatable(self, ConnectionHandler)
end

function ConnectionHandler:Disconnect()
	for _, v in privateVar[self].Connections do
		v:Disconnect()
	end
	privateVar[self].Connections = {}
end

function ConnectionHandler:Insert(c: Disconnectable)
	assert(typeof(c.Disconnect) == "function", tostring(c) .. " (" .. typeof(c) .. ") does not have a Disconnect method.")
	table.insert(privateVar[self].Connections, c)
end

function ConnectionHandler:InsertPackage(c: {Disconnectable})
	for _, v in c do
		self:Insert(v)
	end
end

function ConnectionHandler:Destroy()
	self:Disconnect()
	table.clear(privateVar[self])
	privateVar[self] = nil
end

return ConnectionHandler