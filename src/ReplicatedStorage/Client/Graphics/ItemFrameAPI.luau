--!strict
-- Written by Grok
-- ReplicatedStorage.Client.Graphics.Util.ItemFrame.luau
-- Reusable item slot builder & updater for Inventory, Crafting, Trading, etc.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Item = require(ReplicatedStorage.Modules.Inventory.Item)
local UIAPI = require(ReplicatedStorage.Client.Graphics.Util.UIAPI)

-- Templates should exist inside this script or a known location
local TEMPLATE_FOLDER = script:FindFirstChild("Templates") or script

-- If you prefer to keep templates inside this module script:
-- local Template       = TEMPLATE_FOLDER:WaitForChild("SlotTemplate")
-- local ImageTemplate  = TEMPLATE_FOLDER:WaitForChild("ImageTemplate")
-- local ViewportTemplate = TEMPLATE_FOLDER:WaitForChild("ViewportTemplate")
-- local HighlightTemplate = TEMPLATE_FOLDER:WaitForChild("Highlight")

-- But more commonly people put them in the same folder as the old script:
local Template       = script.Template
local ImageTemplate  = script.ImageTemplate
local ViewportTemplate = script.ViewportTemplate
local HighlightTemplate = script.Highlight

-- Types

local ItemFrame = {}
ItemFrame.__index = ItemFrame

local function createViewportCamera(): Camera
	local cam = Instance.new("Camera")
	cam.CFrame = CFrame.new(Vector3.new(10, 10, 10), Vector3.zero)
	cam.FieldOfView = 30
	return cam
end

function ItemFrame.bareSet(self: ItemFrame, name: string, amt: number)
	return self:Set(Item.new(name, {amt = amt}))
end

function ItemFrame.Set(self: ItemFrame, item: Item.item)

	if self.Mirrors then
		for _, other in self.Mirrors do
			other:Set(item)
		end
	end

	local displayText = `{item.name} {item.dynamic.amt ~= 1 and ` x{tostring(item.dynamic.amt)}` or ``}`

	if self._current ~= item.name then
		self:Clear(false)
		self._current = item.name

		local image = item:getData().image
		if typeof(image) == "string" then
			-- Asset id or rbxassetid
			local img = ImageTemplate:Clone()
			img.Image = image
			img.Name = "DisplayLabel"
			img.Parent = self.Display
			self._ActiveDisplayObject = img
		elseif typeof(image) == "Instance" then
			local vp = ViewportTemplate:Clone()
			vp.Name = "DisplayLabel"

			local modelClone: Model = image:Clone():: Model
			modelClone:PivotTo(CFrame.identity)
			modelClone.Parent = vp
			-- If your models have a specific ThumbnailPoint attachment, you can reposition here

			vp.CurrentCamera = createViewportCamera()
			vp.Parent = self.Display
			self._ActiveDisplayObject = vp
		else
			warn("Unsupported item.image type:", typeof(image))
		end
	end

	self.Display.NameLabel.Text = displayText
end

function ItemFrame.Clear(self: ItemFrame, doMirror: boolean?)
	if doMirror and self.Mirrors then
		for _, other in self.Mirrors do
			other:Clear(true)
		end
	end

	if self._ActiveDisplayObject then
		self._ActiveDisplayObject:Destroy()
		self._ActiveDisplayObject = nil
	end

	self.Display.NameLabel.Text = ""
end

function ItemFrame.SetTextOnly(self: ItemFrame, text: string)

	if self.Mirrors then
		for _, other in self.Mirrors do
			other:SetTextOnly(text)
		end
	end

	self.Display.NameLabel.Text = text
end

function ItemFrame.SetHighlight(self: ItemFrame, enabled: boolean, color: Color3?)

	if self.Mirrors then
		for _, other in self.Mirrors do
			other:SetHighlight(enabled, color)
		end
	end

	if enabled then
		if not self._Highlight then
			self._Highlight = HighlightTemplate:Clone();
			(self._Highlight:: typeof(HighlightTemplate)).Parent = self.Display
		end
		if color then
			(self._Highlight:: Frame).BackgroundColor3 = color
		end
	else
		if self._Highlight then
			self._Highlight:Destroy()
			self._Highlight = nil
		end
	end
end

function ItemFrame.addMirror(self: ItemFrame, mirror: ItemFrame)
	if mirror == self then warn("Can't set self as a mirror") return end
	self.Mirrors = self.Mirrors or {}
	table.insert(self.Mirrors:: {ItemFrame}, mirror)

end

function ItemFrame.Destroy(self: ItemFrame)
	self.Frame:Destroy()
	setmetatable(self, nil)
end

-- Static
function ItemFrame.new(parent: Instance, layoutOrder: number?, frameName: string)
	local frame = Template:Clone()
	if layoutOrder then
		frame.LayoutOrder = layoutOrder
	end
	frame.Parent = parent
	frame.Display.TextLabel.Text = frameName

	local self = setmetatable({
		Frame = frame,
		Display = frame.Display,
		Mirrors = nil:: {ItemFrame}?,
		_current = nil:: string?,
		_Highlight = nil:: typeof(HighlightTemplate)?,
		_ActiveDisplayObject = nil:: typeof(ImageTemplate) | typeof(ViewportTemplate)?,
	}, ItemFrame)

	return self
end

function ItemFrame.bulkNew(
	parent: Instance,
	count: number,
	baseLayoutOrder: number?
): {ItemFrame}

	local slots = {}

	for i = 1, count do
		local slot = ItemFrame.new(
			parent,
			(baseLayoutOrder or 0) + i,
			tostring(i)
		)
		table.insert(slots, slot)
	end

	return slots
end

export type ItemFrame = typeof(ItemFrame.new(Instance.new("Frame"), nil, ""))

return ItemFrame