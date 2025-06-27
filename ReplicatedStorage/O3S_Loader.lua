--!strict

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

function Loader.LoadModule(path: string | Instance)
	local isServer = RunService:IsServer()
	local modules = {}

	if isServer then
		modules = getServerModules()
	else
		modules = getClientModules()
	end
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
