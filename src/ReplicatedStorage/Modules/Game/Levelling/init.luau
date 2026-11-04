local CONFIG = require(game.ReplicatedStorage.Modules.Game.Config)
local GeoSeries = require(game.ReplicatedStorage.Modules.Utility.GeometricSeries)
local ArithSeries = require(game.ReplicatedStorage.Modules.Utility.ArithmeticSeries)
local ManualSeries = require(game.ReplicatedStorage.Modules.Utility.UserDefinedSeries)

local OverallLevelCalculator = ArithSeries.new(1, 200, 400, 0)

local seq1 = ManualSeries.new(0, {
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
})

local seq2 = ManualSeries.new(0, {20, 50, 70, 125, 200, 350, 675, 1600, 3600, 8700, 22000, 54000, 133000, 332000, 829000})


local Upgrades = {

	["Essence Collector"] = ManualSeries.new(0, {10, 50, 125, 250, 475, 800, 1400, 2200, 3400, 5300, 8200, 13000, 19000, 29000, 44000, 65000, 98000, 146000, 221000, 332000});
	["Scholar"] = ManualSeries.new(0, {50,125,175,250,325,425,550,700,900,1200,1500,1900,2500,3200,4200,5500,7300,9700,13000,18000,23000,31000,42000,56000,75000,101000,136000,184000,247000,333000});

	["Attacker"] = seq1;
	["Defender"] = seq1;

	["Precision"] = seq2;
	["Moving Target"] = seq2;

	["Ascension"] = GeoSeries.new(0, 10000, 1.4, 100);
	["Skill Mastery"] = ManualSeries.new(0, {100, 1200, 4300, 12000, 27000, 58000, 121000, 248000, 503000});

	["Lasting Legacy"] = ManualSeries.new(0, {500, 6000, 27000, 92000, 293000, 898000, 2719000});
	["Academic"] = ManualSeries.new(0, {100, 1200, 13000, 124000, 1235000});

	["Critical"] = ManualSeries.new(0, {60, 175, 375, 725, 1300, 2300, 4100, 7000, 12000, 21000, 35000, 60000, 101000, 172000, 292000, 497000, 844000, 1435000, 2440000, 4147000});
	["Vitality"] = ManualSeries.new(0, {10,40,100,200,350,550,850,1300,1900,2700,3800,5300,7300,11000,14000,19000,26000,36000,48000,65000,88000,120000,162000,218000,295000,399000,538000,727000,982000,1326000,1790000,2417000,3264000,4407000,5949000,8032000,10844000,14640000,19764000});

};

return {
	Upgrades = Upgrades;
	Levels = OverallLevelCalculator;
}