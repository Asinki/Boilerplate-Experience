--[[
	Responsible for calling `OnHeartbeat` on all modules in the `singletons` folder.

	see https://www.notion.so/Singletons-136b54502032800eb4cef7fc0a9b86c7
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	task.defer(function()
		while true do
			RunService.Heartbeat:Wait()

			Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnHeartbeat")
		end
	end)
end
