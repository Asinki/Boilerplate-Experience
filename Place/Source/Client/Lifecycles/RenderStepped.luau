local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	task.defer(function()
		while true do
			RunService.RenderStepped:Wait()

			Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnRenderStepped")
		end
	end)
end
