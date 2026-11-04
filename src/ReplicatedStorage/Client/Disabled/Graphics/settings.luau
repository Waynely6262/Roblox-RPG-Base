--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local settingsInfo = require(ReplicatedStorage.Modules.Data.settingsInfo)
local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)
local Slider = require(ReplicatedStorage.Client.Graphics.Util.Slider)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Tween = require(ReplicatedStorage.Modules.Utility.Tween)
local EasingFunctions = require(ReplicatedStorage.Modules.Utility.EasingFunctions)
----------------------------------------------------------------------------------------------------

local SettingsGui = ReplicatedStorage.Client.UserInterface.Settings
local Mainframe = SettingsGui.Main
local ScrollFrame = Mainframe.Holder.ScrollingFrame

local SliderTemplate = script.SliderFrame
local BooleanTemplate = script.BooleanFrame

local changeSignal: Signal.Signal<string, any> = Signal.new()

local SettingsWidget = Widget.new(SettingsGui, Mainframe)
Button.new(Mainframe.Close).Activated:Connect(function()
	SettingsWidget:Toggle(false)
end)

return {
	toggle = function(enabled: boolean?): boolean
		return SettingsWidget:Toggle(enabled)
	end,
	
	createBoolean = function(internalName: string, current: boolean)
		
		local boolFrame = BooleanTemplate:Clone()
		boolFrame.Name = internalName
		boolFrame.Parent = ScrollFrame
		boolFrame.SliderContainer.TextLabel.Text = settingsInfo[internalName].display

		local colorBar = boolFrame.SliderContainer.SliderBar
		boolFrame.LayoutOrder = settingsInfo[internalName].order

		
		local v = current
		colorBar.Slider.Activated:Connect(function()
			v = not v
			
			
			Tween(colorBar, {BackgroundColor3 = v and Color3.new(0.5,1, 0.5) or Color3.new(1,0.5,0.5)}, EasingFunctions.OutExpo, 0.5)
			Tween(colorBar.Slider, {Position = v and UDim2.fromScale(0.875,0.5) or UDim2.fromScale(0.125,0.5)}, EasingFunctions.OutExpo, 0.5)
			changeSignal:Fire(internalName, v)
			
		end)
		
		Tween(colorBar, {BackgroundColor3 = v and Color3.new(0.5,1, 0.5) or Color3.new(1,0.5,0.5)}, EasingFunctions.OutExpo, 0.5)
		Tween(colorBar.Slider, {Position = v and UDim2.fromScale(0.875,0.5) or UDim2.fromScale(0.125,0.5)}, EasingFunctions.OutExpo, 0.5)
		
		
	end,
	
	preferenceChanged = changeSignal,
	
	createSlider = function(internalName: string, current: number)
		
		local sliderFrame = SliderTemplate:Clone()
		sliderFrame.LayoutOrder = settingsInfo[internalName].order
		sliderFrame.Parent = ScrollFrame
		sliderFrame.SliderContainer.TextLabel.Text = settingsInfo[internalName].display
		
		local fillbar = sliderFrame.SliderContainer.SliderBar.FillBar
		
		local slider = Slider.new(sliderFrame.SliderContainer.SliderBar, current)
		slider.signal:Connect(function(v: number)
			fillbar.Size = UDim2.fromScale(v, 1)
			changeSignal:Fire(internalName, v)
		end)
		fillbar.Size = UDim2.fromScale(current,1)
		
		slider:connect()
	end,
}