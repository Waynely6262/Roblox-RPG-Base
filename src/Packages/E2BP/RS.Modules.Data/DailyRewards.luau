--!strict
local isServer = game:GetService("RunService"):IsServer():: any
local Giver = isServer and require(game:GetService("ServerScriptService").Root.Utils.Giver)


return {
	-->> areas in order
	["Interval"] = 60 * 60 * 18; -- 18 hours
	
	["Rewards"] = {
		{
			Title = "10000 Cash";
			Give = function(player)
				assert(isServer, "this can't be called on the client")
					return Giver.Give(player, "leaderstats", "Cash", 10000)
			end,
		},
		{
			Title = "15000 Cash";
			Give = function(player)
				assert(isServer, "this can't be called on the client")
					return Giver.Give(player, "leaderstats", "Cash", 15000)
			end,
		},
		{
			Title = "25000 Cash";
			Give = function(player)
				assert(isServer, "this can't be called on the client")
					return Giver.Give(player, "leaderstats", "Cash", 25000)
			end,
		},
		{
			Title = "40000 Cash";
			Give = function(player)
				assert(isServer, "this can't be called on the client")
					return Giver.Give(player, "leaderstats", "Cash", 40000)
			end,
		},
		{
			Title = "70000 Cash";
			Give = function(player)
				assert(isServer, "this can't be called on the client")
					return Giver.Give(player, "leaderstats", "Cash", 70000)
			end,
		},
		{
			Title = "100000 Cash";
			Give = function(player)
				assert(isServer, "this can't be called on the client")
					return Giver.Give(player, "leaderstats", "Cash", 100000)
			end,
		},
		{
			Title = "Roll Mythic Card";
			Give = function(player)
				assert(isServer, "this can't be called on the client")
					return Giver.NewVariable(player, "BoolValue",true, "FireExt", "Data", "OwnedJetpacks")
			end,
		},
	}
	
	
}