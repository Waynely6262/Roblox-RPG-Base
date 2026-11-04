--!strict
local function search(source, insertionLocation: {[string]: any}, context)

	local function tryInsert(identifier: string, f: () -> ())
		if insertionLocation[identifier] then
			warn(`[{context}] Conflicting remote receiver identifier (kept first occurrence): {identifier}; methods: {tostring(f)}, {tostring(RemoteResponses[identifier])}`)
			return
		end
		insertionLocation[identifier] = f
	end

	for _, v in source:GetChildren() do
		if v:IsA("ModuleScript") then
			local s,r = pcall(function()

				local required = require(v)

				if typeof(required) == "table" then
					tryInsert(v.Name, required.onInvoke)

					if required._aliases then
						for _, alias in required._aliases do
							tryInsert(alias, required.onInvoke)
						end
					end
				elseif typeof(required) == "function" then
					tryInsert(v.Name, required)
				else
					warn(`[{context}] Module ({v:GetFullName()}) did not return a valid remote receiver ({typeof(required)})`)
				end
			end)

			if not s then
				warn(`[{context}] Unable to load remote receiver @{v:GetFullName()}: {r}`)
			end

		elseif v:IsA("Folder") then
			search(v, insertionLocation, context)
		end
	end
end

return search