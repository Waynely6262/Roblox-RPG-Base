export type limits = {
	stack: number,
	[string]: any,
}

export type data = {
	limits: limits,
	weight: number,
	useViewport: boolean?,
	image: string?,
	displayName: string?,
	[string]: any,
}


local function deepfreeze(t: {any}, entries: {}?)
	entries = entries or {}
	
	if entries[t] then return end
	if not table.isfrozen(t) then
		table.freeze(t)
		entries[t] = true
	end
	
	for _, v in t do
		if typeof(v) == "table" then
			deepfreeze(v, entries)
		end
	end
	return t
end

return deepfreeze(require(game.ReplicatedStorage.Modules.PackageConfig.Inventory).Catalog):: typeof(require(game.ServerScriptService.Root.Packages.Inventory.config).Catalog)