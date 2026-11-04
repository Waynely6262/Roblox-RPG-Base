local function clampDecimalPlaces(x: number, sf: number)
	return tonumber(string.format("%."..sf.."f",x))
end
return clampDecimalPlaces