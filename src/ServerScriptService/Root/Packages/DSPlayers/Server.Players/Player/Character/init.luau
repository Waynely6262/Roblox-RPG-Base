-- Every function returned by a child of this module will be called when the character is loaded, with the exception of "DefaultSpawn" when "Spawn" is present.
local modules = {}

for _, v in script:GetChildren() do
	modules[v.Name] = require(v)
end

if modules.Spawn then
	modules.DefaultSpawn = nil
end

if not next(modules) then
	return modules
end

local function onCharacterAdded(player, c)
	for _, f in modules do
		task.defer(function()
			local r = f(player, c)
		end)
		
	end
end


return function(thisPlayer: Player)
	
	thisPlayer.CharacterAdded:Connect(function(thisPlayer_Character)
		onCharacterAdded(thisPlayer, thisPlayer_Character)
	end)
	if thisPlayer.Character then 
		onCharacterAdded(thisPlayer, thisPlayer.Character)
	end
end