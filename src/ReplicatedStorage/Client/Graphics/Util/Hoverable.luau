--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

----------------------------------------------------------------------------------------------------

type Adornee = {Scale: UIScale} & GuiObject

SoundService:WaitForChild("SoundEffects")
local HoverSound = SoundService.SoundEffects.Hover

export type Hoverable = typeof(setmetatable({}:: {
	HoverBegan: RBXScriptSignal,
	HoverEnded: RBXScriptSignal,
	
	_Adornee: Adornee,
	_connections: {RBXScriptConnection},
}, Hoverable))

local Random = Random.new()

local Hoverable = {}
Hoverable.__index = Hoverable

local SCALE_INFO = TweenInfo.new(0.13, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function Hoverable.animateSize(self: Hoverable, targetScale: number)
	TweenService:Create(
		self._Adornee.Scale, 
		SCALE_INFO,
		{Scale = targetScale}
	):Play()
end

function Hoverable.Destroy(self: Hoverable)

	for _, v in self._connections do
		v:Disconnect()
	end
	table.clear(self._connections)

end


return {
	new = function(Adornee: Adornee)
		local self = (setmetatable({
			
			_Adornee = Adornee;
			
		}, Hoverable)):: Hoverable
		
		
		local UIScale = Adornee:FindFirstChild("Scale"):: UIScale
		if not UIScale then
			UIScale = Instance.new("UIScale")
			UIScale.Scale = 1
			UIScale.Name = "Scale"
			UIScale.Parent = Adornee
		end

		self.HoverBegan = Adornee.MouseEnter
		self.HoverEnded = Adornee.MouseLeave
		
		self._connections = {
			self.HoverBegan:Connect(function()
				HoverSound.PlaybackSpeed = Random:NextNumber(0.85, 1.15)
				SoundService:PlayLocalSound(HoverSound)
				self:animateSize(1.1)
			end);
		
			self.HoverEnded:Connect(function()
				self:animateSize(1)
			end);
		}
		
		return self
	end,
	
	class = Hoverable,
}