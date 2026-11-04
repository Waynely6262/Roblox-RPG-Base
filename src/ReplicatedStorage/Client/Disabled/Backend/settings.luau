--!strict
local RemoteE = game.ReplicatedStorage.Remotes.MainE
local RemoteF = game.ReplicatedStorage.Remotes.MainF
local settingsGraphics = require(game.ReplicatedStorage.Client.Graphics.settings)
local settingsInfo = require(game.ReplicatedStorage.Modules.Data.settingsInfo)

local CamShakeUtil = require(game.ReplicatedStorage.Modules.CameraShakeUtil)
local SoundService = game:GetService("SoundService")
local SoundControlPlayback = require(script.Parent.Sound)
local SFX = SoundService:WaitForChild("SoundEffects")
local MFX = SoundService:WaitForChild("Music")

local typeCreate = {
	slider = settingsGraphics.createSlider;
	boolean = settingsGraphics.createBoolean;
}

local latestPreferences = RemoteF:InvokeServer("fetchSetting")

local reactions = {
	CameraShake = function(v)
		
		if v then
			CamShakeUtil.enable()
		else
			CamShakeUtil.disable()
		end
	end,
	
	Music = function(v)
		MFX.Volume = v
		SoundControlPlayback()
	end,
	
	Sound = function(v)
		SFX.Volume = v
	end,
}

for internalName, info in settingsInfo do
	
	typeCreate[info.type](internalName, latestPreferences[internalName])
	reactions[internalName](latestPreferences[internalName])
end

settingsGraphics.preferenceChanged:Connect(function(name: string, value: any)
	latestPreferences[name] = value
	reactions[name](value)
end)

task.defer(function()
	while task.wait(30) do
		RemoteE:FireServer("updateSettings", latestPreferences)
	end
end)

require(game.ReplicatedStorage.Client.Graphics.Util.ExitLikely):Connect(function()
	RemoteE:FireServer("updateSettings", latestPreferences)
end)
return {
	settings = latestPreferences;
	settingUpdated = settingsGraphics.preferenceChanged
}:: {
	settings: {[string]: any};
	settingUpdated: typeof(settingsGraphics.preferenceChanged);
}