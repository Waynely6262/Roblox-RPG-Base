--!strict

local DEFAULT_ITEM_STACK = math.huge

local DEFAULT_LIMITS = {
	stack = DEFAULT_ITEM_STACK;
};

local defaultData = {limits = {stack = DEFAULT_ITEM_STACK}, weight = 0}

export type Data = {
	limits: {amt: number} & {[string]: any};
	weight: number;
	key: string?;
	
	stats: {[string]: number}?;
	lv_stats: {[string]: number}?;
	
}

local Catalog = setmetatable({

	Wood = {
		limits = DEFAULT_LIMITS;
		weight = 2;
		
	};
	
	Stone = {
		limits = DEFAULT_LIMITS;
		weight = 4;
	};
	
	Flint = {
		limits = DEFAULT_LIMITS;
		weight = 2;
	};
	
	["Bone"] = {
		limits = DEFAULT_LIMITS;
		weight = 6;
	};
	
	["Copper Ore"] = {
		limits = DEFAULT_LIMITS;
		weight = 15;
		
	};
	
	["Copper"] = {
		limits = DEFAULT_LIMITS;
		weight = 10;
	};
	
	["Tin Ore"] = {
		limits = DEFAULT_LIMITS;
		weight = 15;
	};
	
	["Tin"] = {
		limits = DEFAULT_LIMITS;
		weight = 10;
	};
	
	["Silver"] = {
		limits = DEFAULT_LIMITS;
		weight = 10;
	};
	
	["Silver Ore"] = {
		limits = DEFAULT_LIMITS;
		weight = 15;
		
	};
	
	["Gold"] = {
		limits = DEFAULT_LIMITS;
		weight = 10;
	};
	
	["Gold Ore"] = {
		limits = DEFAULT_LIMITS;
		weight = 15;
		
	};
	
	["Iron"] = {
		limits = DEFAULT_LIMITS;
		weight = 10;
		
	};
	
	["Iron Ore"] = {
		limits = DEFAULT_LIMITS;
		weight = 15;
		
	};
	
	["Titanium"] = {
		limits = DEFAULT_LIMITS;
		weight = 15;
		
	};
	
	["Titanium Ore"] = {
		limits = DEFAULT_LIMITS;
		weight = 20;
		
	};
	
	["Spider Silk"] = {
		limits = DEFAULT_LIMITS;
		weight = 1;
		
	};

	["Health Potion"] = {
		limits = DEFAULT_LIMITS;
		weight = 20;
	};
	
	["Dragon Scale"] = {
		limits = DEFAULT_LIMITS;
		weight = 20;
	};
}, {
	__index = function()
		return defaultData
	end,
})

------------------------------------------------------------------------------------------

local function merge(t)
	for i, v in t do
		Catalog[i] = v
	end
end

for _, v in script:GetChildren() do
	merge(require(v))
end
------------------------------------------------------------------------------------------

local dir = game.ReplicatedStorage.Models.Tools
for name, data in Catalog do
	data.image = dir:FindFirstChild(name, true)
end
------------------------------------------------------------------------------------------

local ToolTipHandlers = {
	
	
	stats = function(item, base_stats)
		local level_stats = item:getData().lv_stats
		if level_stats then
			level_stats = table.clone(level_stats)
			
			local level = item.dynamic.lv
			if level and level ~= 0 then
				for i, v in level_stats do
					base_stats[i] = (base_stats[i] or 0) + v * level
				end
			end
		end
		local src = "Stats: \n"
		for i, v in base_stats do
			src = src .. `{i}: {v}\n`
		end
		return src
	end,
	
}

local ToolTipDisplayNames = {
	
	-- Dynamic Datas
	amt = "Amount";
	lv = "Level";
	type = "Class";
	key = "Armor Type";
	weight = "Weight";
	
	-- Datas
	
	image = false;
	lv_stats = false;
	limits = false;
}


return {
	Catalog = Catalog:: typeof(Catalog) & {[string]: any};
	EquipmentKeys = {"Head","Chest","Legs","Feet", "Offhand"};
	
	ProfileAccessKey = "Inventory";
	ToolTipTranslation = function(item, k, v): string?
		
		if ToolTipHandlers[k] then
			return ToolTipHandlers[k](item, v)
		elseif ToolTipDisplayNames[k] ~= nil then
			if ToolTipDisplayNames[k] then
				return `{ToolTipDisplayNames[k]}: {v}`
			else
				return nil
			end
		end
		
		return `{k}: {v}`
	end,
}

