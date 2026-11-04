local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local GraphicsUtilPath = ReplicatedStorage.Client.Graphics.Util
local UIAPI = require(GraphicsUtilPath.UIAPI)

local Mainframe = UIAPI.getByName("PersistentGui").Health

local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)
local PGBController = require(ReplicatedStorage.Client.Graphics.Util.GradientProgressBar)
local vfx = require(ReplicatedStorage.Client.Graphics.vfx)

local widget = Widget.new(nil, Mainframe)

widget:Toggle(true)

local ProgressLabelContainer = Mainframe.ProgressLabelContainer
local TitleLabelContainer = Mainframe.TitleLabelContainer
local ProgressBar = Mainframe.ProgressBarContainer.ProgressBar
local UIGradient = ProgressBar.UIGradient

--local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local health = 0
local maxHealth = 0


local myController = PGBController.new(function(cs, ns)
	UIGradient.Transparency = ns
	UIGradient.Color = cs
end)

myController.FillColor = Color3.new(0.4, 1, 0.4)
myController.DeltaDecColor = Color3.new(1, 0.4, 0.4)

myController:setDuration(1.25)
local api = {}
	
api.setMaxHealth = function(x)
	maxHealth = x
 	api.setHealth(health)
end

api.setHealth = function(x)
	health = math.floor(x)
	ProgressLabelContainer.ProgressLabel.Text = health .. " / " .. maxHealth
	vfx.bobbleFrame(ProgressLabelContainer, 1.2)
	
	myController:update(math.clamp(x/maxHealth,0,1))
	--TweenService:Create(ProgressBar, tInfo, {
		
	--}):Play()
end

return api

