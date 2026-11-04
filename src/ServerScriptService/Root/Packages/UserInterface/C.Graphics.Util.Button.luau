--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local super = require(script.Parent.Hoverable) -- Inherits
----------------------------------------------------------------------------------------------------

SoundService:WaitForChild("SoundEffects")
local HoverSound = SoundService.SoundEffects.Hover
local ClickSound = SoundService.SoundEffects.Click

type Adornee = {Scale: UIScale, Click: GuiButton} & GuiObject


local Random = Random.new()

local Button = setmetatable({}, super.class)
Button.__index = Button

export type Button = typeof(setmetatable({}:: (super.Hoverable & {
	Pressed: RBXScriptSignal,
	Released: RBXScriptSignal,
	Activated: RBXScriptSignal,
}), Button))

local SCALE_INFO = TweenInfo.new(0.13, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function Button.animateRotation(self: Button, targetRotation: number)
	TweenService:Create(
		self._Adornee.Click, 
		SCALE_INFO,
		{Rotation = targetRotation}
	):Play()
end
return {
	new = function(Adornee: GuiObject)


		local self = (setmetatable(super.new(Adornee), Button)):: Button

		local UIScale = Adornee:FindFirstChild("Scale"):: UIScale
		if not UIScale then
			UIScale = Instance.new("UIScale")
			UIScale.Scale = 1
			UIScale.Name = "Scale"
			UIScale.Parent = Adornee
		end

		local Button = Adornee:IsA("GuiButton") and Adornee or Adornee:FindFirstChild("Click")
		assert(Button, `No "Click" element found for the button  {Adornee.Name}`)

		Button.MouseEnter:Connect(function()
			self:animateRotation(math.random(0, 1) == 0 and -10 or 10)
		end)
		Button.MouseLeave:Connect(function()
			self:animateRotation(0)
		end)
		Button.MouseButton1Down:Connect(function()
			ClickSound.PlaybackSpeed = Random:NextNumber(1, 1.2)
			SoundService:PlayLocalSound(ClickSound)
			self:animateRotation(0)
			self:animateSize(0.9)
		end)
		Button.MouseButton1Up:Connect(function()
			ClickSound.PlaybackSpeed = Random:NextNumber(0.2, 1)
			SoundService:PlayLocalSound(ClickSound)
			self:animateSize(1.1)
			self:animateRotation(math.random(0, 1) == 0 and -10 or 10)
		end)

		self.Activated = Button.Activated
		self.HoverBegan = Button.MouseEnter
		self.HoverEnded = Button.MouseLeave
		self.Pressed = Button.MouseButton1Down
		self.Released = Button.MouseButton1Up

		return self
	end,

	enabledSequence = ColorSequence.new({

		ColorSequenceKeypoint.new(0, Color3.fromRGB(197,255,125)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(74, 221, 30)),
	});

	disabledSequence = ColorSequence.new({

		ColorSequenceKeypoint.new(0, Color3.fromHex("FF6343")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("C9203F")),


	});
}