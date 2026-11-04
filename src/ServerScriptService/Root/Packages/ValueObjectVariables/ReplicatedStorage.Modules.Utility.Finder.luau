local Finder = {}
function Finder.followPathAsync(root: Instance, ...): Folder | ValueBase?

	for _, header in {...} do
		root = root:WaitForChild(header)
	end
	return root
end

function Finder.followPath(root: Instance, ...): Folder | ValueBase?
	
	for _, header in {...} do
		if root then
			root = root:FindFirstChild(header)
		else
			return nil
		end
	end
	
	return root
	
end

return Finder