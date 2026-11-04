export type BezierParams = {
	DeflectionRelativeSize: number,
	Duration: number,
	DeflectionAngle: number, -- for random generation
	DeflectionEasingStyle: Enum.EasingStyle,
	ForwardEasingStyle: Enum.EasingStyle,
	DeflectionEasingDirection: Enum.EasingDirection,
	ForwardEasingDirection: Enum.EasingDirection,
	MaxSegmentLength: number?,
}

local BezierParams = {}
BezierParams.__index = BezierParams
function BezierParams.new()
	return {
		DeflectionRelativeSize = 0.25;
		Duration = 1;
		DeflectionAngle = 90;

		DeflectionEasingStyle = Enum.EasingStyle.Sine;
		DeflectionEasingDirection = Enum.EasingDirection.In;

		ForwardEasingStyle = Enum.EasingStyle.Back;
		ForwardEasingDirection = Enum.EasingDirection.Out;

	}:: BezierParams
end

return BezierParams