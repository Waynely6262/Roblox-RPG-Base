local Config = {

	IS_STUDIO = game:GetService("RunService"):IsStudio();
	FLOOR_SIZE = 100; -- size of a floor in tiles
	TILE_SIZE = 8; -- size of a tile in studs
	MIN_WALL_HEIGHT = 1024; -- min size of a wall in studs
	MAX_WALL_HEIGHT = 1024; -- max size of a wall in studs
	LOCATION_SPACING = 2048; -- world spacing of locations in studs
	
	MAX_ROOM_SIZE = 20; -- max l/w of a room in tiles
	MIN_ROOM_SIZE = 3; -- min l/w of a room in tiles
	MAX_ROOMS = 200; -- max rooms generated in a floor

	ROOM_PADDING = -1; -- padding between rooms
	
	SPAWN_PERIOD = 3; -- base spawning period of uw floors (before floor difficulty is considered)
	
	WEAPON_MAX_REACH_STUDS = { -- Reach for different types of weapons; used for selection auto-hit feature
		default = 12;
		mace = 12;
		sword = 12;
		greatsword = 13;
		axe = 12;
		hammer = 13;
		spear = 20;
		pickaxe = 12;
		unarmed = 10;
		dagger = 10.5;
	};
	
	WEAPON_DEBOUNCE = { -- delay between each swing for a player
		default = 0.5;
		mace = 0.95;
		sword = 0.8;
		greatsword = 1.3;
		axe = 0.86;
		hammer = 1.5;
		spear = 0.83;
		pickaxe = 1;
		unarmed = 0.7;
		dagger = 0.75;
		bow = 1.5;
	};
	
	NPC_COMBAT_TIME = 30;
	KILL_CREDIT_PERIOD = 30; -- how long until ownership of a kill expires
	
	UNOWNED_ITEM_LIFETIME = 120; -- how long until an item not dropped by a player depsawns
	ITEM_LIFETIME = 300; -- how long until an item dropped by some player despawns
	DEATH_ITEM_LIFETIME = 3600; -- how long until an item dropped due to the death of a player despawns
	
	CRIT_MULTIPLIER = 2.75;
	DAMAGE_FUZZY = 0.1;
	
	UNLOADED_DIR = game:GetService("ServerStorage");
	
	MAX_SKILL_LEVEL = 100; -- maximum level that a skill can go up to
	MAX_OVERALL_LEVEL = 1000; -- maximum overall level that a player can get to
}

function table_deep_freeze(t: any)
	if typeof(t) ~= "table" then return end
	for _, v in t do
		table_deep_freeze(v)
	end
	table.freeze(t)
end
table_deep_freeze(Config)

return Config
