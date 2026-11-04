--!strict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CONFIG = require(game.ReplicatedStorage.Modules.PackageConfig.CustomTools)
local Finder = require(game.ReplicatedStorage.Modules.Utility.Finder)
local Keybinds = require(game.ReplicatedStorage.Client.Graphics.Util.Keybinds)

local LocalPlayer = game:GetService("Players").LocalPlayer:: Player

local IsAliveVB = Finder.followPathAsync(LocalPlayer, "Transient", "IsAlive"):: BoolValue

local RegisteredControllers = {}:: {[string]: {[string]: any}} do
	for _, v in script:GetChildren() do
		local s = pcall(function()

			local module = require(v)

			RegisteredControllers[v.Name] = module

			for _, def in CONFIG.CLIENT_API_REQS do
				if not module[def] then
					print(`{v.Name} is missing a definition for '{def}'`)
				end
			end


		end)

		if not s then
			warn(`[Client: CustomTools] Failed to load tool controller {v.Name}: {r}`)
		end
	end
end

local ActiveTools = {}:: {[string]: Model}



local ActiveControllers: {
	[string]: {
		input_began: (InputObject) -> (),
		input_ended: (InputObject) -> (),
		render_stepped: (number) -> ()?,
		heartbeat: (number) -> ()?,
		input_hints: {[Enum]: {[Enum.KeyCode | Enum.UserInputType]: string}}?,
	}
} = {
	[CONFIG.DEFAULT_GROUP_KEYWORD] = RegisteredControllers._none;
}

local function SetController(group: string, controllerName: string?)
	if ActiveControllers[group] then
		local hints = ActiveControllers[group].input_hints 
		if hints then
			
			if hints[Enum.UserInputType] then
				for key, hint in hints[Enum.UserInputType] do
					Keybinds.remove(hint)
				end
			end
			
			if hints[Enum.KeyCode] then
				for key, hint in hints[Enum.KeyCode] do
					Keybinds.remove(hint)
				end
			end
		end
	end
	
	if controllerName then
		local controller = RegisteredControllers[controllerName]
		if not controller then
			warn(`[Client: CustomTools] Controller '{controllerName}' not found`)
			return
		end
		ActiveControllers[group] = controller:: any
		
		local hints = controller.input_hints
		
		if hints then
			if hints[Enum.UserInputType] then
				for key, hint in hints[Enum.UserInputType] do
					Keybinds.set(nil, key, hint)
				end
			end
			if hints[Enum.KeyCode] then
				for key, hint in hints[Enum.KeyCode] do
					Keybinds.set(key, nil, hint)
				end
			end
		end
	else
		ActiveControllers[group] = nil
	end
end

for group, controllerName in CONFIG.PreloadedControllers do
	SetController(group, controllerName)
end

local RegisteredCharacter



local function action_allowed(): boolean?

	-- A tool is being used but the tool belongs to an older character
	if next(ActiveTools) and RegisteredCharacter ~= LocalPlayer.Character then return false end
	return IsAliveVB.Value
end

-- Single event listener
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if not action_allowed() then return end

	for _, ActiveController in ActiveControllers do
		if ActiveController.input_began then
			ActiveController.input_began(input)
		end
	end


end)

UserInputService.InputEnded:Connect(function(input)

	if not action_allowed() then return end

	for _, ActiveController in ActiveControllers do
		if ActiveController.input_ended then
			ActiveController.input_ended(input)
		end
	end


end)

RunService.RenderStepped:Connect(function(dt)
	if not action_allowed() then return end
	for _, ActiveController in ActiveControllers do
		if ActiveController.render_stepped then
			ActiveController.render_stepped(dt)
		end
	end
end)


RunService.Heartbeat:Connect(function(dt)
	if not action_allowed() then return end

	for _, ActiveController in ActiveControllers do
		if ActiveController.heartbeat then
			ActiveController.heartbeat(dt)
		end
	end
end)

--[[
Controllers are meant to handle:

- Sending events to the server
- Playing client-sided animations
- Performing some client-side actions early
	- Potential model for predictive client-side actions: client performs an action while waiting for the server to approve it. If the server doesn't approve it, it'll send a disapproval message back and cause the client to revert some action, OR the server will handle the disapproval. This feature will help achieve gameplay with actions closer to real-time.
]]

return {
	onInvoke = function(group: string, tool: Model?, controller_id: string?)
		-- Note that the model may not send, depending on client internal processing order. This code assumes that: the instance is created and parented to the character before remotesignals are processed, meaning that the model, created on the same heartbeat, is passable as an argument.
		-- If the above assumption does not hold, use the local player's character and WaitForChild(<tool name>) to obtain said tool, with an optional timeout.
		-- If the client does not process the equip action, nothing fatal should happen on the server's end, the client will only be unable to use the tool they equipped.

		ActiveTools[group] = tool
		

		-- The point of keeping track of the player's character is to make sure that when the player respawns, the residual controller isn't used.
		RegisteredCharacter = LocalPlayer.Character

		if tool then
			SetController(group, controller_id:: string)
		elseif controller_id then
			SetController(group, controller_id)
		else
			SetController(group, group == CONFIG.DEFAULT_GROUP_KEYWORD and "_none" or nil)
		end
	end,
}