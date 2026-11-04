--!strict
local SKIP = {false}

local Data = {}:: {[any]: {FSet | number | false?}}
-- [1]: Function set
-- [2]: base transparency
-- [3]: content transparency (image, text)

type FSet = {init: (any) -> (), set: (any, number) -> ()}
local Functions: {[string]: FSet} = {}
local OrderedKeys = {}

local function AddQuery(keys: {string}, v: FSet)
	for _, key in keys do
		table.insert(OrderedKeys, key)
		Functions[key] = v
	end
end

local function lerp(i: number, f: number, a: number)
	return i + (f - i) * a
end

AddQuery({"ImageLabel", "ImageButton", "ViewportFrame"}, {
	init = function(Ancestor: ImageLabel | ImageButton)
		if Ancestor.BackgroundTransparency >= 1 and Ancestor.ImageTransparency >= 1 then Data[Ancestor] = SKIP return end
		Data[Ancestor] = {Functions.ImageLabel, Ancestor.BackgroundTransparency, Ancestor.ImageTransparency}
	end,
	set = function(Ancestor: ImageLabel | ImageButton, n: number)
		local Transparencies = Data[Ancestor]
		Ancestor.BackgroundTransparency = lerp(Transparencies[2]:: number, 1, n)
		Ancestor.ImageTransparency = lerp(Transparencies[3]:: number, 1, n)
	end,
})

AddQuery({"TextLabel", "TextBox", "TextButton"}, {
	init = function(Ancestor: TextLabel | TextBox | TextButton)
		if Ancestor.BackgroundTransparency >= 1 and Ancestor.TextTransparency >= 1 then Data[Ancestor] = SKIP return end
		Data[Ancestor] = {Functions.TextLabel, Ancestor.BackgroundTransparency, Ancestor.TextTransparency}
	end,
	set = function(Ancestor: TextLabel | TextBox | TextButton, n: number)
		local Transparencies = Data[Ancestor]
		Ancestor.BackgroundTransparency = lerp(Transparencies[2]:: number, 1, n)
		Ancestor.TextTransparency = lerp(Transparencies[3]:: number, 1, n)
	end,
})

AddQuery({"GuiObject"}, {
	init = function(Ancestor: GuiObject)
		if Ancestor.BackgroundTransparency >= 1 then Data[Ancestor] = SKIP return end
		Data[Ancestor] = {Functions.GuiObject, Ancestor.BackgroundTransparency}
	end,
	set = function(Ancestor: GuiObject, n: number)
		local Transparencies = Data[Ancestor]
		Ancestor.BackgroundTransparency = lerp(Transparencies[2]:: number, 1, n)
	end,
})

AddQuery({"UIStroke"}, {
	init = function(Ancestor: UIStroke)
		if Ancestor.Transparency >= 1 then Data[Ancestor] = SKIP return end
		Data[Ancestor] = {Functions.UIStroke, Ancestor.Transparency}
	end,
	set = function(Ancestor: UIStroke, n: number)
		Ancestor.Transparency = lerp(Data[Ancestor][2]:: number, 1, n)
	end,
})

local API = {}


function API.modify(Ancestor: Instance, alpha: number)
	if Data[Ancestor] then
		if Data[Ancestor][1] then
			(Data[Ancestor][1]:: FSet).set(Ancestor, alpha)
		end

		for _, v in Ancestor:GetChildren() do
			API.modify(v, alpha)
		end
	elseif Ancestor.ClassName == "Folder" then
		for _, v in Ancestor:GetChildren() do
			API.modify(v, alpha)
		end
	end
end

function API.getFunctionSet(Ancestor: Instance): FSet?
	for _, v in OrderedKeys do
		if Ancestor:IsA(v) then
			return Functions[v]
		end
	end
	return nil
end

function API.initialize(Ancestor: Instance, recursive: boolean?)
	if recursive then

		Ancestor.DescendantAdded:Connect(API.initialize:: (Instance) -> ())
		Ancestor.DescendantRemoving:Connect(function(Descendant: Instance)
			Data[Descendant] = nil
		end)

		for _, v in Ancestor:GetDescendants() do
			API.initialize(v)
		end


	end

	if Data[Ancestor] then
		return
	else
		for _, v in OrderedKeys do
			if Ancestor:IsA(v) then
				Functions[v].init(Ancestor)
				break
			end
		end

	end
end

function API.reset(Ancestor: Instance, BaseTransparency: number, ContentTransparency: number?)
	local FSet: FSet?
	if Data[Ancestor] then
		FSet = Data[Ancestor][1]:: FSet?
	else
		FSet = API.getFunctionSet(Ancestor):: FSet?
	end

	assert(FSet, `{Ancestor:GetFullName()} of class {Ancestor.ClassName} is not a valid Transparency element.`)

	if BaseTransparency == 1 and (ContentTransparency == nil or ContentTransparency >= 1) then Data[Ancestor] = nil return end
	Data[Ancestor] = {FSet, BaseTransparency, ContentTransparency:: number?}
	(FSet:: FSet).set(Ancestor, 0)
end

return API