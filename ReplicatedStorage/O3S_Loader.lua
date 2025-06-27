--------------
-- SERVICES --
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-----------
-- TYPES --
-----------

---------------
-- CONSTANTS --
---------------
local serverModules = ServerScriptService:FindFirstChild("ServerModules")
local clientModules = ReplicatedStorage:WaitForChild("ClientModules")
local sharedModules = ReplicatedStorage:WaitForChild("SharedModules")

---------------
-- VARIABLES --
---------------
local cachedRequiredModules = {} :: { [string]: { [any]: any } }

------------
-- MODULE --
------------
local Loader = {}

-----------------------
-- PRIVATE FUNCTIONS --
-----------------------
local function getServerModules(): { Modulescript }
	local modulesToReturn = {}

	for _, serverModule in ipairs(serverModules:GetChildren() :: { ModuleScript }) do
		modulesToReturn[serverModule.Name] = serverModule
	end

	for _, sharedModule in ipairs(sharedModules:GetChildren() :: { ModuleScript }) do
		modulesToReturn[sharedModule.Name] = sharedModule
	end

	return modulesToReturn
end

local function getClientModules(): { Modulescript }
	local modulesToReturn = {}

	for _, clientModule in ipairs(clientModules:GetChildren() :: { ModuleScript }) do
		modulesToReturn[clientModule.Name] = clientModule
	end

	for _, sharedModule in ipairs(sharedModules:GetChildren() :: { ModuleScript }) do
		modulesToReturn[sharedModule.Name] = sharedModule
	end

	return modulesToReturn
end

---------------------
-- PRIVATE METHODS --
---------------------

----------------------
-- PUBLIC FUNCTIONS --
----------------------

function Loader.LoadModule(path: string | Instance): any
	local isServer = RunService:IsServer()
	local modules = {} :: { ModuleScript }

	if isServer then
		modules = getServerModules()
	else
		modules = getClientModules()
	end

	local requiredModule = nil

	if path:IsA("string") then
		if cachedRequiredModules[path] then
			return cachedRequiredModules[path]
		end
	end

	for _, module in ipairs(modules) do
		if module == path or module.Name == path then
			requiredModule = require(module)
			break
		end
	end

	return requiredModule
end

function Loader.LoadAll(folder: Instance): {}
	local dictionaryToReturn = {}

	for _, module in ipairs(folder:GetChildren()) do
		if not module:IsA("ModuleScript") then
			continue
		end

		if cachedRequiredModules[module.Name] then
			dictionaryToReturn[module.Name] = cachedRequiredModules[module.Name]
			continue
		end

		local requiredModule = require(module)
		dictionaryToReturn[module.Name] = requiredModule
	end

	return dictionaryToReturn
end

function Loader.RequiredOnce(module: ModuleScript): ()
	if cachedRequiredModules[module.Name] then
		return
	end

	cachedRequiredModules[module.Name] = require(module)
end

function Loader.get(moduleName: string): ModuleScript?
	local isServer = RunService:IsServer()
	local modules = {} :: { ModuleScript }

	if cachedRequiredModules[moduleName] then
		return cachedRequiredModules[moduleName]
	end

	if isServer then
		modules = getServerModules()
	else
		modules = getClientModules()
	end

	for _, module in ipairs(modules) do
		if module.Name == moduleName then
			return module
		end
	end
end

function Loader.Register(name: string, module: ModuleScript): () -> nil
	if cachedRequiredModules[module.Name] then
		cachedRequiredModules[name] = cachedRequiredModules[module.Name]
		cachedRequiredModules[module.Name] = nil
	else
		cachedRequiredModules[name] = require(module)
	end

	return function()
		cachedRequiredModules[name] = nil
	end
end

function Loader.IsLoaded(module: ModuleScript): boolean
	return (cachedRequiredModules[module.Name] ~= nil)
end

--------------------
-- PUBLIC METHODS --
--------------------

---------------
-- EXECUTION --
---------------

-------------
-- CLOSING --
-------------
return Loader
