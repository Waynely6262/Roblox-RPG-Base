local List = {}
local localPlayer = game:GetService("Players").LocalPlayer

local Heartbeat = game:GetService("RunService").Heartbeat
local HeartbeatCnxn

local function Disconnect()
	if HeartbeatCnxn then
		HeartbeatCnxn:Disconnect()
		HeartbeatCnxn = nil
	end
end
local function onHeartbeat(dt)
	dt = math.min(dt, 0.05)
	if not next(List) then 
		Disconnect()
		return
	end

	for Subject, Job in List do
		if not Subject.Parent then
			List[Subject] = nil
			continue
		end
		Job.Progress += dt
		local alpha = Job.Progress / Job.Duration
		if alpha >= 1 then
			alpha = 1
			List[Subject] = nil
		end
		Subject:PivotTo(Job.Identity:Lerp(Job.Next, alpha))
	end
end

return {
	
	onInvoke = function(player, nextCFrame, duration)
		if player == localPlayer then return end
		local M = player.Character
		if not (M and nextCFrame) then return end

		List[M] = {
			Duration = duration or 0.1;
			Progress = 0;
			Identity = M:GetPivot();
			Next = nextCFrame;
		}


		HeartbeatCnxn = HeartbeatCnxn or Heartbeat:Connect(onHeartbeat)

	end,
	_aliases = {
		"cf";
	}
}
