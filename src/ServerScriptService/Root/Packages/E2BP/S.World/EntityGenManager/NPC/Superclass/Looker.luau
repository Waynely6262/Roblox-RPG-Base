--!strict

local API = {}
local Class = {}
Class.__index = Class
API.Class = Class

-- Creates and returns an AlignOrientation constraint configured similarly to
-- Roblox's default character auto-rotate-to-camera behavior (XZ plane only)
--
-- @param rig The R15 character Model
-- @return AlignOrientation The created constraint (already parented to root part)
-- @return Attachment The attachment created on the root part
function API.new(rootPart: BasePart)

	-- Create attachment directly on the root part (primary orientation point)
	local attach = Instance.new("Attachment")
	attach.Name = "CameraXZAlignAttachment"
	attach.Parent = rootPart

	-- Create the AlignOrientation constraint
	local align = Instance.new("AlignOrientation")
	align.Name = "CameraXZAlign"

	-- Core properties matching Roblox default auto-rotate behavior
	align.Mode                = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0         = attach
	align.Enabled             = true

	-- RigidityEnabled makes it snap instantly (like default Roblox character)
	align.RigidityEnabled     = true

	-- We only want rotation around Y-axis (XZ plane facing)
	align.Responsiveness      = 200      -- very snappy
	align.MaxTorque           = 1e8      -- effectively unlimited
	align.MaxAngularVelocity  = 200      -- high enough

	-- Primary axis only → locks to Y-axis rotation
	align.PrimaryAxisOnly     = true
	align.PrimaryAxis         = Vector3.new(0, 0, -1)  -- -Z forward

	-- Initial CFrame (will be updated via methods)
	align.CFrame              = CFrame.new()
	align.Parent              = rootPart

	local self = setmetatable({
		Part = rootPart,
		Attachment = attach,
		AlignOrientation = align,
	}, Class)
	self:toggle(false)
	return self
end

function Class.toggle(self: Class, isEnabled: boolean): boolean
	self.AlignOrientation.Enabled = isEnabled
	return isEnabled
end

-- Changes the direction the character should face (XZ plane only)
-- Pass a direction vector (should be unit length or will be normalized)
function Class.changeDirection(self: Class, lookVector: Vector3)
	if not self:toggle(lookVector ~= nil) then return end
	if lookVector.Magnitude < 0.001 then
		-- Invalid / zero vector → don't change anything
		return
	end

	-- Flatten to XZ plane and normalize
	local flat = Vector3.new(lookVector.X, 0, lookVector.Z)
	local direction = flat.Unit

	-- Create CFrame where -Z points toward the direction
	-- (matches Roblox character forward convention)
	local targetCFrame = CFrame.lookAt(Vector3.zero, direction)

	self.AlignOrientation.CFrame = targetCFrame
end

-- Makes the character face toward a world position (XZ plane only)
-- Ignores Y difference — only horizontal facing
function Class.lookAt(self: Class, position: Vector3?)
	if not self:toggle(position ~= nil) then return end
	
	local rootPos = self.Part.Position

	-- Direction from root to target position
	local toTarget = position - rootPos

	-- If too close, don't do anything (prevents NaN / jitter)
	if toTarget.Magnitude < 0.1 then
		return
	end

	-- Flatten to XZ plane
	local flatDirection = Vector3.new(toTarget.X, 0, toTarget.Z).Unit

	-- Create CFrame where -Z points toward the target
	local targetCFrame = CFrame.lookAt(Vector3.zero, flatDirection)

	self.AlignOrientation.CFrame = targetCFrame
end

export type Class = typeof(API.new(Instance.new("Part")))

return API