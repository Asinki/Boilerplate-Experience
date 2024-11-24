--[[
	Type mapping the Memory management dependency we're using in this project.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)

export type Trove = typeof(Trove.new())

return {}
