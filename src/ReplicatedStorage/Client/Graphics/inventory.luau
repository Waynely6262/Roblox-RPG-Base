--!strict

local GROUP = "Menus"

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local UIAPI = require(ReplicatedStorage.Client.Graphics.Util.UIAPI)
local ItemFrameAPI = require(ReplicatedStorage.Client.Graphics.ItemFrameAPI)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)
local MouseLock = require(ReplicatedStorage.Client.Graphics.Util.MouseLock)
local Locations = require(ReplicatedStorage.Modules.Inventory.Location)
local InventoryConfig = require(ReplicatedStorage.Modules.PackageConfig.Inventory)
local FollowMouse = require(ReplicatedStorage.Client.Graphics.Util.FollowMouse)

local Catalog = require(ReplicatedStorage.Modules.Inventory.Item.Catalog)
----------------------------------------------------------------------------------------------------
local Player = game:GetService("Players").LocalPlayer:: Player
local PlayerGui = Player.PlayerGui

local screenGui = UIAPI.getByName("Inventory"):: typeof(ReplicatedStorage.Client.UserInterface.Inventory)
local persistentGui = UIAPI.getByName("PersistentGui"):: typeof(ReplicatedStorage.Client.UserInterface.PersistentGui)
local mainframe = screenGui.Main

local widget = UIAPI.newGroupedFrame(mainframe, GROUP, screenGui)

local GameplayHotbarFrame = persistentGui:FindFirstChild("ActiveHotbar")
local GameplayHotbarWidget = UIAPI.newGroupedFrame(GameplayHotbarFrame, "Gameplay")
local HotbarFrame = mainframe:FindFirstChild("Hotbar", true).Parent:: Instance
local StorageFrame = mainframe:FindFirstChild("Storage", true).Parent :: Instance
local EquipmentFrame = mainframe:FindFirstChild("Equipment", true).Parent :: Instance
local ExternalFrame = mainframe:FindFirstChild("External", true).Parent :: Instance
local SwapperFrame = assert(ExternalFrame:IsA("GuiObject") and ExternalFrame or ExternalFrame:FindFirstAncestorWhichIsA("GuiObject"), `Couldn't locate GuiObject for SwapperFrame`):: GuiObject

local SelectionBegan = Signal.new():: Signal.Signal<"Hotbar" | "Storage" | "Equipment", number>
local SelectionEnded = Signal.new():: Signal.Signal<"Hotbar" | "Storage" | "Equipment", number>
local ToggleEquipRequested = Signal.new():: Signal.Signal<"Hotbar" | "Storage", number>

-- static variables

local GuiInsetOffset = GuiService:GetGuiInset()

local static = {
	SelectionBegan = SelectionBegan;
	SelectionEnded = SelectionEnded;
	ToggleEquipRequested = ToggleEquipRequested;
}

static.InventoryWidget = widget
local CurrentlyDisplaying = {}:: {[string]: string?}

local frameTree = {
	Drag = {}:: {[any]: ItemFrameAPI.ItemFrame},
	Hotbar = {}:: {[any]: ItemFrameAPI.ItemFrame},
	Storage = {}:: {[any]: ItemFrameAPI.ItemFrame},
	Equipment = {}:: {[any]: ItemFrameAPI.ItemFrame},
	External = {}:: {[any]: ItemFrameAPI.ItemFrame},
}:: {[string]: {[any]: ItemFrameAPI.ItemFrame}}

-- Dictionary that gets the container and slot associated with an indexed GUI frame.
local locationOfFrame: {[GuiObject]: {string | number}} = {}

for i = 1, 10 do
	local frame = ItemFrameAPI.new(HotbarFrame, i, tostring(i%10))
	local frame2 = ItemFrameAPI.new(GameplayHotbarFrame, i, tostring(i%10))
	
	Button.new(frame2.Frame).Activated:Connect(function()
		ToggleEquipRequested:Fire("Hotbar", i)
	end)
	frame:addMirror(frame2)
	frame:Clear(true)
	table.insert(frameTree.Hotbar, frame)

	locationOfFrame[frame.Frame] = {"Hotbar", i}
	
end


