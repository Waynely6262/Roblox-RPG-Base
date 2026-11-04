local TweenService = game:GetService("TweenService")

return function(part: BasePart, final_properties: {[string]: any}, TInfo: TweenInfo)

	local T = TweenService:Create(part, TInfo, final_properties)
	T.Completed:Once(function()
		part:Destroy()
	end)
	T:Play()

end;