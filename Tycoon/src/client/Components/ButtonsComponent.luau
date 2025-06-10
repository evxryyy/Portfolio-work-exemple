local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Types = require(script.Parent.ButtonsTypes)

export type ButtonType = {
	Default : Types.ButtonNormal,
	Robux : Types.ButtonRobux
}

local types = {
	Normal =	"ButtonNormal";
	Robux  =	"ButtonRobux",
}

local module = {}
module.__index = module
module.buttons = {}

function module.ConstructButtonConnection(ButtonModel : Model)
	if(not ButtonModel) then return end
	if(not ButtonModel:GetAttribute("Type")) then return end
	local ButtonModule = require(script.Parent:FindFirstChild(types[ButtonModel:GetAttribute("Type")]))
	ButtonModule:Construct(ButtonModel)
	return ButtonModule
end

return module
