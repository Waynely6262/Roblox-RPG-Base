if game:GetService("RunService"):IsStudio() then
	local fps = 5
	local spf = 1 / fps

	local prv = os.clock()
	game:GetService("RunService"):BindToRenderStep("throttle", 301, function()
		repeat until os.clock() - prv > spf
		prv = os.clock()
	end)
else
	script:Destroy()
end