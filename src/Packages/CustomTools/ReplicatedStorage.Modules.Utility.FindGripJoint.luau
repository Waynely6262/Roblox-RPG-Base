local function r15(C: Model)
	local Hand = C:FindFirstChild("RightHand")
	return Hand and Hand:FindFirstChild("RightGripAttachment")
end

local function r6(C: Model)
	local Arm = C:FindFirstChild("Right Arm")
	return Arm and Arm:FindFirstChild("RightGripAttachment")
end


return {
	
	r6 = r6;
	r15 = r15;
	
	auto = function(Character: Model)
		return r15(Character) or r6(Character) or Character:FindFirstChild("RightGripAttachment", true)
	end
}