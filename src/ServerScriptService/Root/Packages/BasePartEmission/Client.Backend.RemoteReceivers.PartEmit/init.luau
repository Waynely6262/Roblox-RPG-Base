--!strict
local ReplicatedStorage = game.ReplicatedStorage

local fxFolder = workspace:WaitForChild("fx")


local function prep(v: BasePart)
	v.Anchored = true
	v.CanCollide = false
	v.CanQuery = false
	v.CanTouch = false
	return v
end

local templates: {[string]: BasePart} do
	local templateDirectory = ReplicatedStorage.Models.EmittedParts
	
	local children = templateDirectory:GetChildren()
	templates = {}
	
	for _, v in children do
		templates[v.Name] = prep(v)
		
	end
end
	


local branch_onInvoke = {
	TweenInfo = require(script.TS),
	string = require(script.CT),
}

return {
	_aliases = {
		"mfx";
	},
	
	onInvoke = function(template: BasePart | string, initial_properties: {[string]: any}, final_properties: {[string]: any}, easing: string | TweenInfo, duration: number?, useTemplate: boolean?)
		
		if typeof(template) == "string" then
			template = assert(templates[template], `Didn't find a '{template}' in the EmittedParts directory; aborting BasePart emission`)
		end
		
		local part: BasePart = useTemplate and (template:: BasePart) or (template:: BasePart):Clone()
		part.Parent = fxFolder
		
		for p, v in initial_properties do
			part[p] = v
		end
		
		return branch_onInvoke[typeof(easing)](part, final_properties, easing, duration)
		
	end,
	
	prep = prep,
	
}