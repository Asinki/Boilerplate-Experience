local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DevSuite = require(ReplicatedStorage.Packages.DevSuite)

return function()
	DevSuite:SetAuthenticationCallback(function(player: Player)
		local rank = player:GetRankInGroup(35175864)

		return rank >= 254
	end)
end
