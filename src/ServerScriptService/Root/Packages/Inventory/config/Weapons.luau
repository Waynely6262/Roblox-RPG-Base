local Weapons = {

	-- Swords
	
	["Wooden Sword"] = {
		limits = { stack = 1 },
		weight = 180,
		stats = {
			Damage = 10,
			AttackSpeed = 0.5,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "sword",
	},
	
	["Iron Sword"] = {
		limits = { stack = 1 },
		weight = 180,
		stats = {
			Damage = 10,
			AttackSpeed = 0.5,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "sword",
	},
	["Titanium Sword"] = {
		limits = { stack = 1 },
		weight = 220,
		stats = {
			Damage = 14,
			AttackSpeed = 0.5,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "sword",
	},
	["Divine Sword"] = {
		limits = { stack = 1 },
		weight = 200,
		stats = {
			Damage = 18,
			AttackSpeed = 0.5,   -- slightly faster
		},
		lv_stats = {
			Damage = 1,
		},
		type = "sword",
	},

	-- Axes
	["Cool Oak Axe"] = {
		limits = { stack = 1 },
		weight = 280,
		stats = {
			Damage = 13,
			AttackSpeed = 0.25,   -- slower than sword
		},
		lv_stats = {
			Damage = 1,
		},
		type = "axe",
		chop_mul = 1.5;
	},
	["Realm Protector Axe"] = {
		limits = { stack = 1 },
		weight = 320,
		stats = {
			Damage = 18,
			AttackSpeed = 0.25,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "axe",
		chop_mul = 1.5;
	},
	["Pharaoh's Axe"] = {
		limits = { stack = 1 },
		weight = 310,
		stats = {
			Damage = 20,
			AttackSpeed = 0.25,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "axe",
		chop_mul = 1.5;
	},
	["Kraken Slayer"] = {
		limits = { stack = 1 },
		weight = 340,
		stats = {
			Damage = 24,
			AttackSpeed = 0.25,
			Piercing = 70,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "axe",
		chop_mul = 1.5;
	},
	["Dragon Slayer"] = {
		limits = { stack = 1 },
		weight = 360,
		stats = {
			Damage = 28,
			AttackSpeed = 0.25,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "axe",
		chop_mul = 1.5;
	},
	["Dragon Scythe"] = {
		limits = { stack = 1 },
		weight = 380,
		stats = {
			Damage = 30,
			AttackSpeed = 0.5,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "sword",
	},

	-- Bows
	["Assassin's Bow"] = {
		limits = { stack = 1 },
		weight = 140,
		stats = {
			Damage = 12,
			Precision = 6;
			AttackSpeed = 1,   -- fast attack/reload
		},
		lv_stats = {
			Damage = 1,
		},
		type = "bow",
	},
	["Prowler's Shot"] = {
		limits = { stack = 1 },
		weight = 150,
		stats = {
			Damage = 13,
			Precision = 3;
			AttackSpeed = 1,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "bow",
	},
	["Fireslinger"] = {
		limits = { stack = 1 },
		weight = 160,
		stats = {
			Damage = 15,
			Precision = 5;
			AttackSpeed = 1,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "bow",
	},
	["Realm Protector Bow"] = {
		limits = { stack = 1 },
		weight = 170,
		stats = {
			Damage = 18,
			Precision = 5;
			AttackSpeed = 1,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "bow",
	},
	["Divine Bow"] = {
		limits = { stack = 1 },
		weight = 160,
		stats = {
			Damage = 20,
			Precision = 5;
			AttackSpeed = 1,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "bow",
	},
	["Dragon Bow"] = {
		limits = { stack = 1 },
		weight = 180,
		stats = {
			Damage = 24,
			Precision = 5;
			AttackSpeed = 1,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "bow",
	},

	-- Daggers
	["Cool Dagger"] = {
		limits = { stack = 1 },
		weight = 80,
		stats = {
			Damage = 8,
			AttackSpeed = 0.75,   -- very fast
		},
		lv_stats = {
			Damage = 1,
		},
		type = "dagger",
	},
	["Bone Dagger"] = {
		limits = { stack = 1 },
		weight = 90,
		stats = {
			Damage = 9,
			AttackSpeed = 0.75,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "dagger",
	},
	["Ancient Dagger"] = {
		limits = { stack = 1 },
		weight = 100,
		stats = {
			Damage = 11,
			AttackSpeed = 0.75,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "dagger",
	},
	["Dragon's Dagger"] = {
		limits = { stack = 1 },
		weight = 110,
		stats = {
			Damage = 16,
			AttackSpeed = 0.75,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "dagger",
	},
	["Gates of Heaven"] = {   -- assuming this is the special dagger
		limits = { stack = 1 },
		weight = 120,
		stats = {
			Damage = 20,
			AttackSpeed = 0.75,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "dagger",
	},

	-- Greatswords
	["King's Greatsword"] = {
		limits = { stack = 1 },
		weight = 450,
		stats = {
			Damage = 26,
			AttackSpeed = -0.4,   -- very slow
		},
		lv_stats = {
			Damage = 1,
		},
		type = "greatsword",
	},
	["Yeti Greatsword"] = {
		limits = { stack = 1 },
		weight = 480,
		stats = {
			Damage = 28,
			AttackSpeed = -0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "greatsword",
	},
	["Necromancer's Greatsword"] = {
		limits = { stack = 1 },
		weight = 460,
		stats = {
			Damage = 30,
			AttackSpeed = -0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "greatsword",
	},
	["Pyro's Greatsword"] = {
		limits = { stack = 1 },
		weight = 470,
		stats = {
			Damage = 32,
			AttackSpeed = -0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "greatsword",
	},
	["Greatsword of Thunder"] = {
		limits = { stack = 1 },
		weight = 500,
		stats = {
			Damage = 34,
			AttackSpeed = -0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "greatsword",
	},
	["Greatsword of Darkness"] = {
		limits = { stack = 1 },
		weight = 500,
		stats = {
			Damage = 36,
			AttackSpeed = -0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "greatsword",
	},
	
	["Wooden Pickaxe"] = {
		limits = { stack = 1 },
		weight = 80,
		stats = {
			Damage = 3,
			AttackSpeed = 0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "pickaxe",
		mine_mul = 1.25,
	},
	
	["Stone Pickaxe"] = {
		limits = { stack = 1 },
		weight = 150,
		stats = {
			Damage = 5,
			AttackSpeed = 0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "pickaxe",
		mine_mul = 1.5,
	},
	
	["Iron Pickaxe"] = {
		limits = { stack = 1 },
		weight = 270,
		stats = {
			Damage = 8,
			AttackSpeed = 0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "pickaxe",
		mine_mul = 1.6,
	},
	
	["Titanium Pickaxe"] = {
		limits = { stack = 1 },
		weight = 350,
		stats = {
			Damage = 14,
			AttackSpeed = 0.4,
		},
		lv_stats = {
			Damage = 1,
		},
		type = "pickaxe",
		mine_mul = 2,
	},
	
}

--for name, data in Weapons do
--	data.ctrlr = "Weapon"
--end

return Weapons