--!strict
-- pre-MMORPG revamp logic; contains lots of legacy code
local Player = game:GetService("Players").LocalPlayer:: Player
local ReplicatedStorage = game.ReplicatedStorage

local vars = require(ReplicatedStorage.Client.Backend.RemoteReceivers.vars):: {[string]: any}

local Indicators = require(script.Indicators)
local Graphics = require(ReplicatedStorage.Client.Graphics.cards)
local CardData = require(ReplicatedStorage.Modules.Data.Cards)
local CardUtil = require(ReplicatedStorage.Modules.Game.CardUtil)


local E = ReplicatedStorage.Remotes.MainE
local F = ReplicatedStorage.Remotes.MainF

local GroupCooldowns: {[string]: number} = {}

local function validate(str: string?): string
	return str or "empty"
end

local function isOnCooldown(attackName: string): number?
	local timer = GroupCooldowns[CardData[attackName].group]
	
	if not timer then return nil end
	local duration = timer - os.clock()
	if duration > 0 then
		return duration
	end
	return nil
end

vars.longsetted:Connect(function(motherKey: string, i: number | string, v: string?, _max: unknown) -- expects 3 arguments. If > 3 or < 3 then the action is irrelevant
	if _max ~= nil then return end
	if v == nil then return end
	
	if motherKey == "abilities" then
		Graphics.set(i:: number, v)
	
		if v ~= "empty" then
				
			local currentDebounce = isOnCooldown(v)
			
			if currentDebounce then
				Graphics.setCooldown(i:: number, currentDebounce)
			end

		end
	end
end)

local function onReset()
	Graphics.reset(vars.get("abilities"))
end

vars.reset:Connect(onReset)



local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local Mouse = Player:GetMouse()

local actionKeybinds = {
	[Enum.KeyCode.Q] = 1;
	[Enum.KeyCode.E] = 2;
	[Enum.KeyCode.R] = 3;
	[Enum.KeyCode.T] = 4;
	[Enum.KeyCode.F] = 5;
}

-- for mobile users
local selectedSlot: number?

ContextActionService:SetTitle("Attack", "Attack")


local function attack(abilityNumber: number, indicatorFeedback: any)
	local Character = Player.Character
	if Character then
		local PV = Character:GetPivot()
		E:FireServer("Attack", abilityNumber, PV.Position, indicatorFeedback or Mouse.Hit.Position)
	end
end

local activeSlot: number?
local currentIndicatorCleanupFunction: (() -> any)?

local function setIndicator(slot: number?)
	
	
	if not slot then
		
		if activeSlot then
			
			if currentIndicatorCleanupFunction then
				attack(activeSlot, currentIndicatorCleanupFunction())
				currentIndicatorCleanupFunction = nil
			else
				attack(activeSlot)
			end
			activeSlot = nil
			Graphics.setActiveAbility()
			
		end
		return
	end
	
	local src = vars.get("abilities")[slot]:: string?
	
	local attackName = CardUtil.fromSource(src)
	
	if not attackName then return end
	if isOnCooldown(attackName) then return end
	
	
	activeSlot = slot
	if Indicators.handlers[attackName] then
		currentIndicatorCleanupFunction = Indicators.handlers[attackName]()
	end
	
	Graphics.setActiveAbility(activeSlot)
end



task.defer(function()
	if vars.get("abilities") then
		onReset()
	else
		vars.reset:Wait()
	end

	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if activeSlot then return end
		local slot = actionKeybinds[input.KeyCode]
		
		if slot then
			setIndicator(slot)
		end
	end)


	UserInputService.InputEnded:Connect(function(input)
		
		if activeSlot and actionKeybinds[input.KeyCode] == activeSlot then
			setIndicator()
		end
	end)

	ContextActionService:BindAction("Attack", function(_, inputState)
		if not selectedSlot then return end
		if inputState == Enum.UserInputState.Begin then
			setIndicator(selectedSlot)
		elseif inputState == Enum.UserInputState.End then
			if activeSlot == selectedSlot then
				setIndicator()
			end
		end

	end, true)

	Graphics.selectionBegan:Connect(function(i)
		setIndicator(i)
	end)
	
	Graphics.selectionEnded:Connect(function(i)
		if activeSlot == i then
			setIndicator()
		end
	end)
end)

return {
	onInvoke = function(group: string, duration: number)
		GroupCooldowns[group] = os.clock() + duration

		for slot, src in vars.get("abilities"):: {string} do
			local name = CardUtil.fromSource(src)
			if not name then continue end
			if CardData[name].group == group then
				Graphics.setCooldown(slot, duration)
			end
		end

	end;
	_aliases = {
		"cd"
	};
}



