local re = game.ReplicatedStorage.Remotes.MainE
local cnxn
return function(c)
	if cnxn then cnxn:Disconnect() end
	cnxn = game:GetService("RunService").Heartbeat:Connect(function()
		re:FireServer("cf",c:GetPivot())
	end)
end