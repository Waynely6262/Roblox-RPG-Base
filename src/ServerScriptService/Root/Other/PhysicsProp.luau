local rand = Random.new()
local Teams = require(game.ServerScriptService.Root.Other.Teams)
local Welder = require(game.ReplicatedStorage.Modules.Utility.Welder)
local AccessRS = require(game.ServerScriptService.Root.Utils.AccessRS)
local FXTeam = Teams.get("fx")

local Memo = {}
local function Prepare(Template: Model)
	local M = Template:Clone()

	for _, v in M:GetDescendants() do
		if v:IsA("BasePart") then
			v.CollisionGroup = 'prop'
			v.CanCollide = true
			v.Anchored = false
		end
	end
	Welder.weldAll(M, true)
	
	Memo[Template] = M
	return M
end

for _, v in game.ReplicatedStorage.Models.Tools:GetDescendants() do
	if v.Parent.ClassName == "Folder" and v.ClassName == "Model" then
		Prepare(v)
	end
end

return function(Template: Model, Position: Vector3, Lifetime: number?)
	
	if not Memo[Template] then
		warn(`Dynamic preparation on {Template:GetFullName()}`)
		Prepare(Template)
	end
	
	local M = Memo[Template]:Clone()	
	
	M:PivotTo(CFrame.new(Position, Position + rand:NextUnitVector()));
	
	M:FindFirstChildWhichIsA("BasePart").AssemblyLinearVelocity = rand:NextUnitVector() * 20
	
	FXTeam:addChild(M)
	
	task.delay(Lifetime or 5, M.Destroy, M)
end