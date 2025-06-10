local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local DataStoreModule = require(ServerStorage.DataStore)
local OrderedDataStoreModule = require(ServerStorage.OrderedDataStore)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumberAlt)
local Signal = require(ReplicatedStorage.Packages.Signal)

local template = {
	Cash = 0;
}

local function stateChanged(state,dataStore)
	if(dataStore.State == true) then return end
	while(dataStore.State == false) do
		if(dataStore:Open(template) ~= "Success") then task.wait(5) end
	end
end

local module = {}
module.__index = {}
module.OrderedDataStoreInstance = OrderedDataStoreModule.OrderedDataStore

function module.OnPlayerAdded(player : Player)
	if(not player) then return end
	local CashOrderedDataStore = OrderedDataStoreModule.New(player.UserId,template.Cash)
	local dataStore = DataStoreModule.new("PlayerData",player.UserId)
	dataStore.StateChanged:Connect(stateChanged)
	stateChanged(dataStore.State,dataStore)
	CashOrderedDataStore.Value = dataStore.Value.Cash
	return dataStore
end

function module.OnPlayerRemoving(player : Player)
	if(not player) then return end
	local dataStore = DataStoreModule.find("PlayerData",player.UserId)
	if(dataStore ~= nil) then dataStore:Destroy() end
end

function module.GetDataStore(player : Player)
	if(not player) then return end
	local dataStore = DataStoreModule.find("PlayerData",player.UserId)
	if(not dataStore) then return end
	return dataStore
end

function module.GetOrderedDataStore(player : Player)
	if(not player) then return end
	local orderedDataStore = OrderedDataStoreModule.New(player.UserId,template.Cash)
	if(not orderedDataStore) then return end
	return orderedDataStore
end

function module.AddToDataStore(player : Player,Object : any | {any}, key : string)
	if(not player) then return end
	if(not Object or not key) then return end
	local dataStore = DataStoreModule.find("PlayerData",player.UserId)
	if(not dataStore) then return end
	dataStore[key] = Object
	return dataStore
end

return module