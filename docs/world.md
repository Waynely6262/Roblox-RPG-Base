# World, floors and entities

Everything here is in the `E2BP` package (`src/Packages/E2BP`). Paths below are component paths inside that folder. The world code is `S.World`, which deploys to `ServerScriptService.Root.World`. Tunable constants are in `RS.Modules.Game/Config.luau`.

## Floors

Every location is a `Floor` (`S.World/Floor`): a `FLOOR_SIZE × FLOOR_SIZE` grid (100×100) of `Cell`s, each `TILE_SIZE` (8) studs wide. A cell's `Content` is `nil` (open), `"WALL"`, or a tag for whatever occupies it (`t.e-<mob>`, `t.s-<structure>`).

Each floor gets a world origin from a **square spiral** over its number (`SpiralCoordinate`), spaced `LOCATION_SPACING` (2048) studs apart. Floors therefore never overlap, and new ones are placed outward from the centre.

There are two kinds of floor:

- **Canon floors** (`S.World/Canon`): hand-built zones such as Tutorial, Village, Forest, Cave, Crossroads, Memorial, Mountain Range, Castle (North) and Sandbox. Each module sets up its map and spawners. Some can be loaded from a serialized string (`Floor.fromString`).
- **Underworld floors** (`S.World/UnderworldFloor`): generated when first requested by number. They're offset by a partition buffer of 128 so they don't collide with canon slots.

### Underworld generation

1. **Rooms.** Fill the grid with walls. Make up to 2000 attempts at random rectangles (3 to 20 tiles per side) and carve each one whose area is still entirely wall, up to `MAX_ROOMS` (200). Record each room's centre.
2. **Corridors.** A `PathingAgent` starts in the last room and runs **A\*** (binary-heap open set, `PathingAgent/BinaryHeap`) to each room centre, carving the path it takes. Turning cost (0.5) and a randomly ignored weight (50%) make corridors wander instead of running straight.
3. **Dead ends.** It tunnels to 10–30 additional random cells.
4. **Walls.** Each remaining wall cell becomes a textured part with a humanoid attached, so walls are destructible entities. Wall HP is rolled between 10 and the floor's internal number, so deeper walls are tougher.

Steps 2–4 run in a `task.defer` and yield between tunnels, so generating a floor doesn't stall the server. The wall colour and texture rotate through `Themes` by floor number.

## Simulation loop (`S.World/init.luau`)

A single `Heartbeat` loop:

- tracks which floor each player is on;
- **unloads** floors that have no players;
- calls `TickUpdate` on every occupied floor every `SPAWN_PERIOD / √floorNumber` seconds, so deeper floors spawn faster.

`TickUpdate` fills each `Spawner` region up to its cap at open cells. Mobs and structures free their cell and spawner slot when they die or are destroyed. Underworld floors also get a **Hole** (`TickUpdate/Hole`) that teleports players who touch it to the next floor.

`teleportPlayer(player, floor, x?, y?)` loads the target floor if needed, anchors the character, shows a loading message on the client, and places the player at the floor's spawn cell or a random open one.

## Spawning and randomness

- `RNGRoller` is a weighted random table that uses cumulative weights.
- `SpawnerDrawFunctions` defines what each spawner can roll: ores, cave/forest mobs, villagers, guards, trees, bushes and Underworld structures.
- **Underworld mob difficulty:** a window of up to 10 mob tiers is weighted by `(x² − x + 1.25)^−15`, which peaks sharply in the middle of the window. The window's start is meant to slide up with floor difficulty. The tier list currently has 8 placeholder entries (`A`–`H`), all of which fit in the window, so the window doesn't move yet. Adding more tiers turns the sliding on.

## Entities and AI

- `Entities` (`S.World/Entities`) is the custom humanoid layer used by players, mobs, walls and props. It covers combat stats and modifiers (`CombatStats`, `CombatStatsModifier`, `SpecialStats`), death and kill credit (expires after `KILL_CREDIT_PERIOD`), status effects, item drops, and replication to the client.
- `EntityGenManager` creates mobs, structures, items and despawnables for a floor.
- NPC archetypes (`EntityGenManager/NPC`) are **Striker, Dasher, Dodger, Tanker and Super Death**. They're built on a shared `Superclass` that handles state, attacking, line of sight (`Looker`) and animation.
- Behaviour loops (`NPCCoreLoop`):
  - **Hostile**: attacks when it finds a target.
  - **Neutral**: fights back when attacked.
  - **Guard**: defends and marks attackers as *infamous*, keeping them targeted for `NPC_COMBAT_TIME`.
  - **Passive**: never fights.

## Combat

Combat moves live in `S.Other/MovesAsync`. They use spatial queries and casts (`SpatialQuery`, `CastUtil`), Bézier movement (`BezierParams`), and damage and heal packets. Weapon behaviour is under `S.Tools.Weapon` (with client counterparts in `C.Backend.RemoteReceivers.Tool.*`), with hit shapes `SweepArc`, `FrontalCone`, `ForwardThrust` and `Projectile`. Reach and swing cooldown are set per weapon type in `Config`. Crits multiply damage by 2.75, and every hit varies by ±10% (`DAMAGE_FUZZY`).

## Progression

- **Levelling** (`RS.Modules.Game/Levelling`) uses the `SeriesMath` XP curves. Skills cap at `MAX_SKILL_LEVEL` and overall level at `MAX_OVERALL_LEVEL`.
- **Level caps** (`S.MaxLevel`): max level is `60 + 5·ascensions + reincarnations`, and max skill level is `10·(level + 1)`.
- **Rebirths, reincarnation and upgrades** reset or reconcile profile data from the save template in `S.Data/DSTemplate`, which DSPlayers also uses through its config. Upgrades apply stat modifiers when the character spawns (`Server.Players.Player.Character/OnSpawn/HumanoidAffectorUpgrades`).
