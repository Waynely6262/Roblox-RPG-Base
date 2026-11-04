-- @author unknown (KTP UI Pack)
-- revised by waynely


local Notifications = {}
local E = game.ReplicatedStorage.Remotes.MainE


function Notifications.NotifyClient(player: Player, NotificationText: string, NotificationLevel: number)
	E:FireClient(player, "alert", NotificationText, NotificationLevel)
end

function Notifications.NotifyAllClients(NotificationText: string, NotificationLevel: number)
	E:FireAllClients("alert", NotificationText, NotificationLevel)
end

return Notifications
