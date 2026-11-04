
local ToolsFolder = game.ReplicatedStorage.Models.Tools
local t = {}
for _, v in ToolsFolder:GetDescendants() do
	if v:IsA("Model") and v.Parent.ClassName == "Folder" then
		t[v.Name] = v
	elseif v:IsA("BasePart") then
		v.CanCollide = false
		v.CanTouch = false
		v.Anchored = false
	end
end

return table.freeze(t)