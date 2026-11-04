--!strict

local ReplicatedStorage = game.ReplicatedStorage

local fxFolder = workspace.fx

local random = Random.new()

local TweenService = game:GetService("TweenService")

local EasingFunctions = require(ReplicatedStorage.Modules.Utility.EasingFunctions)

local NumberAbbreviator = require(ReplicatedStorage.Client.Graphics.Util.numberAbbreviator)

local HealthBars = require(ReplicatedStorage.Client.Graphics.HealthBars)
local commonAnims = require(script.Parent.CommonAnimations)

local dmgFx = ReplicatedStorage.Models.Effects.dmgFx

local destroyFx = ReplicatedStorage.Models.Effects.critDestroy

local emitterUtil = require(ReplicatedStorage.Modules.Utility.Emit)

local hitIndTemplate = ReplicatedStorage.GuiElements.HitIndicator
local healIndTemplate = ReplicatedStorage.GuiElements.HealIndicator
local critIndTemplate = ReplicatedStorage.GuiElements.CritIndicator

local billboardAdorneeTemplate = ReplicatedStorage.GuiElements.BillboardAdornee

local tInfoIn = TweenInfo.new(.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local tInfoOut = TweenInfo.new(.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.In)

local function newIndicator(model: Model, dmg: number | string, template)
	
	if not model then
		warn("no model")
		return
	end
	
	local adornee = billboardAdorneeTemplate:Clone()
	
	local newInd = (template or hitIndTemplate):Clone():: {Frame: {UIScale: UIScale, Label: TextLabel}} & BillboardGui
	
	newInd.Adornee = adornee
	newInd.Parent = adornee
	
	local tw = TweenService:Create(newInd.Frame.UIScale, tInfoIn, {
		Scale = 1;
	})
	
	tw.Completed:Once(function()
		local tw2 = TweenService:Create(newInd.Frame.UIScale, tInfoOut, {
			Scale = 0;
		})
		
		tw2.Completed:Once(function()
			adornee:Destroy()
		end)
		tw2:Play()
	end)
	tw:Play()
	
	if typeof(dmg) == "number" then
		newInd.Frame.Label.Text = dmg == 0 and "Miss" or 
			NumberAbbreviator(math.abs(math.floor(dmg)))
		
		if dmg < 0 then
			newInd.Frame.Label.TextColor3 = Color3.new(0.5,1,0.5)
		end
	else
		newInd.Frame.Label.Text = dmg
	end
	
	adornee.Position = model:GetPivot().Position + random:NextUnitVector() * 2 * math.random()
	
	adornee.Parent = fxFolder
end


local animations = {
	-- slop code. should refactor this (may '26)
	["-"] = function(v: Model?, dmg: number)
		if v then
			newIndicator(v, dmg, hitIndTemplate)
		end
	end,
	["+"] = function(v: Model?, dmg: number)
		if v then
			newIndicator(v, dmg, healIndTemplate)
		end
	end,
	["!"] = function(v: Model?, dmg: number)
		if v then
			newIndicator(v, dmg, critIndTemplate)
		end
	end,
	
	["?"] = function(v: Model?, str: string)
		if v then
			newIndicator(v, str, hitIndTemplate)
		end
	end,
	
	collected = commonAnims.methods.fadeOut,
	
	["x"] = function(v: Model?)
		if v then
			emitterUtil.build(destroyFx, v:GetPivot(), 2)
			commonAnims.methods.shrinkOut(v)
		end
	end,
	
	["%"] = function(v: Model?, health_alpha: number)
		if v then
			HealthBars.update(v, health_alpha)
		end
	end,
}

return {
	onInvoke = function(jobs: {{Model | string}})
		for _, info in jobs do
			
			local eventType = info[1]:: string
			
			animations[eventType](table.unpack(info, 2))
		end
	end,
	_aliases = {
		"modelAnim";
		"mam";
		"rpl";
	}
}
