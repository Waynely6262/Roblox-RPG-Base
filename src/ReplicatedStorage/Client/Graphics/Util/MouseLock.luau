local Gui = game.ReplicatedStorage.Client.UserInterface.PersistentGui
local Modal = Instance.new("TextButton")
Modal.Size = UDim2.new()
Modal.Position = UDim2.new()
Modal.Parent = Gui
Modal.Text = ""

local locks = {}

function Lock(k,v)
	locks[k] = if not v then nil else true
	Modal.Modal = next(locks) ~= nil
end

return Lock