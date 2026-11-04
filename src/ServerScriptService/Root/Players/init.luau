--!strict

--[[

This script needs to be manually integrated with packages.

]]

local IsStudio = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")

local ProfileService = require(script.ProfileService)
local onPlayer = require(script.Player)
local Profiles = require(script.Profiles)
local ProfileStore = ProfileService.GetProfileStore(IsStudio and "Studio" or "Production",Template)

-- INTEGRATION VARIABLES

-- END OF INTEGRATION VARIABLES

-- these functions MAY YIELD.
local PlayerInitializers: {(Player) -> ()} do
	PlayerInitializers = {}
	
	local Source = script:FindFirstChild("Initialize")
	if Source then
		for _, v in Source:GetChildren() do
			local s,r = pcall(function()
				table.insert(PlayerInitializers, require(v))
			end)
			if not s then
				warn(`Failed to add player initializer {v.Name}; {r}`)
			end
		end
	end
end



local function onPlayerAdded(player: Player)

	local PlayerProfile = ProfileStore:LoadProfileAsync("U" .. player.UserId):: {Data: typeof(Template), [string]: any}

	if PlayerProfile == nil then
		player:Kick("Your save data failed to load. Please rejoin to try loading your saved data again.")
		return
	end
	
	PlayerProfile:Reconcile()
	PlayerProfile:AddUserId(player.UserId)
	
	Profiles[player] = PlayerProfile
	
	-- INTEGRATION
	for _, async_f in PlayerInitializers do
		async_f(player)
	end
	
	
	-- END OF INTEGRATION
	
	onPlayer(player)
	
	
	
	PlayerProfile:ListenToRelease(function()
		Profiles[player] = nil
		
		for _, v in player:GetChildren() do
			if v:IsA("Folder") then
				v:Destroy()
			end
		end
		task.defer(function()
			if player.Parent then
				player:Kick("Multiple sessions detected, please only leave one instance of the game running. You may also have encountered this error because you're rejoining too quickly.")
			end
		end)
	end)
	
	
end

for _, v in Players:GetPlayers() do
	task.spawn(onPlayerAdded,v)
end


Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	if Profiles[player] then
		Profiles[player]:Release()
	end
end)

return onPlayerAdded