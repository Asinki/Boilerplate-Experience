--[[
	Responsible for calling `OnPlayerRemoving` on all modules in the `singletons` folder.

	see https://www.notion.so/Singletons-136b54502032800eb4cef7fc0a9b86c7
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	Players.PlayerRemoving:Connect(function(player: Player)
		Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnPlayerRemoving", player)
	end)
end
