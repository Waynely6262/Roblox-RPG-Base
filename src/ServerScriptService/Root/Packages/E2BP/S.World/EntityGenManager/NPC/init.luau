local Super = require(script.Superclass)

local MobTypes = {}

for _, v in script:GetChildren() do
	if v:IsA("ModuleScript") then
		MobTypes[v.Name] = require(v)
	end
end

return function(mobType: string): Super.type
	local mob = MobTypes[mobType] and MobTypes[mobType].new() or Super.new(mobType)
	mob.Rig.Name = mobType
	return mob
end