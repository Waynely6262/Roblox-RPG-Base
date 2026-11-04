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

local InventoryGraphics = require(ReplicatedStorage.Client.Graphics.inventory)
local InvMenuAPI = require(ReplicatedStorage.Client.Graphics.InventoryMenus)
local CraftConfig = require(ReplicatedStorage.Modules.PackageConfig.Crafting)
local FollowMouse = require(ReplicatedStorage.Client.Graphics.Util.FollowMouse)

local Catalog = require(ReplicatedStorage.Modules.Inventory.Item.Catalog)
----------------------------------------------------------------------------------------------------

local screenGui = UIAPI.getByName("Inventory"):: typeof(ReplicatedStorage.Client.UserInterface.Inventory)

local requestUpdate = Signal.new()
local CraftRequest = Signal.new():: Signal.Signal<string, number>

local api = {}
api.RequestUpdate = requestUpdate
api.CraftRequested = CraftRequest

-- name must match the frame found in InvMenusFrame

local mainframe: GuiObject; mainframe = InvMenuAPI.bindMenuHandler("Crafting", function(isEnabled: boolean)
	-- backend should bind to this signal
	if isEnabled then
		requestUpdate:Fire()
	end

end):: GuiObject

local ActiveFrames: {[string]: ItemFrameAPI.ItemFrame} = {}
local ActiveButtons: {[string]: Button.Button} = {}

local RecipeFrame = script.HoverFrame

local function DisplayRecipe(recipe: {[string]: number}?)
	if recipe then
		FollowMouse.begin(RecipeFrame)
		RecipeFrame.Visible = true
		local text = ""

		for v, n in recipe do
			text ..= `{v} x{n}\n`
		end

		--TODO:FINISH_IMPLEMENTATION
		RecipeFrame.Text = text
	else
		FollowMouse.stop(RecipeFrame)
		RecipeFrame.Visible = false
	end
end

function api.setRecipe(name: string, canCraft: boolean)

	local frame = ActiveFrames[name]

	if not frame then
		frame = ItemFrameAPI.new(mainframe, 1, name)
		ActiveFrames[name] = frame
		frame:bareSet(name, 1)
	end

	frame:SetHighlight(not canCraft, Color3.new(0,0,0))

	if not ActiveButtons[name] then
		local New = Button.new(frame.Frame)
		ActiveButtons[name] = New
		New.Activated:Connect(function()
			CraftRequest:Fire(name, 1)
		end)

		New.HoverBegan:Connect(function()
			DisplayRecipe(CraftConfig[name])
		end)

		New.HoverEnded:Connect(function()
			DisplayRecipe()
		end)
	end

end

function api.removeRecipe(name: string)

	if ActiveFrames[name] then
		ActiveFrames[name]:Destroy()
		ActiveFrames[name] = nil
	end
end

return api