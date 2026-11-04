local CastToInstance = require(script.ValueObjectCaster) -- casts stuff to instances

local util = {}

util.CASTED_TABLES = table.freeze({
	"leaderstats";
	"Data";
})

function util.toInstance(player, data, doOverwrite: boolean)
	for _, nameOfTable in util.CASTED_TABLES do
		
		if doOverwrite then
			local existing = player:FindFirstChild(nameOfTable)
			if existing then
					existing:Destroy()
			end
		end
		
		CastToInstance(nameOfTable,data.Data[nameOfTable]).Parent = player
	end
	
end

return table.freeze(util)