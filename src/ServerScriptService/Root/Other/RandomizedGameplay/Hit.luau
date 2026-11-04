return function(land: number, dodge: number)
	
	return land / (land + dodge) > math.random()
end