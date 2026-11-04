local PlayerInventories = require(game.ServerScriptService.Root.Players.PlayerInventories)
local template = {
	
	Inventory = PlayerInventories.EmptyInventoryJSON:: string;
	Instant = {
		Floor = "Tutorial";
		previous_session_health = nil;
	};
	
	ReplicatedVars = {
		abilities = {"whirlwind_lv_1"};
		
		effects = {}:: {[string]: number};
		
		levelling = {
			--overall = nil;
			--sword = nil;
			--hunting = nil;
			--exploration = nil;
			--armor = nil;
			--destruction = nil;
		};
		
		upgrades = {};
		
		essence = 0;
	};
	
	leaderstats = {
		Rebirths = 0;
	};
	
	Data = {
		QuestCompletedCounts = {
			Jumps = 0;
			Wins = 0;
			Distance = 0;
		};
		
		QuestBegin = {
			Jumps = 0;
			Wins = 0;
			Distance = 0;
		};
		
		DailyRewards = {
			NextClaimTime = 0;
			NextReward = 1;
		};
	};
	
	Preferences = {
		Music = 0.5;
		Sound = 1;
		CameraShake = true;
	};
	
	Statistics = {
		TimeSpentTotal = 0;
		
		TotalXP = 0;
		
		CashSpentTotal = 0;
		CashGainedTotal = 0;
		
		TotalQuestsCompleted = 0;
	}
	
}

return template