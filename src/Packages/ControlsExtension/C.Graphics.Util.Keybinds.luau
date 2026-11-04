--!strict
local UserInputService = game:GetService("UserInputService")

local Hoverable = require(game.ReplicatedStorage.Client.Graphics.Util.Hoverable)

local UIAPI = require(game.ReplicatedStorage.Client.Graphics.Util.UIAPI)

local Mainframe = (UIAPI.getByName("PersistentGui"):: any).Keybinds

local Template = script:FindFirstChild("Template"):: {Bind: {ImageLabel: ImageLabel; TextLabel: TextLabel} & GuiObject} & GuiObject

local KeyCodeToTextMap = {
	[Enum.KeyCode.LeftControl] = "LCtrl",
	[Enum.KeyCode.RightControl] = "RCtrl",
	[Enum.KeyCode.LeftAlt] = "LAlt",
	[Enum.KeyCode.RightAlt] = "RAlt",
	[Enum.KeyCode.F1] = "F1",
	[Enum.KeyCode.F2] = "F2",
	[Enum.KeyCode.F3] = "F3",
	[Enum.KeyCode.F4] = "F4",
	[Enum.KeyCode.F5] = "F5",
	[Enum.KeyCode.F6] = "F6",
	[Enum.KeyCode.F7] = "F7",
	[Enum.KeyCode.F8] = "F8",
	[Enum.KeyCode.F9] = "F9",
	[Enum.KeyCode.F10] = "F10",
	[Enum.KeyCode.F11] = "F11",
	[Enum.KeyCode.F12] = "F12",
}

local GamepadButtonImage = {
	[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
	[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
	[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
	[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRS.png",
}

local KeyboardButtonImage = {
	[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
	[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
	[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png",
	[Enum.KeyCode.Quote] = "rbxasset://textures/ui/Controls/apostrophe.png",
	[Enum.KeyCode.Comma] = "rbxasset://textures/ui/Controls/comma.png",
	[Enum.KeyCode.Backquote] = "rbxasset://textures/ui/Controls/graveaccent.png",
	[Enum.KeyCode.Period] = "rbxasset://textures/ui/Controls/period.png",
	[Enum.KeyCode.Space] = "rbxasset://textures/ui/Controls/spacebar.png",
}

local TouchTap = "rbxasset://textures/ui/Controls/TouchTapIcon.png"


local Active = {}:: {[any]: typeof(Template)}

UserInputService.InputBegan:Connect(function(input)
	if Active[input.KeyCode] then
		Active[input.KeyCode].Bind.BackgroundColor3 = Color3.fromRGB(173, 173, 173)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if Active[input.KeyCode] then
		Active[input.KeyCode].Bind.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	end
end)

Template.Bind.BackgroundColor3 = Color3.fromRGB(200,200,200)

return {

	set = function(keyCode: Enum.KeyCode?, inputType: Enum.UserInputType?, actionText: string)
		local new = Active[actionText]
		if not new then
			new = Template:Clone()
		end

		if inputType == Enum.UserInputType.Gamepad1 then
			assert(keyCode, `Specify a KeyCode for Gamepad1`)
			if not UserInputService.GamepadEnabled then return end 
			if GamepadButtonImage[keyCode] then
				new.Bind.TextLabel.Visible = false
				new.Bind.ImageLabel.Visible = true
				new.Bind.ImageLabel.Image = GamepadButtonImage[keyCode]
			else
				new.Bind.ImageLabel.Visible = false
				new.Bind.TextLabel.Visible = true
				new.Bind.TextLabel.Text = keyCode.Name
			end
		elseif inputType == Enum.UserInputType.Touch or inputType == Enum.UserInputType.MouseButton1 then
			new.Bind.TextLabel.Visible = false
			new.Bind.ImageLabel.Visible = true
			new.Bind.ImageLabel.Image = TouchTap
		else
			assert(keyCode, `Specify a KeyCode; no special case for {inputType}`)
			if not UserInputService.KeyboardEnabled then return end

			--buttonImage.Image = "rbxasset://textures/ui/Controls/key_single.png"


			local buttonTextImage = KeyboardButtonImage[keyCode]
			if buttonTextImage then
				new.Bind.TextLabel.Visible = false
				new.Bind.ImageLabel.Visible = true
				new.Bind.ImageLabel.Image = buttonTextImage
			else
				local keyCodeMappedText = KeyCodeToTextMap[keyCode] or keyCode.Name
				new.Bind.ImageLabel.Visible = false
				new.Bind.TextLabel.Visible = true
				new.Bind.TextLabel.Text = keyCodeMappedText
			end
		end

		new.Visible = true
		new.Action.TextLabel.Text = actionText
		new.Parent = Mainframe
		new.Name = actionText
		
		Active[actionText] = new
	end,

	remove = function(str: string | Enum.KeyCode)
		if Active[str] then
			Active[str]:Destroy()
			Active[str] = nil
		end
	end,

	hide = function(str: string | Enum.KeyCode)
		if Active[str] then
			Active[str].Visible = false
		end
	end,
}
