--[[
	Responsible for returning the keep for the player data - keeps are cached so you can call this function
		multiple times without any issues.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local DataKeep = require(ServerScriptService.Packages.DataKeep)

local getPlayerStore = require(ReplicatedStorage.Shared.Utilities.Data.getPlayerStore)

return function(
	player: Player,
	loadMethod: string?
): Promise.TypedPromise<DataKeep.Keep<getPlayerStore.PlayerData, any>>
	local playerStore = getPlayerStore:expect()

	return playerStore
		:LoadKeep(`{player.UserId}`, function()
			return loadMethod or DataKeep.Enums.LoadMethod.Cancel
		end)
		:andThen(function(keep)
			keep:Reconcile()
			keep:AddUserId(player.UserId)

			return keep
		end)
end
