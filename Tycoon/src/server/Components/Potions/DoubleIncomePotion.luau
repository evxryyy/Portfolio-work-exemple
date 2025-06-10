local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Packets = require(ReplicatedStorage.Packages.Packets)
local Types = require(script.Parent.Types)
local Events = require(script.Parent.Events)
local DataStoreService = require(script.Parent.Parent.Parent.Services.DataStoreService)
local Peek = require(ReplicatedStorage.Packages.Fusion).peek

local module = {}
module.__index = module
module._GlobalActivesPotions = {}

module.new = function(player : Player)
	if(not player) then return end
	if(module._GlobalActivesPotions[player]) then 
		return module._GlobalActivesPotions[player] 
	end
	local self = setmetatable({},module)
	self.plr = player
	self.PotionInitialized = {
		Use = function(plr : Player,Data : Types.DoubleIncomePotion)
			if(not plr) then return end
			if(not plr.Character) then return end
			local character = plr.Character or plr.CharacterAdded:Wait()
			local data = DataStoreService.GetDataStore(plr)
			if(data) then
				if(not data.Value.Potions) then
					data.Value.Potions = {}
				end
				if(data.Value.Potions["DoubleIncomePotion"]) then
					data.Value.Potions["DoubleIncomePotion"] -= 1
					if(data.Value.Potions["DoubleIncomePotion"] <= 0) then
						data.Value.Potions["DoubleIncomePotion"] = nil
					end
				end
			end
			if(script.Parent.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotionDuration")) then
				local duration = script.Parent.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotionDuration")
				duration.Value += Data.Duration
			end
			local asset = ReplicatedStorage.Assets.Potions.DoubleIncomePotion.Handle:Clone()
			asset.Parent = character:FindFirstChild("LeftHand")
			if(not script.Parent.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotion")) then
				local potionValue = Instance.new("BoolValue",script.Parent.DoubleIncomeActivesPotions)
				potionValue.Name = player.Name.."DoubleIncomePotion"
				potionValue.Value = true
			end
			if(not script.Parent.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotionDuration")) then
				local duration = Instance.new("IntValue",script.Parent.DoubleIncomeActivesPotions)
				duration.Name = player.Name.."DoubleIncomePotionDuration"
				duration.Value = Data.Duration
			end
			local motor6d = Instance.new("Motor6D",character:FindFirstChild("LeftHand"))
			motor6d.Part0 = character:FindFirstChild("LeftHand")
			motor6d.Part1 = asset
			motor6d.Name = "PotionHandle"
			motor6d.C1 = CFrame.new(0,0,0) * CFrame.fromOrientation(math.rad(90),math.rad(90),0)
			return asset,motor6d
		end,
		StopUsage = function(plr)
			if(not plr) then return end
			if(not plr.Character) then return end
			local character = plr.Character or plr.CharacterAdded:Wait()
			if(not script.Parent.DoubleIncomeActivesPotions:FindFirstChild(plr.Name.."DoubleIncomePotion")) then return end
			xpcall(function()
				script.Parent.DoubleIncomeActivesPotions:FindFirstChild(plr.Name.."DoubleIncomePotion"):Destroy()
				script.Parent.DoubleIncomeActivesPotions:FindFirstChild(plr.Name.."DoubleIncomePotionDuration"):Destroy()
				character.LeftHand:FindFirstChild("Handle"):Destroy()
				character.LeftHand:FindFirstChild("PotionHandle"):Destroy()
			end,warn)
		end,
	}
	module._GlobalActivesPotions[player] = self
	return self
end

module.Activate = function(self,amount)
	if(not amount) then amount = 1 end
	if(amount <= 0) then amount = 1 end
	if(not self.PotionInitialized) then return end
	local d = 30
	local asset,motor = self.PotionInitialized.Use(self.plr,{
		Duration = d * (amount);
		Mult = 2;
	})
	if(not asset or not motor) then return end
	Packets.AnimatePlayerCharacter:FireClient(self.plr,ReplicatedStorage.Assets.Potions.DoubleIncomePotion.DrinkAnimation)
end

module.Give = function(player : Player)
	return module.new(player)
end

module.Get = function(player)
	return module._GlobalActivesPotions[player]
end

module.OnAnimationEnds = Packets.AnimatePlayerCharacter.OnServerEvent:Connect(function(player: Player, a1: Instance) 
	if(not player) then return end
	local getPotion = module.Get(player)
	local data = DataStoreService.GetDataStore(player)
	if(not getPotion.plr) then return end
	if(player.Character) then
		player.Character.LeftHand:FindFirstChild("Handle"):Destroy()
		player.Character.LeftHand:FindFirstChild("PotionHandle"):Destroy() 
	end
	if(module._GlobalActivesPotions[player].DurationObserver) then return end
	local function observerCallback()
		local getMetadata = module._GlobalActivesPotions[player]
		if(not getMetadata) then return end
		local getObserverData = getMetadata.DurationObserver
		if(not getObserverData) then return end
		local value = Peek(getObserverData.value)
		if(value <= 0) then
			if(data) then
				for i,potionDurationValue in pairs(data.Value) do
					if(i == player.Name.."DoubleIncomePotionDuration") then
						data.Value[player.Name.."DoubleIncomePotionDuration"] = nil
					elseif(i == player.Name.."DoubleIncomePotion") then
						data.Value[player.Name.."DoubleIncomePotion"] = nil
					end
				end
				print(data.Value)
			end
			module._GlobalActivesPotions[player].PotionInitialized.StopUsage(player)
			module._GlobalActivesPotions[player].DurationObserver:stopObserver()
			table.clear(module._GlobalActivesPotions[player])
			module._GlobalActivesPotions[player] = nil
			Packets.DestroyPotionUi:FireClient(player,"DoubleIncomePotion")
		end
	end
	local function startCooldownDuration()
		local getMetadata = module._GlobalActivesPotions[player]
		if(not getMetadata) then return end
		local getObserverData = getMetadata.DurationObserver
		if(not getObserverData) then return end
		local value = getObserverData.value
		local duration = script.Parent.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotionDuration")
		local effect = ReplicatedStorage.Assets.Potions.DoubleIncomePotion.Effect:Clone()
		effect.Parent = player.Character.PrimaryPart
		effect.CFrame = player.Character.Head.CFrame
		effect.CanCollide = false
		effect.Anchored = true;
		task.delay(0.75,function()
			for i,vfx in pairs(effect.Attachment:GetChildren()) do
				if(vfx:IsA("ParticleEmitter")) then
					vfx.Enabled = false
				end
			end
		end)
		Debris:AddItem(effect,1.5)
		duration:GetPropertyChangedSignal("Value"):Connect(function(...: any) 
			value:set(duration.Value)
			Packets.UpdatePotionDuration:FireClient(player,"DoubleIncomePotion",Peek(value))
		end)
		task.spawn(function()
			while(duration) do
				if(not duration) then break end
				if(duration.Value <= 0) then break end
				duration.Value -= 1
				task.wait(1)
			end
		end)
	end
	module._GlobalActivesPotions[player].DurationObserver = Events.newObserver(
		script.Parent.DoubleIncomeActivesPotions:FindFirstChild(player.Name.."DoubleIncomePotionDuration").Value,
		observerCallback
	)
	startCooldownDuration()
end)

return module
