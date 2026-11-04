--!nocheck
--[[
Package migration for Eat to Be Powerful
Generated from the Roblox-RPG-Base export. Run it on a COPY of the place first.

How to run (Studio, Edit mode):
  1. Insert a ModuleScript into ServerStorage, name it "Migrate", and paste this file into it.
  2. In the command bar:  require(game.ServerStorage.Migrate)()
  3. Read the Output. Every skipped step is listed with a reason. Ctrl+Z undoes the whole run.

What it does, in order:
  - move:    puts loaded scripts (and the instances they live in) into packages as components
  - fold:    merges a deployed copy into its package component using the loader's rule
             (children the component lacks are moved in; the component wins clashes),
             then deletes the copy
  - retire:  deletes the old client root, or parks it in ServerStorage.Unused if anything is left
  - prune:   deletes folders that ended up empty
  - source / replace / new: framework update, DSClientRoot rewrite, readmes, requirements,
             and the DSTemplate path change
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local function resolve(path: {string}): Instance?
	local cur: Instance? = game:GetService(path[1])
	for i = 2, #path do
		if not cur then return nil end
		cur = cur:FindFirstChild(path[i])
	end
	return cur
end

local function show(path: {string}) return table.concat(path, "/") end

local function fold(from: Instance, into: Instance)
	for _, child in from:GetChildren() do
		local existing = into:FindFirstChild(child.Name)
		if existing then
			fold(child, existing)
		else
			child.Parent = into
		end
	end
end

local function hasContent(inst: Instance): boolean
	for _, d in inst:GetDescendants() do
		if not d:IsA("Folder") then return true end
	end
	return false
end

local function unusedFolder(): Folder
	local ss = game:GetService("ServerStorage")
	local f = ss:FindFirstChild("Unused")
	if not f then
		f = Instance.new("Folder")
		f.Name = "Unused"
		f.Parent = ss
	end
	return f
end

local OPS = {
	{"move", {"ServerStorage", "Disabled Packages", "CustomPlayerList"}, {"ServerScriptService", "Root", "Packages"}, "CustomPlayerList"},
	{"move", {"ServerScriptService", "Root", "Packages", "CustomPlayerList", "C/Graphics/PlayerList"}, {"ServerScriptService", "Root", "Packages", "CustomPlayerList"}, "C.Graphics.PlayerList"},
	{"move", {"ServerScriptService", "Root", "Packages", "DSClientRoot", "S.ClientMover", "Client"}, {"ServerScriptService", "Root", "Packages", "DSClientRoot"}, "S.Client"},
	{"move", {"ServerScriptService", "Root", "Other"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Other"},
	{"folder", {"ServerScriptService", "Root", "Packages"}, "Utilities"},
	{"move", {"ServerScriptService", "Root", "Utils", "UserDebounce"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "S.Utils.UserDebounce"},
	{"move", {"ServerScriptService", "Root", "Utils", "PointOnSurface"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Utils.PointOnSurface"},
	{"move", {"ServerScriptService", "Root", "Utils", "AccessRS"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Utils.AccessRS"},
	{"move", {"ServerScriptService", "Root", "Utils", "LoadAnimation"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Utils.LoadAnimation"},
	{"move", {"ServerScriptService", "Root", "StatusEffects"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.StatusEffects"},
	{"move", {"ServerScriptService", "Root", "ReadReincarnation"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.ReadReincarnation"},
	{"move", {"ServerScriptService", "Root", "WriteReincarnation"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.WriteReincarnation"},
	{"move", {"ServerScriptService", "Root", "Tools", "Weapon"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Tools.Weapon"},
	{"move", {"ServerScriptService", "Root", "Tools", "Consumable"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Tools.Consumable"},
	{"move", {"ServerScriptService", "Root", "Tools", "Shield"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Tools.Shield"},
	{"move", {"ServerScriptService", "Root", "Players", "Initialize", "IsAlive"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Players.Initialize.IsAlive"},
	{"move", {"ServerScriptService", "Root", "Players", "ProfileDataInstances"}, {"ServerScriptService", "Root", "Packages", "ValueObjectVariables"}, "S.Players.ProfileDataInstances"},
	{"move", {"ServerScriptService", "Root", "Players", "Skills"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Players.Skills"},
	{"move", {"ReplicatedStorage", "Models", "Entities"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "RS.Models.Entities"},
	{"move", {"ReplicatedStorage", "Modules", "Game"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "RS.Modules.Game"},
	{"move", {"ReplicatedStorage", "Modules", "Data"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "RS.Modules.Data"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "Welder"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.Welder"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "PartExtents"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.PartExtents"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "ConnectionHandler"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.ConnectionHandler"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "RetryAsync"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.RetryAsync"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "PlayerNameColor"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.PlayerNameColor"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "MemoGamepass"}, {"ServerScriptService", "Root", "Packages", "Products"}, "RS.Modules.Utility.MemoGamepass"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "AssertGamepass"}, {"ServerScriptService", "Root", "Packages", "Products"}, "RS.Modules.Utility.AssertGamepass"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "ThrottleRun"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.ThrottleRun"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "FakePlayer"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.FakePlayer"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "ReplicationBuffer"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.ReplicationBuffer"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "RunOnNextFrame"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.RunOnNextFrame"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "Emit"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.Emit"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "Pathfind"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.Pathfind"},
	{"move", {"ReplicatedStorage", "Modules", "Utility", "tostringTable"}, {"ServerScriptService", "Root", "Packages", "Utilities"}, "RS.Modules.Utility.tostringTable"},
	{"folder", {"ServerScriptService", "Root", "Packages"}, "CameraShake"},
	{"move", {"ReplicatedStorage", "Modules", "CameraShakeUtil"}, {"ServerScriptService", "Root", "Packages", "CameraShake"}, "RS.Modules.CameraShakeUtil"},
	{"move", {"ReplicatedStorage", "Modules", "SpringModule"}, {"ServerScriptService", "Root", "Packages", "CameraShake"}, "RS.Modules.SpringModule"},
	{"folder", {"ServerScriptService", "Root", "Packages"}, "Ragdoll"},
	{"move", {"ReplicatedStorage", "Remotes", "Ragdoll"}, {"ServerScriptService", "Root", "Packages", "Ragdoll"}, "RS.Remotes.Ragdoll"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "AllPlayers", "PlayerListBackend"}, {"ServerScriptService", "Root", "Packages", "CustomPlayerList"}, "C.Backend.AllPlayers.PlayerListBackend"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "AllPlayers", "AllPlayersCharacterLoaded"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.AllPlayers.AllPlayersCharacterLoaded"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "AllPlayers"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.AllPlayers"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "CharacterLoaded"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.CharacterLoaded"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "Main"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.Main"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "Sound"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.Sound"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "levelBackend"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.levelBackend"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "DeveloperTool"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.DeveloperTool"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "Upgrades"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.Upgrades"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "SendLookVector"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.SendLookVector"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Emit"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.Emit"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "CFrameLerp"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.CFrameLerp"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "CommonAnimations"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.CommonAnimations"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "hp"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.hp"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "load"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.load"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "GameplayReplication"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.GameplayReplication"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Knockback"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.Knockback"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "statusEffects_be"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.statusEffects_be"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "title"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.title"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "CardAttacks"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.CardAttacks"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "CustomizedEmit"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.CustomizedEmit"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Tool", "Selection"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.Tool.Selection"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Tool", "Default"}, {"ServerScriptService", "Root", "Packages", "CustomTools"}, "C.Backend.RemoteReceivers.Tool.Default"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Tool", "Weapon"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.Tool.Weapon"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Tool", "Consumable"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.Tool.Consumable"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Tool", "Shield"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.RemoteReceivers.Tool.Shield"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Tool", "_sprint"}, {"ServerScriptService", "Root", "Packages", "CustomTools"}, "C.Backend.RemoteReceivers.Tool._sprint"},
	{"move", {"ReplicatedStorage", "Client", "Backend", "PointCamera"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Backend.PointCamera"},
	{"move", {"ReplicatedStorage", "Client", "UserInterface", "Widgets"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.UserInterface.Widgets"},
	{"folder", {"ServerStorage"}, "Unused"},
	{"move", {"ReplicatedStorage", "Client", "Disabled"}, {"ServerStorage", "Unused"}, "C.Disabled"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "ExitLikely"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.ExitLikely"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "GradientProgressBar"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.GradientProgressBar"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "MouseHit"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.MouseHit"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "TopBarPlusIcon"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.TopBarPlusIcon"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "comma"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.comma"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "hhmmssFormat"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.hhmmssFormat"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "numberAbbreviator"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.numberAbbreviator"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Util", "round"}, {"ServerScriptService", "Root", "Packages", "UserInterface"}, "C.Graphics.Util.round"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "currencies"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.currencies"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "cards"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.cards"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Levels"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.Levels"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "statusEffects"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.statusEffects"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Health"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.Health"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "vfx"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.vfx"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "HealthBars"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.HealthBars"},
	{"move", {"ReplicatedStorage", "Client", "Graphics", "Upgrades"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.Graphics.Upgrades"},
	{"folder", {"ServerScriptService", "Root", "Packages", "E2BP"}, "S.Data"},
	{"move", {"ServerStorage", "DSTemplate"}, {"ServerScriptService", "Root", "Packages", "E2BP", "S.Data"}, "DSTemplate"},
	{"move", {"ServerStorage", "StudioDSTemplate"}, {"ServerScriptService", "Root", "Packages", "E2BP", "S.Data"}, "StudioDSTemplate"},
	{"fold", {"ReplicatedStorage", "Client", "UserInterface", "Inventory", "Main", "InterfaceFrame", "InvMenusFrame", "Crafting"}, {"ServerScriptService", "Root", "Packages", "Crafting", "C.UserInterface.Inventory.Main.InterfaceFrame.InvMenusFrame.Crafting"}},
	{"fold", {"ReplicatedStorage", "Client", "UserInterface", "Inventory", "Main", "InterfaceFrame", "InvMenusButtons"}, {"ServerScriptService", "Root", "Packages", "InventoryMenus", "C.UserInterface.Inventory.Main.InterfaceFrame.InvMenusButtons"}},
	{"fold", {"ReplicatedStorage", "Client", "UserInterface", "Inventory", "Main", "InterfaceFrame", "InvMenusFrame"}, {"ServerScriptService", "Root", "Packages", "InventoryMenus", "C.UserInterface.Inventory.Main.InterfaceFrame.InvMenusFrame"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "Keybinds", "Template"}, {"ServerScriptService", "Root", "Packages", "ControlsExtension", "C.Graphics.Util.Keybinds.Template"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "Button"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.Button"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "Hoverable"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.Hoverable"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "Slider"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.Slider"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "Widget"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.Widget"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "UIStrokeAutoAdjust"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.UIStrokeAutoAdjust"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "TransparencyAPI"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.TransparencyAPI"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "UIAPI"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.UIAPI"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "MouseLock"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.MouseLock"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "FollowMouse"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics.Util.FollowMouse"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Tool"}, {"ServerScriptService", "Root", "Packages", "CustomTools", "Client.Backend.RemoteReceivers.Tool"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "PartEmit"}, {"ServerScriptService", "Root", "Packages", "BasePartEmission", "Client.Backend.RemoteReceivers.PartEmit"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Notifications"}, {"ServerScriptService", "Root", "Packages", "Notifications", "C.Backend.RemoteReceivers.Notifications"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "vars"}, {"ServerScriptService", "Root", "Packages", "ReplicatedVariables", "C.Backend.RemoteReceivers.vars"}},
	{"fold", {"ReplicatedStorage", "Client", "UserInterface", "PersistentGui", "Keybinds"}, {"ServerScriptService", "Root", "Packages", "ControlsExtension", "C.UserInterface.PersistentGui.Keybinds"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Util", "Keybinds"}, {"ServerScriptService", "Root", "Packages", "ControlsExtension", "C.Graphics.Util.Keybinds"}},
	{"fold", {"ReplicatedStorage", "Client", "UserInterface", "PersistentGui", "ActiveHotbar"}, {"ServerScriptService", "Root", "Packages", "Inventory", "C.UserInterface.PersistentGui.ActiveHotbar"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers", "Inventory"}, {"ServerScriptService", "Root", "Packages", "Inventory", "Client.Backend.RemoteReceivers.Inventory"}},
	{"fold", {"ReplicatedStorage", "Client", "UserInterface", "PersistentGui"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.UserInterface.PersistentGui"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "EasingFunctions"}, {"ServerScriptService", "Root", "Packages", "Easing", "ReplicatedStorage.Modules.Utility.EasingFunctions"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "Tween"}, {"ServerScriptService", "Root", "Packages", "Easing", "ReplicatedStorage.Modules.Utility.Tween"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "TweenObject"}, {"ServerScriptService", "Root", "Packages", "Easing", "ReplicatedStorage.Modules.Utility.TweenObject"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "TweenCallback"}, {"ServerScriptService", "Root", "Packages", "Easing", "ReplicatedStorage.Modules.Utility.TweenCallback"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "Lerp"}, {"ServerScriptService", "Root", "Packages", "Easing", "RS.Modules.Utility.Lerp"}},
	{"fold", {"ServerScriptService", "Root", "Utils", "Giver"}, {"ServerScriptService", "Root", "Packages", "ValueObjectVariables", "Server.Utils.Giver"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "Finder"}, {"ServerScriptService", "Root", "Packages", "ValueObjectVariables", "ReplicatedStorage.Modules.Utility.Finder"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "FindGripJoint"}, {"ServerScriptService", "Root", "Packages", "CustomTools", "ReplicatedStorage.Modules.Utility.FindGripJoint"}},
	{"fold", {"ServerScriptService", "Root", "Utils", "ToolSearch"}, {"ServerScriptService", "Root", "Packages", "CustomTools", "Server.Utils.ToolSearch"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "ShiftLockKeyRemap"}, {"ServerScriptService", "Root", "Packages", "RemapShiftLock", "C.Backend.ShiftLockKeyRemap"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Notifications"}, {"ServerScriptService", "Root", "Packages", "Notifications", "C.Graphics.Notifications"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "Search"}, {"ServerScriptService", "Root", "Packages", "CallbackLoading", "RS.Modules.Utility.Search"}},
	{"fold", {"ServerScriptService", "Root", "Players", "vars"}, {"ServerScriptService", "Root", "Packages", "ReplicatedVariables", "S.Players.vars"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "SafeRequire"}, {"ServerScriptService", "Root", "Packages", "RequiringUtilities", "RS.Modules.Utility.SafeRequire"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "LazyRequire"}, {"ServerScriptService", "Root", "Packages", "RequiringUtilities", "RS.Modules.Utility.LazyRequire"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "Signal"}, {"ServerScriptService", "Root", "Packages", "Signal", "RS.Modules.Utility.Signal"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "ArithmeticSeries"}, {"ServerScriptService", "Root", "Packages", "SeriesMath", "rs.Modules.Utility.ArithmeticSeries"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "GeometricSeries"}, {"ServerScriptService", "Root", "Packages", "SeriesMath", "rs.Modules.Utility.GeometricSeries"}},
	{"fold", {"ReplicatedStorage", "Modules", "Utility", "UserDefinedSeries"}, {"ServerScriptService", "Root", "Packages", "SeriesMath", "rs.Modules.Utility.UserDefinedSeries"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "Craft"}, {"ServerScriptService", "Root", "Packages", "Crafting", "C.Graphics.Craft"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "Craft"}, {"ServerScriptService", "Root", "Packages", "Crafting", "C.Backend.Craft"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "InventoryMenus"}, {"ServerScriptService", "Root", "Packages", "InventoryMenus", "C.Graphics.InventoryMenus"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "SetCASTextScaled"}, {"ServerScriptService", "Root", "Packages", "ControlsExtension", "C.Graphics.SetCASTextScaled"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "RemoteReceivers"}, {"ServerScriptService", "Root", "Packages", "Communications", "Client.Backend.RemoteReceivers"}},
	{"fold", {"ServerScriptService", "Root", "Players", "PlayerInventories"}, {"ServerScriptService", "Root", "Packages", "Inventory", "Server.Players.PlayerInventories"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "inventory"}, {"ServerScriptService", "Root", "Packages", "Inventory", "C.Graphics.inventory"}},
	{"fold", {"ReplicatedStorage", "Client", "Backend", "Input"}, {"ServerScriptService", "Root", "Packages", "Inventory", "Client.Backend.Input"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "ItemFrameAPI"}, {"ServerScriptService", "Root", "Packages", "Inventory", "C.Graphics.ItemFrameAPI"}},
	{"fold", {"ReplicatedStorage", "Client", "UserInterface", "Inventory"}, {"ServerScriptService", "Root", "Packages", "Inventory", "C.UserInterface.Inventory"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics", "PlayerList"}, {"ServerScriptService", "Root", "Packages", "CustomPlayerList", "C.Graphics.PlayerList"}},
	{"fold", {"ServerScriptService", "Root", "RemoteReceivers"}, {"ServerScriptService", "Root", "Packages", "E2BP", "S.RemoteReceivers"}},
	{"fold", {"ReplicatedStorage", "Client", "Graphics"}, {"ServerScriptService", "Root", "Packages", "UserInterface", "C.Graphics"}},
	{"fold", {"ReplicatedStorage", "Models", "Tools"}, {"ServerScriptService", "Root", "Packages", "CustomTools", "RS.Models.Tools"}},
	{"fold", {"ServerScriptService", "Root", "Tools"}, {"ServerScriptService", "Root", "Packages", "CustomTools", "Server.Tools"}},
	{"fold", {"ReplicatedStorage", "Models", "EmittedParts"}, {"ServerScriptService", "Root", "Packages", "BasePartEmission", "RS.Models.EmittedParts"}},
	{"fold", {"ServerScriptService", "Root", "Remotes"}, {"ServerScriptService", "Root", "Packages", "Communications", "Server.Remotes"}},
	{"fold", {"ReplicatedStorage", "Remotes", "MainE"}, {"ServerScriptService", "Root", "Packages", "Communications", "RS.Remotes.MainE"}},
	{"fold", {"ReplicatedStorage", "Remotes", "MainF"}, {"ServerScriptService", "Root", "Packages", "Communications", "RS.Remotes.MainF"}},
	{"fold", {"ServerScriptService", "Root", "Players"}, {"ServerScriptService", "Root", "Packages", "DSPlayers", "Server.Players"}},
	{"fold", {"ReplicatedStorage", "Modules", "Inventory"}, {"ServerScriptService", "Root", "Packages", "Inventory", "ReplicatedStorage.Modules.Inventory"}},
	{"move", {"ReplicatedStorage", "Client", "UserInterface", "Notifications"}, {"ServerScriptService", "Root", "Packages", "Notifications"}, "C.UserInterface.Notifications"},
	{"move", {"ReplicatedStorage", "Client", "UserInterface", "Popups"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.UserInterface.Popups"},
	{"move", {"ReplicatedStorage", "Client", "UserInterface", "HotCards"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.UserInterface.HotCards"},
	{"move", {"ReplicatedStorage", "Client", "UserInterface", "Upgrades"}, {"ServerScriptService", "Root", "Packages", "E2BP"}, "C.UserInterface.Upgrades"},
	{"retire", {"ReplicatedStorage", "Client"}},
	{"destroy", {"ReplicatedStorage", "Modules", "PackageConfig"}},
	{"prune", {"ServerScriptService", "Root", "Utils"}},
	{"prune", {"ReplicatedStorage", "Modules", "Utility"}},
	{"source", {"ServerScriptService", "Root"}, [[
--!strict

-- for loading the environment in command bar which allows for typechecking and autocomplete
local script = (script or game.Selection:Get()[1]):: typeof(script)

local Versioning = require(script._Root.VersionHistory):: {{{string}}}
local PackageLoader = require(script._Root.PackageLoader)

local release = Versioning[#Versioning]
print(`Using Package Loader Framework v{#Versioning}.{#release}.{#release[#release]} by Waynely (https://github.com/Waynely6262/Roblox-Framework)`)

local PackagesFolder = script:FindFirstChild("Packages"):: Folder
if not PackagesFolder then
	return error("No package folder found.")
end

for _, Package in PackagesFolder:GetChildren() do
	PackageLoader.LoadPackage(Package)
end

PackageLoader.AssertRequirements()

if game:GetService("RunService"):IsRunning() then

	local function require_l(m: ModuleScript)

		print(`[Server Root] loading {m:GetFullName()}`)

		local s, r = pcall(require, m)
		if not s then
			warn(`[Server Root] could not load {m:GetFullName()} | {r}`)
		end
	end

	-- Modules required before everything else, if a package provides them
	local PRELOAD = {"Players"}
	local preloaded = {}
	for _, name in PRELOAD do
		local m = script:FindFirstChild(name)
		if m and m:IsA("ModuleScript") then
			preloaded[m] = true
			task.spawn(require_l, m)
		end
	end

	-- Load everything else: every top-level ModuleScript under Root
	for _, v in script:GetChildren() do
		if v:IsA("ModuleScript") and not preloaded[v] then
			task.spawn(require_l, v)
		end
	end
end
]]},
	{"source", {"ServerScriptService", "Root", "_Root", "PackageLoader"}, [=[
--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local timestamp = tick()
local IsStudio = RunService:IsStudio()
local IsRunning = RunService:IsRunning()

local PATH_SPLITTER = "."

local Root = script.Parent.Parent

--[[
Where each root alias deploys to: an instance, plus a path below it.

Client components are not part of the framework. They are staged under Root.Client while the
server is running, so nothing reaches players until a client package (e.g. DSClientRoot) provides
the client root script and releases it to ReplicatedStorage. In Edit mode they go straight to
ReplicatedStorage.Client, so autocomplete resolves the same paths the game uses at runtime.
]]
type Location = {instance: Instance, prefix: {string}}

local ClientLocation: Location = if IsRunning
	then {instance = Root, prefix = {"Client"}}
	else {instance = ReplicatedStorage, prefix = {"Client"}}

local RootLocations: {[string]: Location} = {
	Server = {instance = Root, prefix = {}};
	S = {instance = Root, prefix = {}};
	s = {instance = Root, prefix = {}};

	Client = ClientLocation;
	C = ClientLocation;
	c = ClientLocation;

	ReplicatedStorage = {instance = ReplicatedStorage, prefix = {}};
	RS = {instance = ReplicatedStorage, prefix = {}};
	rs = {instance = ReplicatedStorage, prefix = {}};
}

local ClientAliases = {Client = true, C = true, c = true}
local ClientComponentCount = 0

-- Looks for a directory with the given path. If the path does not exist, one is created with Folders.
local function trace_path(v: Instance, p: {string}): Instance
	for _, pointer in p do
		local nextv = v:FindFirstChild(pointer)
		if not nextv then
			nextv = Instance.new("Folder")
			nextv.Name = pointer
			nextv.Parent = v
		end
		v = nextv:: Instance
	end
	return v
end

--[[
Moves every child of `from` that `into` doesn't already have into `into`, recursing into children
that both have. `into` wins every clash. The caller destroys `from` afterwards.
Exported so packages can apply the same rule (see DSClientRoot).
]]
local function merge(from: Instance, into: Instance)
	for _, child in from:GetChildren() do
		local existing = into:FindFirstChild(child.Name)
		if existing then
			merge(child, existing)
		else
			child.Parent = into
		end
	end
end

-- Initializes the folder for storing package-related config files.
local PackageConfigFolder = trace_path(ReplicatedStorage, {"Modules", "PackageConfig"})
PackageConfigFolder:ClearAllChildren()

local PackageNames = {}
local Requirements = {}
local Special = {
	-- Names other packages this package depends on; checked by AssertRequirements.
	requirements = function(packageName: string, v: ModuleScript)
		local reqs = (require:: any)(v)
		for _, req in reqs do
			Requirements[req] = (Requirements[req] or "") .. packageName .. "; "
		end
	end,
	-- Developer notes; never deployed.
	readme = function(packageName: string)
		return
	end,
	-- Copied to ReplicatedStorage.Modules.PackageConfig[<package name>].
	config = function(packageName: string, v: ModuleScript)
		local configFile = v:Clone()
		configFile.Name = packageName
		configFile.Parent = PackageConfigFolder
	end,
}

local load_component: (Instance, string) -> ()
local load_package: (Instance) -> ()

load_package = function(Package: Instance)

	if Package:IsA("ModuleScript") then
		return load_component(Package, "nil")
	end

	if PackageNames[Package.Name] then
		warn(`Duplicate package name {Package.Name}`)
	end
	PackageNames[Package.Name] = true

	for _, Component in Package:GetChildren() do
		load_component(Component, Package.Name)
	end
end

load_component = function(Component: Instance, PackageName: string)

	-- allow nested packages
	if Component.Name == "Packages" and Component.ClassName == "Folder" then
		load_package(Component)
		return
	elseif Special[Component.Name] then
		Special[Component.Name](PackageName, Component)
		return
	end

	-- Ignore PackageLink instances where the package is part of a Roblox Package
	if Component.ClassName == "PackageLink" then return end

	-- In Studio, deploy a copy so the package stays intact in Edit mode and between play tests
	if IsStudio then
		Component = Component:Clone()
		Component:SetAttribute("_ver", timestamp)
		Component:SetAttribute("_origin", PackageName)
	end

	local Path = Component.Name:split(PATH_SPLITTER)
	if #Path < 2 then warn(`{Component:GetFullName()} of class {Component.ClassName} is not a valid component`) return end

	local ScriptName = table.remove(Path, #Path):: string -- last element
	local RootName = table.remove(Path, 1):: string

	local Location = RootLocations[RootName]
	assert(Location, `Invalid root name: {RootName} (in {PackageName})`)

	if ClientAliases[RootName] then
		ClientComponentCount += 1
	end

	local parent = trace_path(trace_path(Location.instance, Location.prefix), Path)

	local existing = parent:FindFirstChild(ScriptName)
	if existing then

		if existing.ClassName ~= "Folder" then
			print(`Found a matching item {existing:GetFullName()} conflicting with {Component:GetFullName()}; overwriting..`)
		end

		if existing:IsA("LuaSourceContainer") and Component:IsA("LuaSourceContainer") then
			local s, r = pcall(function()
				if (existing:: any).Source ~= (Component:: any).Source then
					warn(`{Component:GetFullName()} and {existing:GetFullName()} have different sources. Check which version is latest`)
				end
			end)
			if not s then
				print(`Failed to read file sources: {r}`)
			end
		end

		merge(existing, Component)
		existing:Destroy()
	end
	Component.Name = ScriptName
	Component.Parent = parent
end

local function AssertRequirements()
	for package, requesterList in Requirements do
		if not PackageNames[package] then
			warn(`Missing dependency {package}: required by {requesterList}`)
		end
	end

	-- Client components only run if some package supplies the client root script itself
	if IsRunning and ClientComponentCount > 0 then
		local clientRoot = Root:FindFirstChild("Client")
		if not (clientRoot and clientRoot:IsA("BaseScript")) then
			warn(`{ClientComponentCount} client components were loaded, but no package provides a client root (e.g. DSClientRoot). They will not run.`)
		end
	end
end

return {
	LoadPackage = load_package;
	LoadComponent = load_component;
	AssertRequirements = AssertRequirements;
	Merge = merge;
	RootLocations = RootLocations;
}
]=]},
	{"source", {"ServerScriptService", "Root", "_Root", "VersionHistory"}, [=[
-- Release > Update > Changes. The printed version is v<releases>.<updates>.<changes in latest update>
return {
	{
		{
			[[Added support for loading content in Edit, which allows for type-check and auto-complete]];
		};
		{
			[[Moved Client Root to ReplicatedStorage]];
			[[Moved scripts in RS.Modules.Graphics to Client.Graphics]];
			[[Moved scripts in RS.Modules.ClientUtility to Client.Graphics.Util]];
		};
		{
			[[Added version history; 01/07/26]];
		};
		{
			[[Added 'Special' library]];
			[[Added special 'requirements' case for specifying a package's dependencies]];
			[[Added special 'readme' case for package description]];
			[[Added special 'config' case for package configuration]];
			[[Migrated config file loading to method library 'Special' in server Root]];
		};
	};
	{
		{
			[[Client support moved out of the framework: client components are staged under Root.Client and released by a client package (e.g. DSClientRoot)]];
			[[Root no longer requires a client root to exist or moves it to ReplicatedStorage]];
			[[Overwriting now merges children recursively (from the game's loader)]];
			[[Exported PackageLoader.Merge so packages can apply the same merge rule]];
			[[Warn when client components load but no package provides a client root]];
			[[Preloading 'Players' is now optional]];
			[[Components are only cloned after special cases are handled]];
		};
	};
}
]=]},
	{"source", {"ServerScriptService", "Root", "Packages", "DSClientRoot", "S.ClientMover"}, [=[
--!strict
--[[
Releases the client root to players.

The framework stages every client component under ServerScriptService.Root.Client while the server
runs. The only requirement for the client is that the Players module has been initialized, so we
require it first, then move the staged root to its destination (ReplicatedStorage by default),
where the client root script starts running on each player.
]]

local Root = game:GetService("ServerScriptService").Root
local PackageLoader = require(Root._Root.PackageLoader)
local CONFIG = require(game.ReplicatedStorage.Modules.PackageConfig.DSClientRoot)

local Players = Root:FindFirstChild("Players")
if Players then
	require(Players)
end

local staged = Root:FindFirstChild("Client")
if not (staged and staged:IsA("BaseScript")) then
	warn("[DSClientRoot] No client root was staged under Root.Client")
	return nil
end

local existing = CONFIG.destination:FindFirstChild("Client")
if existing then
	-- Usually a copy left behind by loading in Edit mode. The freshly loaded version wins.
	PackageLoader.Merge(existing, staged)
	existing:Destroy()
end

staged.Parent = CONFIG.destination

return nil
]=]},
	{"new", {"ServerScriptService", "Root", "Packages", "DSClientRoot"}, "readme", "Script", {Disabled = true, RunContext = Enum.RunContext.Plugin}},
	{"source", {"ServerScriptService", "Root", "Packages", "DSClientRoot", "readme"}, [=[
--[[

Name: DSClientRoot
Summary: The client root. Install this package to run any client code.
Version: 2.0
Author: Waynely (coocoocrazyhead)

The framework never runs client code on its own. Components prefixed with C. / Client. are staged
under ServerScriptService.Root.Client, and this package supplies:

- S.Client: the client root script (RunContext = Client). Once released, it requires every
  top-level ModuleScript in Client.Graphics, Client.Backend and Client, then prints "Client ready".
- S.ClientMover: waits for the Players module (DSPlayers), then moves Root.Client to
  config.destination (ReplicatedStorage). Copies left over from Edit-mode loading are merged
  with the fresh version winning.

Any package that ships C. components should list "DSClientRoot" in its requirements.

]]
]=]},
	{"new", {"ServerScriptService", "Root", "Packages", "Utilities"}, "readme", "Script", {Disabled = true, RunContext = Enum.RunContext.Plugin}},
	{"source", {"ServerScriptService", "Root", "Packages", "Utilities", "readme"}, [=[
--[[

Name: Utilities
Summary: General-purpose modules with no game dependencies.
Author: Waynely (coocoocrazyhead)

Shared (ReplicatedStorage.Modules.Utility): ConnectionHandler, Emit, FakePlayer, PartExtents,
Pathfind, PlayerNameColor, ReplicationBuffer, RetryAsync, RunOnNextFrame, ThrottleRun, Welder,
tostringTable.

Server (Root.Utils): UserDebounce.

]]
]=]},
	{"new", {"ServerScriptService", "Root", "Packages", "CameraShake"}, "readme", "Script", {Disabled = true, RunContext = Enum.RunContext.Plugin}},
	{"source", {"ServerScriptService", "Root", "Packages", "CameraShake", "readme"}, [=[
--[[

Name: CameraShake
Summary: Spring-driven camera shake for the local player.
Author: Waynely (coocoocrazyhead)

RS.Modules.SpringModule: a lazily evaluated damped spring (1D or 3D).
RS.Modules.CameraShakeUtil: applies positional and angular impulses through two springs, bound to
RenderStep under the name "CameraShake".

]]
]=]},
	{"new", {"ServerScriptService", "Root", "Packages", "Ragdoll"}, "readme", "Script", {Disabled = true, RunContext = Enum.RunContext.Plugin}},
	{"source", {"ServerScriptService", "Root", "Packages", "Ragdoll", "readme"}, [=[
--[[

Name: Ragdoll
Summary: Server-driven character ragdolls.

RS.Remotes.Ragdoll contains RagdollHandler (a client Script) and its RemoteEvent. The RemoteEvent's
RagdollServer script (a server Script) exposes Ragdoll.RagdollCharacter(Character), which tells
the owning player through the RemoteEvent and builds limb constraints from LimbTree.
Both scripts set their RunContext, so they run from ReplicatedStorage without being required.

]]
]=]},
	{"new", {"ServerScriptService", "Root", "Packages", "CustomPlayerList"}, "readme", "Script", {Disabled = true, RunContext = Enum.RunContext.Plugin}},
	{"source", {"ServerScriptService", "Root", "Packages", "CustomPlayerList", "readme"}, [=[
--[[

Name: CustomPlayerList
Summary: A custom player list, opened from a TopbarPlus "Leaderboard" icon.
Author: Waynely (coocoocrazyhead)

C.Graphics.PlayerList: the list UI.
C.Backend.AllPlayers.PlayerListBackend: per-player hook (currently a stub).

]]
]=]},
	{"replace", {"ServerScriptService", "Root", "Packages", "E2BP", "S.RemoteReceivers", "updateSettings"}, "game.ServerStorage.DSTemplate", "game.ServerScriptService.Root.Data.DSTemplate"},
	{"replace", {"ServerScriptService", "Root", "Packages", "E2BP", "S.RemoteReceivers", "fetchSetting"}, "game.ServerStorage.DSTemplate", "game.ServerScriptService.Root.Data.DSTemplate"},
	{"replace", {"ServerScriptService", "Root", "Packages", "E2BP", "S.RemoteReceivers", "Rebirth"}, "game.ServerStorage.DSTemplate", "game.ServerScriptService.Root.Data.DSTemplate"},
	{"replace", {"ServerScriptService", "Root", "Packages", "E2BP", "S.RemoteReceivers", "Preferences"}, "game.ServerStorage.DSTemplate", "game.ServerScriptService.Root.Data.DSTemplate"},
	{"replace", {"ServerScriptService", "Root", "Packages", "DSPlayers", "config"}, "game.ServerStorage.StudioDSTemplate", "game.ServerScriptService.Root.Data.StudioDSTemplate"},
	{"replace", {"ServerScriptService", "Root", "Packages", "DSPlayers", "config"}, "game.ServerStorage.DSTemplate", "game.ServerScriptService.Root.Data.DSTemplate"},
	{"new", {"ServerScriptService", "Root", "Packages", "E2BP"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "E2BP", "requirements"}, [[
return {
	"BasePartEmission";
	"Communications";
	"CustomTools";
	"DSClientRoot";
	"DSPlayers";
	"Easing";
	"Inventory";
	"Notifications";
	"ReplicatedVariables";
	"RequiringUtilities";
	"SeriesMath";
	"Signal";
	"UserInterface";
	"Utilities";
	"ValueObjectVariables";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "UserInterface", "requirements"}, [[
return {
	"DSClientRoot";
	"Easing";
	"Signal";
}
]]},
	{"new", {"ServerScriptService", "Root", "Packages", "ValueObjectVariables"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "ValueObjectVariables", "requirements"}, [[
return {
	"DSPlayers";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "CustomTools", "requirements"}, [[
return {
	"Communications";
	"ControlsExtension";
	"DSClientRoot";
	"Signal";
	"Utilities";
	"ValueObjectVariables";
}
]]},
	{"new", {"ServerScriptService", "Root", "Packages", "RemapShiftLock"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "RemapShiftLock", "requirements"}, [[
return {
	"DSClientRoot";
}
]]},
	{"new", {"ServerScriptService", "Root", "Packages", "BasePartEmission"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "BasePartEmission", "requirements"}, [[
return {
	"DSClientRoot";
	"Easing";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "Notifications", "requirements"}, [[
return {
	"Communications";
	"DSClientRoot";
	"UserInterface";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "ReplicatedVariables", "requirements"}, [[
return {
	"Communications";
	"DSClientRoot";
	"DSPlayers";
	"Signal";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "Crafting", "requirements"}, [[
return {
	"Communications";
	"DSClientRoot";
	"Inventory";
	"InventoryMenus";
	"Signal";
	"UserInterface";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "InventoryMenus", "requirements"}, [[
return {
	"DSClientRoot";
	"Inventory";
	"Signal";
	"UserInterface";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "ControlsExtension", "requirements"}, [[
return {
	"DSClientRoot";
	"UserInterface";
}
]]},
	{"new", {"ServerScriptService", "Root", "Packages", "Communications"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "Communications", "requirements"}, [[
return {
	"CallbackLoading";
	"DSClientRoot";
}
]]},
	{"new", {"ServerScriptService", "Root", "Packages", "DSPlayers"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "DSPlayers", "requirements"}, [[
return {
	"ValueObjectVariables";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "Inventory", "requirements"}, [[
return {
	"Communications";
	"CustomTools";
	"DSClientRoot";
	"DSPlayers";
	"Signal";
	"UserInterface";
	"ValueObjectVariables";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "DSClientRoot", "requirements"}, [[
return {
	"DSPlayers";
}
]]},
	{"new", {"ServerScriptService", "Root", "Packages", "Products"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "Products", "requirements"}, [[
return {
	"E2BP";
	"Utilities";
}
]]},
	{"source", {"ServerScriptService", "Root", "Packages", "CustomPlayerList", "requirements"}, [[
return {
	"DSClientRoot";
	"E2BP";
	"UserInterface";
}
]]},
	{"new", {"ServerScriptService", "Root", "Packages", "Utilities"}, "requirements", "ModuleScript", {}},
	{"source", {"ServerScriptService", "Root", "Packages", "Utilities", "requirements"}, [[
return {
	"Signal";
}
]]},
}

local HANDLERS = {
	move = function(from, to, name)
		local inst, parent = resolve(from), resolve(to)
		if not inst then return `missing {show(from)}` end
		if not parent then return `missing destination {show(to)}` end
		if parent:FindFirstChild(name) then return `{show(to)}/{name} already exists` end
		inst.Name = name
		inst.Parent = parent
	end,
	fold = function(from, into)
		local copy, component = resolve(from), resolve(into)
		if not copy then return `nothing deployed at {show(from)}` end
		if not component then return `missing component {show(into)}` end
		fold(copy, component)
		copy:Destroy()
	end,
	destroy = function(path)
		local inst = resolve(path)
		if not inst then return `missing {show(path)}` end
		inst:Destroy()
	end,
	prune = function(path)
		local inst = resolve(path)
		if not inst then return `missing {show(path)}` end
		if #inst:GetChildren() > 0 then return `{show(path)} is not empty; kept` end
		inst:Destroy()
	end,
	retire = function(path)
		local inst = resolve(path)
		if not inst then return `missing {show(path)}` end
		local leftover = false
		for _, child in inst:GetChildren() do
			if hasContent(child) or not child:IsA("Folder") then leftover = true end
		end
		if leftover then
			inst.Name = inst.Name .. " (old root)"
			inst.Parent = unusedFolder()
			return `{show(path)} still had content; moved to ServerStorage.Unused`
		end
		inst:Destroy()
	end,
	folder = function(parentPath, name)
		local parent = resolve(parentPath)
		if not parent then return `missing {show(parentPath)}` end
		if parent:FindFirstChild(name) then return end
		local f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end,
	new = function(parentPath, name, className, props)
		local parent = resolve(parentPath)
		if not parent then return `missing {show(parentPath)}` end
		if parent:FindFirstChild(name) then return end
		local s = Instance.new(className)
		s.Name = name
		for k, v in props do s[k] = v end
		s.Parent = parent
	end,
	source = function(path, src)
		local inst = resolve(path)
		if not inst then return `missing {show(path)}` end
		inst.Source = src
	end,
	replace = function(path, old, new)
		local inst = resolve(path)
		if not inst then return `missing {show(path)}` end
		local s = inst.Source
		local i = string.find(s, old, 1, true)
		if not i then return `{show(path)} no longer contains {old}` end
		local parts = s:split(old)
		inst.Source = table.concat(parts, new)
	end,
}

return function()
	local recording
	pcall(function()
		recording = ChangeHistoryService:TryBeginRecording("Package migration")
	end)

	local done, skipped = 0, 0
	for i, op in OPS do
		local ok, problem = pcall(HANDLERS[op[1]], table.unpack(op, 2))
		if not ok or problem then
			skipped += 1
			warn(`[Migrate] step {i} ({op[1]}): {if ok then problem else "error: " .. tostring(problem)}`)
		else
			done += 1
		end
	end

	if recording then
		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	else
		pcall(function() ChangeHistoryService:SetWaypoint("Package migration") end)
	end
	print(`[Migrate] {done} steps applied, {skipped} skipped. Press Play and check Output for loader warnings.`)
end
