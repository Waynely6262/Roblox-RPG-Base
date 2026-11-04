local TO_RAD = math.pi/180
local ANGULAR_IMPULSE_PROPORTIONS = Vector3.new(TO_RAD * 0.5,TO_RAD*0.5,TO_RAD * 3)
local SOFT_CAP_IMPULSE_SIZE = 1000
local Spring = require(game.ReplicatedStorage.Modules.SpringModule)
local RunService = game:GetService("RunService")

local rand = Random.new()

local position = Spring.new(Vector3.zero)
local orientation = Spring.new(Vector3.zero)

orientation._speed = 30
orientation._damper = 0.18

position._speed = 30
position._damper = 0.18

local humanoid: Humanoid?

local cam = workspace.CurrentCamera

local function getHumanoidFromCharacter(char)
	humanoid = nil
	humanoid = char:WaitForChild("Humanoid")
end

local player = game:GetService("Players").LocalPlayer

player.CharacterAdded:Connect(getHumanoidFromCharacter)
if player.Character then
	getHumanoidFromCharacter(player.Character)
end

local function randomSign()
	return math.random() * 2 - 1
end

local Shaker = {}

function Shaker.ApplyVectorImpulse(impulse_size)
	impulse_size = math.min(impulse_size,SOFT_CAP_IMPULSE_SIZE)
	position.Velocity += rand:NextUnitVector() * impulse_size
end

function Shaker.SetZero()
	position.Velocity = Vector3.zero
	orientation.Velocity = Vector3.zero
end

function Shaker.ApplyAngularImpulse(impulse_size)
	impulse_size = math.min(impulse_size,SOFT_CAP_IMPULSE_SIZE)

	local angularImpulse = (rand:NextUnitVector() * ANGULAR_IMPULSE_PROPORTIONS) * impulse_size

	orientation.Velocity += angularImpulse
	task.delay(0.1, function()
		orientation.Velocity -= angularImpulse
	end)
end

function Shaker.ApplyImpulse(impulse_size)
	Shaker.ApplyVectorImpulse(impulse_size)
	Shaker.ApplyAngularImpulse(impulse_size)
end

function Shaker.disable()
	RunService:UnbindFromRenderStep("CameraShake")
end

function Shaker.enable()
	Shaker.disable()
	local p0 = os.clock()
	RunService:BindToRenderStep("CameraShake", 302, function()

		local now = os.clock()
		local dt = now - p0
		p0 = now

		if humanoid then
			humanoid.CameraOffset = position.Position
		end
		local orientationPos = orientation.Position
		cam.CFrame *= CFrame.Angles(orientationPos.X, orientationPos.Y,orientationPos.Z)

	end)

end
Shaker.enable()

return Shaker


