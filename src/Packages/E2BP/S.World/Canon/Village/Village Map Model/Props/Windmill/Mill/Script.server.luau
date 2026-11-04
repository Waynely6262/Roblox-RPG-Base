local m = script.Parent
repeat
	m:PivotTo(m:GetPivot() * CFrame.Angles(0, 0, task.wait(0.1)))
until false