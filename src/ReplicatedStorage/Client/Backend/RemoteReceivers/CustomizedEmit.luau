local LocalPlayer = game:GetService("Players").LocalPlayer

local BaseEmitAPI = require(game.ReplicatedStorage.Modules.Utility.Emit)

local Themes = {
	
	
	Assassin = {
		Color3.new(1,0,0);
		Color3.new(0,0,0);
		Color3.new(1,1,1);
	};
	
	["Realm Protector"] = {
		Color3.new(0,0.85,1);
		Color3.new(1,1,1);
		Color3.new(1,0.9,0)
	};
	
	["Royal"] = {
		Color3.new(1,0.8,0);
		Color3.new(0.7,0,1);
		Color3.new(0.64,0.67,0.7)
	};
	
	["Knight"] = {
		Color3.new(0.8,0.8,0.8);
		Color3.new(0.25,0.7,0.9);
		Color3.new(1,1,1);
	};
	
	["Soul"] = {
		ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0.75,0.75,0.75));
		Color3.new(0.3, 0.2, 0.2);
		Color3.new(0,1,1);
	};
	
}

local Application = {
	Primary = {"Color", 1};
	Secondary = {"Color", 2};
	Tertiary = {"Color", 3};
}

local function themeify(template, themeKey)
	
	local ThemeSet = Themes[themeKey]
	
	if not ThemeSet then return end
	
	for _, v in template:GetDescendants() do
		local Info = Application[v.Name]
		if Info then
			v[Info[1]] = ThemeSet[Info[2]]
			
		end
	end
end


return {
	onInvoke = function(source: Player, template, cframe, lifetime, theme)
		if source == LocalPlayer then
			return
		end
		
		themeify(template)
		
		BaseEmitAPI.build(template, cframe, lifetime)
	end;
	
	_aliases = {
		"*fx";
	};
}

