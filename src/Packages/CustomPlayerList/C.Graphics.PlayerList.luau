--!strict
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)


local ReplicatedStorage = game.ReplicatedStorage
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local UIVfx = require(ReplicatedStorage.Client.Graphics.vfx)
local abbrevNum = require(ReplicatedStorage.Client.Graphics.Util.numberAbbreviator)
local Widget = require(ReplicatedStorage.Client.Graphics.Util.Widget)
local Button = require(ReplicatedStorage.Client.Graphics.Util.Button)
local TopBarPlusIcon = require(ReplicatedStorage.Client.Graphics.Util.TopBarPlusIcon)

local Mainframe = ReplicatedStorage.Client.UserInterface.PersistentGui.Leaderboard
local ScrollingFrame = Mainframe.Content.Scrollframe
local ListLayout = ScrollingFrame.UIListLayout

local DisabledProperties: {[string]: any} do
	DisabledProperties = {}
	
	DisabledProperties.Position = Mainframe.Position + UDim2.new(Mainframe.Size.X, UDim.new())
end

local playerlist = Widget.new(nil, Mainframe, nil, DisabledProperties)

playerlist:Toggle(true)


local container  = script.Parent

ContextActionService:BindAction("TogglePlayerList", function(_, state)
	if Enum.UserInputState.Begin == state then
		playerlist:Toggle()
	end
end, false, Enum.KeyCode.Tab)


local Icon = TopBarPlusIcon.new()

Icon:setLabel("Leaderboard")

Icon.toggled:Connect(function(b)
	playerlist:Toggle(b)
end)

local Template = script.Template


local function inspectPlayerCharacter(player: Player)
	GuiService:InspectPlayerFromUserId(player.CharacterAppearanceId)
end

local ListItem: {[Player]: typeof(Template:Clone()) | GuiObject} = {}
local Values: {[Player]: number} = {}

local function try_table_remove(t: {any}, v: any): number
	local i = table.find(t,v)
	if i then
		table.remove(t, i)
		return i
	end
	return -1
end

ScrollingFrame.Changed:Connect(function()
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, ListLayout.AbsoluteContentSize.Y)
	ScrollingFrame.CanvasPosition = Vector2.min(ListLayout.AbsoluteContentSize, ScrollingFrame.CanvasPosition)
end)


local function sortFunction(a: Player,b: Player): boolean
	return (Values[a] or 0) > (Values[b] or 0)
end

local function refresh()--🤓--
	
	local order = {}
	
	for player, value in Values do
		
		local i = 1
		
		while true do
			local nextGuy: Player = order[i]
			
			if nextGuy then
				i += 1
				if Values[nextGuy] > value then
					break
				end
			else
				break
			end
		end
		table.insert(order, i, player) 
	end
	
	for index, Player in order do
		ListItem[Player].LayoutOrder = index
		ListItem[Player].Content.Stat.TextLabel.Text = abbrevNum(Values[Player])
	end
	
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, ListLayout.AbsoluteContentSize.Y)
end

local function assertGui(player: Player)

	if not ListItem[player] then
		local new = Template:Clone()
		new.Name = "p_" .. player.UserId
		new.Parent = ScrollingFrame
		local txtLbl = new.Content.Title.TextLabel
		local txtHover = player.Name
		local txtEq = player.DisplayName
		local button = Button.new(new)

		new.Content.Stat.TextLabel:GetPropertyChangedSignal("Text"):Connect(function()
			UIVfx.bobbleFrame(new.Content.Stat)
		end)
		button.HoverBegan:Connect(function()
			txtLbl.Text = txtHover
		end)

		button.HoverEnded:Connect(function()
			txtLbl.Text = txtEq
		end)
		
		txtLbl.Text = txtEq

		button.Activated:Connect(function()
			GuiService:SetInspectMenuEnabled(true)
			inspectPlayerCharacter(player)
		end)
		ListItem[player] = new
		refresh()
	end

end

local function cleanup(player: Player)
	if ListItem[player] then
		ListItem[player]:Destroy()
	end
	Values[player] = nil
	refresh()
end

--for i = 1, 7 do -- fake players for lb test

--	local plr = {
--		DisplayName = "Player" .. i;
--	}

--	table.insert(PlayersListed, plr)
--	Values[plr] = ((i+500)^2) * math.random()
--end

return {
	setPlayerValue = function(player: Player, v: number)
		
		if v >= 0 then
			assertGui(player)
			Values[player] = v
			refresh()
		else
			cleanup(player)
		end
	end,
	
	--showCosmeticStats = function(player: Player, ...: ValueBase)
		
	--	local vbs = {...}
		
	--	for i, vb in vbs do
	--		if not cosmeticStatExists(vb.Name) then
	--			addCosmeticStat(i, vb.Name)
	--		end
	--	end
		
	--end,
}