for i = 1, 30 do
	
	local frame = ItemFrameAPI.new(StorageFrame, i, tostring(i))
	frame:Clear(true)
	table.insert(frameTree.Storage, frame)

	locationOfFrame[frame.Frame] = {"Storage", i}
end


for i = 1, 30 do

	local frame = ItemFrameAPI.new(ExternalFrame, i, tostring(i))
	frame:Clear(true)
	table.insert(frameTree.External, frame)

	locationOfFrame[frame.Frame] = {"External", i}
end

local names = InventoryConfig.EquipmentKeys

for i, name in names do
	
	local frame = ItemFrameAPI.new(EquipmentFrame, i, name)
	frame:Clear(true)

	table.insert(frameTree.Equipment, frame)

	locationOfFrame[frame.Frame] = {"Equipment", i}

end

local DragFrame: ItemFrameAPI.ItemFrame do -- drag
	
	DragFrame = ItemFrameAPI.new(mainframe, nil, "")
	DragFrame:Clear(true)
	frameTree.Drag[1] = DragFrame
	DragFrame.Frame.BackgroundTransparency = 1
	local stroke = DragFrame.Frame:FindFirstChildWhichIsA("UIStroke")
	if stroke then stroke:Destroy() end
	DragFrame.Frame.BorderSizePixel = 0
	DragFrame.Display.Icon.Visible = false
	DragFrame.Display.TextLabel.Visible = false
	DragFrame.Display.NameLabel.Text = ""
end


function static.toggle(enabled: boolean?): boolean
	local bool = widget:Toggle(enabled)
	MouseLock("inv", bool)

	return bool
end

function static.clearOne(containerName: string, slot: number)

	local frame = frameTree[containerName][slot]
	frame:Clear(true)
end

function static.set(containerName: string, slot: number, item: any)
	
	local frame = frameTree[containerName][slot]
	frame:Set(item)
	
end

function static.setHighlight(containerName: string, slot: number, doHighlight: boolean)
	local frame = frameTree[containerName][slot]
	frame:SetHighlight(doHighlight)
end

local interfaceActive = false
local externalState = false
function static.toggleExternal(state: boolean)
	externalState = state
	
	if interfaceActive then return end
	SwapperFrame.Visible = state
end

function static.setInterfaceActive(bool: boolean)
	interfaceActive = bool
	
	if interfaceActive then
		SwapperFrame.Visible = false
	else
		SwapperFrame.Visible = externalState
	end
end


local function whatAtCursor(pos): {number | string}?

	for _, f in PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y) do
		if locationOfFrame[f:: GuiObject] then
			return locationOfFrame[f:: GuiObject]
		end
	end
	return nil
end

local InputTypes = {
	[Enum.UserInputType.MouseButton1] = true;
	[Enum.UserInputType.Touch] = true;
}
local InputMovementTypes = {
	[Enum.UserInputType.Touch] = true;
	[Enum.UserInputType.MouseMovement] = true;
}

local BeganCnxn: RBXScriptConnection?
local EndedCnxn: RBXScriptConnection?
local ChangedCnxn: RBXScriptConnection?

local function Disconnect()
	if BeganCnxn then
		BeganCnxn:Disconnect()
	end
	if EndedCnxn then
		EndedCnxn:Disconnect()
	end
end

widget.Closed:Connect(function()
	Disconnect()
	GameplayHotbarWidget:Toggle(true)
	FollowMouse.stop(DragFrame.Frame)
end)

widget.Opened:Connect(function()

	Disconnect()
	GameplayHotbarWidget:Toggle(false)

	BeganCnxn = UserInputService.InputBegan:Connect(function(input)

		if InputTypes[input.UserInputType] then

			local info = whatAtCursor(input.Position)

			if info then
				SelectionBegan:Fire(info[1]:: "Hotbar" | "Storage" | "Equipment", info[2]:: number)
			end
		end 
	end)

	EndedCnxn = UserInputService.InputEnded:Connect(function(input)

		if InputTypes[input.UserInputType] then
			local info = whatAtCursor(input.Position)

			if info then
				SelectionEnded:Fire(info[1]:: "Hotbar" | "Storage" | "Equipment",info[2]:: number)
			end
		end
	end)

	FollowMouse.begin(DragFrame.Frame)
end)


game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

static.toggleExternal(false)

return static