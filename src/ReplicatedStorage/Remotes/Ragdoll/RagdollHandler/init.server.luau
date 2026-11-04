local Players           = game:GetService("Players")
local StarterGui        = game:GetService("StarterGui")

local Remote = script.RemoteEvent

local Player			= Players.LocalPlayer

local Listener

local function onCharacter(Character)
	if not Character then print("Ragdoll not in view") return end
	local Humanoid     = Character:WaitForChild("Humanoid")

	--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	pcall(StarterGui.SetCore,StarterGui, "ResetButtonCallback", true)

	if Listener then Listener:Disconnect() end
	Listener = Remote.OnClientEvent:Connect(function(Ragdolled)
		print(Ragdolled)
		if Ragdolled then
			Humanoid:UnequipTools()
			StarterGui:SetCore("ResetButtonCallback", false)
			--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		else
			StarterGui:SetCore("ResetButtonCallback", true)
			--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)

end
if Player.Character then onCharacter(Player.Character) end
Player.CharacterAdded:Connect(onCharacter)

script.Parent.OnInvoke = function(...)
	Remote:FireServer(...)
end