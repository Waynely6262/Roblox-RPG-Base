--!strict
local Players = game:GetService("Players")
local dbt = {}

dbt.__index = dbt

function dbt.new()
	local self = {
		Players = {}:: {[Player]: number};
		Connections = {};
		Clock = os.clock;
	}
		
	setmetatable(self, dbt)
	self:Connect()
	return self
end

function dbt:Connect()
	self:Disconnect()
	table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
		self.Players[player] = nil
	end))
end

function dbt:Disconnect()
	for _, v in self.Connections do
		v:Disconnect()
	end
	self.Connections = {}
end

function dbt.setDebounced(self: any, player, arg: number | boolean)
	if arg == true then
		arg = math.huge
	end
	if not arg then
		self.Players[player] = nil
	else -- if typeof(arg) == "number" then
		self.Players[player] = self.Clock() + arg:: number
	end
end

function dbt.addDebounced(self: any, player: Player, arg: number)
	if not self.Players[player] then
		return dbt.setDebounced(self, player, arg)
	end
	self.Players[player] += arg
end

function dbt.isDebounced(self: any, player: Player): (boolean, number?)
	local value = self.Players[player]
	
	local timestamp = self.Clock()
	if value and timestamp < value then
		return true, value - timestamp 
	end
	self.Players[player] = nil
	return false, nil
end

export type class = typeof(setmetatable({}:: {
	Players: {[Player]: number},
	Connections: {RBXScriptConnection},
	Clock: () -> (number),
}, dbt))

return dbt