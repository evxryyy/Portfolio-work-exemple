local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Packets = require(ReplicatedStorage.Packages.Packets)

local module = {}
module.__index = module

local function searchObjectFromName(name : string)
	if(not name) then return end
	if(workspace.Templates:WaitForChild(name)) then return workspace.Templates:WaitForChild(name) end
	return workspace.Templates:FindFirstChild(name,true)
end 

local function onCreatingArrow(Objects : {string})
	local StringToInstance = {}
	for i,ObjName in pairs(Objects) do
		StringToInstance[ObjName] = searchObjectFromName(ObjName)
	end
	for i,instance : Instance in pairs(StringToInstance) do
		if(instance:FindFirstChildOfClass("Attachment")) then
			if(Players.LocalPlayer.Character.PrimaryPart:FindFirstChild(instance.Name)) then continue end
			local beam = ReplicatedStorage.Assets.Plots.Beam:Clone()
			beam.Attachment0 = Players.LocalPlayer.Character.PrimaryPart.RootAttachment
			beam.Attachment1 = instance:FindFirstChildOfClass("Attachment")
			beam.Parent = Players.LocalPlayer.Character.PrimaryPart
			beam.Name = instance.Name
			beam.LightInfluence = 1
			beam.LightEmission = 1
			beam.TextureSpeed = 5
			beam.TextureLength = 20
			beam.FaceCamera = true
			beam.Width1 = 0.1
			beam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)})
		end
	end
end

local function onDestroyingArrow(Objects : string | {string})
	if(type(Objects) == "table") then
		for i,obj in pairs(Objects) do
			if(Players.LocalPlayer.Character.PrimaryPart:FindFirstChild(obj)) then
				Players.LocalPlayer.Character.PrimaryPart:FindFirstChild(obj):Destroy()
			end
		end
	else
		if(Players.LocalPlayer.Character.PrimaryPart:FindFirstChild(Objects)) then
			Players.LocalPlayer.Character.PrimaryPart:FindFirstChild(Objects):Destroy()
		end
	end
end

function module.Start()
	Packets.CreateArrowForPlayer.OnClientEvent:Connect(onCreatingArrow)
	Packets.RemoveArrowFromPlayer.OnClientEvent:Connect(onDestroyingArrow)
end

return module
