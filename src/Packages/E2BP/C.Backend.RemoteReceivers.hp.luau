local Graphics = require(game.ReplicatedStorage.Client.Graphics.Health)


local acts = {
	max = Graphics.setMaxHealth;
	dt = Graphics.setHealth;
}

return {
	onInvoke = function(act: string, ...)
		
		
		acts[act](...)
	end,
	
}

