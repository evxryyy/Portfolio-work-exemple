local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Terrain = workspace:WaitForChild("Terrain")

local Signal = require(ReplicatedStorage.Packages.Signal)

local SfxIds = {
	[Enum.Material.Sand] = "rbxassetid://105793766638092";
	[Enum.Material.Grass] = "rbxassetid://114178506366446";
	[Enum.Material.Plastic] = "rbxasset://sounds/action_footsteps_plastic.mp3";
	[Enum.Material.SmoothPlastic] = "rbxasset://sounds/action_footsteps_plastic.mp3";	
}

local module = {}
module.__index = module

module.OnFloorMaterialChanged = Signal.new()

module.FloorMaterialConnectionChanged = module.OnFloorMaterialChanged:Connect(function(floorMaterial : Enum.Material)
	local RunningSound : Sound = Players.LocalPlayer.Character.PrimaryPart:WaitForChild("Running")
	if(SfxIds[floorMaterial]) then
		RunningSound.PlaybackSpeed = 1.7
		if(floorMaterial == Enum.Material.Plastic or floorMaterial == Enum.Material.SmoothPlastic) then
			RunningSound.PlaybackSpeed = 1.85
		end	
		RunningSound.SoundId = SfxIds[floorMaterial]
	end
end)

function module:InitCharacterSounds()
	if(self.FloorMaterialConnection) then
		self.FloorMaterialConnection:Disconnect()
	end
	local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	Players.LocalPlayer.CharacterAdded:Once(function()
		self:InitCharacterSounds()
	end)
	self.FloorMaterialConnection = humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		self.OnFloorMaterialChanged:Fire(humanoid.FloorMaterial)
	end)
end

return module