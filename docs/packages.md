# Packages

Every package here plugs into the [Package Loader Framework](https://github.com/Waynely6262/Roblox-Framework). Its docs cover component naming, the special `config` / `requirements` / `readme` files, the boot sequence and Edit-mode loading. This page covers what each package in this repo contains and how they depend on each other.

## Quick reference

A component's name is `<root>.<path>.<name>`:

| Prefix | Deploys under (live server) |
|---|---|
| `Server.` / `S.` / `s.` | `ServerScriptService.Root` |
| `Client.` / `C.` / `c.` | `ServerScriptService.Root.Client` (staged; released by DSClientRoot) |
| `ReplicatedStorage.` / `RS.` / `rs.` | `ReplicatedStorage` |

Once DSClientRoot releases the client root, client paths are `ReplicatedStorage.Client.…`, which is how all client code refers to them.

## Client packages

Client scripting is opt-in. The framework stages `C.` components but never runs them. **DSClientRoot** is the package that does:

1. `S.Client` is deployed to `Root.Client`. It's the client root script (RunContext = Client), so it does nothing while it sits in ServerScriptService.
2. Every `C.` component from every package merges into `Root.Client`, in whatever order packages load.
3. When the server runs, `S.ClientMover` requires `Root.Players` (DSPlayers), then moves `Root.Client` to `ReplicatedStorage`. Any copy already there from Edit-mode loading is merged in, and the fresh version wins.
4. On each player, the client root requires every top-level ModuleScript in `Client.Graphics`, `Client.Backend` and `Client`.

All 13 packages with `C.` components list `DSClientRoot` in `requirements`. Without it, the framework warns that client components were loaded but nothing will run them.

**Exceptions:** a few scripts run because of their own RunContext, not because something requires them. They work with or without DSClientRoot:

| Script | Package | RunContext |
|---|---|---|
| `RS.Remotes.Ragdoll/RagdollHandler` | Ragdoll | Client |
| `RS.Remotes.Ragdoll/RagdollHandler/RemoteEvent/RagdollServer` | Ragdoll | Server |
| `RS.Models.Entities/jeb_/rgb` | E2BP | Client (runs once the model is in Workspace) |
| `S.World/Canon/Village/…/Windmill/Mill/Script` | E2BP | Client (map prop) |
| `RS.Modules.Game/SyncedTimeUtil/getServerTime/Script` | E2BP | Server |
| `RS.Modules.Utility.FakePlayer/Script` | Utilities | Server |

## Catalogue

`Requires` comes from each package's `requirements` module. The lists were rebuilt by tracing every `require()` path to the package that deploys it, then merged with the lists that already existed.

| Package | Scripts | Requires | What it does |
|---|---|---|---|
| **BasePartEmission** | 5 | DSClientRoot, Easing | Client-side part emission effects (`PartEmit`), triggered from the server through Communications. |
| **CallbackLoading** | 1 | — | `Search`: builds handler tables by requiring every ModuleScript in a folder. Supports `onInvoke` and `_aliases`, and warns on duplicate identifiers. |
| **CameraShake** | 3 | — | `SpringModule` (lazily evaluated damped spring) and `CameraShakeUtil` (spring-driven camera impulses). |
| **Communications** | 5 | CallbackLoading, DSClientRoot | Single-remote networking. `MainE` (one-way) and `MainF` (two-way) dispatch on their first argument to handler modules under `RemoteReceivers`, on server and client. |
| **ControlsExtension** | 3 | DSClientRoot, UserInterface | Keybind hints and ContextActionService button text scaling. |
| **Crafting** | 7 | Communications, DSClientRoot, Inventory, InventoryMenus, Signal, UserInterface | Recipe-based crafting. Recipes live in `config` (e.g. Iron Sword = 20 Wood + 50 Iron). |
| **CustomPlayerList** | 4 | DSClientRoot, E2BP, UserInterface | Player list opened from a TopbarPlus "Leaderboard" icon. Uses E2BP's `vfx` module. |
| **CustomTools** | 12 | Communications, ControlsExtension, DSClientRoot, Signal, Utilities, ValueObjectVariables | Tool framework that doesn't use Roblox `Tool`s. Controllers implement server `_equip`/`_unequip` and client `input_began`/`input_ended`/`render_stepped`/`heartbeat`. Ships the `Default` and `_sprint` controllers. |
| **DSClientRoot** | 5 | DSPlayers | The client root and its release (see above). |
| **DSPlayers** | 10 | ValueObjectVariables | Session-locked player data on ProfileService. `config.Template` / `StudioTemplate` point at E2BP's `S.Data` templates. |
| **E2BP** | 193 | BasePartEmission, Communications, CustomTools, DSClientRoot, DSPlayers, Easing, Inventory, Notifications, ReplicatedVariables, RequiringUtilities, SeriesMath, Signal, UserInterface, Utilities, ValueObjectVariables | The game. See [world.md](world.md). |
| **Easing** | 5 | — | `EasingFunctions`, `Lerp`, `Tween`, `TweenCallback`, `TweenObject`. |
| **Inventory** | 20 | Communications, CustomTools, DSClientRoot, DSPlayers, Signal, UserInterface, ValueObjectVariables | Equipment (keyed slots), storage and hotbar containers, with `Item`/`Container`/`KeyContainer`/`Location` classes and an item `Catalog`. Saved as JSON. |
| **InventoryMenus** | 3 | DSClientRoot, Inventory, Signal, UserInterface | Utility-menu buttons in the inventory's interface frame. |
| **Notifications** | 4 | Communications, DSClientRoot, UserInterface | Server → client toast notifications, including the `Notifications` ScreenGui. |
| **Products** | 4 | E2BP, Utilities | Developer-product receipts (`ProcessReceipt`) plus `AssertGamepass` / `MemoGamepass`. Reads product IDs from E2BP's `Modules.Data.ProductIds`. |
| **Ragdoll** | 4 | — | Server-driven character ragdolls (see Exceptions above). |
| **RemapShiftLock** | 2 | DSClientRoot | Moves shift-lock to a different key. |
| **ReplicatedVariables** | 5 | Communications, DSClientRoot, DSPlayers, Signal | Per-player variables (`vars`) with `get`/`set`/`ghostSet`, mirrored to the client and saved under the profile key `ReplicatedVars`. |
| **RequiringUtilities** | 2 | — | `LazyRequire` (deferred require, for breaking cycles) and `SafeRequire`. |
| **SeriesMath** | 3 | — | Arithmetic, geometric and user-defined XP series with cumulative-sum caching. |
| **Signal** | 1 | — | Typed fork of stravant's GoodSignal. |
| **UserInterface** | 40 | DSClientRoot, Easing, Signal | Widget/window system (`UIAPI`, `Widget`, `Button`, `Hoverable`, `Slider`, …), UI helpers (`comma`, `numberAbbreviator`, `hhmmssFormat`, `GradientProgressBar`, …) and TopbarPlus. `config` lists the top-level menus. |
| **Utilities** | 16 | Signal | Game-independent helpers: `ConnectionHandler`, `Emit`, `FakePlayer`, `PartExtents`, `Pathfind`, `PlayerNameColor`, `ReplicationBuffer`, `RetryAsync`, `RunOnNextFrame`, `ThrottleRun`, `Welder`, `tostringTable`, plus server `UserDebounce`. |
| **ValueObjectVariables** | 5 | DSPlayers | `Finder`, `Giver` (lifetime statistics, which only ever increase), and `ProfileDataInstances`, which casts profile tables into Value objects such as `leaderstats`. |

### Reusable vs. game-specific

Most packages work without E2BP. Two don't yet:

- **Products** reads `ReplicatedStorage.Modules.Data.ProductIds`, which belongs to E2BP. Moving the IDs into `Products/config` would make it standalone.
- **CustomPlayerList** uses E2BP's `Client.Graphics.vfx` for button effects.

`DSPlayers` and `ValueObjectVariables` list each other because `Player` uses `Giver` and `Giver` reads `Profiles`. The loader only checks that both are present, so the cycle is harmless.

## Adding a package

1. Create `src/Packages/<Name>/`.
2. Add components with prefixed names, e.g. `S.MyFeature.luau` or `C.Graphics.MyWidget.luau`.
3. Add `requirements.luau` listing the packages it uses, including `DSClientRoot` if it has `C.` components. Optionally add a `config.luau` and a `readme`.
4. Press Play. The loader prints overwrites, source conflicts and missing dependencies.
