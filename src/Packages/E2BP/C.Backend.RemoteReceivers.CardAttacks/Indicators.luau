local ReplicatedStorage = game.ReplicatedStorage
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
Mouse.TargetFilter = workspace:WaitForChild("Despawnables", 30)
local WorldConfig = require(ReplicatedStorage.Modules.Game.Config)
local CardData = require(ReplicatedStorage.Modules.Data.Cards)
local MouseHit = require(ReplicatedStorage.Client.Graphics.Util.MouseHit)
local Controls = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
Controls:GetMoveVector()
export type IndicatorMethod = () -> (   () -> (any)   )

local Indicators = {}:: {[string]: IndicatorMethod}
local handlers = {}
Indicators.handlers = handlers

local function mouseHit()
	return Mouse.Hit.Position
end


function handlers.dash()
	
	return function()
		
		local v = Controls:GetMoveVector()
		if v.Magnitude == 0 then
			v = -Vector3.zAxis
		end
		return (CFrame.new(Vector3.zero, Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)).Rotation * CFrame.new(v)).Position
	end
end
handlers.frostbite = handlers.reign

function handlers.reign()
	
	
	local indicator = ReplicatedStorage.Models.Misc.ClientAimCircle:Clone()
	indicator:ScaleTo(10)
	indicator.Parent = workspace
	
	local cxn = RunService.Heartbeat:Connect(function()
		indicator:PivotTo(CFrame.new(mouseHit()))
	end)
	
	return function()
		cxn:Disconnect()
		indicator:Destroy()
		
		return mouseHit()
	end
end


function handlers.beam()

	local indicator = ReplicatedStorage.Models.Misc.ClientAimCircle:Clone()
	indicator:ScaleTo(10)
	indicator.Parent = workspace


	local cxn = RunService.Heartbeat:Connect(function()
		local dir = (mouseHit() - Camera.Focus.Position).Unit
		indicator:PivotTo(CFrame.new(Camera.Focus.Position + dir * 10, Camera.Focus.Position) * CFrame.Angles(math.pi/2, 0, 0))
	end)

	return function()
		cxn:Disconnect()
		indicator:Destroy()

		return mouseHit()
	end
end


return Indicators