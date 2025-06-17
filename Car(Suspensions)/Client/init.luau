local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CarModule = require(ReplicatedStorage:WaitForChild("Car"))

local CarShopUI = Players.LocalPlayer.PlayerGui:WaitForChild("CarShopUI")
local SpawnFrame = CarShopUI:WaitForChild("SpawnFrame")
local DeleteFrame = CarShopUI:WaitForChild("DeleteFrame")

local IsCarInit = false

local function onSpawn()
	if(IsCarInit) then return end
	local SpawnCarState = Remotes.CarState:InvokeServer()
	if(not SpawnCarState) then return end
	IsCarInit = CarModule.GetCar(workspace:WaitForChild(SpawnCarState))
	IsCarInit:SetOrientation(Vector3.new(0,0,90))
	IsCarInit:SetTweenConfiguration(TweenInfo.new(0.2))
	IsCarInit:ConnectCar(function(CurrentSpeed)
		if(IsCarInit:IsBackward()) then
			CurrentSpeed /= 4
			return CurrentSpeed
		end
	end)
	DeleteFrame.Visible = true
end

local function onDespawn()
	if(not IsCarInit) then return end
	local DespawnCarState = Remotes.CarState:InvokeServer("Despawn")
	if(not DespawnCarState) then return end
	IsCarInit:Destroy()
	IsCarInit = false
	DeleteFrame.Visible = false
end

SpawnFrame.TextLabel.Activated:Connect(onSpawn)
DeleteFrame.TextLabel.Activated:Connect(onDespawn)
