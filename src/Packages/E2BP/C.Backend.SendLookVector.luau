local E = game.ReplicatedStorage.Remotes.MainE
local interval = 0.1
local hb = game:GetService("RunService").Heartbeat
local cnxn: RBXScriptConnection?

local requesters = 0


local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera

local function getLookVector()
	--if LocalPlayer.Character then
	--	local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		
	--	if HRP then
	--		local LVY = Camera.CFrame.LookVector
	--		local LVXZ = HRP.CFrame.LookVector
			
	--		local XZSize = math.sqrt(LVY.X^2 + LVY.Z^2)
	--		return Vector3.new(LVXZ.X * XZSize, LVY.Y, LVXZ.Z * XZSize)
	--	end
	--end
	
	---- no character or no hrp; should disconnect
	--if cnxn then
	--	cnxn:Disconnect()
	--	cnxn = nil
	--end
	return Camera.CFrame.LookVector
end

local function invoke()
	E:FireServer("lv", getLookVector())
	if cnxn then return end
	
	local lastUpdate = os.clock()
	
	cnxn = hb:Connect(function()
		
		local now = os.clock()
		if now - lastUpdate > interval then
			E:FireServer("lv", getLookVector())
		end
		
		
	end)
end

return {
	request = function(duration: number)
		
		invoke()
		requesters += 1
		task.delay(duration, function()
			requesters -= 1
			if requesters == 0 then
				if cnxn then
					cnxn:Disconnect()
					cnxn = nil
				end
			end
		end)
	end,
}


