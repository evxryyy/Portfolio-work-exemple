local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes
local CarModule = require(ReplicatedStorage.Car)

local CarActives = {}

local function OnSitEvent(player,newOccupant)
	if(not newOccupant) then
		local getVehicleSeat = CarActives[player].CarData.CarInit:FindFirstChildOfClass("VehicleSeat")
		if(not getVehicleSeat) then return end
		local getClosestAttachment = nil
		local height = -math.huge
		for i,attachment in pairs(getVehicleSeat:GetChildren()) do
			if(attachment.ClassName ~= "Attachment") then continue end
			if(attachment.WorldPosition.Y <= height) then continue end
			height = attachment.WorldPosition.Y
			getClosestAttachment = attachment
		end
		if(not CarActives[player].CarData.LastVehicleSeatOccupant) then return end
		local HumanoidRootPart = CarActives[player].CarData.LastVehicleSeatOccupant.Parent:FindFirstChild("HumanoidRootPart")
		HumanoidRootPart.CFrame = getClosestAttachment.WorldCFrame
		CarActives[player].Proximity.Enabled = true
	else
		CarActives[player].Proximity.Enabled = false
	end
end

local function SetProximityPromptToCar(player)
	if(not player) then return end
	local ChassisClass = CarActives[player].CarData
	local proximity = Instance.new("ProximityPrompt",ChassisClass.CarInit:FindFirstChildOfClass("VehicleSeat"))
	proximity.RequiresLineOfSight = false
	proximity.Triggered:Connect(function(playerWhoTriggered: Player) 
		ChassisClass.CarInit:FindFirstChildOfClass("VehicleSeat"):Sit(playerWhoTriggered.Character.Humanoid)	
	end)
	return proximity
end

Remotes.CarState.OnServerInvoke = function(player,...)
	if(not player) then return end
	if(not ...) then
		local playerCarName = player.Name .. ReplicatedStorage.CarAssets.VanChassis.Name
		local car = ReplicatedStorage.CarAssets.VanChassis:Clone()
		car.Name = playerCarName
		car.Parent = workspace
		CarActives[player] = {
			CarData = CarModule.InitCar(car);
		}
		CarActives[player].CarData:OnSitEvent(function(a0: Humanoid?) 
			OnSitEvent(player,a0)	
		end)
		CarActives[player].Proximity = SetProximityPromptToCar(player)
		CarActives[player].CarData.CarInit:PivotTo(
			player.Character.PrimaryPart.CFrame 
			* CFrame.new(-10,0,0) 
		)
		return playerCarName
	end
	if(CarActives[player]) then
		CarActives[player].CarData:Destroy(true)
		table.clear(CarActives[player])
		CarActives[player] = nil
	end
	return "Despawn"
end
