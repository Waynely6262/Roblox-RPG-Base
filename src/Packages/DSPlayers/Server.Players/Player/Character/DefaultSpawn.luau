local Players = game:GetService("Players")

return function(player, char)
	
	local humanoid: Humanoid?

	
	local onDestroyListener: RBXScriptConnection
	local onDiedListener: RBXScriptConnection?
	-- could be null because the died listener is created after a potential yield
	
	local function onDead()
		
		onDestroyListener:Disconnect()
		
		if onDiedListener then onDiedListener:Disconnect() end

		task.delay(Players.RespawnTime, player.LoadCharacterAsync, player)
		
	end
	onDestroyListener = char.Destroying:Once(onDead)
	
	humanoid = char:WaitForChild("Humanoid"):: Humanoid
	onDiedListener = humanoid.Died:Once(onDead)
	
	
end


