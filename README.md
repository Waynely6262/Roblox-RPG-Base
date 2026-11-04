# Eat to Be Powerful (E2BP)

Source code for **Eat to Be Powerful**, a Roblox combat/progression game by Waynely (`coocoocrazyhead`). Players fight through hand-built zones and procedurally generated **Underworld floors**, level up skills, collect and craft items, and rebirth for permanent progression.

This repository has all **444 scripts (~41k lines of Luau)** from the place, in a [Rojo](https://rojo.space) project layout. Each script lives at the same spot it had in Studio.

## Highlights

- **Package system with a custom loader.** Features ship as self-contained packages in `ServerScriptService/Root/Packages`. At startup a loader copies every component to the location written in its name, checks declared dependencies, and collects per-package config. See [docs/packages.md](docs/packages.md).
- **Procedural dungeon floors.** Underworld floors are 100×100 tile grids. Rooms are carved at random, then an A* "digging" agent (binary-heap open set, turning costs, random weights) tunnels corridors between them. Floors stream in and out as players arrive and leave. See [docs/world.md](docs/world.md).
- **Entity and combat framework.** A custom humanoid layer handles combat stats and modifiers, crits and damage variance, kill credit, status effects, knockback types and Bézier-driven moves. NPC AI comes in Hostile, Neutral, Guard and Passive loops, with archetypes such as Striker, Dasher, Dodger and Tanker.
- **Persistent player data** through ProfileService (session-locked), wrapped by the `DSPlayers` package. Covers inventory as JSON, skills and levelling, upgrades, rebirths/reincarnation, daily rewards, quests and settings.
- **Single-remote networking.** Client→server traffic goes through one `RemoteEvent` and one `RemoteFunction` (`MainE`/`MainF`). The first argument names the handler, and handler modules are discovered automatically.

## Repository layout

```
default.project.json        Rojo project: maps src/<Service> into the place
src/
  ServerScriptService/
    Root/
      init.server.luau      Server entry point: runs the package loader, then requires each top-level module
      _Root/                PackageLoader, VersionHistory, UploadLog
      Packages/             Source of truth for every package (see docs/packages.md)
      Players/ Tools/ ...   Deployed package components (identical copies, see "About the export")
      Other/                MovesAsync (combat moves), Teams, PhysicsProp, ...
  ReplicatedStorage/
    Client/                 Client root (Script with RunContext=Client): Backend, Graphics, UserInterface
    Modules/                Shared modules: Data tables, Game config/levelling, Inventory classes, Utility
    Remotes/                Ragdoll handler
  ServerStorage/            DataStore templates, disabled packages, maintenance scripts
  StarterPack/ StarterGui/ Workspace/ TestService/   Scripts attached to tools, UI and map objects
docs/                       Architecture notes
tools/                      Scripts used to export this repo from the .rbxl (re-runnable)
```

## Working on the code with Rojo (Windows)

The repo only contains **scripts**. Parts, meshes, UI layouts, terrain, sounds and so on stay in your `.rbxl`. Use Rojo to sync code **into your existing place**, not to build the game from scratch.

1. Install the **Rojo** extension in VS Code. It installs the Rojo CLI for you. In Studio, install the **Rojo** plugin from the Creator Store.
2. **Back up your place file first.** The first sync is the riskiest moment.
3. Open this folder in VS Code and run **Rojo: Open menu → Start server** for `default.project.json`. Or from PowerShell:
   ```powershell
   rojo serve default.project.json
   ```
4. Open your place in Studio and click **Connect** in the Rojo plugin. Edits to `.luau` files now show up in Studio live.

Every service, and every folder/script that also holds non-script instances, is marked `ignoreUnknownInstances`. So Rojo updates scripts but leaves the UI, remotes, values and models around them alone.

File naming: `Foo.server.luau` → Script, `Foo.client.luau` → LocalScript, `Foo.luau` → ModuleScript, and `Foo/init.*.luau` is a script that has children. `*.meta.json` files carry `Disabled`, `RunContext` and non-Folder class names.

## About the export

The repo was generated from the place file, and the round trip was checked: `rojo build` of this project gives the same script paths, classes, sources, `Disabled` flags and `RunContext` values as the original place.

- **Deployed copies.** The package loader also runs in Edit mode, so the saved place contains each package component twice: once in `Packages/` and once where it was deployed (e.g. `Root/Players/ProfileService`). Every pair that exists in both places has identical source. `Packages/` is the one to edit. The deployed copies are overwritten each time the loader runs.
- **UI template clones.** Five UI templates appear several times with identical scripts (e.g. `Rebirth.Main.RebirthFrame` ×13, `DailyRewards.GiftsHolder.Gift` ×9). Each is stored once here. A sync updates the first matching instance.
- **Renamed for Windows.** Three instances have `/` in their name, which can't be in a filename: `ServerStorage/Disabled Packages/CustomPlayerList/C/Graphics/PlayerList`, and `ReplicatedStorage/Modules/CameraShakeUtil` and `.../SpringModule` under `Workspace/CameraEffects`. They're stored with `_` in place of `/`.

## Third-party code

These are vendored in the place and keep their original authors and licenses:

| Library | Location | Author |
|---|---|---|
| ProfileService | `Root/Packages/DSPlayers/Server.Players/ProfileService` (+ deployed copy) | loleris / MadStudio |
| TopbarPlus v3.2.5 (bundles Janitor, GoodSignal) | `ReplicatedStorage/Client/Graphics/Util/TopBarPlusIcon` | ForeverHD (Janitor: howmanysmall; GoodSignal: stravant, MIT) |
| GoodSignal (typed fork) | `ReplicatedStorage/Modules/Utility/Signal` | stravant |
| Spring | `ReplicatedStorage/Modules/SpringModule` | not credited in source |
| Notifications UI | `Root/Packages/Notifications` | KTP UI Pack (author unknown) |
| `Animate` scripts | `Workspace/Rig`, `Workspace/Map/Rig`, NPC superclass | Roblox default character script |

Everything else is original work by Waynely.
