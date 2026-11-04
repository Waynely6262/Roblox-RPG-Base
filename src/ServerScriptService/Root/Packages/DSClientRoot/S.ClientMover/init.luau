--!strict

-- The only requirement for the client script is that the Players module has been initialized. Therefore, we require the module in case it was not required. Then, we move the client root to a location where the client can see.



local destination = require(game.ReplicatedStorage.Modules.PackageConfig.DSClientRoot).destination

require(game.ServerScriptService.Root:FindFirstChild("Players"))


local function merge(from: Instance, to: Instance)
	for _, v in from:GetChildren() do
		local existing = to:FindFirstChild(v.Name)
		if existing then
			if v.ClassName ~= existing.ClassName then
				warn(`Class mismatch: {v:GetFullName()}`)
			end
			merge(v, existing)
		else
			v.Parent = to
		end
	end
end


local preexisting = destination:FindFirstChild("Client"):: Instance?
if preexisting then
	merge(script.Client, preexisting)
else
	script.Client.Parent = destination
end

return nil