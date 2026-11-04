local lib = {

	["Iron"] = {
		["Iron Sword"] = {
			Wood = 20;
			Iron = 50;
		};
		["Iron Pickaxe"] = {
			Iron = 30;
			Wood = 15;
		};
	};
	["Stone"] ={
		["Stone Pickaxe"] = {
			Stone = 10;
			Wood = 5;
		};
	};

	["Titanium"] = {
		["Titanium Pickaxe"] = {
			Titanium = 30;
			Wood = 15;
		};
	};

	["Bone"] = {
		["Bone Dagger"] = {
			Bone = 5;
			Wood = 3;
		};
	};
	
	["Wood"] = {
		["Wooden Pickaxe"] = {
			Wood = 15;
		};
		["Wooden Sword"] = {
			Wood = 15;
		};
	};

	[""] = {
		["Health Potion"] = {
			--TODO
			Wood = 1;
		};
	};

}


local flattenedLib = {}


for group_name, group in lib do
	for item_name, materials in group do
		flattenedLib[item_name] = flattenedLib[item_name] or materials
	end
end

return {
	grouped = lib:: typeof(lib) & {{[string]: number}};
	flat = flattenedLib;
	uncategorized_key = "";
}