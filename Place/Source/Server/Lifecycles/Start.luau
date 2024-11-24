--[[
	Responsible for calling `OnStart` on all modules in the `singletons` folder.

	see https://www.notion.so/Singletons-136b54502032800eb4cef7fc0a9b86c7
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnStart")
end
