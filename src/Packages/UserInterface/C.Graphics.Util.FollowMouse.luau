--!strict
local UserInputService = game:GetService("UserInputService")
local UIAPI = require(game.ReplicatedStorage.Client.Graphics.Util.UIAPI)

local Api = {}

local active: boolean = false
local frames: {[GuiObject]: true} = {}
local connection: RBXScriptConnection? = nil

-- Example position update logic (replace with your own)
local function computePosition(frame: GuiObject, input: InputObject): UDim2
	local mousePos = UserInputService:GetMouseLocation()
	return UDim2.fromOffset(mousePos.X - frame.AbsoluteSize.X / 2, mousePos.Y - frame.AbsoluteSize.Y / 2)
end

local function startLoop()
	if active then
		return
	end

	active = true

	connection = UserInputService.InputChanged:Connect(function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		for frame in frames do
			if frame.Parent == nil then
				frames[frame] = nil
			else
				frame.Position = computePosition(frame, input)
			end
		end

		if not next(frames) then
			Api.stopAll()
		end
	end)
end

function Api.begin(frame: GuiObject)
	if frames[frame] then
		return
	end

	frames[frame] = true
	startLoop()
end

function Api.stop(frame: GuiObject)
	frames[frame] = nil

	if not next(frames) then
		Api.stopAll()
	end
end

function Api.stopAll()
	active = false

	frames = {}
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

return Api
