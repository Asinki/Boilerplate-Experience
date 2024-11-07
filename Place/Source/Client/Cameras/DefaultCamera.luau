--[[
	Responsible for being the default player camera in this experience.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CameraProfiler = require(ReplicatedStorage.Packages.CameraProfiler)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Sift = require(ReplicatedStorage.Packages.Sift)

local CameraTypes = require(ReplicatedStorage.Shared.Types.Camera)
local TroveTypes = require(ReplicatedStorage.Shared.Types.Trove)

local DefaultCamera = {}

function DefaultCamera.OnActivated(self: DefaultCamera)
	self.Trove = Trove.new()

	self.Instance.CameraSubject = Players.LocalPlayer.Character
	self.Instance.CameraType = Enum.CameraType.Custom
	self.Instance.FieldOfView = 70

	self.Trove:Connect(Players.LocalPlayer.CharacterAdded, function(character)
		self.Instance.CameraSubject = character
	end)
end

function DefaultCamera.OnDeactivated(self: DefaultCamera)
	self.Trove:Destroy()
end

export type DefaultCamera = CameraTypes.Camera & typeof(DefaultCamera) & {
	Trove: TroveTypes.Trove,
}

return Sift.Dictionary.merge(CameraProfiler.Camera.new("DefaultCamera"), DefaultCamera)
