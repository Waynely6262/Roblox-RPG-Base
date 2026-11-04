--!strict

-- written by grok
-- supervised by Waynely

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer:: Player
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

if LocalPlayer:GetRankInGroupAsync(33738605) < 3 then
	return {}
end

-- Assume the RemoteFunction is in ReplicatedStorage named "AdminRemote"
-- Adjust if the actual name differs based on your setup
local Remote = ReplicatedStorage.Remotes.MainE

local function fireServer(...)
	Remote:FireServer("Developer", ...)
end

local function parseVector3(str: string): Vector3
	local parts = {}
	for part in str:gmatch("[^,%s]+") do
		table.insert(parts, tonumber(part))
	end
	if #parts == 3 then
		return Vector3.new(parts[1], parts[2], parts[3])
	end
	return Vector3.zero
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminCommandsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("ScrollingFrame")
MainFrame.AnchorPoint = Vector2.one
MainFrame.Size = UDim2.new(0.2, 0, 1, 0)
MainFrame.Position = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 0.8
MainFrame.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = MainFrame

-- Section: Print Current Floor
local PrintSection = Instance.new("Frame")
PrintSection.Size = UDim2.new(1, 0, 0, 50)
PrintSection.BackgroundTransparency = 1
PrintSection.Parent = MainFrame
PrintSection.LayoutOrder = 1

local PrintButton = Instance.new("TextButton")
PrintButton.Size = UDim2.new(1, 0, .5, 0)
PrintButton.Text = "Print Current Floor"
PrintButton.Parent = PrintSection

PrintButton.Activated:Connect(function()
	fireServer("printCurrentFloor")
end)


local MapOutButton = Instance.new("TextButton")
MapOutButton.Size = UDim2.new(1, 0, .5, 0)
MapOutButton.Position = UDim2.new(0, 0, .5, 0)
MapOutButton.Text = "Create Map"
MapOutButton.Parent = PrintSection

MapOutButton.Activated:Connect(function()
	fireServer("map")
end)

-- Section: Set Cell
local SetCellSection = Instance.new("Frame")
SetCellSection.Size = UDim2.new(1, 0, 0, 150)
SetCellSection.BackgroundTransparency = 1
SetCellSection.Parent = MainFrame
SetCellSection.LayoutOrder = 2

local SetCellLabel = Instance.new("TextLabel")
SetCellLabel.Size = UDim2.new(1, 0, 0, 30)
SetCellLabel.Text = "Set Cell"
SetCellLabel.Parent = SetCellSection


local ContentTextBox = Instance.new("TextBox")
ContentTextBox.Size = UDim2.new(1, 0, 0, 40)
ContentTextBox.Position = UDim2.new(0, 0, 0, 70)
ContentTextBox.PlaceholderText = "Type of Content"
ContentTextBox.Text = ""
ContentTextBox.Parent = SetCellSection

local SetCellButton = Instance.new("TextButton")
SetCellButton.Size = UDim2.new(1, 0, 0, 40)
SetCellButton.Position = UDim2.new(0, 0, 0, 110)
SetCellButton.Text = "Set Cell"
SetCellButton.Parent = SetCellSection

-- Section: New Spawner
local NewSpawnerSection = Instance.new("Frame")
NewSpawnerSection.Size = UDim2.new(1, 0, 0, 300)
NewSpawnerSection.BackgroundTransparency = 1
NewSpawnerSection.Parent = MainFrame
NewSpawnerSection.LayoutOrder = 3

local NewSpawnerLabel = Instance.new("TextLabel")
NewSpawnerLabel.Size = UDim2.new(1, 0, 0, 30)
NewSpawnerLabel.Text = "New Spawner"
NewSpawnerLabel.Parent = NewSpawnerSection

local Pos0Frame = Instance.new("Frame")
Pos0Frame.Size = UDim2.new(1, 0, 0, 40)
Pos0Frame.Position = UDim2.new(0, 0, 0, 30)
Pos0Frame.BackgroundTransparency = 1
Pos0Frame.Parent = NewSpawnerSection

local Pos0TextBox = Instance.new("TextBox")
Pos0TextBox.Size = UDim2.new(0.7, 0, 1, 0)
Pos0TextBox.PlaceholderText = "Position 0 (X, Y, Z)"
Pos0TextBox.Text = ""
Pos0TextBox.Parent = Pos0Frame

local PickPos0Button = Instance.new("TextButton")
PickPos0Button.Size = UDim2.new(0.3, 0, 1, 0)
PickPos0Button.Position = UDim2.new(0.7, 0, 0, 0)
PickPos0Button.Text = "Pick"
PickPos0Button.Parent = Pos0Frame

