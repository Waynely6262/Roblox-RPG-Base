--!strict

local Cards = {
	
	default = {
		prerequisite = nil,
		incompatibilities = nil,
		
		essence = 10,
		displayName = "Kinetic Blast",
		group = "kineticEnergy",
		description = "Create a blast of energy",
		rarity = "Uncommon",
		
		
		cooldown = .5,
		
	},
	
	fireball = {

		essence = 50,
		displayName = "Fire Ball",
		group = "fireEnergy",
		description = "Harnesses magic to draw a ball of fire. Thrown as a projectile.",
		rarity = "Rare",
		
		
		image = "rbxassetid://107996099141983",
		
		cooldown = .8,

	},
	
	pulsar = {

		essence = 50,
		displayName = "Pulsar",
		group = "kineticEnergy",
		description = "Harnesses magic to periodically generate impulses of energy, while following a linear path.",
		rarity = "Mythic",
		

		image = nil,

		cooldown = 8,

	},
	
	moonfang = {
		
		essence = 100, 
		displayName = "Moon Fang",
		group = "planeLocked",
		description = "Casts a fang that deals splitting damage to anything in its path.",
		rarity = "Legendary",
		
		
		cooldown = 3,
	},
	
	blackhole = {
		
		essence = 100,
		
		displayName = "Black Hole",
		group = "darkEnergy",
		description = "Harnesses dark energy to build a powerful vacuum of destruction.",
		rarity = "Divine",
		
		
		cooldown = 30,
	},
	
	fireExpl = {
		
		essence = 100,

		displayName = "Fire Isolation",
		group = "fireEnergy",
		description = "Harnesses fire magic to set fire around the user.",
		rarity = "Rare",
		

		image = "rbxassetid://13858394766",

		cooldown = 7,

	},
	
	whirlwind = {

		essence = {5,50,200},

		displayName = "Whirlwind",
		group = "generalAOE",
		description = "Strikes everything within a radius around the user.",
		rarity = "Rare",


		image = "rbxassetid://13858394766",

		cooldown = 1.5,

	},
	
	shell = {
		
		displayName = "Shell",
		
		essence = 50,
		
		group = "immunity",
		description = "Creates a temporary shield to protect the user.",
		rarity = "Legendary",
		
		
		cooldown = 60,
		
		image = "rbxassetid://16494644978"
	},
	
	dash = {
		prerequisite = nil,
		incompatibilities = nil,
		
		essence = 5,
		
		displayName = "Dash",
		group = "dash",
		description = "Quickly move forward, dealing damage to anything in your path",
		rarity = "Uncommon",
		
		image = "rbxassetid://17780574525",

		cooldown = 1,
	},
	
	leap = {
		prerequisite = nil,
		incompatibilities = nil,
		
		essence = 25,
		
		displayName = "Leap",
		group = "dash",
		description = "Thrust upward, dealing damage to anything in your vicinity",
		rarity = "Rare",
		
		image = "rbxassetid://17780574525",
		
		cooldown = 1,
	},
	
	reign = {
		
		essence = 200,
		
		displayName = "Divine Strike",
		group = "largeExp",
		description = "Cast a beam of energy from the sky above, dealing massive focused damage",
		rarity = "Divine",
		
		image = "rbxassetid://105125243041334",
		
		cooldown = 16,
	},
	
	beam = {
	
		essence = 30,

		displayName = "Beam",
		group = "largeExp",
		description = "Cast a beam of directed energy",
		rarity = "Epic",
		
		image = "rbxassetid://105125243041334",

		cooldown = 2,
	},
	
	healrain = {
		
		essence = 50,

		displayName = "Healing Rain",
		group = "largeHeal",
		description = "Heal everything around you",
		rarity = "Epic",
		
		image = "rbxassetid://105125243041334",

		cooldown = 20,
	},
	
	frostbite = {
		essence = 100,

		displayName = "Frostbite",
		group = "freezer",
		description = "Crystallize the air to freeze any enemies in front of you",
		rarity = "Epic",
		image = "rbxassetid://105125243041334",

		cooldown = 0,
	},
	
}

setmetatable(Cards, {
	__index = function(self, k)
		return {
			essence = 0,
			group = "unregistered",
			description = `{k} (no information available)`,
			displayName = string.split(k, "")[1]:upper()..string.sub(k, 2),
		rarity = "Common",
			image = "rbxassetid://16494644978",
			
			cooldown = 0.1,
		}
	end
})


Cards.blast = Cards.default
return Cards:: typeof(Cards) & {
	[string]: {

		displayName: string,
		group: string,
		description: string,
		rarity: string,
		image: string?,

		cooldown: number?
		--server_func: (player: Player) -> (),
	}
}