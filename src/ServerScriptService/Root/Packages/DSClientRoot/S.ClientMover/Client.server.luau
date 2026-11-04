--!nocheck


if not game:IsLoaded() then
	game.Loaded:Wait()
end

local LocalPlayer = game:GetService("Players").LocalPlayer


local modules = {
	PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
}

local function insertModule(v)

if modules[v] then 
		return
	end
	local begin = os.clock()
	--print("[Client] Loading " .. v.Name)
	local s,r = pcall(function()
		modules[v] = require(v)
	end)
	local finish = os.clock()

	if s then
		print("[Client]", v.Name, "took ", finish - begin, "seconds to load")
	else
		warn("[Client] failed to load " .. v.Name .. " | ", r)
	end
end 


local srcs = {
	game.ReplicatedStorage.Client.Graphics;
	game.ReplicatedStorage.Client.Backend;
	game.ReplicatedStorage.Client;	
}

local ScriptsLoading = {}

local mainThread = coroutine.running()

for _, src in srcs do
	for _, v in src:GetChildren() do
		if v:IsA("ModuleScript") then

			ScriptsLoading[v] = true
			--local t = os.clock()
			task.defer(function()
				insertModule(v)
				ScriptsLoading[v] = nil

				if not next(ScriptsLoading) then
					coroutine.resume(mainThread)
				end
			end)
			--print(v.Name, "took " .. (os.clock() - t) .. " seconds to load")
		end
	end
end

coroutine.yield()

print("Client ready")

return true