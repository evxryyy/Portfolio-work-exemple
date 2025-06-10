local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local Packets = require(ReplicatedStorage.Packages.Packets)

local module = {}
module.Gui = require(script.Parent.Gui)

module.OnElementAdded = Packets.AddInventoryElementToPlayer.OnClientEvent:Connect(function(
	data: { ElementName: string, ElementType: string }) 
	module.Gui:AddObjectToList(data)
end)

module.OnPotionAdded = Packets.UpdatePotionDuration.OnClientEvent:Connect(function(elementId: string, duration: number) 
	if(not elementId or not duration) then return end
	module.Gui:AddPotionToList(elementId,duration)
end)

module.OnPotionRemoving = Packets.DestroyPotionUi.OnClientEvent:Connect(function(elementId: string) 
	if(not elementId) then return end
	module.Gui:RemovePotionFromList(elementId)
end)

return module
