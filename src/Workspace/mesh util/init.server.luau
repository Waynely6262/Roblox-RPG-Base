--!strict
local pluginName = "Waynely's Mesh Engine: Utility Plugin"
local pluginGroup = "Mesh VFX"

local toolbar = plugin:CreateToolbar(pluginGroup)
local button = toolbar:CreateButton(pluginName, "Does qol stuff for coocoocrazyhead's Mesh Engine", "")

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local SelectionService = game:GetService("Selection")
local StudioService = game:GetService("StudioService")
local UserInputService = game:GetService("UserInputService")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,
	false, -- initially enabled
	false, -- override previous enable
	100, -- min width
	5, -- min height
	150, -- default width
	30 -- default height
)

local widget = plugin:CreateDockWidgetPluginGui(pluginName, widgetInfo)
widget.Title = pluginName
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Theme support
local StudioTheme = settings().Studio.Theme
local function getColor(key)
	return StudioTheme:GetColor(key)
end

local function getIcon(className)
	return StudioService:GetClassIcon(className).Image
end

-- Create the UI
local container = Instance.new("Frame")
container.BackgroundColor3 = getColor(Enum.StudioStyleGuideColor.MainBackground)
container.BorderSizePixel = 0
container.Size = UDim2.new(1, 0, 1, 0)
container.Parent = widget

local uilistlayout = Instance.new("UIListLayout")
uilistlayout.Parent = container


-- px size 20
local generalPurposeTemplate do
	generalPurposeTemplate = Instance.new("Frame");
	generalPurposeTemplate.BackgroundColor3 = getColor(Enum.StudioStyleGuideColor.MainBackground)
	generalPurposeTemplate.Size = UDim2.new(1,0,0,20)
	generalPurposeTemplate.BorderSizePixel = 0
	
	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.TextXAlignment = Enum.TextXAlignment.Center
	description.Text = "nil"
	description.Size = UDim2.new(.25,-10,.9,0);
	description.AnchorPoint = Vector2.new(.5,.5);
	description.Position = UDim2.new(.125,5,.5,0)
	description.TextSize = 15
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Code
	description.TextColor3 = getColor(Enum.StudioStyleGuideColor.MainText)
	description.Parent = generalPurposeTemplate
	description.BorderSizePixel = 0
	
	
	local textBox = Instance.new("TextBox")
	textBox.TextXAlignment = Enum.TextXAlignment.Center
	textBox.Text = "Hello World!"
	textBox.Size = UDim2.new(.5,-110,.9,0);
	textBox.AnchorPoint = Vector2.new(.5,.5);
	textBox.Position = UDim2.new(.5,-55,.5,0)
	textBox.TextSize = 15
	textBox.BackgroundTransparency = 1
	textBox.Font = Enum.Font.Code
	textBox.TextColor3 = getColor(Enum.StudioStyleGuideColor.SubText)
	textBox.PlaceholderColor3 = getColor(Enum.StudioStyleGuideColor.DimmedText)
	textBox.ClearTextOnFocus = true
	textBox.Parent = generalPurposeTemplate
	textBox.BorderSizePixel = 0

	local submitButton = Instance.new("TextButton")
	submitButton.Name = "Submit"
	submitButton.Text = "Submit"
	submitButton.TextXAlignment = Enum.TextXAlignment.Center
	submitButton.Size = UDim2.new(0,100,.9,0)
	submitButton.AnchorPoint = Vector2.new(1,0.5)
	submitButton.Position = UDim2.new(1,-10,0.5,0)
	submitButton.TextSize = 15
	submitButton.BackgroundTransparency = 0
	submitButton.Font = Enum.Font.Code
	submitButton.TextColor3 = getColor(Enum.StudioStyleGuideColor.ButtonText)
	submitButton.BackgroundColor3 = getColor(Enum.StudioStyleGuideColor.Button)
	submitButton.Parent = generalPurposeTemplate
	submitButton.BorderSizePixel = 0
	
end

-- height 30
local largeSpaciousTemplate do
	largeSpaciousTemplate = Instance.new("Frame")
	largeSpaciousTemplate.Size = UDim2.new(1,0,0,30)
	largeSpaciousTemplate.BackgroundTransparency = 1
	local uiList = Instance.new("UIListLayout")
	uiList.FillDirection = Enum.FillDirection.Horizontal
	uiList.SortOrder = Enum.SortOrder.LayoutOrder
	uiList.Parent = largeSpaciousTemplate
