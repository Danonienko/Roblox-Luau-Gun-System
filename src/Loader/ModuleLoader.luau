-----------------------------
-- SERVICES --
-----------------------------
local RunService = game:GetService("RunService")

-----------------------------
-- VARIABLES --
-----------------------------
local actorForServer = script.ActorForServer
local actorForClient = script.ActorForClient
local isClient = RunService:IsClient()

local tracker = {
	Load = {},
	Init = {},
	Start = {},
}

local trackerForActors = {
	Load = {},
	Init = {},
	Start = {},
}

-- CONSTANTS --
local SETTINGS = {
	FOLDER_SEARCH_DEPTH = 1,
	VERBOSE_LOADING = true,
	WAIT_FOR_SERVER = true,
}

local PRINT_IDENTIFIER = if isClient then "[C]" else "[S]"
local LOADED_IDENTIFIER = if isClient then "Client" else "Server"
local ACTOR_PARENT = if isClient
	then game:GetService("Players").LocalPlayer.PlayerScripts
	else game:GetService("ServerScriptService")

-----------------------------
-- PRIVATE FUNCTIONS --
-----------------------------
local function newPrint(...)
	print(PRINT_IDENTIFIER, ...)
end

local function newWarn(...)
	warn(PRINT_IDENTIFIER, ...)
end

local function loadModule(module: ModuleScript)
	if module:GetAttribute("Parallel") then
		-- This module needs to be run in parallel, so create new actor and script.
		local newActorSystem = if isClient then actorForClient:Clone() else actorForServer:Clone()
		local actorScript = newActorSystem:FindFirstChildWhichIsA("BaseScript")
		actorScript.Name = `Required{module.Name}`
		newActorSystem.Parent = ACTOR_PARENT
		if not actorScript:GetAttribute("Loaded") then
			actorScript:GetAttributeChangedSignal("Loaded"):Wait()
		end
		newActorSystem:SendMessage("RequireModule", module)

		if SETTINGS.VERBOSE_LOADING then
			newPrint(("Loading PARALLEL module '%s'"):format(module.Name))
		end

		local startTime = tick()
		if not actorScript:GetAttribute("Required") then
			actorScript:GetAttributeChangedSignal("Required"):Wait()
		end
		local endTime = tick()

		if SETTINGS.VERBOSE_LOADING then
			if actorScript:GetAttribute("Errored") then
				newWarn(
					`>> Failed to load PARALLEL module {module.Name}`,
					("(took %.3f seconds)"):format(endTime - startTime)
				)
			else
				newPrint(`>> Loaded PARALLEL module {module.Name}`, ("(took %.3f seconds)"):format(endTime - startTime))
			end
		end

		trackerForActors.Load[module] = newActorSystem
		tracker.Load[module] = true
		tracker.Init[module] = true
		tracker.Start[module] = true
		return
	end

	if SETTINGS.VERBOSE_LOADING then
		newPrint(("Loading module '%s'"):format(module.Name))
	end
	local startTime = tick()
	local success, result = pcall(function()
		local loadedModule = require(module)
		tracker.Load[module] = loadedModule

		if loadedModule.Init then
			tracker.Init[module] = false
		end
		if loadedModule.Start then
			tracker.Start[module] = false
		end
	end)
	local endTime = tick()

	if not SETTINGS.VERBOSE_LOADING then
		return
	end

	if success then
		newPrint(`>> Loaded module {module.Name}`, ("(took %.3f seconds)"):format(endTime - startTime))
	else
		newWarn(
			`>> Failed to load module {module.Name}`,
			("(took %.3f seconds)\n%s"):format(endTime - startTime, result)
		)
	end
end

