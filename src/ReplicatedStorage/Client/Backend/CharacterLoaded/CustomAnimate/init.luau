local custom = require(script.Animate)
return function(character: Model)
	
	local builtin = character:WaitForChild("Animate", 1)
	if builtin then
		builtin:Destroy()
	end
	
	local humanoid = character:WaitForChild("Humanoid"):: Humanoid
	
	for _, v in humanoid:GetPlayingAnimationTracks() do
		v:Stop()
		v:Destroy()
	end
	
	custom(character)
end