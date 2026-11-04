--!strict
local API = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeepGet = require(script.DeepGetChildren)

local ToolModels = DeepGet.kv(ReplicatedStorage.Models.Tools)
local StructureModels = DeepGet.kv(ReplicatedStorage.Models.Structures)
local EntityModels = DeepGet.kv(ReplicatedStorage.Models.Entities)

local UndefinedCube = Instance.new("Model")
local p = Instance.new("MeshPart")
p.Parent = UndefinedCube
p.Size = Vector3.new(4,4,4)
p.CanCollide = false
p.Anchored = true
p.Material = Enum.Material.ForceField
p.Name = "Undefined"

local function t_rand(t)
	if not t then return nil end
	return t[math.random(#t)]
end

function API.getStructure(str: string)
	return t_rand(StructureModels[str]):: Model? or UndefinedCube
end

function API.getEntity(str: string)
	return t_rand(EntityModels[str]):: Model? or UndefinedCube
end

function API.getTool(str: string)
	return t_rand(ToolModels[str]):: Model? or UndefinedCube
end

return API