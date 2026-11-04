
-- THEME
local DEFAULT_THEME = {
	FloorTexture = "";
	WallTexture = "";
	WallColor = Color3.new(0.8,0.8,0.8);
	WallTransparency = 0;
}

local THEMES = {

	{
		
		FloorTexture = "rbxassetid://126652514472232";
		WallTexture = "rbxassetid://126652514472232";
		WallColor = Color3.new(0.9,0.5,0.3);
	}
}
for _, t in THEMES do
	setmetatable(t, {
		__index = DEFAULT_THEME
	})
end

-- /THEME

return THEMES
