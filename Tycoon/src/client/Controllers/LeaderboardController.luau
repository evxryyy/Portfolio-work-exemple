local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Components = script.Parent.Parent.Components

local Packets = require(ReplicatedStorage.Packages.Packets)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)
local LeaderboardComponent = require(Components.LeaderboardComponent)

local updateDelay = 60

local module = {}
module.__index = module

function module.__AutoUpdateLeaderboard()
	return task.spawn(function()
		while (true) do
			local GetLeaderboardPages = Packets.GetLeaderboardPagesPacket:InvokeServer()
			LeaderboardComponent:InitLeaderboard(GetLeaderboardPages)
			task.wait(updateDelay)
		end
	end)
end

function module:Start()
	return self.__AutoUpdateLeaderboard()
end

return module