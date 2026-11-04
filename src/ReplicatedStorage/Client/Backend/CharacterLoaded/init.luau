-- Every function returned under this module will be called when the character is loaded. 
local modules = {}

for _, v in script:GetChildren() do
	modules[v.Name] = require(v)
end
if not next(modules) then
	return modules
end

local function onCharacterAdded(c)
	for _, f in modules do
		task.defer(function()
			local r = f(c)
		end)
		
	end
end

local LocalPlayer = game:GetService("Players").LocalPlayer

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end

return modules