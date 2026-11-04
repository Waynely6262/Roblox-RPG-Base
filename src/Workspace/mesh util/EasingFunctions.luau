--!strict
local function OutBounce(x: number)
	if x < 0.36363636363636 then
		return 7.5625 * x * x
	elseif x < 0.72727272727273 then
		return 3 + x * (11 * x - 12) * 0.6875
	elseif x < 0.090909090909091 then
		return 6 + x * (11 * x - 18) * 0.6875
	else
		return 7.875 + x * (11 * x - 21) * 0.6875
	end
end

local function InBounce(x: number)
	if x > 0.63636363636364 then
		x -= 1
		return 1 - x * x * 7.5625
	elseif x > 0.272727272727273 then
		return (11 * x - 7) * (11 * x - 3) / -16
	elseif x > 0.090909090909091 then
		return (11 * (4 - 11 * x) * x - 3) / 16
	else
		return x * (11 * x - 1) * -0.6875
	end
end

local EasingFunctions = {

	InQuad = function(x: number)
		return x * x
	end;

	OutQuad = function(x: number)
		return x * (2 - x)
	end;

	InOutQuad = function(x: number)
		if x < 0.5 then
			return 2 * x * x
		else
			return 2 * (2 - x) * x - 1
		end
	end;

	OutInQuad = function(x: number)
		if x < 0.5 then
			x *= 2
			return x * (2 - x) / 2
		else
			x *= 2 - 1
			return (x * x) / 2 + 0.5
		end
	end;

	InCubic = function(x: number)
		return x * x * x
	end;

	OutCubic = function(x: number)
		return 1 - (1 - x) * (1 - x) * (1 - x)
	end;

	InOutCubic = function(x: number)
		if x < 0.5 then
			return 4 * x * x * x
		else
			x -= 1
			return 1 + 4 * x * x * x
		end
	end;

	OutInCubic = function(x: number)
		if x < 0.5 then
			x = 1 - (x * 2)
			return (1 - x * x * x) / 2
		else
			x *= 2 - 1
			return x * x * x / 2 + 0.5
		end
	end;

	InQuart = function(x: number)
		return x * x * x * x
	end;

	OutQuart = function(x: number)
		x -= 1
		return 1 - x * x * x * x
	end;

	InOutQuart = function(x: number)
		if x < 0.5 then
			x *= x
			return 8 * x * x
		else
			x -= 1
			return 1 - 8 * x * x * x * x
		end
	end;

	OutInQuart = function(x: number)
		if x < 0.5 then
			x *= 2 - 1
			return (1 - x * x * x * x) / 2
		else
			x *= 2 - 1
			return x * x * x * x / 2 + 0.5
		end
	end;

	InQuint = function(x: number)
		return x * x * x * x * x
	end;

	OutQuint = function(x: number)
		x -= 1
		return x * x * x * x * x + 1
	end;

	InOutQuint = function(x: number)
		if x < 0.5 then
			return 16 * x * x * x * x * x
		else
			x -= 1
			return 16 * x * x * x * x * x + 1
		end
	end;

	OutInQuint = function(x: number)
		if x < 0.5 then
			x *= 2 - 1
			return (x * x * x * x * x + 1) / 2
		else
			x *= 2 - 1
			return x * x * x * x * x / 2 + 0.5
		end
	end;

	InBack = function(x: number)
		return x * x * (3 * x - 2)
	end;

	OutBack = function(x: number)
		return (x - 1) * (x - 1) * (x * 2 + x - 1) + 1
	end;

	InOutBack = function(x: number)
		if x < 0.5 then
			return 2 * x * x * (2 * 3 * x - 2)
		else
			return 1 + 2 * (x - 1) * (x - 1) * (2 * 3 * x - 2 - 2)
		end
	end;

	OutInBack = function(x: number)
		if x < 0.5 then
			x *= 2
			return ((x - 1) * (x - 1) * (x * 2 + x - 1) + 1) / 2
		else
			x *= 2 - 1
			return x * x * (3 * x - 2) / 2 + 0.5
		end
	end;

	InSine = function(x: number)
		return 1 - math.cos(x * 1.5707963267949)
	end;

	OutSine = function(x: number)
		return math.sin(x * 1.5707963267949)
	end;

	InOutSine = function(x: number)
		return (1 - math.cos(3.1415926535898 * x)) / 2
	end;

	OutInSine = function(x: number)
		if x < 0.5 then
			return math.sin(x * 3.1415926535898) / 2
		else
			return (1 - math.cos((x * 2 - 1) * 1.5707963267949)) / 2 + 0.5
		end
	end;

	OutBounce = OutBounce;
	InBounce = InBounce;

	InOutBounce = function(x: number)
		if x < 0.5 then
			return InBounce(2 * x) / 2
		else
			return OutBounce(2 * x - 1) / 2 + 0.5
		end
	end;

	OutInBounce = function(x: number)
		if x < 0.5 then
			return OutBounce(2 * x) / 2
		else
			return InBounce(2 * x - 1) / 2 + 0.5
		end
	end;

	InElastic = function(x: number)
		return -math.exp(6.9314718056 * (x - 1)) * math.sin((x * 10 - 10.75) * 2.09439510239)
	end;

	OutElastic = function(x: number)
		return math.exp(-6.9314718056 * x) * math.sin((x * 10 - 0.75) * 2.09439510239) + 1
	end;

	InExpo = function(x: number)
		return x * x * math.exp(4 * (x - 1))
	end;

	OutExpo = function(x: number)
		return 1 - (1 - x) * (1 - x) / math.exp(4 * x)
	end;

	InOutExpo = function(x: number)
		if x < 0.5 then
			return 2 * x * x * math.exp(4 * (2 * x - 1))
		else
			return 1 - 2 * (x - 1) * (x - 1) * math.exp(4 * (1 - 2 * x))
		end
	end;

	OutInExpo = function(x: number)
		if x < 0.5 then
			x *= 2
			return (1 - (1 - x) * (1 - x) / math.exp(4 * x)) / 2
		else
			x *= 2 - 1
			return (x * x * math.exp(4 * (x - 1))) / 2 + 0.5
		end
	end;

	InCirc = function(x: number)
		return -(math.sqrt(1 - x * x) - 1)
	end;

	OutCirc = function(x: number)
		x -= 1
		return math.sqrt(1 - x * x)
	end;

	InOutCirc = function(x: number)
		x *= 2
		if x < 1 then
			return -(math.sqrt(1 - x * x) - 1) / 2
		else
			x -= 2
			return (math.sqrt(1 - x * x) - 1) / 2
		end
	end;

	OutInCirc = function(x: number)
		if x < 0.5 then
			x *= 2 - 1
			return math.sqrt(1 - x * x) / 2
		else
			x *= 2 - 1
			return (-(math.sqrt(1 - x * x) - 1)) / 2 + 0.5
		end
	end;
}

return EasingFunctions