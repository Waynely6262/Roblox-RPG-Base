--!strict
-- loading api
local ReplicatedStorage = game.ReplicatedStorage
local PlayerGui = (game:GetService("Players").LocalPlayer:: Player).PlayerGui

local UIStorage = game.ReplicatedStorage.Client.UserInterface
local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)

type FrameGroup = {[GuiObject]: Widget.Widget}

local LoadedInterfaces = {}:: {[string]: ScreenGui}
local Frames = {}:: {[GuiObject]: Widget.Widget}
local GroupedFrames = {}:: {[string]: FrameGroup}
local FrameGroupKV = {}

local API = {}

API.load = function(ScreenGui: ScreenGui | string?, clone: boolean?): ScreenGui

	if typeof(ScreenGui) == "string" then
		if LoadedInterfaces[ScreenGui:: string] then
			return LoadedInterfaces[ScreenGui:: string]
		end
		ScreenGui = assert(UIStorage:FindFirstChild(ScreenGui:: string), `Failed to load {ScreenGui:: string} because not found`):: ScreenGui?
	else
		if LoadedInterfaces[(ScreenGui:: ScreenGui).Name] then
			return LoadedInterfaces[(ScreenGui:: ScreenGui).Name]
		end
	end

	local guiComponent: ScreenGui
	if clone then
		guiComponent = (ScreenGui:: ScreenGui):Clone()
	else
		guiComponent = ScreenGui:: ScreenGui
	end
	guiComponent.Parent = PlayerGui

	LoadedInterfaces[guiComponent.Name] = guiComponent

	return guiComponent
end

API.getByName = function(name: string): ScreenGui
	return assert(LoadedInterfaces[name] or UIStorage:FindFirstChild(name), `No such UI element {name}`):: ScreenGui
end

function API.getFrameGroup(groupName: string): FrameGroup
	GroupedFrames[groupName] = GroupedFrames[groupName] or {}
	return GroupedFrames[groupName]
end


API.newGroupedFrame = function(mainframe: GuiObject, groupName: string, screenGui: ScreenGui?): Widget.Widget
	-- screenGui is used for optimization of component rendering
	local newWidget = Widget.new(screenGui, mainframe)
	API.getFrameGroup(groupName)[mainframe] = newWidget
	Frames[mainframe] = newWidget
	FrameGroupKV[mainframe] = groupName
	return newWidget
end

function API.closeGroup(groupName: string)
	for mainframe, widget in API.getFrameGroup(groupName) do
		widget:Toggle(false)
	end
end

API.disableFrame = function(mainframe: GuiObject)	
	API.getWidget(mainframe):Toggle(false)
end

API.enableFrame = function(mainframe: GuiObject)

	local groupName = FrameGroupKV[mainframe]

	API.closeGroup(groupName)

	API.getWidget(mainframe):Toggle(true)
end

function API.getWidget(mainframe: GuiObject): Widget.Widget
	return Frames[mainframe]
end

return API
