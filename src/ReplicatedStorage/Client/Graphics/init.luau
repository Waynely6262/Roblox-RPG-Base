local ClientRoot = game.ReplicatedStorage.Client
local UIAPI = require(ClientRoot.Graphics.Util.UIAPI)

for i,v in ClientRoot.UserInterface:GetChildren() do
	UIAPI.load(v)
	
end

return {}