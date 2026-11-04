return {
	onInvoke = function(show: boolean, text: string?)
		
		--TODO: Loading page
		print((show and "Loading" or "Loaded") .. ": " .. (text or ""))
		
	end,
}