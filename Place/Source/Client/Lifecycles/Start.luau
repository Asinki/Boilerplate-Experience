local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = require(ReplicatedStorage.Packages.Runtime)

return function(singletons: Folder)
	Runtime:CallMethodOn(Runtime:RequireDescendants(singletons), "OnStart")
end
