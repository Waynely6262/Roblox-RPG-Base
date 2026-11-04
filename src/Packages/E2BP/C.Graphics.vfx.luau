--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Tween = require(ReplicatedStorage.Modules.Utility.Tween)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local EasingFunctions = require(ReplicatedStorage.Modules.Utility.EasingFunctions)

local numberAbbreviator = require(ReplicatedStorage.Client.Graphics.Util.numberAbbreviator)
local addCommas = require(ReplicatedStorage.Client.Graphics.Util.comma)
----------------------------------------------------------------------------------------------------
local VFXGui = ReplicatedStorage.Client.UserInterface.Popups

local CounterSound = SoundService:WaitForChild("SoundEffects").Counter


local random = Random.new()

local tInfo = TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

local bobbles: {[UIScale]: Tween} = {}

local random = Random.new()


-- damping the count
local function reduce(n: number)
	if n > 10 then
		return math.min(200,math.floor(10 + math.log10(n-10)))
	else
		return math.floor(n)
	end
end


local api = {}
function api.bobbleFrame(adornee: Instance, size: number?)
	
	local duration = 0.75
	
	local scale: UIScale = adornee:FindFirstChildWhichIsA("UIScale"):: UIScale
	if not scale then
		local temp = Instance.new("UIScale")
		temp.Scale = 1
		temp.Parent = adornee
		task.delay(duration, function()
			temp:Destroy()
		end)
		scale = temp
	end
	
	local size = size or 2

	--Tween(adornee, {
	--	Scale = size;
	--}, EasingFunctions.OutExpo, 0.5, function()
	scale.Scale = size
	Tween(scale, {
		Scale = 1;
	}, EasingFunctions.OutElastic, duration)
	--end)

end

------------------------------------

function api.addChild(v: Instance)
	v.Parent = VFXGui
end

return api