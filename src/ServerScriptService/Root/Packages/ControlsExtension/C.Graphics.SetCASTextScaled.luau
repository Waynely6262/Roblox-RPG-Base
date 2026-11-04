local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui


local function onScreen(Screen)

	local function onDescendantAdded(d: Instance)
		if d.ClassName == "TextLabel" then

			d.TextScaled = true
		end
	end


	Screen.DescendantAdded:Connect(onDescendantAdded)

	for _, v in Screen:GetDescendants() do
		onDescendantAdded(v)
	end

end

local queryResult = PlayerGui:FindFirstChild("ContextActionGui") 
if queryResult then
	onScreen(queryResult)
	return nil
else

	local cnxn: RBXScriptConnection
	cnxn = PlayerGui.ChildAdded:Connect(function(c)
		if c.Name == ("ContextActionGui") then
			cnxn:Disconnect()
			onScreen(c)
		end
	end)

	return nil
end
