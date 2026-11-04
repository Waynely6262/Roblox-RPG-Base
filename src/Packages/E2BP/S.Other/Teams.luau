--!strict
-- Manages parenting and query parameters of teamed entities, or just collections of entities (such as an fx folder)
-- for example: to make an fx folder, create an operating team, then add a friendly team called "fx" 
-- The destroying of teams is not implemented
local Class = {}
Class.__index = Class
local Teams = {}
Teams.Class = Class

local MainFolder = workspace
--local MainFolder = Instance.new("Folder")
--MainFolder.Name = "Content"
--MainFolder.Parent = workspace
Teams.RootFolder = MainFolder

local TeamFolders = {}

local RegisteredTeams = {}

function Teams.get(identifier: string): Team
	
	if RegisteredTeams[identifier] then
		return RegisteredTeams[identifier]
	else
		local TeamFolder: Folder? = MainFolder:FindFirstChild(identifier):: Folder?
		
		if not TeamFolder then
			TeamFolder = Instance.new("Folder")
			TeamFolder.Name = identifier
			TeamFolder.Parent = MainFolder
		end
		
		TeamFolders[identifier] = TeamFolder
		local self = setmetatable({
			Name = identifier,
			_friendlies = {}:: {[string]: Team},
			_cachedExclusionList = {}:: {Folder},
			_exclusionListUpToDate = false,
		}, Class):: Team
		self:setFriendlyFireEnabled(false)
		RegisteredTeams[identifier] = self
		return self
	end
end
-- given a model and a team name, inserts model into team folder. If the team folder doesn't exist, one is created
function Teams.accommodate(model: Instance, team: string)
	model.Parent = Teams.get(team):getFolder()
end

function Class.addChild(self: Team, model: Instance)
	model.Parent = self:getFolder()
end

function Class.getFolder(self: Team): Folder
	return TeamFolders[self.Name]
end

function Class.setFriendlyFireEnabled(self: Team, bool: boolean)
	if bool then
		self:removeFriendlyTeam(self)
	else
		self:addFriendlyTeam(self)
	end
end

function Class.removeFriendlyTeam(self: Team, team: Team | string)
	if typeof(team) == "string" then
		team = Teams.get(team)
	end
	local team = team:: Team --typechecker
	if self._friendlies[team.Name] then
		self._friendlies[team.Name] = nil
		self._exclusionListUpToDate = false
	end
end

function Class.addFriendlyTeam(self: Team, team: Team | string)
	if typeof(team) == "string" then
		team = Teams.get(team)
	end
	local team = team:: Team --typechecker
	if not self._friendlies[team.Name] then
		self._friendlies[team.Name] = team
		self._exclusionListUpToDate = false
	end
end

function Class.getExclusionList(self: Team): {Folder}
	if not self._exclusionListUpToDate then
		local friendlies = {}:: {Folder}
		for k, v in self._friendlies do
			table.insert(friendlies, v:getFolder():: Folder)
		end
		self._cachedExclusionList = friendlies
		self._exclusionListUpToDate = true
	end
	return self._cachedExclusionList
end

function Class.getAccompaniedExclusionList(self: Team, t: {Instance})
	local list: {Instance} = table.clone(self:getExclusionList()):: {Instance}
	for k, v in t do
		table.insert(list, v)
	end
	return list
end

export type Team = typeof(setmetatable({}:: {
	Name: string,
	_friendlies: {[string]: Team},
	_cachedExclusionList: {Folder},
	_exclusionListUpToDate: boolean,
}, Class))

return Teams