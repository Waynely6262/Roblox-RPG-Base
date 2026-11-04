--!strict

-- status effect for "Mega Power Eater" client module 

local Player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local timeFormat = require(ReplicatedStorage.Client.Graphics.Util.hhmmssFormat)
local StatusEffectData = require(ReplicatedStorage.Modules.Data.StatusEffects)


local Container = ReplicatedStorage.Client.UserInterface.PersistentGui.StatusEffectsContainer



local StatusTemplate = script.Template

local activeEffects: {
	[string]: {
		F: typeof(StatusTemplate),
		T: number,
	}
} = {}

local fadeInTInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local fadeInProperties = {Scale = 1}
local fadeOutTInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local fadeOutProperties = {Scale = 0}


local this = {}

this.setStatusEffect = function(effectName: string, duration: number | boolean)

	if not duration then
		this.clearStatusEffect(effectName)
		return
	elseif duration == true then
		this.setStatusEffect(effectName, math.huge)
		return
	end

	local existing = activeEffects[effectName]

	if not existing then
		existing = {
			F = StatusTemplate:Clone(),
			T = os.clock() + duration,
		}
		
		existing.F.ImageLabel.Image = StatusEffectData[effectName].image
		
		existing.F.Parent = Container
		
		
		activeEffects[effectName] = existing
		
		local tw = TweenService:Create(existing.F.Scale, fadeInTInfo, fadeInProperties)
		tw:Play()
		
	end
	existing.T = os.clock() + duration
	existing.F.DurationLabel.Text = timeFormat(duration)
	
end

this.clearStatusEffect = function(effectName: string)
	local info = activeEffects[effectName]
	if info then
		local frame = info.F
		activeEffects[effectName] = nil
		
		local tw = TweenService:Create(frame.Scale, fadeOutTInfo, fadeOutProperties)
		
		tw.Completed:Once(function()
			frame:Destroy()
		end)
		tw:Play()
	end
end

this.clearAllEffects = function()
	for effectName, _ in activeEffects do
		this.clearStatusEffect(effectName)
	end
end


task.defer(function()
	while task.wait(0.1) do
		for effectName, info in activeEffects do
			
			local timeRemaining = math.max(info.T - os.clock(), 0)
			
			info.F.DurationLabel.Text = timeFormat(timeRemaining)
			
			if timeRemaining == 0 then
				this.clearStatusEffect(effectName)
			end
		end
	end
end)

return this