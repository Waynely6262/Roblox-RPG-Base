-- Every function returned under this module will be called when the character is loaded. 
local modules = {}

for _, v in script:GetChildren() do
	modules[v.Name] = require(v)
end
if not next(modules) then
	return function()end
end

local function onCharacterAdded(player, c)
	for _, f in modules do
		task.defer(function()
			local r = f(player, c)
		end)
		
	end
end


return function(thisPlayer: Player)
	
	thisPlayer.CharacterAdded:Connect(function(c)
		onCharacterAdded(thisPlayer, c)
	end)
	if thisPlayer.Character then onCharacterAdded(thisPlayer, thisPlayer.Character) end
end