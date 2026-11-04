--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local TransparencyAPI = require(ReplicatedStorage.Client.Graphics.Util.TransparencyAPI)
local TweenCallback = require(ReplicatedStorage.Modules.Utility.TweenCallback)
local Lerp = require(ReplicatedStorage.Modules.Utility.Lerp)

local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
----------------------------------------------------------------------------------------------------
export type Widget = {
	Toggle: (self: Widget, enabled: boolean?) -> (boolean),

	Closed: Signal.Signal<>,
	Opened: Signal.Signal<>,

	_ToggleState: boolean,
	_ScreenGui: ScreenGui?,
	_Widget: GuiObject,
	_Tweener: TweenCallback.Class,
}

local Easer = "OutExpo"

local DISPLAY_ORDER_ENABLED = 1
local DISPLAY_ORDER_DISABLING = 0


local Widget = {}
Widget.__index = Widget
function Widget.Toggle(self: Widget, newState: boolean?): boolean
	local enabled: boolean

	if newState == nil then
		enabled = not self._ToggleState
	else
		enabled = newState
	end

	if enabled == self._ToggleState then return enabled end

	self._ToggleState = enabled

	if enabled then

		if self._ScreenGui then
			self._ScreenGui.DisplayOrder = DISPLAY_ORDER_ENABLED
			self._ScreenGui.Enabled = true
		else
			self._Widget.Visible = true
		end

		self._Tweener:play(0)
		self.Opened:Fire()
	else -- DISABLED



		if self._ScreenGui then
			self._ScreenGui.DisplayOrder = DISPLAY_ORDER_DISABLING;
			print("Playing tweener")
			self._Tweener:play(1, function()
				self._ScreenGui.Enabled = false
			end)
		else
			print("Playing tweener")
			self._Tweener:play(1, function()
				self._Widget.Visible = false
			end)

		end
		self.Closed:Fire()

	end

	return enabled
end

return {
	new = function(ScreenGui: ScreenGui?, Adornee: typeof(script.WidgetFormat), EnabledProperties: {[string]: any}, DisabledProperties: {[string]: any})
		EnabledProperties = EnabledProperties or {}
		DisabledProperties = DisabledProperties or {}

		for i, v in EnabledProperties do
			assert(typeof(DisabledProperties[i]) == typeof(v), "Enabled and Disabled properties must have the same types for property: " .. i)
		end
		TransparencyAPI.initialize(Adornee, true)

		local self = setmetatable({
			Opened = Signal.new(),
			Closed = Signal.new(),

			_Widget = Adornee,
			_ToggleState = false,
			_Tweener = TweenCallback.new(1, 0.5, Easer, function(a: number)
				
				for i, v in EnabledProperties do
					Adornee[i] = Lerp(v, DisabledProperties[i], a)
				end
				TransparencyAPI.modify(Adornee, a)
			end),
			_ScreenGui = ScreenGui,

			TweenTransparency = true,
			EnabledProperties = EnabledProperties,
			DisabledProperties = DisabledProperties,
		}, Widget):: Widget


		return self
	end,
}