local function initializeModule(loadedModule, module: ModuleScript)
	if trackerForActors.Load[module] then
		local actorScript = trackerForActors.Load[module]:FindFirstChildWhichIsA("BaseScript")
		trackerForActors.Load[module]:SendMessage("InitModule")

		if SETTINGS.VERBOSE_LOADING then
			newPrint(("Initializing PARALLEL module '%s'"):format(actorScript.Name))
		end

		local startTime = tick()
		if not actorScript:GetAttribute("Initialized") then
			actorScript:GetAttributeChangedSignal("Initialized"):Wait()
		end
		local endTime = tick()

		if SETTINGS.VERBOSE_LOADING then
			if actorScript:GetAttribute("Errored") then
				newWarn(
					`>> Failed to init PARALLEL module {actorScript.Name}`,
					("(took %.3f seconds)"):format(endTime - startTime)
				)
			else
				newPrint(
					`>> Initialized PARALLEL module {actorScript.Name}`,
					("(took %.3f seconds)"):format(endTime - startTime)
				)
			end
		end
		return
	end

	if not loadedModule.Init then
		return
	end

	if SETTINGS.VERBOSE_LOADING then
		newPrint(("Initializing module '%s'"):format(module.Name))
	end
	local startTime = tick()
	local success, result = pcall(function()
		loadedModule:Init()
		tracker.Init[module] = true
	end)
	local endTime = tick()

	if not SETTINGS.VERBOSE_LOADING then
		return
	end

	if success then
		newPrint(`>> Initialized module {module.Name}`, ("(took %.3f seconds)"):format(endTime - startTime))
	else
		newWarn(
			`>> Failed to init module {module.Name}`,
			("(took %.3f seconds)\n%s"):format(endTime - startTime, result)
		)
	end
end

local function startModule(loadedModule, module: ModuleScript)
	if trackerForActors.Load[module] then
		local actorScript = trackerForActors.Load[module]:FindFirstChildWhichIsA("BaseScript")
		trackerForActors.Load[module]:SendMessage("StartModule")

		if SETTINGS.VERBOSE_LOADING then
			newPrint(("Starting PARALLEL module '%s'"):format(actorScript.Name))
		end

		local startTime = tick()
		if not actorScript:GetAttribute("Started") then
			actorScript:GetAttributeChangedSignal("Started"):Wait()
		end
		local endTime = tick()

		if SETTINGS.VERBOSE_LOADING then
			if actorScript:GetAttribute("Errored") then
				newWarn(
					`>> Failed to start PARALLEL module {actorScript.Name}`,
					("(took %.3f seconds)"):format(endTime - startTime)
				)
			else
				newPrint(
					`>> Started PARALLEL module {actorScript.Name}`,
					("(took %.3f seconds)"):format(endTime - startTime)
				)
			end
		end
		return
	end

	if not loadedModule.Start then
		return
	end

	if SETTINGS.VERBOSE_LOADING then
		newPrint(("Starting module '%s'"):format(module.Name))
	end

	local startTime = tick()
	local success, result = pcall(function()
		loadedModule:Start()
		tracker.Start[module] = true
	end)
	local endTime = tick()

	if not SETTINGS.VERBOSE_LOADING then
		return
	end

	if success then
		newPrint(`>> Started module {module.Name}`, ("(took %.3f seconds)"):format(endTime - startTime))
	else
		newWarn(
			`>> Failed to start module {module.Name}`,
			("(took %.3f seconds)\n%s"):format(endTime - startTime, result)
		)
	end
end

local function recursiveSearch(
	container: Instance,
	currentDepth: number,
	maxDepth: number,
	callback: (module: ModuleScript) -> nil
)
	for _, child in container:GetChildren() do
		if child:IsA("Folder") then
			if currentDepth >= maxDepth then
				continue
			end
			recursiveSearch(child, currentDepth + 1, maxDepth, callback)
		elseif child:IsA("ModuleScript") then
			callback(child)
		end
	end
end

-----------------------------
-- MAIN --
-----------------------------
local function start(container: Instance)
	if isClient and SETTINGS.WAIT_FOR_SERVER and not workspace:GetAttribute("ServerLoaded") then
		workspace:GetAttributeChangedSignal("ServerLoaded"):Wait()
	end

	if SETTINGS.VERBOSE_LOADING then
		newWarn("=== LOADING MODULES ===")
		recursiveSearch(container, 0, SETTINGS.FOLDER_SEARCH_DEPTH, loadModule)

		newWarn("=== INITIALIZING MODULES ===")
		for module, _ in tracker.Init do
			initializeModule(tracker.Load[module], module)
		end

		newWarn("=== STARTING MODULES ===")
		for module, _ in tracker.Start do
			startModule(tracker.Load[module], module)
		end

		newWarn("=== LOADING FINISHED ===")
	else
		recursiveSearch(container, 0, SETTINGS.FOLDER_SEARCH_DEPTH, loadModule)
		for module, _ in tracker.Init do
			initializeModule(tracker.Load[module], module)
		end
		for module, _ in tracker.Start do
			startModule(tracker.Load[module], module)
		end
	end

	workspace:SetAttribute(`{LOADED_IDENTIFIER}Loaded`, true)
end

return { Start = start }
