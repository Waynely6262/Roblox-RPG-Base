local function formatTime(seconds: number): string -- from GPT
	local hrs = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)

	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

return formatTime