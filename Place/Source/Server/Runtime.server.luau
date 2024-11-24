--[[
	Runtime.server.luau is responsible for loading the server & all of it's relevant singletons, listeners, etc.

	this is considered the entrypoint for this experience.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Console = require(ReplicatedStorage.Packages.Console)
local Runtime = require(ReplicatedStorage.Packages.Runtime)

local RUNTIME_MODULES_TO_REQUIRE = table.freeze({
	ServerScriptService.Server.Debug,
	ServerScriptService.Server.Components,
	ServerScriptService.Server.Singletons,
	ServerScriptService.Server.Listeners,
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

	require(ServerScriptService.Server.Lifecycles.Start)(ServerScriptService.Server.Singletons)
	require(ServerScriptService.Server.Lifecycles.PlayerJoined)(ServerScriptService.Server.Singletons)
	require(ServerScriptService.Server.Lifecycles.PlayerLeft)(ServerScriptService.Server.Singletons)
	require(ServerScriptService.Server.Lifecycles.Heartbeat)(ServerScriptService.Server.Singletons)

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

	workspace:SetAttribute("ServerError", exception)
end)
