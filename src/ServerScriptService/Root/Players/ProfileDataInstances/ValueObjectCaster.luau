--VOC

--[[ Current implemented tasks:

VOCTASK = "Destroy": Removes the value from the table



]]

local Cast
Cast = function(tableName, largeTable: {any})
	
	local Folder = Instance.new("Folder")
	Folder.Name = tableName
	
	local function voc(i,o,c)
		--print(c:GetFullName())
		--warn("VOCTASK connection exists.")
		--warn("Child added to type", Object.ClassName, " - child's name is", c.Name)
		if c.Name == "VOCTASK" then
			if c.Value == "Destroy" then
				largeTable[i] = nil
				o:Destroy()
			else
				warn("Unrecognized VOCTask:", c.Value)
			end
		else

		end

	end
	
	local function add(i,v)
		local Object
		if type(v) == "table" then
			Object = Cast(i,v)
		elseif type(v) == "number" then
			Object = Instance.new("IntValue")
			Object.Value = v

			Object.Changed:Connect(function(newValue)
				largeTable[i] = newValue
			end)

		elseif type(v) == "string" then
			Object = Instance.new("StringValue")
			Object.Value = v

			Object.Changed:Connect(function(newValue)
				largeTable[i] = newValue
			end)	

		elseif type(v) == "boolean" then
			Object = Instance.new("BoolValue")
			Object.Value = v
			Object.Changed:Connect(function(newValue)
				largeTable[i] = newValue
			end)
		else
			warn("Can't cast this value type:", type(v))
		end
		Object.Name = i
		Object.Parent = Folder
		
		Object.ChildAdded:Connect(function(c)
			voc(i,Object, c)
		end)
	end
	
	local alphabeticalOrder = {}
	
	for i, v in largeTable do
		table.insert(alphabeticalOrder, i)
	end
	
	table.sort(alphabeticalOrder, function(a,b) return a < b end)
	
	for _, i in alphabeticalOrder do
		add(i, largeTable[i]) 
	end
	
	
	
	Folder.ChildAdded:Connect(function(child)
		if child.Name ~= "VOCTASK" and child:IsA("ValueBase") then
			largeTable[child.Name] = child.Value
			child.Changed:Connect(function(newValue)
				largeTable[child.Name] = newValue
			end)
			
			child.ChildAdded:Connect(function(c)
				voc(child.Name, child, c)
			end)
		end
	end)
	
	
	
	return Folder
end

return Cast