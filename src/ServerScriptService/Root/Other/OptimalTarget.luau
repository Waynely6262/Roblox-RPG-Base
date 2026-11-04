local ToolsModule = require(game.ServerScriptService.Root.Tools)
local GameConfig = require(game.ReplicatedStorage.Modules.Game.Config)
return function(attacker: Model, defender: Model)
	local PlayerToolInfo = ToolsModule._active_tools_infos[attacker]
	if not PlayerToolInfo then return end

	local maxreach = GameConfig.WEAPON_MAX_REACH_STUDS[PlayerToolInfo.controller_name] or GameConfig.WEAPON_MAX_REACH_STUDS.default

	-- head is the best part to use as POV
	local head = attacker:FindFirstChild("Head"):: BasePart?
	if not head then return end
	local selectionPosition = defender:GetPivot().Position
	local difference = (selectionPosition - head.Position)
	if difference.Magnitude <= maxreach then
		ToolsModule.processAsync(attacker, "auto", difference.Unit)
	end
end