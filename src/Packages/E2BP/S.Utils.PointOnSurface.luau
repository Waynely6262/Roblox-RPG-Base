local Teams = require(game.ServerScriptService.Root.Other.Teams)

local Map = Teams.get("Map"):getFolder()
local Props = Teams.get("Structures"):getFolder()

local API = {}

local MaxHeight = 64
local CastVector = Vector3.new(0,-MaxHeight,0)
local IncludeProps = RaycastParams.new()
IncludeProps.FilterType = Enum.RaycastFilterType.Include
IncludeProps.FilterDescendantsInstances = {Props, Map}

local ExcludeProps = RaycastParams.new()
ExcludeProps.FilterType = Enum.RaycastFilterType.Include
ExcludeProps.FilterDescendantsInstances = {Map}

function API.includeProps(v: Vector3)
	return workspace:Raycast(v, CastVector, IncludeProps)
end

function API.excludeProps(v: Vector3)
	return workspace:Raycast(v, CastVector, ExcludeProps)
end

return API
