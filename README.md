# Roblox RPG Base

The packages behind **Eat to Be Powerful (E2BP)**, a Roblox combat and progression RPG by Waynely (`coocoocrazyhead`). They're built for the [Package Loader Framework](https://github.com/Waynely6262/Roblox-Framework).

Every loaded script in the game lives in one of the **26 packages** in `src/Packages` (363 scripts). There are reusable systems (data saving, networking, inventory, custom tools, UI) and one game package, `E2BP`, that builds the RPG on top of them.

## How it fits together

```
ServerScriptService
└── Root                     ← framework (Roblox-Framework repo)
    ├── _Root/PackageLoader
    └── Packages             ← this repo (src/Packages)
        ├── DSPlayers/
        │   ├── Server.Players          → deploys to Root.Players
        │   ├── config
        │   └── requirements
        ├── DSClientRoot/
        │   ├── S.Client                → the client root script
        │   └── S.ClientMover           → releases it to players
        └── E2BP/ ...
```

Each package is a folder of **components**. A component's name says where it deploys: `S.Players.Skills` goes to `Root.Players.Skills`, `C.Graphics.Health` goes into the client root, and `RS.Modules.Data` goes to `ReplicatedStorage.Modules.Data`. When the server starts, the framework moves every component into place, then requires each top-level module under `Root`.

**Client code is opt-in.** The framework only *stages* client components. They reach players when the `DSClientRoot` package is installed. It supplies the client root script and releases it once player data has loaded. Every package that ships client components lists `DSClientRoot` in its `requirements`, so a missing client package shows up as a warning instead of silently doing nothing.

## Packages at a glance

| Layer | Packages |
|---|---|
| Foundations | Signal, Easing, SeriesMath, RequiringUtilities, CallbackLoading, Utilities |
| Players & data | DSPlayers, ValueObjectVariables, ReplicatedVariables |
| Client & networking | DSClientRoot, Communications |
| Interface | UserInterface, ControlsExtension, Notifications, CustomPlayerList, RemapShiftLock |
| Gameplay systems | CustomTools, Inventory, InventoryMenus, Crafting, Products, BasePartEmission, CameraShake, Ragdoll |
| Game | **E2BP**: world generation, entities and AI, combat, progression, game UI |

The full catalogue, with every package's components and dependencies, is in [docs/packages.md](docs/packages.md). How the game works is in [docs/world.md](docs/world.md).

## Using the packages

1. Install the framework from [Roblox-Framework](https://github.com/Waynely6262/Roblox-Framework) as `ServerScriptService.Root`.
2. Put the package folders you want under `Root.Packages`. Include everything listed in each package's `requirements`, plus `DSClientRoot` if any package has client components.
3. Press Play. The Output lists missing dependencies and any components that overwrote each other.

To sync with Rojo, `default.project.json` maps `src/Packages` to `ServerScriptService.Root.Packages`. Every node is set to `ignoreUnknownInstances`, so Rojo updates scripts without deleting the UI, models and remotes stored alongside them. Back up your place before the first sync.

## Migrating the existing place

The game's place file still has scripts outside packages and deployed copies saved from Edit mode. [`migration/Migrate.luau`](migration/Migrate.luau) restructures a place to match this repo. See [docs/migration.md](docs/migration.md) for what it changes and how to run it.

## Third-party code

| Library | Package | Author |
|---|---|---|
| ProfileService | DSPlayers | loleris / MadStudio |
| TopbarPlus v3.2.5 (bundles Janitor, GoodSignal) | UserInterface | ForeverHD (Janitor: howmanysmall; GoodSignal: stravant, MIT) |
| GoodSignal (typed fork) | Signal | stravant |
| Spring | CameraShake | not credited in source |
| Notifications UI | Notifications | KTP UI Pack (author unknown) |
| `Animate` (NPC superclass) | E2BP | Roblox default character script |

Everything else is original work by Waynely. Licensed under MIT (see [LICENSE](LICENSE)). The third-party code keeps its own licenses.
