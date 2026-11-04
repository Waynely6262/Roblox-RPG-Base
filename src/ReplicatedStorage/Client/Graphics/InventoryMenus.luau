--!strict

local GROUP = "Menus"

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local UIAPI = require(ReplicatedStorage.Client.Graphics.Util.UIAPI)
local ItemFrameAPI = require(ReplicatedStorage.Client.Graphics.ItemFrameAPI)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)
local MouseLock = require(ReplicatedStorage.Client.Graphics.Util.MouseLock)

local InventoryGraphics = require(ReplicatedStorage.Client.Graphics.inventory)
local InventoryConfig = require(ReplicatedStorage.Modules.PackageConfig.Crafting)

local Catalog = require(ReplicatedStorage.Modules.Inventory.Item.Catalog)
----------------------------------------------------------------------------------------------------
type Widget = typeof(UIAPI.newGroupedFrame(Instance.new("Frame"),""))
local screenGui = UIAPI.getByName("Inventory"):: typeof(ReplicatedStorage.Client.UserInterface.Inventory)

local InventoryInterfaceFrame = screenGui:FindFirstChild("InterfaceFrame", true)

local buttonHolderFrame = assert(InventoryInterfaceFrame:FindFirstChild("InvMenusButtons"), `Couldn't locate invmenus button adornee`):: GuiObject

local mainframe = assert(InventoryInterfaceFrame:FindFirstChild("InvMenusFrame"), `Couldn't find gui for craft`):: GuiObject

local RegisteredMenus = {}:: {[string]: GuiObject}
local BindedMenuControllers = {}:: {[string]: (boolean) -> ()}

local ButtonTemplate = script.Template

local CurrentlyDisplaying: string?

for _, v in mainframe:GetChildren() do

	local name = v.Name

	local widget = UIAPI.newGroupedFrame(v:: GuiObject, "InvMenus")
	RegisteredMenus[name] = v

	local buttonFrame = ButtonTemplate:Clone()
	buttonFrame.Name = name .. " Button"
	buttonFrame.Parent = buttonHolderFrame

	local button = Button.new(buttonFrame)

	buttonFrame.TextLabel.Text = name

	button.Activated:Connect(function()

		widget:Toggle(true)

		for thisName, v in BindedMenuControllers do
			v(name == thisName)
		end
		CurrentlyDisplaying = name
	end)

end

local api = {}

function api.bindMenuHandler(name: string, handler: (boolean) -> ()): GuiObject
	if BindedMenuControllers[name] then warn(`The menu {name}'s handler has been overwritten.`) end
	BindedMenuControllers[name] = handler
	return RegisteredMenus[name]
end

-- getWidget is a little wonky here; it's accessed by the frame it controls. TODO: add optional string access in UIAPI by allowing a 'name' argument for the API widget registration function
UIAPI.getWidget(screenGui.Main).Opened:Connect(function()
	if CurrentlyDisplaying then
		BindedMenuControllers[CurrentlyDisplaying](true)
	end
end)




return api