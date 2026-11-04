local LimbTree = {
	["LowerTorso"]                = "HumanoidRootPart",
		["UpperTorso"]            = "LowerTorso",
			["Head"]              = "UpperTorso",
			["RightUpperArm"]     = "UpperTorso",
				["RightLowerArm"] = "RightUpperArm",
					["RightHand"] = "RightLowerArm",
			["LeftUpperArm"]      = "UpperTorso",
				["LeftLowerArm"]  = "RightUpperArm",
					["LeftHand"]  = "RightLowerArm",
			["RightUpperLeg"]     = "LowerTorso",
				["RightLowerLeg"] = "RightUpperLeg",
					["RightFoot"] = "RightLowerLeg",
			["LeftUpperLeg"]      = "LowerTorso",
				["LeftLowerLeg"]  = "LeftUpperLeg",
					["LeftFoot"]  = "LeftLowerLeg",
}	

function LimbTree.GetParent(Limb, Character)
	return Character:FindFirstChild(LimbTree[Limb])
end

return LimbTree
