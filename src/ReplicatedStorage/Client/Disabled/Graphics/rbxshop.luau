--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage

local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
----------------------------------------------------------------------------------------------------
local ShopGui = ReplicatedStorage.Client.UserInterface.Widgets.Main.Shop

local ShopWidget = Widget.new(nil, ShopGui)

local PurchaseSignal: Signal.Signal<string> = Signal.new() --> <productName>
return {
	PromptPurchase = PurchaseSignal,
	toggle = function(enabled: boolean?): boolean
		return ShopWidget:Toggle(enabled)
	end,
}