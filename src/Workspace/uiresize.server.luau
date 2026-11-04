if game:GetService("RunService"):IsRunning() then warn("can't run during runtime") return end
local newSize = UDim2.fromScale(.5,.5)

local parent = game.Selection:Get()[1].Parent
for _, s in game.Selection:Get() do --[[ validation ]]
	assert(s.Parent == parent, "selected items don't have the same parent")
end
for _, s in game.Selection:Get() do
	s.Size = UDim2.new(
		s.Size.X.Scale * s.Parent.Size.X.Scale / newSize.X.Scale,
		s.Size.X.Offset * s.Parent.Size.X.Scale / newSize.X.Scale,
		s.Size.Y.Scale * s.Parent.Size.Y.Scale / newSize.Y.Scale,
		s.Size.Y.Offset * s.Parent.Size.Y.Scale / newSize.Y.Scale
	);
end

parent.Size = newSize