
-- Relays remote events to the main server tools module

local ServerToolsModule = require(game.ServerScriptService.Root.Tools)

return {
	onInvoke = function(player: Player, action: string, ...)
		
		-- The server already knows what tool the player is holding, so it doesn't need to be sent.
		-- The action string will be automatically mapped by Server/Tools
		
		ServerToolsModule.processAsync(player.Character, action, ...)
		
	end,
}