end

local captionedTextBoxTemplate = Instance.new("Frame") do
	captionedTextBoxTemplate.AutomaticSize = Enum.AutomaticSize.X
	captionedTextBoxTemplate.Size = UDim2.new(0,100, 1,0) -- minimum x size 30 but automatic scaled, fills y size regardless
	captionedTextBoxTemplate.BackgroundTransparency = 1
	
	local field = Instance.new("TextBox")
	field.Size = UDim2.fromScale(1,.5)
	field.AnchorPoint = Vector2.new(0.5,1)
	field.Position = UDim2.fromScale(0.5,1)
	field.Parent = captionedTextBoxTemplate
	field.TextSize = 15
	field.PlaceholderText = "Enter.."
	field.Text = ""
	field.TextColor3 = getColor(Enum.StudioStyleGuideColor.SubText)
	field.PlaceholderColor3 = getColor(Enum.StudioStyleGuideColor.DimmedText)
	field.BackgroundColor3 = getColor(Enum.StudioStyleGuideColor.InputFieldBackground)
	field.BorderSizePixel = 0
	field.Font = Enum.Font.Code
	
	local caption = Instance.new("TextLabel")
	caption.Size = UDim2.fromScale(1,.5)
	caption.AnchorPoint = Vector2.new(0.5,0)
	caption.Position = UDim2.fromScale(0.5,0)
	caption.TextSize = 15
	caption.TextColor3 = getColor(Enum.StudioStyleGuideColor.MainText)
	caption.BackgroundTransparency = 1
	caption.Text = "Desc"
	caption.BorderSizePixel = 0
	caption.Parent = captionedTextBoxTemplate
	caption.Font = Enum.Font.Code
	caption.ZIndex = 0

end

type generalTab = { -- for autocomplete and not representing the actual object
	Description: TextLabel,
	TextBox: TextBox,
	Submit: TextButton,
} & Frame

local emit: generalTab = generalPurposeTemplate:Clone():: any
emit.Description.Text = "Emit Count"
emit.Submit.Text = "Emit"
emit.TextBox.PlaceholderText = "Enter Amount"
emit.TextBox.Text = "0"
emit.Parent = container
emit.LayoutOrder = 0

local convertSelection: generalTab = generalPurposeTemplate:Clone():: any
convertSelection.Description.Text = "Convert to code snippet"
convertSelection.TextBox.PlaceholderText = "Copy/Paste From Here"
convertSelection.TextBox.Text = ""
convertSelection.TextBox.ClearTextOnFocus = false
convertSelection.TextBox.TextWrapped = false
convertSelection.Parent = container
convertSelection.LayoutOrder = 10

local newEmitter: generalTab = generalPurposeTemplate:Clone():: any
newEmitter.Description.Text = "Create new emitter"
newEmitter.TextBox.PlaceholderText = "Enter instance type or leave blank"
newEmitter.TextBox.ClearTextOnFocus = false
newEmitter.TextBox.Text = "CFrameValue"
newEmitter.Parent = container
newEmitter.LayoutOrder = 2

local EasingFunctions = require(script:WaitForChild("EasingFunctions"))
local easingFunctionSelection = largeSpaciousTemplate:Clone()
easingFunctionSelection.Parent = container
easingFunctionSelection.LayoutOrder = 10
;(easingFunctionSelection.UIListLayout:: UIListLayout).HorizontalFlex = Enum.UIFlexAlignment.Fill
;(easingFunctionSelection.UIListLayout:: UIListLayout).HorizontalAlignment = Enum.HorizontalAlignment.Center

local easingFunctionDescription = generalPurposeTemplate.Description:Clone()
easingFunctionDescription.Parent = easingFunctionSelection
easingFunctionDescription.LayoutOrder = 0
easingFunctionDescription.Text = "Apply Number Sequence";
(easingFunctionDescription:: TextLabel).TextWrapped = true

