local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local GraphicsUtilPath = ReplicatedStorage.Client.Graphics.Util
local UIAPI = require(GraphicsUtilPath.UIAPI)
local TransparencyAPI = require(GraphicsUtilPath.TransparencyAPI)
local TwCallback = require(ReplicatedStorage.Modules.Utility.TweenCallback)

local Mainframe = UIAPI.getByName("PersistentGui").Level

local vfx = require(ReplicatedStorage.Client.Graphics.vfx)
local Abbreviate = require(ReplicatedStorage.Client.Graphics.Util.numberAbbreviator)

local TitleLabelContainer = Mainframe.TitleLabelContainer

local ProgressLabelContainer = Mainframe.Labels.ProgressLabelContainer
local ProgressBar = Mainframe.Bars.ProgressBarContainer.ProgressBar

local SkillProgressLabelContainer = Mainframe.Labels.SkillProgressLabelContainer
local SkillProgressBarContainer = Mainframe.Bars.SkillProgressBarContainer
local SkillProgressBar = SkillProgressBarContainer.ProgressBar
local SkillNameTextLabel = SkillProgressLabelContainer.TextLabel

TransparencyAPI.initialize(SkillProgressLabelContainer, true)
TransparencyAPI.initialize(SkillProgressBarContainer, true)

local SkillTransparencyTweener = TwCallback.new(0, 1, "InQuad", function(a)
	TransparencyAPI.modify(SkillProgressLabelContainer, a)
	TransparencyAPI.modify(SkillProgressBarContainer, a)
end)

SkillTransparencyTweener:set(1)

local latestSkillUpdate = os.clock()

local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return {
	
	setOverallXP = function(xp: number, total: number)
		ProgressLabelContainer.ProgressLabel.Text = Abbreviate(xp) .. " / " .. Abbreviate(total)
		vfx.bobbleFrame(ProgressLabelContainer, 1.2)
		
		TweenService:Create(ProgressBar, tInfo, {
			Size = UDim2.fromScale(math.clamp(xp/total,0,1), 1);
		}):Play()
	end,
	
	setOverallLevel = function(level: number)
		
		TitleLabelContainer.TitleLabel.Text = "L. " .. tostring(level)
		vfx.bobbleFrame(TitleLabelContainer, 1.2)
		
	end,
	
	setSkillXP = function(skill: string,xp: number, total: number)
		SkillTransparencyTweener:reset()
		SkillNameTextLabel.Text = skill
		
		SkillProgressLabelContainer.ProgressLabel.Text = Abbreviate(xp) .. " / " .. Abbreviate(total)
		vfx.bobbleFrame(SkillProgressLabelContainer, 1.2)

		TweenService:Create(SkillProgressBar, tInfo, {
			Size = UDim2.fromScale(math.clamp(xp/total,0,1), 1);
		}):Play()
		
		local thisUpdate = os.clock()
		latestSkillUpdate = thisUpdate
		task.wait(2)
		if latestSkillUpdate == thisUpdate then
			SkillTransparencyTweener:play(1)
		end
	end,

	setSkillLevel = function(level: number)

		print("Skill page coming soon?")
	end,
	
}