local connPos0: RBXScriptConnection?
PickPos0Button.Activated:Connect(function()
	if connPos0 then connPos0:Disconnect() end
	connPos0 = Mouse.Button1Down:Connect(function()
		local hitPos = Mouse.Hit.Position
		Pos0TextBox.Text = hitPos.X .. ", " .. hitPos.Y .. ", " .. hitPos.Z;
		(connPos0:: RBXScriptConnection):Disconnect()
		connPos0 = nil
	end)
end)

local Pos1Frame = Instance.new("Frame")
Pos1Frame.Size = UDim2.new(1, 0, 0, 40)
Pos1Frame.Position = UDim2.new(0, 0, 0, 70)
Pos1Frame.BackgroundTransparency = 1
Pos1Frame.Parent = NewSpawnerSection

local Pos1TextBox = Instance.new("TextBox")
Pos1TextBox.Size = UDim2.new(0.7, 0, 1, 0)
Pos1TextBox.PlaceholderText = "Position 1 (X, Y, Z)"
Pos1TextBox.Text = ""
Pos1TextBox.Parent = Pos1Frame

local PickPos1Button = Instance.new("TextButton")
PickPos1Button.Size = UDim2.new(0.3, 0, 1, 0)
PickPos1Button.Position = UDim2.new(0.7, 0, 0, 0)
PickPos1Button.Text = "Pick"
PickPos1Button.Parent = Pos1Frame

local connPos1: RBXScriptConnection?
PickPos1Button.Activated:Connect(function()
	if connPos1 then connPos1:Disconnect() end
	connPos1 = Mouse.Button1Down:Connect(function()
		local hitPos = Mouse.Hit.Position
		Pos1TextBox.Text = hitPos.X .. ", " .. hitPos.Y .. ", " .. hitPos.Z;
		(connPos1:: RBXScriptConnection):Disconnect()
		connPos1 = nil
	end)
end)



local SpawnerTypeTextBox = Instance.new("TextBox")
SpawnerTypeTextBox.Size = UDim2.new(1, 0, 0, 40)
SpawnerTypeTextBox.Position = UDim2.new(0, 0, 0, 110)
SpawnerTypeTextBox.PlaceholderText = "Spawner Type"
SpawnerTypeTextBox.Text = ""
SpawnerTypeTextBox.Parent = NewSpawnerSection

local MaxTextBox = Instance.new("TextBox")
MaxTextBox.Size = UDim2.new(1, 0, 0, 40)
MaxTextBox.Position = UDim2.new(0, 0, 0, 150)
MaxTextBox.PlaceholderText = "Max (number)"
MaxTextBox.Text = ""
MaxTextBox.Parent = NewSpawnerSection

local NewSpawnerButton = Instance.new("TextButton")
NewSpawnerButton.Size = UDim2.new(1, 0, 0, 40)
NewSpawnerButton.Position = UDim2.new(0, 0, 0, 190)
NewSpawnerButton.Text = "Create Spawner"
NewSpawnerButton.Parent = NewSpawnerSection

NewSpawnerButton.Activated:Connect(function()
	local v0 = parseVector3(Pos0TextBox.Text)
	local v1 = parseVector3(Pos1TextBox.Text)
	local spawnerType = SpawnerTypeTextBox.Text
	local max = tonumber(MaxTextBox.Text)
	if v0 and v1 and spawnerType ~= "" and max then
		fireServer("newSpawner", v0, v1, spawnerType, max)
	else
		warn("Invalid input for newSpawner")
	end
end)

SetCellButton.Activated:Connect(function()
	local v1 = parseVector3(Pos0TextBox.Text)
	local v2 = parseVector3(Pos1TextBox.Text)
	local content = ContentTextBox.Text
	if v1 and v2 and content ~= "" then
		fireServer("setCell", v1, v2, content)
	else
		warn("Invalid input for setCell")
	end
end)


-- Adjust scrolling canvas size
MainFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)

ScreenGui.Enabled = false

local walkspeedsetter: RBXScriptConnection?

game.UserInputService.InputBegan:Connect(function(input, gpe)
	
	if input.KeyCode == Enum.KeyCode.F3 then
		
		if LocalPlayer.Character then
			LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 100
		end	
		walkspeedsetter = walkspeedsetter or LocalPlayer.CharacterAdded:Connect(function(char)
			char:WaitForChild("Humanoid").WalkSpeed = 100
		end)
		LocalPlayer.CameraMaxZoomDistance = math.huge
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)
return {}