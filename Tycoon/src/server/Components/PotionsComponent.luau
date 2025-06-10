local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packets = require(ReplicatedStorage.Packages.Packets)

local module = {}
module.__index = module

module.DoubleIncomePotion = require(script.Parent.Potions.DoubleIncomePotion)

return module