local appliedConstant_Field = captionedTextBoxTemplate:Clone()
appliedConstant_Field.TextLabel.Text = "Constant"
appliedConstant_Field.TextBox.PlaceholderText = "number"
appliedConstant_Field.TextBox.Text = "0"
appliedConstant_Field.LayoutOrder = 1
appliedConstant_Field.Parent = easingFunctionSelection

local easingMagnitude_Field = captionedTextBoxTemplate:Clone()
easingMagnitude_Field.TextLabel.Text = "Ease Size"
easingMagnitude_Field.TextBox.PlaceholderText = "number"
easingMagnitude_Field.TextBox.Text = "1"
easingMagnitude_Field.LayoutOrder = 2
easingMagnitude_Field.Parent = easingFunctionSelection

local appliedEasingFunction_Field = captionedTextBoxTemplate:Clone()
appliedEasingFunction_Field.TextLabel.Text = "Function"
appliedEasingFunction_Field.TextBox.Text = "OutExpo"
appliedEasingFunction_Field.TextBox.PlaceholderText = "string"
appliedEasingFunction_Field.LayoutOrder = 3
appliedEasingFunction_Field.Parent = easingFunctionSelection

local scrollframe = Instance.new("ScrollingFrame")
scrollframe.Size = UDim2.fromScale(1,5)
scrollframe.Position = UDim2.fromScale(0.5,0)
scrollframe.AnchorPoint = Vector2.new(0.5,1);
scrollframe.Visible = false
scrollframe.BackgroundTransparency = 0.5
scrollframe.Parent = appliedEasingFunction_Field.TextBox
--scrollframe.VerticalScrollBarInset = Enum.ScrollBarInset.Always

local scrollframeLayout = Instance.new("UIGridLayout")
scrollframeLayout.CellSize = UDim2.new(1,0,0,15)
scrollframeLayout.CellPadding = UDim2.new()
scrollframeLayout.SortOrder = Enum.SortOrder.Name
scrollframeLayout.Parent = scrollframe
scrollframeLayout.FillDirection = Enum.FillDirection.Horizontal
scrollframeLayout.FillDirectionMaxCells = 0

for k, _ in EasingFunctions do
	local option = Instance.new("TextButton")
	option.Size = UDim2.fromScale(1,.5)
	option.AnchorPoint = Vector2.new(0.5,0)
	option.Position = UDim2.fromScale(0.5,0)
	option.TextSize = 15
	option.TextColor3 = getColor(Enum.StudioStyleGuideColor.ButtonText)
	option.BackgroundColor3 = getColor(Enum.StudioStyleGuideColor.Button)
	option.BackgroundTransparency = 0
	option.Text = k
	option.BorderSizePixel = 0
	option.Font = Enum.Font.Code
	option.Parent = scrollframe
	option.MouseButton1Down:Connect(function()
		appliedEasingFunction_Field.TextBox.Text = k
	end)
end
scrollframe.CanvasSize = UDim2.fromOffset(0, scrollframeLayout.AbsoluteContentSize.Y)

local graphWindow = Instance.new("Frame")
graphWindow.Size = UDim2.new(0,70,1,0)
graphWindow.BackgroundColor3 = getColor(Enum.StudioStyleGuideColor.InputFieldBackground)
graphWindow.LayoutOrder = 5
graphWindow.Parent = easingFunctionSelection

local graphPad = Instance.new("UIPadding")
graphPad.Parent = graphWindow
graphPad.PaddingTop = UDim.new(0.1,0)
graphPad.PaddingBottom = graphPad.PaddingTop
graphPad.PaddingLeft = graphPad.PaddingTop
graphPad.PaddingRight = graphPad.PaddingTop
local graphDots = {}
for i = 0, 1, 0.1 do
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(2,2)
	dot.BorderSizePixel = 0
	dot.BackgroundColor3 = getColor(Enum.StudioStyleGuideColor.MainText)
	dot.AnchorPoint = Vector2.new(0.5,0.5)
	dot.Parent = graphWindow
	graphDots[i] = dot
end
local oldText = ""

local attributeName = captionedTextBoxTemplate:Clone()
attributeName.TextBox.PlaceholderText = "string"
attributeName.TextLabel.Text = "Key"
attributeName.TextBox.Text = "Size"
attributeName.LayoutOrder = 6
attributeName.Parent = easingFunctionSelection

