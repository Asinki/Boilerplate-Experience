--[[
	Runtime.client.luau is responsible for loading the client & all of it's relevant singletons, cameras, etc.

	this is considered the entrypoint for this experience.
]]

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Console = require(ReplicatedStorage.Packages.Console)
local Runtime = require(ReplicatedStorage.Packages.Runtime)
local RbxControls = require(ReplicatedStorage.Packages.RbxControls)

local RUNTIME_MODULES_TO_REQUIRE = table.freeze({
	ReplicatedFirst.Client.Debug,
	ReplicatedFirst.Client.Cameras,
	ReplicatedFirst.Client.Components,
	ReplicatedFirst.Client.Interfaces,
	ReplicatedFirst.Client.Singletons,
	ReplicatedFirst.Client.Listeners,
})

local gitBranch = workspace:GetAttribute("GIT_BRANCH")
local gitCommit = workspace:GetAttribute("GIT_COMMIT")
local gitBuild = workspace:GetAttribute("GIT_BUILD")

local scriptStartTime = os.clock()

local runtimeReporter = Console.new(script.Name)
local isProduction = gitBranch == "Master"

Runtime:SetFFValue("Branch", gitBranch)
Runtime:SetFFValue("Commit", gitCommit)
Runtime:SetFFValue("Build", gitBuild)

Runtime:SetFFValue("IsProduction", isProduction)

Runtime:SetFFValue("ShowLoadingScreenInStudio", false)

Console.setGlobalLogLevel(isProduction and Console.LogLevel.Warn or Console.LogLevel.Debug)
Console.setGlobalSchema("[%s][%s] :: %s")

runtimeReporter:Log(`Server Branch: {gitBranch}`)
runtimeReporter:Log(`Server Commit: {gitCommit}`)
runtimeReporter:Log(`Server Build: {gitBuild}`)

if isProduction then
	runtimeReporter:Warn(`Production environment detected, disabling verbose logs!`)
end

xpcall(function()
	local moduleCount = 0

	RbxControls:SetDefaultCoreGui()
	RbxControls:DisableCoreGui()
	RbxControls:DisableCharacterInput()

	GuiService.TouchControlsEnabled = false

	for _, moduleContainer in RUNTIME_MODULES_TO_REQUIRE do
		runtimeReporter:Debug(`Loading runtime modules for '{moduleContainer.Name}'`)

		Runtime:RequireDescendants(moduleContainer, function(instance: ModuleScript)
			runtimeReporter:Debug(`Loading runtime module '{instance.Name}'`)

			-- hack: luau extension expects require to input a string, we're inputting a ModuleScript
			local module = (require :: any)(instance)
			local moduleReturnType = typeof(module)

			if moduleReturnType == "function" then
				module = module()
			end

			moduleCount += 1

			return module
		end)
	end

	runtimeReporter:Debug(`Loaded runtime modules`)
	runtimeReporter:Debug(`Loading Singleton lifecycle methods...`)

	require(ReplicatedFirst.Client.Lifecycles.Start)(ReplicatedFirst.Client.Singletons)
	require(ReplicatedFirst.Client.Lifecycles.PlayerJoined)(ReplicatedFirst.Client.Singletons)
	require(ReplicatedFirst.Client.Lifecycles.PlayerLeft)(ReplicatedFirst.Client.Singletons)
	require(ReplicatedFirst.Client.Lifecycles.Heartbeat)(ReplicatedFirst.Client.Singletons)
	require(ReplicatedFirst.Client.Lifecycles.RenderStepped)(ReplicatedFirst.Client.Singletons)

	runtimeReporter:Debug(`Loaded Singleton lifecycle methods`)
	runtimeReporter:Log(`Loaded {moduleCount} runtime modules in  {os.clock() - scriptStartTime} seconds`)
	runtimeReporter:Log(``)
end, function(exception: string)
	--[[
		Error handling in the case of a critical error, if an error occurs here - the game code is considered borked.

		As a result we should attemtpt to recover from the error - teleport the player to another server, maybe it's just
		this server which is down.
	]]

	local traceback = debug.traceback()

	task.spawn(function()
		runtimeReporter:Debug(traceback)
		runtimeReporter:Critical(exception)
	end)

	if isProduction then
		runtimeReporter:Warn(`Attempting to recover after critical error!`)

		TeleportService:TeleportAsync(game.PlaceId, { Players.LocalPlayer })
	end
end)
