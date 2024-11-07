local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	Players.PlayerRemoving:Connect(function(player: Player)
		Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnPlayerRemoving", player)
	end)
end
