--!strict

-- Custom R6 Animation Script
-- This script handles basic animations for an R6 character: blended walk/run, jump, and fall.
-- Animations are loaded from a configurable table of asset IDs.
-- Blending between walk and run is controlled by a configurable alpha value (0 = full walk, 1 = full run).
-- For modifiability:
-- - Add more animations to AnimationSources and handle them in the state logic.
-- - Adjust priorities, looped states, or fade times as needed.
-- - Expose more configurables via attributes or modules if extended.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Configurable animation sources: {animationName: assetId}
local AnimationSources: {[string]: string} = {
	["walk"] = "rbxassetid://78044860509526",
	["run"] = "rbxassetid://138459459495524",
	["jump"] = "http://www.roblox.com/asset/?id=125750702",
	["fall"] = "http://www.roblox.com/asset/?id=180436148",
}

local cnxns = {}

return function(character: Model)
	local humanoid: Humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local animator: Animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid

	for k, cnxn in cnxns do
		cnxn:Disconnect()
		cnxns[k] = nil
	end

	-- Loaded animation tracks
	local animationTracks: {[string]: AnimationTrack} = {}

	-- Load animations
	for name: string, id: string in pairs(AnimationSources) do
		local animation: Animation = Instance.new("Animation")
		animation.AnimationId = id
		local track: AnimationTrack = animator:LoadAnimation(animation)

		-- Default settings (modifiable)
		track.Priority = Enum.AnimationPriority.Movement
		if name == "jump" then
			track.Looped = false  -- Jump is typically not looped
		else
			track.Looped = true
		end

		animationTracks[name] = track
	end

	-- Current playing tracks for ground movement
	local walkTrack: AnimationTrack = animationTracks["walk"]
	local runTrack: AnimationTrack  = animationTracks["run"]
	local jumpTrack: AnimationTrack = animationTracks["jump"]
	local fallTrack: AnimationTrack = animationTracks["fall"]

	-- Function to stop all animations with fade
	local function stopAll(fadeTime: number): ()
		walkTrack:Stop(fadeTime) 
		runTrack:Stop(fadeTime) 
		jumpTrack:Stop(fadeTime) 
		fallTrack:Stop(fadeTime) 
	end
	
	local latestSpeed = 0
	
	-- Function to update ground movement animations
	local function updateGroundMovement(speed: number?): ()
		local speed = speed or latestSpeed
		latestSpeed = speed
		
		if speed > 0.001 then

			local runAlpha = math.clamp((speed - 16)/10, 0, 1)
			local walkAlpha = 1 - runAlpha

			runTrack:AdjustSpeed(speed/12)
			walkTrack:AdjustSpeed(speed/12)

			if runAlpha > 0 then
				if not runTrack.IsPlaying then
					runTrack:Play(0.1)  -- Fade time modifiable
				end
				runTrack:AdjustWeight(runAlpha)
			else
				runTrack:Stop(0.1)
			end

			if walkAlpha > 0 then
				if not walkTrack.IsPlaying then
					walkTrack:Play(0.1)  -- Fade time modifiable
				end
				walkTrack:AdjustWeight(walkAlpha)
			else
				walkTrack:Stop(0.1)
			end
		else
			walkTrack:Stop(0.1)
			runTrack:Stop(0.1)
		end
	end

	-- Handle humanoid state changes for air animations
	cnxns["state"] = humanoid.StateChanged:Connect(function(_: Enum.HumanoidStateType, newState: Enum.HumanoidStateType): ()
		if newState == Enum.HumanoidStateType.Jumping then
			jumpTrack:Play(0.1)
			fallTrack:Stop(0.1)
			walkTrack:Stop(0.1)
			runTrack:Stop(0.1)
		elseif newState == Enum.HumanoidStateType.Freefall then
			jumpTrack:Stop(0.1)
			fallTrack:Play(0.1)
			walkTrack:Stop(0.1)
			runTrack:Stop(0.1)
		elseif newState == Enum.HumanoidStateType.Landed then
			fallTrack:Stop(0.1) 
			jumpTrack:Stop(0.1) 
			walkTrack:Stop(0.1)
			runTrack:Stop(0.1)
			-- Resume ground movement if moving (will be handled by Running event)
		elseif newState == Enum.HumanoidStateType.Running then
			-- Ensure air animations are stopped when back to running
			fallTrack:Stop(0.1) 
			jumpTrack:Stop(0.1) 
			updateGroundMovement()
		end
	end)

	-- Handle running speed changes for ground movement
	cnxns["running"] = humanoid.Running:Connect(updateGroundMovement)

	-- Cleanup on character removal
	cnxns["ancestry"] = character.AncestryChanged:Connect(function(_: Instance?, parent: Instance?): ()
		if parent == nil then
			stopAll(0)
		end
	end)
	
end