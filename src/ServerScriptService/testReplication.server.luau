
for i = 1, 1000 do
	local part = Instance.new("Part")
	part.Parent = workspace.Camera
	game:GetService("RunService").Heartbeat:Connect(function(dt)
		part.Position += Vector3.yAxis * dt
	end)
end


