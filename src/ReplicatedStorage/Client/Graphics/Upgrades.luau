local UIAPI = require(game.ReplicatedStorage.Client.Graphics.Util.UIAPI)
local Button = require(game.ReplicatedStorage.Client.Graphics.Util.Button)
local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

local Gui = UIAPI.getByName("Upgrades"):: typeof(game.ReplicatedStorage.Client.UserInterface.Upgrades)

local Mainframe = Gui.Mainframe

local widget = UIAPI.newGroupedFrame(Mainframe, "Menus", Gui)

local ContentHolder = Gui.Mainframe.Holder.Contents
local LayoutObject = ContentHolder.UIGridLayout
local Template = script.Template

local Frames = {}:: {[string]: typeof(Template)}

local requestSignal = Signal.new()

local get = function(name)
	
	return Frames[name]
end

local update = function(name, level, req)
	local Frame = Frames[name]
	
	if req == 0 then
		if Frame then
			Frame:Destroy()
			Frames[name] = nil
		end
		
		return
	end
	
	if not Frame then
		Frame = Template:Clone()
		Frame.Parent = ContentHolder
		
		Button.new(Frame.ClaimButton).Activated:Connect(function()
			requestSignal:Fire(name)
		end)
		Frames[name] = Frame
	end
	
	Frame.NameLabel.Text = `{name} - {level + 1}`
	Frame.CostLabel.Text = `{req} Essence`
	
end

Button.new(Mainframe.Close).Activated:Connect(function()
	UIAPI.disableFrame(Mainframe)
end)

game.UserInputService.InputBegan:Connect(function(k, g)
	if k.KeyCode == Enum.KeyCode.U then
		UIAPI.enableFrame(Mainframe)
	end
end)

return {
	update = update;
	requested = requestSignal;
	setCount = function(n: number)
		
		local DistributablePixels = ContentHolder.AbsoluteCanvasSize.Y - n * (LayoutObject.CellPadding.Y.Offset - LayoutObject.CellPadding.Y.Scale * ContentHolder.AbsoluteCanvasSize.Y)
		
		local PixelsPerFrame = DistributablePixels / n
		
		LayoutObject.CellSize = UDim2.fromScale(1, PixelsPerFrame / DistributablePixels) - LayoutObject.CellPadding
	end,
}