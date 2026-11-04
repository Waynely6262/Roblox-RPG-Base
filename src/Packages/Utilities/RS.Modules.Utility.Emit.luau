local localplayer = game:GetService("Players").LocalPlayer

local DEFAULT_LIFETIME = 10

local fxFolder = workspace:WaitForChild("fx", 1)
if not fxFolder then
	fxFolder = Instance.new("Folder")
	fxFolder.Name = "fx"
	fxFolder.Parent = workspace
end

local function ParticleEmitterAsync(Object)
	local Attributes = Object:GetAttributes()
	if Attributes.EmitDelay then 
		task.wait(Attributes.EmitDelay)
	end

	Object:Emit(Attributes.EmitCount)
	if Attributes.EmitDuration then
		Object.Enabled = true;
		task.wait(Attributes.EmitDuration)
		Object.Enabled = false;
	end
end

local function LightAsync(Object)
	Object.Enabled = true
	task.delay(Object:GetAttribute("EmitDuration"), function()
		Object.Enabled = false
	end)
end

local function SoundAsync(Object)


	local Sound: Sound = Object:Clone()
	Sound.Parent = Object.Parent
	Sound:Play()
	task.delay(0, function()
		task.wait(Sound.TimeLength)
		Sound:Destroy()
	end)

end

local CLASS_NAMES = {
	Sound = SoundAsync;
	ParticleEmitter = ParticleEmitterAsync;
	PointLight = LightAsync;
	SpotLight = LightAsync;
	SurfaceLight = LightAsync;
}
local function PlayEffect(Object, pos)
	local f = CLASS_NAMES[Object.ClassName]
	
	--print(Object.ClassName, f ~= nil)
	if f then
		task.spawn(f, Object)
	end
end

local hasEnabledProperty = {
	ParticleEmitter = true;
	Beam = true;
	Trail = true;
	PointLight = true;
	SpotLight = true;
	SurfaceLight = true;
}

-- buildType
-- true: Self-created object and moved to the given cframe
-- {string}: High priority dynamic object that may not exist and will be waited for using pointers
-- nil: Low priority dynamic object

local fn; fn = {
	
	existing = function(super: Instance)
		for _, v in super:GetDescendants() do
			PlayEffect(v)
		end
	end,
	
	build = function(template: PVInstance, cframe: CFrame, lifetime: number?, scale: number?)
		
		local new = template:Clone()
		if scale then
			if new:IsA("Model") then
				new:ScaleTo(scale)
			else
				warn(`Cannot scale {new} because it is not a model.`)
			end
		end
		new:PivotTo(cframe)
		new.Parent = fxFolder
		task.delay(lifetime or DEFAULT_LIFETIME, new.Destroy, new)

		fn.existing(new)
	end,
	
	setEnabled = function(v: Instance, bool: boolean)
		for _, vv in v:GetDescendants() do
			if hasEnabledProperty[vv.ClassName] then
				(vv:: {Enabled: boolean}).Enabled = bool
			end
		end
	end,
	
	
	
}

return fn