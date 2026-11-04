--!strict
local TweenHandler = require(game.ReplicatedStorage.Modules.Utility.TweenObject)

local PGB = setmetatable({}, TweenHandler)
PGB.super = TweenHandler
PGB.__index = PGB

local Class = {}

local newcspoint = ColorSequenceKeypoint.new
local newnmpoint = NumberSequenceKeypoint.new

local function GetTripleSequence(middle_point1, middle_point2, initial_color3, middle_color3, final_color3)

	if middle_point1 > middle_point2 then
		middle_point1, middle_point2 = middle_point2, middle_point1
	end

	middle_point1 = math.clamp(middle_point1, 0.001, 0.996)
	middle_point2 = math.clamp(middle_point2, middle_point1 + 0.002, 0.998)


	return ColorSequence.new({
		newcspoint(0,initial_color3);
		newcspoint(middle_point1, initial_color3);
		newcspoint(middle_point1 + 0.001, middle_color3);
		newcspoint(middle_point2, middle_color3);
		newcspoint(middle_point2 + 0.001, final_color3);
		newcspoint(1,final_color3)
	})
end

local function GetTripleNumSequence(middle_point1, middle_point2, initial_3, middle_3, final_3)

	if middle_point1 > middle_point2 then
		middle_point1, middle_point2 = middle_point2, middle_point1
	end

	middle_point1 = math.clamp(middle_point1, 0.001, 0.996)
	middle_point2 = math.clamp(middle_point2, middle_point1 + 0.002, 0.998)


	return NumberSequence.new({
		newnmpoint(0,initial_3);
		newnmpoint(middle_point1, initial_3);
		newnmpoint(middle_point1 + 0.001, middle_3);
		newnmpoint(middle_point2, middle_3);
		newnmpoint(middle_point2 + 0.001, final_3);
		newnmpoint(1,final_3)
	})
end


function Class.new(gradientReceiver: (ColorSequence, NumberSequence) -> (), initial: number?)
	local self = TweenHandler.new(initial or 0, 0.5):: any

	self._recv = gradientReceiver;

	self["FillColor"] = Color3.new(0,1,0);
	self["DeltaIncColor"] = Color3.new(0.5,1,0.5);
	self["DeltaDecColor"] = Color3.new(1,0,0);
	self["EmptyColor"] = Color3.new(0,0,0);

	self["FillTransparency"] = 0;
	self["DeltaTransparency"] = 0;
	self["EmptyTransparency"] = 0;


	setmetatable(self, PGB)
	return self:: (typeof(self) & TweenHandler.TweenObject)
end

function PGB:changeReceiver(receiver: (ColorSequence, NumberSequence) -> ())
	self._recv = receiver
end

function PGB:changeEasingFunction(f: (number) -> (number))
	self.ease = f
end

function PGB:update(n1: number)
	self:play(n1, function()

		local comparisonvalue = math.round(self.v * 1e3) * 1e-3

		local incrementing = n1 > comparisonvalue
		local equillibrium = n1 == comparisonvalue
		local decrementing = comparisonvalue > n1

		local atEmpty = n1 == 0

		local atFull = n1 == 1

		if atEmpty and equillibrium then
			self.Color = ColorSequence.new(self.EmptyColor)
			self.Transparency = NumberSequence.new(self.EmptyTransparency)
		elseif atFull and equillibrium then
			self.Color = ColorSequence.new(self.FillColor)
			self.Transparency = NumberSequence.new(self.FillTransparency)
		elseif equillibrium then
			self.Color = ColorSequence.new({
				newcspoint(0, self.FillColor);
				newcspoint(math.max(0.001, n1 - 0.001), self.FillColor);
				newcspoint(math.min(0.999, n1 + 0.001), self.EmptyColor);
				newcspoint(1, self.EmptyColor);
			})
			self.Transparency = NumberSequence.new({
				newnmpoint(0, self.FillTransparency);
				newnmpoint(math.max(0.001, n1 - 0.001), self.FillTransparency);
				newnmpoint(math.min(0.999, n1 + 0.001), self.EmptyTransparency);
				newnmpoint(1, self.EmptyTransparency);
			})
		elseif decrementing then
			self.Color = GetTripleSequence(n1, self.v, self.FillColor, self.DeltaDecColor, self.EmptyColor)
			self.Transparency = GetTripleNumSequence(n1, self.v, self.FillTransparency, self.DeltaTransparency, self.EmptyTransparency)
		elseif incrementing then
			self.Color = GetTripleSequence(self.v, n1, self.FillColor, self.DeltaIncColor, self.EmptyColor)
			self.Transparency = GetTripleNumSequence(self.v, n1, self.FillTransparency, self.DeltaTransparency, self.EmptyTransparency)
		end
		self._recv(self.Color, self.Transparency)
	end)


end
return Class