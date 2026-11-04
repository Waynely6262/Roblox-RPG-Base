-- by Waynely - coocoocrazyhead (Dec 2024)

--[[ Usage


The first passed argument is the frame the holds the extents of the slider.

The second argument is and optional argument meant to set the beginning position of the slider.

The third argument is an optional argument that makes use of the value that the slider holds. The thread calls update_function 
with the first argument as the current percentage in decimal notation.

Structure in relativity to SliderExtents (first argument):

	SliderExtents: GuiBase2d
		Slider: GuiButton
	


]]

local static = {}
local Slider = {}
Slider.__index = Slider
local uis = game:GetService("UserInputService")

local Signal = require(game.ReplicatedStorage.Modules.Utility.Signal)

function static.new(SliderExtents: GuiBase2d, current_position)
	
	local self = {
		extents = SliderExtents;
		slider = SliderExtents:FindFirstChild("Slider");
		signal = Signal.new();
		alpha = current_position or 1;
		connections = {};
	}
	return setmetatable(self, Slider)
end

function Slider:disconnect()
	for _,v in self.connections do
		v:Disconnect()
	end
	self.connections = {}
end

function Slider:connect()
	
	self.slider.Position = UDim2.fromScale(self.alpha,self.slider.Position.Y.Scale) -- initial position set

	local function update()

		if self.dragging then

			local MousePos = uis:GetMouseLocation()+Vector2.new(0,-36)
			local RelPos = MousePos-self.extents.AbsolutePosition
			local Percent = math.clamp(RelPos.X/self.extents.AbsoluteSize.X,0,1)

			self.slider.Position = UDim2.fromScale(Percent,self.slider.Position.Y.Scale)
			
			self.alpha = Percent
			self.signal:Fire(Percent)

		end
	end
	
	local function activate()
		self.dragging = true
		update()
	end
	
	self:disconnect()
	
	self.connections = {
		uis.InputBegan:Connect(update);
		
		uis.InputChanged:Connect(update);
		
		self.slider.MouseButton1Down:Connect(activate);
		
		uis.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				self.dragging = false
			end
		end);
	}


	if self.extents:IsA("GuiButton") then
		table.insert(self.connections, self.extents.MouseButton1Down:Connect(activate))
	end
	
end

return static