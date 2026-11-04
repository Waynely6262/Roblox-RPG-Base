local Lerpable = {
	Color3 = true;
	Vector3 = true;
	CFrame = true;
	UDim2 = true;
}

return function(i, f, a)
	if Lerpable[typeof(i)] then
		return i:Lerp(f, a)
	else
		return i * (1 - a) + f * a
	end
end