local isItAnAttribute = captionedTextBoxTemplate:Clone()
isItAnAttribute.TextLabel.Text = "Attribute?"
isItAnAttribute.TextBox.PlaceholderText = "boolean"
isItAnAttribute.TextBox.Text = "true"
isItAnAttribute.LayoutOrder = 7
isItAnAttribute.Parent = easingFunctionSelection

local easingFunctionSubmitButton = generalPurposeTemplate.Submit:Clone()
easingFunctionSubmitButton.LayoutOrder = 8
easingFunctionSubmitButton.Parent = easingFunctionSelection

-- Update loop

local cnxns = {}

local function disconnect()
	for _, v in cnxns do
		v:Disconnect()
	end
	cnxns = {}
end

local e = 1;

local function record(f: () -> ())
	f()
	ChangeHistoryService:SetWaypoint(tostring(e))
end

local function isValid(v)
	return v.ClassName == "ParticleEmitter" or v.ClassName == "Beam" or v:HasTag(shared.MeshEmitterMethods.Tag)
end
	
local function onSelectedDo(f)
	for _, v in SelectionService:Get() do
		if isValid(v) then
			f(v)
		end
	end

	return
end

local function onSelectedAndDescendantsDo(f)
	for _, v in SelectionService:Get() do
		if isValid(v) then
			f(v)
		end

		for _, vv in v:GetDescendants() do
			if isValid(vv) then
				f(vv)
			end
		end
	end
	
	return
end

local function sendBlatantMessageThatPurpl3WillDefinitelyBeAbleToSee(text: string)
	local msg = Instance.new("Message")
	msg.Text = text .. " for more details please open VIEW -> OUTPUT and check for warnings"
	msg.Parent = workspace.Camera
	task.delay(3, function()
		msg:Destroy()
	end)
	warn(text .. "\n" .. debug.info(2, "l"))
end

local function tryEmit(v)
	shared.MeshEmitterMethods.Emit(v, v:GetAttribute("EmitCount") or 0)
end

