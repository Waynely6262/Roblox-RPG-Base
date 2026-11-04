-- Every function returned under this module will be called when a player is added
local modules = {}

for _, v in script:GetChildren() do
	if v:IsA("ModuleScript") then
		modules[v.Name] = require(v)
	end
end
if not next(modules) then
	return modules
end


local function onPlayerAdded(c)
	for _, f in modules do
		f(c)
	end
end
game:GetService("Players").PlayerAdded:Connect(onPlayerAdded)

for _, v in game:GetService("Players"):GetPlayers() do
	task.defer(onPlayerAdded,v)
end

return modules