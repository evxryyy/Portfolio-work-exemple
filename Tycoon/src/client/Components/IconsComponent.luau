local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local Icon = require(ReplicatedStorage.Packages.Icon)

local Setting = require(script.Parent.Settings)
local Shop = require(script.Parent.Shop)
local InventoryComponent = require(script.Parent.InventoryComponent)

local module = {}
module.__index = module

module.InitMainMenuIcon = function()
	Setting:Construct(false):Destroy()
	local icon = Icon.new()
	icon:setLabel("Menu")
	icon:setImage("rbxassetid://98019440372382")
	icon:setMenu({
		Icon.new()
			:setLabel("Shop")
			:modifyTheme({"Menu", "MaxIcons", 2})
			:setImage("rbxassetid://13429538917")
			:bindEvent("toggled",function()
				Shop:Construct()
				SoundService:PlayLocalSound(SoundService.UiClick)
			end);
		Icon.new()
			:setLabel("Settings")
			:setImage("rbxassetid://96957318452720")
			:bindEvent("toggled",function()
				Setting:Construct()
				SoundService:PlayLocalSound(SoundService.UiClick)
			end);
		Icon.new()
			:setLabel("Bugs/Reports")
			:setImage("rbxassetid://7562374548")
			:bindEvent("toggled",function()
				SoundService:PlayLocalSound(SoundService.UiClick)
			end);
		Icon.new()
			:setLabel("Inventory")
			:setImage("rbxassetid://6870729295")
			:bindEvent("toggled",function()
				InventoryComponent.Gui:Construct()
				SoundService:PlayLocalSound(SoundService.UiClick)
			end)
	})
end

return module

