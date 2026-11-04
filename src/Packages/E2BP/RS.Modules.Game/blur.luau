--!strict
local cm = {}


local camera = workspace.CurrentCamera:: Camera

local states = {}:: {[string]: {}}
local enabledStates = {}

local currentState: string?

local Tween = require(game.ReplicatedStorage.Modules.Utility.Tween)

cm.DefaultType = Enum.CameraType.Custom
cm.StateEnabledType = Enum.CameraType.Scriptable

cm.Ease = require(game.ReplicatedStorage.Modules.Utility.EasingFunctions).OutExpo
cm.Duration = 1


local function changeActiveState(newStateName: string?)
	currentState = newStateName
	
	if newStateName then
		camera.CameraType = cm.StateEnabledType
		
		Tween(camera, states[newStateName], cm.Ease, cm.Duration)
	else
		camera.CameraType = cm.DefaultType
	end
	
end

function cm.addState(nameOfState: string, tweenInfo: {[string]: any})
	states[nameOfState] = tweenInfo
end

function cm.setState(nameOfState: string, isEnabled: boolean)
	local i = table.find(enabledStates, nameOfState)
	if isEnabled and not i then
		table.insert(enabledStates, nameOfState)
		
		if nameOfState ~= currentState then
			changeActiveState(nameOfState)
		end
	elseif i and not isEnabled then
		
		
		table.remove(enabledStates, i)
		
		-- active state should always be the last element of the list, so the new last is just old last - 1
		if nameOfState == currentState then
			changeActiveState(enabledStates[i - 1]:: string?)
		end
	end
end

function cm.clearStates()
	enabledStates = {}
	changeActiveState(nil)
end
return cm