--!strict

task.wait()
-- for loading the environment in command bar which allows for typechecking and autocomplete
local script = (script or game.Selection:Get()[1]):: typeof(script)

local Versioning = require(script._Root.VersionHistory):: {{string}}
local PackageLoader = require(script._Root.PackageLoader)

print(`Using Package Loader by Waynely V{#Versioning}.{#Versioning[#Versioning]}.{#Versioning[#Versioning][#Versioning[#Versioning]]}`)

local PackagesFolder = script:FindFirstChild("Packages"):: Folder
if not PackagesFolder then
	print("No package folder found")
	return
end

for _, Package in PackagesFolder:GetChildren() do
	PackageLoader.LoadPackage(Package)
end

PackageLoader.AssertRequirements()

if game:GetService("RunService"):IsRunning() then

	assert(script:FindFirstChild("Client") or game.ReplicatedStorage:FindFirstChild("Client"), `Fatal error: client root is missing`).Parent = game.ReplicatedStorage

	local function require_l(m: ModuleScript)
		
		print(`[Server Root] loading {m:GetFullName()}`)

		local s, r = pcall(require,m)
		if not s then
			warn(`[Server Root] could not load {m:GetFullName()} | {r}`)
		end
	end

	-- Preloaded
	task.spawn(require_l,script.Players)

	-- Load everything else

	local function build_shallow(root: Instance)
		for _, v in root:GetChildren() do
			if v:IsA("ModuleScript") then
				task.spawn(require_l,v)
			end
		end
	end

	build_shallow(script)
end
	