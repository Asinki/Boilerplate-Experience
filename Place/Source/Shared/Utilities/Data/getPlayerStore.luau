--[[
	Responsible for returning the Store that holds the player data
]]

local ServerScriptService = game:GetService("ServerScriptService")

local DataKeep = require(ServerScriptService.Packages.DataKeep)

local playerData = {}

export type PlayerData = typeof(playerData)

return DataKeep.GetStore("DubitLorealIntegration_Persistence", playerData, {})
