local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local FormatNumber = require(ReplicatedStorage.Packages.FormatNumberAlt)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Packets = require(ReplicatedStorage.Packages.Packets)
local Icon = require(ReplicatedStorage.Packages.Icon)

local Workers = require(script.Parent.Workers)

local Constructor = {}
Constructor.__index = Constructor

Constructor.SetTycoonMenu = function()
	return Icon.new()
		:setLabel("Tycoon")
		:setImage("rbxassetid://15125075475")
		:align("Right")
		:setMenu({
		Icon.new()
			:setLabel("Workers")
			:setImage("rbxassetid://12596904697")
			:bindEvent("toggled",function()
				Workers:Construct()
				SoundService:PlayLocalSound(SoundService.UiClick)
			end);
	})
end

table.freeze(Constructor)

local module = {}
module.__index = module
module.TycoonMenu = function() return Constructor.SetTycoonMenu() end
return module