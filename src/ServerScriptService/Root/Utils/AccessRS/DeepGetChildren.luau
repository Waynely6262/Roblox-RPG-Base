local function DeepKVChildren(m: Model | Folder, to: {[string]: {Model}}, ...: string)
	
	if m:IsA("Folder") then
		for _, v in m:GetChildren() do
			DeepKVChildren(v, to, m.Name, ...)
		end
	else
		for _, k in {m.Name, ...} do
		
			to[k] = to[k] or {}
			table.insert(to[k], m)
		end
	end
end

local function DeepGetChildren(m, to: {Model})
	if m:IsA("Folder") then
		for _, v in m:GetChildren() do
			DeepGetChildren(v, to)
		end
	else
		table.insert(to, m)
	end
end

return {
	kv = function(f: Instance)
		local t = {}
		DeepKVChildren(f, t)
		return t
	end;
	t = function(f: Instance)
		local t = {}
		DeepGetChildren(f, t)
		return t
	end;

}