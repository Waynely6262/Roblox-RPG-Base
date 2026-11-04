--!strict
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local TransparencyAPI = require(ReplicatedStorage.Client.Graphics.Util.TransparencyAPI)
local TwCallback = require(ReplicatedStorage.Modules.Utility.TweenCallback)
local PGBController = require(ReplicatedStorage.Client.Graphics.Util.GradientProgressBar)
local Template = ReplicatedStorage.GuiElements.HealthBar

local REQUIRED_NAME = "HumanoidRootPart"

local api = {}

type data = {
	controller:typeof(PGBController.new());
	billboard: BillboardGui;
	Tweener: TwCallback.Class;
	hideThread: thread?;
}

local ActiveHealthBars: {
	[BasePart]: data
} = {}

local function get(Adornee: BasePart): data
	if ActiveHealthBars[Adornee] then return ActiveHealthBars[Adornee] end

	local Billboard = Template:Clone()
	local Container = Billboard.ProgressBarContainer
	local ProgressBar = Container.ProgressBar
	local UIGradient = ProgressBar.UIGradient
	local myController = PGBController.new(function(cs, ns)
		UIGradient.Transparency = ns
		UIGradient.Color = cs
	end)
	
	myController.FillColor = Color3.new(0.4, 1, 0.4)
	myController.DeltaDecColor = Color3.new(1, 0.4, 0.4)
	myController.DeltaIncColor = Color3.new(0.4, 1, 0.4)
	myController:setDuration(1.25)
	
	TransparencyAPI.initialize(Container, true)

	local TransparencyTweener = TwCallback.new(0, 1, "InQuad", function(a)
		TransparencyAPI.modify(Container, a)
	end)
	
	
	ActiveHealthBars[Adornee] = {
		controller = myController;
		billboard = Billboard;
		Tweener = TransparencyTweener;
		latest = os.clock();
	}
	
	Billboard.Parent = Adornee
	Adornee.Destroying:Once(function()
		ActiveHealthBars[Adornee] = nil
	end)
	return ActiveHealthBars[Adornee]
end

function api.update(Model: Model, alpha: number)
	
	local Adornee: BasePart? = Model:FindFirstChild(REQUIRED_NAME):: BasePart?
	if Adornee then
		alpha = math.clamp(alpha,0,1)
		
		local Data = ActiveHealthBars[Adornee] or get(Adornee)
		if Adornee.Parent then
			Data.controller:update(alpha)
			
			local thisUpdate = os.clock()
			Data.Tweener:set(0)
			
			
			if Data.hideThread and coroutine.status(Data.hideThread) == "suspended" then
				task.cancel(Data.hideThread)
			end
			
			Data.hideThread = task.delay(2, function()
				Data.Tweener:play(1)
			end)
		else
			Data.controller.v = alpha
			Data.Tweener:set(1)
		end
		
	end
end

return api

