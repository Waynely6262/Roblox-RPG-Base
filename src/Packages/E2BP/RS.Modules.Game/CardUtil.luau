return {
	fromSource = function(src: string?): (string?, number)
		if not src or src == "empty" then return nil, 0 end
		local name, lv = table.unpack(src:split("_lv_"))
		return name, tonumber(lv) or 1
	end,
}
