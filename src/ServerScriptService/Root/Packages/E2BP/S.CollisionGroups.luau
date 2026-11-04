local PhysicsService = game:GetService("PhysicsService")

local Groups = {
	Targetable = "atk";
	Character = "char";
	Collection = "cllc";
	Default = "Default";
}


local function Register(name)
	if not PhysicsService:IsCollisionGroupRegistered(name) then
		PhysicsService:RegisterCollisionGroup(name)
	end
end

for _, v in Groups do
	Register(v)
end



PhysicsService:CollisionGroupSetCollidable(Groups.Character, Groups.Character, false)
PhysicsService:CollisionGroupSetCollidable(Groups.Character, Groups.Targetable, false)

PhysicsService:CollisionGroupSetCollidable(Groups.Collection, Groups.Character, false)
PhysicsService:CollisionGroupSetCollidable(Groups.Collection, Groups.Default, false)
PhysicsService:CollisionGroupSetCollidable(Groups.Collection, Groups.Targetable, true)


return Groups
