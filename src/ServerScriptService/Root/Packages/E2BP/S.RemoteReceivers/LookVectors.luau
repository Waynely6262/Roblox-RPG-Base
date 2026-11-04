local Vectors = {}

game.Players.PlayerRemoving:Connect(function(player)
	Vectors[player] = nil
end)


return {
	onInvoke = function(player: Player, v: Vector3)
		assert(typeof(v) == "Vector3", `{player.Name} did not send a Vector3.`)
		if player.Parent then
			Vectors[player] = v
		end
	end,
	
	get = function(player: Player)
		return Vectors[player] or Vector3.zAxis
	end,
	
	_aliases = {
		"lv";
	},
}