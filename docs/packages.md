# Package system

All gameplay code is organised into **packages**: folders under `src/ServerScriptService/Root/Packages/`. A package holds **components**, each named after where it should be deployed, and the loader in `Root/_Root/PackageLoader.luau` moves each one there when the server starts. In Studio it also runs in Edit mode, which makes type-checking and autocomplete work across packages.

## Component naming

A component's name is a dot-separated path. The first segment is a root alias and the last segment is the final instance name:

| Prefix | Deploys under |
|---|---|
| `Server.` / `S.` / `s.` | `ServerScriptService.Root` |
| `Client.` / `C.` / `c.` | the client root (`ReplicatedStorage.Client`) |
| `ReplicatedStorage.` / `RS.` / `rs.` | `ReplicatedStorage` |

For example, `Inventory/Server.Players.PlayerInventories` deploys to `ServerScriptService.Root.Players.PlayerInventories`. Missing intermediate folders are created. If something already exists at the destination, the two are merged: the incoming component's children win, and a warning is logged when two scripts with the same name have different source.

### Special components

| Name | Behaviour |
|---|---|
| `requirements` | Returns a list of package names this package depends on. Missing ones are reported after loading. |
| `config` | Copied to `ReplicatedStorage.Modules.PackageConfig.<PackageName>`. Read it with `require(game.ReplicatedStorage.Modules.PackageConfig.<PackageName>)`. |
| `readme` | Notes for developers (a disabled Script). Ignored by the loader. |
| `Packages` (Folder) | Nested packages, loaded recursively. |

## Boot sequence (`Root/init.server.luau`)

1. Print the loader version (from `_Root/VersionHistory`).
2. `LoadPackage` for every child of `Packages`, then `AssertRequirements`.
3. At runtime only: move the client root into `ReplicatedStorage`, require `Root.Players` first, then require every other top-level ModuleScript under `Root` in its own thread. Failures are caught and logged without stopping the rest.

## Packages

| Package | Depends on | What it does |
|---|---|---|
| **E2BP** | — | The game itself: world/floor generation, entities and NPC AI, level caps, character spawn modifiers, collision groups, and the gameplay remote handlers (attack, rebirth, daily rewards, quests, upgrades, settings, developer tools). See [world.md](world.md). |
| **DSPlayers** | — | Player loading on top of ProfileService. Session-locked profiles, a data template from `ServerStorage.DSTemplate` (with a separate Studio template), and an `Initialize` folder of per-player init components. |
| **DSClientRoot** | DSPlayers | Client bootstrap. Once `Players` has loaded, merges the client root into `ReplicatedStorage`. Its `Client` script (RunContext=Client) then requires the client modules on each player. |
| **Communications** | — | Single-remote networking. `MainE` (one-way) and `MainF` (two-way) dispatch on their first argument to handler modules under `RemoteReceivers`, on both server and client. |
| **CallbackLoading** | — | `Search`: builds those handler tables by requiring every ModuleScript in a folder. Supports `onInvoke` and `_aliases`, and warns on duplicate identifiers. |
| **ReplicatedVariables** | Communications, DSPlayers | Per-player variable store (`vars`) on the server with `get`/`set`/`ghostSet`, mirrored to the client and saved under the profile key `ReplicatedVars`. |
| **ValueObjectVariables** | — | `Finder` and `Giver`: helpers for Value-object data and lifetime statistics, which only ever increase. |
| **Inventory** | UserInterface, Communications, CustomTools | Equipment (keyed slots), storage and hotbar containers, plus `Item`/`Container`/`KeyContainer`/`Location` classes and an item `Catalog`. Saved to the profile as JSON. Has its own UI. |
| **InventoryMenus** | Inventory | Utility-menu buttons in the inventory's interface frame. |
| **Crafting** | Inventory, InventoryMenus | Recipe-based crafting. Recipes live in `Crafting/config` (e.g. Iron Sword = 20 Wood + 50 Iron). |
| **CustomTools** | Communications | Tool framework that doesn't use Roblox `Tool`s. Controllers implement server `_equip`/`_unequip` and client `input_began`/`input_ended`/`render_stepped`/`heartbeat`. Includes grip-joint welding and a built-in sprint controller. |
| **UserInterface** | Easing, Signal | Widget/window system (`UIAPI`, `Widget`, `Button`, `Hoverable`, `Slider`, `TransparencyAPI`, `MouseLock`, …). `config` lists the top-level menus: Shop, Settings, Daily Rewards, Quests, Rebirth, … |
| **ControlsExtension** | UserInterface | Keybind display and ContextActionService button text scaling. |
| **Notifications** | UserInterface, Communications | Server → client toast notifications. UI from the KTP UI Pack. |
| **BasePartEmission** | (readme: Easing, Communications) | Client-side part emission effect, triggered from the server. |
| **Products** | — | `MarketplaceService.ProcessReceipt` handler that dispatches developer product purchases to provider modules. |
| **RemapShiftLock** | — | Moves shift-lock to a different key. |
| **Easing** | — | `EasingFunctions`, `Lerp`, `Tween`, `TweenCallback`, `TweenObject`. |
| **SeriesMath** | — | Arithmetic, geometric and user-defined XP series with cumulative-sum caching, used for levelling curves. |
| **RequiringUtilities** | — | `LazyRequire` (deferred require, for breaking cycles) and `SafeRequire`. |
| **Signal** | — | Typed fork of stravant's GoodSignal. |

## Adding a package

1. Create `Packages/<Name>/`.
2. Add components with prefixed names, e.g. `S.MyFeature.luau` or `C.Graphics.MyWidget.luau`.
3. Optionally add `requirements.luau` (returning a list of package names), `config.luau`, and a `readme`. This highlights any dependencies that the package has, for example `Inventory` has both a client and server component, which depends on the `Communications` package.
4. Start a play test. The loader prints conflicts and missing dependencies to the output.
