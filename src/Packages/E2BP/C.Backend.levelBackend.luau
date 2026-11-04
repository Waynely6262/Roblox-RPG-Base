--!strict
local Player = game:GetService("Players").LocalPlayer

local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local Graphics = require(game.ReplicatedStorage.Client.Graphics.Levels)
local LevelUtil = require(game.ReplicatedStorage.Modules.Game.Levelling)
local Config = require(game.ReplicatedStorage.Modules.Game.Config)

local vars = require(game.ReplicatedStorage.Client.Backend.RemoteReceivers.vars)
local quota: number

local nextLevelReq: number
local registeredOverallLevel: number?
local function xp_onChanged(x: number, skillName: string)

	
	if skillName == "overall" then
		local maxLevel = vars.get("maxLevel")
		if not maxLevel then warn(`Couldn't update level because maxLevel is not defined`) return end
		local currentLevel, levelXP = LevelUtil.Levels:getLevel(x, maxLevel)
		if registeredOverallLevel ~= currentLevel then
			Graphics.setOverallLevel(currentLevel)
			registeredOverallLevel = currentLevel
			
			
			nextLevelReq = math.ceil(LevelUtil.Levels:xpToNextLevel(currentLevel, maxLevel) or 0)
		end
		
		Graphics.setOverallXP(math.floor(levelXP), nextLevelReq)
	else
		local maxSkillLevel = vars.get("maxSkillLevel")
		if not maxSkillLevel then warn(`Couldn't update skill b/c maxSkillLevel is not defined`) return end
		local currentLevel, levelXP = LevelUtil.Levels:getLevel(x, maxSkillLevel)
		
		Graphics.setSkillXP(skillName, math.floor(levelXP), math.ceil(LevelUtil.Levels:xpToNextLevel(currentLevel, maxSkillLevel) or 0))
		
		-- doesn't check if the level changed, but this should be a relatively inexpensive
		-- call because it only updates a couple of values in the skill page
		Graphics.setSkillLevel(currentLevel)
	end
end

vars.longsetted:Connect(function(dir, skill: string | {[string]: number}, totalXp)
	
	if dir == "levelling" then
		if totalXp then
			xp_onChanged(totalXp:: number, skill:: string)
		else
			for skillName, xp in skill:: {[string]: number} do
				xp_onChanged(xp, skillName)
			end
		end
	end
end)

vars.changed:Connect(function(key)
	if key == "maxSkillLevel" then
		for skillName, xp in skill:: {[string]: number} do
			xp_onChanged(xp, skillName)
		end
	elseif key == "maxLevel" then
		xp_onChanged(vars.get("levelling").overall or 0, "overall")
	end
end)

vars.reset:Connect(function()
	xp_onChanged(vars.get("levelling").overall or 0, "overall")
end)

return true

