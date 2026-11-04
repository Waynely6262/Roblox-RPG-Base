--!strict
local ReplicatedStorage = game.ReplicatedStorage

local RebirthData = require(ReplicatedStorage.Modules.Data.Rebirths)
local RebirthGraphics = require(ReplicatedStorage.Client.Graphics.rebirthing)
local RemoteE = ReplicatedStorage.Remotes.MainE
local Finder = require(ReplicatedStorage.Modules.Utility.Finder)

local player = game:GetService("Players").LocalPlayer:: Player

local RebirthNumberVB = Finder.followPathAsync(player, "leaderstats", "Rebirths"):: NumberValue

local requirements = {}
local function checkShowButton()
	if RebirthGraphics.getVisible() then return end
	
	for _,v in requirements do
		if not v then
			return
		end
	end
	
	RebirthGraphics.setVisible(true)
	
end 
local function onRebirthVBChanged(v)
	RebirthGraphics.setNextRebirth(v)
	for componentName, _ in RebirthData.Requirements do
		requirements[componentName] = false
	end
	RebirthGraphics.setVisible(false)
end
RebirthNumberVB.Changed:Connect(onRebirthVBChanged)
onRebirthVBChanged(RebirthNumberVB.Value)

-- contains repeated code because Im currently tweaked out and have a broken keyboard
local types = { 
	Folder = function(componentName, info, currentAmtF)
		
		local currentQuota: number

		local function newRebirth(newRebirthNumber: number)
			currentQuota = info.getNextQuota(newRebirthNumber)
			RebirthGraphics.setComponentProgress(componentName, 0, currentQuota)
		end
		newRebirth(RebirthNumberVB.Value)

		RebirthNumberVB.Changed:Connect(newRebirth)
		local currentAmtF = Finder.followPathAsync(player, table.unpack(info.path)):: Folder

		local function refreshProgress()
			local currentAmt = #currentAmtF:GetChildren()
			RebirthGraphics.setComponentProgress(componentName, currentAmt, currentQuota)
			requirements[componentName] = currentAmt >= currentQuota
			checkShowButton()
		end


		
		currentAmtF.ChildAdded:Connect(refreshProgress)
		currentAmtF.ChildRemoved:Connect(refreshProgress)
		refreshProgress()

	end,

	NumberValue = function(componentName, info)
		local currentQuota: number

		local function newRebirth(newRebirthNumber: number)
			currentQuota = info.getNextQuota(newRebirthNumber)
			RebirthGraphics.setComponentProgress(componentName, 0, currentQuota)
		end
		newRebirth(RebirthNumberVB.Value)

		RebirthNumberVB.Changed:Connect(newRebirth)
		local currentAmtVB = Finder.followPathAsync(player, table.unpack(info.path)):: NumberValue

		local function refreshProgress(currentAmt: number)
			RebirthGraphics.setComponentProgress(componentName, currentAmt, currentQuota)
			requirements[componentName] = currentAmt >= currentQuota
			checkShowButton()
		end


		currentAmtVB.Changed:Connect(refreshProgress)
		refreshProgress(currentAmtVB.Value)

	end
}
for componentName, info in RebirthData.Requirements do
	types[info.expectedType](componentName, info)
end


RebirthGraphics.attemptRebirth:Connect(function()
	RemoteE:FireServer("Rebirth")
end)

local util = {}

return util