local function connect()
	disconnect()
	
	table.insert(cnxns, (appliedEasingFunction_Field.TextBox:: TextBox).Focused:Connect(function()
		scrollframe.Visible = true
		scrollframe.Active = true
	end))
	table.insert(cnxns, UserInputService.InputBegan:Connect(function(input)
		if input == Enum.KeyCode.Escape then
			scrollframe.Active = false
			scrollframe.Visible = false
		end
	end))
	
	table.insert(cnxns, (appliedEasingFunction_Field.TextBox:: TextBox).FocusLost:Connect(function()
		scrollframe.Active = false
		scrollframe.Visible = false
	end))
	
	table.insert(cnxns, (appliedEasingFunction_Field.TextBox:: TextBox).Changed:Connect(function()
		if oldText ~= appliedEasingFunction_Field.TextBox.Text then
			oldText = appliedEasingFunction_Field.TextBox.Text

			local f = EasingFunctions[appliedEasingFunction_Field.TextBox.Text]

			f = f or function() return 0 end
			for i, dot in graphDots do
				dot.Position = UDim2.fromScale(i, 1-f(i))
			end
		end
	end))
	
	table.insert(cnxns, emit.Submit.Activated:Connect(function() record(function()
		onSelectedAndDescendantsDo(tryEmit)
	end) end))
	table.insert(cnxns, (easingFunctionSubmitButton:: GuiButton).Activated:Connect(function() record(function()
			
			local f = assert(EasingFunctions[appliedEasingFunction_Field.TextBox.Text], appliedEasingFunction_Field.TextBox.Text .. " is not a valid easing function, refer to the dropdown.")
			local magnitude: number = assert(tonumber(easingMagnitude_Field.TextBox.Text), "Unable to convert \"" .. easingMagnitude_Field.TextBox.Text .. "\" in \"Ease Size\" into a number")
			local const: number = assert(tonumber(appliedConstant_Field.TextBox.Text), "Unable to convert \"" .. appliedConstant_Field.TextBox.Text .. "\" in \"Constant\" into a number")
			
			
			local ns = {}
			for i = 0, 1, 0.1 do
				table.insert(ns, NumberSequenceKeypoint.new(i, const + magnitude * f(i), 0))
			end
			local seq = NumberSequence.new(ns)
			
				if isItAnAttribute.TextBox.Text == "false" or isItAnAttribute.TextBox.Text == "" then
					onSelectedDo(function(emitter)
						emitter[attributeName.TextBox.Text] = seq
					end)
				else
					onSelectedDo(function(emitter)
						local v = emitter:GetAttribute(attributeName.TextBox.Text)

						assert(typeof(v) == "NumberSequence" or typeof(v) == "nil", "Attribute is not a NumberSequence or nil")

						emitter:SetAttribute(attributeName.TextBox.Text, seq)
					end)
				end
	end) end))
	table.insert(cnxns, convertSelection.Submit.Activated:Connect(function() record(function()
			local code = [[
			
			local function sendBlatantMessageThatPurpl3WillDefinitelyBeAbleToSee(text: string)
				local msg = Instance.new("Message")
				msg.Text = text .. " for more details please open VIEW -> OUTPUT and check for warnings"
				msg.Parent = workspace.Camera
				task.delay(3, function()
					msg:Destroy()
				end)
				warn(text .. "\n" .. debug.info(2, "l"))
			end
			
			local __MeshEmit = shared.MeshEmitterMethods.Emit
			
			local function __MeshEmitWithAttributes(v)
				__MeshEmit(v, v:GetAttribute("EmitCount") or 0)
			end
			
			function emitMeshes()
			
			]]
			onSelectedAndDescendantsDo(function(v)
				if not v:IsDescendantOf(workspace) then warn("Can't emit " .. v:GetFullName() .. " because not in workspace") return end
				code = code .. "\nxpcall(function()\n__MeshEmitWithAttributes(" .. v:GetFullName().. ") end, sendBlatantMessageThatPurpl3WillDefinitelyBeAbleToSee)"
			end)
			code = code .. "\nend\nemitMeshes()"
			
			convertSelection.TextBox.Text = code
		end) end))
	
	
	table.insert(cnxns, newEmitter.Submit.Activated:Connect(function() record(function()
			
			local new: Instance
			if newEmitter.TextBox.Text ~= "" then
				local s, result = pcall(function()
					return Instance.new(newEmitter.TextBox.Text)
				end)
				
				
				if s then
					new = result
				else
					warn("Unable to create a " .. newEmitter.TextBox.Text .. " because " .. result)
					newEmitter.TextBox.Text = "Invalid"
					task.delay(2, function()
						if newEmitter.TextBox.Text == "Invalid" then
							newEmitter.TextBox.Text = "CFrameValue"
						end
					end)
				end
			end
			new = new:: Instance? or Instance.new("CFrameValue")
			new:AddTag(shared.MeshEmitterMethods.Tag)
			new.Name = "MeshEmitter"
			new.Parent = SelectionService:Get()[1] or workspace
			local meshPart = Instance.new("MeshPart")
			meshPart.CanCollide = false
			meshPart.CanQuery = false
			meshPart.CanTouch = false
			meshPart.Transparency = 1
			meshPart.Locked= true
			meshPart.Size = Vector3.zero
			meshPart.Anchored = true
			meshPart.Name = "Mesh"
			meshPart.Parent = new
			
			SelectionService:Set({new})
			
			
		end) end))

	
	table.insert(cnxns, emit.TextBox.FocusLost:Connect(function() record(function()
			
		local count = tonumber(emit.TextBox.Text)

			if count then
				onSelectedDo(function(v)
				v:SetAttribute("EmitCount", count)
			end)
		end
	end) end))
	
	SelectionService.SelectionChanged:Connect(function()
		emit.TextBox.Text = ""
	end)
end


local function toggle(ignore)
	if not ignore then
		widget.Enabled = not widget.Enabled
	end
	

	if widget.Enabled then
		connect()
	else
		disconnect()
	end
end

-- Toggle button
button.Click:Connect(toggle)

toggle(true)

-- hotfix

local thisVersion = tick()
_G.cooocrazyheadMeshEmitterUtilPlugin_version = thisVersion
while task.wait() do
	if _G.cooocrazyheadMeshEmitterUtilPlugin_version ~= thisVersion then
		script:Destroy()
	end
end