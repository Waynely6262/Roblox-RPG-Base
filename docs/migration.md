# Migrating the place

The place file the repo was exported from had about 240 loaded scripts outside any package, plus 62 deployed copies saved from Edit-mode loading. [`migration/Migrate.luau`](../migration/Migrate.luau) restructures a place so it matches `src/Packages`. It was generated from the same plan as the repo, which was checked by applying it to the exported place and rebuilding: all 363 package scripts match.

> **Not yet run inside Studio.** The plan was simulated outside Roblox. Run it on a copy of the place first.

## Running it

1. **Make a copy of the place** (File → Save to File As…) and open the copy.
2. Insert a ModuleScript into `ServerStorage`, name it `Migrate`, and paste in the contents of `migration/Migrate.luau`.
3. In the command bar, run:
   ```lua
   require(game.ServerStorage.Migrate)()
   ```
4. Read the Output. Each step that couldn't run is listed with a reason, e.g. a path that has since moved. **Ctrl+Z** undoes the whole run.
5. Press Play and check the Output for `Missing dependency` or `client components were loaded` warnings. Then delete `ServerStorage.Migrate`.

The script works by path, so it still runs on a place that has changed since the export. Steps whose source is missing are skipped. Deployed copies are folded in live, so anything you've added to them since is kept, not deleted.

## What it changes

| Step | Count | Effect |
|---|---|---|
| Move into packages | 88 | Loaded scripts, and the UI/models/remotes they live in, become package components. Rules are below. |
| Fold deployed copies | 62 | For each package component, the copy at its deploy location is merged into the component using the loader's rule (children the component lacks move in; the component wins clashes), then deleted. |
| Retire old client root | 1 | `ReplicatedStorage.Client` is deleted. Its leftover ScreenGuis have already moved into E2BP and Notifications. If anything unexpected remains, it's parked in `ServerStorage.Unused` instead. |
| Park unused code | 1 | `ReplicatedStorage.Client.Disabled` is never loaded (the client loader only requires modules), so it moves to `ServerStorage.Unused/C.Disabled`. |
| Framework update | 3 | `Root`, `_Root/PackageLoader` and `_Root/VersionHistory` get the refined framework from Roblox-Framework. |
| DSClientRoot | 2 | The client root script becomes component `S.Client`. `S.ClientMover` is rewritten to release `Root.Client`. |
| Template paths | 6 | `game.ServerStorage.DSTemplate` / `StudioDSTemplate` → `game.ServerScriptService.Root.Data.…` (E2BP `S.Data`). |
| Requirements | 18 | `requirements` modules rewritten or added, from traced `require()` paths. |
| Readmes | 5 | New readmes for DSClientRoot, Utilities, CameraShake, Ragdoll and CustomPlayerList. |
| Clean-up | 3 | Deletes the loader-generated `ReplicatedStorage.Modules.PackageConfig` and folders left empty. |

### Where things went

Ownership rules, first match wins:

- Client UI helpers (`Client.Graphics.Util.*`, including TopbarPlus) → **UserInterface**
- Game code (combat, status effects, weapons, data tables, game UI, client backend, `Modules.Game`, `Modules.Data`, entity models, save templates) → **E2BP**
- Generic `Modules.Utility.*` and `Root.Utils.UserDebounce` → **Utilities**. Gamepass helpers → **Products**.
- `CameraShakeUtil` + `SpringModule` → **CameraShake**. `Remotes.Ragdoll` → **Ragdoll**.
- `Root.Players.ProfileDataInstances` → **ValueObjectVariables**
- The client `Default` and `_sprint` tool controllers → **CustomTools**
- `ServerStorage/Disabled Packages/CustomPlayerList` is revived as the **CustomPlayerList** package. Its deployed copy was identical.

<details><summary><b>CameraShake</b> (2)</summary>

- `ReplicatedStorage/Modules/CameraShakeUtil` → `RS.Modules.CameraShakeUtil`
- `ReplicatedStorage/Modules/SpringModule` → `RS.Modules.SpringModule`

</details>

<details><summary><b>CustomPlayerList</b> (3)</summary>

- `ServerStorage/Disabled Packages/CustomPlayerList` → package `CustomPlayerList`
- `ServerScriptService/Root/Packages/CustomPlayerList/C/Graphics/PlayerList` → `C.Graphics.PlayerList`
- `ReplicatedStorage/Client/Backend/AllPlayers/PlayerListBackend` → `C.Backend.AllPlayers.PlayerListBackend`

</details>

<details><summary><b>CustomTools</b> (2)</summary>

