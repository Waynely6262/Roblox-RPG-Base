--!strict
local fxFolder = workspace:WaitForChild("fx")

local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local Root = ReplicatedStorage.Client

local PartEmit = require(Root.Backend.RemoteReceivers.PartEmit)
local Tween = require(ReplicatedStorage.Modules.Utility.Tween)
local TweenCallback = require(ReplicatedStorage.Modules.Utility.TweenCallback)
local EasingFunctions = require(ReplicatedStorage.Modules.Utility.EasingFunctions)
local explosionTInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local busy: {[Model]: RBXScriptConnection} = setmetatable({}, {__mode = "k"})

local stuff = {
	sphere = function(r: number, pos: Vector3, color: Color3)

		local i_prop = {
			--Material = Enum.Material.Neon;
			Color = color;
			Position = pos;
			Transparency = 0.5
			
		}
	
		PartEmit.onInvoke("Sphere", i_prop, {
			Size = Vector3.new(r*2,r*2,r*2);
			Transparency = 1,
			Color = Color3.new(1,1,1)
		}, explosionTInfo)
		
		-----------------------------------------------
		-- vacuum
	end,
	
	
	bpFadeOut = function(p: BasePart)

		PartEmit.onInvoke(p, explosionTInfo, {
			Size = p.Size * 2,
			Transparency = 1,
			Color = Color3.new(1,1,1),
		}, explosionTInfo, nil, true)
	end, 
	
	
	shrinkOut = function(v: Model)
		



		if busy[v] then
			busy[v]:Disconnect()
		end
		busy[v] = TweenCallback.run(0.5, EasingFunctions.InBack, function(value)

			v:ScaleTo(1.1 - value)

		end,
		function()
			v:Destroy()
			-- cnxn is disconnected by tweencallback class
			busy[v] = nil
		end)
	end,
	
	fadeOut = function(v: Model)

		local parts: {BasePart} = {}

		for _, vv in v:GetDescendants() do
			if vv:IsA("BasePart") then
				table.insert(parts, vv:: BasePart)
			end
		end

		if busy[v] then
			busy[v]:Disconnect()
		end
		
		busy[v] = TweenCallback.run(0.5, EasingFunctions.OutExpo, function(value)
			
			v:ScaleTo(1 + value * 2)

			for _, v in parts do
				v.Transparency = value
			end

		end,
		function()
			v:Destroy()
			-- cnxn is disconnected by tweencallback class
			busy[v] = nil
		end)
	end,
	
	bobble = function(v: Model)
		if busy[v] then
			busy[v]:Disconnect()
		end

		busy[v] = TweenCallback.run(0.5, EasingFunctions.OutElastic, function(value)

			v:ScaleTo(1.1 * (1 - value) + value)
		end,
		function()
			v:Destroy()
			-- cnxn is disconnected by tweencallback class
			busy[v] = nil
		end)
	end,
}


return {
	methods = stuff,
	onInvoke = function(key, ...)
		if not stuff[key] then
			warn(`{key} is not a valid method for CommonAnimations`)
			return
		end
		stuff[key](...)
	end,
	_aliases = {
		"ca",
		"common",
	}
}