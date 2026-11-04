--!strict

--[[

Implementing a tool:


This module will send the following data to built-in methods:

equip:
1: Rig
2: Humanoid
3: Tool Model
4: Extra data associated with the tool, which was passed during initialization
5, ...: Data passed by the client (not sanitized)


]]

export type ToolFunction = (char: Model, humanoid: Humanoid , tool: Model, data: any, ...any) -> (string?)
export type ToolFunctionGroup = {
	_equip: ToolFunction,
	_unequip: ToolFunction,
	[string]: ToolFunction
}

local tool_methods: {
	[string]: ToolFunctionGroup
} = {}

local Players = game:GetService("Players")

local CONFIG = require(game.ReplicatedStorage.Modules.PackageConfig.CustomTools)
local E = game.ReplicatedStorage.Remotes.MainE

local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)

local function FindPlayer(rig: Model): Player?
	return Players:GetPlayerFromCharacter(rig)
end

local function AttachToolToRig(c: Model, t: Model): boolean

	local P0: BasePart
	local P1: BasePart = assert(t:FindFirstChild("Handle"):: BasePart)
	local A0: Attachment
	local A1: Attachment? = P1:FindFirstChildWhichIsA("Attachment")
	local C0: CFrame
	local C1: CFrame


	if A1 and A1.Name ~= "" then
		A0 = assert(c:FindFirstChild(A1.Name, true), `Could not find {A1.Name} on rig {c:GetFullName()}.`):: Attachment
		C1 = A1.CFrame
	else
		A0 = c:FindFirstChild("RightGripAttachment", true):: Attachment
		C1 = CFrame.identity
	end

	C0 = A0.CFrame
	P0 = A0.Parent:: BasePart



	if C0 and C1 and P0 and P1 then

		local Weld = Instance.new("Weld")
		Weld.C0 = C0
		Weld.C1 = C1
		Weld.Part0 = P0
		Weld.Part1 = P1
		Weld.Name = "CustomTool_Grip"
		Weld.Parent = t

		return true
	end

	return false
end

local ToolModels = require(game.ServerScriptService.Root.Utils.ToolSearch);
local Welder = require(game.ReplicatedStorage.Modules.Utility.Welder)

if CONFIG.DO_PREWELD then


	for _, v in ToolModels do
		Welder.weldAll(v)
		for _, vv in v:GetDescendants() do
			if vv:IsA("BasePart") then
				vv.CanCollide = false
				vv.CanTouch = false
				vv.CanQuery = false
				vv.Massless = true
			end
		end

	end

end



do
	for _, v in script:GetChildren() do
		local s,r = pcall(function()

			local module = require(v)

			tool_methods[v.Name] = module

			for _, def in CONFIG.SERVER_API_REQS do
				if not module[def] then
					warn(`{v.Name} is missing a definition for '{def}'`)
				end
			end

		end)

		if not s then
			warn(`[Server: Custom Tools] Failed to load tool controller {v.Name}: {r}`)
		end
	end
end

local ActiveTools = setmetatable({}:: {
	[Model]: {
		[string]: {
			model: Model,
			humanoid: Humanoid,
			methods: ToolFunctionGroup,
			controller_name: string,
			data: any,
		}
	}
}

, {__mode = "k"})
-- TODO: Make sure this ain't a memory leak

-- this model supports equipping one tool at a time. To add support for multiple tools, add left-hand or custom welding and add a parameter to this function to specify which tool to remove
local unequip = function(rig: Model, group: string?)
	local group = group or CONFIG.DEFAULT_GROUP_KEYWORD


	local activeToolInfo = ActiveTools[rig] and ActiveTools[rig][group]

	if activeToolInfo then

		if activeToolInfo.methods then
			task.defer(activeToolInfo.methods._unequip, rig, activeToolInfo.humanoid, activeToolInfo.model, activeToolInfo.data)
		end
		activeToolInfo.model:Destroy()

		ActiveTools[rig][group] = nil
		
	end


	local Player = FindPlayer(rig)
	if Player then
		E:FireClient(Player, "Tool", group, nil)
	end

end

local equip = function(rig: Model, toolName: string, group: string?, overwrite: boolean?, extraData: any)
	local group = group or CONFIG.DEFAULT_GROUP_KEYWORD

	if overwrite then
		unequip(rig, group)
	else
		assert(not (ActiveTools[rig] and ActiveTools[rig][group]), `{rig.Name} can't equip tool because the rig is already holding a registered tool!`)
	end

	local humanoid = assert(rig:FindFirstChildWhichIsA("Humanoid"), `{rig.Name} can't equip tool because no humanoid was found`)

	local toolTemplate = ToolModels[toolName]
	if not toolTemplate then
		warn(`{rig.Name} Could not equip "{toolName}": no such tool; using Unarmed as placeholder`)
		toolTemplate = ToolModels.Unarmed
	end

	local newTool = toolTemplate:Clone()

	newTool:SetAttribute(CONFIG.TYPE_NAME, newTool:GetAttribute(CONFIG.TYPE_NAME) or toolName)
	newTool:SetAttribute("OG_NAME", toolName)
	newTool.Name = `{rig.Name}'s Tool ({toolName})`
	
	if CONFIG.EXTERIOR_PARENT[group] then
		newTool.Parent = rig.Parent
	
		local c1: RBXScriptConnection
		local c2: RBXScriptConnection
	
		local function disconnect()
			c1:Disconnect()
			c2:Disconnect()
		end
	
		c1 = rig.Destroying:Once(function()
			disconnect()
			newTool:Destroy()
		end)
		
		c2 = newTool.Destroying:Once(disconnect)
	else
		newTool.Parent = rig
	end

	assert(AttachToolToRig(rig, newTool), `{rig.Name} can't equip {toolName} because failed to attach model to the rig`)

	local ctrl_name = newTool:GetAttribute(CONFIG.TYPE_NAME) or newTool.Name
	
	local methods = ctrl_name and tool_methods[ctrl_name]
	
	if methods then
		methods._equip(rig, humanoid, newTool, extraData)
	end

	ActiveTools[rig] = ActiveTools[rig] or {}
	ActiveTools[rig][group] = {
		model = newTool;
		humanoid = humanoid;
		methods = methods;
		controller_name = ctrl_name;
		data = extraData;
	}

	local Player = FindPlayer(rig)
	if Player then
		E:FireClient(Player, "Tool", group, newTool, ctrl_name)
	end

end


local processResponses = {
	unequip = unequip;
}

return {

	equip = equip;
	unequip = unequip;	
	-- @param toolInfo is any extra data that the tool handler may use to execute its function. It should handle being left blank if for example the rig is not part of a player
	processAsync = function(rig: Model, action: string, ...: any)

		local RigActiveTools = ActiveTools[rig]

		assert(RigActiveTools, `Rig has no active tools ({rig:GetFullName()})`)

		assert(action:sub(1) ~= "_", `Cannot externally process an internal method {action}`)

		for _, ActiveToolInfo in RigActiveTools do
			
			if not ActiveToolInfo.methods then
				continue
			end
			local f = ActiveToolInfo.methods[action]
			
			if f then
				local result: {any} = {f(rig, ActiveToolInfo.humanoid, ActiveToolInfo.model, ActiveToolInfo.data, ...)}
				if result[1] then
					processResponses[result[1]](table.unpack(result, 2))
				end
			end
		end
	end,
	_active_tools_infos = ActiveTools;
}


