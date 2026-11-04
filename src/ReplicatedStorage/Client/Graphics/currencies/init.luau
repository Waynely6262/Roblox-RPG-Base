--!strict

----------------------------------------------------------------------------------------------------
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local GraphicsUtilPath = ReplicatedStorage.Client.Graphics.Util
local UIAPI = require(GraphicsUtilPath.UIAPI)
local TransparencyAPI = require(GraphicsUtilPath.TransparencyAPI)

local TweenCallback = require(ReplicatedStorage.Modules.Utility.TweenCallback)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local EasingFunctions = require(ReplicatedStorage.Modules.Utility.EasingFunctions)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)
local Hoverable = require(ReplicatedStorage.Client.Graphics.Util.Hoverable)

local onscreenVfx = require(ReplicatedStorage.Client.Graphics.vfx)
local numberAbbreviator = require(ReplicatedStorage.Client.Graphics.Util.numberAbbreviator)
local addCommas = require(ReplicatedStorage.Client.Graphics.Util.comma)
----------------------------------------------------------------------------------------------------
local CurrenciesGui = UIAPI.getByName("PersistentGui")
local Container = CurrenciesGui.Currency

local Template = script.Template

local RegisteredCurrencies = {}:: {
	[string]: {
		T: TweenCallback.Class;
		Icon: ImageLabel;
	}
}

local Cashound = SoundService:WaitForChild("SoundEffects").Cash

local Camera: Camera = workspace.CurrentCamera:: Camera

local api = {}


function api.newCurrency(Name: string, icon: string)
	
	local New = Template:Clone()
	
	Hoverable.new(New)
	Button.new(New.More)
	
	New.NameText.Text = Name
	
	local AmtLabel = New.ValueText:: TextLabel
	local IconLabel = New.Icon:: ImageLabel
	IconLabel.Image = icon
	
	New.Parent = Container
	
	RegisteredCurrencies[Name] = {
		T = TweenCallback.new(0, 2, "OutExpo", function(a)
			AmtLabel.Text = addCommas(math.floor(a))
		end);
		Icon = IconLabel;
	}
	
	
end

local function validate(currency: string)
	if not RegisteredCurrencies[currency] then
		warn(`{currency} is not a registered currency`)
	end
	return RegisteredCurrencies[currency]
end

local updateAmount = function(currency: string, n: number)
	
	local V = validate(currency)
	if not V then return end
	V.T:play(n)
	
end

api.update = updateAmount;

local AnimationTInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
function api.animateUpdate(currency: string, n: number)
	
	
	local V = validate(currency)
	if not V then return end
	
	if n <= V.T.a then updateAmount(currency, n) return end
	
	local cl = V.Icon:Clone()
	cl.Size = UDim2.fromOffset(
		V.Icon.AbsolutePosition.X + V.Icon.AbsoluteSize.X,
		V.Icon.AbsolutePosition.Y + V.Icon.AbsoluteSize.Y
	)

	cl.Size = UDim2.fromOffset(
		V.Icon.AbsoluteSize.X,
		V.Icon.AbsoluteSize.Y
	)
	onscreenVfx.addChild(cl)
	
	local T = TweenService:Create(cl, AnimationTInfo, {
		Position = UDim2.fromOffset(V.Icon.AbsolutePosition.X, V.Icon.AbsolutePosition.Y)
	})
	
	T.Completed:Once(function()
		task.delay(1, updateAmount, currency, n)
		SoundService:PlayLocalSound(Cashound)
		onscreenVfx.bobbleFrame(V.Icon)
		cl:Destroy()
	end)
	
	T:Play()
end

return api
