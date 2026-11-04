--!strict
local Directory = game.ReplicatedStorage.Animations

local Animations = {}:: {
	[string]: {
		[string]: {
			Animation
		}
	}
}

for _, Category in Directory:GetChildren() do
	local instances: {Animation | Folder} = Category:GetChildren()
	
	local CategoryAnimations = {}
	for _, v in instances do
		if v:IsA("Folder") then
			CategoryAnimations[v.Name] = v:GetChildren():: {Animation}
		else
			CategoryAnimations[v.Name] = {v:: Animation}
		end
	end
	Animations[Category.Name] = CategoryAnimations
	
end

return Animations