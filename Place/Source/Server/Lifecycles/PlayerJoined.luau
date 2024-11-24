--[[
	Responsible for calling `OnPlayerAdded` on all modules in the `singletons` folder.

	see https://www.notion.so/Singletons-136b54502032800eb4cef7fc0a9b86c7
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	Players.PlayerAdded:Connect(function(player: Player)
		Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnPlayerAdded", player)
	end)

	for _, player in Players:GetPlayers() do
		task.defer(function()
			Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnPlayerAdded", player)
		end)
	end
end
