-- Completes interfacing of the CustomTools modules and the Inventory module
local InvConfig = require(game.ReplicatedStorage.Modules.PackageConfig.Inventory)
local ToolConfig = require(game.ReplicatedStorage.Modules.PackageConfig.CustomTools)
local ToolModels = require(game.ServerScriptService.Root.Utils.ToolSearch)


for name, data in InvConfig.Catalog do
	
	if data.ctrlr then
		local Model = ToolModels[name]
		if Model then
			Model:SetAttribute(ToolConfig.TYPE_NAME, data.ctrlr)
		end
	end
end


return nil