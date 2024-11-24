--[[
	Responsible for calling `OnStart` on all modules in the `singletons` folder.

	see https://www.notion.so/Singletons-136b54502032800eb4cef7fc0a9b86c7
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	local modules = Runtime:RequireDescendants(singletons)

	table.sort(modules, function(a, b)
		return (a.Priority or 0) > (b.Priority or 0)
	end)

	Runtime:CallMethodOn(modules, "OnStart")
end
