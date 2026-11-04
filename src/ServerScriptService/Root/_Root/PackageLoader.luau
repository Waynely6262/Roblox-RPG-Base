local timestamp = tick()
local IsStudio = game:GetService("RunService"):IsStudio()

local PATH_SPLITTER = "."


local Root = script.Parent.Parent
local ClientRoot = assert(Root:FindFirstChild("Client") or game.ReplicatedStorage:FindFirstChild("Client"), `Fatal error: client root is missing`)
local RootLocations = {
	Server = Root;
	S = Root;
	s = Root;
	
	Client = ClientRoot;
	C = ClientRoot;
	c = ClientRoot;

	ReplicatedStorage = game.ReplicatedStorage;
	RS = game.ReplicatedStorage;
	rs = game.ReplicatedStorage;
}

local function trace_path(v: any, p: {string})

	for _, pointer in p do

		local nextv: Folder | ModuleRoot = v:FindFirstChild(pointer)

		if not nextv then
			nextv = Instance.new("Folder")
			nextv.Name = pointer
			nextv.Parent = v
			warn(`Did not find a {pointer} folder.`)
			--elseif nextv.ClassName ~= "Folder" then
			--	if not ModuleDirectoryWhitelist[pointer] then
			--		warn(`{pointer} was found as a ModuleScript, but is not a whitelisted module directory`)
			--	end
		end
		v = nextv
	end

	return v

end

local PackageConfigFolder = trace_path(RootLocations.RS, {"Modules","PackageConfig"})
;(PackageConfigFolder:: Folder):ClearAllChildren()

local PackageNames = {}
local Requirements = {}
local Special = {
	requirements = function(packageName: string, v: ModuleScript)
		local reqs = require(v)
		for _, v in reqs do
			Requirements[v] = (Requirements[v] or "") .. packageName .. "; "
		end
	end,
	readme = function(packageName: string)
		return
	end,
	config = function(packageName: string, v: ModuleScript)
		local configFile = v:Clone()
		configFile.Name = packageName
		configFile.Parent = PackageConfigFolder
	end,
}

local load_component: (ModuleScript | Folder, string) -> ()
local load_package: (Folder) -> ()

load_package = function(Package: Instance)

	if Package:IsA("ModuleScript") then
		return load_component(Package, "nil")
	end

	if PackageNames[Package.Name] then
		warn(`Duplicate package name {Package.Name}`)
	end
	PackageNames[Package.Name] = true
	
	local Components = Package:GetChildren():: {Folder | ModuleScript}

	for _, Component in Components do
		load_component(Component, Package.Name)
	end
end

load_component = function(Component: Folder | ModuleScript, PackageName: string)

	if IsStudio then
		Component = Component:Clone()
		Component:SetAttribute("_ver", timestamp)
	end

	if Component.Name == "Packages" and Component.ClassName == "Folder" then
		load_package(Component:: Folder)
		return
	elseif Special[Component.Name] then
		Special[Component.Name](PackageName, Component)
		return
	end


	if Component.ClassName == "PackageLink" then return end

	local Path = Component.Name:split("."):: {string}
	if #Path < 2 then warn(`{Component:GetFullName()} of class {Component.ClassName} is not a valid component`) return end

	local ScriptName = table.remove(Path, #Path):: string -- last element
	local RootName = table.remove(Path, 1):: any

	local RootLocation = RootLocations[RootName]

	assert(RootLocation, `Invalid root name: {RootName}`)
	local parent = trace_path(RootLocation, Path):: Instance

	local existing = parent:FindFirstChild(ScriptName)
	if existing then

		if existing.ClassName ~= "Folder" then
			print(`Found a matching item {existing:GetFullName()} conflicting with {Component:GetFullName()}; overwriting..`)
		end
		
		if existing:IsA("LuaSourceContainer") and Component:IsA("LuaSourceContainer") then
			print(`Instances are both LuaSourceContainer. Attempting to compare source..`)
			local s, r = pcall(function()
				if (existing.Source ~= Component.Source) then
					warn(`{Component:GetFullName()} and {existing:GetFullName()} have different sources. Check which version is latest`)
				end
			end)
			if not s then
				print(`Failed to read file sources: {r}`)
			end
		end
		
		local function merge(from: Instance, to: Instance)
			for _, child in from:GetChildren() do
				local existing = to:FindFirstChild(child.Name)
			
				if existing then
					print(`Clashing children for source: {from:GetFullName()}, destination: {to:GetFullName()} {child.Name}`)
					merge(child, existing)
				else
					child.Parent = to
				end
			end
		end
		
		
		merge(existing, Component)
		print(`{Component:GetFullName()} overwrite successful.`)
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
end




return {
	
	LoadPackage = load_package;
	LoadComponent = load_component;
	AssertRequirements = AssertRequirements;
	RootLocations = RootLocations;
}
