if script:IsDescendantOf(game.ReplicatedStorage) then
	return
end
local player = game.Players.LocalPlayer

if player.Character and script:IsDescendantOf(player.Character) then return end -- avoid running if you are the owner of this character

local rgbs = {}

for _,v in script.Parent:GetChildren() do
	if v:GetAttribute("RGB") then
		table.insert(rgbs, v)
	end
end
script.Parent.ChildAdded:Connect(function(c)
	if c:GetAttribute("RGB") then
		table.insert(rgbs, c)
	end
end)

-- from gpt
local function RainbowColor(alpha: number): Color3
	alpha = alpha % 1 -- wrap around

	local segment = math.floor(alpha * 6)
	local t = (alpha * 6) % 1 -- progress through the current segment

	local r, g, b = 0, 0, 0
	if segment == 0 then      r, g, b = 1, t, 0       -- red to yellow
	elseif segment == 1 then  r, g, b = 1 - t, 1, 0   -- yellow to green
	elseif segment == 2 then  r, g, b = 0, 1, t       -- green to cyan
	elseif segment == 3 then  r, g, b = 0, 1 - t, 1   -- cyan to blue
	elseif segment == 4 then  r, g, b = t, 0, 1       -- blue to magenta
	elseif segment == 5 then  r, g, b = 1, 0, 1 - t   -- magenta to red
	end

	return Color3.new(r, g, b)
end

game:GetService("RunService").RenderStepped:Connect(function()
	for _, v in rgbs do
		v.Color = RainbowColor(tick()*0.1)
	end
end)