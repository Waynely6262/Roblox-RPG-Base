upgrades = {
	{
		name = "Combat Drills",
		benefit_per_rank = "+1 damage",
		total_ranks = 10,
		max_benefit = "+10 damage",
		ranks = {
			50,    -- Rank I
			250,   -- II
			825,   -- III
			2400,  -- IV
			6200,  -- V
			16000, -- VI
			41000, -- VII
			102000,-- VIII
			254000,-- IX
			636000 -- X
		}
	},
	{
		name = "Defender",
		benefit_per_rank = "+1 defense",
		total_ranks = 10,
		max_benefit = "+10 defense",
		ranks = {
			50,    -- I
			250,   -- II
			825,   -- III
			2400,  -- IV
			6200,  -- V
			16000, -- VI
			41000, -- VII
			102000,-- VIII
			254000,-- IX
			636000 -- X
		}
	},
	{
		name = "Pack Rat",
		benefit_per_rank = "+250 carry weight",
		total_ranks = "Undetermined (continues past 30)",
		max_benefit = "Undetermined",
		ranks = {
			20,     -- I
			50,     -- II
			80,     -- III
			125,    -- IV
			200,    -- V
			275,    -- VI
			400,    -- VII
			575,    -- VIII
			850,    -- IX
			1300,   -- X
			1900,   -- XI
			2700,   -- XII
			4100,   -- XIII
			6000,   -- XIV
			8900,   -- XV
			14000,  -- XVI
			20000,  -- XVII
			30000,  -- XVIII
			45000,  -- XIX
			67000,  -- XX
			100000, -- XXI
			150000, -- XXII
			225000, -- XXIII
			337000, -- XXIV
			506000, -- XXV
			758000, -- XXVI
			1137000,-- XXVII
			1705000,-- XXVIII
			2557000,-- XXIX
			3836000,-- XXX
			5753000,-- XXXI
			8630000,-- XXXII
			12944000,-- XXXIII
			19416000,-- XXXIV
			29123000,-- XXXV
			43684000,-- XXXVI
			65526000,-- XXXVII
			98288000,-- XXXVIII
			-- Higher ranks exist but incomplete in source
		}
	},
	{
		name = "Scholar",
		benefit_per_rank = "+20% experience bonus",
		total_ranks = 30,
		max_benefit = "+600% experience bonus",
		ranks = {
			50,    -- I
			125,   -- II
			175,   -- III
			250,   -- IV
			325,   -- V
			425,   -- VI
			550,   -- VII
			700,   -- VIII
			900,   -- IX
			1200,  -- X
			1500,  -- XI
			1900,  -- XII (partial alignment; table shifts)
			2500,  -- XIII
			3200,  -- XIV
			4200,  -- XV
			5500,  -- XVI
			7300,  -- XVII
			9700,  -- XVIII
			13000, -- XIX
			18000, -- XX
			23000, -- XXI
			31000, -- XXII
			42000, -- XXIII
			56000, -- XXIV
			75000, -- XXV
			101000,-- XXVI
			136000,-- XXVII
			184000,-- XXVIII
			247000,-- XXIX
			333000 -- XXX (note: source has some column shifts; costs aligned to Scholar column where possible)
		}
	},
	{
		name = "Vitality",
		benefit_per_rank = "+25 Hit Points",
		total_ranks = "Undetermined (continues past 30)",
		max_benefit = "Undetermined",
		ranks = {
			10,     -- I
			40,     -- II
			100,    -- III
			200,    -- IV
			350,    -- V
			550,    -- VI
			850,    -- VII
			1300,   -- VIII
			1900,   -- IX
			2700,   -- X
			3800,   -- XI
			5300,   -- XII
			7300,   -- XIII
			11000,  -- XIV
			14000,  -- XV
			19000,  -- XVI
			26000,  -- XVII
			36000,  -- XVIII
			48000,  -- XIX
			65000,  -- XX
			88000,  -- XXI
			120000, -- XXII
			162000, -- XXIII
			218000, -- XXIV
			295000, -- XXV
			399000, -- XXVI
			538000, -- XXVII
			727000, -- XXVIII
			982000, -- XXIX
			1326000,-- XXX
			1790000,-- XXXI
			2417000,-- XXXII
			3264000,-- XXXIII
			4407000,-- XXXIV
			5949000,-- XXXV
			8032000,-- XXXVI
			10844000,-- XXXVII
			14640000,-- XXXVIII
			19764000,-- XXXIX
			-- Higher incomplete
		}
	},
	-- Additional upgrades follow the same pattern (abbreviated for brevity; full costs in source table):
	{
		name = "Sage Wisdom",
		benefit_per_rank = "+10% myst bonus",
		total_ranks = 20,
		max_benefit = "+200% myst bonus",
		ranks = {10, 50, 125, 250, 475, 800, 1400, 2200, 3400, 5300, 8200, 13000, 19000, 29000, 44000, 65000, 98000, 146000, 221000, 332000}  -- Up to XX; higher not listed
	},
	{
		name = "Savagery",
		benefit_per_rank = "+1% crit chance",
		total_ranks = 20,
		max_benefit = "+20% crit chance",
		ranks = {60, 175, 375, 725, 1300, 2300, 4100, 7000, 12000, 21000, 35000, 60000, 101000, 172000, 292000, 497000, 844000, 1435000, 2440000, 4147000}
	},
	{
		name = "Skill Mastery",
		benefit_per_rank = "Unlocks next 10-level skill tier",
		total_ranks = 9,
		max_benefit = "All skills to 100",
		ranks = {100, 1200, 4300, 12000, 27000, 58000, 121000, 248000, 503000}
	},
	{
		name = "Moving Target",
		benefit_per_rank = "+4% dodge chance",
		total_ranks = 15,
		max_benefit = "+60% dodge chance",
		ranks = {20, 50, 70, 125, 200, 350, 675, 1600, 3600, 8700, 22000, 54000, 133000, 332000, 829000}  -- Aligned from columns
	},
	{
		name = "Precision",
		benefit_per_rank = "+4% hit chance",
		total_ranks = 15,
		max_benefit = "+60% hit chance",
		ranks = {20, 50, 70, 125, 200, 350, 675, 1600, 3600, 8700, 22000, 54000, 133000, 332000, 829000}
	},
	{
		name = "Ascension",
		benefit_per_rank = "+5 to character level cap",
		total_ranks = "Undetermined",
		max_benefit = "Undetermined",
		ranks = {10000, 25000, 46000, 73000, 106000, 146000, 195000, 252000, 319000, 397000, 487000, 590000, 707000, 838000, 1000000, 1158000, 1348000, 1560000, 1798000, 2064000, 2361000, 2700000, 3071000, 3478000, 3927000, 4420000, 4957000, 5542000, 6179000, 6868000, 7612000, 8414000, 9700000, 10914000, 11190000, 12246000, 13372000, 14570000}  -- Many estimated (* in source)
	},
	{
		name = "Lasting Legacy",
		benefit_per_rank = "+10% myst refund at Reincarnation",
		total_ranks = 7,
		max_benefit = "70% refund",
		ranks = {500, 6000, 27000, 92000, 293000, 898000, 2719000}
	},
	{
		name = "Academic",
		benefit_per_rank = "+1 Ability slot",
		total_ranks = 5,
		max_benefit = "6 total ability slots",
		ranks = {100, 1200, 13000, 124000, 1235000}
	}
}