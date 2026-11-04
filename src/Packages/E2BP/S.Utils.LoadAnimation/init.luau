--!strict
local Animations = require(script.Animations)

local AnimationCounters = setmetatable({}:: {[Humanoid]: number}, {__mode = "k"})

local function getNextQueuedAnimation(Category: string, animation: string, id: number): Animation
	local Set = Animations[Category][animation]
	return Set[(id % #Set) + 1]
end

local API = {}

local PlayingAnimationsPerHumanoid = {}:: {[Humanoid]: {[Animation]: AnimationTrack}}


function API.once(humanoid: Humanoid, Category: string, animationName: string, speed: number?, KFReached: () -> ())
	
	local Animator: Animator | Humanoid = assert(humanoid:FindFirstChildWhichIsA("Animator") or humanoid, `Could not animate {humanoid:GetFullName()} (missing animator??)`)

	AnimationCounters[humanoid] = (AnimationCounters[humanoid] or 0) + 1
	
	
	local AnimationRequired = getNextQueuedAnimation(Category, animationName, AnimationCounters[humanoid])
	
	local HumanoidLoadedAnimations = PlayingAnimationsPerHumanoid[humanoid]
	if not HumanoidLoadedAnimations then
		HumanoidLoadedAnimations = {}:: {[Animation]: AnimationTrack}
		PlayingAnimationsPerHumanoid[humanoid] = HumanoidLoadedAnimations
		humanoid.Destroying:Once(function()
			PlayingAnimationsPerHumanoid[humanoid] = nil
		end)
	end
	
	
	
	local Track = HumanoidLoadedAnimations[AnimationRequired]
	if not Track then
		Track = (Animator:: Animator --[[ Just to avoid type error; Animator could be Humanoid ]] ):LoadAnimation(getNextQueuedAnimation(Category, animationName, AnimationCounters[humanoid]))
		HumanoidLoadedAnimations[AnimationRequired] = Track
	end
	

	local Listeners: {RBXScriptConnection}
	local Completed = false
	
	local TimeoutThread: thread?
	
	local function ExecuteKF()
		if Completed then return end -- avoid running twice
		Completed = true
		
		if TimeoutThread and coroutine.running() ~= TimeoutThread then task.cancel(TimeoutThread) end
		
		for _, L in ipairs(Listeners) do
			L:Disconnect()
		end
		KFReached()
	end
	
	
	Listeners = {
		Track.KeyframeReached:Once(ExecuteKF);
		Track.Ended:Once(ExecuteKF);
		Track.Destroying:Once(ExecuteKF);
	}

	Track:Play(nil, nil, speed)
	task.delay(0, function()
		TimeoutThread = task.delay(Track.Length, ExecuteKF)
	end)
end

function API.pose(humanoid: Humanoid, Category: string, animationName: string, duration: number?)
	
	local Animator: Animator | Humanoid = assert(humanoid:FindFirstChildWhichIsA("Animator") or humanoid, `Could not animate {humanoid:GetFullName()} (missing animator??)`)
	
	AnimationCounters[humanoid] = (AnimationCounters[humanoid] or 0) + 1
	
	local Track = Animator:LoadAnimation(getNextQueuedAnimation(Category, animationName, AnimationCounters[humanoid]))
	
	
	local Listeners: {RBXScriptConnection}
	local Completed = false
	
	local function Exit()
		if Completed then return end -- avoid running twice
		Completed = true
		
		for _, L in ipairs(Listeners) do
			L:Disconnect()
		end
		Track:Stop(0.1)
	end

	
	Track:Play(0.1, 2)
	Listeners = {
		Track.KeyframeReached:Once(function()
			Track:AdjustSpeed(0)
			
			if duration then
				task.wait(duration)
				Exit()
			end
		end);
		
		Track.Ended:Once(Exit)
	}
	
	return Track
end

return API