- `ReplicatedStorage/Client/Backend/RemoteReceivers/Tool/Default` → `C.Backend.RemoteReceivers.Tool.Default`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/Tool/_sprint` → `C.Backend.RemoteReceivers.Tool._sprint`

</details>

<details><summary><b>DSClientRoot</b> (1)</summary>

- `ServerScriptService/Root/Packages/DSClientRoot/S.ClientMover/Client` → `S.Client`

</details>

<details><summary><b>E2BP</b> (54)</summary>

- `ServerScriptService/Root/Other` → `S.Other`
- `ServerScriptService/Root/Utils/PointOnSurface` → `S.Utils.PointOnSurface`
- `ServerScriptService/Root/Utils/AccessRS` → `S.Utils.AccessRS`
- `ServerScriptService/Root/Utils/LoadAnimation` → `S.Utils.LoadAnimation`
- `ServerScriptService/Root/StatusEffects` → `S.StatusEffects`
- `ServerScriptService/Root/ReadReincarnation` → `S.ReadReincarnation`
- `ServerScriptService/Root/WriteReincarnation` → `S.WriteReincarnation`
- `ServerScriptService/Root/Tools/Weapon` → `S.Tools.Weapon`
- `ServerScriptService/Root/Tools/Consumable` → `S.Tools.Consumable`
- `ServerScriptService/Root/Tools/Shield` → `S.Tools.Shield`
- `ServerScriptService/Root/Players/Initialize/IsAlive` → `S.Players.Initialize.IsAlive`
- `ServerScriptService/Root/Players/Skills` → `S.Players.Skills`
- `ReplicatedStorage/Models/Entities` → `RS.Models.Entities`
- `ReplicatedStorage/Modules/Game` → `RS.Modules.Game`
- `ReplicatedStorage/Modules/Data` → `RS.Modules.Data`
- `ReplicatedStorage/Client/Backend/AllPlayers/AllPlayersCharacterLoaded` → `C.Backend.AllPlayers.AllPlayersCharacterLoaded`
- `ReplicatedStorage/Client/Backend/AllPlayers` → `C.Backend.AllPlayers`
- `ReplicatedStorage/Client/Backend/CharacterLoaded` → `C.Backend.CharacterLoaded`
- `ReplicatedStorage/Client/Backend/Main` → `C.Backend.Main`
- `ReplicatedStorage/Client/Backend/Sound` → `C.Backend.Sound`
- `ReplicatedStorage/Client/Backend/levelBackend` → `C.Backend.levelBackend`
- `ReplicatedStorage/Client/Backend/DeveloperTool` → `C.Backend.DeveloperTool`
- `ReplicatedStorage/Client/Backend/Upgrades` → `C.Backend.Upgrades`
- `ReplicatedStorage/Client/Backend/SendLookVector` → `C.Backend.SendLookVector`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/Emit` → `C.Backend.RemoteReceivers.Emit`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/CFrameLerp` → `C.Backend.RemoteReceivers.CFrameLerp`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/CommonAnimations` → `C.Backend.RemoteReceivers.CommonAnimations`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/hp` → `C.Backend.RemoteReceivers.hp`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/load` → `C.Backend.RemoteReceivers.load`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/GameplayReplication` → `C.Backend.RemoteReceivers.GameplayReplication`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/Knockback` → `C.Backend.RemoteReceivers.Knockback`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/statusEffects_be` → `C.Backend.RemoteReceivers.statusEffects_be`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/title` → `C.Backend.RemoteReceivers.title`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/CardAttacks` → `C.Backend.RemoteReceivers.CardAttacks`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/CustomizedEmit` → `C.Backend.RemoteReceivers.CustomizedEmit`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/Tool/Selection` → `C.Backend.RemoteReceivers.Tool.Selection`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/Tool/Weapon` → `C.Backend.RemoteReceivers.Tool.Weapon`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/Tool/Consumable` → `C.Backend.RemoteReceivers.Tool.Consumable`
- `ReplicatedStorage/Client/Backend/RemoteReceivers/Tool/Shield` → `C.Backend.RemoteReceivers.Tool.Shield`
- `ReplicatedStorage/Client/Backend/PointCamera` → `C.Backend.PointCamera`
- `ReplicatedStorage/Client/UserInterface/Widgets` → `C.UserInterface.Widgets`
- `ReplicatedStorage/Client/Graphics/currencies` → `C.Graphics.currencies`
- `ReplicatedStorage/Client/Graphics/cards` → `C.Graphics.cards`
- `ReplicatedStorage/Client/Graphics/Levels` → `C.Graphics.Levels`
- `ReplicatedStorage/Client/Graphics/statusEffects` → `C.Graphics.statusEffects`
- `ReplicatedStorage/Client/Graphics/Health` → `C.Graphics.Health`
- `ReplicatedStorage/Client/Graphics/vfx` → `C.Graphics.vfx`
- `ReplicatedStorage/Client/Graphics/HealthBars` → `C.Graphics.HealthBars`
- `ReplicatedStorage/Client/Graphics/Upgrades` → `C.Graphics.Upgrades`
- `ServerStorage/DSTemplate` → `S.Data/DSTemplate`
- `ServerStorage/StudioDSTemplate` → `S.Data/StudioDSTemplate`
- `ReplicatedStorage/Client/UserInterface/Popups` → `C.UserInterface.Popups`
- `ReplicatedStorage/Client/UserInterface/HotCards` → `C.UserInterface.HotCards`
- `ReplicatedStorage/Client/UserInterface/Upgrades` → `C.UserInterface.Upgrades`

</details>

<details><summary><b>Notifications</b> (1)</summary>

- `ReplicatedStorage/Client/UserInterface/Notifications` → `C.UserInterface.Notifications`

</details>

<details><summary><b>Products</b> (2)</summary>

- `ReplicatedStorage/Modules/Utility/MemoGamepass` → `RS.Modules.Utility.MemoGamepass`
- `ReplicatedStorage/Modules/Utility/AssertGamepass` → `RS.Modules.Utility.AssertGamepass`

</details>

<details><summary><b>Ragdoll</b> (1)</summary>

- `ReplicatedStorage/Remotes/Ragdoll` → `RS.Remotes.Ragdoll`

</details>

<details><summary><b>UserInterface</b> (8)</summary>

- `ReplicatedStorage/Client/Graphics/Util/ExitLikely` → `C.Graphics.Util.ExitLikely`
- `ReplicatedStorage/Client/Graphics/Util/GradientProgressBar` → `C.Graphics.Util.GradientProgressBar`
- `ReplicatedStorage/Client/Graphics/Util/MouseHit` → `C.Graphics.Util.MouseHit`
- `ReplicatedStorage/Client/Graphics/Util/TopBarPlusIcon` → `C.Graphics.Util.TopBarPlusIcon`
- `ReplicatedStorage/Client/Graphics/Util/comma` → `C.Graphics.Util.comma`
- `ReplicatedStorage/Client/Graphics/Util/hhmmssFormat` → `C.Graphics.Util.hhmmssFormat`
- `ReplicatedStorage/Client/Graphics/Util/numberAbbreviator` → `C.Graphics.Util.numberAbbreviator`
- `ReplicatedStorage/Client/Graphics/Util/round` → `C.Graphics.Util.round`

</details>

<details><summary><b>Utilities</b> (13)</summary>

- `ServerScriptService/Root/Utils/UserDebounce` → `S.Utils.UserDebounce`
- `ReplicatedStorage/Modules/Utility/Welder` → `RS.Modules.Utility.Welder`
- `ReplicatedStorage/Modules/Utility/PartExtents` → `RS.Modules.Utility.PartExtents`
- `ReplicatedStorage/Modules/Utility/ConnectionHandler` → `RS.Modules.Utility.ConnectionHandler`
- `ReplicatedStorage/Modules/Utility/RetryAsync` → `RS.Modules.Utility.RetryAsync`
- `ReplicatedStorage/Modules/Utility/PlayerNameColor` → `RS.Modules.Utility.PlayerNameColor`
- `ReplicatedStorage/Modules/Utility/ThrottleRun` → `RS.Modules.Utility.ThrottleRun`
- `ReplicatedStorage/Modules/Utility/FakePlayer` → `RS.Modules.Utility.FakePlayer`
- `ReplicatedStorage/Modules/Utility/ReplicationBuffer` → `RS.Modules.Utility.ReplicationBuffer`
- `ReplicatedStorage/Modules/Utility/RunOnNextFrame` → `RS.Modules.Utility.RunOnNextFrame`
- `ReplicatedStorage/Modules/Utility/Emit` → `RS.Modules.Utility.Emit`
- `ReplicatedStorage/Modules/Utility/Pathfind` → `RS.Modules.Utility.Pathfind`
- `ReplicatedStorage/Modules/Utility/tostringTable` → `RS.Modules.Utility.tostringTable`

</details>

<details><summary><b>ValueObjectVariables</b> (1)</summary>

- `ServerScriptService/Root/Players/ProfileDataInstances` → `S.Players.ProfileDataInstances`

</details>

### Deployed copies that were older than their package

Most deployed copies were identical to their package component. These 11 weren't, and in each case the package version is newer (it reads `PackageConfig`, adds the inventory tooltip, or has extra nil checks). The loader already overwrote them with the package version on every server start, so removing them changes nothing at runtime:

`Modules.Inventory`, `Client.Graphics.inventory`, `Client.Graphics.Craft`, `Client.Graphics.Util.Keybinds`, `Client.Backend.RemoteReceivers.Inventory`, `Client.Backend.RemoteReceivers.Tool`, `Client.Backend.Craft`, `Root.Utils.ToolSearch`, `Root.Remotes`, `Root.Players`, `Root.Players.PlayerInventories`.

The first version of this repo's README said every pair was identical. That was wrong.

## Left alone

These scripts aren't loaded by the framework, so they aren't in the repo. The migration doesn't touch them:

- Workspace: map props, both `Rig/Animate` copies, `mesh util`, `fpslocker`, `uiresize`, `canvas`, `Import/ZeroHeightPivot`, `Pickaxes/PickaxeStats`, and the duplicate `CameraEffects` modules
- `StarterPack/FloorUp` and `FloorDown`, `StarterGui/DevelopmentLayerCollector`
- `ServerScriptService/testReplication`, `ServerStorage/ClearDataStore`, `ServerStorage/Border`, `TestService/RobloxLSP_Settings`
- `Root/_Root/UploadLog`
