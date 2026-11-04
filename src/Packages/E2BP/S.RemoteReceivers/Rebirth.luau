--!strict
local Rebirth = {}

local Template = require(game.ServerScriptService.Root.Data.DSTemplate)
local to_instancer = require(script.Parent.Parent.Players.ProfileDataInstances)
local RebirthData = require(game.ReplicatedStorage.Modules.Data.Rebirths)
local notifClient = require(game.ServerScriptService.Root.Notifications)

local Profiles = require(game:GetService("ServerScriptService").Root.Players.Profiles)


local function deepClone(T: any): any

	if typeof(T) ~= "table" then return T end -- base case

	local T1 = {}

	for i, v in T do
		T1[i] = deepClone(v)
	end

	return T1
end

-- Loss of instances is expected when calling this function
local function lossReconcile(f: Folder, t: {[string]: any})
	
	-- clear old stuff
	for _, vb in f:GetChildren() do
		local v = t[vb.Name]
		
		if v == nil then
			vb:Destroy()
		elseif typeof(v) == "table" then
			lossReconcile(vb:: Folder, v:: {[string]: any})
		else
			if vb:IsA("ValueBase") then
				vb.Value = v --Value should be an abstract member of the ValueBase class 
			else
				warn("Don't know what to do with ", vb:GetFullName(), "type is ", typeof(v), " but instance is not a valueBase")
			end
		end
	end
	
end

local function tracepath(home: {[any]: any}, path: {string}): any
	
	for _, pointer in path do
		home = home[pointer]
		if not home then return nil end
	end
	return home
end
function Rebirth.canRebirth(data: typeof(Template), player: Player): boolean
	
	local rebirthCount = data.leaderstats.Rebirths
	for name, info in RebirthData.Requirements do
		
		
		local v = tracepath(data:: {[any]: any}, info.path)
		-- tables
		if typeof(v) == "table" then
			local count = 0
			for _, _ in v do
				count += 1
			end
			v = count
		end
		local req = info.getNextQuota(rebirthCount)
		if v < req then
			notifClient.NotifyClient(player, "You need " .. req - v .. " more " .. name, 4)
			return false
		end
		
		
	end
	return true
end


function Rebirth.tryRebirth(player: Player): (boolean)
	
	local profile = Profiles[player]
	
	local data = profile and profile.Data
	
	if Rebirth.canRebirth(data, player) then
		
		local new = deepClone(Template)
		
		local rebirths = data.leaderstats.Rebirths
		
		new.leaderstats.Rebirths = rebirths + 1
		
		new.Statistics = data.Statistics
		new.Data.DailyRewards = data.Data.DailyRewards
		profile.Data = new
		
		-- Reconcile everything here
		
		for _, folderName in to_instancer.CASTED_TABLES do
			local f = player:FindFirstChild(folderName):: Folder
			lossReconcile(f, profile.Data[folderName])
		end
		
		return true
	end
	return false
end

return Rebirth.tryRebirth