--!strict
-- Lots of legacy code; this was heavily pre-MMORPG revamp logic
local this = {}
----------------------------------------------------------------------------------------------------

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")

local GraphicsUtilPath = ReplicatedStorage.Client.Graphics.Util
local UIAPI = require(GraphicsUtilPath.UIAPI)

local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)
local Signal = require(ReplicatedStorage.Modules.Utility.Signal)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)


local vfx = require(ReplicatedStorage.Client.Graphics.vfx)

local CardData = require(ReplicatedStorage.Modules.Data.Cards)
local CardUtil = require(ReplicatedStorage.Modules.Game.CardUtil)
local RarityColor = require(ReplicatedStorage.Modules.Game.RarityColor)
----------------------------------------------------------------------------------------------------

local HotGui = UIAPI.load("HotCards")
local HotMainframe = HotGui.Main

local Player = game:GetService("Players").LocalPlayer:: Player
local PlayerGui = Player.PlayerGui
local Mouse = Player:GetMouse()

local TInfo = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local HotAbilitiesContainer = HotMainframe.Abilities.Contents

local Selection: string?
local SelectedContainer: string?
local SelectedSlot: number?

local Inventory: {[string]: {Button.Button}} = {}

local NullTemplate = script.Empty
local Template = script.Template
local HotTemplate = script.HotTemplate

local HotbarCooldownFrames: {typeof(HotTemplate)} = {}
local began: Signal.Signal<number> = Signal.new()
local ended: Signal.Signal<number> = Signal.new()


local function buildFrame(cardSrc: string, isForHotbar: boolean?): typeof(NullTemplate:Clone()) | typeof(Template:Clone()) | typeof(HotTemplate:Clone())?
	local cardName, level = CardUtil.fromSource(cardSrc)
	if cardName then
		
		local info = CardData[cardName]
		
		local frame = (isForHotbar and HotTemplate or Template):Clone()
		frame.Background.BackgroundColor3 = RarityColor[info.rarity]
		frame.BackgroundColor3 = RarityColor[info.rarity]
		frame.TextLabel.Text = info.displayName
		frame.ViewportImage.Image = info.image or ""
		return frame
	elseif not isForHotbar then
		return NullTemplate:Clone()
	end
	-- only returns nil if isForHotbar = true
end

local function toContentHolder(container: Frame, key: string, cardName: string, isForHotbar: boolean?): Frame?
	local ContentHolder = container:FindFirstChild(key):: GuiObject

	--if not ContentHolder then
	--	warn(i,"doesn't exist")
	--	continue
	--end

	local existing = ContentHolder:FindFirstChildWhichIsA("GuiObject")

	if existing then
		if existing.Name == cardName then
			return nil
		else
			existing:Destroy()
		end
	end

	local frame = buildFrame(cardName, isForHotbar)
	ContentHolder.Visible = frame ~= nil
	if not frame then return nil end
	frame.Name = cardName
	frame.Parent = ContentHolder
	
	return frame
end

local defaultSortFunction = function(name1: string, name2: string)

	local rar1 = CardData[name1].rarity
	local rar2 = CardData[name2].rarity

	if rar1 ~= rar2 then
		return rar1 > rar2
	end

	return name1 > name2
end

local Touches = 0
local selectionTouchId: number?
local selection = nil:: number?
UserInputService.InputBegan:Connect(function(input)
	if selection then
		if input.UserInputType == Enum.UserInputType.Touch then
			Touches += 1
			--print("input began invoked; new touches count: ", Touches)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if selection then
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			ended:Fire(selection)
			selection = nil
		elseif input.UserInputType == Enum.UserInputType.Touch then
			Touches -= 1
				--print("Input ended Invoked, new touches count:", Touches)
			if Touches == selectionTouchId then
				ended:Fire(selection)
				selection = nil
			end
		end
	end
end)
local ResetHotbar = function(t: {string})
	for i = 1, 5 do
		local name = t[i]
		local hotframe = toContentHolder(HotAbilitiesContainer, tostring(i), name, true):: typeof(HotTemplate)
		
		if hotframe then
			
			HotbarCooldownFrames[i] = hotframe
			
			hotframe.Click.MouseButton1Down:Connect(function()
				if selection then return end
				began:Fire(i)
				selection = i
				--print("Click registered, touches count:", Touches)
				selectionTouchId = Touches
			end)
		end
	end
end

local Hotbar = function(i: number, name: string)
	local hotframe = toContentHolder(HotAbilitiesContainer, tostring(i), name, true):: typeof(HotTemplate)
	
	if hotframe then
		HotbarCooldownFrames[i] = hotframe
		
		hotframe.Click.MouseButton1Down:Connect(function()
			if selection then return end
			began:Fire(i)
			selection = i
			selectionTouchId = Touches
		end)
	end
end

local hot_widget = UIAPI.newGroupedFrame(HotMainframe, "Gameplay", HotGui)
hot_widget:Toggle(true)

this.reset = function(t: {string})
	ResetHotbar(t)
end

this.set = function(i: string | number, v: string)
	Hotbar(i, v)
end

local oldActiveAbilityUIScale: UIScale?
do
	this.setActiveAbility = function(n: number?)

		-- if given a number, finds the scale object for that slot number
		local scale: UIScale = n and
			(HotAbilitiesContainer :: any)[tostring(n)].Scale
		if oldActiveAbilityUIScale == scale then return end
		
		-- adjusts to 0.8 if a scale is found
		if scale then
			TweenService:Create(scale, TInfo, {
				Scale = 0.8
			}):Play()
		end
		
		-- resets the previous scale
		if oldActiveAbilityUIScale then
			TweenService:Create(oldActiveAbilityUIScale, TInfo, {
				Scale = 1
			}):Play()
		end
		
		-- updates old scale reference
		oldActiveAbilityUIScale = scale
	end
end
this.setCooldown = function(slot: number, duration: number)
	
	local TInfo = TweenInfo.new(duration)
		
	local F = HotbarCooldownFrames[slot]

	F.Enabled.Visible = true

	F.Cooldown.Size = UDim2.fromScale(1,1)
	local tw = TweenService:Create(F.Cooldown, TInfo, {
		Size = UDim2.fromScale(1,0)
	})
	
	tw.Completed:Once(function()
		F.Enabled.Visible = false
	end)
	
	tw:Play()


end
this.selectionBegan = began
this.selectionEnded = ended

return this